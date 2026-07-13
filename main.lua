-- ╔══════════════════════════════════════════════════════════╗
-- ║         METEOR UI LIBRARY — FULL ARCHITECTURE v2.0       ║
-- ║   Button · Toggle · Slider · Dropdown · TextBox          ║
-- ║   ColorPicker · Keybind · Label · Separator              ║
-- ╚══════════════════════════════════════════════════════════╝

local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local LocalPlayer      = Players.LocalPlayer

-- ── ТЕМА ────────────────────────────────────────────────────
local Theme = {
    -- фоны
    MainBg      = Color3.fromRGB(10, 10, 14),
    ElementBg   = Color3.fromRGB(17, 17, 23),
    ElementHov  = Color3.fromRGB(24, 24, 33),
    PopupBg     = Color3.fromRGB(13, 13, 18),
    -- акцент
    Accent      = Color3.fromRGB(218, 43, 172),
    AccentDim   = Color3.fromRGB(140, 28, 110),
    AccentHov   = Color3.fromRGB(240, 60, 195),
    -- текст
    TextPri     = Color3.fromRGB(255, 255, 255),
    TextSec     = Color3.fromRGB(120, 120, 132),
    TextDis     = Color3.fromRGB(60,  60,  72),
    -- UI
    Border      = Color3.fromRGB(28, 28, 40),
    TrackBg     = Color3.fromRGB(38, 38, 52),
    ToggleOff   = Color3.fromRGB(42, 42, 56),
}

-- ── УТИЛИТЫ ─────────────────────────────────────────────────
local function Tween(obj, props, t, style, dir)
    TweenService:Create(obj,
        TweenInfo.new(t or 0.14, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out),
        props):Play()
end

local function Corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 4)
    c.Parent = parent
    return c
end

local function Stroke(parent, color, thick)
    local s = Instance.new("UIStroke")
    s.Color         = color or Theme.Border
    s.Thickness     = thick or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent        = parent
    return s
end

local function Label(parent, text, size, color, font, xa, ya)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Text          = text or ""
    l.TextSize      = size or 11
    l.TextColor3    = color or Theme.TextPri
    l.Font          = font  or Enum.Font.Gotham
    l.TextXAlignment = xa   or Enum.TextXAlignment.Left
    l.TextYAlignment = ya   or Enum.TextYAlignment.Center
    l.Parent        = parent
    return l
end

-- hover-эффект на кнопкообразных фреймах
local function HoverFX(btn, bgNorm, bgHov)
    btn.MouseEnter:Connect(function() Tween(btn, {BackgroundColor3 = bgHov  or Theme.ElementHov}) end)
    btn.MouseLeave:Connect(function() Tween(btn, {BackgroundColor3 = bgNorm or Theme.ElementBg }) end)
end

-- ── ПОПАПЫ ──────────────────────────────────────────────────
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name           = "MeteorLib"
ScreenGui.ResetOnSpawn   = false
ScreenGui.DisplayOrder   = 999
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent         = LocalPlayer:WaitForChild("PlayerGui")

local PopupLayer = Instance.new("Frame")   -- прозрачный слой поверх всего
PopupLayer.Size                 = UDim2.new(1,0,1,0)
PopupLayer.BackgroundTransparency = 1
PopupLayer.ZIndex               = 50
PopupLayer.Parent               = ScreenGui

local function CloseAllPopups()
    for _, v in ipairs(PopupLayer:GetChildren()) do v:Destroy() end
end

-- закрыть попап по клику вне его
PopupLayer.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        CloseAllPopups()
    end
end)

-- ── TOP BAR ─────────────────────────────────────────────────
--   Прижат к самому верху (Y = 0), высота 34 px
local BAR_W  = 530
local BAR_H  = 34
local PAGE_H = 170

local TopBar = Instance.new("Frame")
TopBar.Name            = "TopBar"
TopBar.Size            = UDim2.new(0, BAR_W, 0, BAR_H)
TopBar.Position        = UDim2.new(0.5, -BAR_W/2, 0, 0)   -- ← верхний край экрана
TopBar.BackgroundColor3 = Theme.MainBg
TopBar.BorderSizePixel = 0
TopBar.ZIndex          = 10
TopBar.Parent          = ScreenGui
Corner(TopBar, 0)   -- без скруглений сверху (прижат к краю)
Stroke(TopBar, Theme.Border, 1)

-- нижняя розовая линия
local BarLine = Instance.new("Frame")
BarLine.Size            = UDim2.new(1, 0, 0, 1)
BarLine.Position        = UDim2.new(0, 0, 1, -1)
BarLine.BackgroundColor3 = Theme.Accent
BarLine.BorderSizePixel = 0
BarLine.ZIndex          = 11
BarLine.Parent          = TopBar

-- логотип/иконка слева
local LogoLabel = Instance.new("TextLabel")
LogoLabel.Size            = UDim2.new(0, 70, 1, 0)
LogoLabel.Position        = UDim2.new(0, 8, 0, 0)
LogoLabel.BackgroundTransparency = 1
LogoLabel.Text            = "✦ meteor"
LogoLabel.TextColor3      = Theme.Accent
LogoLabel.Font            = Enum.Font.GothamBold
LogoLabel.TextSize        = 12
LogoLabel.TextXAlignment  = Enum.TextXAlignment.Left
LogoLabel.ZIndex          = 11
LogoLabel.Parent          = TopBar

-- контейнер вкладок (после логотипа)
local TabContainer = Instance.new("Frame")
TabContainer.Size               = UDim2.new(0, 310, 1, -2)
TabContainer.Position           = UDim2.new(0, 84, 0, 0)
TabContainer.BackgroundTransparency = 1
TabContainer.ZIndex             = 11
TabContainer.Parent             = TopBar

local TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection  = Enum.FillDirection.Horizontal
TabLayout.SortOrder      = Enum.SortOrder.LayoutOrder
TabLayout.Padding        = UDim.new(0, 2)
TabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
TabLayout.Parent         = TabContainer

-- строка поиска справа
local SearchBox = Instance.new("Frame")
SearchBox.Size            = UDim2.new(0, 120, 0, 20)
SearchBox.Position        = UDim2.new(1, -128, 0.5, -10)
SearchBox.BackgroundColor3 = Theme.ElementBg
SearchBox.BorderSizePixel = 0
SearchBox.ZIndex          = 11
SearchBox.Parent          = TopBar
Corner(SearchBox, 4)
Stroke(SearchBox, Theme.Border, 1)

local SearchIcon = Instance.new("ImageLabel")
SearchIcon.Size            = UDim2.new(0, 12, 0, 12)
SearchIcon.Position        = UDim2.new(0, 5, 0.5, -6)
SearchIcon.BackgroundTransparency = 1
SearchIcon.Image           = "rbxassetid://11868577178784 3"   -- твоя лупа
SearchIcon.ImageColor3     = Theme.TextSec
SearchIcon.ZIndex          = 12
SearchIcon.Parent          = SearchBox

local SearchInput = Instance.new("TextBox")
SearchInput.Size            = UDim2.new(1, -22, 1, 0)
SearchInput.Position        = UDim2.new(0, 20, 0, 0)
SearchInput.BackgroundTransparency = 1
SearchInput.Font            = Enum.Font.Gotham
SearchInput.Text            = ""
SearchInput.PlaceholderText = "Search.."
SearchInput.PlaceholderColor3 = Theme.TextSec
SearchInput.TextColor3      = Theme.TextPri
SearchInput.TextSize        = 10
SearchInput.TextXAlignment  = Enum.TextXAlignment.Left
SearchInput.ZIndex          = 12
SearchInput.ClearTextOnFocus = false
SearchInput.Parent          = SearchBox

-- ── PAGE CONTAINER (сразу под баром, Y = 34) ────────────────
local PageContainer = Instance.new("Frame")
PageContainer.Name            = "Pages"
PageContainer.Size            = UDim2.new(0, BAR_W, 0, PAGE_H)
PageContainer.Position        = UDim2.new(0.5, -BAR_W/2, 0, BAR_H)
PageContainer.BackgroundColor3 = Theme.MainBg
PageContainer.BorderSizePixel = 0
PageContainer.ClipsDescendants = true
PageContainer.ZIndex          = 9
PageContainer.Parent          = ScreenGui
Corner(PageContainer, 0)
Stroke(PageContainer, Theme.Border, 1)

-- ── DRAG (перетаскивание за TopBar) ─────────────────────────
do
    local dragging, dragStart, startPos
    TopBar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging  = true
            dragStart = i.Position
            startPos  = TopBar.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = i.Position - dragStart
            local newPos = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            TopBar.Position        = newPos
            PageContainer.Position = UDim2.new(
                newPos.X.Scale, newPos.X.Offset,
                newPos.Y.Scale, newPos.Y.Offset + BAR_H)
            PopupLayer:ClearAllChildren()
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
end

-- ════════════════════════════════════════════════════════════
-- LIBRARY CORE
-- ════════════════════════════════════════════════════════════
local Library     = {}
local Pages       = {}
local AllElements = {}   -- для поиска
local ActivePage  = nil
local FirstActivate = nil

-- скрыть/показать по RightShift
local guiVisible = true
UserInputService.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.KeyCode == Enum.KeyCode.RightShift then
        guiVisible = not guiVisible
        TopBar.Visible         = guiVisible
        PageContainer.Visible  = guiVisible
        if not guiVisible then CloseAllPopups() end
    end
end)

-- ── ПОИСК ───────────────────────────────────────────────────
SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
    local q = SearchInput.Text:lower()
    CloseAllPopups()
    for _, e in ipairs(AllElements) do
        if q == "" then
            e.Frame.Visible = true
        elseif string.find(e.Name, q, 1, true) then
            e.Frame.Visible = true
            e.Activate()
        else
            e.Frame.Visible = false
        end
    end
end)

-- ════════════════════════════════════════════════════════════
-- CreateTab
-- ════════════════════════════════════════════════════════════
function Library:CreateTab(name, icon)

    -- страница (ScrollingFrame)
    local Page = Instance.new("ScrollingFrame")
    Page.Name                 = name .. "_Page"
    Page.Size                 = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible              = false
    Page.ScrollBarThickness   = 2
    Page.ScrollBarImageColor3 = Theme.Accent
    Page.CanvasSize           = UDim2.new(0,0,0,0)
    Page.AutomaticCanvasSize  = Enum.AutomaticSize.Y
    Page.ZIndex               = 10
    Page.Parent               = PageContainer

    -- сетка элементов
    local Grid = Instance.new("UIGridLayout")
    Grid.CellSize    = UDim2.new(0, 165, 0, 30)
    Grid.CellPadding = UDim2.new(0, 8, 0, 6)
    Grid.SortOrder   = Enum.SortOrder.LayoutOrder
    Grid.Parent      = Page

    local GridPad = Instance.new("UIPadding")
    GridPad.PaddingTop    = UDim.new(0, 8)
    GridPad.PaddingLeft   = UDim.new(0, 8)
    GridPad.PaddingRight  = UDim.new(0, 8)
    GridPad.PaddingBottom = UDim.new(0, 8)
    GridPad.Parent        = Page

    -- кнопка вкладки
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size            = UDim2.new(0, 64, 1, -6)
    TabBtn.BackgroundTransparency = 1
    TabBtn.Font            = Enum.Font.GothamSemibold
    TabBtn.Text            = (icon and (icon .. "  ") or "") .. name
    TabBtn.TextColor3      = Theme.TextSec
    TabBtn.TextSize        = 11
    TabBtn.AutoButtonColor = false
    TabBtn.ZIndex          = 12
    TabBtn.Parent          = TabContainer

    -- розовый индикатор под активной вкладкой
    local TabLine = Instance.new("Frame")
    TabLine.Size            = UDim2.new(0.7, 0, 0, 1)
    TabLine.Position        = UDim2.new(0.15, 0, 1, -1)
    TabLine.BackgroundColor3 = Theme.Accent
    TabLine.BackgroundTransparency = 1   -- скрыт по умолчанию
    TabLine.BorderSizePixel = 0
    TabLine.ZIndex          = 13
    TabLine.Parent          = TabBtn

    local function Activate()
        CloseAllPopups()
        -- скрыть всё
        for _, p in pairs(Pages) do p.Visible = false end
        for _, b in ipairs(TabContainer:GetChildren()) do
            if b:IsA("TextButton") then
                Tween(b, {TextColor3 = Theme.TextSec})
                local ln = b:FindFirstChildOfClass("Frame")
                if ln then ln.BackgroundTransparency = 1 end
            end
        end
        -- показать текущее
        Page.Visible              = true
        ActivePage                = Page
        Tween(TabBtn, {TextColor3 = Theme.TextPri})
        TabLine.BackgroundTransparency = 0
    end

    TabBtn.MouseButton1Click:Connect(Activate)
    TabBtn.MouseEnter:Connect(function()
        if not Page.Visible then Tween(TabBtn, {TextColor3 = Theme.TextPri}) end
    end)
    TabBtn.MouseLeave:Connect(function()
        if not Page.Visible then Tween(TabBtn, {TextColor3 = Theme.TextSec}) end
    end)

    Pages[name] = Page
    if not FirstActivate then FirstActivate = Activate end

    -- ── ВСПОМОГАТЕЛЬНЫЕ ──────────────────────────────────────
    local function BaseFrame(spanCols)
        -- spanCols: nil=1, 2=двойная ширина (для ColPicker, Keybind)
        local f = Instance.new("Frame")
        f.BackgroundColor3 = Theme.ElementBg
        f.BorderSizePixel  = 0
        f.LayoutOrder      = #Page:GetChildren()
        if spanCols == 2 then
            -- UIGridLayout не поддерживает span, поэтому ставим полную ширину
            f.Size = UDim2.new(1, -16, 0, 30)
        end
        f.Parent = Page
        Corner(f, 4)
        Stroke(f, Theme.Border, 1)
        HoverFX(f, Theme.ElementBg, Theme.ElementHov)
        return f
    end

    local function RegElem(frame, name_)
        table.insert(AllElements, {Frame = frame, Name = name_:lower(), Activate = Activate})
    end

    local Elem = {}

    -- ══════════════════════════════════════════════════════════
    -- 1. LABEL (заголовок / текст)
    -- ══════════════════════════════════════════════════════════
    function Elem:CreateLabel(text)
        local f = Instance.new("Frame")
        f.BackgroundTransparency = 1
        f.BorderSizePixel = 0
        f.LayoutOrder     = #Page:GetChildren()
        f.Parent          = Page
        local l = Label(f, text, 10, Theme.TextSec, Enum.Font.GothamSemibold)
        l.Size     = UDim2.new(1, -8, 1, 0)
        l.Position = UDim2.new(0, 8, 0, 0)
        RegElem(f, text)
    end

    -- ══════════════════════════════════════════════════════════
    -- 2. SEPARATOR
    -- ══════════════════════════════════════════════════════════
    function Elem:CreateSeparator(text)
        local f = Instance.new("Frame")
        f.BackgroundTransparency = 1
        f.BorderSizePixel = 0
        f.LayoutOrder     = #Page:GetChildren()
        f.Parent          = Page

        local line = Instance.new("Frame")
        line.Size            = UDim2.new(1, -8, 0, 1)
        line.Position        = UDim2.new(0, 4, 0.5, 0)
        line.BackgroundColor3 = Theme.Border
        line.BorderSizePixel = 0
        line.Parent          = f

        if text and text ~= "" then
            local bg = Instance.new("Frame")
            bg.Size            = UDim2.new(0, #text * 6 + 12, 0, 14)
            bg.Position        = UDim2.new(0.5, -((#text * 6 + 12)/2), 0.5, -7)
            bg.BackgroundColor3 = Theme.MainBg
            bg.BorderSizePixel = 0
            bg.Parent          = f
            local t = Label(bg, text, 9, Theme.TextSec, Enum.Font.GothamSemibold, Enum.TextXAlignment.Center)
            t.Size = UDim2.new(1,0,1,0)
        end
        RegElem(f, text or "sep")
    end

    -- ══════════════════════════════════════════════════════════
    -- 3. BUTTON
    -- ══════════════════════════════════════════════════════════
    function Elem:CreateButton(text, callback)
        local f = BaseFrame()
        local lbl = Label(f, text, 11, Theme.TextPri, Enum.Font.GothamSemibold)
        lbl.Size     = UDim2.new(1, -8, 1, 0)
        lbl.Position = UDim2.new(0, 8, 0, 0)
        lbl.TextXAlignment = Enum.TextXAlignment.Center

        local btn = Instance.new("TextButton")
        btn.Size   = UDim2.new(1,0,1,0)
        btn.BackgroundTransparency = 1
        btn.Text   = ""
        btn.Parent = f

        btn.MouseButton1Click:Connect(function()
            CloseAllPopups()
            Tween(f, {BackgroundColor3 = Theme.Accent}, 0.05)
            task.delay(0.12, function() Tween(f, {BackgroundColor3 = Theme.ElementBg}) end)
            pcall(callback)
        end)
        RegElem(f, text)
    end

    -- ══════════════════════════════════════════════════════════
    -- 4. TOGGLE
    -- ══════════════════════════════════════════════════════════
    function Elem:CreateToggle(text, default, callback)
        local state = default or false
        local f     = BaseFrame()

        local lbl = Label(f, text, 11, Theme.TextPri)
        lbl.Size     = UDim2.new(1, -38, 1, 0)
        lbl.Position = UDim2.new(0, 8, 0, 0)

        -- pill-переключатель 26×14
        local Track = Instance.new("Frame")
        Track.Size            = UDim2.new(0, 26, 0, 14)
        Track.Position        = UDim2.new(1, -34, 0.5, -7)
        Track.BackgroundColor3 = state and Theme.Accent or Theme.ToggleOff
        Track.BorderSizePixel = 0
        Track.Parent          = f
        Corner(Track, 7)

        local Thumb = Instance.new("Frame")
        Thumb.Size            = UDim2.new(0, 10, 0, 10)
        Thumb.Position        = UDim2.new(0, state and 14 or 2, 0.5, -5)
        Thumb.BackgroundColor3 = Color3.fromRGB(255,255,255)
        Thumb.BorderSizePixel = 0
        Thumb.Parent          = Track
        Corner(Thumb, 5)

        local btn = Instance.new("TextButton")
        btn.Size   = UDim2.new(1,0,1,0)
        btn.BackgroundTransparency = 1
        btn.Text   = ""
        btn.Parent = f

        btn.MouseButton1Click:Connect(function()
            CloseAllPopups()
            state = not state
            Tween(Track, {BackgroundColor3 = state and Theme.Accent or Theme.ToggleOff})
            Tween(Thumb, {Position = UDim2.new(0, state and 14 or 2, 0.5, -5)})
            pcall(callback, state)
        end)
        RegElem(f, text)

        -- внешний контроль
        return {
            SetState = function(_, v)
                state = v
                Tween(Track, {BackgroundColor3 = state and Theme.Accent or Theme.ToggleOff})
                Tween(Thumb, {Position = UDim2.new(0, state and 14 or 2, 0.5, -5)})
                pcall(callback, state)
            end,
            GetState = function() return state end,
        }
    end

    -- ══════════════════════════════════════════════════════════
    -- 5. SLIDER
    -- ══════════════════════════════════════════════════════════
    function Elem:CreateSlider(text, min, max, default, step, callback)
        step = step or 1
        local val = default or min
        local f   = BaseFrame()

        local lbl = Label(f, text, 10, Theme.TextPri)
        lbl.Size     = UDim2.new(1, -48, 0, 14)
        lbl.Position = UDim2.new(0, 8, 0, 2)

        local valLbl = Label(f, tostring(val), 10, Theme.Accent, Enum.Font.GothamBold, Enum.TextXAlignment.Right)
        valLbl.Size     = UDim2.new(0, 38, 0, 14)
        valLbl.Position = UDim2.new(1, -42, 0, 2)

        -- трек
        local Track = Instance.new("TextButton")
        Track.Size            = UDim2.new(1, -16, 0, 3)
        Track.Position        = UDim2.new(0, 8, 1, -7)
        Track.BackgroundColor3 = Theme.TrackBg
        Track.Text            = ""
        Track.BorderSizePixel = 0
        Track.AutoButtonColor = false
        Track.Parent          = f
        Corner(Track, 2)

        local Fill = Instance.new("Frame")
        Fill.Size            = UDim2.new((val-min)/(max-min), 0, 1, 0)
        Fill.BackgroundColor3 = Theme.Accent
        Fill.BorderSizePixel = 0
        Fill.Parent          = Track
        Corner(Fill, 2)

        -- кружок-ручка
        local Knob = Instance.new("Frame")
        Knob.Size            = UDim2.new(0, 9, 0, 9)
        Knob.AnchorPoint     = Vector2.new(0.5, 0.5)
        Knob.Position        = UDim2.new((val-min)/(max-min), 0, 0.5, 0)
        Knob.BackgroundColor3 = Theme.TextPri
        Knob.BorderSizePixel = 0
        Knob.Parent          = Track
        Corner(Knob, 5)

        local sliding = false
        local function UpdateSlider(input)
            local pct = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
            local raw = min + (max - min) * pct
            val = math.floor(raw / step + 0.5) * step
            val = math.clamp(val, min, max)
            local realPct = (val - min) / (max - min)
            Tween(Fill, {Size = UDim2.new(realPct, 0, 1, 0)}, 0.05)
            Tween(Knob, {Position = UDim2.new(realPct, 0, 0.5, 0)}, 0.05)
            valLbl.Text = tostring(val)
            pcall(callback, val)
        end

        Track.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                CloseAllPopups()
                sliding = true
                UpdateSlider(i)
            end
        end)
        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if sliding and i.UserInputType == Enum.UserInputType.MouseMovement then UpdateSlider(i) end
        end)

        RegElem(f, text)
        return {
            SetValue = function(_, v)
                val = math.clamp(v, min, max)
                local p = (val-min)/(max-min)
                Fill.Size     = UDim2.new(p,0,1,0)
                Knob.Position = UDim2.new(p,0,0.5,0)
                valLbl.Text   = tostring(val)
                pcall(callback, val)
            end,
            GetValue = function() return val end,
        }
    end

    -- ══════════════════════════════════════════════════════════
    -- 6. TEXTBOX
    -- ══════════════════════════════════════════════════════════
    function Elem:CreateTextBox(label, placeholder, callback)
        local f = BaseFrame()

        local lbl = Label(f, label, 10, Theme.TextSec)
        lbl.Size     = UDim2.new(0, 70, 1, 0)
        lbl.Position = UDim2.new(0, 8, 0, 0)

        local inner = Instance.new("Frame")
        inner.Size            = UDim2.new(1, -88, 0, 18)
        inner.Position        = UDim2.new(0, 80, 0.5, -9)
        inner.BackgroundColor3 = Theme.TrackBg
        inner.BorderSizePixel = 0
        inner.Parent          = f
        Corner(inner, 3)
        Stroke(inner, Theme.Border, 1)

        local box = Instance.new("TextBox")
        box.Size            = UDim2.new(1, -8, 1, 0)
        box.Position        = UDim2.new(0, 4, 0, 0)
        box.BackgroundTransparency = 1
        box.Font            = Enum.Font.Gotham
        box.Text            = ""
        box.PlaceholderText = placeholder or ""
        box.PlaceholderColor3 = Theme.TextSec
        box.TextColor3      = Theme.TextPri
        box.TextSize        = 10
        box.TextXAlignment  = Enum.TextXAlignment.Left
        box.ClearTextOnFocus = false
        box.Parent          = inner

        box.Focused:Connect(function() Tween(inner, {BackgroundColor3 = Theme.ElementHov}) end)
        box.FocusLost:Connect(function(enter)
            Tween(inner, {BackgroundColor3 = Theme.TrackBg})
            pcall(callback, box.Text, enter)
        end)

        RegElem(f, label)
        return {
            GetText = function() return box.Text end,
            SetText = function(_, t) box.Text = t end,
        }
    end

    -- ══════════════════════════════════════════════════════════
    -- 7. DROPDOWN (с поиском внутри)
    -- ══════════════════════════════════════════════════════════
    function Elem:CreateDropdown(text, list, callback)
        local selected = nil
        local f = BaseFrame()

        local lbl = Label(f, text, 11, Theme.TextPri)
        lbl.Size     = UDim2.new(1, -52, 1, 0)
        lbl.Position = UDim2.new(0, 8, 0, 0)

        local arrow = Label(f, "▾", 11, Theme.Accent, Enum.Font.GothamBold, Enum.TextXAlignment.Right)
        arrow.Size     = UDim2.new(0, 18, 1, 0)
        arrow.Position = UDim2.new(1, -22, 0, 0)

        local selLbl = Label(f, "none", 10, Theme.TextSec, Enum.Font.Gotham, Enum.TextXAlignment.Right)
        selLbl.Size     = UDim2.new(0, 80, 1, 0)
        selLbl.Position = UDim2.new(1, -104, 0, 0)

        local btn = Instance.new("TextButton")
        btn.Size   = UDim2.new(1,0,1,0)
        btn.BackgroundTransparency = 1
        btn.Text   = ""
        btn.Parent = f

        btn.MouseButton1Click:Connect(function()
            local alreadyOpen = PopupLayer:FindFirstChild(text .. "_drop")
            CloseAllPopups()
            if alreadyOpen then return end

            local absPos = f.AbsolutePosition
            local absSize = f.AbsoluteSize
            local itemH   = 24
            local maxVis  = 5
            local menuH   = math.min(#list, maxVis) * itemH + 2

            local Menu = Instance.new("Frame")
            Menu.Name            = text .. "_drop"
            Menu.Size            = UDim2.new(0, absSize.X, 0, menuH)
            Menu.Position        = UDim2.new(0, absPos.X, 0, absPos.Y + absSize.Y + 2)
            Menu.BackgroundColor3 = Theme.PopupBg
            Menu.BorderSizePixel = 0
            Menu.ZIndex          = 60
            Menu.Parent          = PopupLayer
            Corner(Menu, 4)
            Stroke(Menu, Theme.Accent, 1)

            local Scroll = Instance.new("ScrollingFrame")
            Scroll.Size               = UDim2.new(1,0,1,0)
            Scroll.BackgroundTransparency = 1
            Scroll.CanvasSize         = UDim2.new(0,0,0,#list*itemH)
            Scroll.ScrollBarThickness = 2
            Scroll.ScrollBarImageColor3 = Theme.Accent
            Scroll.ZIndex             = 61
            Scroll.Parent             = Menu
            Instance.new("UIListLayout", Scroll)

            for _, opt in ipairs(list) do
                local ob = Instance.new("TextButton")
                ob.Size            = UDim2.new(1,0,0,itemH)
                ob.BackgroundColor3 = (opt == selected) and Theme.ElementHov or Theme.PopupBg
                ob.BorderSizePixel = 0
                ob.Font            = Enum.Font.Gotham
                ob.Text            = "  " .. tostring(opt)
                ob.TextColor3      = (opt == selected) and Theme.TextPri or Theme.TextSec
                ob.TextSize        = 11
                ob.TextXAlignment  = Enum.TextXAlignment.Left
                ob.AutoButtonColor = false
                ob.ZIndex          = 62
                ob.Parent          = Scroll

                ob.MouseEnter:Connect(function() Tween(ob, {BackgroundColor3 = Theme.ElementHov, TextColor3 = Theme.TextPri}) end)
                ob.MouseLeave:Connect(function()
                    if opt ~= selected then Tween(ob, {BackgroundColor3 = Theme.PopupBg, TextColor3 = Theme.TextSec}) end
                end)
                ob.MouseButton1Click:Connect(function()
                    selected = opt
                    selLbl.Text = tostring(opt)
                    CloseAllPopups()
                    pcall(callback, opt)
                end)
            end
        end)

        RegElem(f, text)
        return {
            SetValue = function(_, v) selected = v selLbl.Text = tostring(v) pcall(callback, v) end,
            GetValue = function() return selected end,
        }
    end

    -- ══════════════════════════════════════════════════════════
    -- 8. MULTI-SELECT (выбор нескольких опций)
    -- ══════════════════════════════════════════════════════════
    function Elem:CreateMultiSelect(text, list, callback)
        local selected = {}
        local f = BaseFrame()

        local lbl = Label(f, text, 11, Theme.TextPri)
        lbl.Size     = UDim2.new(0.55, -8, 1, 0)
        lbl.Position = UDim2.new(0, 8, 0, 0)

        local arrow = Label(f, "▾", 11, Theme.Accent, Enum.Font.GothamBold, Enum.TextXAlignment.Right)
        arrow.Size     = UDim2.new(0, 18, 1, 0)
        arrow.Position = UDim2.new(1, -22, 0, 0)

        local selLbl = Label(f, "0 selected", 10, Theme.TextSec, Enum.Font.Gotham, Enum.TextXAlignment.Right)
        selLbl.Size     = UDim2.new(0.4, 0, 1, 0)
        selLbl.Position = UDim2.new(0.55, 0, 0, 0)

        local function RefreshLabel()
            local cnt = 0
            for _ in pairs(selected) do cnt += 1 end
            selLbl.Text = cnt > 0 and (cnt .. " selected") or "none"
        end

        local btn = Instance.new("TextButton")
        btn.Size   = UDim2.new(1,0,1,0)
        btn.BackgroundTransparency = 1
        btn.Text   = ""
        btn.Parent = f

        btn.MouseButton1Click:Connect(function()
            local alreadyOpen = PopupLayer:FindFirstChild(text .. "_multi")
            CloseAllPopups()
            if alreadyOpen then return end

            local absPos  = f.AbsolutePosition
            local absSize = f.AbsoluteSize
            local itemH   = 24
            local menuH   = math.min(#list, 5) * itemH + 2

            local Menu = Instance.new("Frame")
            Menu.Name            = text .. "_multi"
            Menu.Size            = UDim2.new(0, absSize.X, 0, menuH)
            Menu.Position        = UDim2.new(0, absPos.X, 0, absPos.Y + absSize.Y + 2)
            Menu.BackgroundColor3 = Theme.PopupBg
            Menu.BorderSizePixel = 0
            Menu.ZIndex          = 60
            Menu.Parent          = PopupLayer
            Corner(Menu, 4)
            Stroke(Menu, Theme.Accent, 1)

            local Scroll = Instance.new("ScrollingFrame")
            Scroll.Size               = UDim2.new(1,0,1,0)
            Scroll.BackgroundTransparency = 1
            Scroll.CanvasSize         = UDim2.new(0,0,0,#list*itemH)
            Scroll.ScrollBarThickness = 2
            Scroll.ScrollBarImageColor3 = Theme.Accent
            Scroll.ZIndex             = 61
            Scroll.Parent             = Menu
            Instance.new("UIListLayout", Scroll)

            for _, opt in ipairs(list) do
                local ob = Instance.new("TextButton")
                ob.Size            = UDim2.new(1,0,0,itemH)
                ob.BackgroundColor3 = Theme.PopupBg
                ob.BorderSizePixel = 0
                ob.Font            = Enum.Font.Gotham
                ob.Text            = ""
                ob.AutoButtonColor = false
                ob.ZIndex          = 62
                ob.Parent          = Scroll

                -- чекбокс 10×10
                local chk = Instance.new("Frame")
                chk.Size            = UDim2.new(0, 10, 0, 10)
                chk.Position        = UDim2.new(0, 8, 0.5, -5)
                chk.BackgroundColor3 = selected[opt] and Theme.Accent or Theme.TrackBg
                chk.BorderSizePixel = 0
                chk.ZIndex          = 63
                chk.Parent          = ob
                Corner(chk, 2)
                Stroke(chk, Theme.Border, 1)

                local optLbl = Label(ob, tostring(opt), 11, selected[opt] and Theme.TextPri or Theme.TextSec)
                optLbl.Size     = UDim2.new(1,-26,1,0)
                optLbl.Position = UDim2.new(0, 24, 0, 0)
                optLbl.ZIndex   = 63

                ob.MouseEnter:Connect(function() Tween(ob, {BackgroundColor3 = Theme.ElementHov}) end)
                ob.MouseLeave:Connect(function() Tween(ob, {BackgroundColor3 = Theme.PopupBg}) end)
                ob.MouseButton1Click:Connect(function()
                    selected[opt] = not selected[opt]
                    Tween(chk, {BackgroundColor3 = selected[opt] and Theme.Accent or Theme.TrackBg})
                    Tween(optLbl, {TextColor3 = selected[opt] and Theme.TextPri or Theme.TextSec})
                    RefreshLabel()
                    local out = {}
                    for k, v in pairs(selected) do if v then table.insert(out, k) end end
                    pcall(callback, out)
                end)
            end
        end)

        RegElem(f, text)
        return {
            GetSelected = function()
                local out = {}
                for k,v in pairs(selected) do if v then table.insert(out,k) end end
                return out
            end,
        }
    end

    -- ══════════════════════════════════════════════════════════
    -- 9. COLOR PICKER (HSV + hex preview)
    -- ══════════════════════════════════════════════════════════
    function Elem:CreateColorPicker(text, default, callback)
        default = default or Color3.fromRGB(255,255,255)
        local hue, sat, val_ = Color3.toHSV(default)
        local f = BaseFrame()

        local lbl = Label(f, text, 11, Theme.TextPri)
        lbl.Size     = UDim2.new(1, -38, 1, 0)
        lbl.Position = UDim2.new(0, 8, 0, 0)

        local preview = Instance.new("Frame")
        preview.Size            = UDim2.new(0, 14, 0, 14)
        preview.Position        = UDim2.new(1, -22, 0.5, -7)
        preview.BackgroundColor3 = default
        preview.BorderSizePixel = 0
        preview.Parent          = f
        Corner(preview, 3)
        Stroke(preview, Theme.TextSec, 1)

        local btn = Instance.new("TextButton")
        btn.Size   = UDim2.new(1,0,1,0)
        btn.BackgroundTransparency = 1
        btn.Text   = ""
        btn.Parent = f

        local function GetColor() return Color3.fromHSV(hue, sat, val_) end

        btn.MouseButton1Click:Connect(function()
            local alreadyOpen = PopupLayer:FindFirstChild(text .. "_cp")
            CloseAllPopups()
            if alreadyOpen then return end

            local absPos  = f.AbsolutePosition
            local absSize = f.AbsoluteSize

            local Menu = Instance.new("Frame")
            Menu.Name            = text .. "_cp"
            Menu.Size            = UDim2.new(0, absSize.X, 0, 140)
            Menu.Position        = UDim2.new(0, absPos.X, 0, absPos.Y + absSize.Y + 2)
            Menu.BackgroundColor3 = Theme.PopupBg
            Menu.BorderSizePixel = 0
            Menu.ZIndex          = 60
            Menu.Parent          = PopupLayer
            Corner(Menu, 4)
            Stroke(Menu, Theme.Accent, 1)

            -- SV picker квадрат
            local SV = Instance.new("ImageLabel")
            SV.Size            = UDim2.new(0, 100, 0, 100)
            SV.Position        = UDim2.new(0, 8, 0, 8)
            SV.Image           = "rbxassetid://4155801252"   -- S/V gradient
            SV.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
            SV.BorderSizePixel = 0
            SV.ZIndex          = 61
            SV.Parent          = Menu
            Corner(SV, 3)

            local SVcursor = Instance.new("Frame")
            SVcursor.Size            = UDim2.new(0, 7, 0, 7)
            SVcursor.AnchorPoint     = Vector2.new(0.5, 0.5)
            SVcursor.Position        = UDim2.new(sat, 0, 1-val_, 0)
            SVcursor.BackgroundColor3 = Color3.fromRGB(255,255,255)
            SVcursor.BorderSizePixel = 0
            SVcursor.ZIndex          = 62
            SVcursor.Parent          = SV
            Corner(SVcursor, 4)
            Stroke(SVcursor, Color3.fromRGB(0,0,0), 1)

            -- Hue slider (вертикальный)
            local HueTrack = Instance.new("ImageLabel")
            HueTrack.Size            = UDim2.new(0, 12, 0, 100)
            HueTrack.Position        = UDim2.new(0, 116, 0, 8)
            HueTrack.Image           = "rbxassetid://4155805389"   -- hue gradient
            HueTrack.BorderSizePixel = 0
            HueTrack.ZIndex          = 61
            HueTrack.Parent          = Menu
            Corner(HueTrack, 3)

            local HueCursor = Instance.new("Frame")
            HueCursor.Size            = UDim2.new(1, 2, 0, 3)
            HueCursor.AnchorPoint     = Vector2.new(0.5, 0.5)
            HueCursor.Position        = UDim2.new(0.5, 0, hue, 0)
            HueCursor.BackgroundColor3 = Color3.fromRGB(255,255,255)
            HueCursor.BorderSizePixel = 0
            HueCursor.ZIndex          = 62
            HueCursor.Parent          = HueTrack
            Stroke(HueCursor, Color3.fromRGB(0,0,0), 1)

            -- Alpha slider (вертикальный)
            local AlphaTrack = Instance.new("Frame")
            AlphaTrack.Size            = UDim2.new(0, 12, 0, 100)
            AlphaTrack.Position        = UDim2.new(0, 136, 0, 8)
            AlphaTrack.BackgroundColor3 = Color3.fromRGB(255,255,255)
            AlphaTrack.BorderSizePixel = 0
            AlphaTrack.ZIndex          = 61
            AlphaTrack.Parent          = Menu
            Corner(AlphaTrack, 3)
            Stroke(AlphaTrack, Theme.Border, 1)

            -- hex preview снизу
            local HexBg = Instance.new("Frame")
            HexBg.Size            = UDim2.new(0, 100, 0, 18)
            HexBg.Position        = UDim2.new(0, 8, 0, 114)
            HexBg.BackgroundColor3 = Theme.TrackBg
            HexBg.BorderSizePixel = 0
            HexBg.ZIndex          = 61
            HexBg.Parent          = Menu
            Corner(HexBg, 3)

            local HexLabel = Label(HexBg, "#" .. string.format("%02X%02X%02X",
                math.floor(default.R*255), math.floor(default.G*255), math.floor(default.B*255)),
                9, Theme.TextSec, Enum.Font.RobotoMono, Enum.TextXAlignment.Center)
            HexLabel.Size   = UDim2.new(1,0,1,0)
            HexLabel.ZIndex = 62

            local colPreview = Instance.new("Frame")
            colPreview.Size            = UDim2.new(0, 18, 0, 18)
            colPreview.Position        = UDim2.new(0, 114, 0, 114)
            colPreview.BackgroundColor3 = GetColor()
            colPreview.BorderSizePixel = 0
            colPreview.ZIndex          = 61
            colPreview.Parent          = Menu
            Corner(colPreview, 3)

            local function UpdateAll()
                local c = GetColor()
                SV.BackgroundColor3   = Color3.fromHSV(hue, 1, 1)
                SVcursor.Position     = UDim2.new(sat, 0, 1-val_, 0)
                HueCursor.Position    = UDim2.new(0.5, 0, hue, 0)
                colPreview.BackgroundColor3 = c
                preview.BackgroundColor3    = c
                HexLabel.Text = "#" .. string.format("%02X%02X%02X",
                    math.floor(c.R*255), math.floor(c.G*255), math.floor(c.B*255))
                pcall(callback, c)
            end

            -- взаимодействие с SV
            local svDrag = false
            SV.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then
                    svDrag = true
                    local p = i.Position - SV.AbsolutePosition
                    sat  = math.clamp(p.X / SV.AbsoluteSize.X, 0, 1)
                    val_ = math.clamp(1 - p.Y / SV.AbsoluteSize.Y, 0, 1)
                    UpdateAll()
                end
            end)
            UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then svDrag = false end
            end)
            UserInputService.InputChanged:Connect(function(i)
                if svDrag and i.UserInputType == Enum.UserInputType.MouseMovement then
                    local p = i.Position - SV.AbsolutePosition
                    sat  = math.clamp(p.X / SV.AbsoluteSize.X, 0, 1)
                    val_ = math.clamp(1 - p.Y / SV.AbsoluteSize.Y, 0, 1)
                    UpdateAll()
                end
            end)

            -- взаимодействие с Hue
            local hueDrag = false
            HueTrack.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then
                    hueDrag = true
                    hue = math.clamp((i.Position.Y - HueTrack.AbsolutePosition.Y) / HueTrack.AbsoluteSize.Y, 0, 1)
                    UpdateAll()
                end
            end)
            UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then hueDrag = false end
            end)
            UserInputService.InputChanged:Connect(function(i)
                if hueDrag and i.UserInputType == Enum.UserInputType.MouseMovement then
                    hue = math.clamp((i.Position.Y - HueTrack.AbsolutePosition.Y) / HueTrack.AbsoluteSize.Y, 0, 1)
                    UpdateAll()
                end
            end)
        end)

        RegElem(f, text)
        return {
            GetColor = GetColor,
            SetColor = function(_, c)
                hue, sat, val_ = Color3.toHSV(c)
                preview.BackgroundColor3 = c
                pcall(callback, c)
            end,
        }
    end

    -- ══════════════════════════════════════════════════════════
    -- 10. KEYBIND
    -- ══════════════════════════════════════════════════════════
    function Elem:CreateKeybind(text, defaultKey, callback)
        local currentKey = defaultKey or Enum.KeyCode.Unknown
        local listening  = false
        local f = BaseFrame()

        local lbl = Label(f, text, 11, Theme.TextPri)
        lbl.Size     = UDim2.new(1, -80, 1, 0)
        lbl.Position = UDim2.new(0, 8, 0, 0)

        local keyBtn = Instance.new("TextButton")
        keyBtn.Size            = UDim2.new(0, 66, 0, 18)
        keyBtn.Position        = UDim2.new(1, -72, 0.5, -9)
        keyBtn.BackgroundColor3 = Theme.TrackBg
        keyBtn.Font            = Enum.Font.GothamBold
        keyBtn.Text            = currentKey.Name
        keyBtn.TextColor3      = Theme.Accent
        keyBtn.TextSize        = 10
        keyBtn.AutoButtonColor = false
        keyBtn.Parent          = f
        Corner(keyBtn, 3)
        Stroke(keyBtn, Theme.Border, 1)

        keyBtn.MouseButton1Click:Connect(function()
            CloseAllPopups()
            if listening then return end
            listening = true
            keyBtn.Text      = "..."
            keyBtn.TextColor3 = Theme.TextSec
            Tween(keyBtn, {BackgroundColor3 = Theme.ElementHov})

            local conn
            conn = UserInputService.InputBegan:Connect(function(i, gp)
                if gp then return end
                if i.UserInputType == Enum.UserInputType.Keyboard then
                    currentKey        = i.KeyCode
                    keyBtn.Text       = i.KeyCode.Name
                    keyBtn.TextColor3 = Theme.Accent
                    Tween(keyBtn, {BackgroundColor3 = Theme.TrackBg})
                    listening = false
                    conn:Disconnect()
                    pcall(callback, currentKey)
                end
            end)
        end)

        -- глобальное срабатывание при нажатии биндовой клавиши
        UserInputService.InputBegan:Connect(function(i, gp)
            if gp or listening then return end
            if i.KeyCode == currentKey then pcall(callback, currentKey) end
        end)

        RegElem(f, text)
        return {
            GetKey = function() return currentKey end,
            SetKey = function(_, k)
                currentKey    = k
                keyBtn.Text   = k.Name
                pcall(callback, k)
            end,
        }
    end

    -- ══════════════════════════════════════════════════════════
    -- 11. NOTIFICATION (тост сверху)
    -- ══════════════════════════════════════════════════════════
    function Library:Notify(title, body, duration)
        duration = duration or 3
        local notif = Instance.new("Frame")
        notif.Size            = UDim2.new(0, 220, 0, 46)
        notif.Position        = UDim2.new(1, -228, 0, BAR_H + 4)
        notif.BackgroundColor3 = Theme.MainBg
        notif.BorderSizePixel = 0
        notif.ZIndex          = 80
        notif.Parent          = ScreenGui
        Corner(notif, 5)
        Stroke(notif, Theme.Accent, 1)

        -- акцент полоска слева
        local LeftLine = Instance.new("Frame")
        LeftLine.Size            = UDim2.new(0, 2, 1, -8)
        LeftLine.Position        = UDim2.new(0, 4, 0, 4)
        LeftLine.BackgroundColor3 = Theme.Accent
        LeftLine.BorderSizePixel = 0
        LeftLine.ZIndex          = 81
        LeftLine.Parent          = notif
        Corner(LeftLine, 2)

        local t1 = Label(notif, title, 11, Theme.TextPri, Enum.Font.GothamBold)
        t1.Size     = UDim2.new(1,-14,0,14)
        t1.Position = UDim2.new(0,12,0,6)
        t1.ZIndex   = 81

        local t2 = Label(notif, body, 10, Theme.TextSec)
        t2.Size     = UDim2.new(1,-14,0,22)
        t2.Position = UDim2.new(0,12,0,22)
        t2.TextWrapped = true
        t2.ZIndex   = 81

        -- slide in
        notif.Position = UDim2.new(1, 10, 0, BAR_H + 4)
        Tween(notif, {Position = UDim2.new(1, -228, 0, BAR_H + 4)}, 0.25, Enum.EasingStyle.Back)

        task.delay(duration, function()
            Tween(notif, {Position = UDim2.new(1, 10, 0, BAR_H + 4)}, 0.2)
            task.delay(0.22, function() notif:Destroy() end)
        end)
    end

    return Elem
end

-- ── INIT ─────────────────────────────────────────────────────
task.spawn(function()
    repeat task.wait() until FirstActivate
    FirstActivate()
end)

return Library

--[[
════════════════════════════════════════════════
  ПРИМЕР ИСПОЛЬЗОВАНИЯ:
════════════════════════════════════════════════

local Lib = loadstring(game:HttpGet("..."))()

local Combat = Lib:CreateTab("Combat", "⚔")
Combat:CreateButton("Kill Aura", function() print("on") end)
Combat:CreateToggle("Auto Block", false, function(v) print(v) end)
Combat:CreateSlider("Reach", 3, 20, 6, 0.5, function(v) print(v) end)
Combat:CreateDropdown("Target", {"Nearest","Random","Highest HP"}, function(v) print(v) end)
Combat:CreateMultiSelect("Weapons", {"Sword","Bow","Axe"}, function(t) print(t) end)
Combat:CreateKeybind("Toggle Aura", Enum.KeyCode.V, function() print("toggled") end)

local Visual = Lib:CreateTab("Visual", "👁")
Visual:CreateSeparator("ESP")
Visual:CreateToggle("Player ESP", true, function(v) end)
Visual:CreateColorPicker("ESP Color", Color3.fromRGB(218,43,172), function(c) end)
Visual:CreateTextBox("Watermark", "Enter text..", function(t) end)

Lib:Notify("Meteor Loaded", "Enjoy your session!", 4)

]]
