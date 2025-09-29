local EngineObjectProxy = require("CoreLib.EngineObjectProxy")

local InGameState = EngineObjectProxy(function()
    return Infinity.PoE2.getGameStateController():getInGameState()
end)

return InGameState
