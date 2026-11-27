-- Roblox UI Builder companion plugin
-- Creates real editable Roblox GUI instances from a project JSON exported by the website.
-- Install this file as a local Studio plugin, then enable it in Studio.

local HttpService = game:GetService("HttpService")
local Selection = game:GetService("Selection")
local toolbar = plugin:CreateToolbar("Roblox UI Builder")
local toggle = toolbar:CreateButton("Open Builder Import", "Import a Roblox UI Builder project JSON", "rbxassetid://4458901886")
toggle.ClickableWhenViewportHidden = true

local widgetInfo = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Float, false, false, 440, 520, 340, 300)
local widget = plugin:CreateDockWidgetPluginGui("RobloxUIBuilderImport", widgetInfo)
widget.Title = "Roblox UI Builder — Import"

local root = Instance.new("Frame")
root.Size = UDim2.fromScale(1, 1)
root.BackgroundColor3 = Color3.fromRGB(27, 30, 38)
root.BorderSizePixel = 0
root.Parent = widget

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 12)
padding.PaddingBottom = UDim.new(0, 12)
padding.PaddingLeft = UDim.new(0, 12)
padding.PaddingRight = UDim.new(0, 12)
padding.Parent = root

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 9)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = root

local function label(text, height, order)
	local item = Instance.new("TextLabel")
	item.Size = UDim2.new(1, 0, 0, height)
	item.BackgroundTransparency = 1
	item.Text = text
	item.TextColor3 = Color3.fromRGB(232, 235, 242)
	item.Font = Enum.Font.Gotham
	item.TextSize = 13
	item.TextXAlignment = Enum.TextXAlignment.Left
	item.TextWrapped = true
	item.LayoutOrder = order
	item.Parent = root
	return item
end

label("Paste the project JSON downloaded from Roblox UI Builder.", 36, 1)

local input = Instance.new("TextBox")
input.Name = "ProjectJSON"
input.Size = UDim2.new(1, 0, 1, -145)
input.BackgroundColor3 = Color3.fromRGB(15, 18, 24)
input.TextColor3 = Color3.fromRGB(225, 230, 240)
input.PlaceholderText = "Paste JSON here…"
input.PlaceholderColor3 = Color3.fromRGB(125, 133, 148)
input.ClearTextOnFocus = false
input.MultiLine = true
input.TextXAlignment = Enum.TextXAlignment.Left
input.TextYAlignment = Enum.TextYAlignment.Top
input.Font = Enum.Font.Code
input.TextSize = 12
input.LayoutOrder = 2
input.Parent = root

local build = Instance.new("TextButton")
build.Size = UDim2.new(1, 0, 0, 38)
build.BackgroundColor3 = Color3.fromRGB(118, 84, 232)
build.TextColor3 = Color3.new(1, 1, 1)
build.Text = "Build GUI"
build.Font = Enum.Font.GothamBold
build.TextSize = 14
build.LayoutOrder = 3
build.Parent = root
local buildCorner = Instance.new("UICorner")
buildCorner.CornerRadius = UDim.new(0, 8)
buildCorner.Parent = build

local status = label("Ready. Your design will be created as editable Instances.", 38, 4)
status.TextColor3 = Color3.fromRGB(160, 170, 188)

local function colorFromHex(value, fallback)
	if type(value) ~= "string" then return fallback end
	local hex = value:gsub("#", "")
	if #hex ~= 6 then return fallback end
	local r, g, b = tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5, 6), 16)
	if not r or not g or not b then return fallback end
	return Color3.fromRGB(r, g, b)
end

local function fontFromName(name)
	local map = {
		Gotham = Enum.Font.Gotham, GothamBold = Enum.Font.GothamBold,
		Arial = Enum.Font.Arial, ArialBold = Enum.Font.ArialBold,
		SourceSans = Enum.Font.SourceSans, SourceSansBold = Enum.Font.SourceSansBold,
	}
	return map[name] or Enum.Font.Gotham
end

local allowed = {Frame=true, TextButton=true, TextLabel=true, ImageLabel=true, ImageButton=true, ScrollingFrame=true}

local function createInstance(data, parent)
	local className = data.type
	if not allowed[className] then return nil end
	local object = Instance.new(className)
	object.Name = tostring(data.name or className)
	object.BackgroundColor3 = colorFromHex(data.bg, Color3.fromRGB(255, 255, 255))
	object.BackgroundTransparency = math.clamp(tonumber(data.transparency) or 0, 0, 1)
	object.BorderSizePixel = 0
	object.Position = UDim2.fromOffset(tonumber(data.x) or 0, tonumber(data.y) or 0)
	object.Size = UDim2.fromOffset(math.max(1, tonumber(data.w) or 100), math.max(1, tonumber(data.h) or 40))
	object.Parent = parent

	if object:IsA("TextLabel") or object:IsA("TextButton") then
		object.Text = tostring(data.text or "")
		object.TextColor3 = colorFromHex(data.textColor, Color3.fromRGB(32, 38, 51))
		object.Font = fontFromName(data.font)
		object.TextSize = math.clamp(tonumber(data.textSize) or 14, 8, 100)
		object.TextWrapped = true
		object.TextScaled = false
		object.AutoButtonColor = true
	end

	if object:IsA("ImageLabel") or object:IsA("ImageButton") then
		local image = tostring(data.image or "")
		if image:match("^%d+$") then image = "rbxassetid://" .. image end
		if image ~= "" then object.Image = image end
		if object:IsA("ImageButton") then
			object.Text = tostring(data.text or "")
			object.TextColor3 = colorFromHex(data.textColor, Color3.new(1, 1, 1))
			object.Font = fontFromName(data.font)
			object.TextSize = math.clamp(tonumber(data.textSize) or 14, 8, 100)
		end
	end

	if object:IsA("ScrollingFrame") then
		object.CanvasSize = UDim2.new(0, 0, 0, 0)
		object.ScrollBarThickness = 6
		object.ScrollingDirection = Enum.ScrollingDirection.Y
	end

	local radius = math.max(0, tonumber(data.corner) or 0)
	if radius > 0 then
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, radius)
		corner.Parent = object
	end
	local stroke = math.max(0, tonumber(data.stroke) or 0)
	if stroke > 0 then
		local outline = Instance.new("UIStroke")
		outline.Thickness = stroke
		outline.Color = colorFromHex(data.strokeColor, Color3.fromRGB(37, 43, 56))
		outline.Parent = object
	end
	return object
end

build.Activated:Connect(function()
	local ok, projectData = pcall(function() return HttpService:JSONDecode(input.Text) end)
	if not ok or type(projectData) ~= "table" or type(projectData.instances) ~= "table" then
		status.Text = "Invalid JSON. Export a project JSON file from the website and paste its contents here."
		status.TextColor3 = Color3.fromRGB(255, 140, 140)
		return
	end

	local starterGui = game:GetService("StarterGui")
	local old = starterGui:FindFirstChild("RobloxUIBuilderGui")
	if old then old:Destroy() end

	local screen = Instance.new("ScreenGui")
	screen.Name = "RobloxUIBuilderGui"
	screen.ResetOnSpawn = false
	screen.IgnoreGuiInset = false
	screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screen.Parent = starterGui

	local created = 0
	for _, data in ipairs(projectData.instances) do
		if type(data) == "table" and createInstance(data, screen) then created += 1 end
	end
	Selection:Set({screen})
	status.Text = "Created " .. tostring(created) .. " editable GUI objects in StarterGui. Select the ScreenGui and use File → Save to File… to save as .rbxm."
	status.TextColor3 = Color3.fromRGB(150, 230, 175)
end)

toggle.Click:Connect(function() widget.Enabled = not widget.Enabled end)
