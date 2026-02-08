
    local function set_readonly_safe(tbl, state)
        if setreadonly then
            pcall(setreadonly, tbl, state)
        end
    end
    
    local function add_to_library(lib, name, func)
        if not lib then return end
        
        local success = pcall(function()
            set_readonly_safe(lib, false)
            rawset(lib, name, func)
            set_readonly_safe(lib, true)
        end)
        
        if not success and lib == string then
            local mt = debug.getmetatable("")
            if mt then
                set_readonly_safe(mt, false)
                pcall(function()
                    local idx = mt.__index
                    if type(idx) == "table" then
                        idx[name] = func
                    end
                end)
                set_readonly_safe(mt, true)
            end
        end
    end
    
    if string then
        add_to_library(string, "trim", function(str)
            return str:match("^%s*(.-)%s*$")
        end)
        
        add_to_library(string, "split", function(str, sep)
            sep = sep or ","
            local result = {}
            local pattern = "([^" .. sep:gsub("([%.%-%+%*%?%[%]%^%$%(%)%%])", "%%%1") .. "]+)"
            for match in str:gmatch(pattern) do
                table.insert(result, match)
            end
            if #result == 0 then
                result = {str}
            end
            return result
        end)
        
        add_to_library(string, "startswith", function(str, prefix)
            return str:sub(1, #prefix) == prefix
        end)
        
        add_to_library(string, "endswith", function(str, suffix)
            return str:sub(-#suffix) == suffix
        end)
        
        add_to_library(string, "contains", function(str, search)
            return str:find(search, 1, true) ~= nil
        end)
        
        add_to_library(string, "count", function(str, pattern)
            local count = 0
            local init = 1
            while true do
                local pos = str:find(pattern, init, true)
                if not pos then break end
                count = count + 1
                init = pos + 1
            end
            return count
        end)
        
        add_to_library(string, "replace", function(str, old, new)
            local result = ""
            local i = 1
            while i <= #str do
                local s = str:find(old, i, true)
                if not s then
                    result = result .. str:sub(i)
                    break
                end
                result = result .. str:sub(i, s - 1) .. new
                i = s + #old
            end
            return result
        end)
        
        add_to_library(string, "padleft", function(str, len, char)
            char = char or " "
            if #str >= len then return str end
            return string.rep(char, len - #str) .. str
        end)
        
        add_to_library(string, "padright", function(str, len, char)
            char = char or " "
            if #str >= len then return str end
            return str .. string.rep(char, len - #str)
        end)
        
        add_to_library(string, "escape", function(str)
            local escapes = {
                ["\n"] = "\\n",
                ["\r"] = "\\r",
                ["\t"] = "\\t",
                ["\\"] = "\\\\",
                ["\""] = "\\\"",
                ["'"] = "\\'",
            }
            local out = {}
            for i = 1, #str do
                local c = str:sub(i, i)
                out[i] = escapes[c] or c
            end
            return table.concat(out)
        end)
        
        add_to_library(string, "unescape", function(str)
            local unescapes = {
                n = "\n",
                r = "\r",
                t = "\t",
                ["\\"] = "\\",
                ["\""] = "\"",
                ["'"] = "'",
            }
            local out = {}
            local i = 1
            while i <= #str do
                if str:sub(i, i) == "\\" and i < #str then
                    local next_char = str:sub(i + 1, i + 1)
                    table.insert(out, unescapes[next_char] or next_char)
                    i = i + 2
                else
                    table.insert(out, str:sub(i, i))
                    i = i + 1
                end
            end
            return table.concat(out)
        end)
    end
    
    if table then
        add_to_library(table, "find", function(tbl, value, init)
            init = init or 1
            for i = init, #tbl do
                if tbl[i] == value then
                    return i
                end
            end
            return nil
        end)
        
        add_to_library(table, "filter", function(tbl, predicate)
            local result = {}
            for i, v in ipairs(tbl) do
                if predicate(v, i) then
                    table.insert(result, v)
                end
            end
            return result
        end)
        
        add_to_library(table, "map", function(tbl, transformer)
            local result = {}
            for i, v in ipairs(tbl) do
                result[i] = transformer(v, i)
            end
            return result
        end)
        
        add_to_library(table, "reduce", function(tbl, reducer, initial)
            local i = 1
            local accumulator = initial
            
            if accumulator == nil then
                if #tbl == 0 then return nil end
                accumulator = tbl[1]
                i = 2
            end
            
            for idx = i, #tbl do
                accumulator = reducer(accumulator, tbl[idx], idx)
            end
            return accumulator
        end)
        
        add_to_library(table, "slice", function(tbl, start_idx, end_idx)
            local n = #tbl
            start_idx = start_idx or 1
            end_idx = end_idx or n
            
            if start_idx < 0 then start_idx = n + start_idx + 1 end
            if end_idx < 0 then end_idx = n + end_idx + 1 end
            
            if start_idx < 1 then start_idx = 1 end
            if end_idx > n then end_idx = n end
            
            local result = {}
            for i = start_idx, end_idx do
                table.insert(result, tbl[i])
            end
            return result
        end)
        
        add_to_library(table, "flat", function(tbl, depth)
            depth = depth or 1
            local result = {}
            
            local function flatten(t, current_depth)
                for _, v in ipairs(t) do
                    if type(v) == "table" and current_depth < depth then
                        flatten(v, current_depth + 1)
                    else
                        table.insert(result, v)
                    end
                end
            end
            
            flatten(tbl, 0)
            return result
        end)
        
        add_to_library(table, "keys", function(tbl)
            local result = {}
            for k in pairs(tbl) do
                table.insert(result, k)
            end
            return result
        end)
        
        add_to_library(table, "values", function(tbl)
            local result = {}
            for _, v in pairs(tbl) do
                table.insert(result, v)
            end
            return result
        end)
        
        add_to_library(table, "merge", function(t1, t2)
            for k, v in pairs(t2) do
                t1[k] = v
            end
            return t1
        end)
        
        add_to_library(table, "reverse", function(tbl)
            local i, j = 1, #tbl
            while i < j do
                tbl[i], tbl[j] = tbl[j], tbl[i]
                i = i + 1
                j = j - 1
            end
            return tbl
        end)
        
        add_to_library(table, "shuffle", function(tbl)
            for i = #tbl, 2, -1 do
                local j = math.random(1, i)
                tbl[i], tbl[j] = tbl[j], tbl[i]
            end
            return tbl
        end)
        
        add_to_library(table, "copy", function(tbl)
            local result = {}
            for k, v in pairs(tbl) do
                result[k] = v
            end
            return result
        end)
        
        add_to_library(table, "deepcopy", function(tbl, seen)
            if type(tbl) ~= "table" then return tbl end
            
            seen = seen or {}
            if seen[tbl] then return seen[tbl] end
            
            local result = {}
            seen[tbl] = result
            
            for k, v in pairs(tbl) do
                result[table.deepcopy(k, seen)] = table.deepcopy(v, seen)
            end
            
            return setmetatable(result, getmetatable(tbl))
        end)
        
        add_to_library(table, "equal", function(t1, t2)
            if t1 == t2 then return true end
            if type(t1) ~= "table" or type(t2) ~= "table" then return false end
            
            for k, v in pairs(t1) do
                if type(v) == "table" then
                    if not table.equal(v, t2[k]) then return false end
                else
                    if v ~= t2[k] then return false end
                end
            end
            
            for k in pairs(t2) do
                if t1[k] == nil then return false end
            end
            
            return true
        end)
    end
    
    if math then
        add_to_library(math, "clamp", function(value, min, max)
            return math.min(math.max(value, min), max)
        end)
        
        add_to_library(math, "lerp", function(a, b, t)
            return a + (b - a) * t
        end)
        
        add_to_library(math, "round", function(value, decimals)
            decimals = decimals or 0
            local mult = 10 ^ decimals
            if value >= 0 then
                return math.floor(value * mult + 0.5) / mult
            else
                return math.ceil(value * mult - 0.5) / mult
            end
        end)
        
        add_to_library(math, "sign", function(value)
            if value > 0 then return 1
            elseif value < 0 then return -1
            else return 0 end
        end)
        
        add_to_library(math, "map", function(value, in_min, in_max, out_min, out_max)
            return (value - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
        end)
        
        add_to_library(math, "isnan", function(value)
            return value ~= value
        end)
        
        add_to_library(math, "isinf", function(value)
            return value == math.huge or value == -math.huge
        end)
        
        add_to_library(math, "average", function(...)
            local args = {...}
            if #args == 0 then return 0 end
            local sum = 0
            for i = 1, #args do
                sum = sum + args[i]
            end
            return sum / #args
        end)
        
        add_to_library(math, "median", function(...)
            local args = {...}
            if #args == 0 then return 0 end
            table.sort(args)
            local mid = math.floor(#args / 2) + 1
            if #args % 2 == 0 then
                return (args[mid - 1] + args[mid]) / 2
            else
                return args[mid]
            end
        end)
    end
    
    if not _G.vector then
        _G.vector = {}
    end
    
    local function get_xyz(v)
        if type(v) ~= "table" then
            return 0, 0, 0
        end
        return v.x or v[1] or 0,
               v.y or v[2] or 0,
               v.z or v[3] or 0
    end
    
    _G.vector.create = function(x, y, z)
        return {x = x, y = y, z = z}
    end
    
    _G.vector.magnitude = function(v)
        local x, y, z = get_xyz(v)
        return math.sqrt(x * x + y * y + z * z)
    end
    
    _G.vector.normalize = function(v)
        local x, y, z = get_xyz(v)
        local mag = math.sqrt(x * x + y * y + z * z)
        if mag > 0 then
            return {x = x / mag, y = y / mag, z = z / mag}
        end
        return {x = 0, y = 0, z = 0}
    end
    
    _G.vector.dot = function(v1, v2)
        local x1, y1, z1 = get_xyz(v1)
        local x2, y2, z2 = get_xyz(v2)
        return x1 * x2 + y1 * y2 + z1 * z2
    end
    
    _G.vector.cross = function(v1, v2)
        local x1, y1, z1 = get_xyz(v1)
        local x2, y2, z2 = get_xyz(v2)
        return {
            x = y1 * z2 - z1 * y2,
            y = z1 * x2 - x1 * z2,
            z = x1 * y2 - y1 * x2
        }
    end
    
    _G.vector.lerp = function(v1, v2, t)
        local x1, y1, z1 = get_xyz(v1)
        local x2, y2, z2 = get_xyz(v2)
        return {
            x = x1 + (x2 - x1) * t,
            y = y1 + (y2 - y1) * t,
            z = z1 + (z2 - z1) * t
        }
    end
    
    _G.vector.angle = function(v1, v2)
        local dot = _G.vector.dot(v1, v2)
        local mag1 = _G.vector.magnitude(v1)
        local mag2 = _G.vector.magnitude(v2)
        if mag1 > 0 and mag2 > 0 then
            return math.acos(math.clamp(dot / (mag1 * mag2), -1, 1))
        end
        return 0
    end
    
    _G.vector.distance = function(v1, v2)
        local x1, y1, z1 = get_xyz(v1)
        local x2, y2, z2 = get_xyz(v2)
        local dx, dy, dz = x2 - x1, y2 - y1, z2 - z1
        return math.sqrt(dx * dx + dy * dy + dz * dz)
    end
    
    _G.vector.add = function(v1, v2)
        local x1, y1, z1 = get_xyz(v1)
        local x2, y2, z2 = get_xyz(v2)
        return {x = x1 + x2, y = y1 + y2, z = z1 + z2}
    end
    
    _G.vector.subtract = function(v1, v2)
        local x1, y1, z1 = get_xyz(v1)
        local x2, y2, z2 = get_xyz(v2)
        return {x = x1 - x2, y = y1 - y2, z = z1 - z2}
    end
    
    _G.vector.multiply = function(v, scalar)
        local x, y, z = get_xyz(v)
        return {x = x * scalar, y = y * scalar, z = z * scalar}
    end
    
    _G.vector.divide = function(v, scalar)
        if scalar == 0 then return {x = 0, y = 0, z = 0} end
        local x, y, z = get_xyz(v)
        return {x = x / scalar, y = y / scalar, z = z / scalar}
    end
    
    if bit32 then
        local MASK = 0xFFFFFFFF
        
        add_to_library(bit32, "rotl", function(x, disp)
            disp = disp % 32
            x = bit32.band(x, MASK)
            return bit32.bor(
                bit32.band(bit32.lshift(x, disp), MASK),
                bit32.rshift(x, 32 - disp)
            )
        end)
        
        add_to_library(bit32, "rotr", function(x, disp)
            disp = disp % 32
            x = bit32.band(x, MASK)
            return bit32.bor(
                bit32.rshift(x, disp),
                bit32.band(bit32.lshift(x, 32 - disp), MASK)
            )
        end)
        
        add_to_library(bit32, "countbits", function(x)
            local count = 0
            while x > 0 do
                count = count + bit32.band(x, 1)
                x = bit32.rshift(x, 1)
            end
            return count
        end)
    end
    
    if utf8 and bit32 then
        add_to_library(utf8, "validate", function(str)
            local i = 1
            local len = #str
            while i <= len do
                local c = str:byte(i)
                local bytes = 0
                
                if c < 0x80 then 
                    bytes = 1
                elseif bit32.band(c, 0xE0) == 0xC0 then 
                    bytes = 2
                elseif bit32.band(c, 0xF0) == 0xE0 then 
                    bytes = 3
                elseif bit32.band(c, 0xF8) == 0xF0 then 
                    bytes = 4
                else 
                    return false, i 
                end
                
                for j = 2, bytes do
                    if i + j - 1 > len then return false, i end
                    local b = str:byte(i + j - 1)
                    if bit32.band(b, 0xC0) ~= 0x80 then
                        return false, i
                    end
                end
                
                i = i + bytes
            end
            return true
        end)
        
        if utf8.codes and utf8.char then
            add_to_library(utf8, "reverse", function(str)
                local chars = {}
                for p, c in utf8.codes(str) do
                    table.insert(chars, 1, utf8.char(c))
                end
                return table.concat(chars)
            end)
        end
    end
    
    if os then
        add_to_library(os, "timems", function()
            return os.clock() * 1000
        end)
        
        if tick then
            add_to_library(os, "clockms", function()
                return tick() * 1000
            end)
        end
    end

local DrawingCache = {}
local DrawingObjects = {}

local Fonts = {
    [0] = Enum.Font.Arial,
    [1] = Enum.Font.BuilderSans,
    [2] = Enum.Font.Gotham,
    [3] = Enum.Font.RobotoMono
}

local function gethui()
    local success, result = pcall(function()
        return game:GetService("CoreGui")
    end)
    return success and result or game:GetService("Players").LocalPlayer:FindFirstChildOfClass("PlayerGui")
end
getgenv().gethui = gethui

local UI = Instance.new("ScreenGui")
UI.Name = "DrawingLib"
UI.DisplayOrder = 999999
UI.IgnoreGuiInset = true
UI.ResetOnSpawn = false
UI.Parent = gethui()

local Drawing = {
    Fonts = {
        UI = 0,
        System = 1,
        Plex = 2,
        Monospace = 3
    }
}

Drawing.new = function(drawingType)
    if type(drawingType) ~= "string" then
        error("Drawing.new: argument must be a string, got " .. type(drawingType), 2)
    end

    local validTypes = {
        Line = true,
        Square = true,
        Rectangle = true,
        Circle = true,
        Text = true,
        Image = true,
        Triangle = true,
        Quad = true
    }
    
    if not validTypes[drawingType] then
        error("Drawing.new: invalid drawing type '" .. drawingType .. "'", 2)
    end

    local drawingObj = Instance.new("Frame")
    drawingObj.BackgroundTransparency = 1
    drawingObj.BorderSizePixel = 0
    drawingObj.Size = UDim2.fromOffset(0, 0)
    drawingObj.Position = UDim2.fromOffset(0, 0)
    drawingObj.Parent = UI
    
    local properties = {
        Visible = true,
        Color = Color3.new(1, 1, 1),
        Transparency = 1,
        ZIndex = 1
    }
    
    local self = newproxy(true)
    local mt = getmetatable(self)
    
    local removed = false
    
    mt.__index = function(_, key)
        if key == "__OBJECT_EXISTS" then
            return not removed
        end
        return properties[key]
    end
    
    mt.__newindex = function(_, key, value)
        if removed then return end
        
        if key == "__OBJECT_EXISTS" then
            return
        end
        
        properties[key] = value
        
        if key == "Visible" then
            drawingObj.Visible = value
        elseif key == "Color" then
            drawingObj.BackgroundColor3 = value
        elseif key == "Transparency" then
            drawingObj.BackgroundTransparency = 1 - value
        elseif key == "ZIndex" then
            drawingObj.ZIndex = value
        end
    end
    
    mt.__tostring = function()
        return "Drawing"
    end
    
    mt.__metatable = "The metatable is locked"
    
    properties.Remove = function()
        if removed then return end
        
        removed = true
        
        if drawingObj and drawingObj.Parent then
            drawingObj:Destroy()
        end
        
        for i, obj in ipairs(DrawingCache) do
            if obj.proxy == self then
                table.remove(DrawingCache, i)
                break
            end
        end
        
        DrawingObjects[self] = nil
    end
    
    properties.Destroy = properties.Remove
    
    table.insert(DrawingCache, {proxy = self, instance = drawingObj})
    DrawingObjects[self] = true
    
    if drawingType == "Line" then
        drawingObj.AnchorPoint = Vector2.new(0.5, 0.5)
        
        properties.From = Vector2.zero
        properties.To = Vector2.zero
        properties.Thickness = 1
        
        local updateLine = function()
            if removed then return end
            
            local from = properties.From
            local to = properties.To
            local dx = to.X - from.X
            local dy = to.Y - from.Y
            local length = math.sqrt(dx * dx + dy * dy)
            
            drawingObj.Size = UDim2.fromOffset(length, properties.Thickness)
            drawingObj.Position = UDim2.fromOffset((from.X + to.X) / 2, (from.Y + to.Y) / 2)
            drawingObj.Rotation = math.deg(math.atan2(dy, dx))
            drawingObj.BackgroundTransparency = 1 - properties.Transparency
            drawingObj.BackgroundColor3 = properties.Color
        end
        
        local oldNewindex = mt.__newindex
        mt.__newindex = function(t, k, v)
            oldNewindex(t, k, v)
            if k == "From" or k == "To" or k == "Thickness" then
                updateLine()
            end
        end
        
    elseif drawingType == "Square" or drawingType == "Rectangle" then
        local stroke = Instance.new("UIStroke")
        stroke.Parent = drawingObj
        stroke.Thickness = 1
        stroke.Color = Color3.new(1, 1, 1)
        
        properties.Size = Vector2.zero
        properties.Position = Vector2.zero
        properties.Filled = false
        properties.Thickness = 1
        
        local updateSquare = function()
            if removed then return end
            
            drawingObj.Size = UDim2.fromOffset(properties.Size.X, properties.Size.Y)
            drawingObj.Position = UDim2.fromOffset(properties.Position.X, properties.Position.Y)
            
            if properties.Filled then
                drawingObj.BackgroundTransparency = 1 - properties.Transparency
                drawingObj.BackgroundColor3 = properties.Color
                stroke.Enabled = false
            else
                drawingObj.BackgroundTransparency = 1
                stroke.Enabled = true
                stroke.Color = properties.Color
                stroke.Thickness = properties.Thickness
                stroke.Transparency = 1 - properties.Transparency
            end
        end
        
        local oldNewindex = mt.__newindex
        mt.__newindex = function(t, k, v)
            oldNewindex(t, k, v)
            if k == "Size" or k == "Position" or k == "Filled" or k == "Thickness" or k == "Color" or k == "Transparency" then
                updateSquare()
            end
        end
        
    elseif drawingType == "Circle" then
        local stroke = Instance.new("UIStroke")
        stroke.Parent = drawingObj
        stroke.Thickness = 1
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = drawingObj
        
        properties.Radius = 50
        properties.Position = Vector2.zero
        properties.Filled = false
        properties.Thickness = 1
        properties.NumSides = 64
        
        local updateCircle = function()
            if removed then return end
            
            local diameter = properties.Radius * 2
            drawingObj.Size = UDim2.fromOffset(diameter, diameter)
            drawingObj.Position = UDim2.fromOffset(properties.Position.X - properties.Radius, properties.Position.Y - properties.Radius)
            
            if properties.Filled then
                drawingObj.BackgroundTransparency = 1 - properties.Transparency
                drawingObj.BackgroundColor3 = properties.Color
                stroke.Enabled = false
            else
                drawingObj.BackgroundTransparency = 1
                stroke.Enabled = true
                stroke.Color = properties.Color
                stroke.Thickness = properties.Thickness
                stroke.Transparency = 1 - properties.Transparency
            end
        end
        
        local oldNewindex = mt.__newindex
        mt.__newindex = function(t, k, v)
            oldNewindex(t, k, v)
            if k == "Radius" or k == "Position" or k == "Filled" or k == "Thickness" or k == "Color" or k == "Transparency" then
                updateCircle()
            end
        end
        
    elseif drawingType == "Triangle" then
        drawingObj:Destroy()
        
        drawingObj = Instance.new("Frame")
        drawingObj.BackgroundTransparency = 1
        drawingObj.BorderSizePixel = 0
        drawingObj.Size = UDim2.fromOffset(100, 100)
        drawingObj.Parent = UI
        
        local point1Frame = Instance.new("Frame")
        point1Frame.AnchorPoint = Vector2.new(0.5, 0.5)
        point1Frame.BackgroundColor3 = Color3.new(1, 1, 1)
        point1Frame.BorderSizePixel = 0
        point1Frame.Parent = drawingObj
        
        local point2Frame = Instance.new("Frame")
        point2Frame.AnchorPoint = Vector2.new(0.5, 0.5)
        point2Frame.BackgroundColor3 = Color3.new(1, 1, 1)
        point2Frame.BorderSizePixel = 0
        point2Frame.Parent = drawingObj
        
        local point3Frame = Instance.new("Frame")
        point3Frame.AnchorPoint = Vector2.new(0.5, 0.5)
        point3Frame.BackgroundColor3 = Color3.new(1, 1, 1)
        point3Frame.BorderSizePixel = 0
        point3Frame.Parent = drawingObj
        
        properties.PointA = Vector2.zero
        properties.PointB = Vector2.new(50, 100)
        properties.PointC = Vector2.new(100, 0)
        properties.Filled = false
        properties.Thickness = 1
        
        local updateTriangle = function()
            if removed then return end
            
            local pA = properties.PointA
            local pB = properties.PointB
            local pC = properties.PointC
            
            local minX = math.min(pA.X, pB.X, pC.X)
            local minY = math.min(pA.Y, pB.Y, pC.Y)
            local maxX = math.max(pA.X, pB.X, pC.X)
            local maxY = math.max(pA.Y, pB.Y, pC.Y)
            
            drawingObj.Position = UDim2.fromOffset(minX, minY)
            drawingObj.Size = UDim2.fromOffset(maxX - minX, maxY - minY)
            
            local function drawLine(frame, p1, p2)
                local dx = p2.X - p1.X
                local dy = p2.Y - p1.Y
                local length = math.sqrt(dx * dx + dy * dy)
                
                frame.Size = UDim2.fromOffset(length, properties.Thickness)
                frame.Position = UDim2.fromOffset((p1.X + p2.X) / 2 - minX, (p1.Y + p2.Y) / 2 - minY)
                frame.Rotation = math.deg(math.atan2(dy, dx))
                frame.BackgroundColor3 = properties.Color
                frame.BackgroundTransparency = 1 - properties.Transparency
            end
            
            if properties.Filled then
                point1Frame.Visible = false
                point2Frame.Visible = false
                point3Frame.Visible = false
                drawingObj.BackgroundColor3 = properties.Color
                drawingObj.BackgroundTransparency = 1 - properties.Transparency
            else
                point1Frame.Visible = true
                point2Frame.Visible = true
                point3Frame.Visible = true
                drawingObj.BackgroundTransparency = 1
                
                drawLine(point1Frame, pA, pB)
                drawLine(point2Frame, pB, pC)
                drawLine(point3Frame, pC, pA)
            end
        end
        
        local oldNewindex = mt.__newindex
        mt.__newindex = function(t, k, v)
            oldNewindex(t, k, v)
            if k == "PointA" or k == "PointB" or k == "PointC" or k == "Filled" or k == "Thickness" or k == "Color" or k == "Transparency" then
                updateTriangle()
            end
        end
        
    elseif drawingType == "Quad" then
        drawingObj:Destroy()
        
        drawingObj = Instance.new("Frame")
        drawingObj.BackgroundTransparency = 1
        drawingObj.BorderSizePixel = 0
        drawingObj.Size = UDim2.fromOffset(100, 100)
        drawingObj.Parent = UI
        
        local line1 = Instance.new("Frame")
        line1.AnchorPoint = Vector2.new(0.5, 0.5)
        line1.BackgroundColor3 = Color3.new(1, 1, 1)
        line1.BorderSizePixel = 0
        line1.Parent = drawingObj
        
        local line2 = Instance.new("Frame")
        line2.AnchorPoint = Vector2.new(0.5, 0.5)
        line2.BackgroundColor3 = Color3.new(1, 1, 1)
        line2.BorderSizePixel = 0
        line2.Parent = drawingObj
        
        local line3 = Instance.new("Frame")
        line3.AnchorPoint = Vector2.new(0.5, 0.5)
        line3.BackgroundColor3 = Color3.new(1, 1, 1)
        line3.BorderSizePixel = 0
        line3.Parent = drawingObj
        
        local line4 = Instance.new("Frame")
        line4.AnchorPoint = Vector2.new(0.5, 0.5)
        line4.BackgroundColor3 = Color3.new(1, 1, 1)
        line4.BorderSizePixel = 0
        line4.Parent = drawingObj
        
        properties.PointA = Vector2.zero
        properties.PointB = Vector2.new(100, 0)
        properties.PointC = Vector2.new(100, 100)
        properties.PointD = Vector2.new(0, 100)
        properties.Filled = false
        properties.Thickness = 1
        
        local updateQuad = function()
            if removed then return end
            
            local pA = properties.PointA
            local pB = properties.PointB
            local pC = properties.PointC
            local pD = properties.PointD
            
            local minX = math.min(pA.X, pB.X, pC.X, pD.X)
            local minY = math.min(pA.Y, pB.Y, pC.Y, pD.Y)
            local maxX = math.max(pA.X, pB.X, pC.X, pD.X)
            local maxY = math.max(pA.Y, pB.Y, pC.Y, pD.Y)
            
            drawingObj.Position = UDim2.fromOffset(minX, minY)
            drawingObj.Size = UDim2.fromOffset(maxX - minX, maxY - minY)
            
            local function drawLine(frame, p1, p2)
                local dx = p2.X - p1.X
                local dy = p2.Y - p1.Y
                local length = math.sqrt(dx * dx + dy * dy)
                
                frame.Size = UDim2.fromOffset(length, properties.Thickness)
                frame.Position = UDim2.fromOffset((p1.X + p2.X) / 2 - minX, (p1.Y + p2.Y) / 2 - minY)
                frame.Rotation = math.deg(math.atan2(dy, dx))
                frame.BackgroundColor3 = properties.Color
                frame.BackgroundTransparency = 1 - properties.Transparency
            end
            
            if properties.Filled then
                line1.Visible = false
                line2.Visible = false
                line3.Visible = false
                line4.Visible = false
                drawingObj.BackgroundColor3 = properties.Color
                drawingObj.BackgroundTransparency = 1 - properties.Transparency
            else
                line1.Visible = true
                line2.Visible = true
                line3.Visible = true
                line4.Visible = true
                drawingObj.BackgroundTransparency = 1
                
                drawLine(line1, pA, pB)
                drawLine(line2, pB, pC)
                drawLine(line3, pC, pD)
                drawLine(line4, pD, pA)
            end
        end
        
        local oldNewindex = mt.__newindex
        mt.__newindex = function(t, k, v)
            oldNewindex(t, k, v)
            if k == "PointA" or k == "PointB" or k == "PointC" or k == "PointD" or k == "Filled" or k == "Thickness" or k == "Color" or k == "Transparency" then
                updateQuad()
            end
        end
        
    elseif drawingType == "Text" then
        drawingObj:Destroy()
        
        drawingObj = Instance.new("TextLabel")
        drawingObj.BackgroundTransparency = 1
        drawingObj.BorderSizePixel = 0
        drawingObj.TextColor3 = Color3.new(1, 1, 1)
        drawingObj.TextSize = 13
        drawingObj.Font = Enum.Font.Code
        drawingObj.Text = ""
        drawingObj.AutomaticSize = Enum.AutomaticSize.XY
        drawingObj.Parent = UI
        
        properties.Text = ""
        properties.Size = 13
        properties.Center = false
        properties.Outline = false
        properties.OutlineColor = Color3.new(0, 0, 0)
        properties.Position = Vector2.zero
        properties.Font = 2
        properties.TextBounds = Vector2.zero
        
        local updateText = function()
            if removed then return end
            
            drawingObj.Text = tostring(properties.Text)
            drawingObj.TextSize = properties.Size
            drawingObj.Position = UDim2.fromOffset(properties.Position.X, properties.Position.Y)
            drawingObj.TextColor3 = properties.Color
            drawingObj.TextTransparency = 1 - properties.Transparency
            drawingObj.Font = Fonts[properties.Font] or Enum.Font.Code
            
            if properties.Center then
                drawingObj.TextXAlignment = Enum.TextXAlignment.Center
                drawingObj.TextYAlignment = Enum.TextYAlignment.Center
            else
                drawingObj.TextXAlignment = Enum.TextXAlignment.Left
                drawingObj.TextYAlignment = Enum.TextYAlignment.Top
            end
            
            if properties.Outline then
                drawingObj.TextStrokeTransparency = 0
                drawingObj.TextStrokeColor3 = properties.OutlineColor
            else
                drawingObj.TextStrokeTransparency = 1
            end
            
            game:GetService("RunService").RenderStepped:Wait()
            properties.TextBounds = drawingObj.TextBounds
        end
        
        local oldNewindex = mt.__newindex
        mt.__newindex = function(t, k, v)
            oldNewindex(t, k, v)
            if k ~= "TextBounds" then
                task.spawn(updateText)
            end
        end
        
    elseif drawingType == "Image" then
        drawingObj:Destroy()
        
        drawingObj = Instance.new("ImageLabel")
        drawingObj.BackgroundTransparency = 1
        drawingObj.BorderSizePixel = 0
        drawingObj.Parent = UI
        
        properties.Data = ""
        properties.Size = Vector2.zero
        properties.Position = Vector2.zero
        properties.Rounding = 0
        
        local updateImage = function()
            if removed then return end
            
            drawingObj.Image = properties.Data
            drawingObj.Size = UDim2.fromOffset(properties.Size.X, properties.Size.Y)
            drawingObj.Position = UDim2.fromOffset(properties.Position.X, properties.Position.Y)
            drawingObj.ImageTransparency = 1 - properties.Transparency
            drawingObj.ImageColor3 = properties.Color
        end
        
        local oldNewindex = mt.__newindex
        mt.__newindex = function(t, k, v)
            oldNewindex(t, k, v)
            if k == "Data" or k == "Size" or k == "Position" or k == "Transparency" or k == "Color" then
                updateImage()
            end
        end
    end
    
    return self
end

getgenv().Drawing = Drawing

getgenv().isrenderobj = function(obj)
    if type(obj) ~= "userdata" then
        return false
    end
    
    local success, exists = pcall(function()
        return obj.__OBJECT_EXISTS
    end)
    
    return success and exists == true
end

getgenv().cleardrawcache = function()
    for i = #DrawingCache, 1, -1 do
        local data = DrawingCache[i]
        if data and data.proxy then
            pcall(function()
                data.proxy:Remove()
            end)
        end
    end
    
    DrawingCache = {}
    DrawingObjects = {}
end

getgenv().getrenderproperty = function(obj, prop)
    if not getgenv().isrenderobj(obj) then
        return nil
    end
    return obj[prop]
end

getgenv().setrenderproperty = function(obj, prop, value)
    if not getgenv().isrenderobj(obj) then
        return
    end
    obj[prop] = value
end

do
    local function set_readonly_safe(tbl, state)
        if setreadonly then
            pcall(setreadonly, tbl, state)
        end
    end
    
    local function add_to_library(lib, name, func)
        if not lib then return end
        
        local success = pcall(function()
            set_readonly_safe(lib, false)
            rawset(lib, name, func)
            set_readonly_safe(lib, true)
        end)
        
        if not success and lib == string then
            local mt = debug.getmetatable("")
            if mt then
                set_readonly_safe(mt, false)
                pcall(function()
                    local idx = mt.__index
                    if type(idx) == "table" then
                        idx[name] = func
                    end
                end)
                set_readonly_safe(mt, true)
            end
        end
    end
    
    if string then
        add_to_library(string, "trim", function(str)
            return str:match("^%s*(.-)%s*$")
        end)
        
        add_to_library(string, "split", function(str, sep)
            sep = sep or ","
            local result = {}
            local pattern = "([^" .. sep:gsub("([%.%-%+%*%?%[%]%^%$%(%)%%])", "%%%1") .. "]+)"
            for match in str:gmatch(pattern) do
                table.insert(result, match)
            end
            if #result == 0 then
                result = {str}
            end
            return result
        end)
        
        add_to_library(string, "startswith", function(str, prefix)
            return str:sub(1, #prefix) == prefix
        end)
        
        add_to_library(string, "endswith", function(str, suffix)
            return str:sub(-#suffix) == suffix
        end)
        
        add_to_library(string, "contains", function(str, search)
            return str:find(search, 1, true) ~= nil
        end)
        
        add_to_library(string, "count", function(str, pattern)
            local count = 0
            local init = 1
            while true do
                local pos = str:find(pattern, init, true)
                if not pos then break end
                count = count + 1
                init = pos + 1
            end
            return count
        end)
        
        add_to_library(string, "replace", function(str, old, new)
            local result = ""
            local i = 1
            while i <= #str do
                local s = str:find(old, i, true)
                if not s then
                    result = result .. str:sub(i)
                    break
                end
                result = result .. str:sub(i, s - 1) .. new
                i = s + #old
            end
            return result
        end)
        
        add_to_library(string, "padleft", function(str, len, char)
            char = char or " "
            if #str >= len then return str end
            return string.rep(char, len - #str) .. str
        end)
        
        add_to_library(string, "padright", function(str, len, char)
            char = char or " "
            if #str >= len then return str end
            return str .. string.rep(char, len - #str)
        end)
        
        add_to_library(string, "escape", function(str)
            local escapes = {
                ["\n"] = "\\n",
                ["\r"] = "\\r",
                ["\t"] = "\\t",
                ["\\"] = "\\\\",
                ["\""] = "\\\"",
                ["'"] = "\\'",
            }
            local out = {}
            for i = 1, #str do
                local c = str:sub(i, i)
                out[i] = escapes[c] or c
            end
            return table.concat(out)
        end)
        
        add_to_library(string, "unescape", function(str)
            local unescapes = {
                n = "\n",
                r = "\r",
                t = "\t",
                ["\\"] = "\\",
                ["\""] = "\"",
                ["'"] = "'",
            }
            local out = {}
            local i = 1
            while i <= #str do
                if str:sub(i, i) == "\\" and i < #str then
                    local next_char = str:sub(i + 1, i + 1)
                    table.insert(out, unescapes[next_char] or next_char)
                    i = i + 2
                else
                    table.insert(out, str:sub(i, i))
                    i = i + 1
                end
            end
            return table.concat(out)
        end)
    end
    
    if table then
        add_to_library(table, "find", function(tbl, value, init)
            init = init or 1
            for i = init, #tbl do
                if tbl[i] == value then
                    return i
                end
            end
            return nil
        end)
        
        add_to_library(table, "filter", function(tbl, predicate)
            local result = {}
            for i, v in ipairs(tbl) do
                if predicate(v, i) then
                    table.insert(result, v)
                end
            end
            return result
        end)
        
        add_to_library(table, "map", function(tbl, transformer)
            local result = {}
            for i, v in ipairs(tbl) do
                result[i] = transformer(v, i)
            end
            return result
        end)
        
        add_to_library(table, "reduce", function(tbl, reducer, initial)
            local i = 1
            local accumulator = initial
            
            if accumulator == nil then
                if #tbl == 0 then return nil end
                accumulator = tbl[1]
                i = 2
            end
            
            for idx = i, #tbl do
                accumulator = reducer(accumulator, tbl[idx], idx)
            end
            return accumulator
        end)
        
        add_to_library(table, "slice", function(tbl, start_idx, end_idx)
            local n = #tbl
            start_idx = start_idx or 1
            end_idx = end_idx or n
            
            if start_idx < 0 then start_idx = n + start_idx + 1 end
            if end_idx < 0 then end_idx = n + end_idx + 1 end
            
            if start_idx < 1 then start_idx = 1 end
            if end_idx > n then end_idx = n end
            
            local result = {}
            for i = start_idx, end_idx do
                table.insert(result, tbl[i])
            end
            return result
        end)
        
        add_to_library(table, "flat", function(tbl, depth)
            depth = depth or 1
            local result = {}
            
            local function flatten(t, current_depth)
                for _, v in ipairs(t) do
                    if type(v) == "table" and current_depth < depth then
                        flatten(v, current_depth + 1)
                    else
                        table.insert(result, v)
                    end
                end
            end
            
            flatten(tbl, 0)
            return result
        end)
        
        add_to_library(table, "keys", function(tbl)
            local result = {}
            for k in pairs(tbl) do
                table.insert(result, k)
            end
            return result
        end)
        
        add_to_library(table, "values", function(tbl)
            local result = {}
            for _, v in pairs(tbl) do
                table.insert(result, v)
            end
            return result
        end)
        
        add_to_library(table, "merge", function(t1, t2)
            for k, v in pairs(t2) do
                t1[k] = v
            end
            return t1
        end)
        
        add_to_library(table, "reverse", function(tbl)
            local i, j = 1, #tbl
            while i < j do
                tbl[i], tbl[j] = tbl[j], tbl[i]
                i = i + 1
                j = j - 1
            end
            return tbl
        end)
        
        add_to_library(table, "shuffle", function(tbl)
            for i = #tbl, 2, -1 do
                local j = math.random(1, i)
                tbl[i], tbl[j] = tbl[j], tbl[i]
            end
            return tbl
        end)
        
        add_to_library(table, "copy", function(tbl)
            local result = {}
            for k, v in pairs(tbl) do
                result[k] = v
            end
            return result
        end)
        
        add_to_library(table, "deepcopy", function(tbl, seen)
            if type(tbl) ~= "table" then return tbl end
            
            seen = seen or {}
            if seen[tbl] then return seen[tbl] end
            
            local result = {}
            seen[tbl] = result
            
            for k, v in pairs(tbl) do
                result[table.deepcopy(k, seen)] = table.deepcopy(v, seen)
            end
            
            return setmetatable(result, getmetatable(tbl))
        end)
        
        add_to_library(table, "equal", function(t1, t2)
            if t1 == t2 then return true end
            if type(t1) ~= "table" or type(t2) ~= "table" then return false end
            
            for k, v in pairs(t1) do
                if type(v) == "table" then
                    if not table.equal(v, t2[k]) then return false end
                else
                    if v ~= t2[k] then return false end
                end
            end
            
            for k in pairs(t2) do
                if t1[k] == nil then return false end
            end
            
            return true
        end)
    end
    
    if math then
        add_to_library(math, "clamp", function(value, min, max)
            return math.min(math.max(value, min), max)
        end)
        
        add_to_library(math, "lerp", function(a, b, t)
            return a + (b - a) * t
        end)
        
        add_to_library(math, "round", function(value, decimals)
            decimals = decimals or 0
            local mult = 10 ^ decimals
            if value >= 0 then
                return math.floor(value * mult + 0.5) / mult
            else
                return math.ceil(value * mult - 0.5) / mult
            end
        end)
        
        add_to_library(math, "sign", function(value)
            if value > 0 then return 1
            elseif value < 0 then return -1
            else return 0 end
        end)
        
        add_to_library(math, "map", function(value, in_min, in_max, out_min, out_max)
            return (value - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
        end)
        
        add_to_library(math, "isnan", function(value)
            return value ~= value
        end)
        
        add_to_library(math, "isinf", function(value)
            return value == math.huge or value == -math.huge
        end)
        
        add_to_library(math, "average", function(...)
            local args = {...}
            if #args == 0 then return 0 end
            local sum = 0
            for i = 1, #args do
                sum = sum + args[i]
            end
            return sum / #args
        end)
        
        add_to_library(math, "median", function(...)
            local args = {...}
            if #args == 0 then return 0 end
            table.sort(args)
            local mid = math.floor(#args / 2) + 1
            if #args % 2 == 0 then
                return (args[mid - 1] + args[mid]) / 2
            else
                return args[mid]
            end
        end)
    end
    
    if not _G.vector then
        _G.vector = {}
    end
    
    local function get_xyz(v)
        if type(v) ~= "table" then
            return 0, 0, 0
        end
        return v.x or v[1] or 0,
               v.y or v[2] or 0,
               v.z or v[3] or 0
    end
    
    _G.vector.create = function(x, y, z)
        return {x = x, y = y, z = z}
    end
    
    _G.vector.magnitude = function(v)
        local x, y, z = get_xyz(v)
        return math.sqrt(x * x + y * y + z * z)
    end
    
    _G.vector.normalize = function(v)
        local x, y, z = get_xyz(v)
        local mag = math.sqrt(x * x + y * y + z * z)
        if mag > 0 then
            return {x = x / mag, y = y / mag, z = z / mag}
        end
        return {x = 0, y = 0, z = 0}
    end
    
    _G.vector.dot = function(v1, v2)
        local x1, y1, z1 = get_xyz(v1)
        local x2, y2, z2 = get_xyz(v2)
        return x1 * x2 + y1 * y2 + z1 * z2
    end
    
    _G.vector.cross = function(v1, v2)
        local x1, y1, z1 = get_xyz(v1)
        local x2, y2, z2 = get_xyz(v2)
        return {
            x = y1 * z2 - z1 * y2,
            y = z1 * x2 - x1 * z2,
            z = x1 * y2 - y1 * x2
        }
    end
    
    _G.vector.lerp = function(v1, v2, t)
        local x1, y1, z1 = get_xyz(v1)
        local x2, y2, z2 = get_xyz(v2)
        return {
            x = x1 + (x2 - x1) * t,
            y = y1 + (y2 - y1) * t,
            z = z1 + (z2 - z1) * t
        }
    end
    
    _G.vector.angle = function(v1, v2)
        local dot = _G.vector.dot(v1, v2)
        local mag1 = _G.vector.magnitude(v1)
        local mag2 = _G.vector.magnitude(v2)
        if mag1 > 0 and mag2 > 0 then
            return math.acos(math.clamp(dot / (mag1 * mag2), -1, 1))
        end
        return 0
    end
    
    _G.vector.distance = function(v1, v2)
        local x1, y1, z1 = get_xyz(v1)
        local x2, y2, z2 = get_xyz(v2)
        local dx, dy, dz = x2 - x1, y2 - y1, z2 - z1
        return math.sqrt(dx * dx + dy * dy + dz * dz)
    end
    
    _G.vector.add = function(v1, v2)
        local x1, y1, z1 = get_xyz(v1)
        local x2, y2, z2 = get_xyz(v2)
        return {x = x1 + x2, y = y1 + y2, z = z1 + z2}
    end
    
    _G.vector.subtract = function(v1, v2)
        local x1, y1, z1 = get_xyz(v1)
        local x2, y2, z2 = get_xyz(v2)
        return {x = x1 - x2, y = y1 - y2, z = z1 - z2}
    end
    
    _G.vector.multiply = function(v, scalar)
        local x, y, z = get_xyz(v)
        return {x = x * scalar, y = y * scalar, z = z * scalar}
    end
    
    _G.vector.divide = function(v, scalar)
        if scalar == 0 then return {x = 0, y = 0, z = 0} end
        local x, y, z = get_xyz(v)
        return {x = x / scalar, y = y / scalar, z = z / scalar}
    end
    
    if bit32 then
        local MASK = 0xFFFFFFFF
        
        add_to_library(bit32, "rotl", function(x, disp)
            disp = disp % 32
            x = bit32.band(x, MASK)
            return bit32.bor(
                bit32.band(bit32.lshift(x, disp), MASK),
                bit32.rshift(x, 32 - disp)
            )
        end)
        
        add_to_library(bit32, "rotr", function(x, disp)
            disp = disp % 32
            x = bit32.band(x, MASK)
            return bit32.bor(
                bit32.rshift(x, disp),
                bit32.band(bit32.lshift(x, 32 - disp), MASK)
            )
        end)
        
        add_to_library(bit32, "countbits", function(x)
            local count = 0
            while x > 0 do
                count = count + bit32.band(x, 1)
                x = bit32.rshift(x, 1)
            end
            return count
        end)
    end
    
    if utf8 and bit32 then
        add_to_library(utf8, "validate", function(str)
            local i = 1
            local len = #str
            while i <= len do
                local c = str:byte(i)
                local bytes = 0
                
                if c < 0x80 then 
                    bytes = 1
                elseif bit32.band(c, 0xE0) == 0xC0 then 
                    bytes = 2
                elseif bit32.band(c, 0xF0) == 0xE0 then 
                    bytes = 3
                elseif bit32.band(c, 0xF8) == 0xF0 then 
                    bytes = 4
                else 
                    return false, i 
                end
                
                for j = 2, bytes do
                    if i + j - 1 > len then return false, i end
                    local b = str:byte(i + j - 1)
                    if bit32.band(b, 0xC0) ~= 0x80 then
                        return false, i
                    end
                end
                
                i = i + bytes
            end
            return true
        end)
        
        if utf8.codes and utf8.char then
            add_to_library(utf8, "reverse", function(str)
                local chars = {}
                for p, c in utf8.codes(str) do
                    table.insert(chars, 1, utf8.char(c))
                end
                return table.concat(chars)
            end)
        end
    end
    
    if os then
        add_to_library(os, "timems", function()
            return os.clock() * 1000
        end)
        
        if tick then
            add_to_library(os, "clockms", function()
                return tick() * 1000
            end)
        end
    end
end

assert(getscriptbytecode, "Exploit not supported.")

local API: string = "http://api.plusgiant5.com"

local last_call = 0
local function call(konstantType: string, scriptPath: Script | ModuleScript | LocalScript): string
    local success: boolean, bytecode: string = pcall(getscriptbytecode, scriptPath)

    if (not success) then
        return `-- Failed to get script bytecode, error:\n\n--[[\n{bytecode}\n--]]`
    end

    local time_elapsed = os.clock() - last_call
    if time_elapsed <= .5 then
        task.wait(.5 - time_elapsed)
    end
    local httpResult = request({
        Url = API .. konstantType,
        Body = bytecode,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "text/plain"
        },
    })
    last_call = os.clock()
    
    if (httpResult.StatusCode ~= 200) then
        return `-- Error occured while requesting the API, error:\n\n--[[\n{httpResult.Body}\n--]]`
    else
        return httpResult.Body
    end
end

local function decompile(scriptPath: Script | ModuleScript | LocalScript): string
    return call("/konstant/decompile", scriptPath)
end

local function disassemble(scriptPath: Script | ModuleScript | LocalScript): string
    return call("/konstant/disassemble", scriptPath)
end

getgenv().decompile = decompile
getgenv().disassemble = disassemble

-- by lovrewe
