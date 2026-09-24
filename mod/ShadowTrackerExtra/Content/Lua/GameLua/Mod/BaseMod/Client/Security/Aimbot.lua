-- Aimbot.lua
-- Плавный доворот через AddYawInput/AddPitchInput.
-- Если биндинги не экспонированы — молча не работает.

local ASTExtraPlayerController = import("/Script/ShadowTrackerExtra.STExtraPlayerController")
local SecurityCommonUtils = require("GameLua.Mod.BaseMod.Common.Security.SecurityCommonUtils")

-- НАСТРОЙКИ
local fFOVDeg        = 8.0
local fSmoothPerTick = 0.05
local fTickInterval  = 0.016
-- ---------

local function findTarget(uPC, uCamLoc, uCamRot)
    local uMyPawn = uPC:GetCurPawn()
    if not slua.isValid(uMyPawn) then return nil end

    local nMyTeam = uMyPawn.TeamID
    local tAllPawns = Game:GetAllPlayerPawns()
    if not tAllPawns then return nil end

    local uBest, fBestAngle = nil, nil

    for _, uChar in pairs(tAllPawns) do
        if slua.isValid(uChar)
           and uChar.TeamID ~= nMyTeam
           and SecurityCommonUtils.IsHealthStatusAlive(uChar.HealthStatus)
        then
            local uLoc = uChar:GetHeadLocation(true) or uChar:K2_GetActorLocation()
            local uDir = (uLoc - uCamLoc):GetSafeNormal()
            local fDot = math.max(-1.0, math.min(1.0, uDir:Dot(uCamRot:Vector())))
            local fAngle = math.deg(math.acos(fDot))
            if fAngle <= fFOVDeg then
                if not fBestAngle or fAngle < fBestAngle then
                    uBest, fBestAngle = uLoc, fAngle
                end
            end
        end
    end
    return uBest
end

local function shortDelta(a, b)
    local d = math.rad(b - a)
    return math.deg(math.atan2(math.sin(d), math.cos(d)))
end

local function tick()
    local uPC = slua_GameFrontendHUD:GetPlayerController()
    if not Game:IsClassOf(uPC, ASTExtraPlayerController) then return end

    local uCamMgr = uPC.PlayerCameraManager
    if not slua.isValid(uCamMgr) then return end

    local uCamLoc = uCamMgr:GetCameraLocation()
    local uCamRot = uCamMgr:GetCameraRotation()
    if not uCamLoc or not uCamRot then return end

    local uTarget = findTarget(uPC, uCamLoc, uCamRot)
    if not uTarget then return end

    local uDesired = (uTarget - uCamLoc):Rotation()
    local fYaw   = shortDelta(uCamRot.Yaw,   uDesired.Yaw)   * fSmoothPerTick / 2.5
    local fPitch = shortDelta(uCamRot.Pitch, uDesired.Pitch) * fSmoothPerTick / 2.5

    if uPC.AddYawInput   then uPC:AddYawInput(fYaw)     end
    if uPC.AddPitchInput then uPC:AddPitchInput(fPitch) end
end

Game:SetTimer(fTickInterval, true, tick)
print("[MOD] Aimbot: active")
