-- Chams.lua
-- ESP через родную систему Replay_CreateEnemyFrameUI.
-- Тот же API, что использует игра в режиме HawkEye Patrol.

local SecurityCommonUtils = require("GameLua.Mod.BaseMod.Common.Security.SecurityCommonUtils")
local ASTExtraPlayerController = import("/Script/ShadowTrackerExtra.STExtraPlayerController")

local fTickInterval = 0.1

local function getMyTeamID(uPC)
    local uPS = uPC:GetCurPlayerState()
    if not slua.isValid(uPS) then return nil end
    return uPS.TeamID
end

local function tick()
    local uPC = slua_GameFrontendHUD:GetPlayerController()
    if not Game:IsClassOf(uPC, ASTExtraPlayerController) then return end

    local nMyTeam = getMyTeamID(uPC)
    if not nMyTeam then return end

    local uMyPawn = uPC:GetCurPawn()
    if not slua.isValid(uMyPawn) then return end

    local tAllPawns = Game:GetAllPlayerPawns()
    if not tAllPawns then return end

    for _, uChar in pairs(tAllPawns) do
        if slua.isValid(uChar)
           and uChar.TeamID ~= nMyTeam
           and SecurityCommonUtils.IsHealthStatusAlive(uChar.HealthStatus)
           and uChar.Replay_CreateEnemyFrameUI
           and uChar.Replay_SetVisiableOfFrameUI
           and uChar.Replay_IsEnemyFrameUIExisted
        then
            if not uChar:Replay_IsEnemyFrameUIExisted() then
                uChar:Replay_CreateEnemyFrameUI(true, true)
            end
            uChar:Replay_SetVisiableOfFrameUI(true)
        end
    end
end

Game:SetTimer(fTickInterval, true, tick)
print("[MOD] Chams: active")
