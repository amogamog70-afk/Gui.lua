local Library = {}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- Создание корневого контейнера
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MinecraftPremiumV2"
ScreenGui.ResetOnSpawn = false

local success, coreGui = pcall(function() return game:GetService("CoreGui") end)
ScreenGui.Parent = success and coreGui or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

-- Закрытие/открытие всего софта на ПРАВЫЙ ШИФТ
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and input.KeyCode == Enum.KeyCode.RightShift then
		ScreenGui.Enabled = not ScreenGui.Enabled
	end
end)

function Library:CreateWindow(titleText, defaultPosition)
	local Window = {}
	local isCollapsed = false
	
	-- СТРОГО ФИКСИРОВАННАЯ ШИРИНА ОКНА (Как в топовых читах)
	local WINDOW_WIDTH = 190
	local HEADER_HEIGHT = 26

	-- Основной невидимый фрейм-контейнер (удерживает шапку и выпадающий список)
	local MainFrame = Instance.new("Frame")
	MainFrame.Name = titleText .. "_Window"
	MainFrame.Size = UDim2.new(0, WINDOW_WIDTH, 0, HEADER_HEIGHT)
	MainFrame.Position = defaultPosition or UDim2.new(0, 50, 0, 50)
	MainFrame.BackgroundTransparency = 1
	MainFrame.Active = true
	MainFrame.Parent = ScreenGui

	-- Статичная ШАПКА ВКЛАДКИ (Ее размер НИКОГДА не меняется по ширине)
	local TopBar = Instance.new("Frame")
	TopBar.Name = "TopBar"
	TopBar.Size = UDim2.new(1, 0, 0, HEADER_HEIGHT)
	TopBar.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
	TopBar.BorderColor3 = Color3.fromRGB(255, 255, 255)
	TopBar.BorderSizePixel = 1
	TopBar.Parent = MainFrame

	local Title = Instance.new("TextLabel")
	Title.Name = "Title"
	Title.Size = UDim2.new(1, -30, 1, 0)
	Title.Position = UDim2.new(0, 8, 0, 0)
	Title.BackgroundTransparency = 1
	Title.Text = string.upper(titleText)
	Title.TextColor3 = Color3.fromRGB(255, 255, 255)
	Title.Font = Enum.Font.Code
	Title.TextSize = 12
	Title.TextXAlignment = Enum.TextXAlignment.Left
	Title.Parent = TopBar

	local CollapseBtn = Instance.new("TextButton")
	CollapseBtn.Name = "CollapseBtn"
	CollapseBtn.Size = UDim2.new(0, 25, 0, HEADER_HEIGHT)
	CollapseBtn.Position = UDim2.new(1, -25, 0, 0)
	CollapseBtn.BackgroundTransparency = 1
	CollapseBtn.Text = "▲"
	CollapseBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
	CollapseBtn.Font = Enum.Font.Code
	CollapseBtn.TextSize = 11
	CollapseBtn.Parent = TopBar

	-- ДИНАМИЧЕСКИЙ КОНТЕЙНЕР ДЛЯ ФУНКЦИЙ (Вот он меняет размер и подстраивается под кнопки)
	local Container = Instance.new("Frame")
	Container.Name = "Container"
	Container.Size = UDim2.new(1, 0, 0, 0)
	Container.Position = UDim2.new(0, 0, 0, HEADER_HEIGHT + 2)
	Container.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
	Container.BorderColor3 = Color3.fromRGB(40, 40, 40)
	Container.BorderSizePixel = 1
	Container.ClipsDescendants = true
	Container.Parent = MainFrame

	local UIListLayout = Instance.new("UIListLayout")
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout.Padding = UDim.new(0, 1) -- Плотное расположение в стиле MC
	UIListLayout.Parent = Container

	-- Подстройка высоты контейнера под его содержимое на лету
	local function updateHeight()
		if not isCollapsed then
			Container.Size = UDim2.new(1, 0, 0, UIListLayout.AbsoluteContentSize.Y)
			MainFrame.Size = UDim2.new(0, WINDOW_WIDTH, 0, HEADER_HEIGHT + Container.Size.Y.Offset + 5)
		else
			Container.Size = UDim2.new(1, 0, 0, 0)
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

	-- Логика плавного перетаскивания (За шапку)
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
	game:GetService("UserInputService").InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)

	-- ====================================================================
	-- ЭЛЕМЕНТ: ОБЫЧНАЯ КНОПКА (Button)
	-- ====================================================================
	function Window:CreateButton(name, callback)
		local Btn = Instance.new("TextButton")
		Btn.Size = UDim2.new(1, 0, 0, 26)
		Btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
		Btn.BorderSizePixel = 0
		Btn.Text = "  " .. name
		Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
		Btn.Font = Enum.Font.Code
		Btn.TextSize = 11
		Btn.TextXAlignment = Enum.TextXAlignment.Left
		Btn.Parent = Container

		Btn.MouseEnter:Connect(function() Btn.BackgroundColor3 = Color3.fromRGB(26, 26, 26) end)
		Btn.MouseLeave:Connect(function() Btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20) end)
		Btn.MouseButton1Click:Connect(callback)
		return Btn
	end

	-- ====================================================================
	-- ЭЛЕМЕНТ: ПЕРЕКЛЮЧАТЕЛЬ (Toggle)
	-- ====================================================================
	function Window:CreateToggle(name, callback)
		local ToggleBtn = Instance.new("TextButton")
		ToggleBtn.Size = UDim2.new(1, 0, 0, 26)
		ToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
		ToggleBtn.BorderSizePixel = 0
		ToggleBtn.Text = "  " .. name
		ToggleBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
		ToggleBtn.Font = Enum.Font.Code
		ToggleBtn.TextSize = 11
		ToggleBtn.TextXAlignment = Enum.TextXAlignment.Left
		ToggleBtn.Parent = Container

		-- Маленький пиксельный индикатор состояния справа [ ]
		local Indicator = Instance.new("TextLabel")
		Indicator.Size = UDim2.new(0, 35, 1, 0)
		Indicator.Position = UDim2.new(1, -35, 0, 0)
		Indicator.BackgroundTransparency = 1
		Indicator.Text = "[-] "
		Indicator.TextColor3 = Color3.fromRGB(100, 100, 100)
		Indicator.Font = Enum.Font.Code
		Indicator.TextSize = 11
		Indicator.TextXAlignment = Enum.TextXAlignment.Right
		Indicator.Parent = ToggleBtn

		local enabled = false
		ToggleBtn.MouseButton1Click:Connect(function()
			enabled = not enabled
			if enabled then
				ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
				Indicator.Text = "[+] "
				Indicator.TextColor3 = Color3.fromRGB(255, 255, 255)
			else
				ToggleBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
				Indicator.Text = "[-] "
				Indicator.TextColor3 = Color3.fromRGB(100, 100, 100)
			end
			callback(enabled)
		end)
		return ToggleBtn
	end

	-- ====================================================================
	-- ЭЛЕМЕНТ: СЛАЙДЕР (Slider)
	-- ====================================================================
	function Window:CreateSlider(name, min, max, default, callback)
		local SliderFrame = Instance.new("Frame")
		SliderFrame.Size = UDim2.new(1, 0, 0, 32)
		SliderFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
		SliderFrame.BorderSizePixel = 0
		SliderFrame.Parent = Container

		local Label = Instance.new("TextLabel")
		Label.Size = UDim2.new(1, -10, 0, 18)
		Label.Position = UDim2.new(0, 8, 0, 0)
		Label.BackgroundTransparency = 1
		Label.Text = name .. " » " .. tostring(default)
		Label.TextColor3 = Color3.fromRGB(180, 180, 180)
		Label.Font = Enum.Font.Code
		Label.TextSize = 11
		Label.TextXAlignment = Enum.TextXAlignment.Left
		Label.Parent = SliderFrame

		local Track = Instance.new("Frame")
		Track.Size = UDim2.new(1, -16, 0, 4)
		Track.Position = UDim2.new(0, 8, 0, 20)
		Track.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
		Track.BorderSizePixel = 0
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
			val = math.round(val * 10) / 10
			Fill.Size = UDim2.new(pct, 0, 1, 0)
			Label.Text = name .. " » " .. tostring(val)
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
	-- ЭЛЕМЕНТ: ТЕКСТБОКС (TextBox)
	-- ====================================================================
	function Window:CreateTextBox(name, placeholder, callback)
		local BoxFrame = Instance.new("Frame")
		BoxFrame.Size = UDim2.new(1, 0, 0, 34)
		BoxFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
		BoxFrame.BorderSizePixel = 0
		BoxFrame.Parent = Container

		local Label = Instance.new("TextLabel")
		Label.Size = UDim2.new(0, 60, 1, 0)
		Label.Position = UDim2.new(0, 8, 0, 0)
		Label.BackgroundTransparency = 1
		Label.Text = name .. ":"
		Label.TextColor3 = Color3.fromRGB(130, 130, 130)
		Label.Font = Enum.Font.Code
		Label.TextSize = 11
		Label.TextXAlignment = Enum.TextXAlignment.Left
		Label.Parent = BoxFrame

		local TBox = Instance.new("TextBox")
		TBox.Size = UDim2.new(1, -75, 0, 18)
		TBox.Position = UDim2.new(0, 68, 0, 8)
		TBox.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
		TBox.BorderColor3 = Color3.fromRGB(40, 40, 40)
		TBox.BorderSizePixel = 1
		TBox.Text = ""
		TBox.PlaceholderText = placeholder
		TBox.PlaceholderColor3 = Color3.fromRGB(60, 60, 60)
		TBox.TextColor3 = Color3.fromRGB(255, 255, 255)
		TBox.Font = Enum.Font.Code
		TBox.TextSize = 11
		TBox.Parent = BoxFrame

		TBox.FocusLost:Connect(function(enter)
			callback(TBox.Text, enter)
		end)
	end

	-- ====================================================================
	-- УЛЬТРАСОВРЕМЕННЫЙ HSV КОЛОРПИКЕР (Rainbow Hue + Brightness)
	-- ====================================================================
	function Window:CreateColorPicker(name, defaultColor, callback)
		local PickerFrame = Instance.new("Frame")
		PickerFrame.Size = UDim2.new(1, 0, 0, 26) -- Начальная высота
		PickerFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
		PickerFrame.BorderSizePixel = 0
		PickerFrame.ClipsDescendants = true
		PickerFrame.Parent = Container

		local TriggerBtn = Instance.new("TextButton")
		TriggerBtn.Size = UDim2.new(1, 0, 0, 26)
		TriggerBtn.BackgroundTransparency = 1
		TriggerBtn.Text = "  " .. name
		TriggerBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
		TriggerBtn.Font = Enum.Font.Code
		TriggerBtn.TextSize = 11
		TriggerBtn.TextXAlignment = Enum.TextXAlignment.Left
		TriggerBtn.Parent = PickerFrame

		-- Квадрат предпросмотра цвета
		local Preview = Instance.new("Frame")
		Preview.Size = UDim2.new(0, 12, 0, 12)
		Preview.Position = UDim2.new(1, -22, 0, 7)
		Preview.BackgroundColor3 = defaultColor
		Preview.BorderColor3 = Color3.fromRGB(255, 255, 255)
		Preview.BorderSizePixel = 1
		Preview.Parent = TriggerBtn

		-- Скрытая панель с ползунками (выпадает вниз, раздвигая ВСЁ под окном)
		local Dropdown = Instance.new("Frame")
		Dropdown.Size = UDim2.new(1, -16, 0, 40)
		Dropdown.Position = UDim2.new(0, 8, 0, 28)
		Dropdown.BackgroundTransparency = 1
		Dropdown.Parent = PickerFrame

		-- 1. Слайдер Радуги (HUE)
		local HueBar = Instance.new("Frame")
		HueBar.Size = UDim2.new(1, 0, 0, 12)
		HueBar.Position = UDim2.new(0, 0, 0, 2)
		HueBar.BorderSizePixel = 0
		HueBar.Parent = Dropdown

		local HueGrad = Instance.new("UIGradient")
		HueGrad.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
			ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
			ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
			ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
			ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
		})
		HueGrad.Parent = HueBar

		-- 2. Слайдер Яркости (Value)
		local ValBar = Instance.new("Frame")
		ValBar.Size = UDim2.new(1, 0, 0, 12)
		ValBar.Position = UDim2.new(0, 0, 0, 18)
		ValBar.BorderSizePixel = 0
		ValBar.Parent = Dropdown

		local ValGrad = Instance.new("UIGradient")
		ValGrad.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(0, 0, 0))
		ValGrad.Parent = ValBar

		-- Переменные HSV лоада
		local currentH, currentS, currentV = defaultColor:ToHSV()
		local isOpen = false

		local function updateColor()
			local computedColor = Color3.fromHSV(currentH, 1, currentV)
			Preview.BackgroundColor3 = computedColor
			callback(computedColor)
		end

		-- Логика движения по радуге
		local hueSliding = false
		HueBar.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then hueSliding = true
				currentH = math.clamp((input.Position.X - HueBar.AbsolutePosition.X) / HueBar.AbsoluteSize.X, 0, 1)
				updateColor()
			end
		end)
		-- Логика движения по яркости
		local valSliding = false
		ValBar.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then valSliding = true
				currentV = 1 - math.clamp((input.Position.X - ValBar.AbsolutePosition.X) / ValBar.AbsoluteSize.X, 0, 1)
				updateColor()
			end
		end)

		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then hueSliding = false; valSliding = false end
		end)

		UserInputService.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement then
				if hueSliding then
					currentH = math.clamp((input.Position.X - HueBar.AbsolutePosition.X) / HueBar.AbsoluteSize.X, 0, 1)
					updateColor()
				elseif valSliding then
					currentV = 1 - math.clamp((input.Position.X - ValBar.AbsolutePosition.X) / ValBar.AbsoluteSize.X, 0, 1)
					updateColor()
				end
			end
		end)

		-- Открытие/Закрытие колорпикера (Раздвигает контейнер вертикально вниз)
		TriggerBtn.MouseButton1Click:Connect(function()
			isOpen = not isOpen
			PickerFrame.Size = UDim2.new(1, 0, 0, isOpen and 74 or 26)
			-- Принудительно заставляем список обновить высоты под этой вкладкой
			Container.Size = UDim2.new(1, 0, 0, UIListLayout.AbsoluteContentSize.Y)
		end)
	end

	return Window
end

return Library
