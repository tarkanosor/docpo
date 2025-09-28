---@diagnostic disable: missing-return
---@class GameStateController
GameStateController = {}

---@return LoginState
function GameStateController:getLoginState()
end

---@return boolean
function GameStateController:isInGame()
end

---@return boolean
function GameStateController:isAreaLoading()
end

---@return SelectCharacterState
function GameStateController:getSelectCharacterState()
end

---@return InGameState
function GameStateController:getInGameState()
end

---@return AreaLoadingState
function GameStateController:getAreaLoadingState()
end

---@return WaitingState
function GameStateController:getWaitingState()
end

---@param tState integer
---@return GameState?
function GameStateController:getState(tState)
end

---@param actor Actor
---@return boolean
function GameStateController:isAttackableMonster(actor)
end

---@return table<integer, GameState>
function GameStateController:getAllStates()
end