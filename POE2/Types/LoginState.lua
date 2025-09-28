---@diagnostic disable: missing-return
---@class LoginState : GameState
LoginState = {}

---@return string
function LoginState:getUsername()
end

---@return UIElement
function LoginState:getLoginButton()
end

---@return UIElement
function LoginState:getPasswordTextBox()
end

---@return UIElement
function LoginState:getUsernameTextBox()
end