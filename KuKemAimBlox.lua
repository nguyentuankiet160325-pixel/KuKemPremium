local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local WS = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local Cam = WS.CurrentCamera
local LP = Players.LocalPlayer

local CFG = {
    Aim = {
        on = false, team = true, wall = false, fov = 200,
        part = "Head", smooth = 0.25, showFov = true,
        key = Enum.KeyCode.RightAlt,
    },
    ESP = {
        on = false, box = true, corner = true, name = true,
        hp = true, dist = true, tracer = false, glow = true,
        maxDist = 1500, team = true, key = Enum.KeyCode.F,
    },
    Hitbox = {
        on = false, size = 15, team = true,
        transparent = true, key = Enum.KeyCode.H,
    },
}

-- ═══════════ PALETTE ═══════════
local P = {
    bg      = Color3.fromRGB(12, 10, 2),
    bg2     = Color3.fromRGB(20, 16, 4),
    panel   = Color3.fromRGB(28, 23, 6),
    hi      = Color3.fromRGB(40, 33, 8),
    accent  = Color3.fromRGB(255, 200, 40),
    accent2 = Color3.fromRGB(255, 150, 0),
    txt     = Color3.fromRGB(255, 248, 220),
    dim     = Color3.fromRGB(160, 140, 80),
    off     = Color3.fromRGB(50, 42, 15),
    espBox  = Color3.fromRGB(255, 200, 40),
    espGlow = Color3.fromRGB(255, 150, 0),
    espName = Color3.fromRGB(255, 220, 100),
    espHP   = Color3.fromRGB(80, 255, 120),
    espHPLow= Color3.fromRGB(255, 80, 80),
    espDist = Color3.fromRGB(255, 240, 180),
    tracer  = Color3.fromRGB(255, 200, 40),
}

local function corner(p, r)
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 8); c.Parent = p
end
local function stroke(p, col, t, tr)
    local s = Instance.new("UIStroke")
    s.Color = col or P.accent; s.Thickness = t or 1
    s.Transparency = tr or 0.4; s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = p
    return s
end
local function grad(p, c1, c2, rot)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new(c1, c2); g.Rotation = rot or 0
    g.Parent = p
    return g
end

-- ═══════════ GUI ═══════════
local gui = Instance.new("ScreenGui")
gui.Name = "KuKemPremium Vn"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset = true
pcall(function() gui.Parent = CoreGui end)
if not gui.Parent then gui.Parent = LP:WaitForChild("PlayerGui") end

local FloatBtn = Instance.new("TextButton")
FloatBtn.Size = UDim2.new(0, 52, 0, 52)
FloatBtn.Position = UDim2.new(0, 20, 0.5, -26)
FloatBtn.BackgroundColor3 = P.panel
FloatBtn.Text = "√"
FloatBtn.TextColor3 = P.accent
FloatBtn.TextSize = 26
FloatBtn.Font = Enum.Font.GothamBlack
FloatBtn.BorderSizePixel = 0
FloatBtn.AutoButtonColor = false
FloatBtn.Active = true
FloatBtn.Parent = gui
corner(FloatBtn, 26)
stroke(FloatBtn, P.accent, 2, 0.2)

do
    local drag = false
    local dragStart, startPos
    FloatBtn.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag = true
            dragStart = i.Position
            startPos = FloatBtn.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then drag = false end
            end)
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - dragStart
            FloatBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
end

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 500, 0, 360)
Main.Position = UDim2.new(0.5, -250, 0.5, -180)
Main.BackgroundColor3 = P.bg
Main.BorderSizePixel = 0
Main.Active = true
Main.Visible = false
Main.Parent = gui
corner(Main, 16)
stroke(Main, P.accent, 2, 0.25)
grad(Main, P.bg, P.bg2, 45)

do
    local drag = false
    local dragStart, startPos
    Main.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag = true
            dragStart = i.Position
            startPos = Main.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then drag = false end
            end)
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
end

local Head = Instance.new("Frame")
Head.Size = UDim2.new(1, 0, 0, 56)
Head.BackgroundColor3 = P.panel
Head.BorderSizePixel = 0
Head.Parent = Main
corner(Head, 16)

local HeadGlow = Instance.new("Frame")
HeadGlow.Size = UDim2.new(1, 0, 1, 0)
HeadGlow.BackgroundColor3 = P.accent
HeadGlow.BackgroundTransparency = 0.85
HeadGlow.BorderSizePixel = 0
HeadGlow.ZIndex = 1
HeadGlow.Parent = Head
corner(HeadGlow, 16)
grad(HeadGlow, P.accent, P.accent2, 0)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -100, 0, 26)
Title.Position = UDim2.new(0, 16, 0, 8)
Title.BackgroundTransparency = 1
Title.Text = " KuKemPremium "
Title.TextColor3 = P.accent
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 20
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 3
Title.Parent = Head

local Sub = Instance.new("TextLabel")
Sub.Size = UDim2.new(1, -100, 0, 18)
Sub.Position = UDim2.new(0, 16, 0, 32)
Sub.BackgroundTransparency = 1
Sub.Text = "Aimbot · ESP · Hitbox"
Sub.TextColor3 = P.dim
Sub.Font = Enum.Font.Gotham
Sub.TextSize = 11
Sub.TextXAlignment = Enum.TextXAlignment.Left
Sub.ZIndex = 3
Sub.Parent = Head

local CloseB = Instance.new("TextButton")
CloseB.Size = UDim2.new(0, 32, 0, 32)
CloseB.Position = UDim2.new(1, -42, 0, 12)
CloseB.BackgroundColor3 = P.hi
CloseB.Text = "✕"
CloseB.TextColor3 = P.accent
CloseB.Font = Enum.Font.GothamBlack
CloseB.TextSize = 18
CloseB.BorderSizePixel = 0
CloseB.AutoButtonColor = false
CloseB.ZIndex = 5
CloseB.Parent = Head
corner(CloseB, 8)
CloseB.MouseButton1Click:Connect(function() Main.Visible = false end)

local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -20, 0, 40)
TabBar.Position = UDim2.new(0, 10, 0, 64)
TabBar.BackgroundColor3 = P.panel
TabBar.BorderSizePixel = 0
TabBar.Parent = Main
corner(TabBar, 10)
stroke(TabBar, P.accent, 1, 0.55)

local TL = Instance.new("UIListLayout")
TL.FillDirection = Enum.FillDirection.Horizontal
TL.Padding = UDim.new(0, 5)
TL.SortOrder = Enum.SortOrder.LayoutOrder
TL.VerticalAlignment = Enum.VerticalAlignment.Center
TL.Parent = TabBar

local TP = Instance.new("UIPadding")
TP.PaddingLeft = UDim.new(0, 6)
TP.Parent = TabBar

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -20, 1, -116)
Content.Position = UDim2.new(0, 10, 0, 112)
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
    s.CanvasSize = UDim2.new(0, 0, 0, 0)
    s.AutomaticCanvasSize = Enum.AutomaticSize.Y
    s.Visible = false
    s.Parent = Content
    local l = Instance.new("UIListLayout")
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Padding = UDim.new(0, 8)
    l.Parent = s
    local p = Instance.new("UIPadding")
    p.PaddingTop = UDim.new(0, 8); p.PaddingRight = UDim.new(0, 6); p.PaddingBottom = UDim.new(0, 12)
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
    b.Size = UDim2.new(0, 105, 0, 32)
    b.BackgroundColor3 = P.panel
    b.Text = label
    b.TextColor3 = P.dim
    b.Font = Enum.Font.GothamBlack
    b.TextSize = 13
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    b.Parent = TabBar
    corner(b, 8)
    TabBtns[name] = b
    b.MouseButton1Click:Connect(function() switchTab(name) end)
    return p
end

local function section(parent, text)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 26)
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
end

local function toggle(parent, label, default, cb)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 42)
    btn.BackgroundColor3 = P.panel
    btn.Text = ""
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = parent
    corner(btn, 10)
    stroke(btn, P.accent, 1, 0.55)

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -90, 1, 0)
    l.Position = UDim2.new(0, 16, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = label
    l.TextColor3 = P.txt
    l.Font = Enum.Font.GothamMedium
    l.TextSize = 14
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = btn

    local sw = Instance.new("Frame")
    sw.Size = UDim2.new(0, 52, 0, 26)
    sw.Position = UDim2.new(1, -64, 0.5, -13)
    sw.BackgroundColor3 = default and P.accent or P.off
    sw.BorderSizePixel = 0
    sw.Parent = btn
    corner(sw, 13)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 22, 0, 22)
    knob.Position = default and UDim2.new(1, -24, 0.5, -11) or UDim2.new(0, 2, 0.5, -11)
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    knob.BorderSizePixel = 0
    knob.Parent = sw
    corner(knob, 11)

    local v = default
    btn.MouseButton1Click:Connect(function()
        v = not v
        sw.BackgroundColor3 = v and P.accent or P.off
        knob.Position = v and UDim2.new(1, -24, 0.5, -11) or UDim2.new(0, 2, 0.5, -11)
        if cb then pcall(cb, v) end
    end)
end

local function slider(parent, label, mn, mx, def, suf, cb)
        local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 60)
    f.BackgroundColor3 = P.panel
    f.BorderSizePixel = 0
    f.Parent = parent
    corner(f, 10)
    stroke(f, P.accent, 1, 0.55)

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -100, 0, 22)
    l.Position = UDim2.new(0, 16, 0, 8)
    l.BackgroundTransparency = 1
    l.Text = label
    l.TextColor3 = P.txt
    l.Font = Enum.Font.GothamMedium
    l.TextSize = 13
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = f

    local vl = Instance.new("TextLabel")
    vl.Size = UDim2.new(0, 80, 0, 22)
    vl.Position = UDim2.new(1, -90, 0, 8)
    vl.BackgroundTransparency = 1
    vl.Text = tostring(def) .. (suf or "")
    vl.TextColor3 = P.accent2
    vl.Font = Enum.Font.GothamBlack
    vl.TextSize = 13
    vl.TextXAlignment = Enum.TextXAlignment.Right
    vl.Parent = f

    local tr = Instance.new("Frame")
    tr.Size = UDim2.new(1, -32, 0, 8)
    tr.Position = UDim2.new(0, 16, 0, 40)
    tr.BackgroundColor3 = P.off
    tr.BorderSizePixel = 0
    tr.Parent = f
    corner(tr, 4)

    local fl = Instance.new("Frame")
    fl.Size = UDim2.new((def - mn) / (mx - mn), 0, 1, 0)
    fl.BackgroundColor3 = P.accent
    fl.BorderSizePixel = 0
    fl.Parent = tr
    corner(fl, 4)
    grad(fl, P.accent, P.accent2, 0)

    local kb = Instance.new("Frame")
    kb.Size = UDim2.new(0, 18, 0, 18)
    kb.Position = UDim2.new((def - mn) / (mx - mn), -9, 0.5, -9)
    kb.BackgroundColor3 = Color3.new(1, 1, 1)
    kb.BorderSizePixel = 0
    kb.ZIndex = 3
    kb.Parent = tr
    corner(kb, 9)
    stroke(kb, P.accent, 1, 0.3)

    local drag = false
    local function upd(x)
        local rel = math.clamp((x - tr.AbsolutePosition.X) / tr.AbsoluteSize.X, 0, 1)
        local v = mn + rel * (mx - mn)
        if (mx - mn) > 50 then v = math.floor(v) else v = math.floor(v * 100) / 100 end
        fl.Size = UDim2.new(rel, 0, 1, 0)
        kb.Position = UDim2.new(rel, -9, 0.5, -9)
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
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag = false
        end
    end)
end

local function dropdown(parent, label, options, def, cb)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 42)
    f.BackgroundColor3 = P.panel
    f.BorderSizePixel = 0
    f.ClipsDescendants = true
    f.Parent = parent
    corner(f, 10)
    stroke(f, P.accent, 1, 0.55)

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -140, 1, 0)
    l.Position = UDim2.new(0, 16, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = label
    l.TextColor3 = P.txt
    l.Font = Enum.Font.GothamMedium
    l.TextSize = 13
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = f

    local sel = Instance.new("TextButton")
    sel.Size = UDim2.new(0, 110, 0, 28)
    sel.Position = UDim2.new(1, -120, 0.5, -14)
    sel.BackgroundColor3 = P.hi
    sel.Text = def
    sel.TextColor3 = P.accent
    sel.Font = Enum.Font.GothamBold
    sel.TextSize = 12
    sel.BorderSizePixel = 0
    sel.AutoButtonColor = false
    sel.Parent = f
    corner(sel, 6)

    local opts = {}
    local open = false
    local baseH = 42
    for i, opt in ipairs(options) do
        local ob = Instance.new("TextButton")
        ob.Size = UDim2.new(1, -16, 0, 28)
        ob.Position = UDim2.new(0, 8, 0, baseH + (i - 1) * 28)
        ob.BackgroundColor3 = P.hi
        ob.Text = opt
        ob.TextColor3 = P.txt
        ob.Font = Enum.Font.Gotham
        ob.TextSize = 12
        ob.BorderSizePixel = 0
        ob.Visible = false
        ob.AutoButtonColor = false
        ob.Parent = f
        corner(ob, 6)
        ob.MouseButton1Click:Connect(function()
            sel.Text = opt
            open = false
            f.Size = UDim2.new(1, 0, 0, baseH)
            for _, o in pairs(opts) do o.Visible = false end
            if cb then pcall(cb, opt) end
        end)
        table.insert(opts, ob)
    end

    sel.MouseButton1Click:Connect(function()
        open = not open
        f.Size = UDim2.new(1, 0, 0, open and (baseH + #options * 28 + 8) or baseH)
        for _, o in pairs(opts) do o.Visible = open end
    end)
end

local function button(parent, label, cb)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 36)
    b.BackgroundColor3 = P.panel
    b.Text = label
    b.TextColor3 = P.accent
    b.Font = Enum.Font.GothamBold
    b.TextSize = 13
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    b.Parent = parent
    corner(b, 10)
    stroke(b, P.accent, 1, 0.5)
    b.MouseButton1Click:Connect(function() if cb then pcall(cb) end end)
end

-- ═══════════ HELPERS ═══════════
local function isTeammate(plr)
    if plr == LP then return true end
    if plr.Team and LP.Team and plr.Team == LP.Team then return true end
    if plr.TeamColor and LP.TeamColor and plr.TeamColor == LP.TeamColor then return true end
    return false
end

local function getParts(plr)
    if plr == LP or not plr.Character then return nil end
    local c = plr.Character
    local hum = c:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return nil end
    local hrp = c:FindFirstChild("HumanoidRootPart")
    local head = c:FindFirstChild("Head")
    if not hrp or not head then return nil end
    return { hum = hum, hrp = hrp, head = head, char = c }
end

local function valid(plr)
    local p = getParts(plr)
    if not p then return false end
    if CFG.Aim.team and isTeammate(plr) then return false end
    return true
end

local function visible(part)
    if not CFG.Aim.wall then return true end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {LP.Character, part.Parent}
    return WS:Raycast(Cam.CFrame.Position, (part.Position - Cam.CFrame.Position).Unit * 500, params) == nil
end

local function nearestInFov()
    local best, dist = nil, CFG.Aim.fov
    for _, plr in ipairs(Players:GetPlayers()) do
        if valid(plr) then
            local p = getParts(plr)
            local sp, on = Cam:WorldToViewportPoint(p.hrp.Position)
            if on then
                local ctr = Vector2.new(Cam.ViewportSize.X / 2, Cam.ViewportSize.Y / 2)
                local d = (Vector2.new(sp.X, sp.Y) - ctr).Magnitude
                if d < dist then dist = d; best = plr end
            end
        end
    end
    return best
end

-- ═══════════ HITBOX EXPANDER ═══════════
local hitboxModified = {}   -- plr -> {part -> original size}

local function expandHitbox(plr)
    if plr == LP or not plr.Character then return end
    local size = CFG.Hitbox.size
    local targets = {"HumanoidRootPart", "Head", "UpperTorso", "LowerTorso", "Torso"}

    if not hitboxModified[plr] then
        hitboxModified[plr] = {}
    end

    for _, name in ipairs(targets) do
        local part = plr.Character:FindFirstChild(name)
        if part and part:IsA("BasePart") then
            if not hitboxModified[plr][part] then
                hitboxModified[plr][part] = part.Size
            end
            if name == "HumanoidRootPart" then
                part.Size = Vector3.new(size, size, size)
            elseif name == "Head" then
                part.Size = Vector3.new(size * 0.6, size * 0.6, size * 0.6)
            else
                part.Size = Vector3.new(size, size * 1.5, size * 0.7)
            end
            part.Transparency = CFG.Hitbox.transparent and 0.7 or part.Transparency
            part.CanCollide = false
            part.Massless = true
        end
    end
end

local function restoreHitbox(plr)
    local saved = hitboxModified[plr]
    if not saved then return end
    for part, origSize in pairs(saved) do
        if part and part.Parent then
            pcall(function()
                part.Size = origSize
                part.Transparency = 0
                part.CanCollide = true
                part.Massless = false
            end)
        end
    end
    hitboxModified[plr] = nil
end

local function updateHitbox()
    if not CFG.Hitbox.on then
        for plr in pairs(hitboxModified) do
            restoreHitbox(plr)
        end
        return
    end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LP then continue end
        if not plr.Character then continue end
        if CFG.Hitbox.team and isTeammate(plr) then
            restoreHitbox(plr)
            continue
        end
        expandHitbox(plr)
    end
    -- Cleanup player đã rời
    for plr in pairs(hitboxModified) do
        if not plr.Parent or not plr.Character then
            hitboxModified[plr] = nil
        end
    end
end

RunService.Heartbeat:Connect(updateHitbox)

-- ═══════════ BUILD UI ═══════════
local aimP = addTab("AIM", "🎯 AIMBOT")
local espP = addTab("ESP", "👁️ ESP")
local hbP = addTab("HITBOX", "🎯 HITBOX")
local infoP = addTab("INFO", "ℹ️ INFO")

section(aimP, "AIMBOT (CAMERA LOCK)")
toggle(aimP, "Bật Aimbot", false, function(v) CFG.Aim.on = v end)
toggle(aimP, "Team Check", true, function(v) CFG.Aim.team = v end)
toggle(aimP, "Wall Check", false, function(v) CFG.Aim.wall = v end)
toggle(aimP, "Hiện FOV Circle", true, function(v) CFG.Aim.showFov = v end)
slider(aimP, "FOV", 20, 800, 200, "px", function(v) CFG.Aim.fov = v end)
slider(aimP, "Smooth", 0.02, 1, 0.25, "", function(v) CFG.Aim.smooth = v end)
dropdown(aimP, "Vị trí ngắm", {"Head", "HumanoidRootPart", "UpperTorso"}, "Head", function(v) CFG.Aim.part = v end)

section(espP, "ESP")
toggle(espP, "Bật ESP", false, function(v) CFG.ESP.on = v end)
toggle(espP, "Box", true, function(v) CFG.ESP.box = v end)
toggle(espP, "Khung góc", true, function(v) CFG.ESP.corner = v end)
toggle(espP, "Glow", true, function(v) CFG.ESP.glow = v end)
toggle(espP, "Tên", true, function(v) CFG.ESP.name = v end)
toggle(espP, "Máu", true, function(v) CFG.ESP.hp = v end)
toggle(espP, "Khoảng cách", true, function(v) CFG.ESP.dist = v end)
toggle(espP, "Tracer", false, function(v) CFG.ESP.tracer = v end)
toggle(espP, "Team Check", true, function(v) CFG.ESP.team = v end)
slider(espP, "Max Distance", 100, 5000, 1500, "s", function(v) CFG.ESP.maxDist = v end)

section(hbP, "HITBOX EXPANDER")
toggle(hbP, "Bật Expand Hitbox", false, function(v) CFG.Hitbox.on = v end)
toggle(hbP, "Team Check", true, function(v) CFG.Hitbox.team = v end)
toggle(hbP, "Làm mờ hitbox (transparent)", true, function(v) CFG.Hitbox.transparent = v end)
slider(hbP, "Kích thước", 5, 50, 15, " studs", function(v) CFG.Hitbox.size = v end)
button(hbP, "Reset Hitbox ngay", function()
    for plr in pairs(hitboxModified) do
        restoreHitbox(plr)
    end
end)

section(infoP, "THÔNG TIN")
button(infoP, "Tắt toàn bộ", function()
    CFG.Aim.on = false
    CFG.ESP.on = false
    CFG.Hitbox.on = false
    for plr in pairs(hitboxModified) do restoreHitbox(plr) end
end)
button(infoP, "Ẩn menu (RightControl)", function() gui.Enabled = false end)

switchTab("AIM")

-- ═══════════ CAMERA LOCK ═══════════
RunService.RenderStepped:Connect(function(dt)
    if not CFG.Aim.on then return end
    local t = nearestInFov()
    if not t or not t.Character then return end
    local part = t.Character:FindFirstChild(CFG.Aim.part)
    if not part or not visible(part) then return end
    local goal = CFrame.new(Cam.CFrame.Position, part.Position)
    Cam.CFrame = Cam.CFrame:Lerp(goal, math.clamp(CFG.Aim.smooth * (dt * 60), 0, 1))
end)

-- ═══════════ ESP SYSTEM ═══════════
local HAS_DRAW = pcall(function() local d = Drawing.new("Square"); d:Remove() end)
local espList = {}

local function makeESP(plr)
    if plr == LP or not HAS_DRAW then return end
    local ok, d = pcall(function()
        return {
            boxGlow = Drawing.new("Square"),
            box = Drawing.new("Square"),
            tl = Drawing.new("Line"), tr = Drawing.new("Line"),
            bl = Drawing.new("Line"), br = Drawing.new("Line"),
            hpBg = Drawing.new("Square"), hpFill = Drawing.new("Square"),
            name = Drawing.new("Text"), dist = Drawing.new("Text"),
            tracer = Drawing.new("Line"),
        }
    end)
    if not ok then return end

    d.boxGlow.Filled = false; d.boxGlow.Thickness = 4
    d.boxGlow.Color = P.espGlow; d.boxGlow.Transparency = 0.5; d.boxGlow.Visible = false

    d.box.Filled = false; d.box.Thickness = 1.5
    d.box.Color = P.espBox; d.box.Transparency = 0.9; d.box.Visible = false

    for _, k in ipairs({"tl", "tr", "bl", "br"}) do
        d[k].Thickness = 2.5; d[k].Color = P.espBox
        d[k].Transparency = 1; d[k].Visible = false
    end

    d.hpBg.Filled = true; d.hpBg.Color = Color3.fromRGB(15, 12, 4)
    d.hpBg.Transparency = 0.4; d.hpBg.Visible = false
    d.hpFill.Filled = true; d.hpFill.Color = P.espHP
    d.hpFill.Transparency = 1; d.hpFill.Visible = false

    d.name.Size = 15; d.name.Center = true; d.name.Outline = true
    d.name.Color = P.espName; d.name.Visible = false; d.name.Font = 3

    d.dist.Size = 13; d.dist.Center = true; d.dist.Outline = true
    d.dist.Color = P.espDist; d.dist.Visible = false; d.dist.Font = 3

    d.tracer.Thickness = 1.5; d.tracer.Color = P.tracer
    d.tracer.Transparency = 0.7; d.tracer.Visible = false

    espList[plr] = d
end

local function dropESP(plr)
    local d = espList[plr]
    if not d then return end
    for _, v in pairs(d) do pcall(function() v:Remove() end) end
    espList[plr] = nil
end

local function updateESP()
    for plr, d in pairs(espList) do
        local show = CFG.ESP.on and plr.Character ~= nil
        local p
        if show then
            p = getParts(plr)
            if not p then show = false end
            if show and CFG.ESP.team and isTeammate(plr) then show = false end
            if show then
                local dist = (p.hrp.Position - Cam.CFrame.Position).Magnitude
                if dist > CFG.ESP.maxDist then show = false end
            end
        end

        if not show then
            for _, v in pairs(d) do v.Visible = false end
            continue
        end

        local sp, on = Cam:WorldToViewportPoint(p.hrp.Position)
        local hp2 = Cam:WorldToViewportPoint(p.head.Position)
        if not on then
            for _, v in pairs(d) do v.Visible = false end
            continue
        end

        local h = math.abs(hp2.Y - sp.Y) * 1.6
        local w = h * 0.55
        local x, y = sp.X - w / 2, sp.Y - h / 2

        d.boxGlow.Size = Vector2.new(w + 8, h + 8)
        d.boxGlow.Position = Vector2.new(x - 4, y - 4)
        d.boxGlow.Visible = CFG.ESP.glow and CFG.ESP.box

        d.box.Size = Vector2.new(w, h)
        d.box.Position = Vector2.new(x, y)
        d.box.Visible = CFG.ESP.box

        local cl = math.min(w, h) * 0.28
        d.tl.From = Vector2.new(x, y); d.tl.To = Vector2.new(x, y + cl)
        d.tr.From = Vector2.new(x + w, y); d.tr.To = Vector2.new(x + w, y + cl)
        d.bl.From = Vector2.new(x, y + h - cl); d.bl.To = Vector2.new(x, y + h)
        d.br.From = Vector2.new(x + w, y + h - cl); d.br.To = Vector2.new(x + w, y + h)

        for _, k in ipairs({"tl", "tr", "bl", "br"}) do
            d[k].Visible = CFG.ESP.corner
        end

        if CFG.ESP.hp then
            local ratio = math.clamp(p.hum.Health / p.hum.MaxHealth, 0, 1)
            local barW, barH = 4, h
            d.hpBg.Size = Vector2.new(barW, barH)
            d.hpBg.Position = Vector2.new(x - 8, y)
            d.hpBg.Visible = true
            local fh = barH * ratio
            d.hpFill.Size = Vector2.new(barW, fh)
            d.hpFill.Position = Vector2.new(x - 8, y + (barH - fh))
            d.hpFill.Color = P.espHPLow:Lerp(P.espHP, ratio)
            d.hpFill.Visible = true
        else
            d.hpBg.Visible = false
            d.hpFill.Visible = false
        end

        d.name.Text = plr.Name .. "  [" .. math.floor(p.hum.Health) .. "]"
        d.name.Position = Vector2.new(sp.X, y - 22)
        d.name.Visible = CFG.ESP.name

        local dist = (p.hrp.Position - Cam.CFrame.Position).Magnitude
        d.dist.Text = math.floor(dist) .. " studs"
        d.dist.Position = Vector2.new(sp.X, y + h + 5)
        d.dist.Visible = CFG.ESP.dist

        if CFG.ESP.tracer then
            d.tracer.From = Vector2.new(Cam.ViewportSize.X / 2, Cam.ViewportSize.Y)
            d.tracer.To = Vector2.new(sp.X, y + h)
            d.tracer.Visible = true
        else
            d.tracer.Visible = false
        end
    end
end

RunService.RenderStepped:Connect(updateESP)

for _, p in ipairs(Players:GetPlayers()) do makeESP(p) end
Players.PlayerAdded:Connect(makeESP)
Players.PlayerRemoving:Connect(function(plr)
    dropESP(plr)
    restoreHitbox(plr)
end)

-- ═══════════ FOV CIRCLE ═══════════
local fovCircle = nil
if HAS_DRAW then
    pcall(function()
        fovCircle = Drawing.new("Circle")
        fovCircle.Thickness = 2
        fovCircle.NumSides = 90
        fovCircle.Filled = false
        fovCircle.Color = P.accent
        fovCircle.Transparency = 0.7
        fovCircle.Visible = false
    end)
end

RunService.RenderStepped:Connect(function()
    if not fovCircle then return end
    fovCircle.Radius = CFG.Aim.fov
    fovCircle.Position = Vector2.new(Cam.ViewportSize.X / 2, Cam.ViewportSize.Y / 2)
    fovCircle.Visible = CFG.Aim.on and CFG.Aim.showFov
end)

-- ═══════════ KEYBIND ═══════════
FloatBtn.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)

UIS.InputBegan:Connect(function(i, gpe)
    if gpe then return end
    if i.KeyCode == CFG.Aim.key then
        CFG.Aim.on = not CFG.Aim.on
    elseif i.KeyCode == CFG.ESP.key then
        CFG.ESP.on = not CFG.ESP.on
    elseif i.KeyCode == CFG.Hitbox.key then
        CFG.Hitbox.on = not CFG.Hitbox.on
    elseif i.KeyCode == Enum.KeyCode.RightControl then
        Main.Visible = not Main.Visible
    end
end)

print("[KuKemPremium] Loaded — Aimbot + ESP + Hitbox")
