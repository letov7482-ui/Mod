-- _hook.lua
-- Точка входа мода. Грузит NoReport, Chams, Aimbot по порядку.
-- Вызывается из GameMain.lua через:
--   pcall(function() require("GameLua.Mod.BaseMod.Client.Security._hook").init() end)

local M = {}

local function safeRequire(path)
    local ok, err = pcall(require, path)
    if not ok then
        print("[MOD] failed to load: " .. tostring(path) .. " | " .. tostring(err))
    end
    return ok
end

function M.init()
    -- 1. Глушилка репортов ДО всего остального.
    safeRequire("GameLua.Mod.BaseMod.Client.Security.NoReport")

    -- 2. ESP поверх родной системы.
    safeRequire("GameLua.Mod.BaseMod.Client.Security.Chams")

    -- 3. Aimbot последним — он самый палевный.
    safeRequire("GameLua.Mod.BaseMod.Client.Security.Aimbot")

    print("[MOD] init complete")
end

return M
