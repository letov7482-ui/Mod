-- NoReport.lua
-- Override всех OnReport* в ReplayReportHandler на no-op.
-- Грузится ДО инстанцирования ReplayRecordManager.

local noop = function() end

local overrides = {
    OnReportControlRotationSuddenChange       = noop,
    OnReportSpectatorScopeAvatarInconsistency = noop,
    OnReportForbiddenMoveException            = noop,
    OnReportParachuteAvgSpeed                 = noop,
    OnReportNaNPositionEvent                  = noop,
    OnReportFPPAnimState                      = noop,
    OnReportUIState                           = noop,
    OnReceiveBattleResult                     = noop,
    OnUpdateBattleResultPeriod                = noop,
    OnReportAvatarNetData                     = noop,
    OnReportRescueBtnTrace                    = noop,
}

local ok, ReplayReportHandler = pcall(require, "GameLua.Mod.BaseMod.Client.Replay.ReplayReportHandler")
if not ok or not ReplayReportHandler then
    print("[MOD] NoReport: ReplayReportHandler not found, stubbing via package.loaded")
    package.loaded["GameLua.Mod.BaseMod.Client.Replay.ReplayReportHandler"] = overrides
else
    for k, v in pairs(overrides) do
        ReplayReportHandler[k] = v
    end
    print("[MOD] NoReport: patched ReplayReportHandler")
end

return true
