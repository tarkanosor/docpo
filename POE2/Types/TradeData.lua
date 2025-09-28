---@diagnostic disable: missing-return
---@class TradeData : Object
TradeData = {}

---@return boolean
function TradeData:isNull()
end

--- Seemed like some sort of inventory ID, will have to dig deeper.
---@return number
function TradeData:getId0()
end

--- Seemed like some sort of inventory ID, will have to dig deeper.
---@return number
function TradeData:getId1()
end

--- Returns 0 when trading with an NPC.
---@return number tradeId
function TradeData:getTradeId()
end

--- Returns the name of the trade partner. Nil when trading with an NPC.
---@return string? name
function TradeData:getTradePartner()
end

--- Returns -1 when not trading with an NPC.
---@return number npcId
function TradeData:getNPCId()
end

--- Returns 0x11 | 0b10001 | 17 during an outgoing trade request.
--- Returns 0x12 | 0b10010 | 18 during an incoming trade request.
--- Returns 0x13 | 0b10011 | 19 when both parties have opened/accepted the trade request.
--- Returns 0x17 | 0b10111 | 23 when the player has accepted the trade.
--- Returns 0x1B | 0b11011 | 27 when the parther has accepted the trade.
--- Returns 0x1F | 0b11111 | 31 when both parties have accepted the trade (complete).
---@return number flag
function TradeData:getFlag()
end
