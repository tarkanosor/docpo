local Chat = {}

--- Sends a chat message in the game. Return true if the message was sent successfully, false if we did an action that does not send a message (Open chat, etc).
---@param message string
---@return boolean
function Chat.SendMessage(message)
    if not message or message == "" then
        return false
    end

    local chat = Infinity.PoE2.getGameStateController():getInGameState():getInGameUI():getInGameUIElementByType(EInGameUIElement_Chat)
    if not chat then
        print("ERROR: Chat.SendMessage called but Chat UI not found.")
        return false
    end

    if chat:isVisible() then
        chat:changeVisibility(true)
    end

    local chatInput = chat:getChilds()[4]
    if not chatInput then
        print("ERROR: Chat.SendMessage called but Chat input field not found.")
        return false
    end

    if not chatInput:isVisible() then
        chatInput:changeVisibility(true)
    end

    local text = chatInput:getText()
    if text ~= message then
        chatInput:setText(message)
    end

    Infinity.PoE2.ConfirmSendChatMessage()
    return true
end

return Chat
