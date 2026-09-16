local startupArgs = ({...})[1] or {}

local genv = (getgenv and getgenv()) or _G
if genv.library ~= nil then
    pcall(function() genv.library:Unload() end)
end

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local function gs(a)
    return cloneref and cloneref(game:GetService(a)) or game:GetService(a)
end

-- // Variables
local players, http, runservice, inputservice, tweenService, stats, actionservice = gs('Players'), gs('HttpService'), gs('RunService'), gs('UserInputService'), gs('TweenService'), gs('Stats'), gs('ContextActionService')
local localplayer = players.LocalPlayer

local setByConfig = false
local floor, ceil, huge, pi, clamp = math.floor, math.ceil, math.huge, math.pi, math.clamp
local c3new, fromrgb, fromhsv = Color3.new, Color3.fromRGB, Color3.fromHSV
local next, newInstance, newUDim2, newVector2 = next, Instance.new, UDim2.new, Vector2.new
local isexecutorclosure = isexecutorclosure or is_synapse_function or is_sirhurt_closure or iskrnlclosure;
local executor = (
    syn and 'syn' or
    getexecutorname and getexecutorname() or
    'unknown'
)

-- // 2026 Executor Compatibility Helpers
local printconsole = printconsole or rconsoleprint or function(...) warn(...) end
local customRequest = (syn and syn.request) or request or http_request or (http and http.request)

local function decodeBase64(data)
    if syn and syn.crypt and syn.crypt.base64 and syn.crypt.base64.decode then
        local s, r = pcall(syn.crypt.base64.decode, data)
        if s and r then return r end
    end
    if crypt and crypt.base64decode then
        local s, r = pcall(crypt.base64decode, data)
        if s and r then return r end
    end
    if crypt and crypt.base64_decode then
        local s, r = pcall(crypt.base64_decode, data)
        if s and r then return r end
    end
    if base64_decode then
        local s, r = pcall(base64_decode, data)
        if s and r then return r end
    end
    local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r, f = '', (b:find(x) - 1)
        for i = 6, 1, -1 do r = r .. (f % 2^i - f % 2^(i - 1) > 0 and '1' or '0') end
        return r
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c = 0
        for i = 1, 8 do c = c + (x:sub(i, i) == '1' and 2^(8 - i) or 0) end
        return string.char(c)
    end))
end

local function safeCreateDrawing(class)
    local ok, obj = pcall(Drawing.new, class)
    if ok and obj then return obj end
    local dummy = {}
    local mt = {
        __index = function(t, k)
            if k == 'Remove' or k == 'Destroy' then
                return function() end
            elseif k == 'TextBounds' then
                return newVector2(50, 14)
            elseif k == 'Size' or k == 'Position' or k == 'PointA' or k == 'PointB' or k == 'PointC' then
                return newVector2(0, 0)
            end
            return 0
        end,
        __newindex = function(t, k, v) end
    }
    return setmetatable(dummy, mt)
end

-- // Standalone Signal Implementation (zero external dependency, no script.Parent errors)
local SignalModule = {}
do
    local Signal = {}
    Signal.__index = Signal

    local Connection = {}
    Connection.__index = Connection

    function Connection.new(sig, fn)
        return setmetatable({
            _signal = sig,
            _fn = fn,
            Connected = true
        }, Connection)
    end

    function Connection:Disconnect()
        if not self.Connected then return end
        self.Connected = false
        local sig = self._signal
        if sig and sig._handlers then
            local idx = table.find(sig._handlers, self)
            if idx then
                table.remove(sig._handlers, idx)
            end
        end
    end
    Connection.Destroy = Connection.Disconnect

    function Signal.new()
        return setmetatable({
            _handlers = {}
        }, Signal)
    end

    function Signal:Connect(fn)
        local conn = Connection.new(self, fn)
        table.insert(self._handlers, conn)
        return conn
    end

    function Signal:Fire(...)
        local handlers = self._handlers
        for i = 1, #handlers do
            local handler = handlers[i]
            if handler and handler.Connected and handler._fn then
                task.spawn(handler._fn, ...)
            end
        end
    end

    function Signal:Wait()
        local thread = coroutine.running()
        local conn
        conn = self:Connect(function(...)
            conn:Disconnect()
            task.spawn(thread, ...)
        end)
        return coroutine.yield()
    end

    function Signal:Once(fn)
        local conn
        conn = self:Connect(function(...)
            conn:Disconnect()
            fn(...)
        end)
        return conn
    end

    function Signal:DisconnectAll()
        for _, handler in ipairs(self._handlers) do
            handler.Connected = false
        end
        table.clear(self._handlers)
    end
    Signal.Destroy = Signal.DisconnectAll

    SignalModule = Signal
end

local library = {
    windows = {};
    indicators = {};
    flags = {
        ['watermark_enabled'] = false;
        ['watermark_x'] = 6;
        ['watermark_y'] = 1;
        ['keybind_indicator'] = true;
        ['keybind_indicator_x'] = 0.5;
        ['keybind_indicator_y'] = 30;
    };
    options = {};
    connections = {};
    drawings = {};
    instances = {};
    utility = {};
    notifications = {};
    tweens = {};
    theme = {};
    zindexOrder = {
        ['indicator'] = 950;
        ['window'] = 1000;
        ['dropdown'] = 1200;
        ['colorpicker'] = 1100;
        ['watermark'] = 1300;
        ['notification'] = 1400;
        ['cursor'] = 1500;
    },
    stats = {
        ['fps'] = 0;
        ['ping'] = 0;
    };
    images = {
        ['gradientp90'] = 'https://raw.githubusercontent.com/portallol/luna/main/modules/gradient90.png';
        ['gradientp45'] = 'https://raw.githubusercontent.com/portallol/luna/main/modules/gradient45.png';
        ['colorhue'] = 'https://raw.githubusercontent.com/portallol/luna/main/modules/lgbtqshit.png';
        ['colortrans'] = 'https://raw.githubusercontent.com/portallol/luna/main/modules/trans.png';
    };
    numberStrings = {['Zero'] = 0, ['One'] = 1, ['Two'] = 2, ['Three'] = 3, ['Four'] = 4, ['Five'] = 5, ['Six'] = 6, ['Seven'] = 7, ['Eight'] = 8, ['Nine'] = 9};
    signal = SignalModule;
    open = false;
    opening = false;
    hasInit = false;
    cheatname = startupArgs.cheatname or 'Clanware';
    gamename = startupArgs.gamename or 'Universal';
    fileext = startupArgs.fileext or '.txt';
}

library.themes = {
    {
        name = 'Default',
        theme = {
            ['Accent']                    = fromrgb(230,230,230);
            ['Background']                = fromrgb(15,15,15);
            ['Border']                    = fromrgb(0,0,0);
            ['Border 1']                  = fromrgb(45,45,45);
            ['Border 2']                  = fromrgb(22,22,22);
            ['Border 3']                  = fromrgb(10,10,10);
            ['Primary Text']              = fromrgb(240,240,240);
            ['Group Background']          = fromrgb(18,18,18);
            ['Selected Tab Background']   = fromrgb(26,26,26);
            ['Unselected Tab Background'] = fromrgb(14,14,14);
            ['Selected Tab Text']         = fromrgb(255,255,255);
            ['Unselected Tab Text']       = fromrgb(135,135,135);
            ['Section Background']        = fromrgb(16,16,16);
            ['Option Text 1']             = fromrgb(240,240,240);
            ['Option Text 2']             = fromrgb(185,185,185);
            ['Option Text 3']             = fromrgb(135,135,135);
            ['Option Border 1']           = fromrgb(45,45,45);
            ['Option Border 2']           = fromrgb(10,10,10);
            ['Option Background']         = fromrgb(26,26,26);
            ["Risky Text"]                = fromrgb(180, 30, 30);
            ["Risky Text Enabled"]        = fromrgb(255, 50, 50);
        }
    },
    {
        name = 'Midnight',
        theme = {
            ['Accent']                    = fromrgb(103,89,179);
            ['Background']                = fromrgb(22,22,31);
            ['Border']                    = fromrgb(0,0,0);
            ['Border 1']                  = fromrgb(50,50,50);
            ['Border 2']                  = fromrgb(24,25,37);
            ['Border 3']                  = fromrgb(10,10,10);
            ['Primary Text']              = fromrgb(235,235,235);
            ['Group Background']          = fromrgb(24,25,37);
            ['Selected Tab Background']   = fromrgb(24,25,37);
            ['Unselected Tab Background'] = fromrgb(22,22,31);
            ['Selected Tab Text']         = fromrgb(245,245,245);
            ['Unselected Tab Text']       = fromrgb(145,145,145);
            ['Section Background']        = fromrgb(22,22,31);
            ['Option Text 1']             = fromrgb(245,245,245);
            ['Option Text 2']             = fromrgb(195,195,195);
            ['Option Text 3']             = fromrgb(145,145,145);
            ['Option Border 1']           = fromrgb(50,50,50);
            ['Option Border 2']           = fromrgb(0,0,0);
            ['Option Background']         = fromrgb(24,25,37);
            ["Risky Text"]                = fromrgb(175, 21, 21);
            ["Risky Text Enabled"]        = fromrgb(255, 41, 41);
        }
    },
    {
        name = 'Nekocheat',
        theme = {
            ["Accent"]                    = fromrgb(226, 30, 112);
            ["Background"]                = fromrgb(18,18,18);
            ["Border"]                    = fromrgb(0,0,0);
            ["Border 1"]                  = fromrgb(60,60,60);
            ["Border 2"]                  = fromrgb(18,18,18);
            ["Border 3"]                  = fromrgb(10,10,10);
            ["Primary Text"]              = fromrgb(255,255,255);
            ["Group Background"]          = fromrgb(18,18,18);
            ["Selected Tab Background"]   = fromrgb(18,18,18);
            ["Unselected Tab Background"] = fromrgb(18,18,18);
            ["Selected Tab Text"]         = fromrgb(245,245,245);
            ["Unselected Tab Text"]       = fromrgb(145,145,145);
            ["Section Background"]        = fromrgb(18,18,18);
            ["Option Text 1"]             = fromrgb(255,255,255);
            ["Option Text 2"]             = fromrgb(255,255,255);
            ["Option Text 3"]             = fromrgb(255,255,255);
            ["Option Border 1"]           = fromrgb(50,50,50);
            ["Option Border 2"]           = fromrgb(0,0,0);
            ["Option Background"]         = fromrgb(23,23,23);
            ["Risky Text"]                = fromrgb(175, 21, 21);
            ["Risky Text Enabled"]        = fromrgb(255, 41, 41);
        }
    },
    {
        name = 'Nekocheat Blue',
        theme = {
            ["Accent"]                    = fromrgb(0, 247, 255);
            ["Background"]                = fromrgb(18,18,18);
            ["Border"]                    = fromrgb(0,0,0);
            ["Border 1"]                  = fromrgb(60,60,60);
            ["Border 2"]                  = fromrgb(18,18,18);
            ["Border 3"]                  = fromrgb(10,10,10);
            ["Primary Text"]              = fromrgb(255,255,255);
            ["Group Background"]          = fromrgb(18,18,18);
            ["Selected Tab Background"]   = fromrgb(18,18,18);
            ["Unselected Tab Background"] = fromrgb(18,18,18);
            ["Selected Tab Text"]         = fromrgb(245,245,245);
            ["Unselected Tab Text"]       = fromrgb(145,145,145);
            ["Section Background"]        = fromrgb(18,18,18);
            ["Option Text 1"]             = fromrgb(255,255,255);
            ["Option Text 2"]             = fromrgb(255,255,255);
            ["Option Text 3"]             = fromrgb(255,255,255);
            ["Option Border 1"]           = fromrgb(50,50,50);
            ["Option Border 2"]           = fromrgb(0,0,0);
            ["Option Background"]         = fromrgb(23,23,23);
            ["Risky Text"]                = fromrgb(175, 21, 21);
            ["Risky Text Enabled"]        = fromrgb(255, 41, 41);
        }
    },
    {
        name = 'Fatality',
        theme = {
            ['Accent']                    = fromrgb(197,7,83);
            ['Background']                = fromrgb(25,19,53);
            ['Border']                    = fromrgb(0,0,0);
            ['Border 1']                  = fromrgb(60,53,93);
            ['Border 2']                  = fromrgb(29,23,66);
            ['Border 3']                  = fromrgb(10,10,10);
            ['Primary Text']              = fromrgb(235,235,235);
            ['Group Background']          = fromrgb(29,23,66);
            ['Selected Tab Background']   = fromrgb(29,23,66);
            ['Unselected Tab Background'] = fromrgb(25,19,53);
            ['Selected Tab Text']         = fromrgb(245,245,245);
            ['Unselected Tab Text']       = fromrgb(145,145,145);
            ['Section Background']        = fromrgb(25,19,53);
            ['Option Text 1']             = fromrgb(245,245,245);
            ['Option Text 2']             = fromrgb(195,195,195);
            ['Option Text 3']             = fromrgb(145,145,145);
            ['Option Border 1']           = fromrgb(60,53,93);
            ['Option Border 2']           = fromrgb(0,0,0);
            ['Option Background']         = fromrgb(29,23,66);
            ["Risky Text"]                = fromrgb(175, 21, 21);
            ["Risky Text Enabled"]        = fromrgb(255, 41, 41);
        }
    },
    {
        name = 'Gamesense',
        theme = {
            ['Accent']                    = fromrgb(147,184,26);
            ['Background']                = fromrgb(17,17,17);
            ['Border']                    = fromrgb(0,0,0);
            ['Border 1']                  = fromrgb(47,47,47);
            ['Border 2']                  = fromrgb(17,17,17);
            ['Border 3']                  = fromrgb(10,10,10);
            ['Primary Text']              = fromrgb(235,235,235);
            ['Group Background']          = fromrgb(17,17,17);
            ['Selected Tab Background']   = fromrgb(17,17,17);
            ['Unselected Tab Background'] = fromrgb(17,17,17);
            ['Selected Tab Text']         = fromrgb(245,245,245);
            ['Unselected Tab Text']       = fromrgb(145,145,145);
            ['Section Background']        = fromrgb(17,17,17);
            ['Option Text 1']             = fromrgb(245,245,245);
            ['Option Text 2']             = fromrgb(195,195,195);
            ['Option Text 3']             = fromrgb(145,145,145);
            ['Option Border 1']           = fromrgb(47,47,47);
            ['Option Border 2']           = fromrgb(0,0,0);
            ['Option Background']         = fromrgb(35,35,35);
            ["Risky Text"]                = fromrgb(175, 21, 21);
            ["Risky Text Enabled"]        = fromrgb(255, 41, 41);
        }
    },
    {
        name = 'Twitch',
        theme = {
            ['Accent']                    = fromrgb(169,112,255);
            ['Background']                = fromrgb(14,14,14);
            ['Border']                    = fromrgb(0,0,0);
            ['Border 1']                  = fromrgb(45,45,45);
            ['Border 2']                  = fromrgb(31,31,35);
            ['Border 3']                  = fromrgb(10,10,10);
            ['Primary Text']              = fromrgb(235,235,235);
            ['Group Background']          = fromrgb(31,31,35);
            ['Selected Tab Background']   = fromrgb(31,31,35);
            ['Unselected Tab Background'] = fromrgb(17,17,17);
            ['Selected Tab Text']         = fromrgb(225,225,225);
            ['Unselected Tab Text']       = fromrgb(160,170,175);
            ['Section Background']        = fromrgb(17,17,17);
            ['Option Text 1']             = fromrgb(245,245,245);
            ['Option Text 2']             = fromrgb(195,195,195);
            ['Option Text 3']             = fromrgb(145,145,145);
            ['Option Border 1']           = fromrgb(45,45,45);
            ['Option Border 2']           = fromrgb(0,0,0);
            ['Option Background']         = fromrgb(24,24,27);
            ["Risky Text"]                = fromrgb(175, 21, 21);
            ["Risky Text Enabled"]        = fromrgb(255, 41, 41);
        }
    }
}

library.theme = {};
for k, v in next, library.themes[1].theme do
    library.theme[k] = v;
end

local blacklistedKeys = {
    Enum.KeyCode.Unknown,
    Enum.KeyCode.W,
    Enum.KeyCode.A,
    Enum.KeyCode.S,
    Enum.KeyCode.D,
    Enum.KeyCode.Slash,
    Enum.KeyCode.Tab,
    Enum.KeyCode.Escape
}

local whitelistedBoxKeys = {
    Enum.KeyCode.Zero,
    Enum.KeyCode.One,
    Enum.KeyCode.Two,
    Enum.KeyCode.Three,
    Enum.KeyCode.Four,
    Enum.KeyCode.Five,
    Enum.KeyCode.Six,
    Enum.KeyCode.Seven,
    Enum.KeyCode.Eight,
    Enum.KeyCode.Nine
}

local keyNames = {
    [Enum.KeyCode.LeftControl] = 'LCTRL';
    [Enum.KeyCode.RightControl] = 'RCTRL';
    [Enum.KeyCode.LeftShift] = 'LSHIFT';
    [Enum.KeyCode.RightShift] = 'RSHIFT';
    [Enum.UserInputType.MouseButton1] = 'MB1';
    [Enum.UserInputType.MouseButton2] = 'MB2';
    [Enum.UserInputType.MouseButton3] = 'MB3';
}

library.button1down = library.signal.new()
library.button1up   = library.signal.new()
library.mousemove   = library.signal.new()
library.unloaded    = library.signal.new();
library.interactiveDrawings = {};
library.isDragging = false;

local button1down, button1up, mousemove = library.button1down, library.button1up, library.mousemove
local mb1down = false;

local utility = library.utility
do

    function utility:Connection(signal, func)
        local c = signal:Connect(func)
        table.insert(library.connections, c)
        if typeof(signal) == 'table' and signal._owner and signal._owner.Object then
            library.interactiveDrawings[signal._owner.Object] = signal._owner
        end
        return c
    end

    function utility:Instance(class, properties)
        local inst = newInstance(class)
        for prop, val in next, properties or {} do
            local s,e = pcall(function()
                inst[prop] = val
            end)
            if not s then
                printconsole(e, 255,0,0)
            end
        end
        return inst
    end

    function utility:HasProperty(obj, prop)
        return ({(pcall(function() local a = obj[prop] end))})[1]
    end

    function utility:ToRGB(c3)
        return c3.R*255,c3.G*255,c3.B*255
    end

    function utility:AddRGB(a,b)
        local r1,g1,b1 = self:ToRGB(a);
        local r2,g2,b2 = self:ToRGB(b);
        return fromrgb(clamp(r1+r2,0,255),clamp(g1+g2,0,255),clamp(b1+b2,0,255))
    end

    function utility:ConvertNumberRange(val,oldmin,oldmax,newmin,newmax)
        return (((val - oldmin) * (newmax - newmin)) / (oldmax - oldmin)) + newmin
    end

    function utility:UDim2ToVector2(udim2, vector2)
        local x,y
        x = udim2.X.Offset + self:ConvertNumberRange(udim2.X.Scale,0,1,0,vector2.X)
        y = udim2.Y.Offset + self:ConvertNumberRange(udim2.Y.Scale,0,1,0,vector2.Y)
        return newVector2(x,y)
    end

    function utility:Lerp(a,b,c)
        return a + (b-a) * c
    end

    function utility:Tween(obj, prop, val, time, direction, style)
        if self:HasProperty(obj, prop) then
            if library.tweens[obj] then
                if library.tweens[obj][prop] then
                    library.tweens[obj][prop]:Cancel()
                end
            end

            local startVal = obj[prop];
            local a = 0;
            local tween = {
                Completed = library.signal.new();
            };

            library.tweens[obj] = library.tweens[obj] or {};
            library.tweens[obj][prop] = tween;

            tween.Connection = self:Connection(runservice.RenderStepped, function(dt)
                a = a + (dt / time);
                if a >= 1 or obj == nil then
                    tween:Cancel();
                end
                pcall(function()
                    local progress = tweenService:GetValue(a, style or Enum.EasingStyle.Linear, direction or Enum.EasingDirection.In)
                    local newVal
                    if typeof(startVal) == 'number' then
                        newVal = utility:Lerp(startVal, val, progress);
                    else
                        newVal = startVal:Lerp(val, progress);
                    end
                    obj[prop] = newVal;
                end)
            end)

            function tween:Cancel()
                tween.Connection:Disconnect();
                tween.Completed:Fire();
                table.clear(tween);
                library.tweens[obj][prop] = nil;
            end
            
            return tween;
        else
            printconsole('unable to tween: invalid property '..tostring(prop)..' for object '..tostring(obj), 255,0,0)
        end
    end

    function utility:DetectTableChange(indexcallback,newindexcallback)
        if indexcallback == nil then
            warn('DetectTableChange: Argument #1 (indexcallback) is nil, function may not work as expected.')
        elseif newindexcallback == nil then
            warn('DetectTableChange: Argument #2 (newindexcallback) is nil, function may not work as expected.')
        end
        local proxy = newproxy(true);
        local mt = getmetatable(proxy);
        mt.__index = indexcallback
        mt.__newindex = newindexcallback
        return proxy
    end

    function utility:MouseOver(obj)
        local mousePos = inputservice:GetMouseLocation();
        local x1 = obj.Position.X
        local y1 = obj.Position.Y
        local x2 = x1 + obj.Size.X
        local y2 = y1 + obj.Size.Y
        return (mousePos.X >= x1 and mousePos.Y >= y1 and mousePos.X <= x2 and mousePos.Y <= y2)
    end

    function utility:GetHoverObject()
        if library.isDragging then return nil end
        local mousePos = inputservice:GetMouseLocation()
        local mx, my = mousePos.X, mousePos.Y
        local bestObj = nil
        local bestZ = -999999
        for _, v in next, library.interactiveDrawings do
            if v.Visible and v.Class == 'Square' then
                local obj = v.Object
                if obj.Visible then
                    local pos = obj.Position
                    local size = obj.Size
                    local x1, y1 = pos.X, pos.Y
                    if mx >= x1 and mx <= x1 + size.X and my >= y1 and my <= y1 + size.Y then
                        local z = obj.ZIndex
                        if z > bestZ then
                            bestZ = z
                            bestObj = obj
                        end
                    end
                end
            end
        end
        return bestObj
    end

    function utility:Draw(class, properties)
        local blacklistedProperties = {'Object','Children','Class'}
        local drawing = {
            Object = safeCreateDrawing(class);
            Children = {};
            ThemeColor = '';
            OutlineThemeColor = '';
            ThemeColorOffset = 0;
            OutlineThemeColorOffset = 0;
            Parent = nil;
            Size = newUDim2(0,0,0,0);
            Position = newUDim2(0,0,0,0);
            AbsoluteSize = newVector2(0,0);
            AbsolutePosition = newVector2(0,0);
            Hover = false;
            Visible = true;
            MouseButton1Down = library.signal.new();
            MouseButton2Down = library.signal.new();
            MouseButton1Up = library.signal.new();
            MouseButton2Up = library.signal.new();
            MouseEnter = library.signal.new();
            MouseLeave = library.signal.new();
            Class = class;
        }

        drawing.MouseButton1Down._owner = drawing;
        drawing.MouseButton2Down._owner = drawing;
        drawing.MouseButton1Up._owner = drawing;
        drawing.MouseButton2Up._owner = drawing;
        drawing.MouseEnter._owner = drawing;
        drawing.MouseLeave._owner = drawing;

        function drawing:Update()
            -- if drawing.Parent then
                local parent = drawing.Parent ~= nil and library.drawings[drawing.Parent.Object] or nil
                local parentSize,parentPos,parentVis = workspace.CurrentCamera.ViewportSize, Vector2.new(0,0), true;
                if parent ~= nil then
                    parentSize = (parent.Class == 'Square' or parent.Class == 'Image') and parent.Object.Size or parent.Class == 'Text' and parent.TextBounds or workspace.CurrentCamera.ViewportSize
                    parentPos = parent.Object.Position
                    parentVis = parent.Object.Visible
                end

                if drawing.Class == 'Square' or drawing.Class == 'Image' then
                    drawing.Object.Size = typeof(drawing.Size) == 'Vector2' and drawing.Size or typeof(drawing.Size) == 'UDim2' and utility:UDim2ToVector2(drawing.Size,parentSize)
                end

                if drawing.Class == 'Square' or drawing.Class == 'Image' or drawing.Class == 'Circle' or drawing.Class == 'Text' then
                    drawing.Object.Position = parentPos + (typeof(drawing.Position) == 'Vector2' and drawing.Position or utility:UDim2ToVector2(drawing.Position,parentSize))
                end

                drawing.Object.Visible = (parentVis and drawing.Visible) and true or false

            -- end
            drawing:UpdateChildren()
        end

        function drawing:UpdateChildren()
            for child in next, drawing.Children do
                child:Update()
            end
        end

        function drawing:GetDescendants()
            local descendants = {};
            local function a(t)
                for child in next, t.Children do
                    table.insert(descendants, child);
                    a(child)
                end
            end
            a(self)
            return descendants;
        end

        library.drawings[drawing.Object] = drawing

        -- this is really stupid lol
        local proxy = utility:DetectTableChange(
        function(obj,i)
            return drawing[i] == nil and drawing.Object[i] or drawing[i]
        end,
        function(obj,i,v)
            if not table.find(blacklistedProperties,i) then

                local lastval = drawing[i]

                if i == 'Size' and (class == 'Square' or class == 'Image') then
                    drawing.Object.Size = utility:UDim2ToVector2(v,drawing.Parent == nil and workspace.CurrentCamera.ViewportSize or drawing.Parent.Object.Size);
                    drawing.AbsoluteSize = drawing.Object.Size;
                elseif i == 'Position' and (class == 'Square' or class == 'Image' or class == 'Text') then
                    drawing.Object.Position =  utility:UDim2ToVector2(v,drawing.Parent == nil and newVector2(0,0) or drawing.Parent.Object.Position);
                    drawing.AbsolutePosition = drawing.Object.Position;
                elseif i == 'Parent' then
                    if drawing.Parent ~= nil and drawing.Parent.Children then
                        drawing.Parent.Children[drawing] = nil
                    end
                    if v ~= nil and v.Children then
                        v.Children[drawing] = true
                    end
                elseif i == 'Visible' then
                    drawing.Visible = v
                elseif i == 'Font' and v == 2 and executor == 'ScriptWare' then
                    v = 1
                end

                pcall(function()
                    drawing.Object[i] = v
                end)
                if drawing[i] ~= nil or i == 'Parent' then
                    drawing[i] = v
                end

                if table.find({'Size','Position','Position','Visible','Parent'},i) then
                    drawing:Update()
                end
                if table.find({'ThemeColor','OutlineThemeColor','ThemeColorOffset','OutlineThemeColorOffset'},i) and lastval ~= v then
                    library.UpdateThemeColors()
                end

            end
        end)

        function drawing:Remove()
            for child in next, self.Children do
                child:Remove();
            end

            if drawing.Parent and drawing.Parent.Children then
                drawing.Parent.Children[drawing] = nil;
            end

            library.drawings[drawing.Object] = nil;
            library.interactiveDrawings[drawing.Object] = nil;
            drawing.Object:Remove();
            table.clear(drawing);

        end

        properties = typeof(properties) == 'table' and properties or {}

        if class == 'Square' and properties.Filled == nil then
            properties.Filled = true;
        end

        if properties.Visible == nil then
            properties.Visible = true;
        end

        for i,v in next, properties do
            proxy[i] = v
        end

        drawing:Update()
        return proxy
    end
end

library.utility = utility

function library:Unload()
    library.unloaded:Fire();
    pcall(function()
        inputservice.MouseIconEnabled = true
    end)
    for _,c in next, self.connections do
        c:Disconnect()
    end
    for obj in next, self.drawings do
        obj:Remove()
    end
    table.clear(self.drawings)
    getgenv().library = nil
end

function library:init()
    if self.hasInit then
        return
    end

    local tooltipObjects = {};

    local function safeMakeFolder(path)
        pcall(function()
            if isfolder then
                if not isfolder(path) then makefolder(path) end
            elseif makefolder then
                makefolder(path)
            end
        end)
    end

    safeMakeFolder(self.cheatname)
    safeMakeFolder(self.cheatname..'/assets')
    safeMakeFolder(self.cheatname..'/'..self.gamename)
    safeMakeFolder(self.cheatname..'/'..self.gamename..'/configs');

    function self:SetTheme(theme)
        for i,v in next, theme do
            self.theme[i] = v;
        end
        self.UpdateThemeColors();
    end

    function self:GetConfig(name)
        if isfile(self.cheatname..'/'..self.gamename..'/configs/'..name..self.fileext) then
            return readfile(self.cheatname..'/'..self.gamename..'/configs/'..name..self.fileext);
        end
    end

    function self:LoadConfig(name)
        local cfg = self:GetConfig(name)
        if not cfg then
            self:SendNotification('Error loading config: Config does not exist. ('..tostring(name)..')', 5, c3new(1,0,0));
            return
        end

        local s,e = pcall(function()
            setByConfig = true
            for flag,value in next, http:JSONDecode(cfg) do
                local option = library.options[flag]
                if option ~= nil then
                    if option.class == 'toggle' then
                        option:SetState(value == nil and false or (value == 1 and true or false));
                    elseif option.class == 'slider' then
                        option:SetValue(value == nil and 0 or value)
                    elseif option.class == 'bind' then
                        option:SetBind(value == nil and 'none' or (utility:HasProperty(Enum.KeyCode, value) and Enum.KeyCode[value] or Enum.UserInputType[value]));
                    elseif option.class == 'color' then
                        option:SetColor(value == nil and c3new(1,1,1) or c3new(value[1], value[2], value[3]));
                        option:SetTrans(value == nil and 1 or value[4]);
                    elseif option.class == 'list' then
                        option:Select(value == nil and '' or value);
                    elseif option.class == 'box' then
                        option:SetInput(value == nil and '' or value)
                    end
                end
            end
            setByConfig = false
        end)

        if s then
            self:SendNotification('Successfully loaded config: '..name, 5, c3new(0,1,0));
        else
            self:SendNotification('Error loading config: '..tostring(e)..'. ('..tostring(name)..')', 5, c3new(1,0,0));
        end
    end

    function self:SaveConfig(name)
        if not self:GetConfig(name) then
            self:SendNotification('Error saving config: Config does not exist. ('..tostring(name)..')', 5, c3new(1,0,0));
            return
        end

        local s,e = pcall(function()
            local cfg = {};
            for flag,option in next, self.options do
                if option.class == 'toggle' then
                    cfg[flag] = option.state and 1 or 0;
                elseif option.class == 'slider' then
                    cfg[flag] = option.value;
                elseif option.class == 'bind' then
                    cfg[flag] = option.bind.Name;
                elseif option.class == 'color' then
                    cfg[flag] = {
                        option.color.r,
                        option.color.g,
                        option.color.b,
                        option.trans,
                    }
                elseif option.class == 'list' then
                    cfg[flag] = option.selected;
                elseif option.class == 'box' then
                    cfg[flag] = option.input
                end
            end
            writefile(self.cheatname..'/'..self.gamename..'/configs/'..name..self.fileext, http:JSONEncode(cfg));
        end)

        if s then
            self:SendNotification('Successfully saved config: '..name, 5, c3new(0,1,0));
        else
            self:SendNotification('Error saving config: '..tostring(e)..'. ('..tostring(name)..')', 5, c3new(1,0,0));
        end
    end

    for i,v in next, self.images do
        pcall(function()
            local assetPath = self.cheatname..'/assets/'..i..'.oh'
            if isfile and not isfile(assetPath) then
                if writefile then
                    writefile(assetPath, game:HttpGet(v))
                end
            end
            if readfile and isfile and isfile(assetPath) then
                self.images[i] = readfile(assetPath);
            end
        end)
    end

    self.cursor1 = utility:Draw('Triangle', {Filled = true, Color = fromrgb(255,255,255), ZIndex = 999999});
    self.cursor2 = utility:Draw('Triangle', {Filled = true, Color = fromrgb(20,20,20), ZIndex = 999998});
    local function updateCursor()
        self.cursor1.Visible = self.open
        self.cursor2.Visible = self.open
        if self.cursor1.Visible then
            local pos = inputservice:GetMouseLocation();
            self.cursor1.PointA = pos;
            self.cursor1.PointB = pos + newVector2(0, 16);
            self.cursor1.PointC = pos + newVector2(11, 11);
            self.cursor2.PointA = pos - newVector2(1, 1);
            self.cursor2.PointB = pos + newVector2(-1, 18);
            self.cursor2.PointC = pos + newVector2(13, 13);
        end
    end

    local screenGui = Instance.new('ScreenGui');
    if gethui then
        screenGui.Parent = gethui()
    elseif syn and syn.protect_gui then
        syn.protect_gui(screenGui)
        screenGui.Parent = game:GetService('CoreGui')
    else
        local s = pcall(function()
            screenGui.Parent = game:GetService('CoreGui')
        end)
        if not s then
            pcall(function()
                screenGui.Parent = localplayer:WaitForChild('PlayerGui')
            end)
        end
    end
    screenGui.Enabled = true;
    utility:Instance('ImageButton', {
        Parent = screenGui,
        Visible = true,
        Modal = true,
        Size = UDim2.new(1,0,1,0),
        ZIndex = 9999999999,
        Transparency = 1;
    })

    utility:Connection(library.unloaded, function()
        screenGui:Destroy()
    end)

    utility:Connection(inputservice.InputBegan, function(input, gpe)
        if self.hasInit then
            if input.KeyCode == self.toggleKey and not library.opening and not gpe then
                self:SetOpen(not self.open)
                task.spawn(function()
                    library.opening = true;
                    task.wait(.15);
                    library.opening = false;
                end)
            end
            if library.open then
                local hoverObj = utility:GetHoverObject();
                local hoverObjData = library.drawings[hoverObj];
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    mb1down = true;
                    button1down:Fire()
                    if hoverObj and hoverObjData then
                        hoverObjData.MouseButton1Down:Fire(inputservice:GetMouseLocation())
                    end

                    -- // Update Sliders Click
                    if library.draggingSlider ~= nil then
                        local rel = inputservice:GetMouseLocation() - library.draggingSlider.objects.background.Object.Position;
                        local val = utility:ConvertNumberRange(rel.X, 0 , library.draggingSlider.objects.background.Object.Size.X, library.draggingSlider.min, library.draggingSlider.max);
                        library.draggingSlider:SetValue(val)
                    end

                elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
                    if hoverObj and hoverObjData then
                        hoverObjData.MouseButton2Down:Fire(inputservice:GetMouseLocation())
                    end
                end
            end
        end
    end)

    utility:Connection(inputservice.InputEnded, function(input, gpe)
        if self.hasInit and library.open then
            local hoverObj = utility:GetHoverObject();
            local hoverObjData = library.drawings[hoverObj];

            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                mb1down = false;
                button1up:Fire();
                if hoverObj and hoverObjData then
                    hoverObjData.MouseButton1Up:Fire(inputservice:GetMouseLocation())
                end
            elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
                if hoverObj and hoverObjData then
                    hoverObjData.MouseButton2Up:Fire(inputservice:GetMouseLocation())
                end
            end
        end
    end)

    local lastHoverData = nil
    utility:Connection(inputservice.InputChanged, function(input, gpe)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            if library.open then
                local mousePos = inputservice:GetMouseLocation()
                mousemove:Fire(mousePos);
                updateCursor();

                if library.CurrentTooltip ~= nil then
                    tooltipObjects.background.Position = UDim2.new(0,mousePos.X + 15,0,mousePos.Y + 15)
                    tooltipObjects.background.Size = UDim2.new(0,tooltipObjects.text.TextBounds.X + 6 + (library.CurrentTooltip.risky and 60 or 0),0,tooltipObjects.text.TextBounds.Y + 2)
                end

                local hoverObj = utility:GetHoverObject();
                local hoverData = hoverObj and library.drawings[hoverObj]
                if hoverData ~= lastHoverData then
                    if lastHoverData and lastHoverData.Hover then
                        lastHoverData.Hover = false
                        lastHoverData.MouseLeave:Fire(mousePos)
                    end
                    if hoverData and not hoverData.Hover then
                        hoverData.Hover = true
                        hoverData.MouseEnter:Fire(mousePos)
                    end
                    lastHoverData = hoverData
                end

                if mb1down then

                    -- // Update Sliders Drag
                    if library.draggingSlider ~= nil then
                        local rel = mousePos - library.draggingSlider.objects.background.Object.Position;
                        local val = utility:ConvertNumberRange(rel.X, 0 , library.draggingSlider.objects.background.Object.Size.X, library.draggingSlider.min, library.draggingSlider.max);
                        library.draggingSlider:SetValue(val)
                    end

                end
            end
        end
    end)
    
    function self:SetOpen(bool)
        self.open = bool;
        screenGui.Enabled = bool;
        pcall(function()
            inputservice.MouseIconEnabled = not bool
        end)

        if bool and library.flags.disablemenumovement then
            actionservice:BindAction(
                'FreezeMovement',
                function()
                    return Enum.ContextActionResult.Sink
                end,
                false,
                unpack(Enum.PlayerActions:GetEnumItems())
            )
        else
            actionservice:UnbindAction('FreezeMovement');
        end

        updateCursor();
        for _,window in next, self.windows do
            window:SetOpen(bool);
        end

        library.CurrentTooltip = nil;
        tooltipObjects.background.Visible = false
    end

    function self.UpdateThemeColors()
        for _,v in next, library.drawings do
            if v.ThemeColor and library.theme[v.ThemeColor] then
                v.Object.Color = utility:AddRGB(library.theme[v.ThemeColor],fromrgb(v.ThemeColorOffset,v.ThemeColorOffset,v.ThemeColorOffset))
            end
            if v.ThemeColorOutline and library.theme[v.ThemeColorOutline] then
                v.Object.OutlineColor = utility:AddRGB(library.theme[v.ThemeColorOutline],fromrgb(v.OutlineThemeColorOffset,v.OutlineThemeColorOffset,v.OutlineThemeColorOffset))
            end
        end
    end

    function self:SendNotification(message, time, color)
        time = time or 5
        if typeof(message) ~= 'string' then
            return error(string.format('invalid message type, got %s, expected string', typeof(message)))
        elseif typeof(time) ~= 'number' then
            return error(string.format('invalid time type, got %s, expected number', typeof(time)))
        elseif color ~= nil and typeof(color) ~= 'Color3' then
            return error(string.format('invalid color type, got %s, expected color3', typeof(time)))
        end

        local notification = {};

        self.notifications[notification] = true

        do
            local objs = notification;
            local z = self.zindexOrder.notification;

            notification.holder = utility:Draw('Square', {
                Position = newUDim2(0, 0, 0, 75);
                Transparency = 0;
            })
            
            notification.background = utility:Draw('Square', {
                Size = newUDim2(1,0,1,0);
                Position = newUDim2(0, -500, 0, 0);
                Parent = notification.holder;
                ThemeColor = 'Background';
                ZIndex = z;
            })

            notification.border1 = utility:Draw('Square', {
                Size = newUDim2(1,2,1,2);
                Position = newUDim2(0,-1,0,-1);
                ThemeColor = 'Border 2';
                Parent = notification.background;
                ZIndex = z-1;
            })

            objs.border2 = utility:Draw('Square', {
                Size = newUDim2(1,2,1,2);
                Position = newUDim2(0,-1,0,-1);
                ThemeColor = 'Border 3';
                Parent = objs.border1;
                ZIndex = z-2;
            })

            notification.gradient = utility:Draw('Image', {
                Size = newUDim2(1,0,1,0);
                Data = self.images.gradientp90;
                Parent = notification.background;
                Transparency = .5;
                ZIndex = z+1;
            })

            notification.accentBar = utility:Draw('Square',{
                Size = newUDim2(0,5,1,4);
                Position = newUDim2(0,0,0,-2);
                Parent = notification.background;
                ThemeColor = color == nil and 'Accent' or '';
                ZIndex = z+5;
            })

            notification.text = utility:Draw('Text', {
                Position = newUDim2(0,13,0,2);
                ThemeColor = 'Primary Text';
                Text = message;
                Outline = true;
                Font = 2;
                Size = 13;
                ZIndex = z+4;
                Parent = notification.background;
            })

            if color then
                notification.accentBar.Color = color;
            end

        end

        function notification:Remove()
            library.notifications[notification] = nil;
            self.holder:Remove();
            library:UpdateNotifications()
        end

        task.spawn(function()
            self:UpdateNotifications();
            notification.background.Size = newUDim2(0, notification.text.TextBounds.X + 20, 0, 19)
            task.wait();
            utility:Tween(notification.background, 'Position', newUDim2(0,0,0, 0), .1);
            task.wait(time);
            for i,v in next, notification do
                if typeof(v) ~= 'function' then
                    utility:Tween(v, 'Transparency', 0, .15);
                end
            end
            utility:Connection(utility:Tween(notification.background, 'Position', newUDim2(0,-500,0, 0), .25).Completed, (function()
                notification:Remove();
            end))
        end)

    end

    function self:UpdateNotifications()
        local i = 0
        for v in next, self.notifications do
            utility:Tween(v.holder, 'Position', newUDim2(0,0,0, 75 + (i * 30)), .15)
            i += 1
        end
    end

    function self.NewIndicator(data)
        local indicator = {
            title = data.title or 'indicator',
            enabled = data.enabled or false,
            position = data.position or newUDim2(0,15,0,300),
            values = {},
            objects = {valueObjects = {}},
            spacing = '   ',
        };

        table.insert(self.indicators, indicator)

        -- Create Objects --
        do
            local z = self.zindexOrder.indicator;
            local objs = indicator.objects;

            objs.background = utility:Draw('Square', {
                Size = newUDim2(0, 200, 0, 16);
                Position = indicator.position;
                ThemeColor = 'Background';
                ZIndex = z;
            })

            objs.border1 = utility:Draw('Square', {
                Size = newUDim2(1,2,1,2);
                Position = newUDim2(0,-1,0,-1);
                ThemeColor = 'Border 2';
                Parent = objs.background;
                ZIndex = z-1;
            })

            objs.border2 = utility:Draw('Square', {
                Size = newUDim2(1,2,1,2);
                Position = newUDim2(0,-1,0,-1);
                ThemeColor = 'Border 3';
                Parent = objs.border1;
                ZIndex = z-2;
            })

            objs.topborder = utility:Draw('Square', {
                Size = newUDim2(1,0,0,1);
                ThemeColor = 'Accent';
                Parent = objs.background;
                ZIndex = z+1;
            })

            objs.textlabel = utility:Draw('Text', {
                Position = newUDim2(.5,0,0,1);
                ThemeColor = 'Primary Text';
                Text = indicator.title;
                Size = 13;
                Font = 2;
                ZIndex = z+2;
                Center = true;
                Outline = true;
                Parent = objs.background;
            });

            local indDragging = false
            local indMouseStart, indObjStart

            utility:Connection(objs.background.MouseButton1Down, function(pos)
                if library.open then
                    indDragging = true
                    indMouseStart = newVector2(pos.X, pos.Y)
                    indObjStart = objs.background.Object.Position
                end
            end)

            utility:Connection(button1up, function()
                indDragging = false
            end)

            utility:Connection(runservice.RenderStepped, function()
                if indDragging and library.open then
                    local mPos = inputservice:GetMouseLocation()
                    local delta = mPos - indMouseStart
                    local target = indObjStart + delta
                    indicator.position = newUDim2(0, target.X, 0, target.Y)
                    objs.background.Position = indicator.position
                else
                    indDragging = false
                end
            end)

        end
        --------------------

        function indicator:Update()
            local xSize  = 190
            local yPos  = 0
            table.sort(self.values, function(a,b)
                return a.order < b.order;
            end)

            for _,v in next, self.values do
                v.objects.keyLabel.Text = tostring(v.key);
                v.objects.valueLabel.Text = tostring(v.value);
            
                v.objects.valueLabel.Position = newUDim2(1,-(v.objects.valueLabel.TextBounds.X + 5),0,0)
                v.objects.background.Position = newUDim2(0,0,1,3 + yPos)
                v.objects.background.Visible = v.enabled and self.enabled

                if v.enabled and self.enabled then
                    yPos = yPos + 16 + 3
                    local x = (v.objects.keyLabel.TextBounds.X + 16 + v.objects.valueLabel.TextBounds.X)
                    if x > xSize then
                        xSize = x
                    end
                end
            end

            self.objects.background.Size = newUDim2(0,xSize + 10,0,16)
            self.objects.background.Position = self.position
        end

        function indicator:AddValue(data)
            local value = {
                key = data.key or '',
                value = data.value or '',
                order = data.order or #self.values+1,
                enabled = data.enabled == nil and true or data.enabled,
                objects = {},
            }

            table.insert(self.values, value);

            -- Create Objects --
            do
                local z = library.zindexOrder.indicator;
                local objs = value.objects;

                objs.background = utility:Draw('Square', {
                    Size = newUDim2(1, 0, 0, 16);
                    ThemeColor = 'Background';
                    ZIndex = z;
                    Parent = indicator.objects.background;
                })
    
                objs.border1 = utility:Draw('Square', {
                    Size = newUDim2(1,2,1,2);
                    Position = newUDim2(0,-1,0,-1);
                    ThemeColor = 'Border 2';
                    Parent = objs.background;
                    ZIndex = z-1;
                })
    
                objs.border2 = utility:Draw('Square', {
                    Size = newUDim2(1,2,1,2);
                    Position = newUDim2(0,-1,0,-1);
                    ThemeColor = 'Border 3';
                    Parent = objs.border1;
                    ZIndex = z-2;
                })
    
                objs.keyLabel = utility:Draw('Text', {
                    Position = newUDim2(0,3,0,1);
                    ThemeColor = 'Option Text 2';
                    Size = 13;
                    Font = 2;
                    ZIndex = z+2;
                    Outline = true;
                    Parent = objs.background;
                });

                objs.valueLabel = utility:Draw('Text', {
                    Position = newUDim2(0,0,0,1);
                    ThemeColor = 'Option Text 2';
                    Size = 13;
                    Font = 2;
                    ZIndex = z+2;
                    Outline = true;
                    Parent = objs.background;
                });

            end
            --------------------

            function value:Remove()
                table.remove(indicator.values, table.find(indicator.values, value))
                self.objects.background:Remove()
                table.clear(self)
                indicator:Update();
            end

            function value:SetEnabled(bool)
                if typeof(bool) == 'boolean' then
                    self.enabled = bool
                    indicator:Update()
                end
            end

            function value:SetValue(str)
                if typeof(str) == 'string' then
                    self.value = str
                    indicator:Update()
                end
            end

            function value:SetKey(str)
                if typeof(str) == 'string' then
                    self.key = str
                    indicator:Update()
                end
            end

            self:Update()
            return value
        end

        function indicator:GetValue(idx)
            if typeof(idx) == 'number' then
                return self.values[idx]
            else
                for i,v in next, self.values do
                    if v.key == idx then
                        return v
                    end
                end
            end
        end

        function indicator:SetEnabled(bool)
            if typeof(bool) == 'boolean' then
                self.enabled = bool;
                self.objects.background.Visible = bool;
                self:Update();
            end
        end

        function indicator:SetPosition(udim2)
            if typeof(udim2) == 'UDim2' then
                self.position = udim2
                self.objects.background.Position = udim2;
            end
        end

        for i,v in next, data.values or {} do
            indicator:AddValue({key = tostring(i), value = tostring(v)})
        end

        indicator:SetEnabled(indicator.enabled);
        return indicator
    end

    function self.NewWindow(data)
        local window = {
            title = data.title or '',
            selectedTab = nil;
            tabs = {},
            objects = {},
            colorpicker = {
                objects = {};
                color = c3new(1,0,0);
                trans = 0;
            };
            dropdown = {
                objects = {
                    values = {};
                };
                max = 5;
            }
        };

        table.insert(library.windows, window);

        ----- Create Objects ----
        do
            local size = data.size or newUDim2(0, 525, 0, 650);
            local position = data.position or newUDim2(0, 250, 0, 150);
            local objs = window.objects;
            local z = library.zindexOrder.window;

            objs.background = utility:Draw('Square', {
                Size = size;
                Position = position;
                ThemeColor = 'Background';
                ZIndex = z;
            })

            objs.innerBorder1 = utility:Draw('Square', {
                Size = newUDim2(1,2,1,2);
                Position = newUDim2(0,-1,0,-1);
                ThemeColor = 'Border 3';
                ZIndex = z-1;
                Parent = objs.background;
            })

            objs.innerBorder2 = utility:Draw('Square', {
                Size = newUDim2(1,2,1,2);
                Position = newUDim2(0,-1,0,-1);
                ThemeColor = 'Border 1';
                ZIndex = z-2;
                Parent = objs.innerBorder1;
            })

            objs.midBorder = utility:Draw('Square', {
                Size = newUDim2(1,10,1,25);
                Position = newUDim2(0,-5,0,-20);
                ThemeColor = 'Border 2';
                ZIndex = z-3;
                Parent = objs.innerBorder2;
            })

            objs.outerBorder1 = utility:Draw('Square', {
                Size = newUDim2(1,2,1,2);
                Position = newUDim2(0,-1,0,-1);
                ThemeColor = 'Border 1';
                ZIndex = z-4;
                Parent = objs.midBorder;
            })

            objs.outerBorder2 = utility:Draw('Square', {
                Size = newUDim2(1,2,1,2);
                Position = newUDim2(0,-1,0,-1);
                ThemeColor = 'Border 3';
                ZIndex = z-5;
                Parent = objs.outerBorder1;
            })

            objs.topBorder = utility:Draw('Square', {
                Size = newUDim2(1,0,0,1);
                ThemeColor = 'Accent';
                ZIndex = z+1;
                Parent = objs.background;
            })

            objs.title = utility:Draw('Text', {
                Position = newUDim2(0,7,0,2);
                ThemeColor = 'Primary Text';
                Text = window.title;
                Font = 2;
                Size = 13;
                ZIndex = z+1;
                Outline = true;
                Parent = objs.midBorder;
            })

            objs.groupBackground = utility:Draw('Square', {
                Size = newUDim2(1,-16,1,-(16+23));
                Position = newUDim2(0,8,0,8+23);
                ThemeColor = 'Group Background';
                ZIndex = z+5;
                Parent = objs.background;
            })

            objs.groupInnerBorder = utility:Draw('Square', {
                Size = newUDim2(1,2,1,2);
                Position = newUDim2(0,-1,0,-1);
                ThemeColor = 'Border 1';
                ZIndex = z+4;
                Parent = objs.groupBackground;
            })

            objs.groupOuterBorder = utility:Draw('Square', {
                Size = newUDim2(1,2,1,2);
                Position = newUDim2(0,-1,0,-1);
                ThemeColor = 'Border 3';
                ZIndex = z+3;
                Parent = objs.groupInnerBorder;
            })

            objs.tabHolder = utility:Draw('Square', {
                Size = newUDim2(1,0,0,24);
                Position = newUDim2(0,0,0,-25);
                Parent = objs.groupBackground;
                Transparency = 0;
                ZIndex = z+1;
            })

            objs.columnholder1 = utility:Draw('Square', {
                Size = newUDim2(.48, 0, .96, 0);
                Position = newUDim2(.01, 0, .02, 0);
                Transparency = 0;
                ZIndex = z+6;
                Parent = objs.groupBackground;
            })

            objs.columnholder2 = utility:Draw('Square', {
                Size = newUDim2(.48, 0, .96, 0);
                Position = newUDim2(1 - (.48 + .01), 0, .02, 0);
                Transparency = 0;
                ZIndex = z+6;
                Parent = objs.groupBackground;
            })


            objs.dragdetector = utility:Draw('Square',{
                Size = newUDim2(1,0,1,0);
                Parent = objs.midBorder;
                Transparency = 0;
                ZIndex = z+2;
            })

            local dragging, mouseStart, objStart;
            local lastDragPx, lastDragPy = -9999, -9999;

            utility:Connection(objs.dragdetector.MouseButton1Down, function(pos)
                if window.open then
                    dragging = true;
                    library.isDragging = true;
                    mouseStart = newVector2(pos.X, pos.Y);
                    objStart = objs.background.Object.Position;
                end
            end)

            utility:Connection(button1up, function()
                dragging = false;
                library.isDragging = false;
            end)

            utility:Connection(runservice.RenderStepped, function()
                if dragging and window.open then
                    library.isDragging = true;
                    local mPos = inputservice:GetMouseLocation()
                    local delta = mPos - mouseStart
                    local target = objStart + delta
                    local px, py = math.floor(target.X), math.floor(target.Y)
                    if px ~= lastDragPx or py ~= lastDragPy then
                        lastDragPx, lastDragPy = px, py
                        objs.background.Position = newUDim2(0, px, 0, py)
                    end
                else
                    dragging = false;
                    library.isDragging = false;
                end
            end)

        end
        -------------------------

        -- Create Color Picker --
        do
            local function hexToC3(hex)
                if typeof(hex) ~= 'string' then return nil end
                hex = hex:gsub('#', ''):gsub('%s+', '')
                if #hex == 6 then
                    local r = tonumber(hex:sub(1, 2), 16)
                    local g = tonumber(hex:sub(3, 4), 16)
                    local b = tonumber(hex:sub(5, 6), 16)
                    if r and g and b then
                        return Color3.fromRGB(r, g, b)
                    end
                end
                return nil
            end

            local function c3ToHex(c3)
                local r = math.floor(clamp(c3.R, 0, 1) * 255)
                local g = math.floor(clamp(c3.G, 0, 1) * 255)
                local b = math.floor(clamp(c3.B, 0, 1) * 255)
                return string.format("#%02X%02X%02X", r, g, b)
            end

            -- Objects
            do
                local objs = window.colorpicker.objects;
                local z = library.zindexOrder.colorpicker;

                objs.background = utility:Draw('Square', {
                    Visible = false;
                    Size = newUDim2(0, 224, 0, 206);
                    Position = newUDim2(1, -224, 1, 6);
                    ThemeColor = 'Background';
                    ZIndex = z;
                    Parent = window.objects.background;
                })

                objs.border1 = utility:Draw('Square', {
                    Size = newUDim2(1,2,1,2);
                    Position = newUDim2(0,-1,0,-1);
                    ThemeColor = 'Border';
                    ZIndex = z-1;
                    Parent = objs.background;
                })

                objs.border2 = utility:Draw('Square', {
                    Size = newUDim2(1,2,1,2);
                    Position = newUDim2(0,-1,0,-1);
                    ThemeColor = 'Border 1';
                    ZIndex = z-2;
                    Parent = objs.border1;
                })

                objs.border3 = utility:Draw('Square', {
                    Size = newUDim2(1,2,1,2);
                    Position = newUDim2(0,-1,0,-1);
                    ThemeColor = 'Border';
                    ZIndex = z-3;
                    Parent = objs.border2;
                })

                -- Header: Title + Close Button
                objs.statusText = utility:Draw('Text', {
                    Position = newUDim2(0, 8, 0, 6);
                    Text = 'Edit Color';
                    ThemeColor = 'Primary Text';
                    Size = 13;
                    Font = 2;
                    Outline = true;
                    ZIndex = z+1;
                    Parent = objs.background;
                })

                objs.closeBtn = utility:Draw('Text', {
                    Position = newUDim2(1, -16, 0, 5);
                    Text = '×';
                    Color = fromrgb(170, 170, 170);
                    Size = 14;
                    Font = 2;
                    Outline = true;
                    ZIndex = z+2;
                    Parent = objs.background;
                })

                objs.closeDetector = utility:Draw('Square', {
                    Size = newUDim2(0, 18, 0, 18);
                    Position = newUDim2(1, -20, 0, 3);
                    Transparency = 0;
                    ZIndex = z+10;
                    Parent = objs.background;
                })

                utility:Connection(objs.closeDetector.MouseEnter, function()
                    objs.closeBtn.Color = fromrgb(255, 255, 255);
                end)
                utility:Connection(objs.closeDetector.MouseLeave, function()
                    objs.closeBtn.Color = fromrgb(170, 170, 170);
                end)
                utility:Connection(objs.closeDetector.MouseButton1Down, function()
                    if window.colorpicker.selected then
                        window.colorpicker.selected:SetOpen(false);
                    end
                end)

                -- Main Saturation / Value Gradient Palette (16x8 Procedural Matrix - 100% bug free)
                objs.mainColor = utility:Draw('Square', {
                    Size = newUDim2(0, 208, 0, 104);
                    Position = newUDim2(0, 8, 0, 26);
                    Color = fromrgb(20, 20, 20);
                    ZIndex = z+2;
                    Parent = objs.background;
                })

                objs.colorBorder = utility:Draw('Square', {
                    Size = newUDim2(1, 2, 1, 2);
                    Position = newUDim2(0, -1, 0, -1);
                    ThemeColor = 'Border';
                    ZIndex = z+1;
                    Parent = objs.mainColor;
                })

                objs.paletteCells = {}
                local gridCols, gridRows = 16, 8
                local cellW, cellH = 13, 13
                for col = 0, gridCols - 1 do
                    local s = col / (gridCols - 1)
                    for row = 0, gridRows - 1 do
                        local v = 1 - (row / (gridRows - 1))
                        local cell = utility:Draw('Square', {
                            Size = newUDim2(0, cellW, 0, cellH);
                            Position = newUDim2(0, col * cellW, 0, row * cellH);
                            Color = fromhsv(1, s, v);
                            ZIndex = z+3;
                            Parent = objs.mainColor;
                        })
                        table.insert(objs.paletteCells, {sq = cell, s = s, v = v})
                    end
                end

                objs.pointer = utility:Draw('Square', {
                    Size = newUDim2(0, 5, 0, 5);
                    Position = newUDim2(0, 0, 0, 0);
                    Color = c3new(1, 1, 1);
                    ZIndex = z+7;
                    Parent = objs.mainColor;
                })

                objs.pointerBorder = utility:Draw('Square', {
                    Size = newUDim2(1, 2, 1, 2);
                    Position = newUDim2(0, -1, 0, -1);
                    Color = c3new(0, 0, 0);
                    ZIndex = z+6;
                    Parent = objs.pointer;
                })

                objs.mainDetector = utility:Draw('Square', {
                    Size = newUDim2(1, 0, 1, 0);
                    Transparency = 0;
                    ZIndex = z+10;
                    Parent = objs.mainColor;
                })

                -- Sliders: Rainbow Hue Bar (Horizontal)
                objs.hue = utility:Draw('Square', {
                    Size = newUDim2(0, 174, 0, 12);
                    Position = newUDim2(0, 8, 0, 136);
                    Color = c3new(1,0,0);
                    ZIndex = z+2;
                    Parent = objs.background;
                })

                objs.hueSegments = {}
                local segCount = 29
                local segWidth = 174 / segCount
                for seg = 0, segCount - 1 do
                    local segHue = seg / segCount
                    local segSquare = utility:Draw('Square', {
                        Size = newUDim2(0, math.ceil(segWidth), 1, 0);
                        Position = newUDim2(0, math.floor(seg * segWidth), 0, 0);
                        Color = fromhsv(segHue, 1, 1);
                        ZIndex = z+3;
                        Parent = objs.hue;
                    })
                    table.insert(objs.hueSegments, segSquare)
                end

                objs.hueBorder = utility:Draw('Square', {
                    Size = newUDim2(1, 2, 1, 2);
                    Position = newUDim2(0, -1, 0, -1);
                    ThemeColor = 'Border';
                    ZIndex = z+1;
                    Parent = objs.hue;
                })

                objs.hueSlider = utility:Draw('Square', {
                    Size = newUDim2(0, 3, 1, 2);
                    Position = newUDim2(0, 0, 0, -1);
                    Color = c3new(1, 1, 1);
                    ZIndex = z+6;
                    Parent = objs.hue;
                })

                objs.hueSliderBorder = utility:Draw('Square', {
                    Size = newUDim2(1, 2, 1, 2);
                    Position = newUDim2(0, -1, 0, -1);
                    Color = c3new(0, 0, 0);
                    ZIndex = z+5;
                    Parent = objs.hueSlider;
                })

                objs.hueDetector = utility:Draw('Square', {
                    Size = newUDim2(1, 0, 1, 0);
                    Transparency = 0;
                    ZIndex = z+10;
                    Parent = objs.hue;
                })

                -- Sliders: Opacity / Alpha Transparency Bar (Dynamic color-to-dark gradient)
                objs.transColor = utility:Draw('Square', {
                    Size = newUDim2(0, 174, 0, 12);
                    Position = newUDim2(0, 8, 0, 153);
                    Color = fromrgb(22, 22, 24);
                    ZIndex = z+2;
                    Parent = objs.background;
                })

                objs.transSegments = {}
                local transCount = 20
                local transWidth = 174 / transCount
                for seg = 0, transCount - 1 do
                    local transSq = utility:Draw('Square', {
                        Size = newUDim2(0, math.ceil(transWidth), 1, 0);
                        Position = newUDim2(0, math.floor(seg * transWidth), 0, 0);
                        Color = c3new(1, 1, 1);
                        ZIndex = z+3;
                        Parent = objs.transColor;
                    })
                    table.insert(objs.transSegments, transSq)
                end

                objs.transBorder = utility:Draw('Square', {
                    Size = newUDim2(1, 2, 1, 2);
                    Position = newUDim2(0, -1, 0, -1);
                    ThemeColor = 'Border';
                    ZIndex = z+1;
                    Parent = objs.transColor;
                })

                objs.transSlider = utility:Draw('Square', {
                    Size = newUDim2(0, 3, 1, 2);
                    Position = newUDim2(0, 0, 0, -1);
                    Color = c3new(1, 1, 1);
                    ZIndex = z+6;
                    Parent = objs.transColor;
                })

                objs.transSliderBorder = utility:Draw('Square', {
                    Size = newUDim2(1, 2, 1, 2);
                    Position = newUDim2(0, -1, 0, -1);
                    Color = c3new(0, 0, 0);
                    ZIndex = z+5;
                    Parent = objs.transSlider;
                })

                objs.transDetector = utility:Draw('Square', {
                    Size = newUDim2(1, 0, 1, 0);
                    Transparency = 0;
                    ZIndex = z+10;
                    Parent = objs.transColor;
                })

                -- Pipette / Swatch Button (Right of sliders)
                objs.swatchBtn = utility:Draw('Square', {
                    Size = newUDim2(0, 29, 0, 29);
                    Position = newUDim2(0, 187, 0, 136);
                    ThemeColor = 'Option Background';
                    ZIndex = z+2;
                    Parent = objs.background;
                })

                objs.swatchBorder = utility:Draw('Square', {
                    Size = newUDim2(1, 2, 1, 2);
                    Position = newUDim2(0, -1, 0, -1);
                    ThemeColor = 'Option Border 1';
                    ZIndex = z+1;
                    Parent = objs.swatchBtn;
                })

                objs.swatchInner = utility:Draw('Square', {
                    Size = newUDim2(1, -6, 1, -6);
                    Position = newUDim2(0, 3, 0, 3);
                    Color = c3new(1, 1, 1);
                    ZIndex = z+3;
                    Parent = objs.swatchBtn;
                })

                objs.swatchIcon = utility:Draw('Text', {
                    Position = newUDim2(0.5, 0, 0.5, -6);
                    Text = '✎';
                    Center = true;
                    Size = 13;
                    Font = 2;
                    Outline = true;
                    Color = fromrgb(255, 255, 255);
                    ZIndex = z+4;
                    Parent = objs.swatchInner;
                })

                objs.swatchDetector = utility:Draw('Square', {
                    Size = newUDim2(1, 0, 1, 0);
                    Transparency = 0;
                    ZIndex = z+10;
                    Parent = objs.swatchBtn;
                })

                utility:Connection(objs.swatchDetector.MouseEnter, function()
                    objs.swatchBorder.ThemeColor = 'Accent';
                end)
                utility:Connection(objs.swatchDetector.MouseLeave, function()
                    objs.swatchBorder.ThemeColor = 'Option Border 1';
                end)
                utility:Connection(objs.swatchDetector.MouseButton1Down, function()
                    if window.colorpicker.selected ~= nil then
                        local hex = c3ToHex(window.colorpicker.selected.color)
                        if setclipboard then
                            setclipboard(hex)
                            library:SendNotification('Copied '..hex..' to clipboard!', 3)
                        end
                    end
                end)

                -- Bottom Row: Hex TextBox + Percentage Box
                objs.hexBackground = utility:Draw('Square', {
                    Size = newUDim2(0, 136, 0, 22);
                    Position = newUDim2(0, 8, 0, 174);
                    ThemeColor = 'Option Background';
                    ZIndex = z+2;
                    Parent = objs.background;
                })

                objs.hexBorder = utility:Draw('Square', {
                    Size = newUDim2(1, 2, 1, 2);
                    Position = newUDim2(0, -1, 0, -1);
                    ThemeColor = 'Option Border 1';
                    ZIndex = z+1;
                    Parent = objs.hexBackground;
                })

                objs.hexText = utility:Draw('Text', {
                    Position = newUDim2(0, 8, 0, 4);
                    Text = '#FFFFFF';
                    Size = 13;
                    Font = 2;
                    Outline = true;
                    ThemeColor = 'Primary Text';
                    ZIndex = z+3;
                    Parent = objs.hexBackground;
                })

                objs.hexDetector = utility:Draw('Square', {
                    Size = newUDim2(1, 0, 1, 0);
                    Transparency = 0;
                    ZIndex = z+10;
                    Parent = objs.hexBackground;
                })

                -- Percentage Box
                objs.percentBackground = utility:Draw('Square', {
                    Size = newUDim2(0, 64, 0, 22);
                    Position = newUDim2(0, 152, 0, 174);
                    ThemeColor = 'Option Background';
                    ZIndex = z+2;
                    Parent = objs.background;
                })

                objs.percentBorder = utility:Draw('Square', {
                    Size = newUDim2(1, 2, 1, 2);
                    Position = newUDim2(0, -1, 0, -1);
                    ThemeColor = 'Option Border 1';
                    ZIndex = z+1;
                    Parent = objs.percentBackground;
                })

                objs.percentText = utility:Draw('Text', {
                    Position = newUDim2(0.5, 0, 0, 4);
                    Text = '100%';
                    Center = true;
                    Size = 13;
                    Font = 2;
                    Outline = true;
                    ThemeColor = 'Option Text 1';
                    ZIndex = z+3;
                    Parent = objs.percentBackground;
                })

                -- Interactive Hex TextBox Logic
                local hexFocused = false
                local hexInput = ''
                local hexBlinkConn = nil
                local hexBlink = true
                local lastHexBlink = 0

                local function releaseHexFocus(apply)
                    if not hexFocused then return end
                    hexFocused = false
                    objs.hexBorder.ThemeColor = 'Option Border 1'
                    if hexBlinkConn then
                        hexBlinkConn:Disconnect()
                        hexBlinkConn = nil
                    end
                    if apply and window.colorpicker.selected ~= nil then
                        local parsed = hexToC3(hexInput)
                        if parsed then
                            window.colorpicker.selected:SetColor(parsed)
                            window.colorpicker:Visualize(parsed, window.colorpicker.selected.trans)
                            library:SendNotification('Applied color: ' .. c3ToHex(parsed), 3, parsed)
                        else
                            objs.hexText.Text = c3ToHex(window.colorpicker.selected.color)
                        end
                    elseif window.colorpicker.selected ~= nil then
                        objs.hexText.Text = c3ToHex(window.colorpicker.selected.color)
                    end
                end

                local function captureHexFocus()
                    if hexFocused then return end
                    hexFocused = true
                    objs.hexBorder.ThemeColor = 'Accent'
                    if window.colorpicker.selected ~= nil then
                        hexInput = c3ToHex(window.colorpicker.selected.color)
                    else
                        hexInput = '#FFFFFF'
                    end
                    objs.hexText.Text = hexInput .. '|'
                    hexBlink = true
                    lastHexBlink = tick()
                    
                    hexBlinkConn = utility:Connection(runservice.RenderStepped, function()
                        if hexFocused then
                            if tick() - lastHexBlink > 0.45 then
                                hexBlink = not hexBlink
                                lastHexBlink = tick()
                                objs.hexText.Text = hexInput .. (hexBlink and '|' or '')
                            end
                        end
                    end)
                end

                utility:Connection(objs.hexDetector.MouseEnter, function()
                    objs.hexBorder.ThemeColor = 'Accent'
                end)
                utility:Connection(objs.hexDetector.MouseLeave, function()
                    objs.hexBorder.ThemeColor = hexFocused and 'Accent' or 'Option Border 1'
                end)
                utility:Connection(objs.hexDetector.MouseButton1Down, function()
                    captureHexFocus()
                end)

                utility:Connection(inputservice.InputBegan, function(inp)
                    if hexFocused then
                        if inp.KeyCode == Enum.KeyCode.Return then
                            releaseHexFocus(true)
                        elseif inp.KeyCode == Enum.KeyCode.Escape then
                            releaseHexFocus(false)
                        elseif inp.UserInputType == Enum.UserInputType.MouseButton1 then
                            local mp = inputservice:GetMouseLocation()
                            local hp = objs.hexBackground.Object.Position
                            local hs = objs.hexBackground.Object.Size
                            if not (mp.X >= hp.X and mp.X <= hp.X + hs.X and mp.Y >= hp.Y and mp.Y <= hp.Y + hs.Y) then
                                releaseHexFocus(true)
                            end
                        elseif inp.KeyCode == Enum.KeyCode.Backspace then
                            if #hexInput > 1 then
                                hexInput = hexInput:sub(1, -2)
                            end
                            objs.hexText.Text = hexInput .. '|'
                            hexBlink = true
                            lastHexBlink = tick()
                        else
                            local name = inp.KeyCode.Name
                            local numMap = {Zero='0', One='1', Two='2', Three='3', Four='4', Five='5', Six='6', Seven='7', Eight='8', Nine='9'}
                            local ch = numMap[name] or (#name == 1 and name:upper() or nil)
                            if ch and ch:match('^[0-9A-F]$') and #hexInput < 7 then
                                hexInput = hexInput .. ch
                                objs.hexText.Text = hexInput .. '|'
                                hexBlink = true
                                lastHexBlink = tick()
                            end
                        end
                    end
                end)

                local draggingHue, draggingSat, draggingTrans = false, false, false;

                local function updateSatVal(pos)
                    if window.colorpicker.selected ~= nil then
                        local hue, _, _ = window.colorpicker.selected.color:ToHSV()
                        local sizeX = objs.mainColor.Object.Size.X
                        local sizeY = objs.mainColor.Object.Size.Y
                        if sizeX <= 0 then sizeX = 208 end
                        if sizeY <= 0 then sizeY = 104 end
                        local relX = math.clamp((pos.X - objs.mainColor.Object.Position.X) / sizeX, 0, 0.999)
                        local relY = math.clamp((pos.Y - objs.mainColor.Object.Position.Y) / sizeY, 0, 0.999)
                        local sat = relX
                        local val = 1 - relY
                        local newC3 = fromhsv(hue, math.clamp(sat, 0.001, 0.999), math.clamp(val, 0.001, 0.999))
                        window.colorpicker.selected:SetColor(newC3);
                        window.colorpicker:Visualize(newC3, window.colorpicker.selected.trans);
                    end
                end

                local function updateHue(pos)
                    if window.colorpicker.selected ~= nil then
                        local _, sat, val = window.colorpicker.selected.color:ToHSV()
                        local sizeX = objs.hue.Object.Size.X
                        if sizeX <= 0 then sizeX = 174 end
                        local hue = math.clamp((pos.X - objs.hue.Object.Position.X) / sizeX, 0, 0.999)
                        local newC3 = fromhsv(hue, math.clamp(sat, 0.001, 0.999), math.clamp(val, 0.001, 0.999))
                        window.colorpicker.selected:SetColor(newC3);
                        window.colorpicker:Visualize(newC3, window.colorpicker.selected.trans);
                    end
                end

                local function updateTrans(pos)
                    if window.colorpicker.selected ~= nil then
                        local sizeX = objs.transColor.Object.Size.X
                        if sizeX <= 0 then sizeX = 174 end
                        local X = math.clamp((pos.X - objs.transColor.Object.Position.X) / sizeX, 0, 0.999)
                        window.colorpicker.selected:SetTrans(X);
                        window.colorpicker:Visualize(window.colorpicker.selected.color, X);
                    end
                end

                utility:Connection(objs.mainDetector.MouseButton1Down, function(pos)
                    draggingSat = true;
                    updateSatVal(pos)
                end)

                utility:Connection(objs.hueDetector.MouseButton1Down, function(pos)
                    draggingHue = true;
                    updateHue(pos)
                end)

                utility:Connection(objs.transDetector.MouseButton1Down, function(pos)
                    draggingTrans = true;
                    updateTrans(pos)
                end)

                utility:Connection(mousemove, function(pos)
                    if library.open then
                        if draggingSat then
                            updateSatVal(pos)
                        elseif draggingHue then
                            updateHue(pos)
                        elseif draggingTrans then
                            updateTrans(pos)
                        end
                    end
                end)

                utility:Connection(button1up, function()
                    draggingSat = false;
                    draggingHue = false;
                    draggingTrans = false;
                end)

            end

            function window.colorpicker:Visualize(c3, a)
                if typeof(c3) ~= 'Color3' then return end
                if typeof(a) ~= 'number' then return end
                local h,s,v = c3:ToHSV();
                h = h == 0 and 1 or h;
                self.color = c3;
                self.trans = a;

                -- Update 16x8 HSV gradient palette
                for _, cell in ipairs(self.objects.paletteCells) do
                    cell.sq.Color = fromhsv(h, cell.s, cell.v)
                end

                -- Update dynamic transparency bar (c3 fading smoothly to dark background)
                local transCount = #self.objects.transSegments
                for seg = 0, transCount - 1 do
                    local aFrac = seg / math.max(transCount - 1, 1)
                    self.objects.transSegments[seg + 1].Color = c3:Lerp(Color3.fromRGB(22, 22, 24), aFrac)
                end

                self.objects.hueSlider.Position = newUDim2(math.clamp(h, 0, 0.99), 0, 0, -1);
                self.objects.transSlider.Position = newUDim2(math.clamp(a, 0, 0.99), 0, 0, -1);
                self.objects.pointer.Position = newUDim2(math.clamp(s, 0, 0.99), -2, math.clamp(1 - v, 0, 0.99), -2);
                self.objects.swatchInner.Color = c3;

                local title = 'Color';
                if self.selected ~= nil then
                    if self.selected.text ~= nil and self.selected.text ~= '' then
                        title = tostring(self.selected.text)
                    elseif self.selected.flag ~= nil and self.selected.flag ~= '' then
                        title = tostring(self.selected.flag)
                    end
                end
                self.objects.statusText.Text = 'Edit ' .. title;

                local r = math.floor(clamp(c3.R, 0, 1) * 255)
                local g = math.floor(clamp(c3.G, 0, 1) * 255)
                local b = math.floor(clamp(c3.B, 0, 1) * 255)
                self.objects.hexText.Text = string.format("#%02X%02X%02X", r, g, b)
                self.objects.percentText.Text = math.floor((1 - a) * 100) .. '%'

            end
            
            window.colorpicker:Visualize(window.colorpicker.color, window.colorpicker.trans)

        end
        -------------------------------------

        ---- Create Dropdown ----
        do
            -- Default Objects
            do
                local objs = window.dropdown.objects;
                local z = library.zindexOrder.dropdown;

                objs.background = utility:Draw('Square', {
                    Visible = false;
                    Size = newUDim2(1,-3,0,50);
                    Position = newUDim2(0,3,1,0);
                    ThemeColor = 'Background';
                    ZIndex = z;
                    Parent = window.objects.background;
                })

                objs.border1 = utility:Draw('Square', {
                    Size = newUDim2(1,2,1,2);
                    Position = newUDim2(0,-1,0,-1);
                    ThemeColor = 'Border';
                    ZIndex = z-1;
                    Parent = objs.background;
                })

                objs.border2 = utility:Draw('Square', {
                    Size = newUDim2(1,2,1,2);
                    Position = newUDim2(0,-1,0,-1);
                    ThemeColor = 'Border 1';
                    ZIndex = z-2;
                    Parent = objs.border1;
                })

                objs.border3 = utility:Draw('Square', {
                    Size = newUDim2(1,2,1,2);
                    Position = newUDim2(0,-1,0,-1);
                    ThemeColor = 'Border';
                    ZIndex = z-3;
                    Parent = objs.border2;
                })

            end

            function window.dropdown:Refresh()
                if self.selected ~= nil then
                    local list = self.selected
                    local function updateItemVisual(idx, isHovered)
                        local valueObj = self.objects.values[idx]
                        if not valueObj then return end
                        local val = list.values[idx]
                        if val == nil then return end
                        local isSel = (typeof(list.selected) == 'table' and table.find(list.selected, val)) or list.selected == val
                        if isSel then
                            valueObj.background.Transparency = 1
                            valueObj.background.Color = fromrgb(36, 36, 42)
                            valueObj.text.ThemeColor = 'Accent'
                        elseif isHovered then
                            valueObj.background.Transparency = 1
                            valueObj.background.Color = fromrgb(28, 28, 32)
                            valueObj.text.ThemeColor = 'Primary Text'
                        else
                            valueObj.background.Transparency = 0
                            valueObj.background.Color = fromrgb(20, 20, 22)
                            valueObj.text.ThemeColor = 'Option Text 2'
                        end
                    end

                    for idx, value in next, list.values do
                        local valueObject = self.objects.values[idx]
                        if valueObject == nil then
                            valueObject = {};
                            valueObject.background = utility:Draw('Square', {
                                Size = newUDim2(1,-4,0,18);
                                Color = fromrgb(20, 20, 22);
                                Transparency = 0;
                                ZIndex = library.zindexOrder.dropdown+1;
                                Parent = self.objects.background;
                            })
                            valueObject.text = utility:Draw('Text', {
                                Position = newUDim2(0,6,0,1);
                                ThemeColor = 'Option Text 2';
                                Text = tostring(value);
                                Size = 13;
                                Font = 2;
                                ZIndex = library.zindexOrder.dropdown+2;
                                Parent = valueObject.background;
                            })
                            valueObject.isHovered = false;
                            utility:Connection(valueObject.background.MouseEnter, function()
                                valueObject.isHovered = true;
                                updateItemVisual(idx, true);
                            end)
                            utility:Connection(valueObject.background.MouseLeave, function()
                                valueObject.isHovered = false;
                                updateItemVisual(idx, false);
                            end)
                            valueObject.connection = utility:Connection(valueObject.background.MouseButton1Down, function()
                                local currentList = self.selected
                                if currentList then
                                    local val = currentList.values[idx]
                                    local currentSelected = currentList.selected;
                                    local newSelected = currentList.multi and {} or val;
                                    
                                    if currentList.multi then
                                        for i,v in next, currentSelected do
                                            if v == "none" then continue end
                                            newSelected[i] = v;
                                        end
                                        if table.find(newSelected, val) then
                                            table.remove(newSelected, table.find(newSelected, val));
                                        else
                                            table.insert(newSelected, val)
                                        end
                                    end

                                    currentList:Select(newSelected);
                                    if not currentList.multi then
                                        currentList.open = false;
                                        currentList.objects.openText.Text = '+';
                                        window.dropdown.selected = nil;
                                        window.dropdown.objects.background.Visible = false;
                                    else
                                        for vIdx, _ in next, currentList.values do
                                            updateItemVisual(vIdx, self.objects.values[vIdx] and self.objects.values[vIdx].isHovered or false)
                                        end
                                    end

                                end
                            end)
                            self.objects.values[idx] = valueObject
                        end
                    end

                    for idx, val in next, list.values do
                        local valueObj = self.objects.values[idx]
                        if valueObj then
                            updateItemVisual(idx, valueObj.isHovered or false)
                        end
                    end

                    local y,padding = 2,2
                    for idx, obj in next, self.objects.values do
                        local valueStr = list.values[idx]
                        obj.background.Visible = valueStr ~= nil
                        if valueStr ~= nil then
                            obj.background.Position = newUDim2(0,2,0,y);
                            obj.text.Text = valueStr;
                            y = y + obj.background.Object.Size.Y + padding;
                        end
                    end

                    self.objects.background.Size = newUDim2(1,-6,0,y);    

                end
            end
        
            window.dropdown:Refresh();
        end
        -------------------------

        local function tooltip(option)
            utility:Connection(option.objects.holder.MouseEnter, function()
                tooltipObjects.background.Visible = (not (option.tooltip == '' or option.tooltip == nil)) and true or false;
                tooltipObjects.riskytext.Visible = option.risky;
                tooltipObjects.text.Position = option.risky and newUDim2(0,60,0,0) or newUDim2(0,3,0,0)
                tooltipObjects.text.Text = tostring(option.tooltip);
                library.CurrentTooltip = option;
            end)
            utility:Connection(option.objects.holder.MouseLeave, function()
                if library.CurrentTooltip == option then
                    library.CurrentTooltip = nil;
                    tooltipObjects.background.Visible = false
                end
            end)
        end


        function window:SetOpen(bool)
            if typeof(bool) == 'boolean' then
                self.open = bool;

                if bool then
                    self.objects.background.Visible = true;
                end

                if self.fadeConn then
                    self.fadeConn:Disconnect()
                    self.fadeConn = nil
                end

                local startAlpha = bool and 0.05 or 1
                local targetAlpha = bool and 1 or 0.05
                local duration = 0.16
                local elapsed = 0

                self.fadeConn = utility:Connection(runservice.RenderStepped, function(dt)
                    elapsed = elapsed + dt
                    local t = math.clamp(elapsed / duration, 0, 1)
                    local smooth = tweenService:GetValue(t, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                    local alpha = utility:Lerp(startAlpha, targetAlpha, smooth)

                    pcall(function()
                        if self.objects.background and self.objects.background.Object then
                            self.objects.background.Object.Transparency = alpha
                        end
                    end)

                    if t >= 1 then
                        if self.fadeConn then
                            self.fadeConn:Disconnect()
                            self.fadeConn = nil
                        end
                        if not bool then
                            self.objects.background.Visible = false;
                        end
                    end
                end)
            end
        end

        function window:AddTab(text, order)
            local tab = {
                text = text;
                order = order or #self.tabs+1;
                callback = function() end;
                objects = {};
                sections = {};
            }

            table.insert(self.tabs, tab);

            --- Create Objects ---
            do
                local objs = tab.objects;
                local z = library.zindexOrder.window + 5;

                objs.background = utility:Draw('Square', {
                    Size = newUDim2(0,65,1,0);
                    Parent = self.objects.tabHolder;
                    ThemeColor = 'Unselected Tab Background';
                    ZIndex = z;
                })

                objs.innerBorder = utility:Draw('Square', {
                    Size = newUDim2(1,2,1,2);
                    Position = newUDim2(0,-1,0,-1);
                    ThemeColor = 'Border 1';
                    ZIndex = z-1;
                    Parent = objs.background;
                })
    
                objs.outerBorder = utility:Draw('Square', {
                    Size = newUDim2(1,2,1,2);
                    Position = newUDim2(0,-1,0,-1);
                    ThemeColor = 'Border 3';
                    ZIndex = z-2;
                    Parent = objs.innerBorder;
                })

                objs.topBorder = utility:Draw('Square', {
                    Size = newUDim2(1,0,0,1);
                    ThemeColor = 'Unselected Tab Background';
                    ZIndex = z+1;
                    Parent = objs.background;
                })

                objs.text = utility:Draw('Text', {
                    ThemeColor = 'Unselected Tab Text';
                    Text = text;
                    Size = 13;
                    Font = 2;
                    ZIndex = z+1;
                    Outline = true;
                    Center = true;
                    Parent = objs.background;
                })

                utility:Connection(objs.background.MouseButton1Down, function()
                    tab:Select();
                end)

                utility:Connection(objs.background.MouseEnter, function()
                    if tab ~= window.selectedTab then
                        objs.background.Color = fromrgb(32, 32, 36);
                        objs.text.ThemeColor = 'Primary Text';
                        objs.topBorder.ThemeColor = 'Accent';
                    end
                end)

                utility:Connection(objs.background.MouseLeave, function()
                    if tab ~= window.selectedTab then
                        objs.background.ThemeColor = 'Unselected Tab Background';
                        objs.text.ThemeColor = 'Unselected Tab Text';
                        objs.topBorder.ThemeColor = 'Unselected Tab Background';
                    end
                end)

            end
            ----------------------

            function tab:AddSection(text, side, order)
                local section = {
                    text = tostring(text);
                    side = side == nil and 1 or clamp(side,1,2);
                    order = order or #self.sections+1;
                    enabled = true;
                    objects = {};
                    options = {};
                };

                table.insert(self.sections, section);

                --- Create Objects ---
                do
                    local objs = section.objects;
                    local z = library.zindexOrder.window+15;

                    objs.background = utility:Draw('Square', {
                        ThemeColor = 'Section Background';
                        ZIndex = z;
                        Parent = window.objects['columnholder'..(section.side)];
                    })

                    objs.innerBorder = utility:Draw('Square', {
                        Size = newUDim2(1,2,1,1);
                        Position = newUDim2(0,-1,0,0);
                        ThemeColor = 'Border 3';
                        ZIndex = z-1;
                        Parent = objs.background;
                    })

                    objs.outerBorder = utility:Draw('Square', {
                        Size = newUDim2(1,2,1,1);
                        Position = newUDim2(0,-1,0,0);
                        ThemeColor = 'Border 1';
                        ZIndex = z-2;
                        Parent = objs.innerBorder;
                    })

                    objs.topBorder1 = utility:Draw('Square', {
                        Size = newUDim2(.025,1,0,1);
                        Position = newUDim2(0,-1,0,0);
                        ThemeColor = 'Accent';
                        ZIndex = z+1;
                        Parent = objs.background;
                    })

                    objs.topBorder2 = utility:Draw('Square', {
                        ThemeColor = 'Accent';
                        ZIndex = z+1;
                        Parent = objs.background;
                    })

                    objs.textlabel = utility:Draw('Text', {
                        Position = newUDim2(.0425,0,0,-7);
                        ThemeColor = 'Primary Text';
                        Size = 13;
                        Font = 2;
                        ZIndex = z+1;
                        Parent = objs.background;
                    })

                    objs.optionholder = utility:Draw('Square',{
                        Size = newUDim2(1-.03,0,1,-15);
                        Position = newUDim2(.015,0,0,13);
                        Transparency = 0;
                        ZIndex = z+1;
                        Parent = objs.background;
                    })
                    
                end
                ----------------------

                function section:SetText(text)
                    self.text = tostring(text);
                    self.objects.textlabel.Text = self.text;
                    local x = self.objects.background.Object.Size.X - self.objects.textlabel.TextBounds.X - 13
                    self.objects.topBorder2.Size = newUDim2(0, x, 0, 1)
                    self.objects.topBorder2.Position = newUDim2(1, 1 + -x, 0, 0)
                end

                function section:UpdateOptions()
                    table.sort(self.options, function(a,b)
                        return a.order < b.order
                    end)

                    local ySize, padding = 15, 0;
                    for i,option in next, self.options do
                        option.objects.holder.Visible = option.enabled
                        if option.enabled then
                            option.objects.holder.Position = newUDim2(0,0,0,ySize-15);
                            ySize += option.objects.holder.Object.Size.Y + padding;
                        end
                    end

                    self.objects.background.Size = newUDim2(1,0,0,ySize);

                end

                function section:SetEnabled(bool)
                    if typeof(bool) == 'boolean' then
                        section.enabled = bool;
                        tab:UpdateSections();
                    end
                end

                ------- Options -------

                -- // Toggle
                function section:AddToggle(data)
                    local toggle = {
                        class = 'toggle';
                        flag = data.flag;
                        text = '';
                        tooltip = '';
                        order = #self.options+1;
                        state = false;
                        risky = false;
                        callback = function() end;
                        enabled = true;
                        options = {};
                        objects = {};
                    };

                    local blacklist = {'objects'};
                    for i,v in next, data do
                        if not table.find(blacklist, i) ~= toggle[i] ~= nil then
                            toggle[i] = v
                        end
                    end

                    table.insert(self.options, toggle)

                    if toggle.flag then
                        library.flags[toggle.flag] = toggle.state;
                        library.options[toggle.flag] = toggle;
                    end

                    --- Create Objects ---
                    do
                        local objs = toggle.objects;
                        local z = library.zindexOrder.window+25;

                        objs.holder = utility:Draw('Square', {
                            Size = newUDim2(1,0,0,23);
                            Transparency = 0;
                            ZIndex = z+5;
                            Parent = section.objects.optionholder;
                        })

                        objs.background = utility:Draw('Square', {
                            Size = newUDim2(0,14,0,14);
                            Position = newUDim2(0,2,0,4);
                            ThemeColor = 'Option Background';
                            ZIndex = z+3;
                            Parent = objs.holder;
                        })

                        objs.gradient = utility:Draw('Image', {
                            Size = newUDim2(1,0,1,0);
                            Data = library.images.gradientp45;
                            Transparency = .25;
                            ZIndex = z+4;
                            Parent = objs.background;
                        })

                        objs.border1 = utility:Draw('Square', {
                            Size = newUDim2(1,2,1,2);
                            Position = newUDim2(0,-1,0,-1);
                            ThemeColor = 'Option Border 1';
                            ZIndex = z+2;
                            Parent = objs.background;
                        })

                        objs.border2 = utility:Draw('Square', {
                            Size = newUDim2(1,2,1,2);
                            Position = newUDim2(0,-1,0,-1);
                            ThemeColor = 'Option Border 2';
                            ZIndex = z+1;
                            Parent = objs.border1;
                        })

                        objs.text = utility:Draw('Text', {
                            Position = newUDim2(0,24,0,3);
                            ThemeColor = 'Option Text 3';
                            Size = 13;
                            Font = 2;
                            ZIndex = z+1;
                            Outline = true;
                            Parent = objs.holder;
                        })

                        utility:Connection(objs.holder.MouseEnter, function()
                            objs.border1.ThemeColor = 'Accent';
                        end)

                        utility:Connection(objs.holder.MouseLeave, function()
                            objs.border1.ThemeColor = toggle.state and 'Accent' or 'Option Border 1';
                        end)

                        utility:Connection(objs.holder.MouseButton1Down, function()
                            toggle:SetState(not toggle.state);
                        end)

                    end
                    ----------------------

                    function toggle:SetState(bool, nocallback)
                        if typeof(bool) == 'boolean' then
                            self.state = bool;
                            if self.flag then
                                library.flags[self.flag] = bool;
                            end

                            self.objects.border1.ThemeColor = bool and 'Accent' or (self.objects.holder.Hover and 'Accent' or 'Option Border 1');
                            self.objects.text.ThemeColor = bool and (self.risky and 'Risky Text Enabled' or 'Option Text 1') or (self.risky and 'Risky Text' or 'Option Text 3');
                            self.objects.background.ThemeColor = bool and 'Accent' or 'Option Background';
                            self.objects.background.ThemeColorOffset = bool and -55 or 0

                            if not nocallback then
                                self.callback(bool);
                            end

                        end
                    end

                    function toggle:SetText(str)
                        if typeof(str) == 'string' then
                            self.text = str;
                            self.objects.text.Text = str;
                        end
                    end

                    function toggle:UpdateOptions()
                        table.sort(self.options, function(a,b)
                            return a.order < b.order
                        end)

                        local x, y = 0, 0
                        for i,option in next, self.options do
                            option.objects.holder.Visible = option.enabled
                            if option.enabled then
                                if option.class == 'color' or option.class == 'bind' then
                                    option.objects.holder.Position = newUDim2(1,-option.objects.holder.Object.Size.X-x,0,0);
                                    x = x + option.objects.holder.Object.Size.X;
                                elseif option.class == 'slider' or option.class == 'list' then
                                    option.objects.holder.Position = newUDim2(0,0,1,-option.objects.holder.Object.Size.Y-y);
                                    y = y + option.objects.holder.Object.Size.Y;
                                end
                            end
                        end

                        self.objects.holder.Size = newUDim2(1,0,0,23 + y);
                        section:UpdateOptions()

                    end

                    -- // Toggle Addons
                    function toggle:AddColor(data, trans, callback)
                        if typeof(data) == 'Color3' then
                            data = {
                                color = data,
                                trans = trans or 0,
                                callback = callback or function() end
                            }
                        elseif typeof(data) ~= 'table' then
                            data = {}
                        end

                        local color = {
                            class = 'color';
                            flag = data.flag;
                            text = '';
                            tooltip = '';
                            order = #self.options+1;
                            callback = function() end;
                            color = Color3.new(1,1,1);
                            trans = 0;
                            open = false;
                            enabled = true;
                            objects = {};
                        };
    
                        local blacklist = {'objects'};
                        for i,v in next, data do
                            if not table.find(blacklist, i) and color[i] ~= nil then
                                color[i] = v
                            end
                        end
                        
                        table.insert(self.options, color)
    
                        if color.flag then
                            library.flags[color.flag] = color.color;
                            library.options[color.flag] = color;
                        end
    
                        --- Create Objects ---
                        do
                            local objs = color.objects;
                            local z = library.zindexOrder.window+25;
    
                            objs.holder = utility:Draw('Square', {
                                Size = newUDim2(0,25,0,23);
                                Transparency = 0;
                                ZIndex = z+6;
                                Parent = self.objects.holder;
                            })
    
                            objs.background = utility:Draw('Square', {
                                Size = newUDim2(0,18,0,13);
                                Position = newUDim2(0,4,0,5);
                                ZIndex = z+3;
                                Parent = objs.holder;
                            })
    
                            objs.gradient = utility:Draw('Image', {
                                Size = newUDim2(1,0,1,0);
                                Data = library.images.gradientp45;
                                Transparency = .25;
                                ZIndex = z+4;
                                Parent = objs.background;
                            })
    
                            objs.border1 = utility:Draw('Square', {
                                Size = newUDim2(1,2,1,2);
                                Position = newUDim2(0,-1,0,-1);
                                ThemeColor = 'Option Border 1';
                                ZIndex = z+2;
                                Parent = objs.background;
                            })
    
                            objs.border2 = utility:Draw('Square', {
                                Size = newUDim2(1,2,1,2);
                                Position = newUDim2(0,-1,0,-1);
                                ThemeColor = 'Option Border 2';
                                ZIndex = z+1;
                                Parent = objs.border1;
                            })
    
                            utility:Connection(objs.holder.MouseEnter, function()
                                objs.border1.ThemeColor = 'Accent';
                            end)
    
                            utility:Connection(objs.holder.MouseLeave, function()
                                objs.border1.ThemeColor = color.state and 'Accent' or 'Option Border 1';
                            end)
    
                            utility:Connection(objs.holder.MouseButton1Down, function()
                                color:SetOpen(not color.open);
                            end)
    
                        end
                        ----------------------

    
                        function color:SetColor(c3, nocallback)
                            if typeof(c3) == 'Color3' then
                                local h,s,v = c3:ToHSV(); c3 = fromhsv(h, clamp(s,.005,.995), clamp(v,.005,.995))
                                self.color = c3;
                                self.objects.background.Color = c3;
                                if not nocallback then
                                    self.callback(c3, self.trans);
                                end
                                if self.open then
                                    window.colorpicker:Visualize(self.color, self.trans);
                                end
                                if self.flag then
                                    library.flags[self.flag] = c3;
                                end
                            end
                        end
    
                        function color:SetTrans(trans, nocallback)
                            if typeof(trans) == 'number' then
                                self.trans = trans;
                                if not nocallback then
                                    self.callback(self.color, trans);
                                end
                                if self.open then
                                    window.colorpicker:Visualize(self.color, self.trans);
                                end
                            end
                        end
    
                        function color:SetOpen(bool)
                            if typeof(bool) == 'boolean' then
                                self.open = bool
                                if bool then
                                    if window.colorpicker.selected then
                                        window.colorpicker.selected.open = false;
                                    end
                                    window.colorpicker.selected = color
                                    window.colorpicker.objects.background.Parent = self.objects.background;
                                    window.colorpicker.objects.background.Visible = true;
                                    window.colorpicker:Visualize(color.color, color.trans)
                                elseif window.colorpicker.selected == color then
                                    window.colorpicker.selected = nil;
                                    window.colorpicker.objects.background.Parent = window.objects.background;
                                    window.colorpicker.objects.background.Visible = false;
                                end
                            end
                        end
    
                        tooltip(color);
                        color:SetColor(color.color, true);
                        color:SetTrans(color.trans, true);
                        self:UpdateOptions();
                        return color
                    end

                    function toggle:AddBind(data)
                        local bind = {
                            class = 'bind';
                            flag = data.flag;
                            text = '';
                            tooltip = '';
                            bind = 'none';
                            mode = 'toggle';
                            order = #self.options+1;
                            callback = function() end;
                            keycallback = function() end;
                            indicatorValue = library.keyIndicator:AddValue({value = 'value', key = 'key', enabled = false});
                            noindicator = false;
                            invertindicator = false;
                            state = false;
                            nomouse = false;
                            enabled = true;
                            binding = false;
                            objects = {};
                        };
    
                        local blacklist = {'objects'};
                        for i,v in next, data do
                            if not table.find(blacklist, i) and bind[i] ~= nil then
                                bind[i] = v
                            end
                        end
                        
                        table.insert(self.options, bind)
    
                        if bind.flag then
                            library.options[bind.flag] = bind;
                        end

                        if bind.bind == 'none' then
                            bind.state = true
                            if bind.flag then
                                library.flags[bind.flag] = bind.state;
                            end
                            bind.callback(true)
                            local display = bind.state; if bind.invertindicator then display = not bind.state; end
                            bind.indicatorValue:SetEnabled(display and not bind.noindicator);
                            bind.indicatorValue:SetKey((bind.text == nil or bind.text == '') and (bind.flag == nil and 'unknown' or bind.flag) or bind.text); -- this is so dumb
                            bind.indicatorValue:SetValue('[Always]');
                        end
    
                        --- Create Objects ---
                        do
                            local objs = bind.objects;
                            local z = library.zindexOrder.window+25;
    
                            objs.holder = utility:Draw('Square', {
                                Size = newUDim2(0,0,0,23);
                                Transparency = 0;
                                ZIndex = z+6;
                                Parent = self.objects.holder;
                            })
    
                            objs.keyText = utility:Draw('Text', {
                                Position = newUDim2(0,0,0,3);
                                ThemeColor = 'Option Text 3';
                                Size = 13;
                                Font = 2;
                                ZIndex = z+1;
                                Parent = objs.holder;
                            })
    
                            utility:Connection(objs.holder.MouseEnter, function()
                                objs.keyText.ThemeColor = 'Accent';
                            end)
    
                            utility:Connection(objs.holder.MouseLeave, function()
                                objs.keyText.ThemeColor = bind.binding and 'Accent' or 'Option Text 3';
                            end)
    
                            utility:Connection(objs.holder.MouseButton1Down, function()
                                if not bind.binding then
                                    bind:SetKeyText('...');
                                    bind.binding = true;
                                end
                            end)
    
                        end
                        ----------------------
    
                        local c
                        function bind:SetBind(keybind)
                            if c then
                                c:Disconnect();
                                if bind.flag then
                                    library.flags[bind.flag] = false;
                                end
                                bind.callback(false);
                            end
                            local keyName = 'NONE'
                            self.bind = (keybind and keybind) or keybind or self.bind
                            if self.bind == Enum.KeyCode.Backspace then
                                self.bind = 'none';

                                if bind.flag then
                                    library.flags[bind.flag] = bind.state;
                                end
                                self.callback(true)
                                local display = bind.state; if bind.invertindicator then display = not bind.state; end
                                bind.indicatorValue:SetEnabled(display and not bind.noindicator);
                            else
                                keyName = keyNames[keybind] or keybind.Name or keybind
                            end
                            if self.bind ~= 'none' then
                                bind.state = false
                                if bind.flag then
                                    library.flags[bind.flag] = bind.state;
                                end
                                self.callback(false)
                                local display = bind.state; if bind.invertindicator then display = not bind.state; end
                                bind.indicatorValue:SetEnabled(display and not bind.noindicator);
                            end
                            self.keycallback(self.bind);
                            self:SetKeyText(keyName:upper());
                            self.indicatorValue:SetKey((self.text == nil or self.text == '') and (self.flag == nil and 'unknown' or self.flag) or self.text); -- this is so dumb
                            self.indicatorValue:SetValue('['..keyName:upper()..']');
                            if self.bind == 'none' then

                            end
                            self.objects.keyText.ThemeColor = self.objects.holder.Hover and 'Accent' or 'Option Text 3';
                        end
    
                        function bind:SetKeyText(str)
                            str = tostring(str);
                            self.objects.keyText.Text = '['..str..']';
                            self.objects.keyText.Position = newUDim2(0, 2, 0, 2);
                            self.objects.holder.Size = newUDim2(0,self.objects.keyText.TextBounds.X+2,0,17)
                            toggle:UpdateOptions();
                        end
    
                        utility:Connection(inputservice.InputBegan, function(inp)
                            if inputservice:GetFocusedTextBox() then
                                return
                            elseif bind.binding then
                                local key = (table.find({Enum.UserInputType.MouseButton1, Enum.UserInputType.MouseButton2, Enum.UserInputType.MouseButton3}, inp.UserInputType) and not bind.nomouse) and inp.UserInputType
                                bind:SetBind(key or (not table.find(blacklistedKeys, inp.KeyCode)) and inp.KeyCode)
                                bind.binding = false
                            elseif not bind.binding and self.bind == 'none' then
                                bind.state = true
                                library.flags[bind.flag] = bind.state
                                local display = bind.state; if bind.invertindicator then display = not bind.state; end
                                bind.indicatorValue:SetEnabled(display and not bind.noindicator)
                            elseif (inp.KeyCode == bind.bind or inp.UserInputType == bind.bind) and not bind.binding then
                                if bind.mode == 'toggle' then
                                    bind.state = not bind.state
                                    if bind.flag then
                                        library.flags[bind.flag] = bind.state;
                                    end
                                    bind.callback(bind.state)
                                    local display = bind.state; if bind.invertindicator then display = not bind.state; end
                                    bind.indicatorValue:SetEnabled(display and not bind.noindicator);
                                elseif bind.mode == 'hold' then
                                    if bind.flag then
                                        library.flags[bind.flag] = true;
                                    end
                                    bind.indicatorValue:SetEnabled((not bind.invertindicator and true or false) and not bind.noindicator);
                                    c = utility:Connection(runservice.RenderStepped, function()
                                        if bind.callback then
                                            bind.callback(true);
                                        end
                                    end)
                                end
                            end
                        end)
    
                        utility:Connection(inputservice.InputEnded, function(inp)
                            if bind.bind ~= 'none' then
                                if inp.KeyCode == bind.bind or inp.UserInputType == bind.bind then
                                    if c then
                                        c:Disconnect();
                                        if bind.flag then
                                            library.flags[bind.flag] = false;
                                        end
                                        if bind.callback then
                                            bind.callback(false);
                                        end
                                        bind.indicatorValue:SetEnabled(bind.invertindicator and true or false);
                                    end
                                end
                            end
                        end)
    
                        tooltip(bind);
                        bind:SetBind(bind.bind);
                        self:UpdateOptions();
                        return bind
                    end

                    function toggle:AddSlider(data)
                        local slider = {
                            class = 'slider';
                            flag = data.flag;
                            suffix = '';
                            tooltip = '';
                            order = #self.options+1;
                            value = 0;
                            min = 0;
                            max = 100;
                            increment = 1;
                            callback = function() end;
                            enabled = true;
                            dragging = false;
                            focused = false;
                            objects = {};
                        };
    
                        local blacklist = {'objects', 'dragging'};
                        for i,v in next, data do
                            if not table.find(blacklist, i) and (slider[i] ~= nil and typeof(slider[i]) == typeof(v)) then
                                slider[i] = v;
                            end
                        end
                
                        table.insert(self.options, slider)

                        if slider.flag then
                            library.flags[slider.flag] = slider.value;
                            library.options[slider.flag] = slider;
                        end

                        --- Create Objects ---
                        do
                            local objs = slider.objects;
                            local z = library.zindexOrder.window+25;

                            objs.holder = utility:Draw('Square', {
                                Size = newUDim2(1,0,0,26);
                                Transparency = 0;
                                ZIndex = z+6;
                                Parent = toggle.objects.holder;
                            })

                            objs.background = utility:Draw('Square', {
                                Size = newUDim2(1,-4,0,15);
                                Position = newUDim2(0,2,0,5);
                                ThemeColor = 'Option Background';
                                ZIndex = z+2;
                                Parent = objs.holder;
                            })

                            objs.slider = utility:Draw('Square', {
                                Size = newUDim2(0,0,1,0);
                                ThemeColor = 'Accent';
                                ZIndex = z+3;
                                Parent = objs.background;
                            })

                            objs.border1 = utility:Draw('Square', {
                                Size = newUDim2(1,2,1,2);
                                Position = newUDim2(0,-1,0,-1);
                                ThemeColor = 'Option Border 1';
                                ZIndex = z+1;
                                Parent = objs.background;
                            })

                            objs.border2 = utility:Draw('Square', {
                                Size = newUDim2(1,2,1,2);
                                Position = newUDim2(0,-1,0,-1);
                                ThemeColor = 'Option Border 2';
                                ZIndex = z;
                                Parent = objs.border1;
                            })
    
                            objs.gradient = utility:Draw('Image', {
                                Size = newUDim2(1,0,1,0);
                                Data = library.images.gradientp90;
                                Transparency = .65;
                                ZIndex = z+4;
                                Parent = objs.background;
                            })
    
                            objs.text = utility:Draw('Text', {
                                Position = newUDim2(.5,0,0,-1);
                                ThemeColor = 'Option Text 3';
                                Size = 13;
                                Font = 2;
                                ZIndex = z+5;
                                Outline = true;
                                Center = true;
                                Parent = objs.background;
                            })

                            utility:Connection(objs.holder.MouseEnter, function()
                                objs.border1.ThemeColor = 'Accent';
                            end)
    
                            utility:Connection(objs.holder.MouseLeave, function()
                                objs.border1.ThemeColor = slider.dragging and 'Accent' or 'Option Border 1';
                            end)
    
                            local c;
                            local inputNumber = '';
                            utility:Connection(slider.objects.holder.MouseButton1Down, function()
                                if inputservice:IsKeyDown(Enum.KeyCode.LeftControl) then
                                    if slider.focused then
                                        slider.focused = false;
                                        c:Disconnect();
                                    else
                                        objs.text.Text = tostring(slider.value)..tostring(slider.suffix)..'/'..tostring(slider.max)..tostring(slider.suffix)..' []';
                                        slider.focused = true;
                                        inputNumber = '';
                                        c = utility:Connection(inputservice.InputBegan, function(inp)
                                            if library.numberStrings[inp.KeyCode.Name] then
                                                local number = library.numberStrings[inp.KeyCode.Name];
                                                inputNumber = inputNumber..tostring(number);
                                                objs.text.Text = string.format("%.14g", slider.value) .. tostring(slider.suffix) .. "/" .. slider.max .. tostring(slider.suffix) .. " [" .. inputNumber .. "]";
                                            elseif inp.KeyCode == Enum.KeyCode.Backspace then
                                                inputNumber = inputNumber:sub(1,-2);
                                                objs.text.Text = string.format("%.14g", slider.value)..tostring(slider.suffix)..'/'..slider.max..tostring(slider.suffix)..' ['..inputNumber..']';
                                            elseif inp.KeyCode == Enum.KeyCode.Return then
                                                slider:SetValue(tonumber(inputNumber))
                                                slider.focused = false;
                                                c:Disconnect();
                                            elseif inp.KeyCode == Enum.KeyCode.Escape then
                                                slider:SetValue(slider.value, true)
                                                slider.focused = false;
                                                c:Disconnect();
                                            end
                                        end)
                                    end
                                else
                                    slider.dragging = true;
                                    library.draggingSlider = slider;
                                end
                            end)
    
                            utility:Connection(button1up, function()
                                objs.border1.ThemeColor = objs.holder.Hover and 'Accent' or 'Option Border 1';
                                slider.dragging = false;
                                library.draggingSlider = nil;
                            end)
    
                        end
                        ----------------------
    
                        function slider:SetValue(value, nocallback)
                            if typeof(value) == 'number' then
                                local newValue = clamp(self.increment * floor(value/self.increment), self.min, self.max);
                                local size, pos = self.objects.slider.Size, self.objects.slider.Position;
    
                                if self.min >= 0 then
                                    size = newUDim2((newValue - self.min) / (self.max - self.min), 0, 1, 0);
                                else
                                    size = newUDim2(newValue / (self.max - self.min), 0, 1, 0);
                                    pos = newUDim2((0 - self.min) / (self.max - self.min), 0, 0, 0);
                                end
    
                                utility:Tween(self.objects.slider, 'Size', size, .05, Enum.EasingDirection.Out, Enum.EasingStyle.Quad);
                                utility:Tween(self.objects.slider, 'Position', pos, .05, Enum.EasingDirection.Out, Enum.EasingStyle.Quad);
    
                                self.value = newValue;
                                library.flags[self.flag] = newValue;
                                self.objects.text.Text = string.format("%.14g",newValue)..tostring(self.suffix)..'/'..self.max..tostring(self.suffix);
                                self.objects.text.ThemeColor = (self.min < 0 and newValue == 0 or newValue == self.min)  and (self.risky and 'Risky Text' or 'Option Text 3') or (self.risky and 'Risky Text Enabled' or 'Option Text 1');
    
                                if not nocallback then
                                    self.callback(newValue);
                                end
    
                            end
                        end

                        tooltip(slider);
                        slider:SetValue(slider.value, true);
                        self:UpdateOptions();
                        return slider
                    end

                    function toggle:AddList(data)
                        local list = {
                            class = 'list';
                            flag = data.flag;
                            text = '';
                            selected = '';
                            tooltip = '';
                            order = #self.options+1;
                            callback = function() end;
                            enabled = true;
                            multi = false;
                            open = false;
                            values = {};
                            objects = {};
                        }
    
                        table.insert(self.options, list);
    
                        local blacklist = {'objects'};
                        for i,v in next, data do
                            if not table.find(blacklist, i) ~= list[i] ~= nil then
                                list[i] = v
                            end
                        end
    
                        if list.flag then
                            library.flags[list.flag] = list.selected;
                            library.options[list.flag] = list;
                        end
    
                        -- Create Objects --
                        do
                            local objs = list.objects;
                            local z = library.zindexOrder.window+25;
    
                            objs.holder = utility:Draw('Square', {
                                Size = newUDim2(1,0,0,22);
                                Transparency = 0;
                                ZIndex = z+6;
                                Parent = toggle.objects.holder;
                            })
    
                            objs.background = utility:Draw('Square', {
                                Size = newUDim2(1,-4,1,-8);
                                Position = newUDim2(0,2,0,4);
                                ThemeColor = 'Option Background';
                                ZIndex = z+2;
                                Parent = objs.holder;
                            })
    
                            objs.border1 = utility:Draw('Square', {
                                Size = newUDim2(1,2,1,2);
                                Position = newUDim2(0,-1,0,-1);
                                ThemeColor = 'Option Border 1';
                                ZIndex = z+1;
                                Parent = objs.background;
                            })
    
                            objs.border2 = utility:Draw('Square', {
                                Size = newUDim2(1,2,1,2);
                                Position = newUDim2(0,-1,0,-1);
                                ThemeColor = 'Option Border 2';
                                ZIndex = z;
                                Parent = objs.border1;
                            })
    
                            objs.gradient = utility:Draw('Image', {
                                Size = newUDim2(1,0,1,0);
                                Data = library.images.gradientp90;
                                Transparency = .65;
                                ZIndex = z+4;
                                Parent = objs.background;
                            })
    
                            objs.inputText = utility:Draw('Text', {
                                Position = newUDim2(0,4,0,0);
                                ThemeColor = 'Option Text 2';
                                Text = 'none',
                                Size = 13;
                                Font = 2;
                                ZIndex = z+5;
                                Outline = true;
                                Parent = objs.background;
                            })
    
                            objs.openText = utility:Draw('Text', {
                                Position = newUDim2(1,-10,0,0);
                                ThemeColor = 'Option Text 3';
                                Text = '+';
                                Size = 13;
                                Font = 2;
                                ZIndex = z+5;
                                Outline = true;
                                Parent = objs.background;
                            })
    
                            utility:Connection(objs.holder.MouseEnter, function()
                                objs.border1.ThemeColor = 'Accent';
                            end)
    
                            utility:Connection(objs.holder.MouseLeave, function()
                                objs.border1.ThemeColor = 'Option Border 1';
                            end)
    
                            utility:Connection(objs.holder.MouseButton1Down, function()
                                if list.open then
                                    list.open = false;
                                    objs.openText.Text = '+';
                                    if window.dropdown.selected == list then
                                        window.dropdown.selected = nil;
                                        window.dropdown.objects.background.Visible = false;
                                    end
                                else
                                    if window.dropdown.selected ~= nil then
                                        window.dropdown.selected.open = false
                                    end
                                    list.open = true;
                                    objs.openText.Text = '-';
                                    window.dropdown.selected = list;
                                    window.dropdown.objects.background.Visible = true;
                                    window.dropdown.objects.background.Parent = objs.holder;
                                    window.dropdown:Refresh();
                                end
                            end)
    
    
                        end
                        --------------------
    
                        function list:Select(option, nocallback)
                            option = typeof(option) == 'table' and (self.multi == true and option or (#option == 0 and nil or option[1])) or self.multi == true and {option} or option;
                            if option ~= nil then
                                self.selected = option;
                                local text = typeof(option) == 'table' and (#option == 0 and "none" or table.concat(option, ', ')) or tostring(option);
                                local label = self.objects.inputText
                                label.Text = text;
                                if label.TextBounds.X > self.objects.background.Object.Size.X - 10 then
                                    local split = text:split('');
                                    for i = 1,#split do
                                        label.Text = table.concat(split, '', 1, i)
                                        if label.TextBounds.X > self.objects.background.Object.Size.X - 10 then
                                            label.Text = label.Text:sub(1,-6)..'...';
                                            break
                                        end
                                    end
                                end
                                if self.flag then
                                    library.flags[self.flag] = self.selected
                                end
                                if not nocallback then
                                    self.callback(self.selected);
                                end
                            end
                        end
    
                        function list:AddValue(value)
                            table.insert(list.values, tostring(value));
                            if window.dropdown.selected == list then
                                window.dropdown:Refresh()
                            end
                        end
    
                        function list:RemoveValue(value)
                            if table.find(list.values, value) then
                                table.remove(list.values, table.find(list.values, value));
                                if window.dropdown.selected == list then
                                    window.dropdown:Refresh()
                                end
                            end
                        end
    
                        function list:ClearValues()
                            table.clear(list.values);
                            if window.dropdown.selected == list then
                                window.dropdown:Refresh()
                            end
                        end
    
                        tooltip(list);
                        list:Select((data.value or data.selected) or (list.multi and 'none' or list.values[1]), true);
                        self:UpdateOptions();
                        return list
                    end

                    tooltip(toggle);
                    toggle:SetText(toggle.text);
                    toggle:SetState(toggle.state, true);
                    self:UpdateOptions();
                    return toggle
                end

                -- // Slider
                function section:AddSlider(data)
                    local slider = {
                        class = 'slider';
                        flag = data.flag;
                        text = '';
                        tooltip = '';
                        suffix = '';
                        order = #self.options+1;
                        value = 0;
                        min = 0;
                        max = 100;
                        increment = 1;
                        callback = function() end;
                        enabled = true;
                        dragging = false;
                        focused = false;
                        risky = false;
                        objects = {};
                    };

                    local blacklist = {'objects', 'dragging'};
                    for i,v in next, data do
                        if not table.find(blacklist, i) and (slider[i] ~= nil and typeof(slider[i]) == typeof(v)) then
                            slider[i] = v;
                        end
                    end
                    
                    table.insert(self.options, slider)

                    if slider.flag then
                        library.flags[slider.flag] = slider.value;
                        library.options[slider.flag] = slider;
                    end

                    --- Create Objects ---
                    do
                        local objs = slider.objects;
                        local z = library.zindexOrder.window+25;

                        objs.holder = utility:Draw('Square', {
                            Size = newUDim2(1,0,0,38);
                            Transparency = 0;
                            ZIndex = z+4;
                            Parent = section.objects.optionholder;
                        })

                        objs.background = utility:Draw('Square', {
                            Size = newUDim2(1,-4,0,16);
                            Position = newUDim2(0,2,1,-19);
                            ThemeColor = 'Option Background';
                            ZIndex = z+2;
                            Parent = objs.holder;
                        })

                        objs.slider = utility:Draw('Square', {
                            Size = newUDim2(0,0,1,0);
                            ThemeColor = 'Accent';
                            ZIndex = z+3;
                            Parent = objs.background;
                        })

                        objs.border1 = utility:Draw('Square', {
                            Size = newUDim2(1,2,1,2);
                            Position = newUDim2(0,-1,0,-1);
                            ThemeColor = 'Option Border 1';
                            ZIndex = z+1;
                            Parent = objs.background;
                        })

                        objs.border2 = utility:Draw('Square', {
                            Size = newUDim2(1,2,1,2);
                            Position = newUDim2(0,-1,0,-1);
                            ThemeColor = 'Option Border 2';
                            ZIndex = z;
                            Parent = objs.border1;
                        })

                        objs.gradient = utility:Draw('Image', {
                            Size = newUDim2(1,0,1,0);
                            Data = library.images.gradientp90;
                            Transparency = .65;
                            ZIndex = z+4;
                            Parent = objs.background;
                        })

                        objs.text = utility:Draw('Text', {
                            Position = newUDim2(0,2,0,1);
                            ThemeColor = 'Option Text 3';
                            Size = 13;
                            Font = 2;
                            ZIndex = z+1;
                            Outline = true;
                            Parent = objs.holder;
                        })

                        objs.plusDetector = utility:Draw('Square', {
                            Size = newUDim2(0,22,0,18);
                            Position = newUDim2(1,-46,0,-1);
                            Transparency = 0;
                            ZIndex = z+5;
                            Parent = objs.holder;
                        })

                        objs.minusDetector = utility:Draw('Square', {
                            Size = newUDim2(0,22,0,18);
                            Position = newUDim2(1,-22,0,-1);
                            Transparency = 0;
                            ZIndex = z+5;
                            Parent = objs.holder;
                        })

                        objs.plusText = utility:Draw('Text', {
                            Position = newUDim2(.5,0,0,-1);
                            ThemeColor = 'Option Text 3';
                            Text = '+';
                            Size = 15;
                            Font = 2;
                            ZIndex = z+6;
                            Center = true;
                            Outline = true;
                            Parent = objs.plusDetector;
                        })

                        objs.minusText = utility:Draw('Text', {
                            Position = newUDim2(.5,0,0,-1);
                            ThemeColor = 'Option Text 3';
                            Text = '-';
                            Size = 15;
                            Font = 2;
                            ZIndex = z+6;
                            Center = true;
                            Outline = true;
                            Parent = objs.minusDetector;
                        })

                        utility:Connection(objs.plusDetector.MouseEnter, function()
                            objs.plusText.ThemeColor = ''
                            objs.plusText.Color = fromrgb(255, 255, 255)
                        end)

                        utility:Connection(objs.plusDetector.MouseLeave, function()
                            objs.plusText.ThemeColor = 'Option Text 3'
                        end)

                        utility:Connection(objs.minusDetector.MouseEnter, function()
                            objs.minusText.ThemeColor = ''
                            objs.minusText.Color = fromrgb(255, 255, 255)
                        end)

                        utility:Connection(objs.minusDetector.MouseLeave, function()
                            objs.minusText.ThemeColor = 'Option Text 3'
                        end)

                        utility:Connection(objs.holder.MouseEnter, function()
                            objs.border1.ThemeColor = 'Accent';
                        end)

                        utility:Connection(objs.holder.MouseLeave, function()
                            objs.border1.ThemeColor = slider.dragging and 'Accent' or 'Option Border 1';
                        end)

                        utility:Connection(slider.objects.plusDetector.MouseButton1Down,function()
                            slider:SetValue(slider.value + (inputservice:IsKeyDown(Enum.KeyCode.LeftShift) and 10 or slider.increment))
                        end)
    
                        utility:Connection(slider.objects.minusDetector.MouseButton1Down,function()
                            slider:SetValue(slider.value - (inputservice:IsKeyDown(Enum.KeyCode.LeftShift) and 10 or slider.increment))
                        end)


                        local c;
                        local inputNumber = '';
                        utility:Connection(slider.objects.holder.MouseButton1Down, function()
                            if inputservice:IsKeyDown(Enum.KeyCode.LeftControl) then
                                if slider.focused then
                                    slider.focused = false;
                                    c:Disconnect();
                                else
                                    objs.text.Text = slider.text..': '..tostring(slider.value)..tostring(slider.suffix)..' []';
                                    slider.focused = true;
                                    inputNumber = '';
                                    c = utility:Connection(inputservice.InputBegan, function(inp)
                                        if library.numberStrings[inp.KeyCode.Name] then
                                            local number = library.numberStrings[inp.KeyCode.Name];
                                            inputNumber = inputNumber..tostring(number);
                                            objs.text.Text = slider.text..': '..string.format("%.14g",slider.value)..tostring(slider.suffix)..' ['..inputNumber..']';
                                        elseif inp.KeyCode == Enum.KeyCode.Backspace then
                                            inputNumber = inputNumber:sub(1,-2);
                                            objs.text.Text = slider.text..': '..string.format("%.14g",slider.value)..tostring(slider.suffix)..' ['..inputNumber..']';
                                        elseif inp.KeyCode == Enum.KeyCode.Return then
                                            slider:SetValue(tonumber(inputNumber))
                                            slider.focused = false;
                                            c:Disconnect();
                                        elseif inp.KeyCode == Enum.KeyCode.Escape then
                                            slider:SetValue(slider.value, true)
                                            slider.focused = false;
                                            c:Disconnect();
                                        end
                                    end)

                                end


                            else
                                slider.dragging = true;
                                library.draggingSlider = slider;
                            end
                        end)

                        utility:Connection(button1up, function()
                            objs.border1.ThemeColor = objs.holder.Hover and 'Accent' or 'Option Border 1';
                            slider.dragging = false;
                            library.draggingSlider = nil;
                        end)

                    end
                    ----------------------

                    function slider:SetValue(value, nocallback)
                        if typeof(value) == 'number' then
                            local newValue = clamp(self.increment * floor(value/self.increment), self.min, self.max);
                            local size, pos = self.objects.slider.Size, self.objects.slider.Position;

                            if self.min >= 0 then
                                size = newUDim2((newValue - self.min) / (self.max - self.min), 0, 1, 0);
                            else
                                size = newUDim2(newValue / (self.max - self.min), 0, 1, 0);
                                pos = newUDim2((0 - self.min) / (self.max - self.min), 0, 0, 0);
                            end

                            utility:Tween(self.objects.slider, 'Size', size, .05, Enum.EasingDirection.Out, Enum.EasingStyle.Quad);
                            utility:Tween(self.objects.slider, 'Position', pos, .05, Enum.EasingDirection.Out, Enum.EasingStyle.Quad);

                            self.value = newValue;
                            library.flags[self.flag] = newValue;
                            self.objects.text.Text = slider.text..': '..string.format("%.14g",newValue)..tostring(self.suffix);
                            self.objects.text.ThemeColor = (self.min < 0 and newValue == 0 or newValue == self.min)  and (self.risky and 'Risky Text' or 'Option Text 3') or (self.risky and 'Risky Text Enabled' or 'Option Text 1');

                            if not nocallback then
                                self.callback(newValue);
                            end

                        end
                    end

                    function slider:SetText(str)
                        if typeof(str) == 'string' then
                            self.text = str;
                            self.objects.text.Text = str..': '..tostring(self.value)..tostring(self.suffix);
                        end
                    end

                    tooltip(slider);
                    slider:SetText(slider.text);
                    slider:SetValue(slider.value, true);
                    self:UpdateOptions();
                    return slider
                end

                -- // Button
                function section:AddButton(data)
                    local button = {
                        class = 'button';
                        flag = data.flag;
                        text = '';
                        suffix = '';
                        tooltip = '';
                        order = #self.options+1;
                        callback = function() end;
                        confirm = false;
                        enabled = true;
                        risky = false;
                        objects = {};
                        subbuttons = {};
                    };

                    local blacklist = {'objects'};
                    for i,v in next, data do
                        if not table.find(blacklist, i) and button[i] ~= nil then
                            button[i] = v;
                        end
                    end
        
                    table.insert(self.options, button)

                    if button.flag then
                        library.options[button.flag] = button;
                    end

                    --- Create Objects ---
                    do
                        local objs = button.objects;
                        local z = library.zindexOrder.window+25;

                        objs.holder = utility:Draw('Square', {
                            Size = newUDim2(1,0,0,28);
                            Transparency = 0;
                            ZIndex = z+4;
                            Parent = section.objects.optionholder;
                        })

                        objs.background = utility:Draw('Square', {
                            Size = newUDim2(1,-4,0,20);
                            Position = newUDim2(0,2,0,4);
                            ThemeColor = 'Option Background';
                            ZIndex = z+2;
                            Parent = objs.holder;
                        })

                        objs.border1 = utility:Draw('Square', {
                            Size = newUDim2(1,2,1,2);
                            Position = newUDim2(0,-1,0,-1);
                            ThemeColor = 'Option Border 1';
                            ZIndex = z+1;
                            Parent = objs.background;
                        })

                        objs.border2 = utility:Draw('Square', {
                            Size = newUDim2(1,2,1,2);
                            Position = newUDim2(0,-1,0,-1);
                            ThemeColor = 'Option Border 2';
                            ZIndex = z;
                            Parent = objs.border1;
                        })

                        objs.gradient = utility:Draw('Image', {
                            Size = newUDim2(1,0,1,0);
                            Data = library.images.gradientp90;
                            Transparency = .65;
                            ZIndex = z+3;
                            Parent = objs.background;
                        })

                        objs.text = utility:Draw('Text', {
                            Position = newUDim2(.5,0,0,0);
                            ThemeColor = 'Option Text 3';
                            Size = 13;
                            Font = 2;
                            ZIndex = z+4;
                            Outline = true;
                            Center = true;
                            Parent = objs.background;
                        })

                        utility:Connection(objs.holder.MouseEnter, function()
                            objs.border1.ThemeColor = 'Accent';
                        end)

                        utility:Connection(objs.holder.MouseLeave, function()
                            objs.border1.ThemeColor = 'Option Border 1';
                            objs.text.ThemeColor = self.risky and 'Risky Text' or 'Option Text 3';
                            objs.background.ThemeColor = 'Option Background';
                            objs.background.ThemeColorOffset = 0;
                        end)

                        utility:Connection(objs.holder.MouseButton1Up, function()
                            objs.text.ThemeColor = self.risky and 'Risky Text' or  'Option Text 3';
                            objs.background.ThemeColor = 'Option Background';
                            objs.background.ThemeColorOffset = 0;
                        end)

                        local clicked, counting = false, false
                        utility:Connection(objs.holder.MouseButton1Down, function()
                            objs.text.ThemeColor = self.risky and 'Risky Text Enabled' or 'Option Text 2';
                            objs.background.ThemeColor = 'Accent';
                            objs.background.ThemeColorOffset = -95;

                            task.spawn(function() -- this is ugly and i do not care :)
                                if button.confirm then
                                    if clicked then
                                        clicked = false
                                        counting = false
                                        objs.text.Text = button.text
                                        button.callback()
                                    else
                                        clicked = true
                                        counting = true
                                        for i = 3,1,-1 do
                                            if not counting then
                                                break
                                            end
                                            objs.text.Text = 'Confirm '..button.text..'? '..tostring(i)
                                            wait(1)
                                        end
                                        clicked = false
                                        counting = false
                                        objs.text.Text = button.text
                                    end
                                else
                                    button.callback()
                                end
                            end)

                        end)

                    end
                    ----------------------
                    function button:AddButton(data)
                        local button = {
                            class = 'button';
                            flag = data.flag;
                            text = '';
                            suffix = '';
                            tooltip = '';
                            order = #self.subbuttons+1;
                            callback = function() end;
                            confirm = false;
                            enabled = true;
                            objects = {};
                        };
    
                        local blacklist = {'objects'};
                        for i,v in next, data do
                            if not table.find(blacklist, i) and button[i] ~= nil then
                                button[i] = v;
                            end
                        end
            
                        table.insert(self.subbuttons, button)
    
                        if button.flag then
                            library.options[button.flag] = button;
                        end
    
                        --- Create Objects ---
                        do
                            local objs = button.objects;
                            local z = library.zindexOrder.window+25;
    
                            objs.holder = utility:Draw('Square', {
                                Size = newUDim2(1,0,1,0);
                                Transparency = 0;
                                ZIndex = z+5;
                                Parent = self.objects.holder;
                            })
    
                            objs.background = utility:Draw('Square', {
                                Size = newUDim2(1,-4,1,-8);
                                Position = newUDim2(0,2,0,4);
                                ThemeColor = 'Option Background';
                                ZIndex = z+2;
                                Parent = objs.holder;
                            })
    
                            objs.border1 = utility:Draw('Square', {
                                Size = newUDim2(1,2,1,2);
                                Position = newUDim2(0,-1,0,-1);
                                ThemeColor = 'Option Border 1';
                                ZIndex = z+1;
                                Parent = objs.background;
                            })
    
                            objs.border2 = utility:Draw('Square', {
                                Size = newUDim2(1,2,1,2);
                                Position = newUDim2(0,-1,0,-1);
                                ThemeColor = 'Option Border 2';
                                ZIndex = z;
                                Parent = objs.border1;
                            })
    
                            objs.gradient = utility:Draw('Image', {
                                Size = newUDim2(1,0,1,0);
                                Data = library.images.gradientp90;
                                Transparency = .65;
                                ZIndex = z+3;
                                Parent = objs.background;
                            })
    
                            objs.text = utility:Draw('Text', {
                                Position = newUDim2(.5,0,0,0);
                                ThemeColor = 'Option Text 3';
                                Size = 13;
                                Font = 2;
                                ZIndex = z+4;
                                Outline = true;
                                Center = true;
                                Parent = objs.background;
                            })
    
                            utility:Connection(objs.holder.MouseEnter, function()
                                objs.border1.ThemeColor = 'Accent';
                            end)
    
                            utility:Connection(objs.holder.MouseLeave, function()
                                objs.border1.ThemeColor = 'Option Border 1';
                                objs.text.ThemeColor = self.risky and 'Risky Text' or 'Option Text 3';
                                objs.background.ThemeColor = 'Option Background';
                                objs.background.ThemeColorOffset = 0;
                            end)
    
                            utility:Connection(objs.holder.MouseButton1Up, function()
                                objs.text.ThemeColor = self.risky and 'Risky Text' or 'Option Text 3';
                                objs.background.ThemeColor = 'Option Background';
                                objs.background.ThemeColorOffset = 0;
                            end)
    
                            local clicked, counting = false, false
                            utility:Connection(objs.holder.MouseButton1Down, function()
                                objs.text.ThemeColor = self.risky and 'Risky Text Enabled' or 'Option Text 2';
                                objs.background.ThemeColor = 'Accent';
                                objs.background.ThemeColorOffset = -95;
    
                                task.spawn(function() -- this is ugly and i do not care :)
                                    if button.confirm then
                                        if clicked then
                                            clicked = false
                                            counting = false
                                            objs.text.Text = button.text
                                            button.callback()
                                        else
                                            clicked = true
                                            counting = true
                                            for i = 3,1,-1 do
                                                if not counting then
                                                    break
                                                end
                                                objs.text.Text = 'Confirm '..button.text..'? '..tostring(i)
                                                wait(1)
                                            end
                                            clicked = false
                                            counting = false
                                            objs.text.Text = button.text
                                        end
                                    else
                                        button.callback()
                                    end
                                end)
    
                            end)
    
                        end
                        ----------------------
    
                        function button:SetText(str)
                            if typeof(str) == 'string' then
                                self.text = str;
                                self.objects.text.Text = str;
                            end
                        end
    
                        tooltip(button);
                        button:SetText(button.text);
                        self:UpdateOptions();
                        return button
                    end
                    ----------------------

                    function button:UpdateOptions() -- this so dumb XD
                        local buttons = 1 + #self.subbuttons;
                        local buttonSize = (1 / buttons) - .005;
                        self.objects.background.Size = newUDim2(buttonSize,-4,0,14);
                        for i,v in next, self.subbuttons do
                            v.objects.holder.Size = newUDim2(buttonSize,0,1,0);
                            v.objects.holder.Position = newUDim2(i * buttonSize + .01, 0, 0, 0)
                        end
                    end

                    function button:SetText(str)
                        if typeof(str) == 'string' then
                            self.text = str;
                            self.objects.text.Text = str;
                        end
                    end

                    tooltip(button);
                    button:SetText(button.text);
                    self:UpdateOptions();
                    return button
                end

                -- // Separator
                function section:AddSeparator(data)
                    local separator = {
                        class = 'separator';
                        flag = data.flag;
                        text = '';
                        order = #self.options+1;
                        enabled = true;
                        objects = {};
                    };

                    local blacklist = {'objects', 'dragging'};
                    for i,v in next, data do
                        if not table.find(blacklist, i) and (separator[i] ~= nil and typeof(separator[i]) == typeof(v)) then
                            separator[i] = v;
                        end
                    end
        
                    table.insert(self.options, separator)

                    --- Create Objects ---
                    do
                        local objs = separator.objects;
                        local z = library.zindexOrder.window+25;

                        objs.holder = utility:Draw('Square', {
                            Size = newUDim2(1,0,0,18);
                            Transparency = 0;
                            ZIndex = z;
                            Parent = section.objects.optionholder;
                        })

                        objs.line1 = utility:Draw('Square', {
                            Position = newUDim2(0,0,0,1);
                            ThemeColor = 'Option Background';
                            ZIndex = z+1;
                            Parent = objs.holder;
                        })

                        objs.line2 = utility:Draw('Square', {
                            Position = newUDim2(0,0,0,1);
                            ThemeColor = 'Option Background';
                            ZIndex = z+1;
                            Parent = objs.holder;
                        })

                        objs.border1 = utility:Draw('Square', {
                            Size = newUDim2(1,2,1,2);
                            Position = newUDim2(0,-1,0,-1);
                            ThemeColor = 'Option Border 2';
                            ZIndex = z;
                            Parent = objs.line1;
                        })

                        objs.border2 = utility:Draw('Square', {
                            Size = newUDim2(1,2,1,2);
                            Position = newUDim2(0,-1,0,-1);
                            ThemeColor = 'Option Border 2';
                            ZIndex = z;
                            Parent = objs.line2;
                        })

                        objs.text = utility:Draw('Text', {
                            Position = newUDim2(.5,0,0,1);
                            ThemeColor = 'Option Text 2';
                            Size = 13;
                            Font = 2;
                            ZIndex = z;
                            Outline = true;
                            Center = true;
                            Parent = objs.holder;
                        })

                    end
                    ----------------------

                    function separator:SetText(str)
                        if typeof(str) == 'string' then
                            self.text = str;
                            self.objects.text.Text = str;
                            local xScale = ( 1- utility:ConvertNumberRange(self.objects.text.TextBounds.X, 0, self.objects.holder.Object.Size.X, 0, 1)) / 2 - (str == '' and 0 or .04)
                            self.objects.line1.Size = newUDim2(xScale, 0, 0, 1)
                            self.objects.line2.Size = newUDim2(xScale, 0, 0, 1)
                            self.objects.line1.Position = newUDim2(0,1,.5,-1)
                            self.objects.line2.Position = newUDim2(1 - self.objects.line2.Size.X.Scale,-1,.5,-1)
                        end
                    end

                    separator:SetText(separator.text);
                    self:UpdateOptions();
                    return separator
                end

                -- // Color Picker
                function section:AddColor(data, trans, callback)
                    if typeof(data) == 'Color3' then
                        data = {
                            color = data,
                            trans = trans or 0,
                            callback = callback or function() end
                        }
                    elseif typeof(data) ~= 'table' then
                        data = {}
                    end

                    local color = {
                        class = 'color';
                        flag = data.flag;
                        text = '';
                        tooltip = '';
                        order = #self.options+1;
                        callback = function() end;
                        color = Color3.new(1,1,1);
                        trans = 0;
                        open = false;
                        enabled = true;
                        risky = false;
                        objects = {};
                    };

                    local blacklist = {'objects'};
                    for i,v in next, data do
                        if not table.find(blacklist, i) and color[i] ~= nil then
                            color[i] = v
                        end
                    end
                    
                    table.insert(self.options, color)

                    if color.flag then
                        library.flags[color.flag] = color.color;
                        library.options[color.flag] = color;
                    end

                    --- Create Objects ---
                    do
                        local objs = color.objects;
                        local z = library.zindexOrder.window+25;

                        objs.holder = utility:Draw('Square', {
                            Size = newUDim2(1,0,0,24);
                            Transparency = 0;
                            ZIndex = z+5;
                            Parent = section.objects.optionholder;
                        })

                        objs.background = utility:Draw('Square', {
                            Size = newUDim2(0,20,0,14);
                            Position = newUDim2(1,-22,0,5);
                            ZIndex = z+3;
                            Parent = objs.holder;
                        })

                        objs.gradient = utility:Draw('Image', {
                            Size = newUDim2(1,0,1,0);
                            Data = library.images.gradientp45;
                            Transparency = .25;
                            ZIndex = z+4;
                            Parent = objs.background;
                        })

                        objs.border1 = utility:Draw('Square', {
                            Size = newUDim2(1,2,1,2);
                            Position = newUDim2(0,-1,0,-1);
                            ThemeColor = 'Option Border 1';
                            ZIndex = z+2;
                            Parent = objs.background;
                        })

                        objs.border2 = utility:Draw('Square', {
                            Size = newUDim2(1,2,1,2);
                            Position = newUDim2(0,-1,0,-1);
                            ThemeColor = 'Option Border 2';
                            ZIndex = z+1;
                            Parent = objs.border1;
                        })

                        objs.text = utility:Draw('Text', {
                            Position = newUDim2(0,2,0,2);
                            ThemeColor = color.risky and 'Risky Text Enabled' or 'Option Text 3';
                            Size = 13;
                            Font = 2;
                            ZIndex = z+1;
                            Outline = true;
                            Parent = objs.holder;
                        })

                        utility:Connection(objs.holder.MouseEnter, function()
                            objs.border1.ThemeColor = 'Accent';
                        end)

                        utility:Connection(objs.holder.MouseLeave, function()
                            objs.border1.ThemeColor = color.state and 'Accent' or 'Option Border 1';
                        end)

                        utility:Connection(objs.holder.MouseButton1Down, function()
                            color:SetOpen(not color.open);
                        end)

                    end
                    ----------------------

                    function color:SetText(str)
                        if typeof(str) == 'string' then
                            self.text = str;
                            self.objects.text.Text = str;
                        end
                    end

                    function color:SetColor(c3, nocallback)
                        if typeof(c3) == 'Color3' then
                            local h,s,v = c3:ToHSV(); c3 = fromhsv(h, clamp(s,.005,.995), clamp(v,.005,.995));
                            self.color = c3;
                            self.objects.background.Color = c3;
                            if not nocallback then
                                self.callback(c3, self.trans);
                            end
                            if self.open then
                                window.colorpicker:Visualize(self.color, self.trans);
                            end
                            if self.flag then
                                library.flags[self.flag] = c3;
                            end
                        end
                    end

                    function color:SetTrans(trans, nocallback)
                        if typeof(trans) == 'number' then
                            self.trans = trans;
                            if not nocallback then
                                self.callback(self.color, trans);
                            end
                            if self.open then
                                window.colorpicker:Visualize(self.color, self.trans);
                            end
                        end
                    end

                    function color:SetOpen(bool)
                        if typeof(bool) == 'boolean' then
                            self.open = bool
                            if bool then
                                if window.colorpicker.selected then
                                    window.colorpicker.selected.open = false;
                                end
                                window.colorpicker.selected = color
                                window.colorpicker.objects.background.Parent = self.objects.background;
                                window.colorpicker.objects.background.Visible = true;
                                window.colorpicker:Visualize(color.color, color.trans)
                            elseif window.colorpicker.selected == color then
                                window.colorpicker.selected = nil;
                                window.colorpicker.objects.background.Parent = window.objects.background;
                                window.colorpicker.objects.background.Visible = false;
                            end
                        end
                    end

                    tooltip(color);
                    color:SetText(color.text);
                    color:SetColor(color.color, true);
                    color:SetTrans(color.trans, true);
                    self:UpdateOptions();
                    return color
                end

                -- // Text Box
                function section:AddBox(data)
                    local box = {
                        class = 'box';
                        flag = data.flag;
                        text = '';
                        input = '';
                        order = #self.options+1;
                        callback = function() end;
                        enabled = true;
                        focused = false;
                        risky = false;
                        objects = {};
                    };

                    local blacklist = {'objects', 'dragging'};
                    for i,v in next, data do
                        if not table.find(blacklist, i) and box[i] ~= nil then
                            box[i] = v;
                        end
                    end
                    
                    table.insert(self.options, box)

                    if box.flag then
                        library.flags[box.flag] = box.input;
                        library.options[box.flag] = box;
                    end

                    --- Create Objects ---
                    do
                        local objs = box.objects;
                        local z = library.zindexOrder.window+25;

                        objs.holder = utility:Draw('Square', {
                            Size = newUDim2(1,0,0,44);
                            Transparency = 0;
                            ZIndex = z+4;
                            Parent = section.objects.optionholder;
                        })

                        objs.background = utility:Draw('Square', {
                            Size = newUDim2(1,-4,0,22);
                            Position = newUDim2(0,2,1,-24);
                            ThemeColor = 'Option Background';
                            ZIndex = z+2;
                            Parent = objs.holder;
                        })

                        objs.border1 = utility:Draw('Square', {
                            Size = newUDim2(1,2,1,2);
                            Position = newUDim2(0,-1,0,-1);
                            ThemeColor = 'Option Border 1';
                            ZIndex = z+1;
                            Parent = objs.background;
                        })

                        objs.border2 = utility:Draw('Square', {
                            Size = newUDim2(1,2,1,2);
                            Position = newUDim2(0,-1,0,-1);
                            ThemeColor = 'Option Border 2';
                            ZIndex = z;
                            Parent = objs.border1;
                        })

                        objs.gradient = utility:Draw('Image', {
                            Size = newUDim2(1,0,1,0);
                            Data = library.images.gradientp90;
                            Transparency = .65;
                            ZIndex = z+4;
                            Parent = objs.background;
                        })

                        objs.text = utility:Draw('Text', {
                            Position = newUDim2(0,2,0,2);
                            ThemeColor = box.risky and 'Risky Text Enabled' or 'Option Text 2';
                            Size = 13;
                            Font = 2;
                            ZIndex = z+1;
                            Outline = true;
                            Parent = objs.holder;
                        })

                        objs.inputText = utility:Draw('Text', {
                            Position = newUDim2(0,6,0,3);
                            ThemeColor = 'Option Text 2';
                            Size = 13;
                            Font = 2;
                            ZIndex = z+5;
                            Outline = true;
                            Parent = objs.background;
                        })

                        utility:Connection(objs.holder.MouseEnter, function()
                            objs.border1.ThemeColor = 'Accent';
                        end)

                        utility:Connection(objs.holder.MouseLeave, function()
                            if not box.focused then
                                objs.border1.ThemeColor = 'Option Border 1';
                            end
                        end)

                        utility:Connection(objs.holder.MouseButton1Down, function()
                            if box.focused then
                                box:ReleaseFocus(true);
                            else
                                actionservice:BindAction(
                                    'FreezeMovement',
                                    function()
                                        return Enum.ContextActionResult.Sink
                                    end,
                                    false,
                                    unpack(Enum.PlayerActions:GetEnumItems())
                                )
                                box:CaptureFocus(inputservice:IsKeyDown(Enum.KeyCode.LeftControl));
                                if inputservice:IsKeyDown(Enum.KeyCode.LeftControl) then
                                    objs.inputText.Text = '|';
                                end
                            end
                        end)

                    end
                    ----------------------

                    function box:SetText(str)
                        if typeof(str) == 'string' then
                            self.text = str;
                            self.objects.text.Text = str;
                        end
                    end

                    local c, blinkConn
                    local input = box.input;
                    function box:SetInput(str, nocallback)
                        if typeof(str) == 'string' then
                            self.input = str;
                            input = str;
                            self.objects.inputText.Text = str;
                            if not nocallback then
                                self.callback(str);
                            end
                            if self.flag then
                                library.flags[self.flag] = str;
                            end
                        end
                    end

                    function box:CaptureFocus(clear)
                        if box.focused then return end
                        box.focused = true
                        objs.border1.ThemeColor = 'Accent';

                        if clear then
                            input = '';
                        else
                            input = self.input or '';
                        end

                        self.objects.inputText.ThemeColor = 'Option Text 1';
                        local blink = true
                        local lastBlink = tick()
                        self.objects.inputText.Text = input .. '|';

                        blinkConn = utility:Connection(runservice.RenderStepped, function()
                            if box.focused then
                                if tick() - lastBlink > 0.45 then
                                    blink = not blink
                                    lastBlink = tick()
                                    self.objects.inputText.Text = input .. (blink and '|' or '')
                                end
                            end
                        end)

                        c = utility:Connection(inputservice.InputBegan, function(inp)
                            if inp.KeyCode == Enum.KeyCode.Return then
                                box:ReleaseFocus(true);
                            elseif inp.UserInputType == Enum.UserInputType.MouseButton1 then
                                local mp = inputservice:GetMouseLocation()
                                local bp = objs.background.Object.Position
                                local bs = objs.background.Object.Size
                                if not (mp.X >= bp.X and mp.X <= bp.X + bs.X and mp.Y >= bp.Y and mp.Y <= bp.Y + bs.Y) then
                                    box:ReleaseFocus(true);
                                end
                            elseif inp.KeyCode == Enum.KeyCode.Escape then
                                input = self.input
                                box:ReleaseFocus(false);
                            elseif inp.KeyCode == Enum.KeyCode.Backspace then
                                input = input:sub(1,-2);
                                blink = true;
                                lastBlink = tick();
                                self.objects.inputText.Text = input .. '|';
                            elseif #inp.KeyCode.Name == 1 or table.find(whitelistedBoxKeys, inp.KeyCode) or inp.KeyCode.Name == 'Space' or inp.KeyCode.Name == 'Minus' or inp.KeyCode.Name == 'Equals' or inp.KeyCode.Name == 'Backquote' then
                                local wlIdx = table.find(whitelistedBoxKeys, inp.KeyCode)
                                local keyString = inp.KeyCode.Name == 'Space' and ' ' or inp.KeyCode.Name == 'Minus' and '_' or inp.KeyCode.Name == 'Equals' and '+' or inp.KeyCode.Name == 'Backquote' and '~' or wlIdx ~= nil and tostring(wlIdx-1) or inp.KeyCode.Name
                                if not (inputservice:IsKeyDown(Enum.KeyCode.LeftShift) and not inputservice:IsKeyDown(Enum.KeyCode.RightShift)) then
                                    keyString = keyString:lower();
                                    if inp.KeyCode.Name == 'Minus' then
                                        keyString = '-'
                                    elseif inp.KeyCode.Name == 'Equals' then
                                        keyString = '='
                                    elseif inp.KeyCode.Name == 'Backquote' then
                                        keyString = '`'
                                    end
                                else
                                    if keyString == '1' then keyString = '!'
                                    elseif keyString == '2' then keyString = '@'
                                    elseif keyString == '3' then keyString = '#'
                                    elseif keyString == '4' then keyString = '$'
                                    elseif keyString == '5' then keyString = '%'
                                    elseif keyString == '6' then keyString = '^'
                                    elseif keyString == '7' then keyString = '&'
                                    elseif keyString == '8' then keyString = '*'
                                    elseif keyString == '9' then keyString = '('
                                    elseif keyString == '0' then keyString = ')'
                                    end
                                end
                                input = input..keyString;
                                blink = true;
                                lastBlink = tick();
                                self.objects.inputText.Text = input .. '|';
                            end
                        end)

                    end

                    function box:ReleaseFocus(apply)
                        if not box.focused then return end
                        box.focused = false;
                        objs.border1.ThemeColor = 'Option Border 1';
                        self.objects.inputText.ThemeColor = 'Option Text 2';
                        if blinkConn then
                            blinkConn:Disconnect();
                            blinkConn = nil;
                        end
                        if c then
                            c:Disconnect();
                            c = nil;
                        end
                        pcall(function()
                            actionservice:UnbindAction('FreezeMovement');
                        end)
                        if apply then
                            box:SetInput(input);
                        else
                            self.objects.inputText.Text = self.input;
                        end
                    end

                    tooltip(box);
                    box:SetText(box.text);
                    box:SetInput(box.input, true);
                    self:UpdateOptions();
                    return box
                end

                -- // Keybind
                function section:AddBind(data)
                    local bind = {
                        class = 'bind';
                        flag = data.flag;
                        text = '';
                        tooltip = '';
                        bind = 'none';
                        mode = 'toggle';
                        order = #self.options+1;
                        callback = function() end;
                        keycallback = function() end;
                        indicatorValue = library.keyIndicator:AddValue({value = 'value', key = 'key', enabled = false});
                        noindicator = false;
                        state = false;
                        nomouse = false;
                        enabled = true;
                        binding = false;
                        risky = false;
                        objects = {};
                    };

                    local blacklist = {'objects'};
                    for i,v in next, data do
                        if not table.find(blacklist, i) and bind[i] ~= nil then
                            bind[i] = v
                        end
                    end
                    
                    table.insert(self.options, bind)

                    if bind.flag then
                        library.options[bind.flag] = bind;
                    end

                    --- Create Objects ---
                    do
                        local objs = bind.objects;
                        local z = library.zindexOrder.window+25;

                        objs.holder = utility:Draw('Square', {
                            Size = newUDim2(1,0,0,24);
                            Transparency = 0;
                            ZIndex = z+5;
                            Parent = section.objects.optionholder;
                        })

                        objs.text = utility:Draw('Text', {
                            Position = newUDim2(0,2,0,4);
                            ThemeColor = bind.risky and 'Risky Text' or 'Option Text 2';
                            Size = 13;
                            Font = 2;
                            ZIndex = z+1;
                            Outline = true;
                            Parent = objs.holder;
                        })

                        objs.keyText = utility:Draw('Text', {
                            ThemeColor = 'Option Text 3';
                            Size = 13;
                            Font = 2;
                            ZIndex = z+1;
                            Parent = objs.holder;
                        })

                        utility:Connection(objs.holder.MouseEnter, function()
                            objs.keyText.ThemeColor = 'Accent';
                        end)

                        utility:Connection(objs.holder.MouseLeave, function()
                            objs.keyText.ThemeColor = bind.binding and 'Accent' or 'Option Text 3';
                        end)

                        utility:Connection(objs.holder.MouseButton1Down, function()
                            if not bind.binding then
                                bind:SetKeyText('...');
                                bind.binding = true;
                            end
                        end)

                    end
                    ----------------------

                    local c

                    function bind:SetText(str)
                        if typeof(str) == 'string' then
                            self.text = str;
                            self.objects.text.Text = str;
                            self.indicatorValue:SetKey(str);
                        end
                    end

                    function bind:SetBind(keybind)
                        if c then
                            c:Disconnect();
                            if bind.flag then
                                library.flags[bind.flag] = false;
                            end
                            bind.callback(false);
                        end
                        local keyName = 'NONE'
                        self.bind = (keybind and keybind) or keybind or self.bind
                        if self.bind == Enum.KeyCode.Backspace then
                            self.bind = 'none';
                        else
                            keyName = keyNames[keybind] or keybind.Name or keybind
                        end
                        self.keycallback(self.bind);
                        self:SetKeyText(keyName:upper());
                        self.indicatorValue:SetKey((self.text == nil or self.text == '') and (self.flag == nil and 'unknown' or self.flag) or self.text); -- this is so dumb
                        self.indicatorValue:SetValue('['..keyName:upper()..']');
                        self.objects.keyText.ThemeColor = self.objects.holder.Hover and 'Accent' or 'Option Text 3';
                    end

                    function bind:SetKeyText(str)
                        str = tostring(str);
                        self.objects.keyText.Text = '['..str..']';
                        self.objects.keyText.Position = newUDim2(1,-self.objects.keyText.TextBounds.X, 0, 2);
                    end

                    utility:Connection(inputservice.InputBegan, function(inp)
                        if inputservice:GetFocusedTextBox() then
                            return
                        elseif bind.binding then
                            local key = (table.find({Enum.UserInputType.MouseButton1, Enum.UserInputType.MouseButton2, Enum.UserInputType.MouseButton3}, inp.UserInputType) and not bind.nomouse) and inp.UserInputType
                            bind:SetBind(key or (not table.find(blacklistedKeys, inp.KeyCode)) and inp.KeyCode)
                            bind.binding = false
                        elseif not bind.binding and self.bind == 'none' then
                            bind.state = true
                            library.flags[bind.flag] = bind.state
                        elseif (inp.KeyCode == bind.bind or inp.UserInputType == bind.bind) and not bind.binding then
                            if bind.mode == 'toggle' then
                                bind.state = not bind.state
                                if bind.flag then
                                    library.flags[bind.flag] = bind.state;
                                end
                                bind.callback(bind.state)
                                bind.indicatorValue:SetEnabled(bind.state and not bind.noindicator);
                            elseif bind.mode == 'hold' then
                                if bind.flag then
                                    library.flags[bind.flag] = true;
                                end
                                bind.indicatorValue:SetEnabled(true and not bind.noindicator);
                                c = utility:Connection(runservice.RenderStepped, function()
                                    bind.callback(true);
                                end)
                            end
                        end
                    end)

                    utility:Connection(inputservice.InputEnded, function(inp)
                        if bind.bind ~= 'none' then
                            if inp.KeyCode == bind.bind or inp.UserInputType == bind.key then
                                if c then
                                    c:Disconnect();
                                    if bind.flag then
                                        library.flags[bind.flag] = false;
                                    end
                                    bind.callback(false);
                                    bind.indicatorValue:SetEnabled(false);
                                end
                            end
                        end
                    end)

                    tooltip(bind);
                    bind:SetBind(bind.bind);
                    bind:SetText(bind.text);
                    self:UpdateOptions();
                    return bind
                end

                -- // Dropdown
                function section:AddList(data)
                    local list = {
                        class = 'list';
                        flag = data.flag;
                        text = '';
                        selected = '';
                        tooltip = '';
                        order = #self.options+1;
                        callback = function() end;
                        enabled = true;
                        multi = false;
                        open = false;
                        risky = false;
                        values = {};
                        objects = {};
                    }

                    table.insert(self.options, list);

                    local blacklist = {'objects'};
                    for i,v in next, data do
                        if not table.find(blacklist, i) ~= list[i] ~= nil then
                            list[i] = v
                        end
                    end

                    if list.flag then
                        library.flags[list.flag] = list.selected;
                        library.options[list.flag] = list;
                    end

                    -- Create Objects --
                    do
                        local objs = list.objects;
                        local z = library.zindexOrder.window+25;

                        objs.holder = utility:Draw('Square', {
                            Size = newUDim2(1,0,0,46);
                            Transparency = 0;
                            ZIndex = z+4;
                            Parent = section.objects.optionholder;
                        })

                        objs.background = utility:Draw('Square', {
                            Size = newUDim2(1,-4,0,22);
                            Position = newUDim2(0,2,1,-24);
                            ThemeColor = 'Option Background';
                            ZIndex = z+2;
                            Parent = objs.holder;
                        })

                        objs.border1 = utility:Draw('Square', {
                            Size = newUDim2(1,2,1,2);
                            Position = newUDim2(0,-1,0,-1);
                            ThemeColor = 'Option Border 1';
                            ZIndex = z+1;
                            Parent = objs.background;
                        })

                        objs.border2 = utility:Draw('Square', {
                            Size = newUDim2(1,2,1,2);
                            Position = newUDim2(0,-1,0,-1);
                            ThemeColor = 'Option Border 2';
                            ZIndex = z;
                            Parent = objs.border1;
                        })

                        objs.gradient = utility:Draw('Image', {
                            Size = newUDim2(1,0,1,0);
                            Data = library.images.gradientp90;
                            Transparency = .65;
                            ZIndex = z+4;
                            Parent = objs.background;
                        })

                        objs.text = utility:Draw('Text', {
                            Position = newUDim2(0,2,0,2);
                            ThemeColor = list.risky and 'Risky Text Enabled' or 'Option Text 2';
                            Size = 13;
                            Font = 2;
                            ZIndex = z+1;
                            Outline = true;
                            Parent = objs.holder;
                        })

                        objs.inputText = utility:Draw('Text', {
                            Position = newUDim2(0,6,0,3);
                            ThemeColor = 'Option Text 2';
                            Text = 'none',
                            Size = 13;
                            Font = 2;
                            ZIndex = z+5;
                            Outline = true;
                            Parent = objs.background;
                        })

                        objs.openText = utility:Draw('Text', {
                            Position = newUDim2(1,-14,0,3);
                            ThemeColor = 'Option Text 3';
                            Text = '+';
                            Size = 13;
                            Font = 2;
                            ZIndex = z+5;
                            Outline = true;
                            Parent = objs.background;
                        })

                        utility:Connection(objs.holder.MouseEnter, function()
                            objs.border1.ThemeColor = 'Accent';
                        end)

                        utility:Connection(objs.holder.MouseLeave, function()
                            objs.border1.ThemeColor = 'Option Border 1';
                        end)

                        utility:Connection(objs.holder.MouseButton1Down, function()
                            if list.open then
                                list.open = false;
                                objs.openText.Text = '+';
                                if window.dropdown.selected == list then
                                    window.dropdown.selected = nil;
                                    window.dropdown.objects.background.Visible = false;
                                end
                            else
                                if window.dropdown.selected ~= nil then
                                    window.dropdown.selected.open = false
                                end
                                list.open = true;
                                objs.openText.Text = '-';
                                window.dropdown.selected = list;
                                window.dropdown.objects.background.Visible = true;
                                window.dropdown.objects.background.Parent = objs.holder;
                                window.dropdown:Refresh();
                            end
                        end)


                    end
                    --------------------

                    function list:SetText(str)
                        if typeof(str) == 'string' then
                            self.text = str;
                            self.objects.text.Text = str;
                        end
                    end

                    function list:Select(option, nocallback)
                        option = typeof(option) == 'table' and (self.multi == true and option or (#option == 0 and nil or option[1])) or self.multi == true and {option} or option;
                        if option ~= nil then
                            self.selected = option;
                            local text = typeof(option) == 'table' and (#option == 0 and "none" or table.concat(option, ', ')) or tostring(option);
                            local label = self.objects.inputText
                            label.Text = text;
                            if label.TextBounds.X > self.objects.background.Object.Size.X - 10 then
                                local split = text:split('');
                                for i = 1,#split do
                                    label.Text = table.concat(split, '', 1, i)
                                    if label.TextBounds.X > self.objects.background.Object.Size.X - 10 then
                                        label.Text = label.Text:sub(1,-6)..'...';
                                        break
                                    end
                                end
                            end
                            if self.flag then
                                library.flags[self.flag] = self.selected
                            end
                            if not nocallback then
                                self.callback(self.selected);
                            end
                        end
                    end

                    function list:AddValue(value)
                        table.insert(list.values, tostring(value));
                        if window.dropdown.selected == list then
                            window.dropdown:Refresh()
                        end
                    end

                    function list:RemoveValue(value)
                        if table.find(list.values, value) then
                            table.remove(list.values, table.find(list.values, value));
                            if window.dropdown.selected == list then
                                window.dropdown:Refresh()
                            end
                        end
                    end

                    function list:ClearValues()
                        table.clear(list.values);
                        if window.dropdown.selected == list then
                            window.dropdown:Refresh()
                        end
                    end

                    tooltip(list);
                    list:Select((data.value or data.selected) or (list.multi and 'none' or list.values[1]), true);
                    list:SetText(list.text);
                    self:UpdateOptions();
                    return list
                end

                -- Text
                function section:AddText(data)
                    local text = {
                        class = 'text';
                        flag = data.flag;
                        text = '';
                        tooltip = '';
                        order = #self.options+1;
                        enabled = true;
                        risky = false;
                        objects = {};
                    };

                    local blacklist = {'objects'};
                    for i,v in next, data do
                        if not table.find(blacklist, i) and text[i] ~= nil then
                            text[i] = v
                        end
                    end

                    if data.flag then
                        library.options[data.flag] = text;
                    end

                    table.insert(self.options, text)

                    --- Create Objects ---
                    do
                        local objs = text.objects;
                        local z = library.zindexOrder.window+25;

                        objs.holder = utility:Draw('Square', {
                            Transparency = 0;
                            ZIndex = z+5;
                            Parent = section.objects.optionholder;
                        })

                        objs.text = utility:Draw('Text', {
                            Position = newUDim2(0,2,0,2);
                            ThemeColor = text.risky and 'Risky Text Enabled' or 'Option Text 2';
                            Size = 13;
                            Font = 2;
                            ZIndex = z+1;
                            Outline = true;
                            Parent = objs.holder;
                        })
                    end
                    ----------------------

                    function text:SetText(str)
                        if typeof(str) == 'string' then
                            self.text = str;
                            self.objects.text.Text = str;
                            self.objects.holder.Size = newUDim2(1,0,0,self.objects.text.TextBounds.Y + 6);
                            section:UpdateOptions();
                        end
                    end

                    text:SetText(text.text);
                    self:UpdateOptions();
                    return text
                end

                -----------------------

                section:UpdateOptions();
                section:SetText(section.text);
                self:UpdateSections();
                return section;
            end

            function tab:UpdateSections()
                table.sort(self.sections, function(a,b)
                    return a.order < b.order
                end)

                local last1,last2;
                local padding = 15;
                for _,section in next, self.sections do

                    if section.objects.background.Visible ~= (section.enabled and tab.selected) then
                        section.objects.background.Visible = section.enabled and tab.selected
                        section:UpdateOptions();
                    end
                    
                    if section.enabled then
                        if section.side == 1 then
                            if last1 then
                                section.objects.background.Position = last1.objects.background.Position + newUDim2(0,0,0,last1.objects.background.Object.Size.Y + padding);
                            end
                            last1 = section;
                        elseif section.side == 2 then
                            if last2 then
                                section.objects.background.Position = last2.objects.background.Position + newUDim2(0,0,0,last2.objects.background.Object.Size.Y + padding);
                            end
                            last2 = section;
                        end
                    end

                    section:SetText(section.text)
                    
                end
            end

            function tab:SetText(str)
                if typeof(str) == 'string' then
                    self.text = str;
                    self.objects.text.Text = str;
                    window:UpdateTabs();
                end
            end

            function tab:Select()
                window.selectedTab = tab;
                window:UpdateTabs();
                for i,v in next, window.tabs do
                    if v.callback then
                        v.callback(v == tab)
                    end
                end
            end

            if window.selectedTab == nil then
                tab:Select();
            end

            tab:SetText(tab.text);
            window:UpdateTabs();
            return tab;
        end

        function window:UpdateTabs()
            table.sort(self.tabs, function(a,b)
                return a.order < b.order
            end)
            local pos = 0;
            for i,v in next, self.tabs do
                local objs = v.objects;
                v.selected = v == self.selectedTab;
                objs.background.ThemeColor = v.selected and 'Selected Tab Background' or 'Unselected Tab Background';
                objs.background.Size = newUDim2(0, objs.text.TextBounds.X + 14, 1, v.selected and 1 or 0);
                objs.background.Position = newUDim2(0, pos, 0, 0)

                objs.text.ThemeColor = v.selected and 'Selected Tab Text' or 'Unselected Tab Text';
                objs.text.Position = newUDim2(.5, 0, 0, 3);

                objs.topBorder.ThemeColor = v.selected and 'Accent' or 'Unselected Tab Background';

                pos += objs.background.Size.X.Offset + 1

                v:UpdateSections();

            end
        end

        window:SetOpen(true);
        return window;
    end

    -- Tooltip
    do
        local z = library.zindexOrder.window + 2000;
        tooltipObjects.background = utility:Draw('Square', {
            ThemeColor = 'Group Background';
            ZIndex = z;
            Visible = false;
        })

        tooltipObjects.border1 = utility:Draw('Square', {
            Size = UDim2.new(1,2,1,2);
            Position = UDim2.new(0,-1,0,-1);
            ThemeColor = 'Border 1';
            ZIndex = z-1;
            Parent = tooltipObjects.background;
        })

        tooltipObjects.border2 = utility:Draw('Square', {
            Size = UDim2.new(1,4,1,4);
            Position = UDim2.new(0,-2,0,-2);
            ThemeColor = 'Border 3';
            ZIndex = z-2;
            Parent = tooltipObjects.background;
        })

        tooltipObjects.text = utility:Draw('Text', {
            Position = UDim2.new(0,3,0,0);
            ThemeColor = 'Primary Text';
            Size = 13;
            Font = 2;
            ZIndex = z+1;
            Outline = true;
            Parent = tooltipObjects.background;
        })

        tooltipObjects.riskytext = utility:Draw('Text', {
            Position = UDim2.new(0,3,0,0);
            ThemeColor = 'Risky Text Enabled';
            Text = '[RISKY]';
            Size = 13;
            Font = 2;
            ZIndex = z+1;
            Outline = true;
            Parent = tooltipObjects.background;
        })

    end
    
    -- Watermark
    do
        if not IonHub_User then
            getgenv().IonHub_User = {
                UID = 0, 
                User = "admin"
            }
        end
        self.watermark = {
            objects = {};
            text = {
                {self.cheatname, true},
                {"Private", true},
                {self.gamename, true},
                {'0 fps', true},
                {'0ms', true},
                {'00:00:00', true},
                {'M, D, Y', true},
            };
            lock = 'custom';
            position = newUDim2(0,0,0,0);
            refreshrate = 400;
        }

        function self.watermark:Update()
            self.objects.background.Visible = library.flags.watermark_enabled
            if library.flags.watermark_enabled then
                local date = {os.date('%b',os.time()), os.date('%d',os.time()), os.date('%Y',os.time())}
                local daySuffix = math.floor(date[2]%10)
                date[2] = date[2]..(daySuffix == 1 and 'st' or daySuffix == 2 and 'nd' or daySuffix == 3 and 'rd' or 'th')

                self.text[4][1] = library.stats.fps..' fps'
                self.text[5][1] = floor(library.stats.ping)..'ms'
                self.text[6][1] = os.date('%X', os.time())
                self.text[7][1] = table.concat(date, ', ')

                local text = {};
                for _,v in next, self.text do
                    if v[2] then
                        table.insert(text, v[1]);
                    end
                end

                self.objects.text.Text = table.concat(text,' | ')
                self.objects.background.Size = newUDim2(0, self.objects.text.TextBounds.X + 10, 0, 17)

                local size = self.objects.background.Object.Size;
                local screensize = workspace.CurrentCamera.ViewportSize;

                if self.lock ~= 'Free' then
                    self.position = (
                        self.lock == 'Top Right' and newUDim2(0, screensize.X - size.X - 15, 0, 15) or
                        self.lock == 'Top Left' and newUDim2(0, 15, 0, 15) or
                        self.lock == 'Bottom Right' and newUDim2(0, screensize.X - size.X - 15, 0, screensize.Y - size.Y - 15) or
                        self.lock == 'Bottom Left' and newUDim2(0, 15, 0, screensize.Y - size.Y - 15) or
                        self.lock == 'Top' and newUDim2(0, screensize.X / 2 - size.X / 2, 0, 15) or
                        newUDim2((library.flags.watermark_x or 6) / 100, 0, (library.flags.watermark_y or 1) / 100, 0)
                    )
                end

                self.objects.background.Position = self.position
            end
        end

        do
            local objs = self.watermark.objects;
            local z = self.zindexOrder.watermark;
            
            objs.background = utility:Draw('Square', {
                Visible = false;
                Size = newUDim2(0, 200, 0, 17);
                Position = newUDim2(0,800,0,100);
                ThemeColor = 'Background';
                ZIndex = z;
            })

            objs.border1 = utility:Draw('Square', {
                Size = newUDim2(1,2,1,2);
                Position = newUDim2(0,-1,0,-1);
                ThemeColor = 'Border 2';
                Parent = objs.background;
                ZIndex = z-1;
            })

            objs.border2 = utility:Draw('Square', {
                Size = newUDim2(1,2,1,2);
                Position = newUDim2(0,-1,0,-1);
                ThemeColor = 'Border 3';
                Parent = objs.border1;
                ZIndex = z-2;
            })
            
            objs.topbar = utility:Draw('Square', {
                Size = newUDim2(1,0,0,1);
                ThemeColor = 'Accent';
                ZIndex = z+1;
                Parent = objs.background;
            })

            objs.text = utility:Draw('Text', {
                Position = newUDim2(.5,0,0,2);
                ThemeColor = 'Primary Text';
                Text = 'Watermark Text';
                Size = 13;
                Font = 2;
                ZIndex = z+1;
                Outline = true;
                Center = true;
                Parent = objs.background;
            })

            local wmDragging = false
            local wmMouseStart, wmObjStart

            utility:Connection(objs.background.MouseButton1Down, function(pos)
                if library.open then
                    wmDragging = true
                    wmMouseStart = newVector2(pos.X, pos.Y)
                    wmObjStart = objs.background.Object.Position
                end
            end)

            utility:Connection(button1up, function()
                wmDragging = false
            end)

            utility:Connection(runservice.RenderStepped, function()
                if wmDragging and library.open then
                    local mPos = inputservice:GetMouseLocation()
                    local delta = mPos - wmMouseStart
                    local target = wmObjStart + delta
                    self.watermark.lock = 'Free'
                    self.watermark.position = newUDim2(0, target.X, 0, target.Y)
                    objs.background.Position = self.watermark.position
                else
                    wmDragging = false
                end
            end)

        end
    end

    local smoothedFps = 60;
    local smoothedPing = 40;
    local lasttick = tick();
    utility:Connection(runservice.RenderStepped, function(step)
        if step and step > 0 then
            local rawFps = math.clamp(1 / step, 1, 999);
            smoothedFps = smoothedFps + (rawFps - smoothedFps) * math.clamp(step * 3.5, 0.01, 0.15);
        end
        local ok, rawPing = pcall(function()
            return stats.Network.ServerStatsItem["Data Ping"]:GetValue();
        end)
        if ok and typeof(rawPing) == 'number' and rawPing >= 0 then
            smoothedPing = smoothedPing + (rawPing - smoothedPing) * math.clamp((step or 0.016) * 3.5, 0.01, 0.15);
        end

        library.stats.fps = floor(smoothedFps + 0.5);
        library.stats.ping = floor(smoothedPing + 0.5);
        library.stats.sendkbps = stats.DataSendKbps;
        library.stats.receivekbps = stats.DataReceiveKbps;

        if (tick()-lasttick)*1000 > library.watermark.refreshrate then
            lasttick = tick();
            library.watermark:Update();
        end
    end)

    self.keyIndicator = self.NewIndicator({title = 'Keybinds', pos = newUDim2(0,15,0,325), enabled = true});
    
    self.targetIndicator = self.NewIndicator({title = 'Target Info', pos = newUDim2(0,15,0,350), enabled = false});
    self.targetName = self.targetIndicator:AddValue({key = 'Name     :', value = 'nil'})
    self.targetDisplay = self.targetIndicator:AddValue({key = 'DName    :', value = 'nil'})
    self.targetHealth = self.targetIndicator:AddValue({key = 'Health   :', value = '0'})
    self.targetDistance = self.targetIndicator:AddValue({key = 'Distance :', value = '0m'})
    self.targetTool = self.targetIndicator:AddValue({key = 'Weapon   :', value = 'nil'})

    self:SetTheme(library.theme);
    self:SetOpen(true);
    self.hasInit = true

end

function library:CreateSettingsTab(menu)
    local settingsTab = menu:AddTab('  Settings  ', 999);
    local configSection = settingsTab:AddSection('Config', 1);
    local mainSection = settingsTab:AddSection('Main', 1);

    configSection:AddBox({text = 'Config Name', flag = 'configinput'})
    configSection:AddList({text = 'Config', flag = 'selectedconfig'})

    local function refreshConfigs()
        library.options.selectedconfig:ClearValues();
        for _,v in next, listfiles(self.cheatname..'/'..self.gamename..'/configs') do
            local ext = '.'..v:split('.')[#v:split('.')];
            if ext == self.fileext then
                library.options.selectedconfig:AddValue(v:split('\\')[#v:split('\\')]:sub(1,-#ext-1))
            end
        end
    end

    configSection:AddButton({text = 'Load', confirm = true, callback = function()
        library:LoadConfig(library.flags.selectedconfig);
    end}):AddButton({text = 'Save', confirm = true, callback = function()
        library:SaveConfig(library.flags.selectedconfig);
    end})

    configSection:AddButton({text = 'Create', confirm = true, callback = function()
        if library:GetConfig(library.flags.configinput) then
            library:SendNotification('Config \''..library.flags.configinput..'\' already exists.', 5, c3new(1,0,0));
            return
        end
        writefile(self.cheatname..'/'..self.gamename..'/configs/'..library.flags.configinput.. self.fileext, http:JSONEncode({}));
        refreshConfigs()
    end}):AddButton({text = 'Delete', confirm = true, callback = function()
        if library:GetConfig(library.flags.selectedconfig) then
            delfile(self.cheatname..'/'..self.gamename..'/configs/'..library.flags.selectedconfig.. self.fileext);
            refreshConfigs()
        end
    end})

    refreshConfigs()

    mainSection:AddBind({text = 'Open / Close', flag = 'togglebind', nomouse = true, noindicator = true, bind = Enum.KeyCode.End, callback = function()
        library:SetOpen(not library.open)
    end});

    mainSection:AddButton({text = 'Rejoin Server', confirm = true, callback = function()
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId);
    end})

    mainSection:AddButton({text = 'Rejoin Game', confirm = true, callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId);
    end})

    mainSection:AddButton({text = 'Copy Join Script', callback = function()
        setclipboard(([[game:GetService("TeleportService"):TeleportToPlaceInstance(%s, "%s")]]):format(game.PlaceId, game.JobId))
    end})

    mainSection:AddButton({text = "Unload", confirm = true,
       callback = function(bool)
           if bool then
               library:Unload() 
           else
               library:Unload() 
           end
       end})

    mainSection:AddSeparator({text = 'Indicators'});

    mainSection:AddToggle({text = 'Watermark', flag = 'watermark_enabled', state = true, callback = function(bool)
        if library.watermark and library.watermark.objects and library.watermark.objects.background then
            library.watermark.objects.background.Visible = bool
        end
    end});

    mainSection:AddToggle({text = 'Keybinds Menu', flag = 'keybind_indicator', state = true, callback = function(bool)
        if library.keyIndicator then
            library.keyIndicator:SetEnabled(bool)
        end
    end});



    local themeStrings = {"Custom"};
    for _,v in next, library.themes do
        table.insert(themeStrings, v.name)
    end
    local themeSection = settingsTab:AddSection('Custom Theme', 2);
    local setByPreset = false
themeSection:AddList({text = 'Presets', flag = 'preset_theme', values = themeStrings, callback = function(newTheme)
        if newTheme == "Custom" then return end
        setByPreset = true
        for _,v in next, library.themes do
            if v.name == newTheme then
                for x, d in pairs(library.options) do
                    if v.theme[tostring(x)] ~= nil then
                        d:SetColor(v.theme[tostring(x)])
                    end
                end
                library:SetTheme(v.theme)
                break
            end
        end
        setByPreset = false
    end}):Select('Default');

    for i, v in pairs(library.theme) do
        themeSection:AddColor({text = i, flag = i, color = library.theme[i], callback = function(c3)
            library.theme[i] = c3
            library:SetTheme(library.theme)
            if not setByPreset and not setByConfig then 
                library.options.preset_theme:Select('Custom')
            end
        end});
    end

    return settingsTab;
end

local genv = (getgenv and getgenv()) or _G
genv.library = library
return library
