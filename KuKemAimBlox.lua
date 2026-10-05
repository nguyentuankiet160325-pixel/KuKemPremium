local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local WS = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local Cam = WS.CurrentCamera
local LP = Players.LocalPlayer

local CFG = {
    Aim = {
        on = false, team = true, wall = false,
        fov = 200, maxRange = 500,
        part = "Head", smooth = 0.25, showFov = true,
        key = Enum.KeyCode.RightAlt,
    },
    ESP = {
        on = false, box = true, corner = true, name = true,
        hp = true, dist = true, tracer = false, glow = true,
        maxDist = 800, team = true, key = Enum.KeyCode.F,
        textSize = 12, boxThickness = 1, cornerThickness = 2,
    },
}

-- ═══════════ PALETTE ═══════════
local P = {
    bg      = Color3.fromRGB(10, 8, 16),
    bg2     = Color3.fromRGB(16, 12, 26),
    panel   = Color3.fromRGB(22, 18, 38),
    hi      = Color3.fromRGB(34, 26, 56),
    accent  = Color3.fromRGB(255, 200, 40),
    accent2 = Color3.fromRGB(255, 150, 0),
    txt     = Color3.fromRGB(255, 248, 220),
    dim     = Color3.fromRGB(150, 140, 170),
    off     = Color3.fromRGB(45, 38, 60),
    espBox  = Color3.fromRGB(255, 200, 40),
    espGlow = Color3.fromRGB(255, 150, 0),
    espName = Color3.fromRGB(255, 220, 100),
    espHP   = Color3.fromRGB(80, 255, 120),
    espHPLow= Color3.fromRGB(255, 80, 80),
    espDist = Color3.fromRGB(200, 190, 220),
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
gui.Name = "KuKemPremium"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset = true
pcall(function() gui.Parent = CoreGui end)
if not gui.Parent then gui.Parent = LP:WaitForChild("PlayerGui") end

local FloatBtn = Instance.new("TextButton")
FloatBtn.Size = UDim2.new(0, 52, 0, 52)
FloatBtn.Position = UDim2.new(0, 20, 0.5, -26)
FloatBtn.BackgroundColor3 = P.panel
FloatBtn.Text = "🔫"
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
Main.Size = UDim2.new(0, 460, 0, 340)
Main.Position = UDim2.new(0.5, -230, 0.5, -170)
Main.BackgroundColor3 = P.bg
Main.BorderSizePixel = 0
Main.Active = true
Main.Visible = false
Main.Parent = gui
corner(Main, 14)
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
Head.Size = UDim2.new(1, 0, 0, 52)
Head.BackgroundColor3 = P.panel
Head.BorderSizePixel = 0
Head.Parent = Main
corner(Head, 14)

local HeadGlow = Instance.new("Frame")
HeadGlow.Size = UDim2.new(1, 0, 1, 0)
HeadGlow.BackgroundColor3 = P.accent
HeadGlow.BackgroundTransparency = 0.85
HeadGlow.BorderSizePixel = 0
HeadGlow.ZIndex = 1
HeadGlow.Parent = Head
corner(HeadGlow, 14)
grad(HeadGlow, P.accent, P.accent2, 0)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -90, 0, 24)
Title.Position = UDim2.new(0, 14, 0, 6)
Title.BackgroundTransparency = 1
Title.Text = "💥 KuKemPremium 🔫"
Title.TextColor3 = P.accent
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 3
Title.Parent = Head

local Sub = Instance.new("TextLabel")
Sub.Size = UDim2.new(1, -90, 0, 16)
Sub.Position = UDim2.new(0, 14, 0, 30)
Sub.BackgroundTransparency = 1
Sub.Text = "Aimbot · ESP"
Sub.TextColor3 = P.dim
Sub.Font = Enum.Font.Gotham
Sub.TextSize = 10
Sub.TextXAlignment = Enum.TextXAlignment.Left
Sub.ZIndex = 3
Sub.Parent = Head

local CloseB = Instance.new("TextButton")
CloseB.Size = UDim2.new(0, 30, 0, 30)
CloseB.Position = UDim2.new(1, -38, 0, 11)
CloseB.BackgroundColor3 = P.hi
CloseB.Text = "🫀"
CloseB.TextColor3 = P.accent
CloseB.Font = Enum.Font.GothamBlack
CloseB.TextSize = 16
CloseB.BorderSizePixel = 0
CloseB.AutoButtonColor = false
CloseB.ZIndex = 5
CloseB.Parent = Head
corner(CloseB, 7)
CloseB.MouseButton1Click:Connect(function() Main.Visible = false end)

local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -18, 0, 36)
TabBar.Position = UDim2.new(0, 9, 0, 60)
TabBar.BackgroundColor3 = P.panel
TabBar.BorderSizePixel = 0
TabBar.Parent = Main
corner(TabBar, 9)
stroke(TabBar, P.accent, 1, 0.55)

local TL = Instance.new("UIListLayout")
TL.FillDirection = Enum.FillDirection.Horizontal
TL.Padding = UDim.new(0, 4)
TL.SortOrder = Enum.SortOrder.LayoutOrder
TL.VerticalAlignment = Enum.VerticalAlignment.Center
TL.Parent = TabBar

local TP = Instance.new("UIPadding")
TP.PaddingLeft = UDim.new(0, 5)
TP.Parent = TabBar

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -18, 1, -108)
Content.Position = UDim2.new(0, 9, 0, 104)
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
    b.Size = UDim2.new(0, 100, 0, 28)
    b.BackgroundColor3 = P.panel
    b.Text = label
    b.TextColor3 = P.dim
    b.Font = Enum.Font.GothamBlack
    b.TextSize = 12
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    b.Parent = TabBar
    corner(b, 7)
    TabBtns[name] = b
    b.MouseButton1Click:Connect(function() switchTab(name) end)
    return p
end

-- Components
local function section(parent, text)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 22)
    f.BackgroundTransparency = 1
    f.Parent = parent
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 1, 0)
    l.BackgroundTransparency = 1
    l.Text = "▸ " .. text
    l.TextColor3 = P.accent
    l.Font = Enum.Font.GothamBlack
    l.TextSize = 12
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = f
end

local function toggle(parent, label, default, cb)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 38)
    btn.BackgroundColor3 = P.panel
    btn.Text = ""
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = parent
    corner(btn, 9)
    stroke(btn, P.accent, 1, 0.55)

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
    sw.Size = UDim2.new(0, 46, 0, 22)
    sw.Position = UDim2.new(1, -56, 0.5, -11)
    sw.BackgroundColor3 = default and P.accent or P.off
    sw.BorderSizePixel = 0
    sw.Parent = btn
    corner(sw, 11)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.Position = default and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    knob.BorderSizePixel = 0
    knob.Parent = sw
    corner(knob, 9)

    local v = default
    btn.MouseButton1Click:Connect(function()
        v = not v
        sw.BackgroundColor3 = v and P.accent or P.off
        knob.Position = v and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
        if cb then pcall(cb, v) end
    end)
end

local function slider(parent, label, mn, mx, def, suf, cb)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 56)
    f.BackgroundColor3 = P.panel
    f.BorderSizePixel = 0
    f.Parent = parent
    corner(f, 9)
    stroke(f, P.accent, 1, 0.55)

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -90, 0, 20)
    l.Position = UDim2.new(0, 14, 0, 6)
    l.BackgroundTransparency = 1
    l.Text = label
    l.TextColor3 = P.txt
    l.Font = Enum.Font.GothamMedium
    l.TextSize = 12
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
    tr.Size = UDim2.new(1, -28, 0, 8)
    tr.Position = UDim2.new(0, 14, 0, 36)
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
    kb.Size = UDim2.new(0, 16, 0, 16)
    kb.Position = UDim2.new((def - mn) / (mx - mn), -8, 0.5, -8)
    kb.BackgroundColor3 = Color3.new(1, 1, 1)
    kb.BorderSizePixel = 0
    kb.ZIndex = 3
    kb.Parent = tr
    corner(kb, 8)
    stroke(kb, P.accent, 1, 0.3)

    local drag = false
    local function upd(x)
        local rel = math.clamp((x - tr.AbsolutePosition.X) / tr.AbsoluteSize.X, 0, 1)
        local v = mn + rel * (mx - mn)
        if (mx - mn) > 50 then v = math.floor(v) else v = math.floor(v * 100) / 100 end
        fl.Size = UDim2.new(rel, 0, 1, 0)
        kb.Position = UDim2.new(rel, -8, 0.5, -8)
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
    f.Size = UDim2.new(1, 0, 0, 38)
    f.BackgroundColor3 = P.panel
    f.BorderSizePixel = 0
    f.ClipsDescendants = true
    f.Parent = parent
    corner(f, 9)
    stroke(f, P.accent, 1, 0.55)

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -130, 1, 0)
    l.Position = UDim2.new(0, 14, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = label
    l.TextColor3 = P.txt
    l.Font = Enum.Font.GothamMedium
    l.TextSize = 12
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = f

    local sel = Instance.new("TextButton")
    sel.Size = UDim2.new(0, 100, 0, 26)
    sel.Position = UDim2.new(1, -110, 0.5, -13)
    sel.BackgroundColor3 = P.hi
    sel.Text = def
    sel.TextColor3 = P.accent
    sel.Font = Enum.Font.GothamBold
    sel.TextSize = 11
    sel.BorderSizePixel = 0
    sel.AutoButtonColor = false
    sel.Parent = f
    corner(sel, 6)

    local opts = {}
    local open = false
    local baseH = 38
    for i, opt in ipairs(options) do
        local ob = Instance.new("TextButton")
        ob.Size = UDim2.new(1, -16, 0, 26)
        ob.Position = UDim2.new(0, 8, 0, baseH + (i - 1) * 26)
        ob.BackgroundColor3 = P.hi
        ob.Text = opt
        ob.TextColor3 = P.txt
        ob.Font = Enum.Font.Gotham
        ob.TextSize = 11
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
        f.Size = UDim2.new(1, 0, 0, open and (baseH + #options * 26 + 8) or baseH)
        for _, o in pairs(opts) do o.Visible = open end
    end)
end

local function button(parent, label, cb)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 32)
    b.BackgroundColor3 = P.panel
    b.Text = label
    b.TextColor3 = P.accent
    b.Font = Enum.Font.GothamBold
    b.TextSize = 12
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    b.Parent = parent
    corner(b, 9)
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

local function getMyPos()
    if not LP.Character then return nil end
    local myHrp = LP.Character:FindFirstChild("HumanoidRootPart")
    return myHrp and myHrp.Position
end

local function valid(plr)
    local p = getParts(plr)
    if not p then return false end
    if CFG.Aim.team and isTeammate(plr) then return false end
    return true
end

-- Wall check: ray từ camera tới target, nếu có vật cản → không visible
local function visible(part)
    if not CFG.Aim.wall then return true end
    local origin = Cam.CFrame.Position
    local target = part.Position
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {LP.Character, part.Parent}
    local result = WS:Raycast(origin, target - origin, params)
    return result == nil
end

-- Kiểm tra khoảng cách từ player đến target trong max range
local function inRange(plr)
    local p = getParts(plr)
    if not p then return false end
    local myPos = getMyPos()
    if not myPos then return false end
    return (p.hrp.Position - myPos).Magnitude <= CFG.Aim.maxRange
end

local function nearestInFov()
    local best, bestScore = nil, CFG.Aim.fov
    local myPos = getMyPos()
    if not myPos then return nil end

    for _, plr in ipairs(Players:GetPlayers()) do
        if valid(plr) and inRange(plr) then
            local p = getParts(plr)
            if p then
                local targetPart = p.char:FindFirstChild(CFG.Aim.part) or p.head
                if targetPart and visible(targetPart) then
                    local sp, on = Cam:WorldToViewportPoint(p.hrp.Position)
                    if on then
                        local ctr = Vector2.new(Cam.ViewportSize.X / 2, Cam.ViewportSize.Y / 2)
                        local d = (Vector2.new(sp.X, sp.Y) - ctr).Magnitude
                        if d < bestScore then
                            bestScore = d
                            best = plr
                        end
                    end
                end
            end
        end
    end
    return best
end

-- ═══════════ BUILD UI ═══════════
local aimP = addTab("AIM", "🎯 AIMBOT")
local espP = addTab("ESP", "👁️ ESP")
local infoP = addTab("INFO", "ℹ️ INFO")

section(aimP, "AIMBOT")
toggle(aimP, "Bật Aimbot", false, function(v) CFG.Aim.on = v end)
toggle(aimP, "Team Check", true, function(v) CFG.Aim.team = v end)
toggle(aimP, "Wall Check (không aim xuyên tường)", true, function(v) CFG.Aim.wall = v end)
toggle(aimP, "Hiện FOV Circle", true, function(v) CFG.Aim.showFov = v end)
slider(aimP, "FOV", 20, 600, 200, "px", function(v) CFG.Aim.fov = v end)
slider(aimP, "Tầm aim (max range)", 50, 2000, 500, " studs", function(v) CFG.Aim.maxRange = v end)
slider(aimP, "Smooth", 0.02, 1, 0.25, "", function(v) CFG.Aim.smooth = v end)
dropdown(aimP, "Vị trí ngắm", {"Head", "HumanoidRootPart", "UpperTorso"}, "Head", function(v) CFG.Aim.part = v end)

section(espP, "ESP")
toggle(espP, "Bật ESP", false, function(v) CFG.ESP.on = v end)
toggle(espP, "Box", true, function(v) CFG.ESP.box = v end)
toggle(espP, "Khung góc", true, function(v) CFG.ESP.corner = v end)
toggle(espP, "Glow", false, function(v) CFG.ESP.glow = v end)
toggle(espP, "Tên", true, function(v) CFG.ESP.name = v end)
toggle(espP, "Máu", true, function(v) CFG.ESP.hp = v end)
toggle(espP, "Khoảng cách", true, function(v) CFG.ESP.dist = v end)
toggle(espP, "Tracer", false, function(v) CFG.ESP.tracer = v end)
toggle(espP, "Team Check", true, function(v) CFG.ESP.team = v end)
slider(espP, "Max Distance", 100, 3000, 800, " studs", function(v) CFG.ESP.maxDist = v end)
slider(espP, "Cỡ chữ", 8, 20, 12, "px", function(v) CFG.ESP.textSize = v end)
slider(espP, "Độ dày box", 1, 5, 1, "px", function(v) CFG.ESP.boxThickness = v end)
slider(espP, "Độ dày góc", 1, 5, 2, "px", function(v) CFG.ESP.cornerThickness = v end)

section(infoP, "THÔNG TIN")
button(infoP, "Tắt toàn bộ", function()
    CFG.Aim.on = false
    CFG.ESP.on = false
end)
button(infoP, "Ẩn menu (RightControl)", function() gui.Enabled = false end)

switchTab("AIM")

-- ═══════════ AIMBOT LOOP (CAMERA LOCK) ═══════════
RunService.RenderStepped:Connect(function(dt)
    if not CFG.Aim.on then return end
    local t = nearestInFov()
    if not t or not t.Character then return end
    local part = t.Character:FindFirstChild(CFG.Aim.part)
    if not part then return end
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

    d.boxGlow.Filled = false; d.boxGlow.Thickness = 3
    d.boxGlow.Color = P.espGlow; d.boxGlow.Transparency = 0.5; d.boxGlow.Visible = false

    d.box.Filled = false; d.box.Thickness = 1
    d.box.Color = P.espBox; d.box.Transparency = 0.9; d.box.Visible = false

    for _, k in ipairs({"tl", "tr", "bl", "br"}) do
        d[k].Thickness = 2; d[k].Color = P.espBox
        d[k].Transparency = 1; d[k].Visible = false
    end

    d.hpBg.Filled = true; d.hpBg.Color = Color3.fromRGB(15, 12, 4)
    d.hpBg.Transparency = 0.5; d.hpBg.Visible = false
    d.hpFill.Filled = true; d.hpFill.Color = P.espHP
    d.hpFill.Transparency = 1; d.hpFill.Visible = false

    d.name.Size = 12; d.name.Center = true; d.name.Outline = true
    d.name.Color = P.espName; d.name.Visible = false; d.name.Font = 3

    d.dist.Size = 11; d.dist.Center = true; d.dist.Outline = true
    d.dist.Color = P.espDist; d.dist.Visible = false; d.dist.Font = 3

    d.tracer.Thickness = 1; d.tracer.Color = P.tracer
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
                local myPos = getMyPos()
                local dist = myPos and (p.hrp.Position - myPos).Magnitude or 0
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

        -- Size box vừa phải, không che màn hình
        local h = math.abs(hp2.Y - sp.Y) * 1.2
        local w = h * 0.5
        local x, y = sp.X - w / 2, sp.Y - h / 2

        d.boxGlow.Size = Vector2.new(w + 6, h + 6)
        d.boxGlow.Position = Vector2.new(x - 3, y - 3)
        d.boxGlow.Visible = CFG.ESP.glow and CFG.ESP.box

        d.box.Size = Vector2.new(w, h)
        d.box.Position = Vector2.new(x, y)
        d.box.Thickness = CFG.ESP.boxThickness
        d.box.Visible = CFG.ESP.box

        -- Khung 4 góc, không vẽ đường thẳng hai bên
        local cl = math.min(w, h) * 0.25
        d.tl.From = Vector2.new(x, y); d.tl.To = Vector2.new(x + cl, y)
        d.tr.From = Vector2.new(x + w, y); d.tr.To = Vector2.new(x + w - cl, y)
        d.bl.From = Vector2.new(x, y + h); d.bl.To = Vector2.new(x + cl, y + h)
        d.br.From = Vector2.new(x + w, y + h); d.br.To = Vector2.new(x + w - cl, y + h)

        for _, k in ipairs({"tl", "tr", "bl", "br"}) do
            d[k].Thickness = CFG.ESP.cornerThickness
            d[k].Visible = CFG.ESP.corner
        end

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

        d.name.Size = CFG.ESP.textSize
        d.name.Text = plr.Name .. " [" .. math.floor(p.hum.Health) .. "]"
        d.name.Position = Vector2.new(sp.X, y - 18)
        d.name.Visible = CFG.ESP.name

        local dist = getMyPos() and (p.hrp.Position - getMyPos()).Magnitude or 0
        d.dist.Size = CFG.ESP.textSize - 1
        d.dist.Text = math.floor(dist) .. "s"
        d.dist.Position = Vector2.new(sp.X, y + h + 3)
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
Players.PlayerRemoving:Connect(dropESP)

-- ═══════════ FOV CIRCLE ═══════════
local fovCircle = nil
if HAS_DRAW then
    pcall(function()
        fovCircle = Drawing.new("Circle")
        fovCircle.Thickness = 1.5
        fovCircle.NumSides = 80
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
    elseif i.KeyCode == Enum.KeyCode.RightControl then
        Main.Visible = not Main.Visible
    end
end)

print("[KuKemPremium] Loaded")
