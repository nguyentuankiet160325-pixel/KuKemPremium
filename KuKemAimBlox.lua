--[[
    ═══════════════════════════════════════════════
    🌕 KUKEMPREMIUM — Blox Fruits Script
    Self-built UI | SilentAim · AutoSkill · ESP · Speed
    Không dùng Rayfield / library ngoài
    ═══════════════════════════════════════════════
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ═══════════════ CONFIG ═══════════════
local Config = {
    SilentAim = {
        Enabled = false, TeamCheck = true, WallCheck = false,
        FOV = 120, TargetPart = "Head", ShowFOV = true,
        Keybind = Enum.KeyCode.RightAlt,
    },
    AutoSkill = {
        Enabled = false, Skills = {"Z","X","C","V"},
        WaitBetween = 0.6, AutoClick = true,
        Keybind = Enum.KeyCode.G,
    },
    ESP = {
        Enabled = false, ShowBox = true, ShowName = true,
        ShowHealth = true, ShowDistance = true, MaxDistance = 1000,
        TeamCheck = true, Keybind = Enum.KeyCode.F,
    },
    Speed = {
        Enabled = false, Value = 50,
        Keybind = Enum.KeyCode.LeftShift,
    },
}

-- ═══════════════ MÀU VÀNG NEON ═══════════════
local Colors = {
    BG        = Color3.fromRGB(12, 10, 2),
    Panel     = Color3.fromRGB(20, 16, 4),
    Border    = Color3.fromRGB(255, 200, 40),
    Primary   = Color3.fromRGB(255, 200, 40),
    Secondary = Color3.fromRGB(255, 170, 0),
    Text      = Color3.fromRGB(255, 245, 210),
    TextDim   = Color3.fromRGB(180, 160, 100),
    On        = Color3.fromRGB(255, 200, 40),
    Off       = Color3.fromRGB(60, 50, 20),
    SliderFill = Color3.fromRGB(255, 200, 40),
    SliderBG  = Color3.fromRGB(40, 33, 8),
}

-- ═══════════════ UI BUILDER ═══════════════
local CoreGui = game:GetService("CoreGui")
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KukemPremium"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- Main frame
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 320, 0, 460)
Main.Position = UDim2.new(0, 40, 0, 80)
Main.BackgroundColor3 = Colors.BG
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Colors.Border
MainStroke.Thickness = 2
MainStroke.Transparency = 0.15
MainStroke.Parent = Main

-- Title bar
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 42)
Title.BackgroundColor3 = Colors.Panel
Title.BorderSizePixel = 0
Title.Text = "🌕  KUKEMPREMIUM"
Title.TextColor3 = Colors.Primary
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = Main

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = Title

local TitleStroke = Instance.new("UIStroke")
TitleStroke.Color = Colors.Border
TitleStroke.Thickness = 1
TitleStroke.Transparency = 0.4
TitleStroke.Parent = Title

-- Close button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 26, 0, 26)
CloseBtn.Position = UDim2.new(1, -34, 0, 8)
CloseBtn.BackgroundColor3 = Colors.Panel
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Colors.Primary
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = Title

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui.Enabled = not ScreenGui.Enabled
end)

-- Minimize button
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 26, 0, 26)
MinBtn.Position = UDim2.new(1, -64, 0, 8)
MinBtn.BackgroundColor3 = Colors.Panel
MinBtn.Text = "−"
MinBtn.TextColor3 = Colors.Primary
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 18
MinBtn.BorderSizePixel = 0
MinBtn.Parent = Title

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 6)
MinCorner.Parent = MinBtn

local minimized = false
local originalSize = Main.Size
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        Main.Size = UDim2.new(0, 320, 0, 42)
    else
        Main.Size = originalSize
    end
end)

-- Scrolling container
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -16, 1, -52)
Scroll.Position = UDim2.new(0, 8, 0, 48)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 4
Scroll.ScrollBarImageColor3 = Colors.Border
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroll.Parent = Main

local ListLayout = Instance.new("UIListLayout")
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Padding = UDim.new(0, 6)
ListLayout.Parent = Scroll

local Pad = Instance.new("UIPadding")
Pad.PaddingTop = UDim.new(0, 4)
Pad.PaddingBottom = UDim.new(0, 8)
Pad.Parent = Scroll

-- ═══════════════ COMPONENTS ═══════════════
local function makeSection(text)
    local sec = Instance.new("Frame")
    sec.Size = UDim2.new(1, 0, 0, 28)
    sec.BackgroundTransparency = 1
    sec.Parent = Scroll

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = "▸ " .. text
    lbl.TextColor3 = Colors.Primary
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = sec

    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, 0, 0, 1)
    line.Position = UDim2.new(0, 0, 1, -2)
    line.BackgroundColor3 = Colors.Border
    line.BackgroundTransparency = 0.6
    line.BorderSizePixel = 0
    line.Parent = sec

    return sec
end

local function makeToggle(label, default, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 34)
    btn.BackgroundColor3 = Colors.Panel
    btn.Text = ""
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = Scroll

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = btn

    local s = Instance.new("UIStroke")
    s.Color = Colors.Border
    s.Thickness = 1
    s.Transparency = 0.5
    s.Parent = btn

    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size = UDim2.new(1, -70, 1, 0)
    nameLbl.Position = UDim2.new(0, 12, 0, 0)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = label
    nameLbl.TextColor3 = Colors.Text
    nameLbl.Font = Enum.Font.Gotham
    nameLbl.TextSize = 13
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.Parent = btn

    local state = Instance.new("TextLabel")
    state.Size = UDim2.new(0, 46, 0, 22)
    state.Position = UDim2.new(1, -54, 0.5, -11)
    state.BackgroundColor3 = default and Colors.On or Colors.Off
    state.Text = default and "ON" or "OFF"
    state.TextColor3 = default and Colors.BG or Colors.TextDim
    state.Font = Enum.Font.GothamBold
    state.TextSize = 11
    state.BorderSizePixel = 0
    state.Parent = btn

    local stateCorner = Instance.new("UICorner")
    stateCorner.CornerRadius = UDim.new(0, 5)
    stateCorner.Parent = state

    local value = default
    btn.MouseButton1Click:Connect(function()
        value = not value
        state.Text = value and "ON" or "OFF"
        state.BackgroundColor3 = value and Colors.On or Colors.Off
        state.TextColor3 = value and Colors.BG or Colors.TextDim
        if callback then callback(value) end
    end)

    return btn
end

local function makeSlider(label, minV, maxV, default, suffix, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 52)
    frame.BackgroundColor3 = Colors.Panel
    frame.BorderSizePixel = 0
    frame.Parent = Scroll

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = frame

    local s = Instance.new("UIStroke")
    s.Color = Colors.Border
    s.Thickness = 1
    s.Transparency = 0.5
    s.Parent = frame

    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size = UDim2.new(1, -70, 0, 22)
    nameLbl.Position = UDim2.new(0, 12, 0, 4)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = label
    nameLbl.TextColor3 = Colors.Text
    nameLbl.Font = Enum.Font.Gotham
    nameLbl.TextSize = 13
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.Parent = frame

    local valueLbl = Instance.new("TextLabel")
    valueLbl.Size = UDim2.new(0, 60, 0, 22)
    valueLbl.Position = UDim2.new(1, -68, 0, 4)
    valueLbl.BackgroundTransparency = 1
    valueLbl.Text = tostring(default) .. (suffix or "")
    valueLbl.TextColor3 = Colors.Primary
    valueLbl.Font = Enum.Font.GothamBold
    valueLbl.TextSize = 12
    valueLbl.TextXAlignment = Enum.TextXAlignment.Right
    valueLbl.Parent = frame

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -24, 0, 6)
    track.Position = UDim2.new(0, 12, 0, 34)
    track.BackgroundColor3 = Colors.SliderBG
    track.BorderSizePixel = 0
    track.Parent = frame

    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = track

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - minV) / (maxV - minV), 0, 1, 0)
    fill.BackgroundColor3 = Colors.SliderFill
    fill.BorderSizePixel = 0
    fill.Parent = track

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = UDim2.new((default - minV) / (maxV - minV), -7, 0.5, -7)
    knob.BackgroundColor3 = Colors.Primary
    knob.BorderSizePixel = 0
    knob.ZIndex = 2
    knob.Parent = track

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    local knobStroke = Instance.new("UIStroke")
    knobStroke.Color = Colors.Border
    knobStroke.Thickness = 1
    knobStroke.Transparency = 0
    knobStroke.Parent = knob

    local dragging = false

    local function updateFromX(x)
        local rel = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local val = math.floor(minV + rel * (maxV - minV))
        -- làm tròn nếu increment > 1
        if maxV - minV > 100 then
            val = math.floor(val)
        end
        fill.Size = UDim2.new(rel, 0, 1, 0)
        knob.Position = UDim2.new(rel, -7, 0.5, -7)
        valueLbl.Text = tostring(val) .. (suffix or "")
        if callback then callback(val) end
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateFromX(input.Position.X)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateFromX(input.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    return frame
end

local function makeInput(label, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 52)
    frame.BackgroundColor3 = Colors.Panel
    frame.BorderSizePixel = 0
    frame.Parent = Scroll

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = frame

    local s = Instance.new("UIStroke")
    s.Color = Colors.Border
    s.Thickness = 1
    s.Transparency = 0.5
    s.Parent = frame

    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size = UDim2.new(1, -24, 0, 20)
    nameLbl.Position = UDim2.new(0, 12, 0, 4)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = label
    nameLbl.TextColor3 = Colors.Text
    nameLbl.Font = Enum.Font.Gotham
    nameLbl.TextSize = 13
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.Parent = frame

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -24, 0, 24)
    box.Position = UDim2.new(0, 12, 0, 24)
    box.BackgroundColor3 = Colors.BG
    box.Text = default
    box.TextColor3 = Colors.Primary
    box.Font = Enum.Font.Gotham
    box.TextSize = 12
    box.BorderSizePixel = 0
    box.ClearTextOnFocus = false
    box.Parent = frame

    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 4)
    bc.Parent = box

    local bs = Instance.new("UIStroke")
    bs.Color = Colors.Border
    bs.Thickness = 1
    bs.Transparency = 0.6
    bs.Parent = box

    box.FocusLost:Connect(function()
        if callback then callback(box.Text) end
    end)

    return frame
end

local function makeButton(label, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 34)
    btn.BackgroundColor3 = Colors.Panel
    btn.Text = label
    btn.TextColor3 = Colors.Primary
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = Scroll

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = btn

    local s = Instance.new("UIStroke")
    s.Color = Colors.Border
    s.Thickness = 1
    s.Transparency = 0.4
    s.Parent = btn

    btn.MouseEnter:Connect(function() btn.BackgroundColor3 = Colors.Tertiary or Color3.fromRGB(35, 28, 5) end)
    btn.MouseLeave:Connect(function() btn.BackgroundColor3 = Colors.Panel end)
    btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)

    return btn
end

local function makeLabel(text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 20)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Colors.TextDim
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = Scroll
    return lbl
end

-- ═══════════════ HELPER FUNCTIONS ═══════════════
local function getMyRoot()
    local c = LocalPlayer.Character
    return c and c:FindFirstChild("HumanoidRootPart") or nil
end

local function getMyHum()
    local c = LocalPlayer.Character
    return c and c:FindFirstChildOfClass("Humanoid") or nil
end

local function isValidTarget(p)
    if p == LocalPlayer or not p.Character then return false end
    local hum = p.Character:FindFirstChildOfClass("Humanoid")
    local hrp = p.Character:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp or hum.Health <= 0 then return false end
    if Config.SilentAim.TeamCheck and p.Team == LocalPlayer.Team then return false end
    return true
end

local function getNearestPlayer()
    local nearest, shortest = nil, Config.SilentAim.FOV
    local myRoot = getMyRoot()
    if not myRoot then return nil end
    for _, p in ipairs(Players:GetPlayers()) do
        if isValidTarget(p) then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            if onScreen then
                local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                local mag = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                if mag < shortest then
                    shortest = mag
                    nearest = p
                end
            end
        end
    end
    return nearest
end

local function isVisible(part)
    if not Config.SilentAim.WallCheck then return true end
    local origin = Camera.CFrame.Position
    local ray = Ray.new(origin, (part.Position - origin).Unit * 500)
    local hit = Workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, part.Parent})
    return hit == nil
end

-- ═══════════════ BUILD UI ═══════════════
makeSection("SILENT AIM")

makeToggle("Bật Silent Aim", false, function(v) Config.SilentAim.Enabled = v end)
makeToggle("Kiểm tra đồng đội", true, function(v) Config.SilentAim.TeamCheck = v end)
makeToggle("Kiểm tra tường", false, function(v) Config.SilentAim.WallCheck = v end)
makeToggle("Hiển thị vòng FOV", true, function(v) Config.SilentAim.ShowFOV = v end)
makeSlider("FOV", 10, 500, 120, "px", function(v) Config.SilentAim.FOV = v end)

makeSection("AUTO SKILL")

makeToggle("Bật Auto Skill", false, function(v)
    Config.AutoSkill.Enabled = v
    if v then task.spawn(autoSkillLoop) end
end)
makeToggle("Auto Click", true, function(v) Config.AutoSkill.AutoClick = v end)
makeSlider("Delay skill", 0, 3, 0.6, "s", function(v) Config.AutoSkill.WaitBetween = v end)
makeInput("Danh sách phím (Z,X,C,V)", "Z,X,C,V", function(txt)
    local list = {}
    for k in string.gmatch(txt, "[^,]+") do
        table.insert(list, (k:gsub("%s+", "")))
    end
    if #list > 0 then Config.AutoSkill.Skills = list end
end)

makeSection("ESP")

makeToggle("Bật ESP", false, function(v) Config.ESP.Enabled = v end)
makeToggle("Hiển thị Box", true, function(v) Config.ESP.ShowBox = v end)
makeToggle("Hiển thị Tên", true, function(v) Config.ESP.ShowName = v end)
makeToggle("Hiển thị Máu", true, function(v) Config.ESP.ShowHealth = v end)
makeToggle("Hiển thị Khoảng cách", true, function(v) Config.ESP.ShowDistance = v end)
makeToggle("Kiểm tra đồng đội", true, function(v) Config.ESP.TeamCheck = v end)
makeSlider("Khoảng cách tối đa", 100, 5000, 1000, " studs", function(v) Config.ESP.MaxDistance = v end)

makeSection("SPEED")

makeToggle("Bật Speed", false, function(v)
    Config.Speed.Enabled = v
    if not v then
        local hum = getMyHum()
        if hum then hum.WalkSpeed = 16 end
    end
end)
makeSlider("WalkSpeed (1 - 1000)", 1, 1000, 50, " ws", function(v) Config.Speed.Value = v end)
makeButton("Reset về 16", function()
    Config.Speed.Value = 16
    local hum = getMyHum()
    if hum then hum.WalkSpeed = 16 end
end)

makeSection("THÔNG TIN")
makeLabel("🌕 KukemPremium — Gold Neon")
makeLabel("Phím tắt: RightAlt · F · G · LeftShift")
makeButton("Tắt toàn bộ", function()
    Config.SilentAim.Enabled = false
    Config.AutoSkill.Enabled = false
    Config.ESP.Enabled = false
    Config.Speed.Enabled = false
    local hum = getMyHum()
    if hum then hum.WalkSpeed = 16 end
end)
makeButton("Ẩn/Hiện Menu", function()
    ScreenGui.Enabled = not ScreenGui.Enabled
end)

-- ═══════════════ HOOK SILENT AIM ═══════════════
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if Config.SilentAim.Enabled and (method == "FindPartOnRay" or method == "Raycast") then
        local target = getNearestPlayer()
        if target and target.Character then
            local aimPart = target.Character:FindFirstChild(Config.SilentAim.TargetPart)
            if aimPart and isVisible(aimPart) then
                local dir = (aimPart.Position - Camera.CFrame.Position).Unit * 500
                if method == "FindPartOnRay" then
                    args[1] = Ray.new(Camera.CFrame.Position, dir)
                elseif method == "Raycast" then
                    args[2] = dir
                end
            end
        end
    end

    return oldNamecall(self, unpack(args))
end)

-- ═══════════════ AUTO SKILL LOOP ═══════════════
function autoSkillLoop()
    while Config.AutoSkill.Enabled do
        if getMyHum() then
            for _, k in ipairs(Config.AutoSkill.Skills) do
                if not Config.AutoSkill.Enabled then break end
                local vk = Enum.KeyCode[k]
                if vk then
                    keypress(vk); task.wait(0.05); keyrelease(vk)
                end
                task.wait(Config.AutoSkill.WaitBetween)
            end
            if Config.AutoSkill.AutoClick then
                mouse1click(); task.wait(0.1)
            end
        end
        task.wait(0.1)
    end
end

-- ═══════════════ ESP SYSTEM ═══════════════
local espObjects = {}

local function createESP(player)
    if player == LocalPlayer then return end
    local box = Drawing.new("Square")
    box.Visible, box.Thickness, box.Filled = false, 1, false
    box.Color = Color3.fromRGB(255, 200, 40)

    local name = Drawing.new("Text")
    name.Size, name.Center, name.Outline, name.Visible = 14, true, true, false
    name.Color = Color3.fromRGB(255, 245, 210)

    local hp = Drawing.new("Text")
    hp.Size, hp.Center, hp.Outline, hp.Visible = 14, true, true, false
    hp.Color = Color3.fromRGB(0, 255, 80)

    local dist = Drawing.new("Text")
    dist.Size, dist.Center, dist.Outline, dist.Visible = 13, true, true, false
    dist.Color = Color3.fromRGB(255, 200, 40)

    espObjects[player] = {box = box, name = name, hp = hp, dist = dist}
end

local function removeESP(player)
    local o = espObjects[player]
    if o then
        for _, v in pairs(o) do v:Remove() end
        espObjects[player] = nil
    end
end

local function updateESP()
    for p, o in pairs(espObjects) do
        local show = Config.ESP.Enabled and p.Character ~= nil
        local hrp, head, hum

        if show then
            hrp = p.Character:FindFirstChild("HumanoidRootPart")
            head = p.Character:FindFirstChild("Head")
            hum = p.Character:FindFirstChildOfClass("Humanoid")
            if not (hrp and head and hum and hum.Health > 0) then show = false end
            if Config.ESP.TeamCheck and p.Team == LocalPlayer.Team then show = false end
        end

        if show then
            local dst = (hrp.Position - Camera.CFrame.Position).Magnitude
            if dst > Config.ESP.MaxDistance then show = false end

            if show then
                local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                local headPos = Camera:WorldToViewportPoint(head.Position)
                if not onScreen then show = false
                else
                    local h = math.abs(headPos.Y - screenPos.Y)
                    local w = h / 2
                    o.box.Size = Vector2.new(w, h)
                    o.box.Position = Vector2.new(screenPos.X - w/2, screenPos.Y - h/2)
                    o.box.Visible = Config.ESP.ShowBox

                    o.name.Text = p.Name
                    o.name.Position = Vector2.new(screenPos.X, screenPos.Y - h/2 - 22)
                    o.name.Visible = Config.ESP.ShowName

                    o.hp.Text = "HP: " .. math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth)
                    o.hp.Position = Vector2.new(screenPos.X, screenPos.Y - h/2 - 6)
                    o.hp.Visible = Config.ESP.ShowHealth

                    o.dist.Text = math.floor(dst) .. "s"
                    o.dist.Position = Vector2.new(screenPos.X, screenPos.Y + h/2 + 4)
                    o.dist.Visible = Config.ESP.ShowDistance
                end
            end
        end

        if not show then
            for _, v in pairs(o) do v.Visible = false end
        end
    end
end

-- ═══════════════ FOV CIRCLE + MAIN LOOP ═══════════════
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 1.5
fovCircle.NumSides = 80
fovCircle.Filled = false
fovCircle.Color = Color3.fromRGB(255, 200, 40)
fovCircle.Visible = false

RunService.RenderStepped:Connect(function()
    fovCircle.Radius = Config.SilentAim.FOV
    fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    fovCircle.Visible = Config.SilentAim.Enabled and Config.SilentAim.ShowFOV
    updateESP()
    if Config.Speed.Enabled then
        local hum = getMyHum()
        if hum then hum.WalkSpeed = Config.Speed.Value end
    end
end)

-- ═══════════════ KEYBIND ═══════════════
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Config.SilentAim.Keybind then
        Config.SilentAim.Enabled = not Config.SilentAim.Enabled
    elseif input.KeyCode == Config.ESP.Keybind then
        Config.ESP.Enabled = not Config.ESP.Enabled
    elseif input.KeyCode == Config.AutoSkill.Keybind then
        Config.AutoSkill.Enabled = not Config.AutoSkill.Enabled
        if Config.AutoSkill.Enabled then task.spawn(autoSkillLoop) end
    elseif input.KeyCode == Config.Speed.Keybind then
        Config.Speed.Enabled = not Config.Speed.Enabled
        if not Config.Speed.Enabled then
            local hum = getMyHum()
            if hum then hum.WalkSpeed = 16 end
        end
    elseif input.KeyCode == Enum.KeyCode.RightControl then
        ScreenGui.Enabled = not ScreenGui.Enabled
    end
end)

-- ═══════════════ INIT ESP ═══════════════
for _, p in ipairs(Players:GetPlayers()) do createESP(p) end
Players.PlayerAdded:Connect(createESP)
Players.PlayerRemoving:Connect(removeESP)

print("[KukemPremium] Loaded — Self-built UI (không Rayfield)")
