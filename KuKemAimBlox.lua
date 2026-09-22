local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local Cam = Workspace.CurrentCamera
local LP = Players.LocalPlayer

local CFG = {
    Aim = { on=false, cam=false, team=true, wall=false, fov=150,
            part="Head", showFov=true, smooth=0.25, key=Enum.KeyCode.RightAlt },
    Skill = { on=false, keys={"Z","X","C","V"}, wait=0.6, click=true, key=Enum.KeyCode.G },
    ESP = { on=false, box=true, name=true, hp=true, dist=true, tracer=false,
            max=1500, team=true, key=Enum.KeyCode.F },
    Speed = { on=false, val=50, key=Enum.KeyCode.LeftShift },
}

-- ══ PALETTE (tím - cyan neon) ══
local P = {
    bg      = Color3.fromRGB(14, 12, 24),
    bg2     = Color3.fromRGB(20, 16, 36),
    panel   = Color3.fromRGB(26, 22, 48),
    hi      = Color3.fromRGB(38, 32, 68),
    accent  = Color3.fromRGB(170, 120, 255),   -- tím
    accent2 = Color3.fromRGB(90, 220, 255),    -- cyan
    txt     = Color3.fromRGB(240, 235, 255),
    dim     = Color3.fromRGB(140, 130, 180),
    off     = Color3.fromRGB(45, 40, 70),
    hpFull  = Color3.fromRGB(90, 255, 130),
    hpLow   = Color3.fromRGB(255, 80, 80),
    espBox  = Color3.fromRGB(170, 120, 255),
    espName = Color3.fromRGB(90, 220, 255),
    espDist = Color3.fromRGB(240, 235, 255),
}

local function corner(p,r)
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,r or 8); c.Parent = p
end
local function stroke(p,c,t,tr)
    local s = Instance.new("UIStroke")
    s.Color = c or P.accent; s.Thickness = t or 1; s.Transparency = tr or 0.4
    s.Parent = p
    return s
end
local function grad(p,c1,c2,rot)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new(c1, c2)
    g.Rotation = rot or 0
    g.Parent = p
    return g
end

-- ══ GUI ══
local gui = Instance.new("ScreenGui")
gui.Name = "Kukem"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() gui.Parent = CoreGui end)
if not gui.Parent then gui.Parent = LP:WaitForChild("PlayerGui") end

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 480, 0, 360)
Main.Position = UDim2.new(0, 60, 0, 100)
Main.BackgroundColor3 = P.bg
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = gui
corner(Main, 14)
local mStroke = stroke(Main, P.accent, 1.5, 0.3)
local mGrad = grad(Main, P.bg, P.bg2, 45)

-- Header
local Head = Instance.new("Frame")
Head.Size = UDim2.new(1, 0, 0, 46)
Head.BackgroundColor3 = P.panel
Head.BorderSizePixel = 0
Head.Parent = Main
corner(Head, 14)

local HeadGrad = Instance.new("Frame")
HeadGrad.Size = UDim2.new(1, 0, 0, 46)
HeadGrad.BackgroundColor3 = P.panel
HeadGrad.BorderSizePixel = 0
HeadGrad.BackgroundTransparency = 0
HeadGrad.Parent = Head
corner(HeadGrad, 14)
grad(HeadGrad, P.accent, P.accent2, 0)
HeadGrad.BackgroundTransparency = 0.85

local HeadTitle = Instance.new("TextLabel")
HeadTitle.Size = UDim2.new(1, -100, 1, 0)
HeadTitle.Position = UDim2.new(0, 16, 0, 0)
HeadTitle.BackgroundTransparency = 1
HeadTitle.Text = "✦ KUKEMPREMIUM"
HeadTitle.TextColor3 = P.txt
HeadTitle.Font = Enum.Font.GothamBlack
HeadTitle.TextSize = 20
HeadTitle.TextXAlignment = Enum.TextXAlignment.Left
HeadTitle.Parent = Head

local CloseB = Instance.new("TextButton")
CloseB.Size = UDim2.new(0, 30, 0, 30)
CloseB.Position = UDim2.new(1, -38, 0, 8)
CloseB.BackgroundColor3 = P.hi
CloseB.Text = "✕"
CloseB.TextColor3 = P.accent
CloseB.Font = Enum.Font.GothamBlack
CloseB.TextSize = 16
CloseB.BorderSizePixel = 0
CloseB.AutoButtonColor = false
CloseB.Parent = Head
corner(CloseB, 8)
CloseB.MouseButton1Click:Connect(function() gui.Enabled = false end)

-- Tabs
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -20, 0, 36)
TabBar.Position = UDim2.new(0, 10, 0, 54)
TabBar.BackgroundColor3 = P.panel
TabBar.BorderSizePixel = 0
TabBar.Parent = Main
corner(TabBar, 8)
stroke(TabBar, P.accent, 1, 0.6)

local TL = Instance.new("UIListLayout")
TL.FillDirection = Enum.FillDirection.Horizontal
TL.Padding = UDim.new(0, 4)
TL.SortOrder = Enum.SortOrder.LayoutOrder
TL.Parent = TabBar

local TP = Instance.new("UIPadding")
TP.PaddingLeft = UDim.new(0, 5); TP.PaddingTop = UDim.new(0, 4); TP.PaddingBottom = UDim.new(0, 4)
TP.Parent = TabBar

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -20, 1, -100)
Content.Position = UDim2.new(0, 10, 0, 96)
Content.BackgroundTransparency = 1
Content.Parent = Main

local Pages = {}
local TabBtns = {}

local function makePage()
    local s = Instance.new("ScrollingFrame")
    s.Size = UDim2.new(1, 0, 1, 0)
    s.BackgroundTransparency = 1
    s.BorderSizePixel = 0
    s.ScrollBarThickness = 3
    s.ScrollBarImageColor3 = P.accent
    s.CanvasSize = UDim2.new(0,0,0,0)
    s.AutomaticCanvasSize = Enum.AutomaticSize.Y
    s.Visible = false
    s.Parent = Content
    local l = Instance.new("UIListLayout")
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Padding = UDim.new(0, 6)
    l.Parent = s
    local p = Instance.new("UIPadding")
    p.PaddingTop = UDim.new(0, 6); p.PaddingRight = UDim.new(0, 4); p.PaddingBottom = UDim.new(0, 8)
    p.Parent = s
    return s
end

local function switchTab(n)
    for k, v in pairs(Pages) do v.Visible = (k == n) end
    for k, b in pairs(TabBtns) do
        b.BackgroundColor3 = (k == n) and P.hi or P.panel
        b.TextColor3 = (k == n) and P.accent or P.dim
    end
end

local function addTab(name, label)
    local p = makePage()
    Pages[name] = p
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 88, 1, -8)
    b.BackgroundColor3 = P.panel
    b.Text = label
    b.TextColor3 = P.dim
    b.Font = Enum.Font.GothamBlack
    b.TextSize = 13
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    b.Parent = TabBar
    corner(b, 6)
    TabBtns[name] = b
    b.MouseButton1Click:Connect(function() switchTab(name) end)
    return p
end

-- ══ COMPONENTS ══
local function section(parent, text)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 24)
    f.BackgroundTransparency = 1
    f.Parent = parent
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 1, 0)
    l.BackgroundTransparency = 1
    l.Text = "▸ " .. text
    l.TextColor3 = P.accent
    l.Font = Enum.Font.GothamBlack
    l.TextSize = 13
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = f
    local ln = Instance.new("Frame")
    ln.Size = UDim2.new(1, 0, 0, 1)
    ln.Position = UDim2.new(0, 0, 1, -2)
    ln.BackgroundColor3 = P.accent
    ln.BackgroundTransparency = 0.4
    ln.BorderSizePixel = 0
    ln.Parent = f
end

local function toggle(parent, label, default, cb)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = P.panel
    btn.Text = ""
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = parent
    corner(btn, 8)
    stroke(btn, P.accent, 1, 0.6)

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -80, 1, 0)
    l.Position = UDim2.new(0, 14, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = label
    l.TextColor3 = P.txt
    l.Font = Enum.Font.GothamMedium
    l.TextSize = 13
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = btn

    local sw = Instance.new("Frame")
    sw.Size = UDim2.new(0, 44, 0, 20)
    sw.Position = UDim2.new(1, -54, 0.5, -10)
    sw.BackgroundColor3 = default and P.accent or P.off
    sw.BorderSizePixel = 0
    sw.Parent = btn
    corner(sw, 10)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    knob.BackgroundColor3 = Color3.new(1,1,1)
    knob.BorderSizePixel = 0
    knob.Parent = sw
    corner(knob, 8)

    local v = default
    btn.MouseButton1Click:Connect(function()
        v = not v
        sw.BackgroundColor3 = v and P.accent or P.off
        knob.Position = v and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        if cb then pcall(cb, v) end
    end)
end

local function slider(parent, label, mn, mx, def, suf, cb)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 54)
    f.BackgroundColor3 = P.panel
    f.BorderSizePixel = 0
    f.Parent = parent
    corner(f, 8)
    stroke(f, P.accent, 1, 0.6)

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -90, 0, 20)
    l.Position = UDim2.new(0, 14, 0, 6)
    l.BackgroundTransparency = 1
    l.Text = label
    l.TextColor3 = P.txt
    l.Font = Enum.Font.GothamMedium
    l.TextSize = 13
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = f

    local vl = Instance.new("TextLabel")
    vl.Size = UDim2.new(0, 70, 0, 20)
    vl.Position = UDim2.new(1, -80, 0, 6)
    vl.BackgroundTransparency = 1
    vl.Text = tostring(def) .. (suf or "")
    vl.TextColor3 = P.accent2
    vl.Font = Enum.Font.GothamBlack
    vl.TextSize = 12
    vl.TextXAlignment = Enum.TextXAlignment.Right
    vl.Parent = f

    local tr = Instance.new("Frame")
    tr.Size = UDim2.new(1, -28, 0, 6)
    tr.Position = UDim2.new(0, 14, 0, 38)
    tr.BackgroundColor3 = P.off
    tr.BorderSizePixel = 0
    tr.Parent = f
    corner(tr, 3)

    local fl = Instance.new("Frame")
        fl.Size = UDim2.new((def-mn)/(mx-mn), 0, 1, 0)
    fl.BackgroundColor3 = P.accent
    fl.BorderSizePixel = 0
    fl.Parent = tr
    corner(fl, 3)
    grad(fl, P.accent, P.accent2, 0)

    local kb = Instance.new("Frame")
    kb.Size = UDim2.new(0, 14, 0, 14)
    kb.Position = UDim2.new((def-mn)/(mx-mn), -7, 0.5, -7)
    kb.BackgroundColor3 = Color3.new(1,1,1)
    kb.BorderSizePixel = 0
    kb.ZIndex = 3
    kb.Parent = tr
    corner(kb, 7)

    local drag = false
    local function upd(x)
        local rel = math.clamp((x - tr.AbsolutePosition.X) / tr.AbsoluteSize.X, 0, 1)
        local v
        if (mx-mn) > 50 then v = math.floor(mn + rel*(mx-mn))
        else v = math.floor((mn + rel*(mx-mn))*10 + 0.5)/10 end
        fl.Size = UDim2.new(rel, 0, 1, 0)
        kb.Position = UDim2.new(rel, -7, 0.5, -7)
        vl.Text = tostring(v) .. (suf or "")
        if cb then pcall(cb, v) end
    end
    tr.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag = true; upd(i.Position.X)
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            upd(i.Position.X)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = false end
    end)
end

local function input(parent, label, def, cb)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 54)
    f.BackgroundColor3 = P.panel
    f.BorderSizePixel = 0
    f.Parent = parent
    corner(f, 8)
    stroke(f, P.accent, 1, 0.6)

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -24, 0, 18)
    l.Position = UDim2.new(0, 14, 0, 4)
    l.BackgroundTransparency = 1
    l.Text = label
    l.TextColor3 = P.txt
    l.Font = Enum.Font.GothamMedium
    l.TextSize = 12
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = f

    local b = Instance.new("TextBox")
    b.Size = UDim2.new(1, -28, 0, 26)
    b.Position = UDim2.new(0, 14, 0, 24)
    b.BackgroundColor3 = P.bg
    b.Text = def
    b.TextColor3 = P.accent2
    b.Font = Enum.Font.GothamBold
    b.TextSize = 12
    b.BorderSizePixel = 0
    b.ClearTextOnFocus = false
    b.Parent = f
    corner(b, 6)
    stroke(b, P.accent, 1, 0.6)
    b.FocusLost:Connect(function() if cb then pcall(cb, b.Text) end end)
end

local function button(parent, label, cb)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 34)
    b.BackgroundColor3 = P.panel
    b.Text = label
    b.TextColor3 = P.accent
    b.Font = Enum.Font.GothamBold
    b.TextSize = 13
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    b.Parent = parent
    corner(b, 8)
    stroke(b, P.accent, 1, 0.5)
    b.MouseButton1Click:Connect(function() if cb then pcall(cb) end end)
end

-- ══ HELPERS ══
local function myHum()
    local c = LP.Character
    return c and c:FindFirstChildOfClass("Humanoid") or nil
end

local function valid(p)
    if p == LP or not p.Character then return false end
    local h = p.Character:FindFirstChildOfClass("Humanoid")
    local r = p.Character:FindFirstChild("HumanoidRootPart")
    if not h or not r or h.Health <= 0 then return false end
    if CFG.Aim.team and p.Team == LP.Team then return false end
    return true
end

local function nearest()
    local best, dist = nil, CFG.Aim.fov
    for _, p in ipairs(Players:GetPlayers()) do
        if valid(p) then
            local r = p.Character:FindFirstChild("HumanoidRootPart")
            local s, on = Cam:WorldToViewportPoint(r.Position)
            if on then
                local c = Vector2.new(Cam.ViewportSize.X/2, Cam.ViewportSize.Y/2)
                local m = (Vector2.new(s.X, s.Y) - c).Magnitude
                if m < dist then dist = m; best = p end
            end
        end
    end
    return best
end

local function visible(part)
    if not CFG.Aim.wall then return true end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {LP.Character, part.Parent}
    return Workspace:Raycast(Cam.CFrame.Position, (part.Position - Cam.CFrame.Position).Unit * 500, params) == nil
end

-- ══ BUILD ══
local aimP = addTab("AIM", "AIM")
local skillP = addTab("SKILL", "SKILL")
local espP = addTab("ESP", "ESP")
local spdP = addTab("SPEED", "SPEED")
local infoP = addTab("INFO", "INFO")

section(aimP, "SILENT AIM")
toggle(aimP, "Bật Silent Aim", false, function(v) CFG.Aim.on = v end)
toggle(aimP, "Camera Lock (aim thật)", false, function(v) CFG.Aim.cam = v end)
toggle(aimP, "Team Check", true, function(v) CFG.Aim.team = v end)
toggle(aimP, "Wall Check", false, function(v) CFG.Aim.wall = v end)
toggle(aimP, "Hiện FOV", true, function(v) CFG.Aim.showFov = v end)
slider(aimP, "FOV", 20, 600, 150, "px", function(v) CFG.Aim.fov = v end)
slider(aimP, "Camera Smooth", 0.05, 1, 0.25, "", function(v) CFG.Aim.smooth = v end)

section(skillP, "AUTO SKILL")
toggle(skillP, "Bật Auto Skill", false, function(v)
    CFG.Skill.on = v
    if v then task.spawn(skillLoop) end
end)
toggle(skillP, "Auto Click", true, function(v) CFG.Skill.click = v end)
slider(skillP, "Delay", 0, 3, 0.6, "s", function(v) CFG.Skill.wait = v end)
input(skillP, "Phím (Z,X,C,V)", "Z,X,C,V", function(t)
    local l = {}
    for k in string.gmatch(t, "[^,]+") do table.insert(l, (k:gsub("%s+",""))) end
    if #l > 0 then CFG.Skill.keys = l end
end)

section(espP, "ESP")
toggle(espP, "Bật ESP", false, function(v) CFG.ESP.on = v end)
toggle(espP, "Box", true, function(v) CFG.ESP.box = v end)
toggle(espP, "Tên", true, function(v) CFG.ESP.name = v end)
toggle(espP, "Thanh máu", true, function(v) CFG.ESP.hp = v end)
toggle(espP, "Khoảng cách", true, function(v) CFG.ESP.dist = v end)
toggle(espP, "Tracer (đường nối)", false, function(v) CFG.ESP.tracer = v end)
toggle(espP, "Team Check", true, function(v) CFG.ESP.team = v end)
slider(espP, "Max Distance", 100, 5000, 1500, "s", function(v) CFG.ESP.max = v end)

section(spdP, "SPEED")
toggle(spdP, "Bật Speed", false, function(v)
    CFG.Speed.on = v
    if not v then local h = myHum(); if h then h.WalkSpeed = 16 end end
end)
slider(spdP, "WalkSpeed", 1, 1000, 50, " ws", function(v) CFG.Speed.val = v end)
button(spdP, "Reset 16", function()
    CFG.Speed.val = 16
    local h = myHum(); if h then h.WalkSpeed = 16 end
end)

section(infoP, "INFO")
button(infoP, "Tắt toàn bộ", function()
    CFG.Aim.on = false; CFG.Skill.on = false
    CFG.ESP.on = false; CFG.Speed.on = false
    local h = myHum(); if h then h.WalkSpeed = 16 end
end)
button(infoP, "Ẩn menu (RightControl)", function() gui.Enabled = false end)

switchTab("AIM")

-- ══ CAMERA LOCK ══
RunService.RenderStepped:Connect(function(dt)
    if CFG.Aim.on and CFG.Aim.cam then
        local t = nearest()
        if t and t.Character then
            local part = t.Character:FindFirstChild(CFG.Aim.part)
            if part and visible(part) then
                local target = CFrame.new(Cam.CFrame.Position, part.Position)
                Cam.CFrame = Cam.CFrame:Lerp(target, math.clamp(CFG.Aim.smooth * (dt * 60), 0, 1))
            end
        end
    end
end)

-- ══ SILENT AIM HOOK ══
pcall(function()
    local mt = getrawmetatable(game)
    local old = mt.__namecall
    setreadonly(mt, false)
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if CFG.Aim.on and (method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList"
            or method == "FindPartOnRayWithWhitelist" or method == "Raycast") then
            local t = nearest()
            if t and t.Character then
                local p = t.Character:FindFirstChild(CFG.Aim.part)
                if p and visible(p) then
                    local a = {...}
                    local d = (p.Position - Cam.CFrame.Position).Unit * 1000
                    if method == "Raycast" then a[2] = d
                    else a[1] = Ray.new(Cam.CFrame.Position, d) end
                    return old(self, unpack(a))
                end
            end
        end
        return old(self, ...)
    end)
    setreadonly(mt, true)
end)

-- ══ AUTO SKILL ══
function skillLoop()
    while CFG.Skill.on do
        if myHum() then
            for _, k in ipairs(CFG.Skill.keys) do
                if not CFG.Skill.on then break end
                local vk = Enum.KeyCode[k]
                if vk then keypress(vk); task.wait(0.05); keyrelease(vk) end
                task.wait(CFG.Skill.wait)
            end
            if CFG.Skill.click then mouse1click(); task.wait(0.1) end
        end
        task.wait(0.1)
    end
end

-- ══ ESP PRO ══
local HAS_DRAW = pcall(function() local d = Drawing.new("Square"); d:Remove() end)
local list = {}

local function mkESP(p)
    if p == LP then return end
    if HAS_DRAW then
        local ok, d = pcall(function()
            return {
                box = Drawing.new("Square"),
                tl = Drawing.new("Line"), tr = Drawing.new("Line"),
                bl = Drawing.new("Line"), br = Drawing.new("Line"),
                hpBg = Drawing.new("Square"),
                hpFill = Drawing.new("Square"),
                nm = Drawing.new("Text"),
                dst = Drawing.new("Text"),
                tracer = Drawing.new("Line"),
            }
        end)
        if ok then
            d.box.Filled = false; d.box.Thickness = 1; d.box.Color = P.espBox
            d.box.Visible = false
            for _, k in ipairs({"tl","tr","bl","br"}) do
                d[k].Thickness = 2; d[k].Color = P.espBox; d[k].Visible = false
            end
            d.hpBg.Filled = true; d.hpBg.Color = Color3.fromRGB(20,20,20)
            d.hpBg.Visible = false
            d.hpFill.Filled = true; d.hpFill.Color = P.hpFull
            d.hpFill.Visible = false
            d.nm.Size = 14; d.nm.Center = true; d.nm.Outline = true
            d.nm.Color = P.espName; d.nm.Visible = false
            d.dst.Size = 13; d.dst.Center = true; d.dst.Outline = true
            d.dst.Color = P.espDist; d.dst.Visible = false
            d.tracer.Thickness = 1; d.tracer.Color = P.espBox; d.tracer.Visible = false
            list[p] = {t = "d", d = d}
            return
        end
    end
    -- fallback BillboardGui
    local bb = Instance.new("BillboardGui")
    bb.Size = UDim2.new(0, 100, 0, 60)
    bb.StudsOffset = Vector3.new(0, 3, 0)
    bb.AlwaysOnTop = true
    bb.Enabled = false
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 1, 0)
    l.BackgroundTransparency = 1
    l.Text = p.Name
    l.TextColor3 = P.espName
    l.TextStrokeTransparency = 0
    l.Font = Enum.Font.GothamBold
    l.TextSize = 14
    l.Parent = bb
    list[p] = {t = "bb", d = bb}
end

local function rmESP(p)
    local o = list[p]
    if not o then return end
    if o.t == "d" then
        for _, v in pairs(o.d) do pcall(function() v:Remove() end) end
    else
        pcall(function() o.d:Destroy() end)
    end
    list[p] = nil
end

local function updateESP()
    for p, o in pairs(list) do
        local show = CFG.ESP.on and p.Character ~= nil
        local hrp, head, hum, dst
        if show then
            hrp = p.Character:FindFirstChild("HumanoidRootPart")
            head = p.Character:FindFirstChild("Head")
            hum = p.Character:FindFirstChildOfClass("Humanoid")
            if not (hrp and head and hum and hum.Health > 0) then show = false end
            if CFG.ESP.team and p.Team == LP.Team then show = false end
            if show then
                dst = (hrp.Position - Cam.CFrame.Position).Magnitude
                if dst > CFG.ESP.max then show = false end
            end
        end

        if o.t == "d" then
            local d = o.d
            if show then
                local sp, on = Cam:WorldToViewportPoint(hrp.Position)
                local hs = Cam:WorldToViewportPoint(head.Position)
                if on then
                    local h = math.abs(hs.Y - sp.Y)
                    local w = h / 2
                    local x, y = sp.X - w/2, sp.Y - h/2

                    if CFG.ESP.box then
                        -- khung đầy đủ (mờ)
                        d.box.Size = Vector2.new(w, h)
                        d.box.Position = Vector2.new(x, y)
                        d.box.Visible = true
                        -- khung góc (đậm)
                        local cl = math.min(w, h) * 0.25
                        d.tl.From = Vector2.new(x, y); d.tl.To = Vector2.new(x + cl, y)
                        d.tr.From = Vector2.new(x + w, y); d.tr.To = Vector2.new(x + w - cl, y)
                        d.bl.From = Vector2.new(x, y + h); d.bl.To = Vector2.new(x + cl, y + h)
                        d.br.From = Vector2.new(x + w, y + h); d.br.To = Vector2.new(x + w - cl, y + h)
                        for _, k in ipairs({"tl","tr","bl","br"}) do d[k].Visible = true end
                        -- dọc 2 bên góc
                        local vt, vb = y, y + cl
                        d.tl.From = Vector2.new(x, vt); d.tl.To = Vector2.new(x, y + cl)
                        d.tr.From = Vector2.new(x + w, vt); d.tr.To = Vector2.new(x + w, y + cl)
                        d.bl.From = Vector2.new(x, y + h - cl); d.bl.To = Vector2.new(x, y + h)
                        d.br.From = Vector2.new(x + w, y + h - cl); d.br.To = Vector2.new(x + w, y + h)
                    else
                        d.box.Visible = false
                        for _, k in ipairs({"tl","tr","bl","br"}) do d[k].Visible = false end
                    end

                    if CFG.ESP.hp then
                        local ratio = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                        local barW, barH = 3, h
                        local bx, by = x - 6, y
                        d.hpBg.Size = Vector2.new(barW, barH)
                        d.hpBg.Position = Vector2.new(bx, by)
                        d.hpBg.Visible = true
                        local fh = barH * ratio
                        d.hpFill.Size = Vector2.new(barW, fh)
                        d.hpFill.Position = Vector2.new(bx, by + (barH - fh))
                        d.hpFill.Color = P.hpLow:Lerp(P.hpFull, ratio)
                        d.hpFill.Visible = true
                    else
                        d.hpBg.Visible = false; d.hpFill.Visible = false
                    end

                    d.nm.Text = p.Name .. "  [" .. math.floor(hum.Health) .. "]"
                    d.nm.Position = Vector2.new(sp.X, y - 20)
                    d.nm.Visible = CFG.ESP.name

                    d.dst.Text = math.floor(dst) .. " studs"
                    d.dst.Position = Vector2.new(sp.X, y + h + 4)
                    d.dst.Visible = CFG.ESP.dist

                    if CFG.ESP.tracer then
                        d.tracer.From = Vector2.new(Cam.ViewportSize.X/2, Cam.ViewportSize.Y)
                        d.tracer.To = Vector2.new(sp.X, y + h)
                        d.tracer.Visible = true
                    else
                        d.tracer.Visible = false
                    end
                else
                    for _, v in pairs(d) do v.Visible = false end
                end
            else
                for _, v in pairs(d) do v.Visible = false end
            end
        else
            local bb = o.d
            if show then bb.Adornee = head; bb.Enabled = true
            else bb.Enabled = false end
        end
    end
end

-- ══ MAIN LOOP ══
local fovC = nil
if HAS_DRAW then
    pcall(function()
        fovC = Drawing.new("Circle")
        fovC.Thickness = 1.5
        fovC.NumSides = 90
        fovC.Filled = false
        fovC.Color = P.accent
        fovC.Visible = false
    end)
end

RunService.RenderStepped:Connect(function()
    if fovC then
        fovC.Radius = CFG.Aim.fov
        fovC.Position = Vector2.new(Cam.ViewportSize.X/2, Cam.ViewportSize.Y/2)
        fovC.Visible = CFG.Aim.on and CFG.Aim.showFov
    end
    updateESP()
    if CFG.Speed.on then
        local h = myHum()
        if h then h.WalkSpeed = CFG.Speed.val end
    end
end)

-- ══ KEYBINDS ══
UIS.InputBegan:Connect(function(i, gpe)
    if gpe then return end
    if i.KeyCode == CFG.Aim.key then CFG.Aim.on = not CFG.Aim.on
    elseif i.KeyCode == CFG.ESP.key then CFG.ESP.on = not CFG.ESP.on
    elseif i.KeyCode == CFG.Skill.key then
        CFG.Skill.on = not CFG.Skill.on
        if CFG.Skill.on then task.spawn(skillLoop) end
    elseif i.KeyCode == CFG.Speed.key then
        CFG.Speed.on = not CFG.Speed.on
        if not CFG.Speed.on then local h = myHum(); if h then h.WalkSpeed = 16 end end
    elseif i.KeyCode == Enum.KeyCode.RightControl then
        gui.Enabled = not gui.Enabled
    end
end)

for _, p in ipairs(Players:GetPlayers()) do mkESP(p) end
Players.PlayerAdded:Connect(mkESP)
Players.PlayerRemoving:Connect(rmESP)

print("[Kukem] Loaded — Drawing:", HAS_DRAW)
