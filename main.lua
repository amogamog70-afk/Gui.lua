local Library = {}
local TextService = game:GetService("TextService")
local UserInputService = game:GetService("UserInputService")

-- Создание общего контейнера
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MinecraftPremiumUiLibrary"
ScreenGui.ResetOnSpawn = false

local success, coreGui = pcall(function() return game:GetService("CoreGui") end)
ScreenGui.Parent = success and coreGui or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

-- Глобальный бинд на скрытие (Right Shift)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and input.KeyCode == Enum.KeyCode.RightShift then
		ScreenGui.Enabled = not ScreenGui.Enabled
	end
end)

-- Вспомогательная функция для замера длины текста
local function GetTextWidth(text, fontSize, font)
	local size = TextService:GetTextSize(text, fontSize, font, Vector2.new(1000, 1000))
	return size.X
end

function Library:CreateWindow(titleText, defaultPosition)
	local Window = {}
	local isCollapsed = false
	
	local MIN_WIDTH = 180
	local currentWidth = MIN_WIDTH
	local HEADER_HEIGHT = 25

	-- Главный фрейм
	local MainFrame = Instance.new("Frame")
	MainFrame.Name = titleText .. "_Window"
	MainFrame.Size = UDim2.new(0, currentWidth, 0, HEADER_HEIGHT)
	MainFrame.Position = defaultPosition or UDim2.new(0, 50, 0, 50)
	MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
	MainFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
	MainFrame.BorderSizePixel = 2
	MainFrame.Active = true
	MainFrame.Parent = ScreenGui

	-- Функция динамического расширения ширины окна
	local function ensureWidth(requiredTextWidth)
		local padding = 45 -- Запас под рамки, отступы и стрелочки
		local totalNeeded = requiredTextWidth + padding
		if totalNeeded > currentWidth then
			currentWidth = totalNeeded
			MainFrame.Size = UDim2.new(0, currentWidth, 0, MainFrame.Size.Y.Offset)
		end
	end

	-- Шапка
	local TopBar = Instance.new("Frame")
	TopBar.Name = "TopBar"
	TopBar.Size = UDim2.new(1, 0, 0, HEADER_HEIGHT)
	TopBar.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
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
	ensureWidth(GetTextWidth(Title.Text, 12, Enum.Font.Code))

	-- Стрелочка
	local CollapseBtn = Instance.new("TextButton")
	CollapseBtn.Name = "CollapseBtn"
	CollapseBtn.Size = UDim2.new(0, 25, 0, 25)
	CollapseBtn.Position = UDim2.new(1, -25, 0, 0)
	CollapseBtn.BackgroundTransparency = 1
	CollapseBtn.Text = "▲"
	CollapseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	CollapseBtn.Font = Enum.Font.Code
	CollapseBtn.TextSize = 12
	CollapseBtn.Parent = TopBar

	-- Контейнер элементов
	local Container = Instance.new("Frame")
	Container.Name = "Container"
	Container.Size = UDim2.new(1, -12, 0, 0)
	Container.Position = UDim2.new(0, 6, 0, HEADER_HEIGHT + 6)
	Container.BackgroundTransparency = 1
	Container.Parent = MainFrame

	local UIListLayout = Instance.new("UIListLayout")
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout.Padding = UDim.new(0, 5)
	UIListLayout.Parent = Container

	-- Авто-высота под количество контента
	local function updateHeight()
		if not isCollapsed then
			MainFrame.Size = UDim2.new(0, currentWidth, 0, UIListLayout.AbsoluteContentSize.Y + HEADER_HEIGHT + 14)
		else
			MainFrame.Size = UDim2.new(0, currentWidth, 0, HEADER_HEIGHT)
		end
	end
	UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateHeight)

	CollapseBtn.MouseButton1Click:Connect(function()
		isCollapsed = not isCollapsed
		Container.Visible = not isCollapsed
		CollapseBtn.Text = isCollapsed and "▼" or "▲"
		updateHeight()
	end)

	-- Драггер (Перетаскивание)
	local dragging, dragInput, dragStart, startPos
	TopBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = MainFrame.Position
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
	-- КОМПОНЕНТ: КНОПКА (Button)
	-- ====================================================================
	function Window:CreateButton(buttonName, callback)
		ensureWidth(GetTextWidth("  " .. buttonName, 11, Enum.Font.Code))
		
		local Btn = Instance.new("TextButton")
		Btn.Size = UDim2.new(1, 0, 0, 24)
		Btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
		Btn.BorderColor3 = Color3.fromRGB(55, 55, 55)
		Btn.BorderSizePixel = 1
		Btn.Text = "  " .. buttonName
		Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
		Btn.Font = Enum.Font.Code
		Btn.TextSize = 11
		Btn.TextXAlignment = Enum.TextXAlignment.Left
		Btn.Parent = Container

		Btn.MouseButton1Click:Connect(callback)
		return Btn
	end

	-- ====================================================================
	-- КОМПОНЕНТ: ПЕРЕКЛЮЧАТЕЛЬ (Toggle)
	-- ====================================================================
	function Window:CreateToggle(toggleName, callback)
		ensureWidth(GetTextWidth("  " .. toggleName .. ": OFF", 11, Enum.Font.Code))

		local ToggleBtn = Instance.new("TextButton")
		ToggleBtn.Size = UDim2.new(1, 0, 0, 24)
		ToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
		ToggleBtn.BorderColor3 = Color3.fromRGB(55, 55, 55)
		ToggleBtn.BorderSizePixel = 1
		ToggleBtn.Text = "  " .. toggleName .. ": OFF"
		ToggleBtn.TextColor3 = Color3.fromRGB(140, 140, 140)
		ToggleBtn.Font = Enum.Font.Code
		ToggleBtn.TextSize = 11
		ToggleBtn.TextXAlignment = Enum.TextXAlignment.Left
		ToggleBtn.Parent = Container

		local enabled = false
		ToggleBtn.MouseButton1Click:Connect(function()
			enabled = not enabled
			if enabled then
				ToggleBtn.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
				ToggleBtn.BorderColor3 = Color3.fromRGB(255, 255, 255)
				ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
				ToggleBtn.Text = "  " .. toggleName .. ": ON"
			else
				ToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
				ToggleBtn.BorderColor3 = Color3.fromRGB(55, 55, 55)
				ToggleBtn.TextColor3 = Color3.fromRGB(140, 140, 140)
				ToggleBtn.Text = "  " .. toggleName .. ": OFF"
			end
			callback(enabled)
		end)
		return ToggleBtn
	end

	-- ====================================================================
	-- КОМПОНЕНТ: СЛАЙДЕР (Slider)
	-- ====================================================================
	function Window:CreateSlider(sliderName, min, max, default, callback)
		ensureWidth(GetTextWidth("  " .. sliderName .. ": " .. tostring(max) .. ".00", 11, Enum.Font.Code) + 20)

		local SliderFrame = Instance.new("Frame")
		SliderFrame.Size = UDim2.new(1, 0, 0, 34)
		SliderFrame.BackgroundTransparency = 1
		SliderFrame.Parent = Container

		local Label = Instance.new("TextLabel")
		Label.Size = UDim2.new(1, 0, 0, 16)
		Label.BackgroundTransparency = 1
		Label.Text = "  " .. sliderName .. ": " .. tostring(default)
		Label.TextColor3 = Color3.fromRGB(200, 200, 200)
		Label.Font = Enum.Font.Code
		Label.TextSize = 11
		Label.TextXAlignment = Enum.TextXAlignment.Left
		Label.Parent = SliderFrame

		local SliderBg = Instance.new("Frame")
		SliderBg.Size = UDim2.new(1, -4, 0, 8)
		SliderBg.Position = UDim2.new(0, 2, 0, 18)
		SliderBg.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
		SliderBg.BorderColor3 = Color3.fromRGB(60, 60, 60)
		SliderBg.BorderSizePixel = 1
		SliderBg.Parent = SliderFrame

		local SliderFill = Instance.new("Frame")
		local initPercent = math.clamp((default - min) / (max - min), 0, 1)
		SliderFill.Size = UDim2.new(initPercent, 0, 1, 0)
		SliderFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		SliderFill.BorderSizePixel = 0
		SliderFill.Parent = SliderBg

		local isSliding = false

		local function updateSlider(input)
			local bgPosX = SliderBg.AbsolutePosition.X
			local bgWidth = SliderBg.AbsoluteSize.X
			local percent = math.clamp((input.Position.X - bgPosX) / bgWidth, 0, 1)
			
			local val = min + (max - min) * percent
			val = math.round(val * 100) / 100 -- Округление до сотых
			
			SliderFill.Size = UDim2.new(percent, 0, 1, 0)
			Label.Text = "  " .. sliderName .. ": " .. tostring(val)
			callback(val)
		end

		SliderBg.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				isSliding = true
				updateSlider(input)
			end
		end)

		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				isSliding = false
			end
		end)

		UserInputService.InputChanged:Connect(function(input)
			if isSliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				updateSlider(input)
			end
		end)
	end

	-- ====================================================================
	-- КОМПОНЕНТ: ТЕКСТ БОКС (TextBox)
	-- ====================================================================
	function Window:CreateTextBox(boxName, placeholder, callback)
		ensureWidth(GetTextWidth("  " .. boxName .. ": " .. placeholder, 11, Enum.Font.Code) + 15)

		local BoxFrame = Instance.new("Frame")
		BoxFrame.Size = UDim2.new(1, 0, 0, 38)
		BoxFrame.BackgroundTransparency = 1
		BoxFrame.Parent = Container

		local Label = Instance.new("TextLabel")
		Label.Size = UDim2.new(1, 0, 0, 14)
		Label.BackgroundTransparency = 1
		Label.Text = "  " .. boxName
		Label.TextColor3 = Color3.fromRGB(160, 160, 160)
		Label.Font = Enum.Font.Code
		Label.TextSize = 10
		Label.TextXAlignment = Enum.TextXAlignment.Left
		Label.Parent = BoxFrame

		local TBox = Instance.new("TextBox")
		TBox.Size = UDim2.new(1, -4, 0, 20)
		TBox.Position = UDim2.new(0, 2, 0, 16)
		TBox.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
		TBox.BorderColor3 = Color3.fromRGB(60, 60, 60)
		TBox.BorderSizePixel = 1
		TBox.Text = ""
		TBox.PlaceholderText = placeholder
		TBox.PlaceholderColor3 = Color3.fromRGB(80, 80, 80)
		TBox.TextColor3 = Color3.fromRGB(255, 255, 255)
		TBox.Font = Enum.Font.Code
		TBox.TextSize = 11
		TBox.TextXAlignment = Enum.TextXAlignment.Left
		TBox.Parent = BoxFrame

		TBox.FocusLost:Connect(function(enterPressed)
			callback(TBox.Text, enterPressed)
		end)
	end

	-- ====================================================================
	-- КОМПОНЕНТ: ВЫБОР ЦВЕТА (ColorPicker)
	-- ====================================================================
	function Window:CreateColorPicker(pickerName, defaultColor, callback)
		ensureWidth(GetTextWidth("  " .. pickerName, 11, Enum.Font.Code) + 50)

		local PickerFrame = Instance.new("Frame")
		PickerFrame.Size = UDim2.new(1, 0, 0, 24)
		PickerFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
		PickerFrame.BorderColor3 = Color3.fromRGB(55, 55, 55)
		PickerFrame.BorderSizePixel = 1
		PickerFrame.ClipsDescendants = true
		PickerFrame.Parent = Container

		local MainBtn = Instance.new("TextButton")
		MainBtn.Size = UDim2.new(1, 0, 0, 24)
		MainBtn.BackgroundTransparency = 1
		MainBtn.Text = "  " .. pickerName
		MainBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
		MainBtn.Font = Enum.Font.Code
		MainBtn.TextSize = 11
		MainBtn.TextXAlignment = Enum.TextXAlignment.Left
		MainBtn.Parent = PickerFrame

		-- Квадратик текущего цвета справа
		local ColorIndicator = Instance.new("Frame")
		ColorIndicator.Size = UDim2.new(0, 14, 0, 14)
		ColorIndicator.Position = UDim2.new(1, -20, 0, 5)
		ColorIndicator.BackgroundColor3 = defaultColor
		ColorIndicator.BorderColor3 = Color3.fromRGB(255, 255, 255)
		ColorIndicator.BorderSizePixel = 1
		ColorIndicator.Parent = MainBtn

		-- Контейнер под RGB ползунки
		local RGBSubFrame = Instance.new("Frame")
		RGBSubFrame.Size = UDim2.new(1, -10, 0, 65)
		RGBSubFrame.Position = UDim2.new(0, 5, 0, 26)
		RGBSubFrame.BackgroundTransparency = 1
		RGBSubFrame.Parent = PickerFrame

		local curR, curG, curB = math.round(defaultColor.R*255), math.round(defaultColor.G*255), math.round(defaultColor.B*255)
		local pickerOpen = false

		local function updateColor()
			local newColor = Color3.fromRGB(curR, curG, curB)
			ColorIndicator.BackgroundColor3 = newColor
			callback(newColor)
		end

		-- Внутренняя функция для быстрого создания мини-ползунков RGB
		local function createMiniSlider(labelTag, defaultVal, orderY, colorChannelCallback)
			local subSlider = Instance.new("Frame")
			subSlider.Size = UDim2.new(1, 0, 0, 18)
			subSlider.Position = UDim2.new(0, 0, 0, orderY)
			subSlider.BackgroundTransparency = 1
			subSlider.Parent = RGBSubFrame

			local l = Instance.new("TextLabel")
			l.Size = UDim2.new(0, 15, 1, 0)
			l.BackgroundTransparency = 1
			l.Text = labelTag
			l.TextColor3 = Color3.fromRGB(255, 255, 255)
			l.Font = Enum.Font.Code
			l.TextSize = 10
			l.Parent = subSlider

			local bar = Instance.new("Frame")
			bar.Size = UDim2.new(1, -20, 0, 6)
			bar.Position = UDim2.new(0, 18, 0, 6)
			bar.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
			bar.BorderColor3 = Color3.fromRGB(50, 50, 50)
			bar.Parent = subSlider

			local fill = Instance.new("Frame")
			fill.Size = UDim2.new(defaultVal / 255, 0, 1, 0)
			fill.BackgroundColor3 = Color3.fromRGB(180, 180, 180)
			fill.BorderSizePixel = 0
			fill.Parent = bar

			local sliding = false
			local function track(input)
				local pct = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
				fill.Size = UDim2.new(pct, 0, 1, 0)
				colorChannelCallback(math.round(pct * 255))
			end

			bar.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					sliding = true; track(input)
				end
			end)
			UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sliding = false end
			end)
			UserInputService.InputChanged:Connect(function(input)
				if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then track(input) end
			end)
		end

		createMiniSlider("R", curR, 0, function(v) curR = v; updateColor() end)
		createMiniSlider("G", curG, 20, function(v) curG = v; updateColor() end)
		createMiniSlider("B", curB, 40, function(v) curB = v; updateColor() end)

		-- Логика раскрытия панели цвета
		MainBtn.MouseButton1Click:Connect(function()
			pickerOpen = not pickerOpen
			if pickerOpen then
				PickerFrame.Size = UDim2.new(1, 0, 0, 95)
				PickerFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
			else
				PickerFrame.Size = UDim2.new(1, 0, 0, 24)
				PickerFrame.BorderColor3 = Color3.fromRGB(55, 55, 55)
			end
			-- Форсируем обновление UIListLayout родителя
			Container.Size = UDim2.new(1, -12, 0, UIListLayout.AbsoluteContentSize.Y)
		end)
	end

	return Window
end

return Library
