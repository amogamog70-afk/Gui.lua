-- ============================================================================
-- ROBLOX GUI LIBRARY — Minecraft cheat-client style (sidebar + module list)
-- Inspired by the layout of clients like Meteor Client / Wurst:
--   left = category sidebar, right = module list, click arrow = expand settings
-- ============================================================================

local Library = {}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CheatClientUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true

local ok, coreGui = pcall(function() return game:GetService("CoreGui") end)
ScreenGui.Parent = ok and coreGui or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

-- Global show/hide key (override via Library.ToggleKey)
Library.ToggleKey = Enum.KeyCode.RightShift
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and input.KeyCode == Library.ToggleKey then
		ScreenGui.Enabled = not ScreenGui.Enabled
	end
end)

-- Theme
local Theme = {
	Background   = Color3.fromRGB(12, 12, 14),
	Panel        = Color3.fromRGB(17, 17, 20),
	Sidebar      = Color3.fromRGB(9, 9, 11),
	Border       = Color3.fromRGB(40, 40, 45),
	Text         = Color3.fromRGB(190, 190, 195),
	TextDim      = Color3.fromRGB(110, 110, 115),
	TextEnabled  = Color3.fromRGB(255, 255, 255),
	Accent       = Color3.fromRGB(80, 170, 255),   -- enabled indicator / active tab
	AccentDim    = Color3.fromRGB(50, 100, 150),
}

-- ============================================================================
-- NOTIFICATIONS
-- ============================================================================
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
	Notif.Size = UDim2.new(1, 0, 0, 34)
	Notif.BackgroundColor3 = Theme.Panel
	Notif.BorderColor3 = Theme.Accent
	Notif.BorderSizePixel = 1
	Notif.BackgroundTransparency = 1
	Notif.Parent = NotifHolder

	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(1, -12, 1, 0)
	Label.Position = UDim2.new(0, 6, 0, 0)
	Label.BackgroundTransparency = 1
	Label.Text = text
	Label.TextColor3 = Theme.TextEnabled
	Label.Font = Enum.Font.Code
	Label.TextSize = 12
	Label.TextWrapped = true
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.TextTransparency = 1
	Label.Parent = Notif

	TweenService:Create(Notif, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
	TweenService:Create(Label, TweenInfo.new(0.2), {TextTransparency = 0}):Play()

	task.delay(duration, function()
		TweenService:Create(Label, TweenInfo.new(0.25), {TextTransparency = 1}):Play()
		local fadeOut = TweenService:Create(Notif, TweenInfo.new(0.25), {BackgroundTransparency = 1})
		fadeOut:Play()
		fadeOut.Completed:Wait()
		Notif:Destroy()
	end)
end

-- ============================================================================
-- WATERMARK — sits directly under Roblox's own top-left menu icon row
-- ============================================================================
function Library:CreateWatermark(initialText)
	local Watermark = Instance.new("TextLabel")
	Watermark.Name = "Watermark"
	Watermark.Size = UDim2.new(0, 180, 0, 18)
	Watermark.Position = UDim2.new(0, 8, 0, 44) -- below the Roblox icon/menu bar
	Watermark.BackgroundColor3 = Theme.Panel
	Watermark.BorderColor3 = Theme.Accent
	Watermark.BorderSizePixel = 1
	Watermark.Text = "  " .. (initialText or "")
	Watermark.TextColor3 = Theme.TextEnabled
	Watermark.Font = Enum.Font.Code
	Watermark.TextSize = 12
	Watermark.TextXAlignment = Enum.TextXAlignment.Left
	Watermark.Parent = ScreenGui

	return {
		SetText = function(_, newText) Watermark.Text = "  " .. newText end,
		Destroy = function() Watermark:Destroy() end
	}
end

-- ============================================================================
-- CONFIG SAVE / LOAD
-- ============================================================================
local ConfigFolder = "CheatClientUI_Configs"
local flags = {}

local function ensureFolder()
	if writefile and isfolder and makefolder then
		if not isfolder(ConfigFolder) then makefolder(ConfigFolder) end
	end
end

function Library:SaveConfig(name)
	if not writefile then Library:Notify("Executor does not support writefile", 3); return false end
	ensureFolder()
	local data = {}
	for flagName, entry in pairs(flags) do data[flagName] = entry.get() end
	local okEnc, encoded = pcall(function() return game:GetService("HttpService"):JSONEncode(data) end)
	if okEnc then
		writefile(ConfigFolder .. "/" .. name .. ".json", encoded)
		Library:Notify("Config saved: " .. name, 2)
		return true
	end
	return false
end

function Library:LoadConfig(name)
	if not readfile or not isfile then Library:Notify("Executor does not support readfile", 3); return false end
	local path = ConfigFolder .. "/" .. name .. ".json"
	if not isfile(path) then Library:Notify("Config not found: " .. name, 2); return false end
	local okDec, decoded = pcall(function() return game:GetService("HttpService"):JSONDecode(readfile(path)) end)
	if okDec then
		for flagName, value in pairs(decoded) do
			if flags[flagName] then flags[flagName].set(value) end
		end
		Library:Notify("Config loaded: " .. name, 2)
		return true
	end
	return false
end

-- ============================================================================
-- MODULE SETTINGS ROW BUILDERS (used inside a module's collapsible panel)
-- ============================================================================
local function addSlider(Settings, sname, min, max, default, callback, flagName)
	local Frame = Instance.new("Frame")
	Frame.Size = UDim2.new(1, 0, 0, 32)
	Frame.BackgroundTransparency = 1
	Frame.Parent = Settings

	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(1, 0, 0, 16)
	Label.BackgroundTransparency = 1
	Label.Text = sname .. ": " .. tostring(default)
	Label.TextColor3 = Theme.TextDim
	Label.Font = Enum.Font.Code
	Label.TextSize = 11
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = Frame

	local Track = Instance.new("Frame")
	Track.Size = UDim2.new(1, 0, 0, 5)
	Track.Position = UDim2.new(0, 0, 0, 20)
	Track.BackgroundColor3 = Theme.Background
	Track.BorderColor3 = Theme.Border
	Track.BorderSizePixel = 1
	Track.Parent = Frame

	local Fill = Instance.new("Frame")
	local initPct = math.clamp((default - min) / (max - min), 0, 1)
	Fill.Size = UDim2.new(initPct, 0, 1, 0)
	Fill.BackgroundColor3 = Theme.Accent
	Fill.BorderSizePixel = 0
	Fill.Parent = Track

	local currentVal = default
	local sliding = false

	local function setValue(val, skip)
		val = math.clamp(math.round(val), min, max)
		currentVal = val
		Fill.Size = UDim2.new((val - min) / (max - min), 0, 1, 0)
		Label.Text = sname .. ": " .. tostring(val)
		if not skip and callback then callback(val) end
	end

	local function fromInput(input)
		local pct = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
		setValue(min + (max - min) * pct)
	end

	local endedConn
	Frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			sliding = true
			fromInput(input)
			if not endedConn then
				endedConn = UserInputService.InputEnded:Connect(function(e)
					if e.UserInputType == Enum.UserInputType.MouseButton1 or e.UserInputType == Enum.UserInputType.Touch then
						sliding = false
					end
				end)
			end
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			fromInput(input)
		end
	end)

	if flagName then
		flags[flagName] = { get = function() return currentVal end, set = function(v) setValue(v, false) end }
	end

	return { SetValue = setValue }
end

local function addDropdown(Settings, dname, options, default, callback, flagName)
	local Frame = Instance.new("Frame")
	Frame.Size = UDim2.new(1, 0, 0, 20)
	Frame.BackgroundColor3 = Theme.Background
	Frame.BorderColor3 = Theme.Border
	Frame.BorderSizePixel = 1
	Frame.ClipsDescendants = false
	Frame.ZIndex = 5
	Frame.Parent = Settings

	local SelectedBtn = Instance.new("TextButton")
	SelectedBtn.Size = UDim2.new(1, 0, 1, 0)
	SelectedBtn.BackgroundTransparency = 1
	SelectedBtn.Text = "  " .. dname .. ": " .. tostring(default or options[1])
	SelectedBtn.TextColor3 = Theme.TextDim
	SelectedBtn.Font = Enum.Font.Code
	SelectedBtn.TextSize = 11
	SelectedBtn.TextXAlignment = Enum.TextXAlignment.Left
	SelectedBtn.ZIndex = 5
	SelectedBtn.Parent = Frame

	local ListFrame = Instance.new("Frame")
	ListFrame.Size = UDim2.new(1, 0, 0, #options * 18)
	ListFrame.Position = UDim2.new(0, 0, 1, 2)
	ListFrame.BackgroundColor3 = Theme.Panel
	ListFrame.BorderColor3 = Theme.Border
	ListFrame.BorderSizePixel = 1
	ListFrame.Visible = false
	ListFrame.ZIndex = 10
	ListFrame.Parent = Frame

	local ListLayout = Instance.new("UIListLayout")
	ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	ListLayout.Parent = ListFrame

	local currentValue = default or options[1]
	local function selectValue(value, skip)
		currentValue = value
		SelectedBtn.Text = "  " .. dname .. ": " .. tostring(value)
		ListFrame.Visible = false
		if not skip and callback then callback(value) end
	end

	for _, option in ipairs(options) do
		local OptBtn = Instance.new("TextButton")
		OptBtn.Size = UDim2.new(1, 0, 0, 18)
		OptBtn.BackgroundColor3 = Theme.Panel
		OptBtn.BorderSizePixel = 0
		OptBtn.Text = "  " .. tostring(option)
		OptBtn.TextColor3 = Theme.Text
		OptBtn.Font = Enum.Font.Code
		OptBtn.TextSize = 11
		OptBtn.TextXAlignment = Enum.TextXAlignment.Left
		OptBtn.ZIndex = 10
		OptBtn.Parent = ListFrame
		OptBtn.MouseButton1Click:Connect(function() selectValue(option) end)
	end

	SelectedBtn.MouseButton1Click:Connect(function() ListFrame.Visible = not ListFrame.Visible end)

	if flagName then
		flags[flagName] = { get = function() return currentValue end, set = function(v) selectValue(v, false) end }
	end

	return { Select = selectValue }
end

local function addKeybind(Settings, kname, defaultKey, callback, flagName)
	local KeyBtn = Instance.new("TextButton")
	KeyBtn.Size = UDim2.new(1, 0, 0, 20)
	KeyBtn.BackgroundColor3 = Theme.Background
	KeyBtn.BorderColor3 = Theme.Border
	KeyBtn.BorderSizePixel = 1
	KeyBtn.Text = "  " .. kname .. ": [" .. defaultKey.Name .. "]"
	KeyBtn.TextColor3 = Theme.TextDim
	KeyBtn.Font = Enum.Font.Code
	KeyBtn.TextSize = 11
	KeyBtn.TextXAlignment = Enum.TextXAlignment.Left
	KeyBtn.Parent = Settings

	local currentKey = defaultKey
	local listening = false
	local function setKey(key)
		currentKey = key
		KeyBtn.Text = "  " .. kname .. ": [" .. key.Name .. "]"
	end

	KeyBtn.MouseButton1Click:Connect(function()
		if listening then return end
		listening = true
		KeyBtn.Text = "  " .. kname .. ": [...]"
	end)

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if listening and input.UserInputType == Enum.UserInputType.Keyboard then
			setKey(input.KeyCode)
			listening = false
		elseif not gameProcessed and not listening and input.KeyCode == currentKey then
			if callback then callback() end
		end
	end)

	if flagName then
		flags[flagName] = {
			get = function() return currentKey.Name end,
			set = function(v) local k = Enum.KeyCode[v]; if k then setKey(k) end end
		}
	end

	return { SetKey = setKey }
end

local function addTextbox(Settings, tname, placeholder, callback, flagName)
	local Frame = Instance.new("Frame")
	Frame.Size = UDim2.new(1, 0, 0, 34)
	Frame.BackgroundColor3 = Theme.Background
	Frame.BorderColor3 = Theme.Border
	Frame.BorderSizePixel = 1
	Frame.Parent = Settings

	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(1, -8, 0, 14)
	Label.Position = UDim2.new(0, 4, 0, 2)
	Label.BackgroundTransparency = 1
	Label.Text = tname .. ":"
	Label.TextColor3 = Theme.TextDim
	Label.Font = Enum.Font.Code
	Label.TextSize = 10
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = Frame

	local TBox = Instance.new("TextBox")
	TBox.Size = UDim2.new(1, -8, 0, 14)
	TBox.Position = UDim2.new(0, 4, 0, 16)
	TBox.BackgroundColor3 = Theme.Panel
	TBox.BorderColor3 = Theme.Border
	TBox.BorderSizePixel = 1
	TBox.Text = ""
	TBox.PlaceholderText = placeholder or ""
	TBox.PlaceholderColor3 = Theme.TextDim
	TBox.TextColor3 = Theme.TextEnabled
	TBox.Font = Enum.Font.Code
	TBox.TextSize = 11
	TBox.TextXAlignment = Enum.TextXAlignment.Left
	TBox.Parent = Frame

	TBox.FocusLost:Connect(function(enter) if callback then callback(TBox.Text, enter) end end)

	if flagName then
		flags[flagName] = {
			get = function() return TBox.Text end,
			set = function(v) TBox.Text = v; if callback then callback(v, false) end end
		}
	end
end

-- ============================================================================
-- WINDOW — sidebar (categories) + content (module list), Meteor/Wurst layout
-- ============================================================================
function Library:CreateWindow(titleText, defaultPosition)
	local Window = {}

	local WINDOW_WIDTH  = 380
	local HEADER_HEIGHT = 26
	local SIDEBAR_WIDTH = 100
	local BODY_HEIGHT    = 300
	local isCollapsed = false

	local MainFrame = Instance.new("Frame")
	MainFrame.Name = titleText .. "_Window"
	MainFrame.Size = UDim2.new(0, WINDOW_WIDTH, 0, HEADER_HEIGHT + BODY_HEIGHT)
	MainFrame.Position = defaultPosition or UDim2.new(0, 60, 0, 60)
	MainFrame.BackgroundColor3 = Theme.Background
	MainFrame.BorderColor3 = Theme.Border
	MainFrame.BorderSizePixel = 1
	MainFrame.Active = true
	MainFrame.Parent = ScreenGui

	-- Header
	local TopBar = Instance.new("Frame")
	TopBar.Size = UDim2.new(1, 0, 0, HEADER_HEIGHT)
	TopBar.BackgroundColor3 = Theme.Panel
	TopBar.BorderColor3 = Theme.Border
	TopBar.BorderSizePixel = 0
	TopBar.Parent = MainFrame

	local HeaderLine = Instance.new("Frame")
	HeaderLine.Size = UDim2.new(1, 0, 0, 1)
	HeaderLine.Position = UDim2.new(0, 0, 1, 0)
	HeaderLine.BackgroundColor3 = Theme.Accent
	HeaderLine.BorderSizePixel = 0
	HeaderLine.Parent = TopBar

	local Title = Instance.new("TextLabel")
	Title.Size = UDim2.new(1, -30, 1, 0)
	Title.Position = UDim2.new(0, 10, 0, 0)
	Title.BackgroundTransparency = 1
	Title.Text = string.upper(titleText)
	Title.TextColor3 = Theme.TextEnabled
	Title.Font = Enum.Font.Code
	Title.TextSize = 13
	Title.TextXAlignment = Enum.TextXAlignment.Left
	Title.Parent = TopBar

	local CollapseBtn = Instance.new("TextButton")
	CollapseBtn.Size = UDim2.new(0, 26, 0, HEADER_HEIGHT)
	CollapseBtn.Position = UDim2.new(1, -26, 0, 0)
	CollapseBtn.BackgroundTransparency = 1
	CollapseBtn.Text = "-"
	CollapseBtn.TextColor3 = Theme.TextEnabled
	CollapseBtn.Font = Enum.Font.Code
	CollapseBtn.TextSize = 16
	CollapseBtn.Parent = TopBar

	-- Body (sidebar + content, below header)
	local Body = Instance.new("Frame")
	Body.Size = UDim2.new(1, 0, 0, BODY_HEIGHT)
	Body.Position = UDim2.new(0, 0, 0, HEADER_HEIGHT)
	Body.BackgroundTransparency = 1
	Body.Parent = MainFrame

	-- Sidebar
	local Sidebar = Instance.new("Frame")
	Sidebar.Size = UDim2.new(0, SIDEBAR_WIDTH, 1, 0)
	Sidebar.BackgroundColor3 = Theme.Sidebar
	Sidebar.BorderColor3 = Theme.Border
	Sidebar.BorderSizePixel = 1
	Sidebar.Parent = Body

	local SidebarLayout = Instance.new("UIListLayout")
	SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
	SidebarLayout.Parent = Sidebar

	-- Content (module list)
	local Content = Instance.new("ScrollingFrame")
	Content.Size = UDim2.new(1, -SIDEBAR_WIDTH - 8, 1, -8)
	Content.Position = UDim2.new(0, SIDEBAR_WIDTH + 4, 0, 4)
	Content.BackgroundTransparency = 1
	Content.BorderSizePixel = 0
	Content.ScrollBarThickness = 3
	Content.ScrollBarImageColor3 = Theme.Accent
	Content.CanvasSize = UDim2.new(0, 0, 0, 0)
	Content.AutomaticCanvasSize = Enum.AutomaticSize.Y
	Content.Parent = Body

	local ContentLayout = Instance.new("UIListLayout")
	ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
	ContentLayout.Padding = UDim.new(0, 3)
	ContentLayout.Parent = Content

	CollapseBtn.MouseButton1Click:Connect(function()
		isCollapsed = not isCollapsed
		Body.Visible = not isCollapsed
		CollapseBtn.Text = isCollapsed and "+" or "-"
		MainFrame.Size = isCollapsed
			and UDim2.new(0, WINDOW_WIDTH, 0, HEADER_HEIGHT)
			or UDim2.new(0, WINDOW_WIDTH, 0, HEADER_HEIGHT + BODY_HEIGHT)
	end)

	-- Window dragger
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

	local categories = {}
	local activeContent = nil

	local function selectCategory(target)
		for _, cat in ipairs(categories) do
			local isActive = cat.container == target
			cat.container.Visible = isActive
			cat.button.BackgroundColor3 = isActive and Theme.Panel or Theme.Sidebar
			cat.button.TextColor3 = isActive and Theme.TextEnabled or Theme.TextDim
			cat.indicator.BackgroundColor3 = isActive and Theme.Accent or Theme.Sidebar
		end
		activeContent = target
	end

	-- ========================================================================
	-- CreateTab (category) — returns API for adding modules/buttons in it
	-- ========================================================================
	function Window:CreateTab(name)
		local CatBtn = Instance.new("TextButton")
		CatBtn.Size = UDim2.new(1, 0, 0, 30)
		CatBtn.BackgroundColor3 = Theme.Sidebar
		CatBtn.BorderSizePixel = 0
		CatBtn.Text = string.upper(name)
		CatBtn.TextColor3 = Theme.TextDim
		CatBtn.Font = Enum.Font.Code
		CatBtn.TextSize = 12
		CatBtn.Parent = Sidebar

		local Indicator = Instance.new("Frame")
		Indicator.Size = UDim2.new(0, 2, 1, 0)
		Indicator.BackgroundColor3 = Theme.Sidebar
		Indicator.BorderSizePixel = 0
		Indicator.Parent = CatBtn

		local TabContent = Instance.new("Frame")
		TabContent.Size = UDim2.new(1, 0, 0, 0)
		TabContent.AutomaticSize = Enum.AutomaticSize.Y
		TabContent.BackgroundTransparency = 1
		TabContent.Visible = false
		TabContent.LayoutOrder = #categories + 1
		TabContent.Parent = Content

		local TabContentLayout = Instance.new("UIListLayout")
		TabContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
		TabContentLayout.Padding = UDim.new(0, 3)
		TabContentLayout.Parent = TabContent

		table.insert(categories, { button = CatBtn, container = TabContent, indicator = Indicator })

		CatBtn.MouseButton1Click:Connect(function()
			selectCategory(TabContent)
		end)

		if #categories == 1 then
			selectCategory(TabContent)
		end

		local Tab = {}

		-- A plain action button (no toggle state) — e.g. "Save Config"
		function Tab:CreateButton(bname, callback)
			local Btn = Instance.new("TextButton")
			Btn.Size = UDim2.new(1, 0, 0, 24)
			Btn.BackgroundColor3 = Theme.Panel
			Btn.BorderColor3 = Theme.Border
			Btn.BorderSizePixel = 1
			Btn.Text = "  " .. bname
			Btn.TextColor3 = Theme.Text
			Btn.Font = Enum.Font.Code
			Btn.TextSize = 12
			Btn.TextXAlignment = Enum.TextXAlignment.Left
			Btn.Parent = TabContent
			Btn.MouseButton1Click:Connect(callback)
			return Btn
		end

		-- A section divider label (optional, purely visual grouping)
		function Tab:CreateSection(sname)
			local Label = Instance.new("TextLabel")
			Label.Size = UDim2.new(1, 0, 0, 16)
			Label.BackgroundTransparency = 1
			Label.Text = string.upper(sname)
			Label.TextColor3 = Theme.TextDim
			Label.Font = Enum.Font.Code
			Label.TextSize = 10
			Label.TextXAlignment = Enum.TextXAlignment.Left
			Label.Parent = TabContent
			return Label
		end

		-- A module: toggle row + arrow that expands a settings panel below it
		function Tab:CreateModule(mname, defaultEnabled, callback, flagName)
			local ModuleFrame = Instance.new("Frame")
			ModuleFrame.Size = UDim2.new(1, 0, 0, 0)
			ModuleFrame.AutomaticSize = Enum.AutomaticSize.Y
			ModuleFrame.BackgroundTransparency = 1
			ModuleFrame.Parent = TabContent

			local ModuleLayout = Instance.new("UIListLayout")
			ModuleLayout.SortOrder = Enum.SortOrder.LayoutOrder
			ModuleLayout.Parent = ModuleFrame

			local Header = Instance.new("TextButton")
			Header.Size = UDim2.new(1, 0, 0, 24)
			Header.BackgroundColor3 = Theme.Panel
			Header.BorderColor3 = Theme.Border
			Header.BorderSizePixel = 1
			Header.Text = ""
			Header.AutoButtonColor = false
			Header.Parent = ModuleFrame

			local Indicator2 = Instance.new("Frame")
			Indicator2.Size = UDim2.new(0, 3, 1, 0)
			Indicator2.BorderSizePixel = 0
			Indicator2.BackgroundColor3 = Theme.Border
			Indicator2.Parent = Header

			local NameLabel = Instance.new("TextLabel")
			NameLabel.Size = UDim2.new(1, -46, 1, 0)
			NameLabel.Position = UDim2.new(0, 10, 0, 0)
			NameLabel.BackgroundTransparency = 1
			NameLabel.Text = mname
			NameLabel.Font = Enum.Font.Code
			NameLabel.TextSize = 12
			NameLabel.TextColor3 = Theme.Text
			NameLabel.TextXAlignment = Enum.TextXAlignment.Left
			NameLabel.Parent = Header

			local ArrowBtn = Instance.new("TextButton")
			ArrowBtn.Size = UDim2.new(0, 24, 1, 0)
			ArrowBtn.Position = UDim2.new(1, -24, 0, 0)
			ArrowBtn.BackgroundTransparency = 1
			ArrowBtn.Text = "+"
			ArrowBtn.Font = Enum.Font.Code
			ArrowBtn.TextSize = 13
			ArrowBtn.TextColor3 = Theme.TextDim
			ArrowBtn.Parent = Header

			local Settings = Instance.new("Frame")
			Settings.Size = UDim2.new(1, 0, 0, 0)
			Settings.AutomaticSize = Enum.AutomaticSize.Y
			Settings.BackgroundColor3 = Theme.Background
			Settings.BorderColor3 = Theme.Border
			Settings.BorderSizePixel = 1
			Settings.Visible = false
			Settings.Parent = ModuleFrame

			local Pad = Instance.new("UIPadding")
			Pad.PaddingTop = UDim.new(0, 5)
			Pad.PaddingBottom = UDim.new(0, 5)
			Pad.PaddingLeft = UDim.new(0, 5)
			Pad.PaddingRight = UDim.new(0, 5)
			Pad.Parent = Settings

			local SettingsLayout = Instance.new("UIListLayout")
			SettingsLayout.SortOrder = Enum.SortOrder.LayoutOrder
			SettingsLayout.Padding = UDim.new(0, 4)
			SettingsLayout.Parent = Settings

			local enabled = defaultEnabled or false
			local function setEnabled(state, skip)
				enabled = state
				Indicator2.BackgroundColor3 = enabled and Theme.Accent or Theme.Border
				NameLabel.TextColor3 = enabled and Theme.TextEnabled or Theme.Text
				if not skip and callback then callback(enabled) end
			end
			setEnabled(enabled, true)

			local expanded = false
			local function setExpanded(state)
				expanded = state
				Settings.Visible = expanded
				ArrowBtn.Text = expanded and "-" or "+"
			end

			Header.MouseButton1Click:Connect(function() setEnabled(not enabled) end)
			ArrowBtn.MouseButton1Click:Connect(function() setExpanded(not expanded) end)

			if flagName then
				flags[flagName] = { get = function() return enabled end, set = function(v) setEnabled(v) end }
			end

			local Module = {}
			function Module:AddSlider(sname, min, max, default, cb, fname) return addSlider(Settings, sname, min, max, default, cb, fname) end
			function Module:AddDropdown(dname, options, default, cb, fname) return addDropdown(Settings, dname, options, default, cb, fname) end
			function Module:AddKeybind(kname, defaultKey, cb, fname) return addKeybind(Settings, kname, defaultKey, cb, fname) end
			function Module:AddTextbox(tname, placeholder, cb, fname) return addTextbox(Settings, tname, placeholder, cb, fname) end
			function Module:SetEnabled(state) setEnabled(state) end

			return Module
		end

		return Tab
	end

	return Window
end

-- ============================================================================
-- WINDOW SETUP — Combat / Visuals categories, filled with example modules
-- ============================================================================
local watermark = Library:CreateWatermark("MyScript v1.0")

local Window = Library:CreateWindow("Client", UDim2.new(0, 60, 0, 60))

local Combat = Window:CreateTab("Combat")
local Visuals = Window:CreateTab("Visuals")

-- ---------------------------------------------------------------------------
-- COMBAT
-- ---------------------------------------------------------------------------
local SilentAim = Combat:CreateModule("Silent Aim", false, function(state)
	print("Silent Aim:", state)
end, "SilentAim")
SilentAim:AddSlider("FOV Size", 10, 200, 90, function(v) print("FOV:", v) end, "FovSize")
SilentAim:AddDropdown("Aim Part", {"Head", "Torso", "Random"}, "Head", function(v) print("Aim Part:", v) end, "AimPart")
SilentAim:AddKeybind("Aim Key", Enum.KeyCode.Q, function() print("Aim key pressed") end, "AimKey")

local AutoClicker = Combat:CreateModule("Auto Clicker", false, function(state)
	print("Auto Clicker:", state)
end, "AutoClicker")
AutoClicker:AddSlider("Click Speed (CPS)", 1, 20, 10, function(v) print("CPS:", v) end, "ClickSpeed")

local KillAura = Combat:CreateModule("Kill Aura", false, function(state)
	print("Kill Aura:", state)
end, "KillAura")
KillAura:AddSlider("Range", 1, 30, 12, function(v) print("Range:", v) end, "KillAuraRange")

-- ---------------------------------------------------------------------------
-- VISUALS
-- ---------------------------------------------------------------------------
local PlayerESP = Visuals:CreateModule("Player ESP", false, function(state)
	print("Player ESP:", state)
end, "PlayerESP")
PlayerESP:AddDropdown("ESP Mode", {"Box", "Chams", "Skeleton"}, "Box", function(v) print("ESP Mode:", v) end, "ESPMode")
PlayerESP:AddSlider("Transparency", 0, 100, 50, function(v) print("Transparency:", v) end, "ESPTransparency")

local Fullbright = Visuals:CreateModule("Fullbright", false, function(state)
	game.Lighting.Brightness = state and 2 or 1
end, "Fullbright")

local FPSDisplay = Visuals:CreateModule("FPS Counter", true, function() end, "FPSCounter")

Visuals:CreateSection("Info")
Visuals:CreateButton("Ping Check", function()
	Library:Notify("Checking ping...", 2)
end)

-- ---------------------------------------------------------------------------
-- CONFIG
-- ---------------------------------------------------------------------------
Combat:CreateSection("Config")
Combat:CreateButton("Save Config", function() Library:SaveConfig("default") end)
Combat:CreateButton("Load Config", function() Library:LoadConfig("default") end)

Library:Notify("Script loaded successfully!", 3)
