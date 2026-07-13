-- =============================================================================
-- METEOR UI ENGINE (TRADITIONAL VERTICAL SIDEBAR EDITION)
-- =============================================================================
local InputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Theme = {
    MainBg = Color3.fromRGB(10, 10, 10),
    GroupBg = Color3.fromRGB(15, 15, 15),
    ElementBg = Color3.fromRGB(20, 20, 20),
    Accent = Color3.fromRGB(218, 43, 172),          -- Фирменный неоновый Meteor
    AccentSecondary = Color3.fromRGB(30, 120, 255),
    BorderDark = Color3.fromRGB(0, 0, 0),
    BorderLight = Color3.fromRGB(30, 30, 30),
    TextPrimary = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(130, 130, 130)
}

local RenderFont = Enum.Font.Code
local Library = { Registry = {}, Unloaded = false, Watermark = nil, KeybindsFrame = nil, ActivePopups = {} }

local function Create(class, properties)
    local instance = Instance.new(class)
    for k, v in pairs(properties) do instance[k] = v end
    return instance
end

local function ApplyStrictBorder(parent, color)
    return Create("UIStroke", {
        Color = color or Theme.BorderLight,
        Thickness = 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = parent
    })
end

local function CloseAllPopups()
    for _, popup in pairs(Library.ActivePopups) do if popup then popup:Destroy() end end
    table.clear(Library.ActivePopups)
end

local function RGBToHex(c) return string.format("#%02x%02x%02x", math.floor(c.R*255), math.floor(c.G*255), math.floor(c.B*255)) end
local function HexToRGB(h) h = h:gsub("#","") return Color3.fromRGB(tonumber("0x"..h:sub(1,2)), tonumber("0x"..h:sub(3,4)), tonumber("0x"..h:sub(5,6))) end

local ScreenGui = Create("ScreenGui", { Name = "MeteorEngineGui", ResetOnSpawn = false, DisplayOrder = 999, Parent = LocalPlayer:WaitForChild("PlayerGui") })

-- [1] СИСТЕМНЫЕ ОВЕРЛЕИ (Watermark & Keybinds)
function Library:InitWatermark(title)
    local WatermarkFrame = Create("Frame", { Size = UDim2.new(0, 260, 0, 22), Position = UDim2.new(0, 15, 0, 10), BackgroundColor3 = Theme.MainBg, Parent = ScreenGui })
    ApplyStrictBorder(WatermarkFrame, Theme.BorderDark)
    Create("Frame", { Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, Parent = WatermarkFrame })
    local TextLabel = Create("TextLabel", { Size = UDim2.new(1, -10, 1, -1), Position = UDim2.new(0, 5, 0, 1), BackgroundTransparency = 1, Font = RenderFont, Text = title, TextColor3 = Theme.TextPrimary, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Parent = WatermarkFrame })
    
    task.spawn(function()
        local history = {}
        RunService.RenderStepped:Connect(function()
            if Library.Unloaded then return end
            local now = os.clock() table.insert(history, 1, now) while history[#history] < now - 1 do table.remove(history) end
            local ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString():match("%d+") or "0"
            TextLabel.Text = string.format("%s | %d FPS | %s MS", title, #history, ping)
        end)
    end)
    Library.Watermark = WatermarkFrame
end

function Library:InitKeybinds()
    local KBFrame = Create("Frame", { Size = UDim2.new(0, 210, 0, 24), Position = UDim2.new(0, 15, 0, 40), BackgroundColor3 = Theme.MainBg, Parent = ScreenGui })
    ApplyStrictBorder(KBFrame, Theme.BorderDark)
    Create("Frame", { Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, Parent = KBFrame })
    Create("TextLabel", { Size = UDim2.new(1, -10, 0, 22), Position = UDim2.new(0, 5, 0, 1), BackgroundTransparency = 1, Font = RenderFont, Text = "Active Keybinds", TextColor3 = Theme.TextPrimary, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Parent = KBFrame })
    local List = Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2), Parent = KBFrame })
    local Container = Create("Frame", { Size = UDim2.new(1, 0, 0, 0), Position = UDim2.new(0, 0, 0, 23), BackgroundTransparency = 1, Parent = KBFrame })
    List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() KBFrame.Size = UDim2.new(0, 210, 0, List.AbsoluteContentSize.Y + 24) end)
    Library.KeybindsFrame = Container
end

function Library:AddKeybindRow(name, keyStr)
    if not Library.KeybindsFrame then return end
    local Row = Create("Frame", { Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, Parent = Library.KeybindsFrame })
    local Lbl = Create("TextLabel", { Size = UDim2.new(1, -60, 1, 0), Position = UDim2.new(0, 6, 0, 0), BackgroundTransparency = 1, Font = RenderFont, Text = string.format("[%s] %s", keyStr, name), TextColor3 = Theme.TextSecondary, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, Parent = Row })
    local Mode = Create("TextLabel", { Size = UDim2.new(0, 50, 1, 0), Position = UDim2.new(1, -55, 0, 0), BackgroundTransparency = 1, Font = RenderFont, Text = "(Toggle)", TextColor3 = Theme.TextSecondary, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Right, Parent = Row })
    return { Update = function(newKey, act) Lbl.Text = string.format("[%s] %s", newKey, name) Mode.TextColor3 = act and Theme.Accent or Theme.TextSecondary end }
end

-- [2] ГЛАВНОЕ ОКНО С ЛЕВЫМИ ВКЛАДКАМИ И ПОИСКОМ
function Library:CreateWindow(windowTitle)
    local Window = { Tabs = {}, CurrentTab = nil }
    local MainFrame = Create("Frame", { Name = "MeteorMain", Size = UDim2.new(0, 660, 0, 480), Position = UDim2.new(0.5, -330, 0, 60), BackgroundColor3 = Theme.MainBg, Parent = ScreenGui })
    ApplyStrictBorder(MainFrame, Theme.BorderDark)

    -- Левая панель навигации (Sidebar)
    local Sidebar = Create("Frame", { Size = UDim2.new(0, 140, 1, 0), BackgroundColor3 = Theme.GroupBg, Parent = MainFrame })
    ApplyStrictBorder(Sidebar, Theme.BorderDark)
    Create("Frame", { Size = UDim2.new(0, 1, 1, 0), Position = UDim2.new(1, 0, 0, 0), BackgroundColor3 = Theme.BorderLight, BorderSizePixel = 0, Parent = Sidebar })

    -- Поиск бар (Внутри Сайбара сверху)
    local SearchBar = Create("Frame", { Size = UDim2.new(1, -12, 0, 22), Position = UDim2.new(0, 6, 0, 8), BackgroundColor3 = Theme.ElementBg, Parent = Sidebar })
    ApplyStrictBorder(SearchBar, Theme.BorderLight)
    local SearchInput = Create("TextBox", { Size = UDim2.new(1, -20, 1, 0), Position = UDim2.new(0, 4, 0, 0), BackgroundTransparency = 1, Font = RenderFont, Text = "", PlaceholderText = "Search...", PlaceholderColor3 = Theme.TextSecondary, TextColor3 = Theme.TextPrimary, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, Parent = SearchBar })

    -- Контейнер для кнопок вкладок
    local TabScroller = Create("ScrollingFrame", { Size = UDim2.new(1, -6, 1, -40), Position = UDim2.new(0, 3, 0, 36), BackgroundTransparency = 1, CanvasSize = UDim2.new(0, 0, 0, 0), ScrollBarThickness = 0, Parent = Sidebar })
    local TabListLayout = Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4), Parent = TabScroller })

    -- Правая рабочая область для контента
    local ContentArea = Create("Frame", { Size = UDim2.new(1, -140, 1, 0), Position = UDim2.new(0, 140, 0, 0), BackgroundTransparency = 1, Parent = MainFrame })

    -- Драггинг
    local dragging, dragInput, dragStart, startPos
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and input.Position.Y - MainFrame.AbsolutePosition.Y < 30 then
            dragging = true dragStart = input.Position startPos = MainFrame.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    MainFrame.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end end)
    InputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- [3] СОЗДАНИЕ ВЕРТИКАЛЬНЫХ ВКЛАДОК
    function Window:CreateTab(tabName)
        local Tab = { Groupboxes = {}, ElementsMap = {} }
        
        local TabButton = Create("TextButton", { Size = UDim2.new(1, 0, 0, 24), BackgroundColor3 = Theme.GroupBg, Font = RenderFont, Text = "  " .. tabName, TextColor3 = Theme.TextSecondary, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Parent = TabScroller })
        ApplyStrictBorder(TabButton, Theme.BorderDark)

        local TabView = Create("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Visible = false, Parent = ContentArea })
        
        -- Сетка из двух колонок (Левая/Правая) внутри открытой вкладки
        local LeftColumn = Create("ScrollingFrame", { Size = UDim2.new(0.5, -8, 1, -16), Position = UDim2.new(0, 6, 0, 8), BackgroundTransparency = 1, CanvasSize = UDim2.new(0, 0, 0, 0), ScrollBarThickness = 0, Parent = TabView })
        Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10), Parent = LeftColumn })
        
        local RightColumn = Create("ScrollingFrame", { Size = UDim2.new(0.5, -8, 1, -16), Position = UDim2.new(0.5, 2, 0, 8), BackgroundTransparency = 1, CanvasSize = UDim2.new(0, 0, 0, 0), ScrollBarThickness = 0, Parent = TabView })
        Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10), Parent = RightColumn })

        local function Select()
            if Window.CurrentTab then
                Window.CurrentTab.Button.TextColor3 = Theme.TextSecondary
                Window.CurrentTab.Button.BackgroundColor3 = Theme.GroupBg
                Window.CurrentTab.View.Visible = false
            end
            TabButton.TextColor3 = Theme.Accent
            TabButton.BackgroundColor3 = Theme.ElementBg
            TabView.Visible = true
            Window.CurrentTab = { Button = TabButton, View = TabView }
            CloseAllPopups()
        end
        TabButton.MouseButton1Click:Connect(Select)
        if not Window.CurrentTab then Select() end

        -- [4] СТРУКТУРНЫЕ ГРУПБОКСЫ
        function Tab:CreateGroupbox(boxName, columnSide)
            local Groupbox = { SubtabsContainer = nil }
            local targetColumn = (columnSide == "Right") and RightColumn or LeftColumn

            local GroupFrame = Create("Frame", { Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = Theme.GroupBg, Parent = targetColumn })
            ApplyStrictBorder(GroupFrame, Theme.BorderLight)
            
            local TopLine = Create("Frame", { Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, Parent = GroupFrame })
            local GroupTitle = Create("TextLabel", { Position = UDim2.new(0, 10, 0, -6), BackgroundColor3 = Theme.GroupBg, Font = RenderFont, Text = " " .. boxName .. " ", TextColor3 = Theme.TextPrimary, TextSize = 11, Parent = GroupFrame })
            GroupTitle.Size = UDim2.new(0, GroupTitle.TextBounds.X + 4, 0, 12)

            local ItemsList = Create("Frame", { Size = UDim2.new(1, -12, 1, -14), Position = UDim2.new(0, 6, 0, 8), BackgroundTransparency = 1, Parent = GroupFrame })
            local ItemsLayout = Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5), Parent = ItemsList })

            local function AutoResize()
                GroupFrame.Size = UDim2.new(1, 0, 0, ItemsLayout.AbsoluteContentSize.Y + 16)
                targetColumn.CanvasSize = UDim2.new(0, 0, 0, targetColumn.UIListLayout.AbsoluteContentSize.Y + 20)
            end
            ItemsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(AutoResize)

            -- Внутренние слоты/сабтабы внутри одного групбокса
            function Groupbox:CreateSubtabs()
                local SubSystem = { CurrentSub = nil }
                local Bar = Create("Frame", { Size = UDim2.new(1, 0, 0, 18), BackgroundColor3 = Theme.ElementBg, Parent = ItemsList })
                ApplyStrictBorder(Bar, Theme.BorderLight)
                Create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Parent = Bar })

                local MultiFrame = Create("Frame", { Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1, Parent = ItemsList })
                local MultiLayout = Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5), Parent = MultiFrame })
                MultiLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() MultiFrame.Size = UDim2.new(1, 0, 0, MultiLayout.AbsoluteContentSize.Y) AutoResize() end)
                Groupbox.SubtabsContainer = MultiFrame

                function SubSystem:AddSlot(slotName)
                    local SlotFrame = Create("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Visible = false, Parent = MultiFrame })
                    local SlotLayout = Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5), Parent = SlotFrame })
                    SlotLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() if SlotFrame.Visible then MultiFrame.Size = UDim2.new(1, 0, 0, SlotLayout.AbsoluteContentSize.Y) AutoResize() end end)

                    local Btn = Create("TextButton", { Size = UDim2.new(0, 60, 1, 0), BackgroundColor3 = Theme.ElementBg, Font = RenderFont, Text = slotName, TextColor3 = Theme.TextSecondary, TextSize = 10, Parent = Bar })
                    ApplyStrictBorder(Btn, Theme.BorderDark)

                    local function Activate()
                        if SubSystem.CurrentSub then SubSystem.CurrentSub.B.TextColor3 = Theme.TextSecondary SubSystem.CurrentSub.F.Visible = false end
                        Btn.TextColor3 = Theme.TextPrimary SlotFrame.Visible = true SubSystem.CurrentSub = { B = Btn, F = SlotFrame }
                        MultiFrame.Size = UDim2.new(1, 0, 0, SlotLayout.AbsoluteContentSize.Y) AutoResize()
                    end
                    Btn.MouseButton1Click:Connect(Activate) if not SubSystem.CurrentSub then Activate() end

                    local Proxy = {} setmetatable(Proxy, { __index = function(_, m) return function(self, ...) return Groupbox[m](Groupbox, ..., SlotFrame) end end })
                    return Proxy
                end
                return SubSystem
            end

            local function GetParent(override) return override or Groupbox.SubtabsContainer or ItemsList end

            -- [ЭЛЕМЕНТ]: Чекбокс (Toggle) + Аддоны (Бинд и Колорпикер)
            function Groupbox:CreateToggle(text, default, callback, overrideParent)
                local state = default or false local p = GetParent(overrideParent)
                local TFrame = Create("Frame", { Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1, Parent = p })
                local Box = Create("TextButton", { Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(0, 2, 0.5, -6), BackgroundColor3 = state and Theme.Accent or Theme.ElementBg, Text = "", Parent = TFrame })
                ApplyStrictBorder(Box, Theme.BorderDark)
                local Lbl = Create("TextButton", { Size = UDim2.new(1, -20, 1, 0), Position = UDim2.new(0, 20, 0, 0), BackgroundTransparency = 1, Font = RenderFont, Text = text, TextColor3 = state and Theme.TextPrimary or Theme.TextSecondary, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, Parent = TFrame })
                
                local Addons = Create("Frame", { Size = UDim2.new(0, 80, 1, 0), Position = UDim2.new(1, -80, 0, 0), BackgroundTransparency = 1, Parent = TFrame })
                Create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Right, Padding = UDim.new(0, 4), Parent = Addons })

                local function Press()
                    state = not state Box.BackgroundColor3 = state and Theme.Accent or Theme.ElementBg Lbl.TextColor3 = state and Theme.TextPrimary or Theme.TextSecondary
                    pcall(callback, state)
                end
                Box.MouseButton1Click:Connect(Press) Lbl.MouseButton1Click:Connect(Press)
                Tab.ElementsMap[text:lower()] = { Frame = TFrame }

                local Builder = {}
                function Builder:AddKeybind(initKey, bindCall)
                    local current = initKey or "None" local row = Library:AddKeybindRow(text, current)
                    local BBtn = Create("TextButton", { Size = UDim2.new(0, 30, 0, 12), BackgroundColor3 = Theme.ElementBg, Font = RenderFont, Text = "["..current.."]", TextColor3 = Theme.TextSecondary, TextSize = 9, Parent = Addons })
                    ApplyStrictBorder(BBtn, Theme.BorderDark)
                    BBtn.MouseButton1Click:Connect(function()
                        BBtn.Text = "[...]" local c con = InputService.InputBegan:Connect(function(i)
                            if i.UserInputType == Enum.UserInputType.Keyboard then current = i.KeyCode.Name elseif i.UserInputType == Enum.UserInputType.MouseButton1 then current = "MB1" elseif i.UserInputType == Enum.UserInputType.MouseButton2 then current = "MB2" end
                            BBtn.Text = "["..current.."]" if row then row.Update(current, state) end con:Disconnect()
                        end)
                    end)
                    InputService.InputBegan:Connect(function(i, proc) if not proc and ((i.UserInputType == Enum.UserInputType.Keyboard and i.KeyCode.Name == current) or (current == "MB1" and i.UserInputType == Enum.UserInputType.MouseButton1) or (current == "MB2" and i.UserInputType == Enum.UserInputType.MouseButton2)) then Press() if row then row.Update(current, state) end pcall(bindCall, state) end end)
                    return Builder
                end
                function Builder:AddColorPicker(initCol, cpCall)
                    local c = initCol or Color3.new(1,1,1)
                    local PBox = Create("TextButton", { Size = UDim2.new(0, 14, 0, 12), BackgroundColor3 = c, Text = "", Parent = Addons }) ApplyStrictBorder(PBox, Theme.BorderDark)
                    PBox.MouseButton1Click:Connect(function() Groupbox:OpenAdvancedColorPicker(text, c, function(nc) PBox.BackgroundColor3 = nc c = nc pcall(cpCall, nc) end) end)
                    return Builder
                end
                return Builder
            end

            -- [ЭЛЕМЕНТ]: Слайдер (Slider)
            function Groupbox:CreateSlider(text, min, max, default, fmt, callback, overrideParent)
                local p = GetParent(overrideParent) fmt = fmt or "%d/%d"
                local SFrame = Create("Frame", { Size = UDim2.new(1, 0, 0, 26), BackgroundTransparency = 1, Parent = p })
                Create("TextLabel", { Size = UDim2.new(1, 0, 0, 12), BackgroundTransparency = 1, Font = RenderFont, Text = text, TextColor3 = Theme.TextPrimary, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, Parent = SFrame })
                local Track = Create("TextButton", { Size = UDim2.new(1, -4, 0, 10), Position = UDim2.new(0, 2, 0, 13), BackgroundColor3 = Theme.ElementBg, Text = "", Parent = SFrame }) ApplyStrictBorder(Track, Theme.BorderDark)
                local Fill = Create("Frame", { Size = UDim2.new((default-min)/(max-min), 0, 1, 0), BackgroundColor3 = Theme.AccentSecondary, BorderSizePixel = 0, Parent = Track })
                local Disp = Create("TextLabel", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Font = RenderFont, Text = string.format(fmt, default, max), TextColor3 = Theme.TextPrimary, TextSize = 9, Parent = Track })
                
                local hold = false
                local function Upd(input)
                    local d = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1) local val = math.floor(min + (max - min) * d)
                    Disp.Text = string.format(fmt, val, max) Fill.Size = UDim2.new(d, 0, 1, 0) pcall(callback, val)
                end
                Track.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then hold = true CloseAllPopups() Upd(i) end end)
                InputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then hold = false end end)
                InputService.InputChanged:Connect(function(i) if hold and i.UserInputType == Enum.UserInputType.MouseMovement then Upd(i) end end)
                Tab.ElementsMap[text:lower()] = { Frame = SFrame }
            end

            -- [ЭЛЕМЕНТ]: Выпадающий список (Dropdown)
            function Groupbox:CreateDropdown(text, items, default, callback, overrideParent)
                local p = GetParent(overrideParent) local sel = default or items[1]
                local DFrame = Create("Frame", { Size = UDim2.new(1, 0, 0, 28), BackgroundTransparency = 1, Parent = p })
                Create("TextLabel", { Size = UDim2.new(1, 0, 0, 12), BackgroundTransparency = 1, Font = RenderFont, Text = text, TextColor3 = Theme.TextPrimary, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, Parent = DFrame })
                local Fld = Create("TextButton", { Size = UDim2.new(1, -4, 0, 14), Position = UDim2.new(0, 2, 0, 13), BackgroundColor3 = Theme.ElementBg, Font = RenderFont, Text = "  "..tostring(sel), TextColor3 = Theme.TextPrimary, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, Parent = DFrame }) ApplyStrictBorder(Fld, Theme.BorderDark)
                
                Fld.MouseButton1Click:Connect(function()
                    local n = text.."Pop" if ScreenGui:FindFirstChild(n) then ScreenGui[n]:Destroy() return end CloseAllPopups()
                    local M = Create("Frame", { Name = n, Size = UDim2.new(0, Fld.AbsoluteSize.X, 0, #items * 16), Position = UDim2.new(0, Fld.AbsolutePosition.X, 0, Fld.AbsolutePosition.Y + Fld.AbsoluteSize.Y + 2), BackgroundColor3 = Theme.MainBg, Parent = ScreenGui }) table.insert(Library.ActivePopups, M) ApplyStrictBorder(M, Theme.Accent)
                    Create("UIListLayout", { Parent = M })
                    for _, it in pairs(items) do
                        local R = Create("TextButton", { Size = UDim2.new(1, 0, 0, 16), BackgroundColor3 = Theme.MainBg, Font = RenderFont, Text = "  "..tostring(it), TextColor3 = (it==sel) and Theme.Accent or Theme.TextSecondary, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, Parent = M })
                        R.MouseButton1Click:Connect(function() sel = it Fld.Text = "  "..tostring(it) CloseAllPopups() pcall(callback, it) end)
                    end
                end)
                Tab.ElementsMap[text:lower()] = { Frame = DFrame }
            end

            -- [ЭЛЕМЕНТ]: Однострочный текстовый ввод (TextBox)
            function Groupbox:CreateTextBox(text, default, placeholder, callback, overrideParent)
                local p = GetParent(overrideParent)
                local BFrame = Create("Frame", { Size = UDim2.new(1, 0, 0, 28), BackgroundTransparency = 1, Parent = p })
                Create("TextLabel", { Size = UDim2.new(1, 0, 0, 12), BackgroundTransparency = 1, Font = RenderFont, Text = text, TextColor3 = Theme.TextPrimary, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, Parent = BFrame })
                local Inp = Create("TextBox", { Size = UDim2.new(1, -4, 0, 14), Position = UDim2.new(0, 2, 0, 13), BackgroundColor3 = Theme.ElementBg, Font = RenderFont, Text = default or "", PlaceholderText = placeholder or "Type...", PlaceholderColor3 = Theme.TextSecondary, TextColor3 = Theme.TextPrimary, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, Parent = BFrame }) ApplyStrictBorder(Inp, Theme.BorderDark)
                Inp.FocusLost:Connect(function() pcall(callback, Inp.Text) end)
                Tab.ElementsMap[text:lower()] = { Frame = BFrame }
            end

            -- [ЭЛЕМЕНТ]: Динамический многострочный лейбл
            function Groupbox:CreateLabel(text, overrideParent)
                local p = GetParent(overrideParent)
                local LFrame = Create("Frame", { Size = UDim2.new(1, 0, 0, 12), BackgroundTransparency = 1, Parent = p })
                local Txt = Create("TextLabel", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Font = RenderFont, Text = text, TextColor3 = Theme.TextPrimary, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, Parent = LFrame })
                Txt:GetPropertyChangedSignal("TextBounds"):Connect(function() LFrame.Size = UDim2.new(1, 0, 0, Txt.TextBounds.Y + 2) end)
                LFrame.Size = UDim2.new(1, 0, 0, Txt.TextBounds.Y + 2)
                Tab.ElementsMap[text:lower()] = { Frame = LFrame }
            end

            -- [ВНУТРЕННИЙ МОДУЛЬ]: Профессиональная 2D HSV Палитра
            function Groupbox:OpenAdvancedColorPicker(title, initCol, cpCall)
                CloseAllPopups() local h, s, v = initCol:ToHSV()
                local CP = Create("Frame", { Size = UDim2.new(0, 170, 0, 180), Position = UDim2.new(0, MainFrame.AbsolutePosition.X + MainFrame.AbsoluteSize.X + 8, 0, MainFrame.AbsolutePosition.Y), BackgroundColor3 = Theme.MainBg, Parent = ScreenGui }) ApplyStrictBorder(CP, Theme.Accent) table.insert(Library.ActivePopups, CP)
                Create("TextLabel", { Size = UDim2.new(1, -10, 0, 16), Position = UDim2.new(0, 6, 0, 2), BackgroundTransparency = 1, Font = RenderFont, Text = title, TextColor3 = Theme.TextPrimary, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, Parent = CP })
                
                local Canvas = Create("TextButton", { Size = UDim2.new(0, 130, 0, 110), Position = UDim2.new(0, 6, 0, 20), BackgroundColor3 = Color3.fromHSV(h, 1, 1), Text = "", Parent = CP }) ApplyStrictBorder(Canvas, Theme.BorderDark)
                local W = Create("Frame", { Size = UDim2.new(1, 0, 1, 0), Parent = Canvas }) Create("UIGradient", { Color = ColorSequence.new(Color3.new(1,1,1)), Transparency = NumberSequence.new(0, 1), Parent = W })
                local B = Create("Frame", { Size = UDim2.new(1, 0, 1, 0), Parent = Canvas }) Create("UIGradient", { Color = ColorSequence.new(Color3.new(0,0,0)), Transparency = NumberSequence.new(1, 0), Rotation = 90, Parent = B })
                local Dot = Create("Frame", { Size = UDim2.new(0, 4, 0, 4), Position = UDim2.new(s, -2, 1-v, -2), BackgroundColor3 = Color3.new(1,1,1), Parent = Canvas }) Create("UICorner", { CornerRadius = UDim.new(1,0), Parent = Dot })

                local Hue = Create("TextButton", { Size = UDim2.new(0, 12, 0, 110), Position = UDim2.new(0, 142, 0, 20), Text = "", Parent = CP }) ApplyStrictBorder(Hue, Theme.BorderDark)
                Create("UIGradient", { Rotation = 90, Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)), ColorSequenceKeypoint.new(0.16, Color3.fromRGB(255,255,0)), ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0,255,0)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,255,255)), ColorSequenceKeypoint.new(0.66, Color3.fromRGB(0,0,255)), ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255,0,255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,0)) }), Parent = Hue })
                local BarInd = Create("Frame", { Size = UDim2.new(1, 4, 0, 2), Position = UDim2.new(0, -2, h, -1), BackgroundColor3 = Color3.new(1,1,1), Parent = Hue })

                local Hex = Create("TextBox", { Size = UDim2.new(0, 65, 0, 16), Position = UDim2.new(0, 6, 0, 136), BackgroundColor3 = Theme.ElementBg, Font = RenderFont, Text = RGBToHex(initCol), TextColor3 = Theme.TextPrimary, TextSize = 10, Parent = CP }) ApplyStrictBorder(Hex, Theme.BorderDark)
                local Preview = Create("Frame", { Size = UDim2.new(0, 83, 0, 16), Position = UDim2.new(0, 76, 0, 136), BackgroundColor3 = initCol, Parent = CP }) ApplyStrictBorder(Preview, Theme.BorderDark)

                local function Sync()
                    local c = Color3.fromHSV(h, s, v) Canvas.BackgroundColor3 = Color3.fromHSV(h, 1, 1) Preview.BackgroundColor3 = c
                    Dot.Position = UDim2.new(s, -2, 1-v, -2) BarInd.Position = UDim2.new(0, -2, h, -1) Hex.Text = RGBToHex(c) pcall(cpCall, c)
                end
                local dSV, dH = false, false
                Canvas.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dSV = true end end)
                Hue.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dH = true end end)
                InputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dSV = false dH = false end end)
                InputService.InputChanged:Connect(function(i)
                    if dSV and i.UserInputType == Enum.UserInputType.MouseMovement then
                        s = math.clamp((i.Position.X - Canvas.AbsolutePosition.X) / Canvas.AbsoluteSize.X, 0, 1)
                        v = 1 - math.clamp((i.Position.Y - Canvas.AbsolutePosition.Y) / Canvas.AbsoluteSize.Y, 0, 1) Sync()
                    elseif dH and i.UserInputType == Enum.UserInputType.MouseMovement then
                        h = math.clamp((i.Position.Y - Hue.AbsolutePosition.Y) / Hue.AbsoluteSize.Y, 0, 1) Sync()
                    end
                end)
            end
            return Groupbox
        end
        Window.Tabs[tabName] = Tab return Tab
    end

    -- Логика сквозного поиска элементов на текущей рабочей вкладке
    SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
        local q = SearchInput.Text:lower()
        for _, tab in pairs(Window.Tabs) do
            for name, el in pairs(tab.ElementsMap) do el.Frame.Visible = (q == "" or string.find(name, q)) and true or false end
        end
    end)

    InputService.InputBegan:Connect(function(i, proc) if not proc and i.KeyCode == Enum.KeyCode.RightShift then MainFrame.Visible = not MainFrame.Visible CloseAllPopups() end end)
    return Window
end

-- =============================================================================
-- ПРИМЕР СТРУКТУРНОЙ ДЕМОНСТРАЦИИ ПОЛНОГО КОНФИГА
-- =============================================================================
Library:InitWatermark("METEOR SYSTEM CLIENT")
Library:InitKeybinds()

local Win = Library:CreateWindow("METEOR PREMIUM")

-- Создаем 1 Вкладку: Combat (Проверяем Сабтабы, Слайдеры, Дропдауны)
local Combat = Win:CreateTab("Combat")
local MainBox = Combat:CreateGroupbox("Aimbot Engine", "Left")

local Slots = MainBox:CreateSubtabs()
local Primary = Slots:AddSlot("Primary")
local Secondary = Slots:AddSlot("Secondary")

-- Навешиваем на один тоггл полный комплект аддонов
local AimToggle = Primary:CreateToggle("Rage Silent Aim", true, function(s) print("Silent state:", s) end)
AimToggle:AddKeybind("F", function(a) print("Bind state:", a) end)
AimToggle:AddColorPicker(Color3.fromRGB(218, 43, 172), function(c) print("Fov Color:", c) end)

Primary:CreateSlider("Field Of View", 1, 300, 90, "%d FOV px", function(v) end)
Primary:CreateDropdown("Target Priority", {"Distance", "Health", "Crosshair"}, "Distance", function(d) end)

Secondary:CreateToggle("Fallback Triggerbot", false, function(s) end):AddKeybind("X", function() end)
Secondary:CreateTextBox("Target Blacklist", "Username", "Player to ignore...", function(t) end)

-- Создаем 2 Вкладку: Visuals (Проверяем Колонки, Лейблы и Поиск)
local Visuals = Win:CreateTab("Visuals")
local EspBox = Visuals:CreateGroupbox("Render Settings", "Left")
EspBox:CreateToggle("Bounding Boxes", false, function(s) end):AddColorPicker(Color3.fromRGB(0,255,100), function() end)

local InfoBox = Visuals:CreateGroupbox("Meteor Help", "Right")
InfoBox:CreateLabel("Welcome back. All tabs are now correctly anchored on the left sidebar as requested.")
InfoBox:CreateLabel("The input filter on top will dynamically parse and hide components across the engine instantly.")

return Library
