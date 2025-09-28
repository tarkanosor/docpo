---@diagnostic disable: missing-return
-- Inference is still finicky (see end of the file for tests), so not used until
-- it works properly...
--
-- Since I don't have engine source, the methods here are just guesses.
--
---@class Container<K, V> : { [K]: V }
Container = {}

---@generic K, V
---@param self Container<K, V>
---@param pos K
---@return V? value
function Container:get(pos)
end

---@generic K, V
---@param self Container<K, V>
---@param pos K
---@param value V
function Container:set(pos, value)
end

---@generic K, V
---@param self Container<K, V>
---@param value V
function Container:add(value)
end

---@generic K, V
---@param self Container<K, V>
---@return number size
---@see https://en.cppreference.com/w/cpp/container/vector/size
function Container:size()
end

---@generic K, V
---@param self Container<K, V>
---@return boolean empty
---@see https://en.cppreference.com/w/cpp/container/vector/empty
function Container:empty()
end

---@generic K, V
---@param self Container<K, V>
---@see https://en.cppreference.com/w/cpp/container/vector/clear
function Container:clear()
end

---@generic K, V
---@param pos K
---@param self Container<K, V>
---@see https://en.cppreference.com/w/cpp/container/vector/erase
function Container:erase(pos)
end

---@generic K, V
---@param self Container<K, V>
---@param pos K
---@param value V
---@see https://en.cppreference.com/w/cpp/container/vector/insert
function Container:insert(pos, value)
end

---@generic K, V
---@param self Container<K, V>
---@return fun():K, V
function Container:pairs()
end

---@generic K, V
---@param self Container<K, V>
---@param pos? K
---@return K?, V?
function Container:next(pos)
end

-- Guessed std::find?
---@generic K, V
---@param self Container<K, V>
---@param first K
---@param last  K
---@param value V
---@return K?
function Container:find(first, last, value)
end

---@generic K, V
---@param self Container<K, V>
---@param value V
---@return K?
function Container:index_of(value)
end

-- Can't specify type parameters on class inheritance yet. Maybe in Sumneko's V3
---@alias Vector<T> Container<number, T>
---@alias UnorderedMap<K, V> Container<K, V>

-- ---@type Container<number, Actor>
-- local foo = {}

-- -- Infers pairs
-- for k, v in pairs(foo) do
-- end

-- -- Infers index
-- local a = foo[1]

-- ---@return Vector<Actor>
-- local function bar()
-- end

-- -- Doesn't infer pairs
-- for k, v in pairs(bar()) do
-- end

-- -- Does infer returns
-- local barr = bar()
-- -- Does infer copies
-- local fooo = foo

-- -- Doesn't infer pairs
-- for k, v in pairs(barr) do
-- end

-- -- Infers pairs
-- for k, v in pairs(fooo) do
-- end

-- -- Infers assigned pairs
-- local x = foo:pairs()
-- for k, v in x do
-- end

-- -- Infers index
-- local b = barr[1]
