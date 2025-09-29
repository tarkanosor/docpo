local EngineObjectProxy = require("CoreLib.EngineObjectProxy")

local ServerData = EngineObjectProxy(function()
    return Infinity.PoE2.getGameStateController():getInGameState():getServerData()
end)

return ServerData
