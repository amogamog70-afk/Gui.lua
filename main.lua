local Library = {}

-- Создание общего контейнера для всех окон
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MinecraftUiLibrary"
ScreenGui.ResetOnSpawn = false

-- Авто-определение: если запуск через чит — идет в CoreGui, если тест в Студии — в PlayerGui
local success, coreGui = pcall(function() return game:GetService("CoreGui") end)
ScreenGui.Parent = success and coreGui or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

-- Скрытие ВСЕХ окон библиотеки по нажатию на Правый Shift
game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and input.KeyCode == Enum.KeyCode.RightShift then
		ScreenGui.Enabled = not ScreenGui.Enabled
	end
end)

-- Функция создания Окна (Категории)
function Library:CreateWindow(titleText, defaultPosition)
	local Window = {}
	local isCollapsed = false
	local FRAME_WIDTH = 170
	local HEADER_HEIGHT = 25

	-- Главный фрейм окна
	local MainFrame = Instance.new("Frame")
	MainFrame.Name = titleText .. "_Window"
	MainFrame.Size = UDim2.new(0, FRAME_WIDTH, 0, HEADER_HEIGHT)
	MainFrame.Position = defaultPosition or UDim2.new(0, 50, 0, 50)
	MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	MainFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
	MainFrame.BorderSizePixel = 2
	MainFrame.Active = true
	MainFrame.Parent = ScreenGui

	-- Шапка окна
	local TopBar = Instance.new("Frame")
	TopBar.Name = "TopBar"
	TopBar.Size = UDim2.new(1, 0, 0, HEADER_HEIGHT)
	TopBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	TopBar.BorderColor3 = Color3.fromRGB(255, 255, 255)
	TopBar.BorderSizePixel = 1
	TopBar.Parent = MainFrame

	-- Текст заголовка
	local Title = Instance.new("TextLabel")
	Title.Name = "Title"
	Title.Size = UDim2.new(1, -30, 1, 0)
	Title.Position = UDim2.new(0, 8, 0, 0)
	Title.BackgroundTransparency = 1
	Title.Text = string.upper(titleText) -- Всегда капсом, как в старых читах
	Title.TextColor3 = Color3.fromRGB(255, 255, 255)
	Title.Font = Enum.Font.Code
	Title.TextSize = 12
	Title.TextXAlignment = Enum.TextXAlignment.Left
	Title.Parent = TopBar

	-- Стрелочка свернуть/развернуть
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

	-- Контейнер для элементов внутри окна
	local Container = Instance.new("Frame")
	Container.Name = "Container"
	Container.Size = UDim2.new(1, -12, 0, 0)
	Container.Position = UDim2.new(0, 6, 0, HEADER_HEIGHT + 6)
	Container.BackgroundTransparency = 1
	Container.Parent = MainFrame

	-- Авто-выравнивание элементов (вертикальный список)
	local UIListLayout = Instance.new("UIListLayout")
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout.Padding = UDim.new(0, 4)
	UIListLayout.Parent = Container

	-- Динамическое изменение размера окна под количество кнопок
	local function updateSize()
		if not isCollapsed then
			MainFrame.Size = UDim2.new(0, FRAME_WIDTH, 0, UIListLayout.AbsoluteContentSize.Y + HEADER_HEIGHT + 12)
		else
			MainFrame.Size = UDim2.new(0, FRAME_WIDTH, 0, HEADER_HEIGHT)
		end
	end
	UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateSize)

	-- Логика стрелочки
	CollapseBtn.MouseButton1Click:Connect(function()
		isCollapsed = not isCollapsed
		Container.Visible = not isCollapsed
		CollapseBtn.Text = isCollapsed and "▼" or "▲"
		updateSize()
	end)

	-- Скрипт перетаскивания окна мышкой
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
	game:GetService("UserInputService").InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)

	-- МЕТОД: Создание переключателя (Toggle)
	function Window:CreateToggle(toggleName, callback)
		local ToggleBtn = Instance.new("TextButton")
		ToggleBtn.Size = UDim2.new(1, 0, 0, 24)
		ToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
		ToggleBtn.BorderColor3 = Color3.fromRGB(60, 60, 60)
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
				ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
				ToggleBtn.BorderColor3 = Color3.fromRGB(255, 255, 255)
				ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
				ToggleBtn.Text = "  " .. toggleName .. ": ON"
			else
				ToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
				ToggleBtn.BorderColor3 = Color3.fromRGB(60, 60, 60)
				ToggleBtn.TextColor3 = Color3.fromRGB(140, 140, 140)
				ToggleBtn.Text = "  " .. toggleName .. ": OFF"
			end
			callback(enabled)
		end)
	end

	-- МЕТОД: Создание обычной кнопки (Button)
	function Window:CreateButton(buttonName, callback)
		local Btn = Instance.new("TextButton")
		Btn.Size = UDim2.new(1, 0, 0, 24)
		Btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
		Btn.BorderColor3 = Color3.fromRGB(60, 60, 60)
		Btn.BorderSizePixel = 1
		Btn.Text = "  " .. buttonName
		Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
		Btn.Font = Enum.Font.Code
		Btn.TextSize = 11
		Btn.TextXAlignment = Enum.TextXAlignment.Left
		Btn.Parent = Container

		Btn.MouseButton1Click:Connect(callback)
	end

	return Window
end

return Library
