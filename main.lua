local Library = {}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MinecraftStrictUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true

local success, coreGui = pcall(function() return game:GetService("CoreGui") end)
ScreenGui.Parent = success and coreGui or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

-- Глобальный toggle-key библиотеки (можно переопределить через Library.ToggleKey)
Library.ToggleKey = Enum.KeyCode.RightShift

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and input.KeyCode == Library.ToggleKey then
		ScreenGui.Enabled = not ScreenGui.Enabled
	end
end)

-- ========================================================================
-- NOTIFICATIONS (всплывающие уведомления в углу экрана)
-- ========================================================================
local NotifHolder = Instance.new("Frame")
NotifHolder.Name = "Notifications"
NotifHolder.AnchorPoint = Vector2.new(1, 1)
NotifHolder.Position = UDim2.new(1, -10, 1, -10)
NotifHolder.Size = UDim2.new(0, 220, 1, -20)
NotifHolder.BackgroundTransparency = 1
NotifHolder.Parent = ScreenGui

local NotifList = Instance.new("UIListLayout")
NotifList.SortOrder = Enum.SortOrder.LayoutOrder
NotifList.VerticalAlignment = Enum.VerticalAlignment.Bottom
NotifList.Padding = UDim.new(0, 4)
NotifList.Parent = NotifHolder

function Library:Notify(text, duration)
	duration = duration or 3

	local Notif = Instance.new("Frame")
	Notif.Size = UDim2.new(1, 0, 0, 36)
	Notif.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	Notif.BorderColor3 = Color3.fromRGB(255, 255, 255)
	Notif.BorderSizePixel = 1
	Notif.BackgroundTransparency = 1
	Notif.Parent = NotifHolder

	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(1, -12, 1, 0)
	Label.Position = UDim2.new(0, 6, 0, 0)
	Label.BackgroundTransparency = 1
	Label.Text = text
	Label.TextColor3 = Color3.fromRGB(255, 255, 255)
	Label.Font = Enum.Font.Code
	Label.TextSize = 12
	Label.TextWrapped = true
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.TextTransparency = 1
	Label.Parent = Notif

	TweenService:Create(Notif, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
	TweenService:Create(Label, TweenInfo.new(0.2), {TextTransparency = 0}):Play()

	task.delay(duration, function()
		local fadeOut = TweenService:Create(Notif, TweenInfo.new(0.25), {BackgroundTransparency = 1})
		TweenService:Create(Label, TweenInfo.new(0.25), {TextTransparency = 1}):Play()
		fadeOut:Play()
		fadeOut.Completed:Wait()
		Notif:Destroy()
	end)
end

-- ========================================================================
-- WATERMARK (плашка с названием/статусом в углу экрана)
-- ========================================================================
function Library:CreateWatermark(initialText)
	local Watermark = Instance.new("TextLabel")
	Watermark.Name = "Watermark"
	Watermark.Size = UDim2.new(0, 200, 0, 20)
	Watermark.Position = UDim2.new(0, 6, 0, 6)
	Watermark.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	Watermark.BorderColor3 = Color3.fromRGB(255, 255, 255)
	Watermark.BorderSizePixel = 1
	Watermark.Text = "  " .. (initialText or "")
	Watermark.TextColor3 = Color3.fromRGB(255, 255, 255)
	Watermark.Font = Enum.Font.Code
	Watermark.TextSize = 12
	Watermark.TextXAlignment = Enum.TextXAlignment.Left
	Watermark.Parent = ScreenGui

	return {
		SetText = function(_, newText)
			Watermark.Text = "  " .. newText
		end,
		Destroy = function()
			Watermark:Destroy()
		end
	}
end

-- ========================================================================
-- CONFIG SAVE / LOAD (writefile / readfile, если доступны экзекьютору)
-- ========================================================================
local ConfigFolder = "MinecraftStrictUI_Configs"
local flags = {} -- flagName -> {get = fn, set = fn}

local function ensureFolder()
	if writefile and isfolder and makefolder then
		if not isfolder(ConfigFolder) then
			makefolder(ConfigFolder)
		end
	end
end

function Library:SaveConfig(name)
	if not writefile then
		Library:Notify("Executor не поддерживает writefile", 3)
		return false
	end
	ensureFolder()
	local data = {}
	for flagName, entry in pairs(flags) do
		data[flagName] = entry.get()
	end
	local ok, encoded = pcall(function() return game:GetService("HttpService"):JSONEncode(data) end)
	if ok then
		writefile(ConfigFolder .. "/" .. name .. ".json", encoded)
		Library:Notify("Конфиг сохранён: " .. name, 2)
		return true
	end
	return false
end

function Library:LoadConfig(name)
	if not readfile or not isfile then
		Library:Notify("Executor не поддерживает readfile", 3)
		return false
	end
	local path = ConfigFolder .. "/" .. name .. ".json"
	if not isfile(path) then
		Library:Notify("Конфиг не найден: " .. name, 2)
		return false
	end
	local ok, decoded = pcall(function()
		return game:GetService("HttpService"):JSONDecode(readfile(path))
	end)
	if ok then
		for flagName, value in pairs(decoded) do
			if flags[flagName] then
				flags[flagName].set(value)
			end
		end
		Library:Notify("Конфиг загружен: " .. name, 2)
		return true
	end
	return false
end

-- ========================================================================
-- WINDOW
-- ========================================================================
function Library:CreateWindow(titleText, defaultPosition)
	local Window = {}
	local isCollapsed = false

	local WINDOW_WIDTH = 230
	local HEADER_HEIGHT = 24
	local MAX_CONTENT_HEIGHT = 320 -- лимит, после которого включается скролл

	local MainFrame = Instance.new("Frame")
	MainFrame.Name = titleText .. "_Window"
	MainFrame.Size = UDim2.new(0, WINDOW_WIDTH, 0, HEADER_HEIGHT)
	MainFrame.Position = defaultPosition or UDim2.new(0, 50, 0, 50)
	MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	MainFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
	MainFrame.BorderSizePixel = 2
	MainFrame.Active = true
	MainFrame.Parent = ScreenGui

	local TopBar = Instance.new("Frame")
	TopBar.Name = "TopBar"
	TopBar.Size = UDim2.new(1, 0, 0, HEADER_HEIGHT)
	TopBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	TopBar.BorderSizePixel = 0
	TopBar.Parent = MainFrame

	local Separator = Instance.new("Frame")
	Separator.Size = UDim2.new(1, 0, 0, 1)
	Separator.Position = UDim2.new(0, 0, 1, 0)
	Separator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Separator.BorderSizePixel = 0
	Separator.Parent = TopBar

	local Title = Instance.new("TextLabel")
	Title.Name = "Title"
	Title.Size = UDim2.new(1, 0, 1, 0)
	Title.BackgroundTransparency = 1
	Title.Text = string.upper(titleText)
	Title.TextColor3 = Color3.fromRGB(255, 255, 255)
	Title.Font = Enum.Font.Code
	Title.TextSize = 13
	Title.TextXAlignment = Enum.TextXAlignment.Center
	Title.ZIndex = 1
	Title.Parent = TopBar

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

	-- Контейнер теперь ScrollingFrame — не вылезает за экран при большом кол-ве элементов
	local Container = Instance.new("ScrollingFrame")
	Container.Name = "Container"
	Container.Size = UDim2.new(1, -8, 0, 0)
	Container.Position = UDim2.new(0, 4, 0, HEADER_HEIGHT + 5)
	Container.BackgroundTransparency = 1
	Container.BorderSizePixel = 0
	Container.ClipsDescendants = true
	Container.ScrollBarThickness = 3
	Container.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
	Container.CanvasSize = UDim2.new(0, 0, 0, 0)
	Container.AutomaticCanvasSize = Enum.AutomaticSize.Y
	Container.Parent = MainFrame

	local UIListLayout = Instance.new("UIListLayout")
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout.Padding = UDim.new(0, 3)
	UIListLayout.Parent = Container

	local function updateHeight()
		if not isCollapsed then
			local contentHeight = UIListLayout.AbsoluteContentSize.Y
			local shownHeight = math.min(contentHeight, MAX_CONTENT_HEIGHT)
			Container.Size = UDim2.new(1, -8, 0, shownHeight)
			MainFrame.Size = UDim2.new(0, WINDOW_WIDTH, 0, HEADER_HEIGHT + shownHeight + 10)
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
	-- SECTION / DIVIDER (заголовок-разделитель внутри окна)
	-- ====================================================================
	function Window:CreateSection(name)
		local SectionFrame = Instance.new("Frame")
		SectionFrame.Size = UDim2.new(1, 0, 0, 18)
		SectionFrame.BackgroundTransparency = 1
		SectionFrame.Parent = Container

		local Line1 = Instance.new("Frame")
		Line1.Size = UDim2.new(0, 6, 0, 1)
		Line1.Position = UDim2.new(0, 0, 0.5, 0)
		Line1.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
		Line1.BorderSizePixel = 0
		Line1.Parent = SectionFrame

		local Label = Instance.new("TextLabel")
		Label.Size = UDim2.new(1, -70, 1, 0)
		Label.Position = UDim2.new(0, 10, 0, 0)
		Label.BackgroundTransparency = 1
		Label.Text = string.upper(name)
		Label.TextColor3 = Color3.fromRGB(140, 140, 140)
		Label.Font = Enum.Font.Code
		Label.TextSize = 11
		Label.TextXAlignment = Enum.TextXAlignment.Left
		Label.Parent = SectionFrame

		return SectionFrame
	end

	-- ====================================================================
	-- LABEL (статичный текст, например для вывода FPS / статуса)
	-- ====================================================================
	function Window:CreateLabel(text)
		local Label = Instance.new("TextLabel")
		Label.Size = UDim2.new(1, 0, 0, 18)
		Label.BackgroundTransparency = 1
		Label.Text = "  " .. text
		Label.TextColor3 = Color3.fromRGB(160, 160, 160)
		Label.Font = Enum.Font.Code
		Label.TextSize = 12
		Label.TextXAlignment = Enum.TextXAlignment.Left
		Label.TextTruncate = Enum.TextTruncate.AtEnd
		Label.Parent = Container

		return {
			SetText = function(_, newText)
				Label.Text = "  " .. newText
			end
		}
	end

	-- ====================================================================
	-- ОБЫЧНАЯ КНОПКА
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
		Btn.TextTruncate = Enum.TextTruncate.AtEnd
		Btn.Parent = Container

		Btn.MouseButton1Click:Connect(callback)
		return Btn
	end

	-- ====================================================================
	-- ПЕРЕКЛЮЧАТЕЛЬ (с опциональным flagName для config save/load)
	-- ====================================================================
	function Window:CreateToggle(name, callback, flagName)
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
		local function setEnabled(value, skipCallback)
			enabled = value
			if enabled then
				ToggleBtn.Text = "  " .. name .. ": ON"
				ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
			else
				ToggleBtn.Text = "  " .. name .. ": OFF"
				ToggleBtn.TextColor3 = Color3.fromRGB(130, 130, 130)
			end
			if not skipCallback then
				callback(enabled)
			end
		end

		ToggleBtn.MouseButton1Click:Connect(function()
			setEnabled(not enabled)
		end)

		if flagName then
			flags[flagName] = {
				get = function() return enabled end,
				set = function(value) setEnabled(value) end
			}
		end

		return ToggleBtn
	end

	-- ====================================================================
	-- СЛАЙДЕР (с опциональным flagName)
	-- ====================================================================
	function Window:CreateSlider(name, min, max, default, callback, flagName)
		local SliderFrame = Instance.new("Frame")
		SliderFrame.Size = UDim2.new(1, 0, 0, 36)
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

		local currentVal = default
		local sliding = false

		local function setValue(val, skipCallback)
			val = math.clamp(math.round(val), min, max)
			currentVal = val
			local pct = (val - min) / (max - min)
			Fill.Size = UDim2.new(pct, 0, 1, 0)
			Label.Text = name .. ": " .. tostring(val)
			if not skipCallback then
				callback(val)
			end
		end

		local function updateFromInput(input)
			local pct = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
			setValue(min + (max - min) * pct)
		end

		local inputEndedConn
		SliderFrame.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				sliding = true
				updateFromInput(input)
				if not inputEndedConn then
					inputEndedConn = UserInputService.InputEnded:Connect(function(endInput)
						if endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType == Enum.UserInputType.Touch then
							sliding = false
						end
					end)
				end
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				updateFromInput(input)
			end
		end)

		if flagName then
			flags[flagName] = {
				get = function() return currentVal end,
				set = function(value) setValue(value, false) end
			}
		end

		return { SetValue = setValue }
	end

	-- ====================================================================
	-- ТЕКСТБОКС
	-- ====================================================================
	function Window:CreateTextBox(name, placeholder, callback, flagName)
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

		if flagName then
			flags[flagName] = {
				get = function() return TBox.Text end,
				set = function(value) TBox.Text = value; callback(value, false) end
			}
		end
	end

	-- ====================================================================
	-- DROPDOWN (выбор одного значения из списка)
	-- ====================================================================
	function Window:CreateDropdown(name, options, default, callback, flagName)
		local DropFrame = Instance.new("Frame")
		DropFrame.Size = UDim2.new(1, 0, 0, 24)
		DropFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
		DropFrame.BorderColor3 = Color3.fromRGB(60, 60, 60)
		DropFrame.BorderSizePixel = 1
		DropFrame.ClipsDescendants = false
		DropFrame.ZIndex = 5
		DropFrame.Parent = Container

		local SelectedBtn = Instance.new("TextButton")
		SelectedBtn.Size = UDim2.new(1, 0, 1, 0)
		SelectedBtn.BackgroundTransparency = 1
		SelectedBtn.Text = "  " .. name .. ": " .. tostring(default or options[1])
		SelectedBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
		SelectedBtn.Font = Enum.Font.Code
		SelectedBtn.TextSize = 12
		SelectedBtn.TextXAlignment = Enum.TextXAlignment.Left
		SelectedBtn.TextTruncate = Enum.TextTruncate.AtEnd
		SelectedBtn.ZIndex = 5
		SelectedBtn.Parent = DropFrame

		local ListFrame = Instance.new("Frame")
		ListFrame.Size = UDim2.new(1, 0, 0, #options * 20)
		ListFrame.Position = UDim2.new(0, 0, 1, 2)
		ListFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
		ListFrame.BorderColor3 = Color3.fromRGB(60, 60, 60)
		ListFrame.BorderSizePixel = 1
		ListFrame.Visible = false
		ListFrame.ZIndex = 10
		ListFrame.Parent = DropFrame

		local ListLayout = Instance.new("UIListLayout")
		ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		ListLayout.Parent = ListFrame

		local currentValue = default or options[1]

		local function selectValue(value, skipCallback)
			currentValue = value
			SelectedBtn.Text = "  " .. name .. ": " .. tostring(value)
			ListFrame.Visible = false
			if not skipCallback then
				callback(value)
			end
		end

		for _, option in ipairs(options) do
			local OptBtn = Instance.new("TextButton")
			OptBtn.Size = UDim2.new(1, 0, 0, 20)
			OptBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
			OptBtn.BackgroundTransparency = 0.3
			OptBtn.BorderSizePixel = 0
			OptBtn.Text = "  " .. tostring(option)
			OptBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
			OptBtn.Font = Enum.Font.Code
			OptBtn.TextSize = 11
			OptBtn.TextXAlignment = Enum.TextXAlignment.Left
			OptBtn.ZIndex = 10
			OptBtn.Parent = ListFrame

			OptBtn.MouseButton1Click:Connect(function()
				selectValue(option)
			end)
		end

		SelectedBtn.MouseButton1Click:Connect(function()
			ListFrame.Visible = not ListFrame.Visible
		end)

		if flagName then
			flags[flagName] = {
				get = function() return currentValue end,
				set = function(value) selectValue(value, false) end
			}
		end

		return { Select = selectValue }
	end

	-- ====================================================================
	-- KEYBIND (привязка любого действия к произвольной клавише)
	-- ====================================================================
	function Window:CreateKeybind(name, defaultKey, callback, flagName)
		local KeyBtn = Instance.new("TextButton")
		KeyBtn.Size = UDim2.new(1, 0, 0, 24)
		KeyBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
		KeyBtn.BorderColor3 = Color3.fromRGB(60, 60, 60)
		KeyBtn.BorderSizePixel = 1
		KeyBtn.Text = "  " .. name .. ": [" .. defaultKey.Name .. "]"
		KeyBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
		KeyBtn.Font = Enum.Font.Code
		KeyBtn.TextSize = 12
		KeyBtn.TextXAlignment = Enum.TextXAlignment.Left
		KeyBtn.TextTruncate = Enum.TextTruncate.AtEnd
		KeyBtn.Parent = Container

		local currentKey = defaultKey
		local listening = false

		local function setKey(key, skipCallback)
			currentKey = key
			KeyBtn.Text = "  " .. name .. ": [" .. key.Name .. "]"
		end

		KeyBtn.MouseButton1Click:Connect(function()
			if listening then return end
			listening = true
			KeyBtn.Text = "  " .. name .. ": [...]"
		end)

		UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if listening and input.UserInputType == Enum.UserInputType.Keyboard then
				setKey(input.KeyCode)
				listening = false
			elseif not gameProcessed and not listening and input.KeyCode == currentKey then
				callback()
			end
		end)

		if flagName then
			flags[flagName] = {
				get = function() return currentKey.Name end,
				set = function(value)
					local key = Enum.KeyCode[value]
					if key then setKey(key) end
				end
			}
		end

		return { SetKey = setKey }
	end

	return Window
end

return Library
