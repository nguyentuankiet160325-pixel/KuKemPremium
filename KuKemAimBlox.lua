local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local WS = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local LP = Players.LocalPlayer
local Cam = WS.CurrentCamera

-- ═══════════ CONFIG ═══════════
local CFG = {
    Aim = {
        on = false, mode = "Camera",  -- Camera | Silent | Both
        team = true, wall = false, vis = false,
        fov = 200, part = "Head", smooth = 0.25,
        predict = 0.15, key = Enum.KeyCode.RightAlt, showFov = true,
    },
    ESP = {
        on = false, box = true, corner = true, name = true,
        hp = true, dist = true, tracer = false, skeleton = false,
        chams = false, maxDist = 2000, team = true,
        key = Enum.KeyCode.F,
    },
    Misc = {
        on = true, key = Enum.KeyCode.RightControl,
    },
}

-- ═══════════ PALETTE ═══════════
local P = {
    bg      = Color3.fromRGB(10, 8, 18),
    bg2     = Color3.fromRGB(16, 12, 28),
    panel   = Color3.fromRGB(22, 18, 40),
    hi      = Color3.fromRGB(34, 26, 58),
    accent  = Color3.fromRGB(170, 120, 255),
    accent2 = Color3.fromRGB(90, 220, 255),
    txt     = Color3.fromRGB(240, 235, 255),
    dim     = Color3.fromRGB(140, 130, 180),
    off     = Color3.fromRGB(42, 36, 68),
    espBox  = Color3.fromRGB(170, 120, 255),
    espName = Color3.fromRGB(90, 220, 255),
    espHP   = Color3.fromRGB(90, 255, 130),
    espHPLow= Color3.fromRGB(255, 80, 80),
    tracer  = Color3.fromRGB(90, 220, 255),
}

local function corner(p, r)
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 8); c.Parent = p
end
local function stroke(p, col, t, tr)
    local s = Instance.new("UIStroke")
    s.Color = col or P.accent; s.Thickness = t or 1
    s.Transparency = tr or 0.5; s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = p
    return s
end
local function grad(p, c1, c2, rot)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new(c1, c2); g.Rotation = rot or 0
    g.Parent = p
    return g
end

-- ═══════════ GUI ROOT ═══════════
local gui = Instance.new("ScreenGui")
gui.Name = "KukemPremium"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() gui.Parent = CoreGui end)
if not gui.Parent then gui.Parent = LP:WaitForChild("PlayerGui") end

-- ═══════════ MAIN FRAME ═══════════
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 480, 0, 360)
Main.Position = UDim2.new(0, 60, 0, 100)
Main.BackgroundColor3 = P.bg
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = gui
corner(Main, 14)
stroke(Main, P.accent, 2, 0.3)
grad(Main, P.bg, P.bg2, 45)

-- Header với glow
local Head = Instance.new("Frame")
Head.Size = UDim2.new(1, 0, 0, 48)
Head.BackgroundColor3 = P.panel
Head.BorderSizePixel = 0
Head.Parent = Main
corner(Head, 14)

local HeadGlow = Instance.new("Frame")
HeadGlow.Size = UDim2.new(1, 0, 1, 0)
HeadGlow.BackgroundColor3 = P.accent
HeadGlow.BackgroundTransparency = 0.9
HeadGlow.BorderSizePixel = 0
HeadGlow.Parent = Head
corner(HeadGlow, 14)
grad(HeadGlow, P.accent, P.accent2, 0)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -100, 1, 0)
Title.Position = UDim2.new(0, 18, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "✦ KUKEMPREMIUM"
Title.TextColor3 = P.accent
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 20
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Head

local Sub = Instance.new("TextLabel")
Sub.Size = UDim2.new(0, 200, 0, 14)
Sub.Position = UDim2.new(1, -110, 0.5, -7)
Sub.BackgroundTransparency = 1
Sub.Text = "ESP · AIMBOT · ALL GAMES"
Sub.TextColor3 = P.dim
Sub.Font = Enum.Font.Gotham
Sub.TextSize = 10
Sub.TextXAlignment = Enum.TextXAlignment.Right
Sub.Parent = Head

local CloseB = Instance.new("TextButton")
CloseB.Size = UDim2.new(0, 30, 0, 30)
CloseB.Position = UDim2.new(1, -38, 0, 9)
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

-- Tab bar
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -20, 0, 38)
TabBar.Position = UDim2.new(0, 10, 0, 56)
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
TP.PaddingLeft = UDim.new(0, 5); TP.PaddingTop = UDim.new(0, 5); TP.PaddingBottom = UDim.new(0, 5)
TP.Parent = TabBar

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -20, 1, -104)
Content.Position = UDim2.new(0, 10, 0, 100)
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
    b.Size = UDim2.new(0, 90, 1, 0)
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

-- ═══════════ COMPONENTS ═══════════
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
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
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
    fl.Size = UDim2.new((def - mn) / (mx - mn), 0, 1, 0)
    fl.BackgroundColor3 = P.accent
    fl.BorderSizePixel = 0
    fl.Parent = tr
    corner(fl, 3)
    grad(fl, P.accent, P.accent2, 0)

    local kb = Instance.new("Frame")
    kb.Size = UDim2.new(0, 14, 0, 14)
    kb.Position = UDim2.new((def - mn) / (mx - mn), -7, 0.5, -7)
    kb.BackgroundColor3 = Color3.new(1, 1, 1)
    kb.BorderSizePixel = 0
    kb.ZIndex = 3
    kb.Parent = tr
    corner(kb, 7)

    local drag = false
    local function upd(x)
        local rel = math.clamp((x - tr.AbsolutePosition.X) / tr.AbsoluteSize.X, 0, 1)
        local v = mn + rel * (mx - mn)
        if (mx - mn) > 50 then v = math.floor(v) else v = math.floor(v * 100) / 100 end
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
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag = false
        end
    end)
end

local function dropdown(parent, label, options, def, cb)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 34)
    f.BackgroundColor3 = P.panel
    f.BorderSizePixel = 0
    f.ClipsDescendants = true
    f.Parent = parent
    corner(f, 8)
    stroke(f, P.accent, 1, 0.6)

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -120, 1, 0)
    l.Position = UDim2.new(0, 14, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = label
    l.TextColor3 = P.txt
    l.Font = Enum.Font.GothamMedium
    l.TextSize = 13
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = f

    local sel = Instance.new("TextButton")
    sel.Size = UDim2.new(0, 100, 0, 24)
    sel.Position = UDim2.new(1, -108, 0.5, -12)
    sel.BackgroundColor3 = P.hi
    sel.Text = def
    sel.TextColor3 = P.accent
    sel.Font = Enum.Font.GothamBold
    sel.TextSize = 12
    sel.BorderSizePixel = 0
    sel.Parent = f
    corner(sel, 6)

    local opts = {}
    local open = false
    local baseH = 34
    for i, opt in ipairs(options) do
        local ob = Instance.new("TextButton")
        ob.Size = UDim2.new(1, -12, 0, 28)
        ob.Position = UDim2.new(0, 6, 0, baseH + (i - 1) * 28)
        ob.BackgroundColor3 = P.hi
        ob.Text = opt
        ob.TextColor3 = P.txt
        ob.Font = Enum.Font.Gotham
        ob.TextSize = 12
        ob.BorderSizePixel = 0
        ob.Visible = false
        ob.Parent = f
        corner(ob, 4)
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
        f.Size = UDim2.new(1, 0, 0, open and (baseH + #options * 28 + 6) or baseH)
        for _, o in pairs(opts) do o.Visible = open end
    end)
end

-- ═══════════ HELPERS ═══════════
local function myChar() return LP.Character end
local function myHRP() local c = myChar(); return c and c:FindFirstChild("HumanoidRootPart") end
local function myHum() local c = myChar(); return c and c:FindFirstChildOfClass("Humanoid") end

local function getParts(plr)
    if plr == LP or not plr.Character then return nil end
    local c = plr.Character
    local hum = c:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return nil end
    local hrp = c:FindFirstChild("HumanoidRootPart")
    local head = c:FindFirstChild("Head") or (c:FindFirstChild("UpperTorso") and c:FindFirstChild("Head"))
    if not hrp or not head then return nil end
    return { hum = hum, hrp = hrp, head = head, char = c }
end

local function valid(plr)
    local p = getParts(plr)
    if not p then return false end
    if CFG.Aim.team and plr.Team and plr.Team == LP.Team then return false end
    return true
end

local function visible(part)
    if not CFG.Aim.wall then return true end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {myChar(), part.Parent}
    return WS:Raycast(Cam.CFrame.Position, (part.Position - Cam.CFrame.Position).Unit * 500, params) == nil
end

local function nearestInFov()
    local best, bestDist = nil, CFG.Aim.fov
    for _, plr in ipairs(Players:GetPlayers()) do
        if valid(plr) then
            local p = getParts(plr)
            local sp, on = Cam:WorldToViewportPoint(p.hrp.Position)
            if on then
                local ctr = Vector2.new(Cam.ViewportSize.X / 2, Cam.ViewportSize.Y / 2)
                local d = (Vector2.new(sp.X, sp.Y) - ctr).Magnitude
                if d < bestDist then bestDist = d; best = plr end
            end
        end
    end
    return best
end

-- Prediction
local function predict(plr, part)
    if CFG.Aim.predict <= 0 then return part.Position end
    local p = getParts(plr)
    if not p then return part.Position end
    local vel = p.hrp.AssemblyLinearVelocity or Vector3.new()
    return part.Position + vel * CFG.Aim.predict
end

-- ═══════════ BUILD UI ═══════════
local aimP = addTab("AIM", "🎯 AIM")
local espP = addTab("ESP", "👁️ ESP")
local visP = addTab("VISUAL", "✨ VISUAL")
local infoP = addTab("INFO", "ℹ️ INFO")

-- AIM TAB
section(aimP, "AIMBOT")
toggle(aimP, "Bật Aimbot", false, function(v) CFG.Aim.on = v end)
dropdown(aimP, "Chế độ", { "Camera", "Silent", "Both" }, "Camera", function(v) CFG.Aim.mode = v end)
dropdown(aimP, "Vị trí ngắm", { "Head", "HumanoidRootPart", "UpperTorso", "LowerTorso" }, "Head", function(v) CFG.Aim.part = v end)
slider(aimP, "FOV", 20, 800, 200, "px", function(v) CFG.Aim.fov = v end)
slider(aimP, "Smooth (Camera)", 0.02, 1, 0.25, "", function(v) CFG.Aim.smooth = v end)
slider(aimP, "Prediction", 0, 0.5, 0.15, "s", function(v) CFG.Aim.predict = v end)
toggle(aimP, "Team Check", true, function(v) CFG.Aim.team = v end)
toggle(aimP, "Wall Check", false, function(v) CFG.Aim.wall = v end)
toggle(aimP, "Hiện FOV Circle", true, function(v) CFG.Aim.showFov = v end)

-- ESP TAB
section(espP, "ESP")
toggle(espP, "Bật ESP", false, function(v) CFG.ESP.on = v end)
toggle(espP, "Box viền", true, function(v) CFG.ESP.box = v end)
toggle(espP, "Khung góc (corner)", true, function(v) CFG.ESP.corner = v end)
toggle(espP, "Tên", true, function(v) CFG.ESP.name = v end)
toggle(espP, "Thanh máu", true, function(v) CFG.ESP.hp = v end)
toggle(espP, "Khoảng cách", true, function(v) CFG.ESP.dist = v end)
toggle(espP, "Tracer", false, function(v) CFG.ESP.tracer = v end)
toggle(espP, "Skeleton", false, function(v) CFG.ESP.skeleton = v end)
toggle(espP, "Team Check", true, function(v) CFG.ESP.team = v end)
slider(espP, "Max Distance", 100, 5000, 2000, "s", function(v) CFG.ESP.maxDist = v end)

-- VISUAL TAB
section(visP, "TÙY CHỈNH")
toggle(visP, "Full Bright", false, function(v)
    if v then
        game:GetService("Lighting").Ambient = Color3.fromRGB(255, 255, 255)
        game:GetService("Lighting").Brightness = 3
    else
        game:GetService("Lighting").Ambient = Color3.fromRGB(70, 70, 70)
        game:GetService("Lighting").Brightness = 1
    end
end)
toggle(visP, "No Fog", false, function(v)
    if v then game:GetService("Lighting").FogEnd = 1e6 else game:GetService("Lighting").FogEnd = 100000 end
end)
toggle(visP, "Xuyên tường (Camera clip)", false, function(v)
    LP.CameraMaxZoomDistance = v and 1e6 or 128
end)

-- INFO TAB
section(infoP, "THÔNG TIN")
local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(1, 0, 0, 80)
infoLabel.BackgroundColor3 = P.panel
infoLabel.Text = "✦ KukemPremium\nUniversal ESP + Aimbot\nRightAlt: Aim · F: ESP · RightCtrl: Ẩn menu"
infoLabel.TextColor3 = P.txt
infoLabel.Font = Enum.Font.GothamMedium
infoLabel.TextSize = 13
infoLabel.TextWrapped = true
infoLabel.Parent = infoP
corner(infoLabel, 8)
stroke(infoLabel, P.accent, 1, 0.6)

switchTab("AIM")

-- ═══════════ AIM LOOPS ═══════════
RunService.RenderStepped:Connect(function(dt)
    if not CFG.Aim.on then return end
    if CFG.Aim.mode ~= "Camera" and CFG.Aim.mode ~= "Both" then return end
    local t = nearestInFov()
    if not t then return end
    local p = getParts(t)
    if not p then return end
    local target = p.char:FindFirstChild(CFG.Aim.part) or p.head
    if not target or not visible(target) then return end
    local aimPos = predict(t, target)
    local goal = CFrame.new(Cam.CFrame.Position, aimPos)
    local alpha = math.clamp(CFG.Aim.smooth * (dt * 60), 0, 1)
    Cam.CFrame = Cam.CFrame:Lerp(goal, alpha)
end)

-- Silent aim hook
pcall(function()
    local mt = getrawmetatable(game)
    local old = mt.__namecall
    setreadonly(mt, false)
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if CFG.Aim.on and (CFG.Aim.mode == "Silent" or CFG.Aim.mode == "Both")
            and (method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList"
                 or method == "FindPartOnRayWithWhitelist" or method == "Raycast") then
            local t = nearestInFov()
            if t then
                local p = getParts(t)
                if p then
                    local target = p.char:FindFirstChild(CFG.Aim.part) or p.head
                    if target and visible(target) then
                        local a = {...}
                        local aimPos = predict(t, target)
                        local dir = (aimPos - Cam.CFrame.Position).Unit * 1500
                        if method == "Raycast" then a[2] = dir
                        else a[1] = Ray.new(Cam.CFrame.Position, dir) end
                        return old(self, unpack(a))
                    end
                end
            end
        end
        return old(self, ...)
    end)
    setreadonly(mt, true)
    print("[Kukem] Silent aim hook OK")
end)

-- ═══════════ FOV CIRCLE ═══════════
local HAS_DRAW = pcall(function() local d = Drawing.new("Square"); d:Remove() end)
local fovCircle = nil
if HAS_DRAW then
    pcall(function()
        fovCircle = Drawing.new("Circle")
        fovCircle.Thickness = 1.5
        fovCircle.NumSides = 90
        fovCircle.Filled = false
        fovCircle.Color = P.accent
        fovCircle.Transparency = 0.6
        fovCircle.Visible = false
    end)
end

RunService.RenderStepped:Connect(function()
    if not fovCircle then return end
    fovCircle.Radius = CFG.Aim.fov
    fovCircle.Position = Vector2.new(Cam.ViewportSize.X / 2, Cam.ViewportSize.Y / 2)
    fovCircle.Visible = CFG.Aim.on and CFG.Aim.showFov
end)

-- ═══════════ ESP SYSTEM ═══════════
local espList = {}

local function makeESP(plr)
    if plr == LP then return end
    if not HAS_DRAW then return end
    local ok, d = pcall(function()
        return {
            box = Drawing.new("Square"),
            tl = Drawing.new("Line"), tr = Drawing.new("Line"),
            bl = Drawing.new("Line"), br = Drawing.new("Line"),
            hpBg = Drawing.new("Square"), hpFill = Drawing.new("Square"),
            name = Drawing.new("Text"), dist = Drawing.new("Text"),
            tracer = Drawing.new("Line"),
        }
    end)
    if not ok then return end

    d.box.Filled = false; d.box.Thickness = 1; d.box.Color = P.espBox; d.box.Visible = false
    d.box.Transparency = 0.5

    for _, k in ipairs({"tl", "tr", "bl", "br"}) do
        d[k].Thickness = 2; d[k].Color = P.espBox; d[k].Visible = false; d[k].Transparency = 1
    end

    d.hpBg.Filled = true; d.hpBg.Color = Color3.fromRGB(15, 15, 25); d.hpBg.Visible = false
    d.hpBg.Transparency = 0.6
    d.hpFill.Filled = true; d.hpFill.Color = P.espHP; d.hpFill.Visible = false
    d.hpFill.Transparency = 1

    d.name.Size = 14; d.name.Center = true; d.name.Outline = true
    d.name.Color = P.espName; d.name.Visible = false; d.name.Font = 3

    d.dist.Size = 13; d.dist.Center = true; d.dist.Outline = true
    d.dist.Color = P.txt; d.dist.Visible = false; d.dist.Font = 3

    d.tracer.Thickness = 1.5; d.tracer.Color = P.tracer; d.tracer.Visible = false
    d.tracer.Transparency = 0.8

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
            if show and CFG.ESP.team and plr.Team and plr.Team == LP.Team then show = false end
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

        -- Box
        d.box.Size = Vector2.new(w, h)
        d.box.Position = Vector2.new(x, y)
        d.box.Visible = CFG.ESP.box

        -- Corner brackets
        local cl = math.min(w, h) * 0.28
        d.tl.From = Vector2.new(x, y); d.tl.To = Vector2.new(x + cl, y)
        d.tr.From = Vector2.new(x + w, y); d.tr.To = Vector2.new(x + w - cl, y)
        d.bl.From = Vector2.new(x, y + h); d.bl.To = Vector2.new(x + cl, y + h)
        d.br.From = Vector2.new(x + w, y + h); d.br.To = Vector2.new(x + w - cl, y + h)
        -- vertical strokes
        d.tl.From = Vector2.new(x, y); d.tl.To = Vector2.new(x, y + cl)
        d.tr.From = Vector2.new(x + w, y); d.tr.To = Vector2.new(x + w, y + cl)
        d.bl.From = Vector2.new(x, y + h - cl); d.bl.To = Vector2.new(x, y + h)
        d.br.From = Vector2.new(x + w, y + h - cl); d.br.To = Vector2.new(x + w, y + h)

        for _, k in ipairs({"tl", "tr", "bl", "br"}) do
            d[k].Visible = CFG.ESP.corner
        end

        -- HP bar
        if CFG.ESP.hp then
            local ratio = math.clamp(p.hum.Health / p.hum.MaxHealth, 0, 1)
            local barW, barH = 3, h
            d.hpBg.Size = Vector2.new(barW, barH)
            d.hpBg.Position = Vector2.new(x - 6, y)
            d.hpBg.Visible = true
            local fh = barH * ratio
            d.hpFill.Size = Vector2.new(barW, fh)
            d.hpFill.Position = Vector2.new(x - 6, y + (barH - fh))
            d.hpFill.Color = P.espHPLow:Lerp(P.espHP, ratio)
            d.hpFill.Visible = true
        else
            d.hpBg.Visible = false
            d.hpFill.Visible = false
        end

        -- Name + HP
        d.name.Text = plr.Name .. "  [" .. math.floor(p.hum.Health) .. "]"
        d.name.Position = Vector2.new(sp.X, y - 20)
        d.name.Visible = CFG.ESP.name

        -- Distance
        local dist = (p.hrp.Position - Cam.CFrame.Position).Magnitude
        d.dist.Text = math.floor(dist) .. " studs"
        d.dist.Position = Vector2.new(sp.X, y + h + 4)
        d.dist.Visible = CFG.ESP.dist

        -- Tracer
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
Players.PlayerRemoving:Connect(dropESP)

-- ═══════════ KEYBINDS ═══════════
UIS.InputBegan:Connect(function(i, gpe)
    if gpe then return end
    if i.KeyCode == CFG.Aim.key then
        CFG.Aim.on = not CFG.Aim.on
    elseif i.KeyCode == CFG.ESP.key then
        CFG.ESP.on = not CFG.ESP.on
    elseif i.KeyCode == CFG.Misc.key then
        gui.Enabled = not gui.Enabled
    end
end)

print("[KukemPremium] Loaded — Universal ESP + Aimbot | Drawing:", HAS_DRAW)
