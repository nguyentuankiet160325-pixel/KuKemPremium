local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ══════ CONFIG ══════
local Config = {
    SilentAim = { Enabled=false, TeamCheck=true, WallCheck=false, FOV=140,
        TargetPart="Head", ShowFOV=true, Keybind=Enum.KeyCode.RightAlt },
    AutoSkill = { Enabled=false, Skills={"Z","X","C","V"},
        WaitBetween=0.6, AutoClick=true, Keybind=Enum.KeyCode.G },
    ESP = { Enabled=false, ShowBox=true, ShowName=true, ShowHealth=true,
        ShowDistance=true, MaxDistance=1000, TeamCheck=true, Keybind=Enum.KeyCode.F },
    Speed = { Enabled=false, Value=50, Keybind=Enum.KeyCode.LeftShift },
}

-- ══════ COLORS ══════
local C = {
    BG        = Color3.fromRGB(8, 7, 2),
    Panel     = Color3.fromRGB(18, 15, 4),
    PanelHi   = Color3.fromRGB(28, 23, 6),
    Border    = Color3.fromRGB(255, 200, 40),
    Primary   = Color3.fromRGB(255, 200, 40),
    Secondary = Color3.fromRGB(255, 150, 0),
    Text      = Color3.fromRGB(255, 248, 220),
    TextDim   = Color3.fromRGB(160, 140, 80),
    On        = Color3.fromRGB(255, 200, 40),
    Off       = Color3.fromRGB(50, 42, 15),
    SliderBG  = Color3.fromRGB(35, 28, 8),
    Tab       = Color3.fromRGB(14, 12, 3),
}

-- ══════ GUI ROOT ══════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KukemPremium"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- ══════ HELPER UI ══════
local function corner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = p
    return c
end

local function stroke(p, color, thick, trans)
    local s = Instance.new("UIStroke")
    s.Color = color or C.Border
    s.Thickness = thick or 1
    s.Transparency = trans or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = p
    return s
end

local function gradient(p, c1, c2, rot)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new(c1, c2)
    g.Rotation = rot or 90
    g.Parent = p
    return g
end

-- ══════ MAIN ══════
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 440, 0, 320)
Main.Position = UDim2.new(0, 60, 0, 100)
Main.BackgroundColor3 = C.BG
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui
corner(Main, 12)
local mainStroke = stroke(Main, C.Border, 2, 0.1)
local mainGrad = gradient(Main, C.BG, C.PanelHi, 90)

-- Title
local Title = Instance.new("Frame")
Title.Size = UDim2.new(1, 0, 0, 44)
Title.BackgroundColor3 = C.Panel
Title.BorderSizePixel = 0
Title.Parent = Main
corner(Title, 12)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -110, 1, 0)
TitleLabel.Position = UDim2.new(0, 16, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "🌕  KUKEMPREMIUM"
TitleLabel.TextColor3 = C.Primary
TitleLabel.Font = Enum.Font.GothamBlack
TitleLabel.TextSize = 20
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = Title
local tg = gradient(TitleLabel, C.Primary, C.Secondary, 0)
tg.Enabled = false

-- Tab bar
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -16, 0, 32)
TabBar.Position = UDim2.new(0, 8, 0, 50)
TabBar.BackgroundColor3 = C.Tab
TabBar.BorderSizePixel = 0
TabBar.Parent = Main
corner(TabBar, 8)
stroke(TabBar, C.Border, 1, 0.7)

local TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabLayout.Padding = UDim.new(0, 4)
TabLayout.Parent = TabBar

local TabPad = Instance.new("UIPadding")
TabPad.PaddingLeft = UDim.new(0, 6)
TabPad.PaddingTop = UDim.new(0, 4)
TabPad.PaddingBottom = UDim.new(0, 4)
TabPad.Parent = TabBar

-- Content
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -16, 1, -90)
Content.Position = UDim2.new(0, 8, 0, 88)
Content.BackgroundTransparency = 1
Content.Parent = Main

local Pages = {}

local function createPage(name)
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, 0, 1, 0)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 3
    scroll.ScrollBarImageColor3 = C.Border
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.Visible = false
    scroll.Parent = Content

    local lay = Instance.new("UIListLayout")
    lay.SortOrder = Enum.SortOrder.LayoutOrder
    lay.Padding = UDim.new(0, 6)
    lay.Parent = scroll

    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 6)
    pad.PaddingRight = UDim.new(0, 6)
    pad.PaddingBottom = UDim.new(0, 8)
    pad.Parent = scroll

    Pages[name] = scroll
    return scroll
end

local activeTabBtn = nil
local function selectTab(name, btn)
    for n, p in pairs(Pages) do p.Visible = (n == name) end
    if activeTabBtn then
        TweenService:Create(activeTabBtn, TweenInfo.new(0.15), {BackgroundColor3 = C.Tab}):Play()
        activeTabBtn.TextColor3 = C.TextDim
    end
    activeTabBtn = btn
    if btn then
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = C.PanelHi}):Play()
        btn.TextColor3 = C.Primary
    end
end

local function addTab(name, label)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 80, 1, -8)
    btn.BackgroundColor3 = C.Tab
    btn.Text = label
    btn.TextColor3 = C.TextDim
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = TabBar
    corner(btn, 6)

    local page = createPage(name)

    btn.MouseButton1Click:Connect(function()
        selectTab(name, btn)
    end)

    btn.MouseEnter:Connect(function()
        if activeTabBtn ~= btn then
            TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = C.Panel}):Play()
        end
    end)
    btn.MouseLeave:Connect(function()
        if activeTabBtn ~= btn then
            TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = C.Tab}):Play()
        end
    end)

    return page
end

-- ══════ COMPONENTS ══════
local function section(parent, text)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 26)
    f.BackgroundTransparency = 1
    f.Parent = parent

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 1, 0)
    l.BackgroundTransparency = 1
    l.Text = "◆ " .. text
    l.TextColor3 = C.Primary
    l.Font = Enum.Font.GothamBlack
    l.TextSize = 13
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = f

    local ln = Instance.new("Frame")
    ln.Size = UDim2.new(1, 0, 0, 1)
    ln.Position = UDim2.new(0, 0, 1, -2)
    ln.BackgroundColor3 = C.Border
    ln.BackgroundTransparency = 0.5
    ln.BorderSizePixel = 0
    ln.Parent = f
end

local function toggle(parent, label, default, cb)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = C.Panel
    btn.Text = ""
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = parent
    corner(btn, 8)
    stroke(btn, C.Border, 1, 0.65)

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -80, 1, 0)
    l.Position = UDim2.new(0, 14, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = label
    l.TextColor3 = C.Text
    l.Font = Enum.Font.GothamMedium
    l.TextSize = 13
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = btn

    local st = Instance.new("TextLabel")
    st.Size = UDim2.new(0, 50, 0, 24)
    st.Position = UDim2.new(1, -58, 0.5, -12)
    st.BackgroundColor3 = default and C.On or C.Off
    st.Text = default and "ON" or "OFF"
    st.TextColor3 = default and C.BG or C.TextDim
    st.Font = Enum.Font.GothamBlack
    st.TextSize = 11
    st.BorderSizePixel = 0
    st.Parent = btn
    corner(st, 6)

    local v = default
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = C.PanelHi}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = C.Panel}):Play()
    end)
    btn.MouseButton1Click:Connect(function()
        v = not v
        st.Text = v and "ON" or "OFF"
        TweenService:Create(st, TweenInfo.new(0.15),
            {BackgroundColor3 = v and C.On or C.Off}):Play()
        st.TextColor3 = v and C.BG or C.TextDim
        if cb then cb(v) end
    end)
end

local function slider(parent, label, minV, maxV, default, suffix, cb)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 56)
    f.BackgroundColor3 = C.Panel
    f.BorderSizePixel = 0
    f.Parent = parent
    corner(f, 8)
    stroke(f, C.Border, 1, 0.65)

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -90, 0, 22)
    l.Position = UDim2.new(0, 14, 0, 6)
        l.BackgroundTransparency = 1
    l.Text = label
    l.TextColor3 = C.Text
    l.Font = Enum.Font.GothamMedium
    l.TextSize = 13
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = f

    local vl = Instance.new("TextLabel")
    vl.Size = UDim2.new(0, 70, 0, 22)
    vl.Position = UDim2.new(1, -80, 0, 6)
    vl.BackgroundTransparency = 1
    vl.Text = tostring(default) .. (suffix or "")
    vl.TextColor3 = C.Primary
    vl.Font = Enum.Font.GothamBlack
    vl.TextSize = 12
    vl.TextXAlignment = Enum.TextXAlignment.Right
    vl.Parent = f

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -28, 0, 6)
    track.Position = UDim2.new(0, 14, 0, 38)
    track.BackgroundColor3 = C.SliderBG
    track.BorderSizePixel = 0
    track.Parent = f
    corner(track, 3)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - minV)/(maxV - minV), 0, 1, 0)
    fill.BackgroundColor3 = C.Primary
    fill.BorderSizePixel = 0
    fill.Parent = track
    corner(fill, 3)
    gradient(fill, C.Primary, C.Secondary, 0)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = UDim2.new((default - minV)/(maxV - minV), -7, 0.5, -7)
    knob.BackgroundColor3 = C.Primary
    knob.BorderSizePixel = 0
    knob.ZIndex = 3
    knob.Parent = track
    corner(knob, 7)
    stroke(knob, C.Border, 1, 0)

    local dragging = false
    local function updateFromX(x)
        local rel = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local val
        if (maxV - minV) > 100 then
            val = math.floor(minV + rel * (maxV - minV))
        else
            val = math.floor((minV + rel * (maxV - minV)) * 10 + 0.5) / 10
        end
        fill.Size = UDim2.new(rel, 0, 1, 0)
        knob.Position = UDim2.new(rel, -7, 0.5, -7)
        vl.Text = tostring(val) .. (suffix or "")
        if cb then cb(val) end
    end

    track.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateFromX(i.Position.X)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            updateFromX(i.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

local function input(parent, label, default, cb)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 56)
    f.BackgroundColor3 = C.Panel
    f.BorderSizePixel = 0
    f.Parent = parent
    corner(f, 8)
    stroke(f, C.Border, 1, 0.65)

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -24, 0, 20)
    l.Position = UDim2.new(0, 14, 0, 4)
    l.BackgroundTransparency = 1
    l.Text = label
    l.TextColor3 = C.Text
    l.Font = Enum.Font.GothamMedium
    l.TextSize = 12
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = f

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -28, 0, 26)
    box.Position = UDim2.new(0, 14, 0, 24)
    box.BackgroundColor3 = C.BG
    box.Text = default
    box.TextColor3 = C.Primary
    box.Font = Enum.Font.GothamBold
    box.TextSize = 12
    box.BorderSizePixel = 0
    box.ClearTextOnFocus = false
    box.Parent = f
    corner(box, 6)
    stroke(box, C.Border, 1, 0.6)

    box.FocusLost:Connect(function() if cb then cb(box.Text) end end)
end

local function button(parent, label, cb)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 34)
    b.BackgroundColor3 = C.Panel
    b.Text = label
    b.TextColor3 = C.Primary
    b.Font = Enum.Font.GothamBold
    b.TextSize = 13
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    b.Parent = parent
    corner(b, 8)
    stroke(b, C.Border, 1, 0.5)

    b.MouseEnter:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = C.PanelHi}):Play()
    end)
    b.MouseLeave:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = C.Panel}):Play()
    end)
    b.MouseButton1Click:Connect(function() if cb then cb() end end)
end

-- ══════ HELPERS ══════
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
            local sp, on = Camera:WorldToViewportPoint(hrp.Position)
            if on then
                local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
                local mag = (Vector2.new(sp.X, sp.Y) - center).Magnitude
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
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {LocalPlayer.Character, part.Parent}
    local hit = Workspace:Raycast(origin, (part.Position - origin).Unit * 500, params)
    return hit == nil
end

-- ══════ BUILD UI ══════
local pageAim = addTab("aim", "AIM")
local pageSkill = addTab("skill", "SKILL")
local pageESP = addTab("esp", "ESP")
local pageSpeed = addTab("speed", "SPEED")
local pageInfo = addTab("info", "INFO")

-- AIM
section(pageAim, "SILENT AIM")
toggle(pageAim, "Bật Silent Aim", false, function(v) Config.SilentAim.Enabled = v end)
toggle(pageAim, "Kiểm tra đồng đội", true, function(v) Config.SilentAim.TeamCheck = v end)
toggle(pageAim, "Kiểm tra tường", false, function(v) Config.SilentAim.WallCheck = v end)
toggle(pageAim, "Hiển thị vòng FOV", true, function(v) Config.SilentAim.ShowFOV = v end)
slider(pageAim, "FOV", 20, 500, 140, "px", function(v) Config.SilentAim.FOV = v end)

-- SKILL
section(pageSkill, "AUTO SKILL")
toggle(pageSkill, "Bật Auto Skill", false, function(v)
    Config.AutoSkill.Enabled = v
    if v then task.spawn(autoSkillLoop) end
end)
toggle(pageSkill, "Auto Click", true, function(v) Config.AutoSkill.AutoClick = v end)
slider(pageSkill, "Delay skill", 0, 3, 0.6, "s", function(v) Config.AutoSkill.WaitBetween = v end)
input(pageSkill, "Danh sách phím (Z,X,C,V)", "Z,X,C,V", function(txt)
    local list = {}
    for k in string.gmatch(txt, "[^,]+") do table.insert(list, (k:gsub("%s+", ""))) end
    if #list > 0 then Config.AutoSkill.Skills = list end
end)

-- ESP
section(pageESP, "ESP")
toggle(pageESP, "Bật ESP", false, function(v) Config.ESP.Enabled = v end)
toggle(pageESP, "Hiển thị Box", true, function(v) Config.ESP.ShowBox = v end)
toggle(pageESP, "Hiển thị Tên", true, function(v) Config.ESP.ShowName = v end)
toggle(pageESP, "Hiển thị Máu", true, function(v) Config.ESP.ShowHealth = v end)
toggle(pageESP, "Hiển thị Khoảng cách", true, function(v) Config.ESP.ShowDistance = v end)
toggle(pageESP, "Kiểm tra đồng đội", true, function(v) Config.ESP.TeamCheck = v end)
slider(pageESP, "Khoảng cách tối đa", 100, 5000, 1000, "s", function(v) Config.ESP.MaxDistance = v end)

-- SPEED
section(pageSpeed, "SPEED HACK")
toggle(pageSpeed, "Bật Speed", false, function(v)
    Config.Speed.Enabled = v
    if not v then
        local hum = getMyHum()
        if hum then hum.WalkSpeed = 16 end
    end
end)
slider(pageSpeed, "WalkSpeed (1 - 1000)", 1, 1000, 50, " ws", function(v) Config.Speed.Value = v end)
button(pageSpeed, "Reset về 16", function()
    Config.Speed.Value = 16
    local hum = getMyHum()
    if hum then hum.WalkSpeed = 16 end
end)

-- INFO
section(pageInfo, "THÔNG TIN")
button(pageInfo, "Tắt toàn bộ chức năng", function()
    Config.SilentAim.Enabled = false
    Config.AutoSkill.Enabled = false
    Config.ESP.Enabled = false
    Config.Speed.Enabled = false
    local hum = getMyHum()
    if hum then hum.WalkSpeed = 16 end
end)
button(pageInfo, "Ẩn menu (RightControl)", function() ScreenGui.Enabled = false end)

selectTab("aim", TabBar:GetChildren()[1])

-- ══════ SILENT AIM HOOK (đầy đủ 4 method) ══════
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if Config.SilentAim.Enabled and (self == Workspace or self == Camera) then
        if method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList"
            or method == "FindPartOnRayWithWhitelist" or method == "Raycast" then
            local target = getNearestPlayer()
            if target and target.Character then
                local part = target.Character:FindFirstChild(Config.SilentAim.TargetPart)
                if part and isVisible(part) then
                    local args = {...}
                    local dir = (part.Position - Camera.CFrame.Position).Unit * 1000
                    if method == "Raycast" then
                        args[2] = dir
                    else
                        args[1] = Ray.new(Camera.CFrame.Position, dir)
                    end
                    return oldNamecall(self, unpack(args))
                end
            end
        end
    end
    return oldNamecall(self, ...)
end))

-- ══════ AUTO SKILL LOOP ══════
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

-- ══════ ESP SYSTEM (Drawing + fallback BillboardGui) ══════
local HAS_DRAWING = pcall(function() return Drawing.new end)
local espObjects = {}

local function createESP(player)
    if player == LocalPlayer then return end
    if HAS_DRAWING then
        local ok, obj = pcall(function()
            return {
                box = Drawing.new("Square"),
                name = Drawing.new("Text"),
                hp = Drawing.new("Text"),
                dist = Drawing.new("Text"),
            }
        end)
        if ok then
            obj.box.Visible=false; obj.box.Thickness=1; obj.box.Filled=false
            obj.box.Color = Color3.fromRGB(255, 200, 40)
            obj.name.Size=14; obj.name.Center=true; obj.name.Outline=true
            obj.name.Color = Color3.fromRGB(255, 248, 220); obj.name.Visible=false
            obj.hp.Size=14; obj.hp.Center=true; obj.hp.Outline=true
            obj.hp.Color = Color3.fromRGB(0, 255, 80); obj.hp.Visible=false
            obj.dist.Size=13; obj.dist.Center=true; obj.dist.Outline=true
            obj.dist.Color = Color3.fromRGB(255, 200, 40); obj.dist.Visible=false
            espObjects[player] = {type="drawing", data=obj}
            return
        end
    end
    -- Fallback BillboardGui
    local bb = Instance.new("BillboardGui")
    bb.Name = "KukemESP"
    bb.Size = UDim2.new(0, 100, 0, 60)
    bb.StudsOffset = Vector3.new(0, 3, 0)
    bb.AlwaysOnTop = true
    bb.Adornee = nil
    espObjects[player] = {type="bb", data=bb}
end

local function removeESP(player)
    local o = espObjects[player]
    if not o then return end
    if o.type == "drawing" then
        for _, v in pairs(o.data) do pcall(function() v:Remove() end) end
    else
        pcall(function() o.data:Destroy() end)
    end
    espObjects[player] = nil
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
            if show then
                local dst = (hrp.Position - Camera.CFrame.Position).Magnitude
                if dst > Config.ESP.MaxDistance then show = false end
            end
        end

        if o.type == "drawing" then
            local d = o.data
            if show then
                local sp, on = Camera:WorldToViewportPoint(hrp.Position)
                local hp2 = Camera:WorldToViewportPoint(head.Position)
                if not on then show = false end
                if show then
                    local h = math.abs(hp2.Y - sp.Y)
                    local w = h / 2
                    d.box.Size = Vector2.new(w, h)
                    d.box.Position = Vector2.new(sp.X - w/2, sp.Y - h/2)
                    d.box.Visible = Config.ESP.ShowBox
                    d.name.Text = p.Name
                    d.name.Position = Vector2.new(sp.X, sp.Y - h/2 - 22)
                    d.name.Visible = Config.ESP.ShowName
                    d.hp.Text = "HP " .. math.floor(hum.Health)
                    d.hp.Position = Vector2.new(sp.X, sp.Y - h/2 - 6)
                    d.hp.Visible = Config.ESP.ShowHealth
                    local dist = (hrp.Position - Camera.CFrame.Position).Magnitude
                    d.dist.Text = math.floor(dist) .. "s"
                    d.dist.Position = Vector2.new(sp.X, sp.Y + h/2 + 4)
                    d.dist.Visible = Config.ESP.ShowDistance
                end
            end
            if not show then
                for _, v in pairs(d) do v.Visible = false end
            end
        else
            local bb = o.data
            if show then
                if bb.Adornee ~= head then bb.Adornee = head end
                bb.Enabled = true
            else
                bb.Enabled = false
            end
        end
    end
end

-- ══════ MAIN LOOP ══════
local fovCircle = nil
if HAS_DRAWING then
    local ok, c = pcall(function() return Drawing.new("Circle") end)
    if ok then
        c.Thickness = 1.5; c.NumSides = 80; c.Filled = false
        c.Color = Color3.fromRGB(255, 200, 40); c.Visible = false
        fovCircle = c
    end
end

RunService.RenderStepped:Connect(function()
    if fovCircle then
        fovCircle.Radius = Config.SilentAim.FOV
        fovCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        fovCircle.Visible = Config.SilentAim.Enabled and Config.SilentAim.ShowFOV
    end
    updateESP()
    if Config.Speed.Enabled then
        local hum = getMyHum()
        if hum then hum.WalkSpeed = Config.Speed.Value end
    end
end)

-- ══════ KEYBIND ══════
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

-- ══════ INIT ESP ══════
for _, p in ipairs(Players:GetPlayers()) do createESP(p) end
Players.PlayerAdded:Connect(createESP)
Players.PlayerRemoving:Connect(removeESP)

print("[KukemPremium] Loaded — Tabs UI + SilentAim 4-hook + ESP fallback")
