-- player_locator_menu.lua
-- Delta Executor (Roblox Android) — Player Locator + Menu
-- Execute trong Delta. Auto-run. Unload: getgenv().PLocatorUnload()

if getgenv().PLocatorLoaded then
    pcall(getgenv().PLocatorUnload)
end
getgenv().PLocatorLoaded = true

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS        = game:GetService("UserInputService")
local Workspace  = game:GetService("Workspace")
local Camera     = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ==== CONFIG runtime — menu sẽ ghi vào đây ====
local CONFIG = {
    enabled      = true,
    team_check   = false,
    max_distance = 1000,
    box          = true,
    name         = true,
    distance     = true,
    health       = true,
    tracer       = false,
    dot          = false,
    color        = Color3.fromRGB(0, 255, 170),
    team_color   = Color3.fromRGB(0, 170, 255),
    enemy_color  = Color3.fromRGB(255, 80, 80),
}

local Drawing = Drawing or (getgenv and getgenv().Drawing)
if not Drawing then
    return warn("[PLocator] Drawing API không có. Delta phải cung cấp.")
end

-- ============ ESP CORE ============
local esp_objects = {}

local function new_drawing(class)
    local ok, obj = pcall(function() return Drawing.new(class) end)
    if ok then return obj end
    return nil
end

local function create_esp(player)
    if player == LocalPlayer or esp_objects[player] then return end
    local p = {}
    p.box        = new_drawing("Square")
    p.name       = new_drawing("Text")
    p.distance   = new_drawing("Text")
    p.health_bg  = new_drawing("Square")
    p.health_bar = new_drawing("Square")
    p.tracer     = new_drawing("Line")
    p.dot        = new_drawing("Circle")

    if p.box then p.box.Thickness = 1; p.box.Filled = false end
    if p.name then p.name.Size = 14; p.name.Center = true; p.name.Outline = true end
    if p.distance then p.distance.Size = 13; p.distance.Center = true; p.distance.Outline = true end
    if p.health_bg then
        p.health_bg.Filled = true
        p.health_bg.Color = Color3.new(0, 0, 0)
        p.health_bg.Transparency = 0.4
    end
    if p.health_bar then p.health_bar.Filled = true end
    if p.tracer then p.tracer.Thickness = 1 end
    if p.dot then p.dot.Radius = 3; p.dot.Filled = true end

    esp_objects[player] = p
end

local function destroy_esp(player)
    local p = esp_objects[player]
    if not p then return end
    for _, obj in pairs(p) do
        if obj and obj.Remove then pcall(function() obj:Remove() end) end
    end
    esp_objects[player] = nil
end

for _, pl in ipairs(Players:GetPlayers()) do create_esp(pl) end
Players.PlayerAdded:Connect(create_esp)
Players.PlayerRemoving:Connect(destroy_esp)

local function get_character(player)
    if player.Character and player.Character.Parent then return player.Character end
end

local function world_to_screen(pos)
    local vec, on_screen = Camera:WorldToViewportPoint(pos)
    if not on_screen or vec.Z <= 0 then return nil end
    return Vector2.new(vec.X, vec.Y), vec.Z
end

local function same_team(pl)
    if not CONFIG.team_check then return false end
    return pl.Team and LocalPlayer.Team and pl.Team == LocalPlayer.Team
end

local function color_for(pl)
    if same_team(pl) then return CONFIG.team_color end
    if pl.Team and LocalPlayer.Team then return CONFIG.enemy_color end
    return CONFIG.color
end

local function hide_all(player_p)
    for _, obj in pairs(player_p) do
        if obj and obj.Visible ~= nil then obj.Visible = false end
    end
end

local render_conn = RunService.RenderStepped:Connect(function()
    if not CONFIG.enabled or not LocalPlayer.Character then
        for _, p in pairs(esp_objects) do hide_all(p) end
        return
    end

    local my_hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

    for player, p in pairs(esp_objects) do
        local char     = get_character(player)
        local head     = char and char:FindFirstChild("Head")
        local hrp      = char and char:FindFirstChild("HumanoidRootPart")
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")

        local visible = char and head and hrp and humanoid and humanoid.Health > 0

        if visible and my_hrp then
            local dist = (my_hrp.Position - hrp.Position).Magnitude
            if dist > CONFIG.max_distance then visible = false end

            local root_screen = visible and world_to_screen(hrp.Position + Vector3.new(0, 2.5, 0))
            local head_screen = visible and world_to_screen(head.Position + Vector3.new(0, 0.5, 0))
            local feet_screen = visible and world_to_screen(hrp.Position - Vector3.new(0, 2.5, 0))

            if not (root_screen and head_screen and feet_screen) then
                visible = false
            end

            if visible then
                local top    = head_screen
                local bottom = feet_screen
                local height = bottom.Y - top.Y
                local width  = height * 0.55
                local box_x  = top.X - width / 2
                local box_y  = top.Y
                local col    = color_for(player)

                if p.box then
                    p.box.Visible  = CONFIG.box
                    p.box.Color    = col
                    p.box.Size     = Vector2.new(width, height)
                    p.box.Position = Vector2.new(box_x, box_y)
                end
                if p.dot then
                    p.dot.Visible  = CONFIG.dot and not CONFIG.box
                    p.dot.Color    = col
                    p.dot.Position = root_screen
                end
                if p.name then
                    p.name.Visible  = CONFIG.name
                    p.name.Color    = col
                    p.name.Position = Vector2.new(root_screen.X, box_y - 16)
                    p.name.Text     = player.Name
                end
                if p.distance then
                    p.distance.Visible  = CONFIG.distance
                    p.distance.Color    = Color3.fromRGB(220, 220, 220)
                    p.distance.Position = Vector2.new(root_screen.X, box_y + height + 2)
                    p.distance.Text     = string.format("%d studs", math.floor(dist))
                end
                if p.health_bg and p.health_bar then
                    local hp    = math.clamp(humanoid.Health / math.max(humanoid.MaxHealth, 1), 0, 1)
                    local bar_h = height * hp
                    p.health_bg.Visible  = CONFIG.health
                    p.health_bg.Size     = Vector2.new(3, height)
                    p.health_bg.Position = Vector2.new(box_x - 6, box_y)
                    p.health_bar.Visible  = CONFIG.health
                    p.health_bar.Color    = Color3.fromRGB(80, 255, 120):Lerp(Color3.fromRGB(255, 60, 60), 1 - hp)
                    p.health_bar.Size     = Vector2.new(3, bar_h)
                    p.health_bar.Position = Vector2.new(box_x - 6, box_y + (height - bar_h))
                end
                if p.tracer then
                    p.tracer.Visible = CONFIG.tracer
                    p.tracer.Color   = col
                    p.tracer.From    = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    p.tracer.To      = Vector2.new(root_screen.X, box_y + height)
                end
            end
        end

        if not visible then hide_all(p) end
    end
end)

-- ============ MENU UI ============
local parent = (gethui and gethui()) or game:GetService("CoreGui")

local old = parent:FindFirstChild("PLocatorGui")
if old then old:Destroy() end

local screen = Instance.new("ScreenGui")
screen.Name = "PLocatorGui"
screen.ResetOnSpawn = false
screen.IgnoreGuiInset = true
screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screen.Parent = parent

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0, 240, 0, 44)
main.Position = UDim2.new(0, 30, 0, 80)
main.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
main.BorderSizePixel = 0
main.Active = true
main.ClipsDescendants = true
main.Parent = screen

local main_corner = Instance.new("UICorner")
main_corner.CornerRadius = UDim.new(0, 10)
main_corner.Parent = main

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(45, 200, 160)
stroke.Thickness = 1
stroke.Transparency = 0.35
stroke.Parent = main

-- Title bar
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -44, 0, 44)
title.Position = UDim2.new(0, 14, 0, 0)
title.BackgroundTransparency = 1
title.Text = "PLAYER LOCATOR"
title.TextColor3 = Color3.fromRGB(220, 255, 240)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = main

local accent_dot = Instance.new("Frame")
accent_dot.Size = UDim2.new(0, 8, 0, 8)
accent_dot.Position = UDim2.new(0, 6, 0, 18)
accent_dot.BackgroundColor3 = Color3.fromRGB(0, 255, 170)
accent_dot.BorderSizePixel = 0
accent_dot.Parent = main
local accent_corner = Instance.new("UICorner")
accent_corner.CornerRadius = UDim.new(1, 0)
accent_corner.Parent = accent_dot

-- Minimize button
local min_btn = Instance.new("TextButton")
min_btn.Size = UDim2.new(0, 28, 0, 28)
min_btn.Position = UDim2.new(1, -36, 0, 8)
min_btn.BackgroundColor3 = Color3.fromRGB(35, 38, 48)
min_btn.BorderSizePixel = 0
min_btn.Text = "–"
min_btn.TextColor3 = Color3.fromRGB(200, 200, 210)
min_btn.Font = Enum.Font.GothamBold
min_btn.TextSize = 18
min_btn.AutoButtonColor = false
min_btn.Parent = main
local min_corner = Instance.new("UICorner")
min_corner.CornerRadius = UDim.new(0, 6)
min_corner.Parent = min_btn

-- Content container
local content = Instance.new("Frame")
content.Size = UDim2.new(1, 0, 0, 0)
content.Position = UDim2.new(0, 0, 0, 48)
content.BackgroundTransparency = 1
content.Parent = main

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 6)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = content

local pad = Instance.new("UIPadding")
pad.PaddingLeft = UDim.new(0, 12)
pad.PaddingRight = UDim.new(0, 12)
pad.PaddingTop = UDim.new(0, 4)
pad.PaddingBottom = UDim.new(0, 12)
pad.Parent = content

-- Row builder
local ROW_H = 28
local ROW_GAP = 6

local function make_row(label_text, initial_state, on_toggle)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, ROW_H)
    row.BackgroundTransparency = 1
    row.Parent = content

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -60, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label_text
    lbl.TextColor3 = Color3.fromRGB(210, 215, 225)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 50, 0, 24)
    btn.Position = UDim2.new(1, -50, 0.5, -12)
    btn.BackgroundColor3 = initial_state and Color3.fromRGB(0, 200, 140) or Color3.fromRGB(45, 48, 58)
    btn.BorderSizePixel = 0
    btn.Text = initial_state and "ON" or "OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.AutoButtonColor = false
    btn.Parent = row
    local btn_corner = Instance.new("UICorner")
    btn_corner.CornerRadius = UDim.new(0, 6)
    btn_corner.Parent = btn

    local state = initial_state
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = state and "ON" or "OFF"
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 200, 140) or Color3.fromRGB(45, 48, 58)
        if on_toggle then on_toggle(state) end
    end)

    return row
end

-- Build toggles
local toggles = {
    { "Enabled",      "enabled"      },
    { "Box",          "box"          },
    { "Name",         "name"         },
    { "Distance",     "distance"     },
    { "Health bar",   "health"       },
    { "Tracer",       "tracer"       },
    { "Dot",          "dot"          },
    { "Team check",   "team_check"   },
}

for _, t in ipairs(toggles) do
    local key = t[2]
    make_row(t[1], CONFIG[key], function(state)
        CONFIG[key] = state
    end)
end

-- Distance row with stepper
do
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, ROW_H)
    row.BackgroundTransparency = 1
    row.Parent = content

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -110, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = "Max distance"
    lbl.TextColor3 = Color3.fromRGB(210, 215, 225)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local minus = Instance.new("TextButton")
    minus.Size = UDim2.new(0, 26, 0, 24)
    minus.Position = UDim2.new(1, -100, 0.5, -12)
    minus.BackgroundColor3 = Color3.fromRGB(45, 48, 58)
    minus.BorderSizePixel = 0
    minus.Text = "−"
    minus.TextColor3 = Color3.fromRGB(220, 220, 230)
    minus.Font = Enum.Font.GothamBold
    minus.TextSize = 14
    minus.AutoButtonColor = false
    minus.Parent = row
    local mc = Instance.new("UICorner"); mc.CornerRadius = UDim.new(0, 6); mc.Parent = minus

    local val = Instance.new("TextLabel")
    val.Size = UDim2.new(0, 44, 0, 24)
    val.Position = UDim2.new(1, -72, 0.5, -12)
    val.BackgroundColor3 = Color3.fromRGB(28, 30, 38)
    val.BorderSizePixel = 0
    val.Text = tostring(CONFIG.max_distance)
    val.TextColor3 = Color3.fromRGB(220, 255, 240)
    val.Font = Enum.Font.GothamBold
    val.TextSize = 12
    val.Parent = row
    local vc = Instance.new("UICorner"); vc.CornerRadius = UDim.new(0, 6); vc.Parent = val

    local plus = Instance.new("TextButton")
    plus.Size = UDim2.new(0, 26, 0, 24)
    plus.Position = UDim2.new(1, -26, 0.5, -12)
    plus.BackgroundColor3 = Color3.fromRGB(45, 48, 58)
    plus.BorderSizePixel = 0
    plus.Text = "+"
    plus.TextColor3 = Color3.fromRGB(220, 220, 230)
    plus.Font = Enum.Font.GothamBold
    plus.TextSize = 14
    plus.AutoButtonColor = false
    plus.Parent = row
    local pc = Instance.new("UICorner"); pc.CornerRadius = UDim.new(0, 6); pc.Parent = plus

    local function set_dist(v)
        CONFIG.max_distance = math.clamp(v, 50, 5000)
        val.Text = tostring(CONFIG.max_distance)
    end

    minus.MouseButton1Click:Connect(function() set_dist(CONFIG.max_distance - 100) end)
    plus.MouseButton1Click:Connect(function() set_dist(CONFIG.max_distance + 100) end)
end

-- Compute content height: rows + distance row
local row_count = #toggles + 1
local content_h = row_count * ROW_H + (row_count - 1) * ROW_GAP + 16
content.Size = UDim2.new(1, 0, 0, content_h)

local expanded_h = 44 + content_h + 4
main.Size = UDim2.new(0, 240, 0, expanded_h)

-- Minimize logic
local expanded = true
min_btn.MouseButton1Click:Connect(function()
    expanded = not expanded
    if expanded then
        main:TweenSize(UDim2.new(0, 240, 0, expanded_h), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.15, true)
        content.Visible = true
    else
        content.Visible = false
        main:TweenSize(UDim2.new(0, 240, 0, 44), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.15, true)
    end
end)

-- ============ DRAG (touch + mouse) ============
local dragging, drag_start, start_pos = false, nil, nil

local function begin_drag(input)
    dragging = true
    drag_start = input.Position
    start_pos = main.Position
end

local function update_drag(input)
    if not dragging then return end
    local delta = input.Position - drag_start
    main.Position = UDim2.new(
        start_pos.X.Scale, start_pos.X.Offset + delta.X,
        start_pos.Y.Scale, start_pos.Y.Offset + delta.Y
    )
end

local function end_drag()
    dragging = false
end

title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
    or input.UserInputType == Enum.UserInputType.MouseButton1 then
        begin_drag(input)
    end
end)
title.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
    or input.UserInputType == Enum.UserInputType.MouseButton1 then
        end_drag()
    end
end)

UIS.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
    or input.UserInputType == Enum.UserInputType.MouseMovement then
        update_drag(input)
    end
end)
UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
    or input.UserInputType == Enum.UserInputType.MouseButton1 then
        end_drag()
    end
end)

-- Also allow drag from accent dot area (feels more natural on mobile)
accent_dot.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
    or input.UserInputType == Enum.UserInputType.MouseButton1 then
        begin_drag(input)
    end
end)
accent_dot.InputEnded:Connect(function(input) end_drag() end)

-- ============ UNLOAD ============
getgenv().PLocatorUnload = function()
    if render_conn then render_conn:Disconnect() end
    for player, _ in pairs(esp_objects) do destroy_esp(player) end
    if screen then screen:Destroy() end
    getgenv().PLocatorLoaded = false
    print("[PLocator] unloaded")
end

print("[PLocator] loaded — menu + ESP active")