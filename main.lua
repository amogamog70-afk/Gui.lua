-- [[ METEOR ADVANCED UTILITY ENGINE - LINORIA DIRECT STYLE ]]
local InputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Theme = {
    MainBg = Color3.fromRGB(12, 12, 12),
    GroupBg = Color3.fromRGB(16, 16, 16),
    ElementBg = Color3.fromRGB(22, 22, 22),
    Accent = Color3.fromRGB(218, 43, 172), -- Твой фирменный неоново-розовый
    AccentSecondary = Color3.fromRGB(30, 120, 255), -- Синий для системных штук из скринов
    BorderDark = Color3.fromRGB(5, 5, 5),
    BorderLight = Color3.fromRGB(35, 35, 35),
    TextPrimary = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(145, 145, 145)
}

local RenderFont = Enum.Font.Code -- Фирменный строгий шрифт читов

local Library = {
    Registry = {},
    Unloaded = false,
    Watermark = nil,
    KeybindsFrame = nil,
    ActivePopups = {}
}

-- Вспомогательные функции
local function Create(class, properties)
    local instance = Instance.new(class)
    for k, v in pairs(properties) do
        instance[k] = v
    end
    return instance
end

local function ApplyStrictBorder(parent, outerColor, innerColor)
    local Outer = Create("UIStroke", {
        Color = outerColor or Theme.BorderDark,
        Thickness = 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = parent
    })
    return Outer
end

local function CloseAllPopups()
    for _, popup in pairs(Library.ActivePopups) do
        if popup then popup:Destroy() end
    end
    table.clear(Library.ActivePopups)
end

-- Математика для HSV пикера
local function RGBToHex(color)
    return string.format("#%02x%02x%02x", math.floor(color.R * 255), math.floor(color.G * 255), math.floor(color.B * 255))
end

local function HexToRGB(hex)
    hex = hex:gsub("#","")
    return Color3.fromRGB(
        tonumber("0x"..hex:sub(1,2)),
        tonumber("0x"..hex:sub(3,4)),
        tonumber("0x"..hex:sub(5,6))
    )
end

-- Инициализация Core GUI
local ScreenGui = Create("ScreenGui", {
    Name = "MeteorLinoriaPremium",
    ResetOnSpawn = false,
    DisplayOrder = 999,
    Parent = LocalPlayer:WaitForChild("PlayerGui")
})

-- [[ 1. WATERMARK SYSTEM ]]
function Library:InitWatermark(title)
    local WatermarkFrame = Create("Frame", {
        Name = "Watermark",
        Size = UDim2.new(0, 240, 0, 22),
        Position = UDim2.new(0, 15, 0, 15), -- Высокое позиционирование
        BackgroundColor3 = Theme.MainBg,
        BorderSizePixel = 0,
        Parent = ScreenGui
    })
    ApplyStrictBorder(WatermarkFrame, Theme.BorderDark)
    
    local TopLine = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Parent = WatermarkFrame
    })

    local TextLabel = Create("TextLabel", {
        Size = UDim2.new(1, -10, 1, -1),
        Position = UDim2.new(0, 5, 0, 1),
        BackgroundTransparency = 1,
        Font = RenderFont,
        Text = title,
        TextColor3 = Theme.TextPrimary,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = WatermarkFrame
    })

    -- Динамическое обновление FPS / Пинга
    task.spawn(value_generation or function()
        local lastIteration = os.clock()
        local frameHistory = {}
        
        RunService.RenderStepped:Connect(function()
            if Library.Unloaded then return end
            local now = os.clock()
            table.insert(frameHistory, 1, now)
            while frameHistory[#frameHistory] < now - 1 do
                table.remove(frameHistory)
            end
            local fps = #frameHistory
            local ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString():match("%d+") or "0"
            TextLabel.Text = string.format("%s | %d fps | %s ms", title, fps, ping)
        end)
    end)
    
    Library.Watermark = WatermarkFrame
end

-- [[ 2. KEYBINDS OVERLAY ]]
function Library:InitKeybinds()
    local KeybindsFrame = Create("Frame", {
        Name = "KeybindList",
        Size = UDim2.new(0, 210, 0, 24),
        Position = UDim2.new(0, 15, 0, 300),
        BackgroundColor3 = Theme.MainBg,
        BorderSizePixel = 0,
        Parent = ScreenGui
    })
    ApplyStrictBorder(KeybindsFrame, Theme.BorderDark)

    local TopLine = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Parent = KeybindsFrame
    })

    local Title = Create("TextLabel", {
        Size = UDim2.new(1, -10, 0, 22),
        Position = UDim2.new(0, 5, 0, 1),
        BackgroundTransparency = 1,
        Font = RenderFont,
        Text = "Keybinds",
        TextColor3 = Theme.TextPrimary,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = KeybindsFrame
    })

    local ListLayout = Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2),
        Parent = KeybindsFrame
    })

    local Container = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 0, 23),
        BackgroundTransparency = 1,
        Parent = KeybindsFrame
    })
    
    ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        KeybindsFrame.Size = UDim2.new(0, 210, 0, ListLayout.AbsoluteContentSize.Y + 24)
    end)

    Library.KeybindsFrame = Container
end

function Library:AddKeybindRow(name, keyStr)
    if not Library.KeybindsFrame then return end
    
    local Row = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        Parent = Library.KeybindsFrame
    })
    
    local Label = Create("TextLabel", {
        Size = UDim2.new(1, -60, 1, 0),
        Position = UDim2.new(0, 6, 0, 0),
        BackgroundTransparency = 1,
        Font = RenderFont,
        Text = "[" .. keyStr .. "] " .. name,
        TextColor3 = Theme.TextSecondary,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Row
    })
    
    local ModeLabel = Create("TextLabel", {
        Size = UDim2.new(0, 50, 1, 0),
        Position = UDim2.new(1, -55, 0, 0),
        BackgroundTransparency = 1,
        Font = RenderFont,
        Text = "(Toggle)",
        TextColor3 = Theme.TextSecondary,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = Row
    })
    
    return {
        Update = function(newKey, active)
            Label.Text = "[" .. newKey .. "] " .. name
            ModeLabel.TextColor3 = active and Theme.Accent or Theme.TextSecondary
        end,
        Destroy = function() Row:Destroy() end
    }
end

-- [[ 3. MAIN WINDOW CREATION ]]
function Library:CreateWindow(windowTitle)
    local Window = { Tabs = {}, CurrentTab = nil }

    local MainFrame = Create("Frame", {
        Name = "MainPanel",
        Size = UDim2.new(0, 620, 0, 480),
        Position = UDim2.new(0.5, -310, 0, 45), -- Смещено наверх экрана
        BackgroundColor3 = Theme.MainBg,
        BorderSizePixel = 0,
        Parent = ScreenGui
    })
    ApplyStrictBorder(MainFrame, Theme.BorderDark)

    -- Поисковая панель (Сверху справа в шапке)
    local SearchBar = Create("Frame", {
        Size = UDim2.new(0, 150, 0, 20),
        Position = UDim2.new(1, -165, 0, 8),
        BackgroundColor3 = Theme.ElementBg,
        Parent = MainFrame
    })
    ApplyStrictBorder(SearchBar)

    local SearchIcon = Create("ImageLabel", {
        Size = UDim2.new(0, 12, 0, 12),
        Position = UDim2.new(1, -16, 0.5, -6),
        BackgroundTransparency = 1,
        Image = "rbxassetid://118685771787843", -- Твой кастомный ассет лупы
        ImageColor3 = Theme.Accent,
        Parent = SearchBar
    })

    local SearchInput = Create("TextBox", {
        Size = UDim2.new(1, -22, 1, 0),
        Position = UDim2.new(0, 4, 0, 0),
        BackgroundTransparency = 1,
        Font = RenderFont,
        Text = "",
        PlaceholderText = "Search features...",
        PlaceholderColor3 = Theme.TextSecondary,
        TextColor3 = Theme.TextPrimary,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = SearchBar
    })

    -- Линия разграничения топ-бара
    local DecLine = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 0, 35),
        BackgroundColor3 = Theme.BorderLight,
        BorderSizePixel = 0,
        Parent = MainFrame
    })

    local TabScroller = Create("Frame", {
        Size = UDim2.new(1, -180, 0, 26),
        Position = UDim2.new(0, 10, 0, 5),
        BackgroundTransparency = 1,
        Parent = MainFrame
    })

    local TabListLayout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4),
        Parent = TabScroller
    })

    local ContainerHolder = Create("Frame", {
        Size = UDim2.new(1, -12, 1, -45),
        Position = UDim2.new(0, 6, 0, 40),
        BackgroundColor3 = Theme.GroupBg,
        Parent = MainFrame
    })
    ApplyStrictBorder(ContainerHolder)

    -- Реализация Dragging (Перетаскивание за топ-бар)
    local dragging, dragInput, dragStart, startPos
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and input.Position.Y - MainFrame.AbsolutePosition.Y < 35 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    MainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    InputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- [[ 4. TAB COMPONENT ]]
    function Window:CreateTab(tabName)
        local Tab = { Groupboxes = {}, ElementsMap = {} }

        local TabButton = Create("TextButton", {
            Size = UDim2.new(0, 85, 1, 0),
            BackgroundColor3 = Theme.GroupBg,
            Font = RenderFont,
            Text = tabName,
            TextColor3 = Theme.TextSecondary,
            TextSize = 12,
            Parent = TabScroller
        })
        ApplyStrictBorder(TabButton)

        local TabView = Create("Frame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Visible = false,
            Parent = ContainerHolder
        })

        local LeftColumn = Create("ScrollingFrame", {
            Size = UDim2.new(0.5, -6, 1, -10),
            Position = UDim2.new(0, 4, 0, 5),
            BackgroundTransparency = 1,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 0,
            Parent = TabView
        })
        Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10), Parent = LeftColumn })

        local RightColumn = Create("ScrollingFrame", {
            Size = UDim2.new(0.5, -6, 1, -10),
            Position = UDim2.new(0.5, 2, 0, 5),
            BackgroundTransparency = 1,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 0,
            Parent = TabView
        })
        Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10), Parent = RightColumn })

        local function Select()
            if Window.CurrentTab then
                Window.CurrentTab.Button.TextColor3 = Theme.TextSecondary
                Window.CurrentTab.Button.BackgroundColor3 = Theme.GroupBg
                Window.CurrentTab.View.Visible = false
            end
            TabButton.TextColor3 = Theme.Accent
            TabButton.BackgroundColor3 = Theme.MainBg
            TabView.Visible = true
            Window.CurrentTab = { Button = TabButton, View = TabView }
            CloseAllPopups()
        end

        TabButton.MouseButton1Click:Connect(Select)
        if not Window.CurrentTab then Select() end

        -- [[ 5. GROUPBOX COMPONENT (Рамки настроек) ]]
        function Tab:CreateGroupbox(boxName, columnSide)
            local Groupbox = { CurrentSubtabFrame = nil, SubtabsContainer = nil }
            local targetColumn = (columnSide == "Right") and RightColumn or LeftColumn

            local GroupFrame = Create("Frame", {
                Name = boxName .. "Group",
                Size = UDim2.new(1, 0, 0, 40),
                BackgroundColor3 = Theme.MainBg,
                Parent = targetColumn
            })
            ApplyStrictBorder(GroupFrame, Theme.BorderDark)

            local AccentTop = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 2),
                BackgroundColor3 = Theme.Accent,
                BorderSizePixel = 0,
                Parent = GroupFrame
            })

            local GroupTitle = Create("TextLabel", {
                Size = UDim2.new(0, 100, 0, 14),
                Position = UDim2.new(0, 10, 0, -7),
                BackgroundColor3 = Theme.MainBg,
                Font = RenderFont,
                Text = " " .. boxName .. " ",
                TextColor3 = Theme.TextPrimary,
                TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = GroupFrame
            })
            GroupTitle.Size = UDim2.new(0, GroupTitle.TextBounds.X + 6, 0, 14)

            local ItemsList = Create("Frame", {
                Size = UDim2.new(1, -16, 1, -16),
                Position = UDim2.new(0, 8, 0, 10),
                BackgroundTransparency = 1,
                Parent = GroupFrame
            })
            local ItemsLayout = Create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 6),
                Parent = ItemsList
            })

            local function AutoResize()
                local baseSize = ItemsLayout.AbsoluteContentSize.Y + 22
                GroupFrame.Size = UDim2.new(1, 0, 0, baseSize)
                targetColumn.CanvasSize = UDim2.new(0, 0, 0, targetColumn.UIListLayout.AbsoluteContentSize.Y + 20)
            end
            ItemsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(AutoResize)

            -- [[ 6. SUBTABS / SLOTS SYSTEM INSIDE GROUPBOX ]]
            function Groupbox:CreateSubtabs()
                local SubtabSystem = { CurrentSub = nil }
                
                local Bar = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 20),
                    BackgroundColor3 = Theme.ElementBg,
                    Parent = ItemsList
                })
                ApplyStrictBorder(Bar)
                
                local Layout = Create("UIListLayout", {
                    FillDirection = Enum.FillDirection.Horizontal,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Parent = Bar
                })

                local MultiFrame = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 0),
                    BackgroundTransparency = 1,
                    Parent = ItemsList
                })
                local MultiLayout = Create("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 5),
                    Parent = MultiFrame
                })
                MultiLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    MultiFrame.Size = UDim2.new(1, 0, 0, MultiLayout.AbsoluteContentSize.Y)
                    AutoResize()
                end)

                Groupbox.SubtabsContainer = MultiFrame

                function SubtabSystem:AddSlot(slotName)
                    local SlotFrame = Create("Frame", {
                        Size = UDim2.new(1, 0, 1, 0),
                        BackgroundTransparency = 1,
                        Visible = false,
                        Parent = MultiFrame
                    })
                    local SlotLayout = Create("UIListLayout", {
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        Padding = UDim.new(0, 5),
                        Parent = SlotFrame
                    })
                    SlotLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                        if SlotFrame.Visible then
                            MultiFrame.Size = UDim2.new(1, 0, 0, SlotLayout.AbsoluteContentSize.Y)
                            AutoResize()
                        end
                    end)

                    local Button = Create("TextButton", {
                        Size = UDim2.new(0, 70, 1, 0),
                        BackgroundColor3 = Theme.ElementBg,
                        Font = RenderFont,
                        Text = slotName,
                        TextColor3 = Theme.TextSecondary,
                        TextSize = 11,
                        Parent = Bar
                    })
                    ApplyStrictBorder(Button)

                    local function ActivateSlot()
                        if SubtabSystem.CurrentSub then
                            SubtabSystem.CurrentSub.Btn.TextColor3 = Theme.TextSecondary
                            SubtabSystem.CurrentSub.Btn.BackgroundColor3 = Theme.ElementBg
                            SubtabSystem.CurrentSub.Fr.Visible = false
                        end
                        Button.TextColor3 = Theme.TextPrimary
                        Button.BackgroundColor3 = Theme.GroupBg
                        SlotFrame.Visible = true
                        SubtabSystem.CurrentSub = { Btn = Button, Fr = SlotFrame }
                        MultiFrame.Size = UDim2.new(1, 0, 0, SlotLayout.AbsoluteContentSize.Y)
                        AutoResize()
                    end

                    Button.MouseButton1Click:Connect(ActivateSlot)
                    if not SubtabSystem.CurrentSub then ActivateSlot() end

                    -- Перенаправление добавления элементов в контейнер слота
                    local SlotBuilder = {}
                    setmetatable(SlotBuilder, {
                        __index = function(_, key)
                            return function(self, ...)
                                return Groupbox[key](Groupbox, ...)
                            end
                        end
                    })
                    -- Подменяем фабричный родительский объект для элементов слота
                    return SlotFrame
                end

                return SubtabSystem
            end

            -- Хелпер для определения куда пушить элемент (в групбокс или активный внутренний слот)
            local function GetTargetParent(overrideParent)
                return overrideParent or Groupbox.SubtabsContainer or ItemsList
            end

            -- [[ 7. ЭЛЕМЕНТ: TOGGLE (Квадратный Чекбокс) ]]
            function Groupbox:CreateToggle(text, default, callback, overrideParent)
                local state = default or false
                local parent = GetTargetParent(overrideParent)

                local ToggleFrame = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 20),
                    BackgroundTransparency = 1,
                    Parent = parent
                })

                local Checkbox = Create("TextButton", {
                    Size = UDim2.new(0, 12, 0, 12),
                    Position = UDim2.new(0, 2, 0.5, -6),
                    BackgroundColor3 = state and Theme.Accent or Theme.ElementBg,
                    Text = "",
                    Parent = ToggleFrame
                })
                ApplyStrictBorder(Checkbox)

                local Label = Create("TextButton", {
                    Size = UDim2.new(1, -20, 1, 0),
                    Position = UDim2.new(0, 22, 0, 0),
                    BackgroundTransparency = 1,
                    Font = RenderFont,
                    Text = text,
                    TextColor3 = state and Theme.TextPrimary or Theme.TextSecondary,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = ToggleFrame
                })

                local function ToggleAction()
                    state = not state
                    Checkbox.BackgroundColor3 = state and Theme.Accent or Theme.ElementBg
                    Label.TextColor3 = state and Theme.TextPrimary or Theme.TextSecondary
                    pcall(callback, state)
                end

                Checkbox.MouseButton1Click:Connect(ToggleAction)
                Label.MouseButton1Click:Connect(ToggleAction)

                local Addons = Create("Frame", {
                    Size = UDim2.new(0, 60, 1, 0),
                    Position = UDim2.new(1, -60, 0, 0),
                    BackgroundTransparency = 1,
                    Parent = ToggleFrame
                })
                local AddonLayout = Create("UIListLayout", {
                    FillDirection = Enum.FillDirection.Horizontal,
                    HorizontalAlignment = Enum.HorizontalAlignment.Right,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 4),
                    Parent = Addons
                })

                Tab.ElementsMap[text:lower()] = { Frame = ToggleFrame, MainLabel = Label }

                -- Функционал встраивания Keybind в строку Toggle
                local Builder = {}
                function Builder:AddKeybind(initialKey, bindCallback)
                    local currentKey = initialKey or "None"
                    local KBRow = nil
                    
                    local BindButton = Create("TextButton", {
                        Size = UDim2.new(0, 35, 0, 14),
                        BackgroundColor3 = Theme.ElementBg,
                        Font = RenderFont,
                        Text = "[" .. currentKey .. "]",
                        TextColor3 = Theme.TextSecondary,
                        TextSize = 10,
                        Parent = Addons
                    })
                    ApplyStrictBorder(BindButton)

                    if Library.KeybindsFrame then
                        KBRow = Library:AddKeybindRow(text, currentKey)
                    end

                    BindButton.MouseButton1Click:Connect(function()
                        BindButton.Text = "[...]"
                        local connection
                        connection = InputService.InputBegan:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.Keyboard then
                                currentKey = input.KeyCode.Name
                                BindButton.Text = "[" .. currentKey .. "]"
                                if KBRow then KBRow.Update(currentKey, state) end
                                connection:Disconnect()
                            elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 then
                                currentKey = input.UserInputType.Name == "MouseButton1" and "MB1" or "MB2"
                                BindButton.Text = "[" .. currentKey .. "]"
                                if KBRow then KBRow.Update(currentKey, state) end
                                connection:Disconnect()
                            end
                        end)
                    end)

                    InputService.InputBegan:Connect(function(input, processed)
                        if processed then return end
                        if (input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode.Name == currentKey) or
                           (currentKey == "MB1" and input.UserInputType == Enum.UserInputType.MouseButton1) or 
                           (currentKey == "MB2" and input.UserInputType == Enum.UserInputType.MouseButton2) then
                            ToggleAction()
                            if KBRow then KBRow.Update(currentKey, state) end
                            pcall(bindCallback, state)
                        end
                    end)
                end

                -- Интеграция Colorpicker прямо в строку Toggle
                function Builder:AddColorPicker(defaultColor, cpCallback)
                    local FrameColor = defaultColor or Color3.fromRGB(255, 255, 255)
                    local VisualBox = Create("TextButton", {
                        Size = UDim2.new(0, 16, 0, 12),
                        BackgroundColor3 = FrameColor,
                        Text = "",
                        Parent = Addons
                    })
                    ApplyStrictBorder(VisualBox)

                    VisualBox.MouseButton1Click:Connect(function()
                        Groupbox:OpenAdvancedColorPicker(text, FrameColor, function(selectedColor)
                            VisualBox.BackgroundColor3 = selectedColor
                            FrameColor = selectedColor
                            pcall(cpCallback, selectedColor)
                        end)
                    end)
                end

                return Builder
            end

            -- [[ 8. ЭЛЕМЕНТ: SLIDER (Строгий Линория стиль с текстом внутри) ]]
            function Groupbox:CreateSlider(text, min, max, default, formatStr, callback, overrideParent)
                local parent = GetTargetParent(overrideParent)
                formatStr = formatStr or "%d/%d"

                local SliderFrame = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 30),
                    BackgroundTransparency = 1,
                    Parent = parent
                })

                local Label = Create("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 14),
                    BackgroundTransparency = 1,
                    Font = RenderFont,
                    Text = text,
                    TextColor3 = Theme.TextPrimary,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = SliderFrame
                })

                local Track = Create("TextButton", {
                    Size = UDim2.new(1, -4, 0, 12),
                    Position = UDim2.new(0, 2, 0, 15),
                    BackgroundColor3 = Theme.ElementBg,
                    Text = "",
                    Parent = SliderFrame
                })
                ApplyStrictBorder(Track)

                local Fill = Create("Frame", {
                    Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
                    BackgroundColor3 = Theme.AccentSecondary, -- Синий цвет трека из референса
                    BorderSizePixel = 0,
                    Parent = Track
                })

                local ValueDisplay = Create("TextLabel", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Font = RenderFont,
                    Text = string.format(formatStr, default, max),
                    TextColor3 = Theme.TextPrimary,
                    TextSize = 10,
                    TextYAlignment = Enum.TextYAlignment.Center,
                    Parent = Track
                })

                local sliding = false
                local function UpdateSlider(input)
                    local delta = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                    local val = math.floor(min + (max - min) * delta)
                    ValueDisplay.Text = string.format(formatStr, val, max)
                    Fill.Size = UDim2.new(delta, 0, 1, 0)
                    pcall(callback, val)
                end

                Track.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        sliding = true
                        CloseAllPopups()
                        UpdateSlider(input)
                    end
                end)
                InputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
                end)
                InputService.InputChanged:Connect(function(input)
                    if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then UpdateSlider(input) end
                end)

                Tab.ElementsMap[text:lower()] = { Frame = SliderFrame, MainLabel = Label }
            end

            -- [[ 9. ЭЛЕМЕНТ: DROPDOWN ]]
            function Groupbox:CreateDropdown(text, items, default, callback, overrideParent)
                local parent = GetTargetParent(overrideParent)
                local selected = default or items[1]

                local DropFrame = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 32),
                    BackgroundTransparency = 1,
                    Parent = parent
                })

                local Label = Create("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 12),
                    BackgroundTransparency = 1,
                    Font = RenderFont,
                    Text = text,
                    TextColor3 = Theme.TextPrimary,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = DropFrame
                })

                local Field = Create("TextButton", {
                    Size = UDim2.new(1, -4, 0, 16),
                    Position = UDim2.new(0, 2, 0, 14),
                    BackgroundColor3 = Theme.ElementBg,
                    Font = RenderFont,
                    Text = "  " .. tostring(selected),
                    TextColor3 = Theme.TextPrimary,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = DropFrame
                })
                ApplyStrictBorder(Field)

                local Indicator = Create("TextLabel", {
                    Size = UDim2.new(0, 14, 1, 0),
                    Position = UDim2.new(1, -16, 0, 0),
                    BackgroundTransparency = 1,
                    Font = RenderFont,
                    Text = "▼",
                    TextColor3 = Theme.TextSecondary,
                    TextSize = 9,
                    Parent = Field
                })

                Field.MouseButton1Click:Connect(function()
                    local openName = text .. "Pop"
                    if ScreenGui:FindFirstChild(openName) then
                        ScreenGui[openName]:Destroy()
                        return
                    end
                    CloseAllPopups()

                    local Menu = Create("Frame", {
                        Name = openName,
                        Size = UDim2.new(0, Field.AbsoluteSize.X, 0, #items * 18),
                        Position = UDim2.new(0, Field.AbsolutePosition.X, 0, Field.AbsolutePosition.Y + Field.AbsoluteSize.Y + 2),
                        BackgroundColor3 = Theme.MainBg,
                        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
                        Parent = ScreenGui
                    })
                    ApplyStrictBorder(Menu, Theme.AccentSecondary)
                    table.insert(Library.ActivePopups, Menu)

                    local List = Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = Menu })

                    for _, it in pairs(items) do
                        local Row = Create("TextButton", {
                            Size = UDim2.new(1, 0, 0, 18),
                            BackgroundColor3 = Theme.MainBg,
                            BorderSizePixel = 0,
                            Font = RenderFont,
                            Text = "  " .. tostring(it),
                            TextColor3 = (it == selected) and Theme.AccentSecondary or Theme.TextSecondary,
                            TextSize = 11,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            Parent = Menu
                        })

                        Row.MouseEnter:Connect(function() Row.BackgroundColor3 = Theme.ElementBg end)
                        Row.MouseLeave:Connect(function() Row.BackgroundColor3 = Theme.MainBg end)
                        Row.MouseButton1Click:Connect(function()
                            selected = it
                            Field.Text = "  " .. tostring(it)
                            CloseAllPopups()
                            pcall(callback, it)
                        end)
                    end
                end)

                Tab.ElementsMap[text:lower()] = { Frame = DropFrame, MainLabel = Label }
            end

            -- [[ 10. ЭЛЕМЕНТ: TEXTBOX ]]
            function Groupbox:CreateTextBox(text, default, placeholder, callback, overrideParent)
                local parent = GetTargetParent(overrideParent)

                local BoxFrame = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 32),
                    BackgroundTransparency = 1,
                    Parent = parent
                })

                local Label = Create("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 12),
                    BackgroundTransparency = 1,
                    Font = RenderFont,
                    Text = text,
                    TextColor3 = Theme.TextPrimary,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = BoxFrame
                })

                local Input = Create("TextBox", {
                    Size = UDim2.new(1, -4, 0, 16),
                    Position = UDim2.new(0, 2, 0, 14),
                    BackgroundColor3 = Theme.ElementBg,
                    Font = RenderFont,
                    Text = default or "",
                    PlaceholderText = placeholder or "Type here..",
                    PlaceholderColor3 = Theme.TextSecondary,
                    TextColor3 = Theme.TextPrimary,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = BoxFrame
                })
                ApplyStrictBorder(Input)

                Input.FocusLost:Connect(function()
                    pcall(callback, Input.Text)
                end)

                Tab.ElementsMap[text:lower()] = { Frame = BoxFrame, MainLabel = Label }
            end

            -- [[ 11. ЭЛЕМЕНТ: МНОГОСТРОЧНЫЙ LABEL ]]
            function Groupbox:CreateLabel(text, overrideParent)
                local parent = GetTargetParent(overrideParent)

                local LabelFrame = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 14),
                    BackgroundTransparency = 1,
                    Parent = parent
                })

                local RealText = Create("TextLabel", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Font = RenderFont,
                    Text = text,
                    TextColor3 = Theme.TextPrimary,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextWrapped = true,
                    Parent = LabelFrame
                })

                RealText:GetPropertyChangedSignal("TextBounds"):Connect(function()
                    LabelFrame.Size = UDim2.new(1, 0, 0, RealText.TextBounds.Y + 2)
                end)
                LabelFrame.Size = UDim2.new(1, 0, 0, RealText.TextBounds.Y + 2)

                Tab.ElementsMap[text:lower()] = { Frame = LabelFrame, MainLabel = RealText }
            end

            -- [[ 12. ADVANCED HARDCORE COLOR PICKER ENGINE (Из твоего Скриншота) ]]
            function Groupbox:OpenAdvancedColorPicker(cpTitle, initColor, cpCallback)
                CloseAllPopups()

                local h, s, v = initColor:ToHSV()

                local CPWindow = Create("Frame", {
                    Name = cpTitle .. "PickerPanel",
                    Size = UDim2.new(0, 180, 0, 195),
                    Position = UDim2.new(0, MainFrame.AbsolutePosition.X + MainFrame.AbsoluteSize.X + 10, 0, MainFrame.AbsolutePosition.Y + 40),
                    BackgroundColor3 = Theme.MainBg,
                    Parent = ScreenGui
                })
                ApplyStrictBorder(CPWindow, Theme.BorderDark)
                table.insert(Library.ActivePopups, CPWindow)

                local Title = Create("TextLabel", {
                    Size = UDim2.new(1, -10, 0, 16),
                    Position = UDim2.new(0, 6, 0, 2),
                    BackgroundTransparency = 1,
                    Font = RenderFont,
                    Text = cpTitle,
                    TextColor3 = Theme.TextPrimary,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = CPWindow
                })

                -- 2D Матрица Насыщенности / Яркости (Saturation / Value Canvas)
                local SatValBox = Create("TextButton", {
                    Size = UDim2.new(0, 140, 0, 115),
                    Position = UDim2.new(0, 6, 0, 20),
                    BackgroundColor3 = Color3.fromHSV(h, 1, 1),
                    Text = "",
                    Parent = CPWindow
                })
                ApplyStrictBorder(SatValBox)

                -- Градиенты для воссоздания полноценной палитры без тяжелых картинок
                local WhiteGrad = Create("Frame", { Size = UDim2.new(1, 0, 1, 0), Parent = SatValBox })
                Create("UIGradient", {
                    Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(255, 255, 255)),
                    Transparency = NumberSequence.new(0, 1),
                    Rotation = 0,
                    Parent = WhiteGrad
                })

                local BlackGrad = Create("Frame", { Size = UDim2.new(1, 0, 1, 0), Parent = SatValBox })
                Create("UIGradient", {
                    Color = ColorSequence.new(Color3.fromRGB(0, 0, 0), Color3.fromRGB(0, 0, 0)),
                    Transparency = NumberSequence.new(1, 0),
                    Rotation = 90,
                    Parent = BlackGrad
                })

                -- Кружок-указатель на палитре
                local Pointer = Create("Frame", {
                    Size = UDim2.new(0, 4, 0, 4),
                    Position = UDim2.new(s, -2, 1 - v, -2),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    Parent = SatValBox
                })
                Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Pointer })
                ApplyStrictBorder(Pointer, Color3.fromRGB(0, 0, 0))

                -- Вертикальный Радужный Слайдер Оттенка (Hue Slider Bar)
                local HueBar = Create("TextButton", {
                    Size = UDim2.new(0, 12, 0, 115),
                    Position = UDim2.new(0, 154, 0, 20),
                    Text = "",
                    Parent = CPWindow
                })
                ApplyStrictBorder(HueBar)

                local HueGrad = Create("UIGradient", {
                    Rotation = 90,
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                        ColorSequenceKeypoint.new(0.16, Color3.fromRGB(255, 255, 0)),
                        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
                        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                        ColorSequenceKeypoint.new(0.66, Color3.fromRGB(0, 0, 255)),
                        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
                    }),
                    Parent = HueBar
                })

                local HueIndicator = Create("Frame", {
                    Size = UDim2.new(1, 4, 0, 2),
                    Position = UDim2.new(0, -2, h, -1),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BorderSizePixel = 0,
                    Parent = HueBar
                })

                -- Нижние Текстовые Поля (Ввод HEX и RGB напрямую как в Линории)
                local HexInput = Create("TextBox", {
                    Size = UDim2.new(0, 75, 0, 16),
                    Position = UDim2.new(0, 6, 0, 142),
                    BackgroundColor3 = Theme.ElementBg,
                    Font = RenderFont,
                    Text = RGBToHex(initColor),
                    TextColor3 = Theme.TextPrimary,
                    TextSize = 10,
                    Parent = CPWindow
                })
                ApplyStrictBorder(HexInput)

                local RGBInput = Create("TextBox", {
                    Size = UDim2.new(0, 85, 0, 16),
                    Position = UDim2.new(0, 85, 0, 142),
                    BackgroundColor3 = Theme.ElementBg,
                    Font = RenderFont,
                    Text = string.format("%d, %d, %d", math.floor(initColor.R*255), math.floor(initColor.G*255), math.floor(initColor.B*255)),
                    TextColor3 = Theme.TextPrimary,
                    TextSize = 9,
                    Parent = CPWindow
                })
                ApplyStrictBorder(RGBInput)

                -- Шкала Альфа / Прозрачности
                local AlphaBar = Create("Frame", {
                    Size = UDim2.new(0, 161, 0, 10),
                    Position = UDim2.new(0, 6, 0, 166),
                    BackgroundColor3 = Theme.ElementBg,
                    Parent = CPWindow
                })
                ApplyStrictBorder(AlphaBar)
                local AlphaFill = Create("Frame", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundColor3 = initColor,
                    BorderSizePixel = 0,
                    Parent = AlphaBar
                })

                -- Внутренняя Логика Обновления Цвета
                local function SynchronizeColors(updateInputs)
                    local combinedColor = Color3.fromHSV(h, s, v)
                    SatValBox.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                    AlphaFill.BackgroundColor3 = combinedColor
                    
                    Pointer.Position = UDim2.new(s, -2, 1 - v, -2)
                    HueIndicator.Position = UDim2.new(0, -2, h, -1)

                    if updateInputs then
                        HexInput.Text = RGBToHex(combinedColor)
                        RGBInput.Text = string.format("%d, %d, %d", math.floor(combinedColor.R*255), math.floor(combinedColor.G*255), math.floor(combinedColor.B*255))
                    end
                    pcall(cpCallback, combinedColor)
                end

                -- Контроллеры Мыши
                local dragSatVal = false
                SatValBox.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragSatVal = true end end)
                InputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragSatVal = false end end)
                
                local dragHue = false
                HueBar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragHue = true end end)
                InputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragHue = false end end)

                InputService.InputChanged:Connect(function(input)
                    if dragSatVal and input.UserInputType == Enum.UserInputType.MouseMovement then
                        local mX = math.clamp((input.Position.X - SatValBox.AbsolutePosition.X) / SatValBox.AbsoluteSize.X, 0, 1)
                        local mY = math.clamp((input.Position.Y - SatValBox.AbsolutePosition.Y) / SatValBox.AbsoluteSize.Y, 0, 1)
                        s = mX
                        v = 1 - mY
                        SynchronizeColors(true)
                    elseif dragHue and input.UserInputType == Enum.UserInputType.MouseMovement then
                        h = math.clamp((input.Position.Y - HueBar.AbsolutePosition.Y) / HueBar.AbsoluteSize.Y, 0, 1)
                        SynchronizeColors(true)
                    end
                end)

                -- Кастомный ручной ввод данных игроком
                HexInput.FocusLost:Connect(function()
                    local success, res = pcall(HexToRGB, HexInput.Text)
                    if success and res then
                        h, s, v = res:ToHSV()
                        SynchronizeColors(false)
                        RGBInput.Text = string.format("%d, %d, %d", math.floor(res.R*255), math.floor(res.G*255), math.floor(res.B*255))
                    end
                end)

                RGBInput.FocusLost:Connect(function()
                    local r, g, b = RGBInput.Text:match("(%d+),%s*(%d+),%s*(%d+)")
                    if r and g and b then
                        local c = Color3.fromRGB(tonumber(r), tonumber(g), tonumber(b))
                        h, s, v = c:ToHSV()
                        SynchronizeColors(false)
                        HexInput.Text = RGBToHex(c)
                    end
                end)
            end

            return Groupbox
        end

        return Tab
    end

    -- Глобальный поиск по элементам
    SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
        local query = SearchInput.Text:lower()
        for _, tab in pairs(Window.Tabs) do
            for name, data in pairs(tab.ElementsMap) do
                if query == "" or string.find(name, query) then
                    data.Frame.Visible = true
                else
                    data.Frame.Visible = false
                end
            end
        end
    end)

    -- Переключение видимости всего меню на клавишу RightShift
    InputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == Enum.KeyCode.RightShift then
            MainFrame.Visible = not MainFrame.Visible
            if Library.Watermark then Library.Watermark.Visible = MainFrame.Visible end
            if not MainFrame.Visible then CloseAllPopups() end
        end
    end)

    return Window
end

return Library
