-- ╔══════════════════════════════════════════════════════════╗
-- ║         METEOR UI LIBRARY — METEOR CLIENT STYLE v3.0     ║
-- ║   Минималистичный дизайн · Прозрачные элементы          ║
-- ║   Вкладки сверху · Loading Screen · Fixed RightShift    ║
-- ╚══════════════════════════════════════════════════════════╝

local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local LocalPlayer      = Players.LocalPlayer

-- ── ТЕМА METEOR CLIENT ──────────────────────────────────────
local Theme = {
    -- фоны (прозрачные/тёмные)
    MainBg      = Color3.fromRGB(8, 8, 11),        -- почти чёрный
    ElementBg   = Color3.fromRGB(0, 0, 0),         -- полностью прозрачный (будет через Transparency)
    ElementHov  = Color3.fromRGB(18, 18, 24),      -- еле заметный hover
    PopupBg     = Color3.fromRGB(11, 11, 15),
    -- акцент
    Accent      = Color3.fromRGB(220, 45, 175),    -- яркий розовый
    AccentDim   = Color3.fromRGB(145, 30, 115),
    AccentHov   = Color3.fromRGB(245, 65, 200),
    -- текст
    TextPri     = Color3.fromRGB(255, 255, 255),
    TextSec     = Color3.fromRGB(130, 130, 142),
    TextDis     = Color3.fromRGB(70,  70,  82),
    -- UI
    Border      = Color3.fromRGB(35, 35, 48),      -- тонкие линии
    TrackBg     = Color3.fromRGB(40, 40, 54),
    ToggleOff   = Color3.fromRGB(45, 45, 58),
    Divider     = Color3.fromRGB(30, 30, 42),      -- разделители
}

-- ── УТИЛИТЫ ─────────────────────────────────────────────────
local function Tween(obj, props, t, style, dir)
    local tween = TweenService:Create(obj,
        TweenInfo.new(t or 0.16, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out),
        props)
    tween:Play()
    return tween
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

-- ══════════════════════════════════════════════════════════
-- LOADING SCREEN
-- ══════════════════════════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name           = "MeteorLib"
ScreenGui.ResetOnSpawn   = false
ScreenGui.DisplayOrder   = 999
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent         = LocalPlayer:WaitForChild("PlayerGui")

local LoadingScreen = Instance.new("Frame")
LoadingScreen.Size            = UDim2.new(1, 0, 1, 0)
LoadingScreen.BackgroundColor3 = Color3.fromRGB(5, 5, 8)
LoadingScreen.BorderSizePixel = 0
LoadingScreen.ZIndex          = 100
LoadingScreen.Parent          = ScreenGui

local LoadingLogo = Instance.new("TextLabel")
LoadingLogo.Size            = UDim2.new(0, 300, 0, 60)
LoadingLogo.Position        = UDim2.new(0.5, -150, 0.5, -80)
LoadingLogo.BackgroundTransparency = 1
LoadingLogo.Text            = "✦ METEOR"
LoadingLogo.TextColor3      = Theme.Accent
LoadingLogo.Font            = Enum.Font.GothamBold
LoadingLogo.TextSize        = 42
LoadingLogo.TextTransparency = 1
LoadingLogo.ZIndex          = 101
LoadingLogo.Parent          = LoadingScreen

local LoadingSubtitle = Instance.new("TextLabel")
LoadingSubtitle.Size            = UDim2.new(0, 300, 0, 20)
LoadingSubtitle.Position        = UDim2.new(0.5, -150, 0.5, -10)
LoadingSubtitle.BackgroundTransparency = 1
LoadingSubtitle.Text            = "client"
LoadingSubtitle.TextColor3      = Theme.TextSec
LoadingSubtitle.Font            = Enum.Font.Gotham
LoadingSubtitle.TextSize        = 14
LoadingSubtitle.TextTransparency = 1
LoadingSubtitle.ZIndex          = 101
LoadingSubtitle.Parent          = LoadingScreen

-- Progress Bar
local ProgressBg = Instance.new("Frame")
ProgressBg.Size            = UDim2.new(0, 300, 0, 3)
ProgressBg.Position        = UDim2.new(0.5, -150, 0.5, 30)
ProgressBg.BackgroundColor3 = Theme.Border
ProgressBg.BorderSizePixel = 0
ProgressBg.BackgroundTransparency = 1
ProgressBg.ZIndex          = 101
ProgressBg.Parent          = LoadingScreen
Corner(ProgressBg, 2)

local ProgressFill = Instance.new("Frame")
ProgressFill.Size            = UDim2.new(0, 0, 1, 0)
ProgressFill.BackgroundColor3 = Theme.Accent
ProgressFill.BorderSizePixel = 0
ProgressFill.ZIndex          = 102
ProgressFill.Parent          = ProgressBg
Corner(ProgressFill, 2)

local LoadingText = Instance.new("TextLabel")
LoadingText.Size            = UDim2.new(0, 300, 0, 20)
LoadingText.Position        = UDim2.new(0.5, -150, 0.5, 45)
LoadingText.BackgroundTransparency = 1
LoadingText.Text            = "Initializing..."
LoadingText.TextColor3      = Theme.TextSec
LoadingText.Font            = Enum.Font.Gotham
LoadingText.TextSize        = 11
LoadingText.TextTransparency = 1
LoadingText.ZIndex          = 101
LoadingText.Parent          = LoadingScreen

-- Анимация загрузки
task.spawn(function()
    task.wait(0.1)
    Tween(LoadingLogo, {TextTransparency = 0}, 0.6)
    task.wait(0.2)
    Tween(LoadingSubtitle, {TextTransparency = 0}, 0.5)
    task.wait(0.3)
    Tween(ProgressBg, {BackgroundTransparency = 0}, 0.4)
    Tween(LoadingText, {TextTransparency = 0}, 0.4)
    
    -- Этапы загрузки
    local stages = {
        {text = "Loading UI...", progress = 0.25, time = 0.3},
        {text = "Loading components...", progress = 0.5, time = 0.3},
        {text = "Initializing modules...", progress = 0.75, time = 0.3},
        {text = "Ready!", progress = 1, time = 0.4}
    }
    
    for _, stage in ipairs(stages) do
        LoadingText.Text = stage.text
        Tween(ProgressFill, {Size = UDim2.new(stage.progress, 0, 1, 0)}, stage.time, Enum.EasingStyle.Quart)
        task.wait(stage.time)
    end
    
    task.wait(0.3)
    -- Fade out
    Tween(LoadingScreen, {BackgroundTransparency = 1}, 0.5)
    Tween(LoadingLogo, {TextTransparency = 1}, 0.5)
    Tween(LoadingSubtitle, {TextTransparency = 1}, 0.5)
    Tween(ProgressBg, {BackgroundTransparency = 1}, 0.5)
    Tween(LoadingText, {TextTransparency = 1}, 0.5)
    task.wait(0.6)
    LoadingScreen:Destroy()
end)

-- ── ПОПАПЫ ──────────────────────────────────────────────────
local PopupLayer = Instance.new("Frame")
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

-- ── TOP BAR (КАК В METEOR CLIENT) ──────────────────────────
-- Вкладки горизонтально сверху, Search Bar справа
local BAR_W  = 600
local BAR_H  = 32
local PAGE_H = 340

local TopBar = Instance.new("Frame")
TopBar.Name            = "TopBar"
TopBar.Size            = UDim2.new(0, BAR_W, 0, BAR_H)
TopBar.Position        = UDim2.new(0.5, -BAR_W/2, 0.5, -(BAR_H + PAGE_H)/2)
TopBar.BackgroundColor3 = Theme.MainBg
TopBar.BorderSizePixel = 0
TopBar.ZIndex          = 10
TopBar.Visible         = false  -- покажется после загрузки
TopBar.Parent          = ScreenGui
Corner(TopBar, 6)
Stroke(TopBar, Theme.Border, 1)

-- Показать после загрузки
task.spawn(function()
    task.wait(2.2)
    TopBar.Visible = true
    TopBar.BackgroundTransparency = 1
    Tween(TopBar, {BackgroundTransparency = 0}, 0.4)
end)

-- Нижняя акцентная линия
local BarLine = Instance.new("Frame")
BarLine.Size            = UDim2.new(1, -8, 0, 1)
BarLine.Position        = UDim2.new(0, 4, 1, -1)
BarLine.BackgroundColor3 = Theme.Accent
BarLine.BorderSizePixel = 0
BarLine.ZIndex          = 11
BarLine.Parent          = TopBar

-- Логотип слева
local LogoLabel = Instance.new("TextLabel")
LogoLabel.Size            = UDim2.new(0, 80, 1, 0)
LogoLabel.Position        = UDim2.new(0, 10, 0, 0)
LogoLabel.BackgroundTransparency = 1
LogoLabel.Text            = "✦ meteor"
LogoLabel.TextColor3      = Theme.Accent
LogoLabel.Font            = Enum.Font.GothamBold
LogoLabel.TextSize        = 13
LogoLabel.TextXAlignment  = Enum.TextXAlignment.Left
LogoLabel.ZIndex          = 12
LogoLabel.Parent          = TopBar

-- Контейнер вкладок (горизонтально после логотипа)
local TabContainer = Instance.new("Frame")
TabContainer.Size               = UDim2.new(0, 360, 1, 0)
TabContainer.Position           = UDim2.new(0, 96, 0, 0)
TabContainer.BackgroundTransparency = 1
TabContainer.ZIndex             = 12
TabContainer.Parent             = TopBar

local TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection  = Enum.FillDirection.Horizontal
TabLayout.SortOrder      = Enum.SortOrder.LayoutOrder
TabLayout.Padding        = UDim.new(0, 4)
TabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
TabLayout.Parent         = TabContainer

-- Search Bar справа
local SearchBox = Instance.new("Frame")
SearchBox.Size            = UDim2.new(0, 130, 0, 20)
SearchBox.Position        = UDim2.new(1, -138, 0.5, -10)
SearchBox.BackgroundColor3 = Theme.TrackBg
SearchBox.BorderSizePixel = 0
SearchBox.ZIndex          = 12
SearchBox.Parent          = TopBar
Corner(SearchBox, 4)
Stroke(SearchBox, Theme.Border, 1)

local SearchIcon = Instance.new("TextLabel")
SearchIcon.Size            = UDim2.new(0, 14, 0, 14)
SearchIcon.Position        = UDim2.new(0, 4, 0.5, -7)
SearchIcon.BackgroundTransparency = 1
SearchIcon.Text            = "🔍"
SearchIcon.TextColor3      = Theme.TextSec
SearchIcon.TextSize        = 10
SearchIcon.ZIndex          = 13
SearchIcon.Parent          = SearchBox

local SearchInput = Instance.new("TextBox")
SearchInput.Size            = UDim2.new(1, -24, 1, 0)
SearchInput.Position        = UDim2.new(0, 20, 0, 0)
SearchInput.BackgroundTransparency = 1
SearchInput.Font            = Enum.Font.Gotham
SearchInput.Text            = ""
SearchInput.PlaceholderText = "Search..."
SearchInput.PlaceholderColor3 = Theme.TextSec
SearchInput.TextColor3      = Theme.TextPri
SearchInput.TextSize        = 10
SearchInput.TextXAlignment  = Enum.TextXAlignment.Left
SearchInput.ZIndex          = 13
SearchInput.ClearTextOnFocus = false
SearchInput.Parent          = SearchBox

-- ── PAGE CONTAINER (под TopBar) ─────────────────────────────
local PageContainer = Instance.new("Frame")
PageContainer.Name            = "Pages"
PageContainer.Size            = UDim2.new(0, BAR_W, 0, PAGE_H)
PageContainer.Position        = UDim2.new(0.5, -BAR_W/2, 0.5, -(BAR_H + PAGE_H)/2 + BAR_H)
PageContainer.BackgroundColor3 = Theme.MainBg
PageContainer.BorderSizePixel = 0
PageContainer.ClipsDescendants = true
PageContainer.ZIndex          = 9
PageContainer.Visible         = false
PageContainer.Parent          = ScreenGui
Corner(PageContainer, 6)
Stroke(PageContainer, Theme.Border, 1)

task.spawn(function()
    task.wait(2.2)
    PageContainer.Visible = true
    PageContainer.BackgroundTransparency = 1
    Tween(PageContainer, {BackgroundTransparency = 0}, 0.4)
end)

-- ── DRAG (перетаскивание за TopBar) ────────────────────────
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
local AllElements = {}
local ActivePage  = nil
local FirstActivate = nil

-- ══ FIXED RIGHTSHIFT TOGGLE ══
local guiVisible = true
local rightShiftPressed = false

UserInputService.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.KeyCode == Enum.KeyCode.RightShift then
        if not rightShiftPressed then
            rightShiftPressed = true
            guiVisible = not guiVisible
            TopBar.Visible         = guiVisible
            PageContainer.Visible  = guiVisible
            if not guiVisible then CloseAllPopups() end
        end
    end
end)

UserInputService.InputEnded:Connect(function(i, gp)
    if i.KeyCode == Enum.KeyCode.RightShift then
        rightShiftPressed = false
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
-- CreateTab (горизонтальные вкладки сверху как в Meteor Client)
-- ════════════════════════════════════════════════════════════
function Library:CreateTab(name, icon)

    -- страница (ScrollingFrame)
    local Page = Instance.new("ScrollingFrame")
    Page.Name                 = name .. "_Page"
    Page.Size                 = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible              = false
    Page.ScrollBarThickness   = 3
    Page.ScrollBarImageColor3 = Theme.Accent
    Page.CanvasSize           = UDim2.new(0,0,0,0)
    Page.AutomaticCanvasSize  = Enum.AutomaticSize.Y
    Page.ZIndex               = 10
    Page.Parent               = PageContainer

    -- сетка элементов (3 колонки как в оригинале)
    local Grid = Instance.new("UIGridLayout")
    Grid.CellSize    = UDim2.new(0, 190, 0, 32)
    Grid.CellPadding = UDim2.new(0, 6, 0, 5)
    Grid.SortOrder   = Enum.SortOrder.LayoutOrder
    Grid.Parent      = Page

    local GridPad = Instance.new("UIPadding")
    GridPad.PaddingTop    = UDim.new(0, 8)
    GridPad.PaddingLeft   = UDim.new(0, 8)
    GridPad.PaddingRight  = UDim.new(0, 8)
    GridPad.PaddingBottom = UDim.new(0, 8)
    GridPad.Parent        = Page

    -- ═══ КНОПКА ВКЛАДКИ (горизонтально сверху) ═══
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size            = UDim2.new(0, 72, 1, -4)
    TabBtn.BackgroundTransparency = 1
    TabBtn.Font            = Enum.Font.GothamSemibold
    TabBtn.Text            = (icon and (icon .. " ") or "") .. name
    TabBtn.TextColor3      = Theme.TextSec
    TabBtn.TextSize        = 11
    TabBtn.AutoButtonColor = false
    TabBtn.ZIndex          = 13
    TabBtn.Parent          = TabContainer

    -- Розовый индикатор снизу (при активности)
    local TabLine = Instance.new("Frame")
    TabLine.Size            = UDim2.new(0.8, 0, 0, 2)
    TabLine.Position        = UDim2.new(0.1, 0, 1, -2)
    TabLine.BackgroundColor3 = Theme.Accent
    TabLine.BackgroundTransparency = 1
    TabLine.BorderSizePixel = 0
    TabLine.ZIndex          = 14
    TabLine.Parent          = TabBtn
    Corner(TabLine, 1)

    local function Activate()
        CloseAllPopups()
        -- скрыть всё
        for _, p in pairs(Pages) do p.Visible = false end
        for _, b in ipairs(TabContainer:GetChildren()) do
            if b:IsA("TextButton") then
                Tween(b, {TextColor3 = Theme.TextSec})
                local ind = b:FindFirstChildOfClass("Frame")
                if ind then ind.BackgroundTransparency = 1 end
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
        if not Page.Visible then 
            Tween(TabBtn, {TextColor3 = Theme.TextPri})
        end
    end)
    TabBtn.MouseLeave:Connect(function()
        if not Page.Visible then 
            Tween(TabBtn, {TextColor3 = Theme.TextSec})
        end
    end)

    Pages[name] = Page
    if not FirstActivate then FirstActivate = Activate end

    -- ── ВСПОМОГАТЕЛЬНЫЕ ──────────────────────────────────────
    local function BaseFrame(spanCols, noBackground)
        local f = Instance.new("Frame")
        -- БЕЗ ФОНА (как в Meteor Client) если не указано иначе
        if noBackground then
            f.BackgroundTransparency = 1
        else
            f.BackgroundTransparency = 0.95  -- почти прозрачный
            f.BackgroundColor3 = Theme.ElementBg
        end
        f.BorderSizePixel  = 0
        f.LayoutOrder      = #Page:GetChildren()
        if spanCols == 2 then
            f.Size = UDim2.new(1, -20, 0, 32)
        end
        f.Parent = Page
        Corner(f, 5)
        if not noBackground then
            Stroke(f, Theme.Border, 1)
        end
        return f
    end

    local function RegElem(frame, name_)
        table.insert(AllElements, {Frame = frame, Name = name_:lower(), Activate = Activate})
    end

    local Elem = {}

    -- ══════════════════════════════════════════════════════════
    -- 1. LABEL (без фона)
    -- ══════════════════════════════════════════════════════════
    function Elem:CreateLabel(text)
        local f = BaseFrame(nil, true)
        local l = Label(f, text, 11, Theme.TextSec, Enum.Font.GothamSemibold)
        l.Size     = UDim2.new(1, -8, 1, 0)
        l.Position = UDim2.new(0, 8, 0, 0)
        RegElem(f, text)
    end

    -- ══════════════════════════════════════════════════════════
    -- 2. SEPARATOR (минималистичная линия)
    -- ══════════════════════════════════════════════════════════
    function Elem:CreateSeparator(text)
        local f = BaseFrame(nil, true)

        local line = Instance.new("Frame")
        line.Size            = UDim2.new(1, -8, 0, 1)
        line.Position        = UDim2.new(0, 4, 0.5, 0)
        line.BackgroundColor3 = Theme.Divider
        line.BorderSizePixel = 0
        line.Parent          = f

        if text and text ~= "" then
            local bg = Instance.new("Frame")
            bg.Size            = UDim2.new(0, #text * 6 + 10, 0, 14)
            bg.Position        = UDim2.new(0.5, -((#text * 6 + 10)/2), 0.5, -7)
            bg.BackgroundColor3 = Theme.MainBg
            bg.BorderSizePixel = 0
            bg.Parent          = f
            local t = Label(bg, text, 9, Theme.TextSec, Enum.Font.GothamSemibold, Enum.TextXAlignment.Center)
            t.Size = UDim2.new(1,0,1,0)
        end
        RegElem(f, text or "sep")
    end

    -- ══════════════════════════════════════════════════════════
    -- 3. BUTTON (БЕЗ фона, только текст + hover)
    -- ══════════════════════════════════════════════════════════
    function Elem:CreateButton(text, callback)
        local f = BaseFrame(nil, true)
        Stroke(f, Theme.Border, 1)
        
        local lbl = Label(f, text, 11, Theme.TextPri, Enum.Font.GothamSemibold)
        lbl.Size     = UDim2.new(1, -8, 1, 0)
        lbl.Position = UDim2.new(0, 8, 0, 0)
        lbl.TextXAlignment = Enum.TextXAlignment.Center

        local btn = Instance.new("TextButton")
        btn.Size   = UDim2.new(1,0,1,0)
        btn.BackgroundTransparency = 1
        btn.Text   = ""
        btn.Parent = f

        btn.MouseEnter:Connect(function() 
            Tween(f, {BackgroundTransparency = 0.9})
            f.BackgroundColor3 = Theme.ElementHov
        end)
        btn.MouseLeave:Connect(function() 
            Tween(f, {BackgroundTransparency = 1})
        end)

        btn.MouseButton1Click:Connect(function()
            CloseAllPopups()
            f.BackgroundTransparency = 0
            f.BackgroundColor3 = Theme.Accent
            Tween(lbl, {TextColor3 = Color3.fromRGB(255,255,255)}, 0.05)
            task.delay(0.15, function() 
                Tween(f, {BackgroundTransparency = 1})
                Tween(lbl, {TextColor3 = Theme.TextPri})
            end)
            pcall(callback)
        end)
        RegElem(f, text)
    end

    -- ══════════════════════════════════════════════════════════
    -- 4. TOGGLE (БЕЗ фона, только switcher)
    -- ══════════════════════════════════════════════════════════
    function Elem:CreateToggle(text, default, callback)
        local state = default or false
        local f     = BaseFrame(nil, true)
        Stroke(f, Theme.Border, 1)

        local lbl = Label(f, text, 11, Theme.TextPri)
        lbl.Size     = UDim2.new(1, -42, 1, 0)
        lbl.Position = UDim2.new(0, 8, 0, 0)

        -- pill-переключатель 28×15
        local Track = Instance.new("Frame")
        Track.Size            = UDim2.new(0, 28, 0, 15)
        Track.Position        = UDim2.new(1, -36, 0.5, -7.5)
        Track.BackgroundColor3 = state and Theme.Accent or Theme.ToggleOff
        Track.BorderSizePixel = 0
        Track.Parent          = f
        Corner(Track, 8)

        local Thumb = Instance.new("Frame")
        Thumb.Size            = UDim2.new(0, 11, 0, 11)
        Thumb.Position        = UDim2.new(0, state and 15 or 2, 0.5, -5.5)
        Thumb.BackgroundColor3 = Color3.fromRGB(255,255,255)
        Thumb.BorderSizePixel = 0
        Thumb.Parent          = Track
        Corner(Thumb, 6)

        local btn = Instance.new("TextButton")
        btn.Size   = UDim2.new(1,0,1,0)
        btn.BackgroundTransparency = 1
        btn.Text   = ""
        btn.Parent = f

        btn.MouseEnter:Connect(function() 
            f.BackgroundTransparency = 0.92
            f.BackgroundColor3 = Theme.ElementHov
        end)
        btn.MouseLeave:Connect(function() 
            f.BackgroundTransparency = 1
        end)

        btn.MouseButton1Click:Connect(function()
            CloseAllPopups()
            state = not state
            Tween(Track, {BackgroundColor3 = state and Theme.Accent or Theme.ToggleOff}, 0.18)
            Tween(Thumb, {Position = UDim2.new(0, state and 15 or 2, 0.5, -5.5)}, 0.18)
            pcall(callback, state)
        end)
        RegElem(f, text)

        return {
            SetState = function(_, v)
                state = v
                Tween(Track, {BackgroundColor3 = state and Theme.Accent or Theme.ToggleOff})
                Tween(Thumb, {Position = UDim2.new(0, state and 15 or 2, 0.5, -5.5)})
                pcall(callback, state)
            end,
            GetState = function() return state end,
        }
    end

    -- ══════════════════════════════════════════════════════════
    -- 5. SLIDER (БЕЗ фона)
    -- ══════════════════════════════════════════════════════════
    function Elem:CreateSlider(text, min, max, default, step, callback)
        step = step or 1
        local val = default or min
        local f   = BaseFrame(nil, true)
        Stroke(f, Theme.Border, 1)

        local lbl = Label(f, text, 10, Theme.TextPri)
        lbl.Size     = UDim2.new(1, -48, 0, 14)
        lbl.Position = UDim2.new(0, 8, 0, 2)

        local valLbl = Label(f, tostring(val), 10, Theme.Accent, Enum.Font.GothamBold, Enum.TextXAlignment.Right)
        valLbl.Size     = UDim2.new(0, 38, 0, 14)
        valLbl.Position = UDim2.new(1, -42, 0, 2)

        -- трек
        local Track = Instance.new("TextButton")
        Track.Size            = UDim2.new(1, -16, 0, 3)
        Track.Position        = UDim2.new(0, 8, 1, -8)
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

        local Knob = Instance.new("Frame")
        Knob.Size            = UDim2.new(0, 10, 0, 10)
        Knob.AnchorPoint     = Vector2.new(0.5, 0.5)
        Knob.Position        = UDim2.new((val-min)/(max-min), 0, 0.5, 0)
        Knob.BackgroundColor3 = Theme.TextPri
        Knob.BorderSizePixel = 0
        Knob.Parent          = Track
        Corner(Knob, 5)

        f.MouseEnter:Connect(function() 
            f.BackgroundTransparency = 0.92
            f.BackgroundColor3 = Theme.ElementHov
        end)
        f.MouseLeave:Connect(function() 
            f.BackgroundTransparency = 1
        end)

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
    -- 6. TEXTBOX (БЕЗ внешнего фона)
    -- ══════════════════════════════════════════════════════════
    function Elem:CreateTextBox(label, placeholder, callback)
        local f = BaseFrame(nil, true)

        local lbl = Label(f, label, 10, Theme.TextSec)
        lbl.Size     = UDim2.new(0, 70, 1, 0)
        lbl.Position = UDim2.new(0, 8, 0, 0)

        local inner = Instance.new("Frame")
        inner.Size            = UDim2.new(1, -88, 0, 20)
        inner.Position        = UDim2.new(0, 80, 0.5, -10)
        inner.BackgroundColor3 = Theme.TrackBg
        inner.BorderSizePixel = 0
        inner.Parent          = f
        Corner(inner, 4)
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

        box.Focused:Connect(function() 
            Tween(inner, {BackgroundColor3 = Theme.ElementHov})
            f.BackgroundTransparency = 0.92
            f.BackgroundColor3 = Theme.ElementHov
        end)
        box.FocusLost:Connect(function(enter)
            Tween(inner, {BackgroundColor3 = Theme.TrackBg})
            f.BackgroundTransparency = 1
            pcall(callback, box.Text, enter)
        end)

        RegElem(f, label)
        return {
            GetText = function() return box.Text end,
            SetText = function(_, t) box.Text = t end,
        }
    end

    -- ══════════════════════════════════════════════════════════
    -- 7. DROPDOWN (БЕЗ фона, с улучшенной анимацией)
    -- ══════════════════════════════════════════════════════════
    function Elem:CreateDropdown(text, list, callback)
        local selected = nil
        local f = BaseFrame(nil, true)
        Stroke(f, Theme.Border, 1)

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

        btn.MouseEnter:Connect(function() 
            f.BackgroundTransparency = 0.92
            f.BackgroundColor3 = Theme.ElementHov
        end)
        btn.MouseLeave:Connect(function() 
            f.BackgroundTransparency = 1
        end)

        btn.MouseButton1Click:Connect(function()
            local alreadyOpen = PopupLayer:FindFirstChild(text .. "_drop")
            CloseAllPopups()
            if alreadyOpen then return end

            local absPos = f.AbsolutePosition
            local absSize = f.AbsoluteSize
            local itemH   = 26
            local maxVis  = 6
            local menuH   = math.min(#list, maxVis) * itemH + 4

            local Menu = Instance.new("Frame")
            Menu.Name            = text .. "_drop"
            Menu.Size            = UDim2.new(0, absSize.X, 0, menuH)
            Menu.Position        = UDim2.new(0, absPos.X, 0, absPos.Y + absSize.Y + 4)
            Menu.BackgroundColor3 = Theme.PopupBg
            Menu.BorderSizePixel = 0
            Menu.ZIndex          = 60
            Menu.BackgroundTransparency = 1
            Menu.Parent          = PopupLayer
            Corner(Menu, 5)
            Stroke(Menu, Theme.Accent, 1)
            
            Tween(Menu, {BackgroundTransparency = 0}, 0.15)

            local Scroll = Instance.new("ScrollingFrame")
            Scroll.Size               = UDim2.new(1,0,1,0)
            Scroll.BackgroundTransparency = 1
            Scroll.CanvasSize         = UDim2.new(0,0,0,#list*itemH)
            Scroll.ScrollBarThickness = 3
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

                ob.MouseEnter:Connect(function() 
                    Tween(ob, {BackgroundColor3 = Theme.ElementHov, TextColor3 = Theme.TextPri}, 0.12) 
                end)
                ob.MouseLeave:Connect(function()
                    if opt ~= selected then 
                        Tween(ob, {BackgroundColor3 = Theme.PopupBg, TextColor3 = Theme.TextSec}, 0.12) 
                    end
                end)
                ob.MouseButton1Click:Connect(function()
                    selected = opt
                    selLbl.Text = tostring(opt)
                    Tween(Menu, {BackgroundTransparency = 1}, 0.1)
                    task.delay(0.12, function() CloseAllPopups() end)
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
    -- 8. MULTI-SELECT (БЕЗ фона)
    -- ══════════════════════════════════════════════════════════
    function Elem:CreateMultiSelect(text, list, callback)
        local selected = {}
        local f = BaseFrame(nil, true)
        Stroke(f, Theme.Border, 1)

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

        btn.MouseEnter:Connect(function() 
            f.BackgroundTransparency = 0.92
            f.BackgroundColor3 = Theme.ElementHov
        end)
        btn.MouseLeave:Connect(function() 
            f.BackgroundTransparency = 1
        end)

        btn.MouseButton1Click:Connect(function()
            local alreadyOpen = PopupLayer:FindFirstChild(text .. "_multi")
            CloseAllPopups()
            if alreadyOpen then return end

            local absPos  = f.AbsolutePosition
            local absSize = f.AbsoluteSize
            local itemH   = 26
            local menuH   = math.min(#list, 6) * itemH + 4

            local Menu = Instance.new("Frame")
            Menu.Name            = text .. "_multi"
            Menu.Size            = UDim2.new(0, absSize.X, 0, menuH)
            Menu.Position        = UDim2.new(0, absPos.X, 0, absPos.Y + absSize.Y + 4)
            Menu.BackgroundColor3 = Theme.PopupBg
            Menu.BorderSizePixel = 0
            Menu.ZIndex          = 60
            Menu.BackgroundTransparency = 1
            Menu.Parent          = PopupLayer
            Corner(Menu, 5)
            Stroke(Menu, Theme.Accent, 1)
            
            Tween(Menu, {BackgroundTransparency = 0}, 0.15)

            local Scroll = Instance.new("ScrollingFrame")
            Scroll.Size               = UDim2.new(1,0,1,0)
            Scroll.BackgroundTransparency = 1
            Scroll.CanvasSize         = UDim2.new(0,0,0,#list*itemH)
            Scroll.ScrollBarThickness = 3
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

                local chk = Instance.new("Frame")
                chk.Size            = UDim2.new(0, 11, 0, 11)
                chk.Position        = UDim2.new(0, 8, 0.5, -5.5)
                chk.BackgroundColor3 = selected[opt] and Theme.Accent or Theme.TrackBg
                chk.BorderSizePixel = 0
                chk.ZIndex          = 63
                chk.Parent          = ob
                Corner(chk, 2)
                Stroke(chk, Theme.Border, 1)

                local optLbl = Label(ob, tostring(opt), 11, selected[opt] and Theme.TextPri or Theme.TextSec)
                optLbl.Size     = UDim2.new(1,-28,1,0)
                optLbl.Position = UDim2.new(0, 26, 0, 0)
                optLbl.ZIndex   = 63

                ob.MouseEnter:Connect(function() 
                    Tween(ob, {BackgroundColor3 = Theme.ElementHov}, 0.12) 
                end)
                ob.MouseLeave:Connect(function() 
                    Tween(ob, {BackgroundColor3 = Theme.PopupBg}, 0.12) 
                end)
                ob.MouseButton1Click:Connect(function()
                    selected[opt] = not selected[opt]
                    Tween(chk, {BackgroundColor3 = selected[opt] and Theme.Accent or Theme.TrackBg}, 0.18)
                    Tween(optLbl, {TextColor3 = selected[opt] and Theme.TextPri or Theme.TextSec}, 0.18)
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
    -- 9. COLOR PICKER (БЕЗ внешнего фона)
    -- ══════════════════════════════════════════════════════════
    function Elem:CreateColorPicker(text, default, callback)
        default = default or Color3.fromRGB(255,255,255)
        local hue, sat, val_ = Color3.toHSV(default)
        local f = BaseFrame(nil, true)
        Stroke(f, Theme.Border, 1)

        local lbl = Label(f, text, 11, Theme.TextPri)
        lbl.Size     = UDim2.new(1, -40, 1, 0)
        lbl.Position = UDim2.new(0, 8, 0, 0)

        local preview = Instance.new("Frame")
        preview.Size            = UDim2.new(0, 16, 0, 16)
        preview.Position        = UDim2.new(1, -24, 0.5, -8)
        preview.BackgroundColor3 = default
        preview.BorderSizePixel = 0
        preview.Parent          = f
        Corner(preview, 4)
        Stroke(preview, Theme.TextSec, 1)

        local btn = Instance.new("TextButton")
        btn.Size   = UDim2.new(1,0,1,0)
        btn.BackgroundTransparency = 1
        btn.Text   = ""
        btn.Parent = f

        btn.MouseEnter:Connect(function() 
            f.BackgroundTransparency = 0.92
            f.BackgroundColor3 = Theme.ElementHov
        end)
        btn.MouseLeave:Connect(function() 
            f.BackgroundTransparency = 1
        end)

        local function GetColor() return Color3.fromHSV(hue, sat, val_) end

        btn.MouseButton1Click:Connect(function()
            local alreadyOpen = PopupLayer:FindFirstChild(text .. "_cp")
            CloseAllPopups()
            if alreadyOpen then return end

            local absPos  = f.AbsolutePosition
            local absSize = f.AbsoluteSize

            local Menu = Instance.new("Frame")
            Menu.Name            = text .. "_cp"
            Menu.Size            = UDim2.new(0, absSize.X, 0, 150)
            Menu.Position        = UDim2.new(0, absPos.X, 0, absPos.Y + absSize.Y + 4)
            Menu.BackgroundColor3 = Theme.PopupBg
            Menu.BorderSizePixel = 0
            Menu.ZIndex          = 60
            Menu.BackgroundTransparency = 1
            Menu.Parent          = PopupLayer
            Corner(Menu, 5)
            Stroke(Menu, Theme.Accent, 1)
            
            Tween(Menu, {BackgroundTransparency = 0}, 0.15)

            -- SV picker
            local SV = Instance.new("ImageLabel")
            SV.Size            = UDim2.new(0, 110, 0, 110)
            SV.Position        = UDim2.new(0, 10, 0, 10)
            SV.Image           = "rbxassetid://4155801252"
            SV.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
            SV.BorderSizePixel = 0
            SV.ZIndex          = 61
            SV.Parent          = Menu
            Corner(SV, 4)

            local SVcursor = Instance.new("Frame")
            SVcursor.Size            = UDim2.new(0, 8, 0, 8)
            SVcursor.AnchorPoint     = Vector2.new(0.5, 0.5)
            SVcursor.Position        = UDim2.new(sat, 0, 1-val_, 0)
            SVcursor.BackgroundColor3 = Color3.fromRGB(255,255,255)
            SVcursor.BorderSizePixel = 0
            SVcursor.ZIndex          = 62
            SVcursor.Parent          = SV
            Corner(SVcursor, 4)
            Stroke(SVcursor, Color3.fromRGB(0,0,0), 1)

            -- Hue slider
            local HueTrack = Instance.new("ImageLabel")
            HueTrack.Size            = UDim2.new(0, 14, 0, 110)
            HueTrack.Position        = UDim2.new(0, 128, 0, 10)
            HueTrack.Image           = "rbxassetid://4155805389"
            HueTrack.BorderSizePixel = 0
            HueTrack.ZIndex          = 61
            HueTrack.Parent          = Menu
            Corner(HueTrack, 4)

            local HueCursor = Instance.new("Frame")
            HueCursor.Size            = UDim2.new(1, 2, 0, 3)
            HueCursor.AnchorPoint     = Vector2.new(0.5, 0.5)
            HueCursor.Position        = UDim2.new(0.5, 0, hue, 0)
            HueCursor.BackgroundColor3 = Color3.fromRGB(255,255,255)
            HueCursor.BorderSizePixel = 0
            HueCursor.ZIndex          = 62
            HueCursor.Parent          = HueTrack
            Stroke(HueCursor, Color3.fromRGB(0,0,0), 1)

            -- Alpha slider
            local AlphaTrack = Instance.new("Frame")
            AlphaTrack.Size            = UDim2.new(0, 14, 0, 110)
            AlphaTrack.Position        = UDim2.new(0, 150, 0, 10)
            AlphaTrack.BackgroundColor3 = Color3.fromRGB(255,255,255)
            AlphaTrack.BorderSizePixel = 0
            AlphaTrack.ZIndex          = 61
            AlphaTrack.Parent          = Menu
            Corner(AlphaTrack, 4)
            Stroke(AlphaTrack, Theme.Border, 1)

            -- Hex preview
            local HexBg = Instance.new("Frame")
            HexBg.Size            = UDim2.new(0, 110, 0, 20)
            HexBg.Position        = UDim2.new(0, 10, 0, 124)
            HexBg.BackgroundColor3 = Theme.TrackBg
            HexBg.BorderSizePixel = 0
            HexBg.ZIndex          = 61
            HexBg.Parent          = Menu
            Corner(HexBg, 4)

            local HexLabel = Label(HexBg, "#" .. string.format("%02X%02X%02X",
                math.floor(default.R*255), math.floor(default.G*255), math.floor(default.B*255)),
                10, Theme.TextSec, Enum.Font.RobotoMono, Enum.TextXAlignment.Center)
            HexLabel.Size   = UDim2.new(1,0,1,0)
            HexLabel.ZIndex = 62

            local colPreview = Instance.new("Frame")
            colPreview.Size            = UDim2.new(0, 20, 0, 20)
            colPreview.Position        = UDim2.new(0, 128, 0, 124)
            colPreview.BackgroundColor3 = GetColor()
            colPreview.BorderSizePixel = 0
            colPreview.ZIndex          = 61
            colPreview.Parent          = Menu
            Corner(colPreview, 4)

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

            -- SV interaction
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

            -- Hue interaction
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
    -- 10. KEYBIND (БЕЗ фона, FIXED для RightShift)
    -- ══════════════════════════════════════════════════════════
    function Elem:CreateKeybind(text, defaultKey, callback)
        local currentKey = defaultKey or Enum.KeyCode.Unknown
        local listening  = false
        local f = BaseFrame(nil, true)
        Stroke(f, Theme.Border, 1)

        local lbl = Label(f, text, 11, Theme.TextPri)
        lbl.Size     = UDim2.new(1, -82, 1, 0)
        lbl.Position = UDim2.new(0, 8, 0, 0)

        local keyBtn = Instance.new("TextButton")
        keyBtn.Size            = UDim2.new(0, 70, 0, 20)
        keyBtn.Position        = UDim2.new(1, -76, 0.5, -10)
        keyBtn.BackgroundColor3 = Theme.TrackBg
        keyBtn.Font            = Enum.Font.GothamBold
        keyBtn.Text            = currentKey.Name
        keyBtn.TextColor3      = Theme.Accent
        keyBtn.TextSize        = 10
        keyBtn.AutoButtonColor = false
        keyBtn.Parent          = f
        Corner(keyBtn, 4)
        Stroke(keyBtn, Theme.Border, 1)

        f.MouseEnter:Connect(function() 
            f.BackgroundTransparency = 0.92
            f.BackgroundColor3 = Theme.ElementHov
        end)
        f.MouseLeave:Connect(function() 
            f.BackgroundTransparency = 1
        end)

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
                    -- Не позволяем бинд на RightShift (он зарезервирован)
                    if i.KeyCode == Enum.KeyCode.RightShift then
                        keyBtn.Text = "Reserved"
                        task.delay(0.8, function()
                            if not listening then return end
                            keyBtn.Text = currentKey.Name
                            keyBtn.TextColor3 = Theme.Accent
                            Tween(keyBtn, {BackgroundColor3 = Theme.TrackBg})
                            listening = false
                            conn:Disconnect()
                        end)
                        return
                    end
                    
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

        -- Глобальное срабатывание (изолированное от RightShift)
        UserInputService.InputBegan:Connect(function(i, gp)
            if gp or listening then return end
            if i.KeyCode == currentKey and currentKey ~= Enum.KeyCode.RightShift then 
                pcall(callback, currentKey) 
            end
        end)

        RegElem(f, text)
        return {
            GetKey = function() return currentKey end,
            SetKey = function(_, k)
                if k == Enum.KeyCode.RightShift then return end  -- блокируем RightShift
                currentKey    = k
                keyBtn.Text   = k.Name
                pcall(callback, k)
            end,
        }
    end

    -- ══════════════════════════════════════════════════════════
    -- 11. NOTIFICATION (улучшенная анимация)
    -- ══════════════════════════════════════════════════════════
    function Library:Notify(title, body, duration)
        duration = duration or 3
        local notif = Instance.new("Frame")
        notif.Size            = UDim2.new(0, 240, 0, 52)
        notif.Position        = UDim2.new(1, -248, 0, BAR_H + 8)
        notif.BackgroundColor3 = Theme.MainBg
        notif.BorderSizePixel = 0
        notif.BackgroundTransparency = 1
        notif.ZIndex          = 80
        notif.Parent          = ScreenGui
        Corner(notif, 6)
        Stroke(notif, Theme.Accent, 1)

        -- Левая акцентная полоска
        local LeftLine = Instance.new("Frame")
        LeftLine.Size            = UDim2.new(0, 3, 1, -10)
        LeftLine.Position        = UDim2.new(0, 5, 0, 5)
        LeftLine.BackgroundColor3 = Theme.Accent
        LeftLine.BorderSizePixel = 0
        LeftLine.ZIndex          = 81
        LeftLine.Parent          = notif
        Corner(LeftLine, 2)

        local t1 = Label(notif, title, 12, Theme.TextPri, Enum.Font.GothamBold)
        t1.Size     = UDim2.new(1,-18,0,16)
        t1.Position = UDim2.new(0,14,0,8)
        t1.ZIndex   = 81

        local t2 = Label(notif, body, 10, Theme.TextSec)
        t2.Size     = UDim2.new(1,-18,0,24)
        t2.Position = UDim2.new(0,14,0,26)
        t2.TextWrapped = true
        t2.ZIndex   = 81

        -- Slide in animation
        notif.Position = UDim2.new(1, 20, 0, BAR_H + 8)
        Tween(notif, {BackgroundTransparency = 0}, 0.2)
        Tween(notif, {Position = UDim2.new(1, -248, 0, BAR_H + 8)}, 0.3, Enum.EasingStyle.Back)

        task.delay(duration, function()
            Tween(notif, {Position = UDim2.new(1, 20, 0, BAR_H + 8)}, 0.25, Enum.EasingStyle.Quart)
            Tween(notif, {BackgroundTransparency = 1}, 0.25)
            task.delay(0.28, function() notif:Destroy() end)
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
  ✦ METEOR UI LIBRARY v3.0 — METEOR CLIENT STYLE
  
  ОСОБЕННОСТИ:
  • Loading Screen с анимацией
  • Вкладки сверху горизонтально (как в Meteor Client)
  • Прозрачные элементы без фона
  • Фон только у Search Bar
  • Минималистичный дизайн
  • Исправлен баг RightShift
  • Улучшенные анимации
════════════════════════════════════════════════

ПРИМЕР ИСПОЛЬЗОВАНИЯ:

local Lib = loadstring(game:HttpGet("..."))()

-- Combat Tab
local Combat = Lib:CreateTab("Combat", "⚔")
Combat:CreateButton("Kill Aura", function() 
    print("Kill Aura activated") 
end)
Combat:CreateToggle("Auto Block", false, function(v) 
    print("Auto Block:", v) 
end)
Combat:CreateSlider("Reach", 3, 20, 6, 0.5, function(v) 
    print("Reach:", v) 
end)
Combat:CreateDropdown("Target Mode", {"Nearest","Random","Highest HP"}, function(v) 
    print("Target:", v) 
end)
Combat:CreateKeybind("Toggle Aura", Enum.KeyCode.V, function(key) 
    print("Aura toggled with", key.Name) 
end)

-- Visual Tab
local Visual = Lib:CreateTab("Visual", "👁")
Visual:CreateSeparator("ESP Settings")
Visual:CreateToggle("Player ESP", true, function(v) 
    print("Player ESP:", v) 
end)
Visual:CreateColorPicker("ESP Color", Color3.fromRGB(220,45,175), function(c) 
    print("ESP Color:", c) 
end)
Visual:CreateMultiSelect("ESP Elements", {"Box","Name","Health","Distance"}, function(t) 
    print("Selected:", table.concat(t, ", ")) 
end)

-- Settings Tab
local Settings = Lib:CreateTab("Settings", "⚙")
Settings:CreateTextBox("Username", "Enter name...", function(text, enter) 
    if enter then print("Saved username:", text) end
end)
Settings:CreateLabel("Press RightShift to toggle GUI")

-- Notification
Lib:Notify("Meteor Loaded", "Welcome! Press RightShift to toggle.", 5)

]]
