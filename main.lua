--[[
    MeteorGUI Library — Custom Icon Edition
    Иконки: rbxassetid://83838907325267 (открытое око)
            rbxassetid://135935519452375 (закрытое око)
            rbxassetid://75552929277870 (мусорка)
]]

local MeteorGUI = {}
MeteorGUI.__index = MeteorGUI

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Theme
local Theme = {
    Background = Color3.fromRGB(20, 20, 20),
    BackgroundTransparency = 0.15,
    Secondary = Color3.fromRGB(30, 30, 30),
    Accent = Color3.fromRGB(0, 170, 255),
    AccentHover = Color3.fromRGB(0, 200, 255),
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(180, 180, 180),
    Border = Color3.fromRGB(40, 40, 40),
    Error = Color3.fromRGB(255, 80, 80),
    Success = Color3.fromRGB(80, 255, 120),
    Font = Enum.Font.BuilderSans,
    CornerRadius = UDim.new(0, 6),
    AnimationSpeed = 0.25
}

-- Asset IDs
local Assets = {
    EyeOpen = "rbxassetid://83838907325267",
    EyeClosed = "rbxassetid://135935519452375",
    Trash = "rbxassetid://75552929277870"
}

-- Utility
local function Tween(instance, properties, duration, easingStyle, easingDirection)
    local tween = TweenService:Create(
        instance,
        TweenInfo.new(
            duration or Theme.AnimationSpeed,
            easingStyle or Enum.EasingStyle.Quart,
            easingDirection or Enum.EasingDirection.Out
        ),
        properties
    )
    tween:Play()
    return tween
end

local function Create(className, properties)
    local instance = Instance.new(className)
    for prop, value in pairs(properties or {}) do
        instance[prop] = value
    end
    return instance
end

-- Helper: создаёт ImageButton-иконку
local function CreateIcon(parent, assetId, position, size, color)
    local btn = Create("ImageButton", {
        Parent = parent,
        Size = size or UDim2.new(0, 20, 0, 20),
        Position = position or UDim2.new(1, -24, 0.5, -10),
        BackgroundTransparency = 1,
        Image = assetId,
        ImageColor3 = color or Theme.Text,
        ScaleType = Enum.ScaleType.Fit,
        BorderSizePixel = 0
    })
    return btn
end

-- Dragging
local function MakeDraggable(frame, dragHandle)
    local dragging = false
    local dragStart, startPos = nil, nil
    dragHandle = dragHandle or frame

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            Tween(frame, {BackgroundTransparency = 0.05}, 0.1)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            Tween(frame, {BackgroundTransparency = Theme.BackgroundTransparency}, 0.1)
        end
    end)
end

-- Confirmation Modal
local function ShowConfirmationModal(text, onConfirm, onCancel)
    local screenGui = PlayerGui:FindFirstChild("MeteorGUI")
    if not screenGui then return end

    local backdrop = Create("Frame", {
        Parent = screenGui,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 0.5,
        ZIndex = 99
    })

    local modal = Create("Frame", {
        Name = "ConfirmationModal",
        Parent = screenGui,
        Size = UDim2.new(0, 320, 0, 140),
        Position = UDim2.new(0.5, -160, 0.5, -70),
        BackgroundColor3 = Theme.Secondary,
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0,
        ZIndex = 100,
        ClipsDescendants = true
    })
    Create("UICorner", {CornerRadius = Theme.CornerRadius, Parent = modal})
    Create("UIStroke", {Color = Theme.Border, Thickness = 1, Parent = modal})

    local title = Create("TextLabel", {
        Parent = modal,
        Size = UDim2.new(1, -20, 0, 30),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundTransparency = 1,
        Text = "Confirm Action",
        TextColor3 = Theme.Text,
        Font = Theme.Font,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 101
    })

    local message = Create("TextLabel", {
        Parent = modal,
        Size = UDim2.new(1, -20, 0, 40),
        Position = UDim2.new(0, 10, 0, 45),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme.TextDim,
        Font = Theme.Font,
        TextSize = 14,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 101
    })

    local buttonLayout = Create("Frame", {
        Parent = modal,
        Size = UDim2.new(1, -20, 0, 32),
        Position = UDim2.new(0, 10, 1, -42),
        BackgroundTransparency = 1,
        ZIndex = 101
    })

    Create("UIListLayout", {
        Parent = buttonLayout,
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        Padding = UDim.new(0, 8)
    })

    local function closeModal()
        Tween(modal, {Size = UDim2.new(0, 320, 0, 0)}, 0.2)
        Tween(backdrop, {BackgroundTransparency = 1}, 0.2)
        task.wait(0.2)
        modal:Destroy()
        backdrop:Destroy()
    end

    local cancelBtn = Create("TextButton", {
        Parent = buttonLayout,
        Size = UDim2.new(0, 80, 1, 0),
        BackgroundColor3 = Theme.Background,
        Text = "Cancel",
        TextColor3 = Theme.TextDim,
        Font = Theme.Font,
        TextSize = 14,
        BorderSizePixel = 0,
        ZIndex = 102
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = cancelBtn})

    cancelBtn.MouseEnter:Connect(function() Tween(cancelBtn, {BackgroundColor3 = Theme.Secondary}, 0.15) end)
    cancelBtn.MouseLeave:Connect(function() Tween(cancelBtn, {BackgroundColor3 = Theme.Background}, 0.15) end)
    cancelBtn.MouseButton1Click:Connect(function()
        closeModal()
        if onCancel then onCancel() end
    end)

    local yesBtn = Create("TextButton", {
        Parent = buttonLayout,
        Size = UDim2.new(0, 80, 1, 0),
        BackgroundColor3 = Theme.Error,
        Text = "Yes",
        TextColor3 = Theme.Text,
        Font = Theme.Font,
        TextSize = 14,
        BorderSizePixel = 0,
        ZIndex = 102
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = yesBtn})

    yesBtn.MouseEnter:Connect(function() Tween(yesBtn, {BackgroundColor3 = Color3.fromRGB(255, 100, 100)}, 0.15) end)
    yesBtn.MouseLeave:Connect(function() Tween(yesBtn, {BackgroundColor3 = Theme.Error}, 0.15) end)
    yesBtn.MouseButton1Click:Connect(function()
        closeModal()
        if onConfirm then onConfirm() end
    end)

    modal.Size = UDim2.new(0, 320, 0, 0)
    Tween(modal, {Size = UDim2.new(0, 320, 0, 140)}, 0.3, Enum.EasingStyle.Back)
end

-- ==========================================
-- SETTINGS PANEL
-- ==========================================
local SettingsPanel = {}
SettingsPanel.__index = SettingsPanel

function SettingsPanel.new(parentFeature, featureName)
    local self = setmetatable({}, SettingsPanel)
    self.Feature = parentFeature
    self.Elements = {}
    self.Visible = false

    self.Frame = Create("Frame", {
        Name = featureName .. "_Settings",
        Parent = parentFeature.Category.Window.Frame,
        Size = UDim2.new(0, 220, 0, 0),
        Position = UDim2.new(1, 10, 0, parentFeature.Button.AbsolutePosition.Y - parentFeature.Category.Window.Frame.AbsolutePosition.Y),
        BackgroundColor3 = Theme.Secondary,
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Visible = false,
        ZIndex = 50
    })

    Create("UICorner", {CornerRadius = Theme.CornerRadius, Parent = self.Frame})
    Create("UIStroke", {Color = Theme.Border, Thickness = 1, Parent = self.Frame})

    Create("UIPadding", {
        Parent = self.Frame,
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingTop = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10)
    })

    Create("UIListLayout", {
        Parent = self.Frame,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 6)
    })

    local title = Create("TextLabel", {
        Parent = self.Frame,
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundTransparency = 1,
        Text = featureName .. " Settings",
        TextColor3 = Theme.Text,
        Font = Theme.Font,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    Create("Frame", {
        Parent = self.Frame,
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = Theme.Border,
        BorderSizePixel = 0
    })

    return self
end

function SettingsPanel:AddToggle(name, default, callback)
    local toggleFrame = Create("Frame", {
        Parent = self.Frame,
        Size = UDim2.new(1, 0, 0, 28),
        BackgroundTransparency = 1
    })

    local label = Create("TextLabel", {
        Parent = toggleFrame,
        Size = UDim2.new(1, -50, 1, 0),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = Theme.TextDim,
        Font = Theme.Font,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local switch = Create("Frame", {
        Parent = toggleFrame,
        Size = UDim2.new(0, 40, 0, 20),
        Position = UDim2.new(1, -40, 0.5, -10),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0
    })
    Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = switch})

    local knob = Create("Frame", {
        Parent = switch,
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(0, 2, 0.5, -8),
        BackgroundColor3 = Theme.TextDim,
        BorderSizePixel = 0
    })
    Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = knob})

    local enabled = default or false

    local function updateToggle()
        if enabled then
            Tween(switch, {BackgroundColor3 = Theme.Accent}, 0.2)
            Tween(knob, {Position = UDim2.new(1, -18, 0.5, -8), BackgroundColor3 = Theme.Text}, 0.2)
        else
            Tween(switch, {BackgroundColor3 = Theme.Background}, 0.2)
            Tween(knob, {Position = UDim2.new(0, 2, 0.5, -8), BackgroundColor3 = Theme.TextDim}, 0.2)
        end
        if callback then callback(enabled) end
    end

    if enabled then
        switch.BackgroundColor3 = Theme.Accent
        knob.Position = UDim2.new(1, -18, 0.5, -8)
        knob.BackgroundColor3 = Theme.Text
    end

    local clickArea = Create("TextButton", {
        Parent = toggleFrame,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = ""
    })

    clickArea.MouseButton1Click:Connect(function()
        enabled = not enabled
        updateToggle()
    end)

    table.insert(self.Elements, toggleFrame)
    return self
end

function SettingsPanel:AddSlider(name, min, max, default, callback)
    local sliderFrame = Create("Frame", {
        Parent = self.Frame,
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1
    })

    local label = Create("TextLabel", {
        Parent = sliderFrame,
        Size = UDim2.new(1, -40, 0, 18),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = Theme.TextDim,
        Font = Theme.Font,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local valueLabel = Create("TextLabel", {
        Parent = sliderFrame,
        Size = UDim2.new(0, 40, 0, 18),
        Position = UDim2.new(1, -40, 0, 0),
        BackgroundTransparency = 1,
        Text = tostring(default),
        TextColor3 = Theme.Accent,
        Font = Theme.Font,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Right
    })

    local track = Create("Frame", {
        Parent = sliderFrame,
        Size = UDim2.new(1, 0, 0, 4),
        Position = UDim2.new(0, 0, 0, 26),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0
    })
    Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = track})

    local fill = Create("Frame", {
        Parent = track,
        Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0
    })
    Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = fill})

    local dragging = false

    local function updateSlider(input)
        local pos = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local value = math.floor(min + (pos * (max - min)))
        fill.Size = UDim2.new(pos, 0, 1, 0)
        valueLabel.Text = tostring(value)
        if callback then callback(value) end
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            updateSlider(input)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    table.insert(self.Elements, sliderFrame)
    return self
end

function SettingsPanel:AddDropdown(name, options, default, callback)
    local dropdownFrame = Create("Frame", {
        Parent = self.Frame,
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 1
    })

    local label = Create("TextLabel", {
        Parent = dropdownFrame,
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = Theme.TextDim,
        Font = Theme.Font,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local button = Create("TextButton", {
        Parent = dropdownFrame,
        Size = UDim2.new(1, 0, 0, 24),
        Position = UDim2.new(0, 0, 0, 18),
        BackgroundColor3 = Theme.Background,
        Text = "  " .. (default or options[1]),
        TextColor3 = Theme.Text,
        Font = Theme.Font,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        BorderSizePixel = 0
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = button})

    local arrow = Create("TextLabel", {
        Parent = button,
        Size = UDim2.new(0, 20, 1, 0),
        Position = UDim2.new(1, -20, 0, 0),
        BackgroundTransparency = 1,
        Text = "›",
        TextColor3 = Theme.TextDim,
        Font = Theme.Font,
        TextSize = 14
    })

    local expanded = false
    local optionFrames = {}

    button.MouseButton1Click:Connect(function()
        expanded = not expanded
        for _, opt in ipairs(optionFrames) do
            opt.Visible = expanded
        end
        arrow.Text = expanded and "⌄" or "›"
    end)

    for i, option in ipairs(options) do
        local optBtn = Create("TextButton", {
            Parent = dropdownFrame,
            Size = UDim2.new(1, 0, 0, 22),
            Position = UDim2.new(0, 0, 0, 42 + ((i-1) * 24)),
            BackgroundColor3 = Theme.Secondary,
            Text = "  " .. option,
            TextColor3 = Theme.TextDim,
            Font = Theme.Font,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            BorderSizePixel = 0,
            Visible = false,
            ZIndex = 55
        })
        Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = optBtn})

        optBtn.MouseEnter:Connect(function() Tween(optBtn, {BackgroundColor3 = Theme.Background}, 0.1) end)
        optBtn.MouseLeave:Connect(function() Tween(optBtn, {BackgroundColor3 = Theme.Secondary}, 0.1) end)

        optBtn.MouseButton1Click:Connect(function()
            button.Text = "  " .. option
            expanded = false
            for _, opt in ipairs(optionFrames) do opt.Visible = false end
            arrow.Text = "›"
            if callback then callback(option) end
        end)

        table.insert(optionFrames, optBtn)
    end

    table.insert(self.Elements, dropdownFrame)
    return self
end

function SettingsPanel:Toggle()
    self.Visible = not self.Visible
    self.Frame.Visible = true

    if self.Visible then
        local height = 0
        for _, child in ipairs(self.Frame:GetChildren()) do
            if child:IsA("GuiObject") and child.Name ~= "UIListLayout" and child.Name ~= "UIPadding" then
                height = height + child.AbsoluteSize.Y + 6
            end
        end
        height = math.max(height + 20, 100)
        Tween(self.Frame, {Size = UDim2.new(0, 220, 0, height)}, 0.3, Enum.EasingStyle.Quart)
    else
        Tween(self.Frame, {Size = UDim2.new(0, 220, 0, 0)}, 0.2)
        task.wait(0.2)
        self.Frame.Visible = false
    end
end

function SettingsPanel:Destroy()
    self.Frame:Destroy()
end

-- ==========================================
-- FEATURE
-- ==========================================
local Feature = {}
Feature.__index = Feature

function Feature.new(category, name)
    local self = setmetatable({}, Feature)
    self.Name = name
    self.Category = category
    self.Visible = true
    self.Settings = nil

    self.Button = Create("TextButton", {
        Name = name,
        Parent = category.FeatureList,
        Size = UDim2.new(1, -10, 0, 32),
        BackgroundColor3 = Theme.Background,
        Text = "",
        BorderSizePixel = 0,
        AutoButtonColor = false
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = self.Button})

    Create("UIPadding", {
        Parent = self.Button,
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10)
    })

    self.Label = Create("TextLabel", {
        Parent = self.Button,
        Size = UDim2.new(1, -30, 1, 0),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = Theme.Text,
        Font = Theme.Font,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    -- Кастомная иконка глаза (открыто/закрыто) для фичи
    self.EyeButton = CreateIcon(self.Button, Assets.EyeOpen, UDim2.new(1, -24, 0.5, -10), UDim2.new(0, 20, 0, 20), Theme.Text)

    self.Button.MouseEnter:Connect(function() Tween(self.Button, {BackgroundColor3 = Theme.Secondary}, 0.15) end)
    self.Button.MouseLeave:Connect(function() Tween(self.Button, {BackgroundColor3 = Theme.Background}, 0.15) end)

    self.Button.MouseButton1Click:Connect(function()
        if not self.Settings then
            self.Settings = SettingsPanel.new(self, name)
        end
        self.Settings:Toggle()
    end)

    self.EyeButton.MouseButton1Click:Connect(function()
        self.Visible = not self.Visible
        self.EyeButton.Image = self.Visible and Assets.EyeOpen or Assets.EyeClosed
        self.EyeButton.ImageColor3 = self.Visible and Theme.Text or Theme.TextDim

        if self.Settings then
            self.Settings.Frame.Visible = self.Visible
            if not self.Visible then self.Settings.Visible = false end
        end
    end)

    return self
end

function Feature:AddToggle(name, default, callback)
    if not self.Settings then self.Settings = SettingsPanel.new(self, self.Name) end
    self.Settings:AddToggle(name, default, callback)
    return self
end

function Feature:AddSlider(name, min, max, default, callback)
    if not self.Settings then self.Settings = SettingsPanel.new(self, self.Name) end
    self.Settings:AddSlider(name, min, max, default, callback)
    return self
end

function Feature:AddDropdown(name, options, default, callback)
    if not self.Settings then self.Settings = SettingsPanel.new(self, self.Name) end
    self.Settings:AddDropdown(name, options, default, callback)
    return self
end

function Feature:Destroy()
    if self.Settings then self.Settings:Destroy() end
    self.Button:Destroy()
end

-- ==========================================
-- CATEGORY WINDOW
-- ==========================================
local CategoryWindow = {}
CategoryWindow.__index = CategoryWindow

function CategoryWindow.new(category, name)
    local self = setmetatable({}, CategoryWindow)
    self.Name = name
    self.Category = category
    self.Visible = true
    self.Position = UDim2.new(0.1, 0, 0.2, 0)

    self.Frame = Create("Frame", {
        Name = name .. "Window",
        Parent = category.GUI.ScreenGui,
        Size = UDim2.new(0, 240, 0, 320),
        Position = self.Position,
        BackgroundColor3 = Theme.Background,
        BackgroundTransparency = Theme.BackgroundTransparency,
        BorderSizePixel = 0,
        ClipsDescendants = true
    })

    Create("UICorner", {CornerRadius = Theme.CornerRadius, Parent = self.Frame})
    Create("UIStroke", {Color = Theme.Border, Thickness = 1, Parent = self.Frame})

    self.TitleBar = Create("Frame", {
        Name = "TitleBar",
        Parent = self.Frame,
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = Theme.Secondary,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0
    })

    Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = self.TitleBar})
    Create("Frame", {
        Parent = self.TitleBar,
        Size = UDim2.new(1, 0, 0.5, 0),
        Position = UDim2.new(0, 0, 0.5, 0),
        BackgroundColor3 = Theme.Secondary,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0
    })

    Create("TextLabel", {
        Parent = self.TitleBar,
        Size = UDim2.new(1, -40, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = Theme.Text,
        Font = Theme.Font,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local closeBtn = Create("TextButton", {
        Parent = self.TitleBar,
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(1, -28, 0.5, -12),
        BackgroundTransparency = 1,
        Text = "✕",
        TextColor3 = Theme.TextDim,
        Font = Theme.Font,
        TextSize = 14
    })

    closeBtn.MouseEnter:Connect(function() Tween(closeBtn, {TextColor3 = Theme.Error}, 0.15) end)
    closeBtn.MouseLeave:Connect(function() Tween(closeBtn, {TextColor3 = Theme.TextDim}, 0.15) end)
    closeBtn.MouseButton1Click:Connect(function() self:Toggle() end)

    self.FeatureList = Create("ScrollingFrame", {
        Name = "FeatureList",
        Parent = self.Frame,
        Size = UDim2.new(1, -10, 1, -42),
        Position = UDim2.new(0, 5, 0, 37),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0)
    })

    local listLayout = Create("UIListLayout", {
        Parent = self.FeatureList,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4)
    })

    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        self.FeatureList.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
    end)

    MakeDraggable(self.Frame, self.TitleBar)

    self.Frame.Size = UDim2.new(0, 240, 0, 0)
    Tween(self.Frame, {Size = UDim2.new(0, 240, 0, 320)}, 0.4, Enum.EasingStyle.Back)

    return self
end

function CategoryWindow:Toggle()
    self.Visible = not self.Visible
    if self.Visible then
        self.Frame.Visible = true
        Tween(self.Frame, {Size = UDim2.new(0, 240, 0, 320)}, 0.3, Enum.EasingStyle.Back)
    else
        Tween(self.Frame, {Size = UDim2.new(0, 240, 0, 0)}, 0.2)
        task.wait(0.2)
        self.Frame.Visible = false
    end
end

function CategoryWindow:Destroy()
    Tween(self.Frame, {Size = UDim2.new(0, 240, 0, 0)}, 0.2)
    task.wait(0.2)
    self.Frame:Destroy()
end

-- ==========================================
-- CATEGORY TAB
-- ==========================================
local Category = {}
Category.__index = Category

function Category.new(gui, name)
    local self = setmetatable({}, Category)
    self.GUI = gui
    self.Name = name
    self.Visible = true
    self.Features = {}

    self.Tab = Create("Frame", {
        Name = name .. "Tab",
        Parent = gui.TabContainer,
        Size = UDim2.new(0, 160, 1, -10),
        BackgroundColor3 = Theme.Secondary,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = self.Tab})

    Create("UIPadding", {
        Parent = self.Tab,
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8)
    })

    self.Label = Create("TextLabel", {
        Parent = self.Tab,
        Size = UDim2.new(1, -60, 1, 0),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = Theme.Text,
        Font = Theme.Font,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    -- Иконка глаза (открыто/закрыто) в табе
    self.EyeButton = CreateIcon(self.Tab, Assets.EyeOpen, UDim2.new(1, -52, 0.5, -10), UDim2.new(0, 20, 0, 20), Theme.Text)

    -- Иконка мусорки в табе
    self.TrashButton = CreateIcon(self.Tab, Assets.Trash, UDim2.new(1, -28, 0.5, -10), UDim2.new(0, 20, 0, 20), Theme.TextDim)

    self.Tab.MouseEnter:Connect(function() Tween(self.Tab, {BackgroundColor3 = Color3.fromRGB(45, 45, 45)}, 0.15) end)
    self.Tab.MouseLeave:Connect(function() Tween(self.Tab, {BackgroundColor3 = Theme.Secondary}, 0.15) end)

    self.Tab.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local pos = Vector2.new(input.Position.X, input.Position.Y)
            local eyePos = self.EyeButton.AbsolutePosition
            local eyeSize = self.EyeButton.AbsoluteSize
            local trashPos = self.TrashButton.AbsolutePosition
            local trashSize = self.TrashButton.AbsoluteSize

            if not (pos.X >= eyePos.X and pos.X <= eyePos.X + eyeSize.X and pos.Y >= eyePos.Y and pos.Y <= eyePos.Y + eyeSize.Y) and
               not (pos.X >= trashPos.X and pos.X <= trashPos.X + trashSize.X and pos.Y >= trashPos.Y and pos.Y <= trashPos.Y + trashSize.Y) then
                self.Window:Toggle()
                if not self.Window.Visible then self.Window:Toggle() end
                self.Window.Frame.Position = UDim2.new(0.1 + (#gui.Categories * 0.05), 0, 0.2, 0)
            end
        end
    end)

    self.EyeButton.MouseButton1Click:Connect(function()
        self.Visible = not self.Visible
        self.EyeButton.Image = self.Visible and Assets.EyeOpen or Assets.EyeClosed
        self.EyeButton.ImageColor3 = self.Visible and Theme.Text or Theme.TextDim

        if self.Window then
            if self.Visible then
                self.Window.Frame.Visible = true
                Tween(self.Window.Frame, {Size = UDim2.new(0, 240, 0, 320)}, 0.3, Enum.EasingStyle.Back)
            else
                Tween(self.Window.Frame, {Size = UDim2.new(0, 240, 0, 0)}, 0.2)
                task.wait(0.2)
                self.Window.Frame.Visible = false
            end
        end
    end)

    self.TrashButton.MouseEnter:Connect(function() Tween(self.TrashButton, {ImageColor3 = Theme.Error}, 0.15) end)
    self.TrashButton.MouseLeave:Connect(function() Tween(self.TrashButton, {ImageColor3 = Theme.TextDim}, 0.15) end)

    self.TrashButton.MouseButton1Click:Connect(function()
        ShowConfirmationModal("Are you sure you want to delete this tab?", function()
            self:Destroy()
        end)
    end)

    self.Window = CategoryWindow.new(self, name)
    return self
end

function Category:AddFeature(name)
    local feature = Feature.new(self, name)
    table.insert(self.Features, feature)
    return feature
end

function Category:Destroy()
    for _, feature in ipairs(self.Features) do feature:Destroy() end
    if self.Window then self.Window:Destroy() end

    Tween(self.Tab, {Size = UDim2.new(0, 0, 1, -10)}, 0.2)
    task.wait(0.2)
    self.Tab:Destroy()

    for i, cat in ipairs(self.GUI.Categories) do
        if cat == self then
            table.remove(self.GUI.Categories, i)
            break
        end
    end
end

-- ==========================================
-- MAIN GUI
-- ==========================================
function MeteorGUI.new()
    local self = setmetatable({}, MeteorGUI)
    self.Categories = {}

    self.ScreenGui = Create("ScreenGui", {
        Name = "MeteorGUI",
        Parent = PlayerGui,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })

    self.TopBar = Create("Frame", {
        Name = "TopBar",
        Parent = self.ScreenGui,
        Size = UDim2.new(1, 0, 0, 44),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Theme.Background,
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0
    })

    Create("UICorner", {CornerRadius = UDim.new(0, 0), Parent = self.TopBar})
    Create("Frame", {
        Parent = self.TopBar,
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = Theme.Border,
        BorderSizePixel = 0
    })

    self.SearchContainer = Create("Frame", {
        Name = "SearchContainer",
        Parent = self.TopBar,
        Size = UDim2.new(0, 200, 0, 30),
        Position = UDim2.new(1, -210, 0.5, -15),
        BackgroundColor3 = Theme.Secondary,
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = self.SearchContainer})

    local searchIcon = Create("TextLabel", {
        Parent = self.SearchContainer,
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(0, 6, 0.5, -12),
        BackgroundTransparency = 1,
        Text = "🔍",
        TextColor3 = Theme.TextDim,
        Font = Theme.Font,
        TextSize = 12
    })

    self.SearchBox = Create("TextBox", {
        Parent = self.SearchContainer,
        Size = UDim2.new(1, -36, 1, 0),
        Position = UDim2.new(0, 30, 0, 0),
        BackgroundTransparency = 1,
        Text = "",
        PlaceholderText = "Search features...",
        TextColor3 = Theme.Text,
        PlaceholderColor3 = Theme.TextDim,
        Font = Theme.Font,
        TextSize = 13,
        ClearTextOnFocus = false
    })

    self.SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        self:FilterTabs(self.SearchBox.Text)
    end)

    self.TabContainer = Create("Frame", {
        Name = "TabContainer",
        Parent = self.TopBar,
        Size = UDim2.new(1, -220, 0, 34),
        Position = UDim2.new(0, 10, 0.5, -17),
        BackgroundTransparency = 1
    })

    Create("UIListLayout", {
        Parent = self.TabContainer,
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 6),
        VerticalAlignment = Enum.VerticalAlignment.Center
    })

    self.TopBar.Position = UDim2.new(0, 0, 0, -44)
    Tween(self.TopBar, {Position = UDim2.new(0, 0, 0, 0)}, 0.5, Enum.EasingStyle.Quart)

    return self
end

function MeteorGUI:AddCategory(name)
    local category = Category.new(self, name)
    table.insert(self.Categories, category)
    return category
end

function MeteorGUI:FilterTabs(query)
    query = query:lower()
    for _, category in ipairs(self.Categories) do
        local tabVisible = true
        if query ~= "" and not category.Name:lower():find(query) then
            tabVisible = false
        end

        if tabVisible then
            category.Tab.Visible = true
            Tween(category.Tab, {Size = UDim2.new(0, 160, 1, -10)}, 0.2)
        else
            Tween(category.Tab, {Size = UDim2.new(0, 0, 1, -10)}, 0.2)
            task.wait(0.1)
            category.Tab.Visible = false
        end

        for _, feature in ipairs(category.Features) do
            if query == "" or feature.Name:lower():find(query) then
                feature.Button.Visible = true
            else
                feature.Button.Visible = false
            end
        end
    end
end

function MeteorGUI:Destroy()
    for _, category in ipairs(self.Categories) do category:Destroy() end
    self.ScreenGui:Destroy()
end

return MeteorGUI
