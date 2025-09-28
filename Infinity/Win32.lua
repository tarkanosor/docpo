---@diagnostic disable: missing-return
---@class Infinity.Win32
Infinity.Win32 = {}

---@return number
function Infinity.Win32.GetTickCount()
end

---@return number
function Infinity.Win32.GetSecondsSinceEpoch()
end


--- Get a high resolution timestamp
---@return number timestamp
function Infinity.Win32.GetPerformanceCounter()
end

---@param vkey number Virtual Key Code
---@return number
function Infinity.Win32.GetKeyState(vkey)
end

---@param vkey number Virtual Key Code
---@return number
function Infinity.Win32.GetAsyncKeyState(vkey)
end

---@param text string
function Infinity.Win32.SetClipboardText(text)
end

function Infinity.Win32.TerminateProcess()
end

---@param frequency number
---@param duration number
function Infinity.Win32.Beep(frequency, duration)
end

---@class Infinity.Win32.Enums
Infinity.Win32.Enums = {
    ---@type Enum
    VirtualKeyCode = {}
}
