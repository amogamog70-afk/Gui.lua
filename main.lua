-- [[
--    METEOR / WISH STYLE CLICKGUI ENGINE
--    [VERSION 4.0 - GOLD EDITION] 
--    Fixes: Persistent Watermark, Non-GPE Keybind Engine, Standalone ColorPickers.
--    Features: Auto Theme Window, Auto Settings Window, Realtime Redraw Matrix, Full CFG JSON Sync.
-- ]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Stats = game:GetService("Stats")

local Library = {
    Windows = {},
    Registry = {}, 
    ThemeRefreshes = {}, -- Матрица функций для динамической перерисовки элементов
    ToggleKey = Enum.KeyCode.RightShift,
    Visible = true,
    WatermarkEnabled = true
}

local Theme = {
    MainBG = Color3.fromRGB(12, 12, 14),
    TopbarBG = Color3.fromRGB(18, 18, 22),
    ElementBG = Color3.fromRGB(16, 16, 20),
    InnerBoxBG = Color3.fromRGB(8, 8, 10),
    Accent = Color3.fromRGB(221, 43, 110),
    TextMain = Color3.fromRGB(240, 240, 245),
    TextDim = Color3.fromRGB(140, 140, 145),
    Stroke = Color3.fromRGB(26, 26, 32),
    Hover = Color3.fromRGB(24, 24, 30)
}

-- Инициализация директории воркспейса
pcall(function()
    if makefolder then makefolder("Meteor_Configs") end
end)

-- ГЛАВНЫЕ КОНТЕЙНЕРЫ ИНТЕРФЕЙСА (Разделенные для независимой видимости)
local MenuGui = Instance.new("ScreenGui")
MenuGui.Name = "MeteorMenu_Core"
MenuGui.ResetOnSpawn = false

local WatermarkGui = Instance.new("ScreenGui")
WatermarkGui.Name = "MeteorWatermark_Core"
WatermarkGui.ResetOnSpawn = false

pcall(function() 
    MenuGui.Parent = CoreGui 
    WatermarkGui.Parent = CoreGui
end)

if not MenuGui.Parent then
    MenuGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    WatermarkGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
end

-- СТАБИЛЬНЫЙ ДВИЖОК СКРЫТИЯ МЕНЮ (Игнорирует игровые перехваты, кроме чата)
UserInputService.InputBegan:Connect(function(input)
    if UserInputService:GetFocusedTextBox() then return end
    if input.KeyCode == Library.ToggleKey then
        Library.Visible = not Library.Visible
        MenuGui.Enabled = Library.Visible
    end
end)

function Library:UpdateTheme()
    for _, refreshFunc in ipairs(Library.ThemeRefreshes) do
        pcall(refreshFunc)
    end
end

local function applyStroke(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = thickness or 1
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.LineJoinMode = Enum.LineJoinMode.Miter
    stroke.Parent = parent
    return stroke
end

local function tween(object, info, properties)
    local t = TweenService:Create(object, info, properties)
    t:Play()
    return t
end

local function makeDraggable(frame, dragHandle)
    local dragging, dragInput, dragStart, startPos
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

function Library:CreateWindow(windowName, initialPosition)
    local Window = { Elements = {}, Collapsed = false }
    initialPosition = initialPosition or UDim2.new(0, 50, 0, 50)

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = windowName .. "_Window"
    MainFrame.Size = UDim2.new(0, 220, 0, 30)
    MainFrame.Position = initialPosition
    MainFrame.BackgroundColor3 = Theme.MainBG
    MainFrame.BorderSizePixel = 0
    MainFrame.AutomaticSize = Enum.AutomaticSize.Y
    MainFrame.Parent = MenuGui
    local MainFrameStroke = applyStroke(MainFrame, Theme.Stroke, 1)

    local Topbar = Instance.new("TextButton")
    Topbar.Name = "Topbar"
    Topbar.Size = UDim2.new(1, 0, 0, 30)
    Topbar.BackgroundColor3 = Theme.TopbarBG
    Topbar.BorderSizePixel = 0
    Topbar.Text = " " .. windowName
    Topbar.Font = Enum.Font.Code
    Topbar.TextSize = 13
    Topbar.TextColor3 = Theme.TextMain
    Topbar.TextXAlignment = Enum.TextXAlignment.Left
    Topbar.AutoButtonColor = false
    Topbar.Parent = MainFrame

    local AccentLine = Instance.new("Frame")
    AccentLine.Size = UDim2.new(1, 0, 0, 2)
    AccentLine.Position = UDim2.new(0, 0, 1, -2)
    AccentLine.BackgroundColor3 = Theme.Accent
    AccentLine.BorderSizePixel = 0
    AccentLine.Parent = Topbar

    local Container = Instance.new("Frame")
    Container.Name = "Container"
    Container.Size = UDim2.new(1, 0, 0, 0)
    Container.Position = UDim2.new(0, 0, 0, 30)
    Container.BackgroundTransparency = 1
    Container.AutomaticSize = Enum.AutomaticSize.Y
    Container.BorderSizePixel = 0
    Container.Parent = MainFrame

    local ListLayout = Instance.new("UIListLayout")
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Padding = UDim.new(0, 1)
    ListLayout.Parent = Container

    makeDraggable(MainFrame, Topbar)

    Topbar.MouseButton2Click:Connect(function()
        Window.Collapsed = not Window.Collapsed
        Container.Visible = not Window.Collapsed
        MainFrame.AutomaticSize = Window.Collapsed and Enum.AutomaticSize.None or Enum.AutomaticSize.Y
        if Window.Collapsed then MainFrame.Size = UDim2.new(0, 220, 0, 30) end
    end)

    -- Матричное обновление Окна
    table.insert(Library.ThemeRefreshes, function()
        MainFrame.BackgroundColor3 = Theme.MainBG
        MainFrameStroke.Color = Theme.Stroke
        Topbar.BackgroundColor3 = Theme.TopbarBG
        Topbar.TextColor3 = Theme.TextMain
        AccentLine.BackgroundColor3 = Theme.Accent
    end)

    function Window:CreateButton(name, callback)
        callback = callback or function() end
        local ButtonFrame = Instance.new("Frame")
        ButtonFrame.Size = UDim2.new(1, 0, 0, 24)
        ButtonFrame.BackgroundColor3 = Theme.ElementBG
        ButtonFrame.BorderSizePixel = 0
        ButtonFrame.Parent = Container

        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(1, 0, 1, 0)
        Btn.BackgroundTransparency = 1
        Btn.Text = " " .. name
        Btn.Font = Enum.Font.Code
        Btn.TextSize = 11
        Btn.TextColor3 = Theme.TextMain
        Btn.TextXAlignment = Enum.TextXAlignment.Left
        Btn.Parent = ButtonFrame

        Btn.MouseEnter:Connect(function() tween(ButtonFrame, TweenInfo.new(0.1), {BackgroundColor3 = Theme.Hover}) end)
        Btn.MouseLeave:Connect(function() tween(ButtonFrame, TweenInfo.new(0.1), {BackgroundColor3 = Theme.ElementBG}) end)
        Btn.MouseButton1Click:Connect(function()
            ButtonFrame.BackgroundColor3 = Theme.Accent
            tween(ButtonFrame, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Hover})
            callback()
        end)

        table.insert(Library.ThemeRefreshes, function()
            ButtonFrame.BackgroundColor3 = Theme.ElementBG
            Btn.TextColor3 = Theme.TextMain
        end)
    end

    function Window:CreateToggle(name, default, callback, defaultColor, colorCallback)
        local state = default or false
        local currentInstColor = defaultColor or Color3.fromRGB(255,255,255)
        callback = callback or function() end
        local registryKey = windowName .. "_" .. name

        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.Size = UDim2.new(1, 0, 0, 24)
        ToggleFrame.BackgroundColor3 = Theme.ElementBG
        ToggleFrame.BorderSizePixel = 0
        ToggleFrame.AutomaticSize = Enum.AutomaticSize.Y
        ToggleFrame.Parent = Container

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, defaultColor and -50 or -30, 0, 24)
        Label.Position = UDim2.new(0, 6, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = name
        Label.Font = Enum.Font.Code
        Label.TextSize = 11
        Label.TextColor3 = state and Theme.TextMain or Theme.TextDim
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = ToggleFrame

        local Box = Instance.new("TextButton")
        Box.AnchorPoint = Vector2.new(1, 0)
        Box.Size = UDim2.new(0, 14, 0, 14)
        Box.Position = UDim2.new(1, -6, 0, 5)
        Box.BackgroundColor3 = state and Theme.Accent or Theme.InnerBoxBG
        Box.BorderSizePixel = 0
        Box.Text = ""
        Box.Parent = ToggleFrame
        local BoxStroke = applyStroke(Box, Theme.Stroke, 1)

        local function updateToggle()
            Label.TextColor3 = state and Theme.TextMain or Theme.TextDim
            Box.BackgroundColor3 = state and Theme.Accent or Theme.InnerBoxBG
            BoxStroke.Color = state and Theme.Accent or Theme.Stroke
        end

        local function toggle()
            state = not state
            updateToggle()
            callback(state)
        end

        Box.MouseButton1Click:Connect(toggle)
        
        local InvisibleBtn = Instance.new("TextButton")
        InvisibleBtn.Size = UDim2.new(1, defaultColor and -50 or -30, 0, 24)
        InvisibleBtn.BackgroundTransparency = 1
        InvisibleBtn.Text = ""
        InvisibleBtn.Parent = ToggleFrame
        InvisibleBtn.MouseButton1Click:Connect(toggle)

        local ColorPreview, PreviewStroke, PickerContainer, PickerContainerStroke
        if defaultColor and colorCallback then
            local h, s, v = currentInstColor:ToHSV()
            local pickerExpanded = false

            ColorPreview = Instance.new("Frame")
            ColorPreview.AnchorPoint = Vector2.new(1, 0)
            ColorPreview.Size = UDim2.new(0, 14, 0, 14)
            ColorPreview.Position = UDim2.new(1, -25, 0, 5)
            ColorPreview.BackgroundColor3 = currentInstColor
            ColorPreview.BorderSizePixel = 0
            ColorPreview.Parent = ToggleFrame
            PreviewStroke = applyStroke(ColorPreview, Theme.Stroke, 1)

            local ColorBtn = Instance.new("TextButton")
            ColorBtn.Size = UDim2.new(1, 0, 1, 0)
            ColorBtn.BackgroundTransparency = 1
            ColorBtn.Text = ""
            ColorBtn.Parent = ColorPreview

            PickerContainer = Instance.new("Frame")
            PickerContainer.Size = UDim2.new(1, -12, 0, 110)
            PickerContainer.Position = UDim2.new(0, 6, 0, 24)
            PickerContainer.BackgroundColor3 = Theme.InnerBoxBG
            PickerContainer.BorderSizePixel = 0
            PickerContainer.Visible = false
            PickerContainer.Parent = ToggleFrame
            PickerContainerStroke = applyStroke(PickerContainer, Theme.Stroke, 1)

            local SatValCanvas = Instance.new("TextButton")
            SatValCanvas.Size = UDim2.new(0, 150, 0, 100)
            SatValCanvas.Position = UDim2.new(0, 5, 0, 5)
            SatValCanvas.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
            SatValCanvas.BorderSizePixel = 0
            SatValCanvas.Text = ""
            SatValCanvas.AutoButtonColor = false
            SatValCanvas.Parent = PickerContainer

            local WhiteGrad = Instance.new("Frame")
            WhiteGrad.Size = UDim2.new(1, 0, 1, 0)
            WhiteGrad.BorderSizePixel = 0
            WhiteGrad.Parent = SatValCanvas
            local wG = Instance.new("UIGradient")
            wG.Color = ColorSequence.new(Color3.new(1,1,1), Color3.new(1,1,1))
            wG.Transparency = NumberSequence.new(0, 1)
            wG.Parent = WhiteGrad

            local BlackGrad = Instance.new("Frame")
            BlackGrad.Size = UDim2.new(1, 0, 1, 0)
            BlackGrad.BorderSizePixel = 0
            BlackGrad.Parent = SatValCanvas
            local bG = Instance.new("UIGradient")
            bG.Color = ColorSequence.new(Color3.new(0,0,0), Color3.new(0,0,0))
            bG.Transparency = NumberSequence.new(0, 1)
            bG.Rotation = -90
            bG.Parent = BlackGrad

            local Cursor = Instance.new("Frame")
            Cursor.AnchorPoint = Vector2.new(0.5, 0.5)
            Cursor.Size = UDim2.new(0, 4, 0, 4)
            Cursor.Position = UDim2.new(s, 0, 1 - v, 0)
            Cursor.BackgroundColor3 = Color3.new(1,1,1)
            Cursor.BorderSizePixel = 0
            Cursor.Parent = SatValCanvas
            applyStroke(Cursor, Color3.new(0,0,0), 1)

            local HueBar = Instance.new("TextButton")
            HueBar.Size = UDim2.new(0, 15, 0, 100)
            HueBar.Position = UDim2.new(0, 165, 0, 5)
            HueBar.BackgroundColor3 = Color3.new(1,1,1)
            HueBar.BorderSizePixel = 0
            HueBar.Text = ""
            HueBar.AutoButtonColor = false
            HueBar.Parent = PickerContainer

            local HueGrad = Instance.new("UIGradient")
            HueGrad.Rotation = 90
            HueGrad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)),
                ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255,0,255)),
                ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0,0,255)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,255,255)),
                ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0,255,0)),
                ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255,255,0)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,0))
            })
            HueGrad.Parent = HueBar

            local HueCursor = Instance.new("Frame")
            HueCursor.Size = UDim2.new(1, 4, 0, 2)
            HueCursor.Position = UDim2.new(0, -2, 1 - h, 0)
            HueCursor.BackgroundColor3 = Color3.new(1,1,1)
            HueCursor.BorderSizePixel = 0
            HueCursor.Parent = HueBar
            applyStroke(HueCursor, Color3.new(0,0,0), 1)

            local function fireUpdate()
                currentInstColor = Color3.fromHSV(h, s, v)
                ColorPreview.BackgroundColor3 = currentInstColor
                SatValCanvas.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                colorCallback(currentInstColor)
            end

            local draggingCanvas = false
            local function updateCanvas(input)
                local scaleX = math.clamp((input.Position.X - SatValCanvas.AbsolutePosition.X) / SatValCanvas.AbsoluteSize.X, 0, 1)
                local scaleY = math.clamp((input.Position.Y - SatValCanvas.AbsolutePosition.Y) / SatValCanvas.AbsoluteSize.Y, 0, 1)
                s = scaleX
                v = 1 - scaleY
                Cursor.Position = UDim2.new(s, 0, scaleY, 0)
                fireUpdate()
            end

            SatValCanvas.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingCanvas = true updateCanvas(input) end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if draggingCanvas and input.UserInputType == Enum.UserInputType.MouseMovement then updateCanvas(input) end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingCanvas = false end
            end)

            local draggingHue = false
            local function updateHue(input)
                local scaleY = math.clamp((input.Position.Y - HueBar.AbsolutePosition.Y) / HueBar.AbsoluteSize.Y, 0, 1)
                h = 1 - scaleY
                HueCursor.Position = UDim2.new(0, -2, scaleY, 0)
                fireUpdate()
            end

            HueBar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingHue = true updateHue(input) end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if draggingHue and input.UserInputType == Enum.UserInputType.MouseMovement then updateHue(input) end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingHue = false end
            end)

            ColorBtn.MouseButton1Click:Connect(function()
                pickerExpanded = not pickerExpanded
                PickerContainer.Visible = pickerExpanded
                PreviewStroke.Color = pickerExpanded and Theme.Accent or Theme.Stroke
            end)
        end

        table.insert(Library.ThemeRefreshes, function()
            ToggleFrame.BackgroundColor3 = Theme.ElementBG
            updateToggle()
            if defaultColor and colorCallback then
                PreviewStroke.Color = Theme.Stroke
                PickerContainer.BackgroundColor3 = Theme.InnerBoxBG
                PickerContainerStroke.Color = Theme.Stroke
            end
        end)

        Library.Registry[registryKey] = {
            Type = "Toggle",
            Get = function()
                return {
                    State = state,
                    Color = defaultColor and {currentInstColor.R, currentInstColor.G, currentInstColor.B} or nil
                }
            end,
            Set = function(self, data)
                state = data.State
                updateToggle()
                callback(state)
                if data.Color and colorCallback then
                    currentInstColor = Color3.new(data.Color[1], data.Color[2], data.Color[3])
                    if ColorPreview then ColorPreview.BackgroundColor3 = currentInstColor end
                    colorCallback(currentInstColor)
                end
            end
        }

        return { SetState = function(self, val) state = val updateToggle() callback(state) end }
    end

    function Window:CreateSlider(name, min, max, default, decimals, callback)
        min = min or 0 max = max or 100 decimals = decimals or 0
        local value = math.clamp(default or min, min, max)
        callback = callback or function() end
        local registryKey = windowName .. "_" .. name

        local SliderFrame = Instance.new("Frame")
        SliderFrame.Size = UDim2.new(1, 0, 0, 34)
        SliderFrame.BackgroundColor3 = Theme.ElementBG
        SliderFrame.BorderSizePixel = 0
        SliderFrame.Parent = Container

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(0.6, 0, 0, 18)
        Label.Position = UDim2.new(0, 6, 0, 2)
        Label.BackgroundTransparency = 1
        Label.Text = name
        Label.Font = Enum.Font.Code
        Label.TextSize = 11
        Label.TextColor3 = Theme.TextMain
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = SliderFrame

        local ValueLabel = Instance.new("TextLabel")
        ValueLabel.AnchorPoint = Vector2.new(1, 0)
        ValueLabel.Size = UDim2.new(0.35, 0, 0, 18)
        ValueLabel.Position = UDim2.new(1, -6, 0, 2)
        ValueLabel.BackgroundTransparency = 1
        ValueLabel.Text = string.format("%." .. decimals .. "f", value)
        ValueLabel.Font = Enum.Font.Code
        ValueLabel.TextSize = 11
        ValueLabel.TextColor3 = Theme.Accent
        ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
        ValueLabel.Parent = SliderFrame

        local SliderBar = Instance.new("TextButton")
        SliderBar.Size = UDim2.new(1, -12, 0, 6)
        SliderBar.Position = UDim2.new(0, 6, 0, 22)
        SliderBar.BackgroundColor3 = Theme.InnerBoxBG
        SliderBar.BorderSizePixel = 0
        SliderBar.Text = ""
        SliderBar.AutoButtonColor = false
        SliderBar.Parent = SliderFrame
        local SliderBarStroke = applyStroke(SliderBar, Theme.Stroke, 1)

        local Fill = Instance.new("Frame")
        Fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
        Fill.BackgroundColor3 = Theme.Accent
        Fill.BorderSizePixel = 0
        Fill.Parent = SliderBar

        local sliding = false
        local function updateSlider(input)
            local percentage = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
            value = min + (max - min) * percentage
            local formatStr = "%." .. decimals .. "f"
            value = tonumber(string.format(formatStr, value))
            Fill.Size = UDim2.new(percentage, 0, 1, 0)
            ValueLabel.Text = string.format(formatStr, value)
            callback(value)
        end

        SliderBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = true updateSlider(input) end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then updateSlider(input) end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
        end)

        local function externalSet(val)
            value = math.clamp(val, min, max)
            local pct = (value - min) / (max - min)
            Fill.Size = UDim2.new(pct, 0, 1, 0)
            ValueLabel.Text = string.format("%." .. decimals .. "f", value)
            callback(value)
        end

        table.insert(Library.ThemeRefreshes, function()
            SliderFrame.BackgroundColor3 = Theme.ElementBG
            Label.TextColor3 = Theme.TextMain
            ValueLabel.TextColor3 = Theme.Accent
            SliderBar.BackgroundColor3 = Theme.InnerBoxBG
            SliderBarStroke.Color = Theme.Stroke
            Fill.BackgroundColor3 = Theme.Accent
        end)

        Library.Registry[registryKey] = {
            Type = "Slider",
            Get = function() return value end,
            Set = function(self, val) externalSet(val) end
        }

        return { SetValue = externalSet }
    end

    function Window:CreateTextBox(name, placeholder, callback)
        callback = callback or function() end
        local registryKey = windowName .. "_" .. name

        local BoxFrame = Instance.new("Frame")
        BoxFrame.Size = UDim2.new(1, 0, 0, 26)
        BoxFrame.BackgroundColor3 = Theme.ElementBG
        BoxFrame.BorderSizePixel = 0
        BoxFrame.Parent = Container

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(0.4, 0, 1, 0)
        Label.Position = UDim2.new(0, 6, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = name
        Label.Font = Enum.Font.Code
        Label.TextSize = 11
        Label.TextColor3 = Theme.TextDim
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = BoxFrame

        local TBox = Instance.new("TextBox")
        TBox.AnchorPoint = Vector2.new(1, 0)
        TBox.Size = UDim2.new(0.55, 0, 0, 16)
        TBox.Position = UDim2.new(1, -6, 0, 5)
        TBox.BackgroundColor3 = Theme.InnerBoxBG
        TBox.BorderSizePixel = 0
        TBox.Text = ""
        TBox.PlaceholderText = placeholder
        TBox.PlaceholderColor3 = Theme.TextDim
        TBox.TextColor3 = Theme.TextMain
        TBox.Font = Enum.Font.Code
        TBox.TextSize = 10
        TBox.TextXAlignment = Enum.TextXAlignment.Center
        TBox.ClearTextOnFocus = false
        TBox.Parent = BoxFrame
        local BoxStroke = applyStroke(TBox, Theme.Stroke, 1)

        TBox.Focused:Connect(function() Label.TextColor3 = Theme.TextMain BoxStroke.Color = Theme.Accent end)
        TBox.FocusLost:Connect(function(enter) Label.TextColor3 = Theme.TextDim BoxStroke.Color = Theme.Stroke callback(TBox.Text, enter) end)

        table.insert(Library.ThemeRefreshes, function()
            BoxFrame.BackgroundColor3 = Theme.ElementBG
            Label.TextColor3 = Theme.TextDim
            TBox.BackgroundColor3 = Theme.InnerBoxBG
            TBox.TextColor3 = Theme.TextMain
            TBox.PlaceholderColor3 = Theme.TextDim
            BoxStroke.Color = Theme.Stroke
        end)

        Library.Registry[registryKey] = {
            Type = "TextBox",
            Get = function() return TBox.Text end,
            Set = function(self, val) TBox.Text = val callback(val, false) end
        }
    end

    function Window:CreateDropdown(name, list, default, callback)
        list = list or {} local currentSelection = default or list[1] or "" callback = callback or function() end local expanded = false
        local registryKey = windowName .. "_" .. name

        local DropdownFrame = Instance.new("Frame")
        DropdownFrame.Size = UDim2.new(1, 0, 0, 26)
        DropdownFrame.BackgroundColor3 = Theme.ElementBG
        DropdownFrame.BorderSizePixel = 0
        DropdownFrame.AutomaticSize = Enum.AutomaticSize.Y
        DropdownFrame.Parent = Container

        local Header = Instance.new("TextButton")
        Header.Size = UDim2.new(1, 0, 0, 26)
        Header.BackgroundTransparency = 1
        Header.Text = ""
        Header.Parent = DropdownFrame

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(0.4, 0, 1, 0)
        Label.Position = UDim2.new(0, 6, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = name
        Label.Font = Enum.Font.Code
        Label.TextSize = 11
        Label.TextColor3 = Theme.TextMain
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = Header

        local SelectionLabel = Instance.new("TextLabel")
        SelectionLabel.AnchorPoint = Vector2.new(1, 0)
        SelectionLabel.Size = UDim2.new(0.55, -14, 0, 16)
        SelectionLabel.Position = UDim2.new(1, -20, 0, 5)
        SelectionLabel.BackgroundColor3 = Theme.InnerBoxBG
        SelectionLabel.Text = currentSelection
        SelectionLabel.Font = Enum.Font.Code
        SelectionLabel.TextSize = 10
        SelectionLabel.TextColor3 = Theme.Accent
        SelectionLabel.Parent = Header
        local BoxStroke = applyStroke(SelectionLabel, Theme.Stroke, 1)

        local Arrow = Instance.new("TextLabel")
        Arrow.AnchorPoint = Vector2.new(1, 0)
        Arrow.Size = UDim2.new(0, 10, 0, 16)
        Arrow.Position = UDim2.new(1, -6, 0, 5)
        Arrow.BackgroundTransparency = 1
        Arrow.Text = "v"
        Arrow.Font = Enum.Font.Code
        Arrow.TextSize = 10
        Arrow.TextColor3 = Theme.TextDim
        Arrow.Parent = Header

        local OptionsContainer = Instance.new("Frame")
        OptionsContainer.Size = UDim2.new(0.55, -14, 0, 0)
        OptionsContainer.Position = UDim2.new(0.45, 0, 0, 24)
        OptionsContainer.BackgroundColor3 = Theme.InnerBoxBG
        OptionsContainer.BorderSizePixel = 0
        OptionsContainer.AutomaticSize = Enum.AutomaticSize.Y
        OptionsContainer.Visible = false
        OptionsContainer.ZIndex = 10
        OptionsContainer.Parent = DropdownFrame
        local OptionsContainerStroke = applyStroke(OptionsContainer, Theme.Stroke, 1)

        local OptionsLayout = Instance.new("UIListLayout")
        OptionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
        OptionsLayout.Parent = OptionsContainer

        local function refreshOptions()
            for _, child in ipairs(OptionsContainer:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
            for _, optionName in ipairs(list) do
                local OptBtn = Instance.new("TextButton")
                OptBtn.Size = UDim2.new(1, 0, 0, 18)
                OptBtn.BackgroundColor3 = optionName == currentSelection and Theme.Hover or Color3.fromRGB(0,0,0)
                OptBtn.BackgroundTransparency = optionName == currentSelection and 0 or 1
                OptBtn.BorderSizePixel = 0
                OptBtn.Text = optionName
                OptBtn.Font = Enum.Font.Code
                OptBtn.TextSize = 10
                OptBtn.TextColor3 = optionName == currentSelection and Theme.Accent or Theme.TextDim
                OptBtn.ZIndex = 11
                OptBtn.Parent = OptionsContainer

                OptBtn.MouseButton1Click:Connect(function()
                    currentSelection = optionName
                    SelectionLabel.Text = optionName
                    expanded = false
                    OptionsContainer.Visible = false
                    Arrow.Text = "v"
                    BoxStroke.Color = Theme.Stroke
                    refreshOptions()
                    callback(optionName)
                end)
            end
        end

        Header.MouseButton1Click:Connect(function()
            expanded = not expanded
            OptionsContainer.Visible = expanded
            Arrow.Text = expanded and "^" or "v"
            BoxStroke.Color = expanded and Theme.Accent or Theme.Stroke
            if expanded then refreshOptions() end
        end)

        table.insert(Library.ThemeRefreshes, function()
            DropdownFrame.BackgroundColor3 = Theme.ElementBG
            Label.TextColor3 = Theme.TextMain
            SelectionLabel.BackgroundColor3 = Theme.InnerBoxBG
            SelectionLabel.TextColor3 = Theme.Accent
            BoxStroke.Color = Theme.Stroke
            Arrow.TextColor3 = Theme.TextDim
            OptionsContainer.BackgroundColor3 = Theme.InnerBoxBG
            OptionsContainerStroke.Color = Theme.Stroke
        end)

        Library.Registry[registryKey] = {
            Type = "Dropdown",
            Get = function() return currentSelection end,
            Set = function(self, val) 
                currentSelection = val 
                SelectionLabel.Text = val 
                callback(val) 
            end
        }

        return { Refresh = function(self, newList)
            list = newList
            if not table.find(list, currentSelection) then
                currentSelection = list[1] or ""
                SelectionLabel.Text = currentSelection
            end
            if expanded then refreshOptions() end
        end }
    end

    function Window:CreateKeybind(name, default, callback)
        local currentKey = default or Enum.KeyCode.RightShift
        callback = callback or function() end
        local registryKey = windowName .. "_" .. name
        local listening = false

        local BindFrame = Instance.new("Frame")
        BindFrame.Size = UDim2.new(1, 0, 0, 24)
        BindFrame.BackgroundColor3 = Theme.ElementBG
        BindFrame.BorderSizePixel = 0
        BindFrame.Parent = Container

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(0.5, 0, 1, 0)
        Label.Position = UDim2.new(0, 6, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = name
        Label.Font = Enum.Font.Code
        Label.TextSize = 11
        Label.TextColor3 = Theme.TextMain
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = BindFrame

        local BindBtn = Instance.new("TextButton")
        BindBtn.AnchorPoint = Vector2.new(1, 0)
        BindBtn.Size = UDim2.new(0.45, 0, 0, 16)
        BindBtn.Position = UDim2.new(1, -6, 0, 4)
        BindBtn.BackgroundColor3 = Theme.InnerBoxBG
        BindBtn.BorderSizePixel = 0
        BindBtn.Text = "[" .. currentKey.Name .. "]"
        BindBtn.Font = Enum.Font.Code
        BindBtn.TextSize = 10
        BindBtn.TextColor3 = Theme.Accent
        BindBtn.Parent = BindFrame
        local BoxStroke = applyStroke(BindBtn, Theme.Stroke, 1)

        BindBtn.MouseButton1Click:Connect(function()
            listening = true
            BindBtn.Text = "[...]"
            BoxStroke.Color = Theme.Accent
        end)

        UserInputService.InputBegan:Connect(function(input)
            if listening and not UserInputService:GetFocusedTextBox() then
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    listening = false
                    currentKey = input.KeyCode
                    BindBtn.Text = "[" .. currentKey.Name .. "]"
                    BoxStroke.Color = Theme.Stroke
                    callback(currentKey)
                end
            end
        end)

        table.insert(Library.ThemeRefreshes, function()
            BindFrame.BackgroundColor3 = Theme.ElementBG
            Label.TextColor3 = Theme.TextMain
            BindBtn.BackgroundColor3 = Theme.InnerBoxBG
            BindBtn.TextColor3 = Theme.Accent
            BoxStroke.Color = Theme.Stroke
        end)

        Library.Registry[registryKey] = {
            Type = "Keybind",
            Get = function() return currentKey.Name end,
            Set = function(self, val)
                currentKey = Enum.KeyCode[val]
                BindBtn.Text = "[" .. val .. "]"
                callback(currentKey)
            end
        }
    end

    -- НОВЫЙ ЭЛЕМЕНТ: АВТОНОМНЫЙ ЦВЕТОВОЙ ПИKЕР ДЛЯ ВКЛАДКИ THEME
    function Window:CreateColorPicker(name, defaultColor, callback)
        callback = callback or function() end
        local currentInstColor = defaultColor or Color3.fromRGB(255,255,255)
        local registryKey = windowName .. "_" .. name
        local h, s, v = currentInstColor:ToHSV()
        local pickerExpanded = false

        local PickerFrame = Instance.new("Frame")
        PickerFrame.Size = UDim2.new(1, 0, 0, 24)
        PickerFrame.BackgroundColor3 = Theme.ElementBG
        PickerFrame.BorderSizePixel = 0
        PickerFrame.AutomaticSize = Enum.AutomaticSize.Y
        PickerFrame.Parent = Container

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(0.6, 0, 0, 24)
        Label.Position = UDim2.new(0, 6, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = name
        Label.Font = Enum.Font.Code
        Label.TextSize = 11
        Label.TextColor3 = Theme.TextMain
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = PickerFrame

        local ColorPreview = Instance.new("Frame")
        ColorPreview.AnchorPoint = Vector2.new(1, 0)
        ColorPreview.Size = UDim2.new(0, 20, 0, 14)
        ColorPreview.Position = UDim2.new(1, -6, 0, 5)
        ColorPreview.BackgroundColor3 = currentInstColor
        ColorPreview.BorderSizePixel = 0
        ColorPreview.Parent = PickerFrame
        local PreviewStroke = applyStroke(ColorPreview, Theme.Stroke, 1)

        local ColorBtn = Instance.new("TextButton")
        ColorBtn.Size = UDim2.new(1, 0, 1, 0)
        ColorBtn.BackgroundTransparency = 1
        ColorBtn.Text = ""
        ColorBtn.Parent = ColorPreview

        local PickerContainer = Instance.new("Frame")
        PickerContainer.Size = UDim2.new(1, -12, 0, 110)
        PickerContainer.Position = UDim2.new(0, 6, 0, 24)
        PickerContainer.BackgroundColor3 = Theme.InnerBoxBG
        PickerContainer.BorderSizePixel = 0
        PickerContainer.Visible = false
        PickerContainer.Parent = PickerFrame
        local PickerContainerStroke = applyStroke(PickerContainer, Theme.Stroke, 1)

        local SatValCanvas = Instance.new("TextButton")
        SatValCanvas.Size = UDim2.new(0, 150, 0, 100)
        SatValCanvas.Position = UDim2.new(0, 5, 0, 5)
        SatValCanvas.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
        SatValCanvas.BorderSizePixel = 0
        SatValCanvas.Text = ""
        SatValCanvas.AutoButtonColor = false
        SatValCanvas.Parent = PickerContainer

        local WhiteGrad = Instance.new("Frame")
        WhiteGrad.Size = UDim2.new(1, 0, 1, 0)
        WhiteGrad.BorderSizePixel = 0
        WhiteGrad.Parent = SatValCanvas
        local wG = Instance.new("UIGradient")
        wG.Color = ColorSequence.new(Color3.new(1,1,1), Color3.new(1,1,1))
        wG.Transparency = NumberSequence.new(0, 1)
        wG.Parent = WhiteGrad

        local BlackGrad = Instance.new("Frame")
        BlackGrad.Size = UDim2.new(1, 0, 1, 0)
        BlackGrad.BorderSizePixel = 0
        BlackGrad.Parent = SatValCanvas
        local bG = Instance.new("UIGradient")
        bG.Color = ColorSequence.new(Color3.new(0,0,0), Color3.new(0,0,0))
        bG.Transparency = NumberSequence.new(0, 1)
        bG.Rotation = -90
        bG.Parent = BlackGrad

        local Cursor = Instance.new("Frame")
        Cursor.AnchorPoint = Vector2.new(0.5, 0.5)
        Cursor.Size = UDim2.new(0, 4, 0, 4)
        Cursor.Position = UDim2.new(s, 0, 1 - v, 0)
        Cursor.BackgroundColor3 = Color3.new(1,1,1)
        Cursor.BorderSizePixel = 0
        Cursor.Parent = SatValCanvas
        applyStroke(Cursor, Color3.new(0,0,0), 1)

        local HueBar = Instance.new("TextButton")
        HueBar.Size = UDim2.new(0, 15, 0, 100)
        HueBar.Position = UDim2.new(0, 165, 0, 5)
        HueBar.BackgroundColor3 = Color3.new(1,1,1)
        HueBar.BorderSizePixel = 0
        HueBar.Text = ""
        HueBar.AutoButtonColor = false
        HueBar.Parent = PickerContainer

        local HueGrad = Instance.new("UIGradient")
        HueGrad.Rotation = 90
        HueGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)),
            ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255,0,255)),
            ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0,0,255)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,255,255)),
            ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0,255,0)),
            ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255,255,0)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,0))
        })
        HueGrad.Parent = HueBar

        local HueCursor = Instance.new("Frame")
        HueCursor.Size = UDim2.new(1, 4, 0, 2)
        HueCursor.Position = UDim2.new(0, -2, 1 - h, 0)
        HueCursor.BackgroundColor3 = Color3.new(1,1,1)
        HueCursor.BorderSizePixel = 0
        HueCursor.Parent = HueBar
        applyStroke(HueCursor, Color3.new(0,0,0), 1)

        local function fireUpdate()
            currentInstColor = Color3.fromHSV(h, s, v)
            ColorPreview.BackgroundColor3 = currentInstColor
            SatValCanvas.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
            callback(currentInstColor)
        end

        local draggingCanvas = false
        local function updateCanvas(input)
            local scaleX = math.clamp((input.Position.X - SatValCanvas.AbsolutePosition.X) / SatValCanvas.AbsoluteSize.X, 0, 1)
            local scaleY = math.clamp((input.Position.Y - SatValCanvas.AbsolutePosition.Y) / SatValCanvas.AbsoluteSize.Y, 0, 1)
            s = scaleX
            v = 1 - scaleY
            Cursor.Position = UDim2.new(s, 0, scaleY, 0)
            fireUpdate()
        end

        SatValCanvas.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingCanvas = true updateCanvas(input) end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if draggingCanvas and input.UserInputType == Enum.UserInputType.MouseMovement then updateCanvas(input) end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingCanvas = false end
        end)

        local draggingHue = false
        local function updateHue(input)
            local scaleY = math.clamp((input.Position.Y - HueBar.AbsolutePosition.Y) / HueBar.AbsoluteSize.Y, 0, 1)
            h = 1 - scaleY
            HueCursor.Position = UDim2.new(0, -2, scaleY, 0)
            fireUpdate()
        end

        HueBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingHue = true updateHue(input) end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if draggingHue and input.UserInputType == Enum.UserInputType.MouseMovement then updateHue(input) end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingHue = false end
        end)

        ColorBtn.MouseButton1Click:Connect(function()
            pickerExpanded = not pickerExpanded
            PickerContainer.Visible = pickerExpanded
            PreviewStroke.Color = pickerExpanded and Theme.Accent or Theme.Stroke
        end)

        table.insert(Library.ThemeRefreshes, function()
            PickerFrame.BackgroundColor3 = Theme.ElementBG
            Label.TextColor3 = Theme.TextMain
            PreviewStroke.Color = Theme.Stroke
            PickerContainer.BackgroundColor3 = Theme.InnerBoxBG
            PickerContainerStroke.Color = Theme.Stroke
        end)

        Library.Registry[registryKey] = {
            Type = "ColorPicker",
            Get = function() return {currentInstColor.R, currentInstColor.G, currentInstColor.B} end,
            Set = function(self, val)
                currentInstColor = Color3.new(val[1], val[2], val[3])
                ColorPreview.BackgroundColor3 = currentInstColor
                h, s, v = currentInstColor:ToHSV()
                Cursor.Position = UDim2.new(s, 0, 1 - v, 0)
                HueCursor.Position = UDim2.new(0, -2, 1 - h, 0)
                SatValCanvas.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                callback(currentInstColor)
            end
        }
    end

    return Window
end

-- ====================================================================
-- НЕЗАВИСИМЫЙ ВОТЕРМАРК С ФИКСИРОВАННЫМ РЕНДЕРОМ
-- ====================================================================
local WatermarkFrame = Instance.new("Frame")
WatermarkFrame.Name = "Meteor_Watermark"
WatermarkFrame.Size = UDim2.new(0, 180, 0, 22)
WatermarkFrame.Position = UDim2.new(1, -195, 1, -35)
WatermarkFrame.BackgroundColor3 = Theme.MainBG
WatermarkFrame.BorderSizePixel = 0
WatermarkFrame.Parent = WatermarkGui
local WatermarkFrameStroke = applyStroke(WatermarkFrame, Theme.Stroke, 1)

local WMarkLine = Instance.new("Frame")
WMarkLine.Size = UDim2.new(1, 0, 0, 2)
WMarkLine.BackgroundColor3 = Theme.Accent
WMarkLine.BorderSizePixel = 0
WMarkLine.Parent = WatermarkFrame

local WMarkLabel = Instance.new("TextLabel")
WMarkLabel.Size = UDim2.new(1, 0, 1, -2)
WMarkLabel.Position = UDim2.new(0, 0, 0, 2)
WMarkLabel.BackgroundTransparency = 1
WMarkLabel.Text = " METEOR | FPS: 0 | PING: 0ms"
WMarkLabel.Font = Enum.Font.Code
WMarkLabel.TextSize = 11
WMarkLabel.TextColor3 = Theme.TextMain
WMarkLabel.TextXAlignment = Enum.TextXAlignment.Left
WMarkLabel.Parent = WatermarkFrame

makeDraggable(WatermarkFrame, WatermarkFrame)

table.insert(Library.ThemeRefreshes, function()
    WatermarkFrame.BackgroundColor3 = Theme.MainBG
    WatermarkFrameStroke.Color = Theme.Stroke
    WMarkLine.BackgroundColor3 = Theme.Accent
    WMarkLabel.TextColor3 = Theme.TextMain
end)

task.spawn(function()
    local lastIteration = os.clock()
    while task.wait(0.5) do
        if not Library.WatermarkEnabled then 
            WatermarkFrame.Visible = false
        else
            WatermarkFrame.Visible = true
            local now = os.clock()
            local fps = math.floor(1 / (now - lastIteration))
            if fps > 1000 then fps = 60 end
            lastIteration = now
            
            local ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
            WMarkLabel.Text = string.format(" METEOR | FPS: %d | PING: %dms", fps, ping)
        end
    end
end)

-- ====================================================================
-- АВТОМАТИЧЕСКАЯ ИНИЦИАЛИЗАЦИЯ ВКЛАДКИ THEME (КАСТОМИЗАЦИЯ СТИЛЕЙ)
-- ====================================================================
local ThemeWindow = Library:CreateWindow("Theme", UDim2.new(0, 20, 0, 20))

ThemeWindow:CreateColorPicker("Accent Highlight", Theme.Accent, function(color)
    Theme.Accent = color
    Library:UpdateTheme()
end)

ThemeWindow:CreateColorPicker("Text Primary", Theme.TextMain, function(color)
    Theme.TextMain = color
    Library:UpdateTheme()
end)

ThemeWindow:CreateColorPicker("Text Disabled", Theme.TextDim, function(color)
    Theme.TextDim = color
    Library:UpdateTheme()
end)

ThemeWindow:CreateColorPicker("Border (Stroke)", Theme.Stroke, function(color)
    Theme.Stroke = color
    Library:UpdateTheme()
end)

ThemeWindow:CreateColorPicker("Window Background", Theme.MainBG, function(color)
    Theme.MainBG = color
    Library:UpdateTheme()
end)

ThemeWindow:CreateColorPicker("Topbar Background", Theme.TopbarBG, function(color)
    Theme.TopbarBG = color
    Library:UpdateTheme()
end)

ThemeWindow:CreateColorPicker("Element Rows", Theme.ElementBG, function(color)
    Theme.ElementBG = color
    Library:UpdateTheme()
end)

ThemeWindow:CreateColorPicker("Inner Fields", Theme.InnerBoxBG, function(color)
    Theme.InnerBoxBG = color
    Library:UpdateTheme()
end)

-- ====================================================================
-- АВТОМАТИЧЕСКАЯ ИНИЦИАЛИЗАЦИЯ ВКЛАДКИ SETTINGS
-- ====================================================================
local SettingsWindow = Library:CreateWindow("Settings", UDim2.new(0, 20, 0, 310))

SettingsWindow:CreateKeybind("Menu Bind", Enum.KeyCode.RightShift, function(newKey)
    Library.ToggleKey = newKey
end)

SettingsWindow:CreateToggle("Watermark Overlay", true, function(state)
    Library.WatermarkEnabled = state
end)

local currentConfigName = ""
SettingsWindow:CreateTextBox("Config Name", "enter name...", function(text)
    currentConfigName = text
end)

local function scanConfigs()
    local list = {}
    pcall(function()
        if listfiles then
            for _, file in ipairs(listfiles("Meteor_Configs")) do
                local name = file:match("([^/\\]+)%.txt$") or file:match("([^/\\]+)$")
                if name then table.insert(list, name) end
            end
        end
    end)
    if #list == 0 then table.insert(list, "None") end
    return list
end

local ConfigDropdown
ConfigDropdown = SettingsWindow:CreateDropdown("Select Config", scanConfigs(), "None", function(selected)
    currentConfigName = selected
end)

SettingsWindow:CreateButton("Save/Create Config", function()
    if currentConfigName == "" or currentConfigName == "None" then return end
    
    local dataToSave = {}
    for id, element in pairs(Library.Registry) do
        dataToSave[id] = element:Get()
    end
    
    local success, json = pcall(function() return HttpService:JSONEncode(dataToSave) end)
    if success and writefile then
        writefile("Meteor_Configs/" .. currentConfigName .. ".txt", json)
        if ConfigDropdown then ConfigDropdown:Refresh(scanConfigs()) end
    end
end)

SettingsWindow:CreateButton("Load Config", function()
    if currentConfigName == "" or currentConfigName == "None" then return end
    
    if readfile and isfile and isfile("Meteor_Configs/" .. currentConfigName .. ".txt") then
        local json = readfile("Meteor_Configs/" .. currentConfigName .. ".txt")
        local success, data = pcall(function() return HttpService:JSONDecode(json) end)
        if success then
            for id, value in pairs(data) do
                if Library.Registry[id] then
                    pcall(function() Library.Registry[id]:Set(value) end)
                end
            end
        end
    end
end)

SettingsWindow:CreateButton("Delete Config", function()
    if currentConfigName == "" or currentConfigName == "None" then return end
    if delfile and isfile and isfile("Meteor_Configs/" .. currentConfigName .. ".txt") then
        delfile("Meteor_Configs/" .. currentConfigName .. ".txt")
        currentConfigName = ""
        if ConfigDropdown then ConfigDropdown:Refresh(scanConfigs()) end
    end
end)

SettingsWindow:CreateButton("Refresh List", function()
    if ConfigDropdown then ConfigDropdown:Refresh(scanConfigs()) end
end)

return Library
