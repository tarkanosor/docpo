local EngineObjectProxy = require("CoreLib.EngineObjectProxy")

local InGameUI = EngineObjectProxy(function()
    return Infinity.PoE2.getGameStateController():getInGameState():getInGameUI()
end)

return InGameUI
