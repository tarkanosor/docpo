---@diagnostic disable: missing-return
---@class ImGui
---
--- Signatures are from imgui.h, but no guarantees for correctness because of
--- the translation layer.
---@see https://github.com/ocornut/imgui/blob/master/imgui.h
ImGui = {}

---@class ImVec2
---@field x number
---@field y number

---@return ImVec2
---@param x number
---@param y number
function ImVec2(x, y)
end

---@class ImVec4
---@field x number
---@field y number
---@field z number
---@field w number

---@return ImVec4
---@param x number r for colors.
---@param y number g for colors.
---@param z number b for colors.
---@param w number a for colors.
function ImVec4(x, y, z, w)
end

---@class ImU32

---@class ImFont

---@alias ImGuiID number
---@alias ImGuiKey number
---@alias ImTextureID unknown void*

function ImGui.AlignTextToFramePadding()
end

---@param id string
---@param direction number ImGuiDir
function ImGui.ArrowButton(id, direction)
end

---@param name string
---@param open? boolean
---@param flags? number
---@return boolean
function ImGui.Begin(name, open, flags)
end

---@param id string|integer
---@param size? ImVec2
---@param border? boolean
---@param flags? number
---@return boolean
function ImGui.BeginChild(id, size, border, flags)
end

---@param id string
---@param size? ImVec2
---@param flags? number
---@return boolean
function ImGui.BeginChildFrame(id, size, flags)
end

---@param label string
---@param preview string
---@param flags? number
---@return boolean
function ImGui.BeginCombo(label, preview, flags)
end

---@return boolean
function ImGui.BeginGroup()
end

---@return boolean
function ImGui.BeginMainMenuBar()
end

---@param label string
---@param enabled boolean
---@return boolean
function ImGui.BeginMenu(label, enabled)
end

---@return boolean
function ImGui.BeginMenuBar()
end

---@param id string
---@param flags? number
---@return boolean
function ImGui.BeginPopup(id, flags)
end

---@param id string
---@param flags? number
---@return boolean
function ImGui.BeginPopupContextItem(id, flags)
end

---@param id string
---@param flags? number
---@return boolean
function ImGui.BeginPopupContextVoid(id, flags)
end

---@param id string
---@param flags? number
---@return boolean
function ImGui.BeginPopupContextWindow(id, flags)
end

---@param name string
---@param open? boolean
---@param flags? number
---@return boolean
function ImGui.BeginPopupModal(name, open, flags)
end

---@param id string
---@param flags? number
---@return boolean
function ImGui.BeginTabBar(id, flags)
end

---@param label string
---@param open? boolean
---@param flags? number
---@return boolean
function ImGui.BeginTabItem(label, open, flags)
end

function ImGui.BeginTooltip()
end

---@return boolean
function ImGui.Bullet()
end

---@param text string
function ImGui.BulletText(text)
end

---@param label string
---@param size? ImVec2
---@return boolean clicked
function ImGui.Button(label, size)
end

---@return number
function ImGui.CalcItemWidth()
end

-- TODO: Check?
---@param text string
---@param hideTextAfterDoubleHash boolean?
---@param wrapWidth number?
---@return ImVec2
function ImGui.CalcTextSize(text, hideTextAfterDoubleHash, wrapWidth)
end

---@param label string
---@param value boolean
---@return boolean changed, boolean value
function ImGui.Checkbox(label, value)
end

function ImGui.CloseCurrentPopup()
end

---@param label string
---@param visible? boolean
---@param flags? number
---@return boolean
function ImGui.CollapsingHeader(label, visible, flags)
end

---@param color ImVec4
---@return ImU32
function ImGui.ColorConvertFloat4ToU32(color)
end

---@param r number
---@param g number
---@param b number
---@return number h, number s, number v
function ImGui.ColorConvertHSVtoRGB(r, g, b)
end

---@param h number
---@param s number
---@param v number
---@return number r, number g, number b
function ImGui.ColorConvertRGBtoHSV(h, s, v)
end

---@param color ImU32
---@return ImVec4
function ImGui.ColorConvertU32ToFloat4(color)
end

--- Mutates color, instead of returning?
---@param label string
---@param color ImVec4
---@param flags number
---@return boolean
function ImGui.ColorEdit3(label, color, flags)
end

--- Mutates color, instead of returning?
---@param label string
---@param color ImVec4
---@param flags number
---@return boolean
function ImGui.ColorEdit4(label, color, flags)
end

--- Mutates color, instead of returning?
---@param label string
---@param color ImVec4
---@param flags number
---@return boolean
function ImGui.ColorPicker3(label, color, flags)
end

--- Mutates color, instead of returning?
---@param label string
---@param color ImVec4
---@param flags number
---@param refCol unknown float pointer, effect unknown
---@return boolean
function ImGui.ColorPicker4(label, color, flags, refCol)
end

---@param count number
---@param id? string
---@param border? boolean
function ImGui.Columns(count, id, border)
end

---@param label string
---@param current number index
---@param items string[]
---@return boolean changed, number index
function ImGui.Combo(label, current, items)
end

-- ---@param name string
-- ---@param unit string
-- ---@return MetricsGuiMetric
-- function ImGui.CreateMetricsGuiMetric(name, unit)
-- end

-- ---@return MetricsGuiPlot
-- function ImGui.CreateMetricsGuiPlot()
-- end

---@param label string
---@param value number
---@param speed? number
---@param min? number
---@param max? number
---@param format? string
---@param flags? number
---@return unknown
function ImGui.DragFloat(label, value, speed, min, max, format, flags)
end

---@param label string
---@param values number[]
---@param speed? number
---@param min? number
---@param max? number
---@param format? string
---@param flags? number
---@return unknown
function ImGui.DragFloat2(label, values, speed, min, max, format, flags)
end

---@param label string
---@param values number[]
---@param speed? number
---@param min? number
---@param max? number
---@param format? string
---@param flags? number
---@return unknown
function ImGui.DragFloat3(label, values, speed, min, max, format, flags)
end

---@param label string
---@param values number[]
---@param speed? number
---@param min? number
---@param max? number
---@param format? string
---@param flags? number
---@return unknown
function ImGui.DragFloat4(label, values, speed, min, max, format, flags)
end

---@param label string
---@param value number
---@param speed? number
---@param min? number
---@param max? number
---@param format? string
---@param flags? number
---@return unknown
function ImGui.DragInt(label, value, speed, min, max, format, flags)
end

---@param label string
---@param values number[]
---@param speed? number
---@param min? number
---@param max? number
---@param format? string
---@param flags? number
---@return unknown
function ImGui.DragInt2(label, values, speed, min, max, format, flags)
end

---@param label string
---@param values number[]
---@param speed? number
---@param min? number
---@param max? number
---@param format? string
---@param flags? number
---@return unknown
function ImGui.DragInt3(label, values, speed, min, max, format, flags)
end

---@param label string
---@param values number[]
---@param speed? number
---@param min? number
---@param max? number
---@param format? string
---@param flags? number
---@return unknown
function ImGui.DragInt4(label, values, speed, min, max, format, flags)
end

---@param size ImVec2
function ImGui.Dummy(size)
end

function ImGui.End()
end

function ImGui.EndChild()
end

function ImGui.EndChildFrame()
end

function ImGui.EndCombo()
end

function ImGui.EndGroup()
end

function ImGui.EndMainMenuBar()
end

function ImGui.EndMenu()
end

function ImGui.EndMenuBar()
end

function ImGui.EndPopup()
end

function ImGui.EndTabBar()
end

function ImGui.EndTabItem()
end

function ImGui.EndTooltip()
end

---@return string
function ImGui.GetClipboardText()
end

---@return number
function ImGui.GetColumnIndex()
end

---@param column number index
---@return number
function ImGui.GetColumnOffset(column)
end

---@return number
function ImGui.GetColumnsCount()
end

---@param column? number index
---@return number
function ImGui.GetColumnWidth(column)
end

---@return ImVec2
function ImGui.GetContentRegionAvail()
end

---@return number
function ImGui.GetContentRegionAvailWidth()
end

---@return ImVec2
function ImGui.GetContentRegionMax()
end

---@return ImVec2
function ImGui.GetCursorPos()
end

---@return number
function ImGui.GetCursorPosX()
end

---@return number
function ImGui.GetCursorPosY()
end

---@return ImVec2
function ImGui.GetCursorScreenPos()
end

---@return ImVec2
function ImGui.GetCursorStartPos()
end

---@return ImFont
function ImGui.GetFont()
end

---@return number
function ImGui.GetFontSize()
end

---@return ImVec2
function ImGui.GetFontTexUvWhitePixel()
end

---@return number
function ImGui.GetFrameCount()
end

---@return number
function ImGui.GetFrameHeight()
end

---@return number
function ImGui.GetFrameHeightWithSpacing()
end

---@param id string
---@return ImGuiID
function ImGui.GetID(id)
end

---@return ImVec2
function ImGui.GetItemRectMax()
end

---@return ImVec2
function ImGui.GetItemRectMin()
end

---@return ImVec2
function ImGui.GetItemRectSize()
end


---@return number cursor ImGuiMouseCursor
function ImGui.GetMouseCursor()
end

---@param button number ImGuiMouseButton
---@param threshold number Lock threshold distance
---@return ImVec2
function ImGui.GetMouseDragDelta(button, threshold)
end

---@return ImVec2
function ImGui.GetMousePos()
end

---@return ImVec2
function ImGui.GetMousePosOnOpeningCurrentPopup()
end

---@return number
function ImGui.GetScrollMaxX()
end

---@return number
function ImGui.GetScrollMaxY()
end

---@return number
function ImGui.GetScrollX()
end

---@return number
function ImGui.GetScrollY()
end

---@param column number index
---@return string
function ImGui.GetStyleColorName(column)
end

---@param column number index
---@return ImVec4
function ImGui.GetStyleColorVec4(column)
end

---@return number
function ImGui.GetTextLineHeight()
end

---@return number
function ImGui.GetTextLineHeightWithSpacing()
end

---@return number
function ImGui.GetTime()
end

---@return number
function ImGui.GetTreeNodeToLabelSpacing()
end

---@return ImVec2
function ImGui.GetWindowContentRegionMax()
end

---@return ImVec2
function ImGui.GetWindowContentRegionMin()
end

---@return number
function ImGui.GetWindowContentRegionWidth()
end

---@return number
function ImGui.GetWindowHeight()
end

---@return ImVec2
function ImGui.GetWindowPos()
end

---@return ImVec2
function ImGui.GetWindowSize()
end

---@return number
function ImGui.GetWindowWidth()
end

---@param id ImTextureID
---@param size ImVec2
---@param uv0 ImVec2
---@param uv1 ImVec2
---@param tintColor ImVec4
---@param borderColor ImVec4
function ImGui.Image(id, size, uv0, uv1, tintColor, borderColor)
end

---@param width? number
function ImGui.Indent(width)
end

---@param label string
---@param value number
---@param step? number
---@param stepFast? number
---@param format? string
---@param flags? number
---@return boolean changed, number value
function ImGui.InputFloat(label, value, step, stepFast, format, flags)
end

---@param label string
---@param values number[]
---@param format? string
---@param flags? number
---@return unknown
function ImGui.InputFloat2(label, values, format, flags)
end

---@param label string
---@param values number[]
---@param format? string
---@param flags? number
---@return unknown
function ImGui.InputFloat3(label, values, format, flags)
end

---@param label string
---@param values number[]
---@param format? string
---@param flags? number
---@return unknown
function ImGui.InputFloat4(label, values, format, flags)
end

---@param label string
---@param value number
---@param step? number
---@param stepFast? number
---@param flags? number
---@return boolean changed, number value
function ImGui.InputInt(label, value, step, stepFast, flags)
end

---@param label string
---@param value number
---@param flags? number
---@return unknown
function ImGui.InputInt2(label, value, flags)
end

---@param label string
---@param value number
---@param flags? number
---@return unknown
function ImGui.InputInt3(label, value, flags)
end

---@param label string
---@param value number
---@param flags? number
---@return unknown
function ImGui.InputInt4(label, value, flags)
end

---@param label string
---@param text string
---@param bufferSize integer?
---@param flags? number
---@return boolean changed, string text
function ImGui.InputText(label, text, bufferSize, flags)
end

---@param label string
---@param text string
---@param bufferSize number
---@param size? ImVec2
---@param flags? number
---@return boolean changed, string text
function ImGui.InputTextMultiline(label, text, bufferSize, size, flags)
end

---@param label string
---@param hint string
---@param text string
---@param flags? number
---@return boolean changed, string text
function ImGui.InputTextWithHint(label, hint, text, flags)
end

---@param id string
---@param size? ImVec2
---@param flags? number
---@return boolean
function ImGui.InvisibleButton(id, size, flags)
end

---@return boolean
function ImGui.IsAnyItemActive()
end

---@return boolean
function ImGui.IsAnyItemFocused()
end

---@return boolean
function ImGui.IsAnyItemHovered()
end

---@return boolean
function ImGui.IsAnyMouseDown()
end

---@return boolean
function ImGui.IsItemActivated()
end

---@return boolean
function ImGui.IsItemActive()
end

---@param button? number ImGuiMouseButton
---@return boolean
function ImGui.IsItemClicked(button)
end

---@return boolean
function ImGui.IsItemDeactivated()
end

---@return boolean
function ImGui.IsItemDeactivatedAfterEdit()
end

---@return boolean
function ImGui.IsItemEdited()
end

---@return boolean
function ImGui.IsItemFocused()
end

---@param flags? number ImGuiHoveredFlags
---@return boolean
function ImGui.IsItemHovered(flags)
end

---@return boolean
function ImGui.IsItemToggledOpen()
end

---@return boolean
function ImGui.IsItemVisible()
end

---@param key ImGuiKey
---@return boolean
function ImGui.IsKeyDown(key)
end

---@param key ImGuiKey
---@param repeats? boolean
---@return boolean
function ImGui.IsKeyPressed(key, repeats)
end

---@param key ImGuiKey
---@return boolean
function ImGui.IsKeyReleased(key)
end

---@param button? number ImGuiMouseButton
---@param repeats? boolean
---@return boolean
function ImGui.IsMouseClicked(button, repeats)
end

---@param button? number ImGuiMouseButton
---@return boolean
function ImGui.IsMouseDoubleClicked(button)
end

---@param button? number ImGuiMouseButton
---@return boolean
function ImGui.IsMouseDown(button)
end

---@param button? number ImGuiMouseButton
---@param threshold? number Lock threshold distance
---@return boolean
function ImGui.IsMouseDragging(button, threshold)
end

---@param min ImVec2
---@param max ImVec2
---@param clip? boolean
---@return boolean
function ImGui.IsMouseHoveringRect(min, max, clip)
end

---@param button number ImGuiMouseButton
---@return boolean
function ImGui.IsMouseReleased(button)
end

---@param id string
---@param flags? number
---@return boolean
function ImGui.IsPopupOpen(id, flags)
end

---@param size ImVec2
---@return boolean
---@overload fun(min: ImVec2, max: ImVec2): boolean
function ImGui.IsRectVisible(size)
end

---@return boolean
function ImGui.IsWindowAppearing()
end

---@return boolean
function ImGui.IsWindowCollapsed()
end

---@param flags? number ImGuiFocusedFlags
---@return boolean
function ImGui.IsWindowFocused(flags)
end

---@param flags? number ImGuiHoveredFlags
---@return boolean
function ImGui.IsWindowHovered(flags)
end

---@param label string
---@param format? string
function ImGui.LabelText(label, format, ...)
end

---@param label string
---@param index number
---@param items string[]
---@return boolean changed, string value
function ImGui.ListBox(label, index, items)
end

---@deprecated OBSOLETED in 1.81 (from February 2021)
function ImGui.ListBoxFooter()
end

---@deprecated OBSOLETED in 1.81 (from February 2021)
function ImGui.ListBoxHeader()
end

---@param label string
---@param shortcut string
---@param selected? boolean
---@param enabled? boolean
---@return boolean
function ImGui.MenuItem(label, shortcut, selected, enabled)
end

-- TODO: Unknown
function ImGui.MetricsGuiMetric()
end

-- TODO: Unknown
function ImGui.MetricsGuiPlot()
end

function ImGui.NewLine()
end

function ImGui.NextColumn()
end

---@param id string|ImGuiID
---@param flags? number
function ImGui.OpenPopup(id, flags)
end

function ImGui.PopAllowKeyboardFocus()
end

function ImGui.PopButtonRepeat()
end

function ImGui.PopClipRect()
end

function ImGui.PopDisable()
end

function ImGui.PopFont()
end

function ImGui.PopID()
end

function ImGui.PopItemWidth()
end

---@param count? number
function ImGui.PopStyleColor(count)
end

---@param count? number
function ImGui.PopStyleVar(count)
end

function ImGui.PopTextWrapPos()
end

---@param fraction number
---@param size? ImVec2
---@param overlay? string
function ImGui.ProgressBar(fraction, size, overlay)
end

---@param allow boolean
function ImGui.PushAllowKeyboardFocus(allow)
end

---@param repeats boolean
function ImGui.PushButtonRepeat(repeats)
end

---@param min ImVec2
---@param max ImVec2
---@param intersect boolean intersect_with_current_clip_rect
function ImGui.PushClipRect(min, max, intersect)
end

-- TODO: Unknown
function ImGui.PushDisable()
end

---@param font ImFont
function ImGui.PushFont(font)
end

---@param id string|number
function ImGui.PushID(id)
end

---@param width number
function ImGui.PushItemWidth(width)
end

---@param idx number ImGuiCol
---@param color ImVec4
function ImGui.PushStyleColor(idx, color)
end

---@param idx number ImGuiCol
---@param color unknown
function ImGui.PushStyleColor1(idx, color)
end

---@param idx number ImGuiCol
---@param color unknown
function ImGui.PushStyleColor2(idx, color)
end

---@param id number
---@param value number|ImVec2
function ImGui.PushStyleVar(id, value)
end

---@param id number
---@param value number
function ImGui.PushStyleVar1(id, value)
end

---@param id number
---@param value ImVec2
function ImGui.PushStyleVar2(id, value)
end

---@param x number wrap_local_pos_x
function ImGui.PushTextWrapPos(x)
end

---@param label string
---@param active boolean
---@return boolean changed, boolean active
function ImGui.RadioButton(label, active)
end

---@param button number ImGuiMouseButton
function ImGui.ResetMouseDragDelta(button)
end

---@param offsetFromStartX? number
---@param spacing? number
function ImGui.SameLine(offsetFromStartX, spacing)
end

---@param label string
---@param selected boolean
---@param flags? number
---@param size? ImVec2
---@return boolean changed
function ImGui.Selectable(label, selected, flags, size)
end

function ImGui.Separator()
end

---@param text string
function ImGui.SetClipboardText(text)
end

---@param column number index
---@param offset number x
function ImGui.SetColumnOffset(column, offset)
end

---@param index number
---@param width number
function ImGui.SetColumnWidth(index, width)
end

---@param pos ImVec2
function ImGui.SetCursorPos(pos)
end

---@param x number
function ImGui.SetCursorPosX(x)
end

---@param y number
function ImGui.SetCursorPosY(y)
end

---@param pos ImVec2
function ImGui.SetCursorScreenPos(pos)
end

function ImGui.SetItemAllowOverlap()
end

function ImGui.SetItemDefaultFocus()
end

---@param offset number
function ImGui.SetKeyboardFocusHere(offset)
end

---@param cursor number ImGuiMouseCursor
function ImGui.SetMouseCursor(cursor)
end

---@param open boolean
---@param cond? number ImGuiCond
function ImGui.SetNextItemOpen(open, cond)
end

---@param width number
function ImGui.SetNextItemWidth(width)
end

---@param alpha number
function ImGui.SetNextWindowBgAlpha(alpha)
end

---@param collapsed boolean
---@param cond? number ImGuiCond
function ImGui.SetNextWindowCollapsed(collapsed, cond)
end

---@param size ImVec2
function ImGui.SetNextWindowContentSize(size)
end

function ImGui.SetNextWindowFocus()
end

---@param x number
---@param y number
---@param cond? number ImGuiCond
---@param pivot? ImVec2
function ImGui.SetNextWindowPos(x, y, cond, pivot)
end

---@param size ImVec2
---@param cond? number ImGuiCond
function ImGui.SetNextWindowSize(size, cond)
end

---@param min ImVec2
---@param max ImVec2
function ImGui.SetNextWindowSizeConstraints(min, max)
end

---@param x number
---@param ratio number
function ImGui.SetScrollFromPosX(x, ratio)
end

---@param y number
---@param ratio number
function ImGui.SetScrollFromPosY(y, ratio)
end

---@param ratio? number
function ImGui.SetScrollHere(ratio)
end

---@param ratio? number
function ImGui.SetScrollHereX(ratio)
end

---@param ratio? number
function ImGui.SetScrollHereY(ratio)
end

---@param x number
function ImGui.SetScrollX(x)
end

---@param y number
function ImGui.SetScrollY(y)
end

---@param label string
function ImGui.SetTabItemClosed(label)
end

---@param text string
function ImGui.SetTooltip(text)
end

---@param name string
---@param collapsed boolean
---@param cond? number ImGuiCond
function ImGui.SetWindowCollapsed(name, collapsed, cond)
end

function ImGui.SetWindowFocus()
end

---@param scale number
function ImGui.SetWindowFontScale(scale)
end

---@param pos ImVec2
---@param cond? number ImGuiCond
function ImGui.SetWindowPos(pos, cond)
end

---@param size ImVec2
---@param cond? number ImGuiCond
function ImGui.SetWindowSize(size, cond)
end

---@param label string
---@param rad number
---@param min number
---@param max number
---@param format? string
---@param flags? number
---@return boolean changed, number angle
function ImGui.SliderAngle(label, rad, min, max, format, flags)
end

---@param label string
---@param value number
---@param min number
---@param max number
---@param format? string
---@param flags? number
---@return boolean changed, number value
function ImGui.SliderFloat(label, value, min, max, format, flags)
end

---@param label string
---@param values number[]
---@param min number
---@param max number
---@param format? string
---@param flags? number
---@return unknown
function ImGui.SliderFloat2(label, values, min, max, format, flags)
end

---@param label string
---@param values number[]
---@param min number
---@param max number
---@param format? string
---@param flags? number
---@return unknown
function ImGui.SliderFloat3(label, values, min, max, format, flags)
end

---@param label string
---@param values number[]
---@param min number
---@param max number
---@param format? string
---@param flags? number
---@return unknown
function ImGui.SliderFloat4(label, values, min, max, format, flags)
end

---@param label string
---@param value number
---@param min number
---@param max number
---@param format? string
---@param flags? number
---@return boolean changed, number value
function ImGui.SliderInt(label, value, min, max, format, flags)
end

---@param label string
---@param values number[]
---@param min number
---@param max number
---@param format? string
---@param flags? number
---@return unknown
function ImGui.SliderInt2(label, values, min, max, format, flags)
end

---@param label string
---@param values number[]
---@param min number
---@param max number
---@param format? string
---@param flags? number
---@return unknown
function ImGui.SliderInt3(label, values, min, max, format, flags)
end

---@param label string
---@param values number[]
---@param min number
---@param max number
---@param format? string
---@param flags? number
---@return unknown
function ImGui.SliderInt4(label, values, min, max, format, flags)
end

---@param label string
---@return boolean
function ImGui.SmallButton(label)
end

function ImGui.Spacing()
end

---@param text string
function ImGui.Text(text, ...)
end

---@param text string
function ImGui.TextAnsi(text)
end

---@param color ImVec4
---@param text string
function ImGui.TextColored(color, text, ...)
end

---@param text string
function ImGui.TextDisabled(text, ...)
end

---@param text string
function ImGui.TextUnformatted(text)
end

---@param text string
function ImGui.TextWrapped(text, ...)
end

---@param label string
---@return boolean open
function ImGui.TreeNode(label)
end

---@param label string
---@param flags? number
---@return boolean open
function ImGui.TreeNodeEx(label, flags)
end

function ImGui.TreePop()
end

---@param id string
function ImGui.TreePush(id)
end

---@param width? number
function ImGui.Unindent(width)
end

---@param prefix string
---@param value boolean|number|string
function ImGui.Value(prefix, value)
end

---@param label string
---@param size ImVec2
---@param value number
---@param min number
---@param max number
---@param format? string
---@param flags? number
---@return boolean changed, number value
function ImGui.VSliderFloat(label, size, value, min, max, format, flags)
end

---@param label string
---@param size ImVec2
---@param value number
---@param min number
---@param max number
---@param format? string
---@param flags? number
---@return boolean changed, number value
function ImGui.VSliderInt(label, size, value, min, max, format, flags)
end

---@return number
function ImGui.GetFPS()
end

---@param flags? number
---@return boolean sourceDragActive
function ImGui.BeginDragDropSource(flags)
end

function ImGui.EndDragDropSource()
end

---@return boolean targetDragActive
function ImGui.BeginDragDropTarget()
end

function ImGui.EndDragDropTarget()
end

---@param label string
---@param payload number
---@return boolean accepted
function ImGui.SetDragDropPayload(label, payload)
end

---@return nil|integer payload
function ImGui.GetDragDropPayload()
end

---@param label string
---@return boolean accepted, integer payload
function ImGui.AcceptDragDropPayload(label)
end

---@param label string
---@param xLabel string
---@param yLabel string
---@param times number[]
---@param values number[]
function ImGui.DrawTimePlot(label, xLabel, yLabel, times, values)
end
