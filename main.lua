local Library = {}
local UserInputService = game:GetService("UserInputService")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MinecraftStrictUI"
ScreenGui.ResetOnSpawn = false

local success, coreGui = pcall(function() return game:GetService("CoreGui") end)
ScreenGui.Parent = success and coreGui or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and input.KeyCode == Enum.KeyCode.RightShift then
		ScreenGui.Enabled = not ScreenGui.Enabled
	end
end)

function Library:CreateWindow(titleText, defaultPosition)
	local Window = {}
	local isCollapsed = false
	
	-- ЖЕЛЕЗОБЕТОННАЯ ШИРИНА ОКНА
	local WINDOW_WIDTH = 230
	local HEADER_HEIGHT = 24

	-- Главный фрейм (общая белая обводка как на скрине)
	local MainFrame = Instance.new("Frame")
	MainFrame.Name = titleText .. "_Window"
	MainFrame.Size = UDim2.new(0, WINDOW_WIDTH, 0, HEADER_HEIGHT)
	MainFrame.Position = defaultPosition or UDim2.new(0, 50, 0, 50)
	MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	MainFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
	MainFrame.BorderSizePixel = 2
	MainFrame.Active = true
	MainFrame.Parent = ScreenGui

	-- Шапка
	local TopBar = Instance.new("Frame")
	TopBar.Name = "TopBar"
	TopBar.Size = UDim2.new(1, 0, 0, HEADER_HEIGHT)
	TopBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	TopBar.BorderSizePixel = 0
	TopBar.Parent = MainFrame

	-- Белая линия-разделитель между шапкой и контентом
	local Separator = Instance.new("Frame")
	Separator.Size = UDim2.new(1, 0, 0, 1)
	Separator.Position = UDim2.new(0, 0, 1, 0)
	Separator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Separator.BorderSizePixel = 0
	Separator.Parent = TopBar

	-- Текст шапки ПО ЦЕНТРУ
	local Title = Instance.new("TextLabel")
	Title.Name = "Title"
	Title.Size = UDim2.new(1, 0, 1, 0)
	Title.Position = UDim2.new(0, 0, 0, 0)
	Title.BackgroundTransparency = 1
	Title.Text = string.upper(titleText)
	Title.TextColor3 = Color3.fromRGB(255, 255, 255)
	Title.Font = Enum.Font.Code
	Title.TextSize = 13
	Title.TextXAlignment = Enum.TextXAlignment.Center -- Центрирование
	Title.ZIndex = 1
	Title.Parent = TopBar

	-- Кнопка сворачивания
	local CollapseBtn = Instance.new("TextButton")
	CollapseBtn.Name = "CollapseBtn"
	CollapseBtn.Size = UDim2.new(0, 24, 0, HEADER_HEIGHT)
	CollapseBtn.Position = UDim2.new(1, -24, 0, 0)
	CollapseBtn.BackgroundTransparency = 1
	CollapseBtn.Text = "▲"
	CollapseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	CollapseBtn.Font = Enum.Font.Code
	CollapseBtn.TextSize = 12
	CollapseBtn.ZIndex = 2
	CollapseBtn.Parent = TopBar

	-- Контейнер для плотных элементов
	local Container = Instance.new("Frame")
	Container.Name = "Container"
	Container.Size = UDim2.new(1, -8, 0, 0) -- Отступы по бокам 4px
	Container.Position = UDim2.new(0, 4, 0, HEADER_HEIGHT + 5)
	Container.BackgroundTransparency = 1
	Container.ClipsDescendants = true
	Container.Parent = MainFrame

	local UIListLayout = Instance.new("UIListLayout")
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout.Padding = UDim.new(0, 3) -- Плотное прилегание элементов
	UIListLayout.Parent = Container

	-- Авто-высота
	local function updateHeight()
		if not isCollapsed then
			Container.Size = UDim2.new(1, -8, 0, UIListLayout.AbsoluteContentSize.Y)
			MainFrame.Size = UDim2.new(0, WINDOW_WIDTH, 0, HEADER_HEIGHT + Container.Size.Y.Offset + 10)
		else
			Container.Size = UDim2.new(1, -8, 0, 0)
			MainFrame.Size = UDim2.new(0, WINDOW_WIDTH, 0, HEADER_HEIGHT)
		end
	end
	UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateHeight)

	CollapseBtn.MouseButton1Click:Connect(function()
		isCollapsed = not isCollapsed
		Container.Visible = not isCollapsed
		CollapseBtn.Text = isCollapsed and "▼" or "▲"
		updateHeight()
	end)

	-- Драггер окна
	local dragging, dragInput, dragStart, startPos
	TopBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true; dragStart = input.Position; startPos = MainFrame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	TopBar.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)

	-- ====================================================================
	-- ОБЫЧНАЯ КНОПКА (Как "Instant Respawn" на скрине)
	-- ====================================================================
	function Window:CreateButton(name, callback)
		local Btn = Instance.new("TextButton")
		Btn.Size = UDim2.new(1, 0, 0, 24)
		Btn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
		Btn.BorderColor3 = Color3.fromRGB(60, 60, 60)
		Btn.BorderSizePixel = 1
		Btn.Text = "  " .. name
		Btn.TextColor3 = Color3.fromRGB(180, 180, 180)
		Btn.Font = Enum.Font.Code
		Btn.TextSize = 12
		Btn.TextXAlignment = Enum.TextXAlignment.Left
		Btn.TextTruncate = Enum.TextTruncate.AtEnd -- Обрезка слишком длинного текста
		Btn.Parent = Container

		Btn.MouseButton1Click:Connect(callback)
		return Btn
	end

	-- ====================================================================
	-- ПЕРЕКЛЮЧАТЕЛЬ (Как "Fly Bypass: OFF" на скрине)
	-- ====================================================================
	function Window:CreateToggle(name, callback)
		local ToggleBtn = Instance.new("TextButton")
		ToggleBtn.Size = UDim2.new(1, 0, 0, 24)
		ToggleBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
		ToggleBtn.BorderColor3 = Color3.fromRGB(60, 60, 60)
		ToggleBtn.BorderSizePixel = 1
		ToggleBtn.Text = "  " .. name .. ": OFF"
		ToggleBtn.TextColor3 = Color3.fromRGB(130, 130, 130)
		ToggleBtn.Font = Enum.Font.Code
		ToggleBtn.TextSize = 12
		ToggleBtn.TextXAlignment = Enum.TextXAlignment.Left
		ToggleBtn.TextTruncate = Enum.TextTruncate.AtEnd
		ToggleBtn.Parent = Container

		local enabled = false
		ToggleBtn.MouseButton1Click:Connect(function()
			enabled = not enabled
			if enabled then
				ToggleBtn.Text = "  " .. name .. ": ON"
				ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
			else
				ToggleBtn.Text = "  " .. name .. ": OFF"
				ToggleBtn.TextColor3 = Color3.fromRGB(130, 130, 130)
			end
			callback(enabled)
		end)
		return ToggleBtn
	end

	-- ====================================================================
	-- СЛАЙДЕР (Как "Fly Speed Control" на скрине)
	-- ====================================================================
	function Window:CreateSlider(name, min, max, default, callback)
		local SliderFrame = Instance.new("Frame")
		SliderFrame.Size = UDim2.new(1, 0, 0, 36) -- Компактная высота
		SliderFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
		SliderFrame.BorderColor3 = Color3.fromRGB(60, 60, 60)
		SliderFrame.BorderSizePixel = 1
		SliderFrame.Parent = Container

		local Label = Instance.new("TextLabel")
		Label.Size = UDim2.new(1, -10, 0, 20)
		Label.Position = UDim2.new(0, 8, 0, 0)
		Label.BackgroundTransparency = 1
		Label.Text = name .. ": " .. tostring(default)
		Label.TextColor3 = Color3.fromRGB(180, 180, 180)
		Label.Font = Enum.Font.Code
		Label.TextSize = 12
		Label.TextXAlignment = Enum.TextXAlignment.Left
		Label.TextTruncate = Enum.TextTruncate.AtEnd
		Label.Parent = SliderFrame

		local Track = Instance.new("Frame")
		Track.Size = UDim2.new(1, -16, 0, 6)
		Track.Position = UDim2.new(0, 8, 0, 22)
		Track.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
		Track.BorderColor3 = Color3.fromRGB(50, 50, 50)
		Track.BorderSizePixel = 1
		Track.Parent = SliderFrame

		local Fill = Instance.new("Frame")
		local initPct = math.clamp((default - min) / (max - min), 0, 1)
		Fill.Size = UDim2.new(initPct, 0, 1, 0)
		Fill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Fill.BorderSizePixel = 0
		Fill.Parent = Track

		local sliding = false
		local function update(input)
			local pct = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
			local val = min + (max - min) * pct
			val = math.round(val) -- Целые числа как на скрине
			Fill.Size = UDim2.new(pct, 0, 1, 0)
			Label.Text = name .. ": " .. tostring(val)
			callback(val)
		end

		SliderFrame.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = true; update(input) end
		end)
		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then update(input) end
		end)
	end

	-- ====================================================================
	-- ТЕКСТБОКС
	-- ====================================================================
	function Window:CreateTextBox(name, placeholder, callback)
		local BoxFrame = Instance.new("Frame")
		BoxFrame.Size = UDim2.new(1, 0, 0, 40)
		BoxFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
		BoxFrame.BorderColor3 = Color3.fromRGB(60, 60, 60)
		BoxFrame.BorderSizePixel = 1
		BoxFrame.Parent = Container

		local Label = Instance.new("TextLabel")
		Label.Size = UDim2.new(1, -10, 0, 16)
		Label.Position = UDim2.new(0, 8, 0, 2)
		Label.BackgroundTransparency = 1
		Label.Text = name .. ":"
		Label.TextColor3 = Color3.fromRGB(150, 150, 150)
		Label.Font = Enum.Font.Code
		Label.TextSize = 11
		Label.TextXAlignment = Enum.TextXAlignment.Left
		Label.TextTruncate = Enum.TextTruncate.AtEnd
		Label.Parent = BoxFrame

		local TBox = Instance.new("TextBox")
		TBox.Size = UDim2.new(1, -16, 0, 16)
		TBox.Position = UDim2.new(0, 8, 0, 18)
		TBox.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
		TBox.BorderColor3 = Color3.fromRGB(50, 50, 50)
		TBox.BorderSizePixel = 1
		TBox.Text = ""
		TBox.PlaceholderText = placeholder
		TBox.PlaceholderColor3 = Color3.fromRGB(80, 80, 80)
		TBox.TextColor3 = Color3.fromRGB(255, 255, 255)
		TBox.Font = Enum.Font.Code
		TBox.TextSize = 11
		TBox.TextXAlignment = Enum.TextXAlignment.Left
		TBox.Parent = BoxFrame

		TBox.FocusLost:Connect(function(enter)
			callback(TBox.Text, enter)
		end)
	end

	return Window
end

return Library
