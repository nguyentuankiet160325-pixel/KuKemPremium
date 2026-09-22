local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local Camera = Workspace.CurrentCamera
local LP = Players.LocalPlayer

local Config = {
    Aim = {on=false, team=true, wall=false, fov=140, part="Head", showFov=true, key=Enum.KeyCode.RightAlt},
    Skill = {on=false, keys={"Z","X","C","V"}, wait=0.6, click=true, key=Enum.KeyCode.G},
    ESP = {on=false, box=true, name=true, hp=true, dist=true, max=1000, team=true, key=Enum.KeyCode.F},
    Speed = {on=false, val=50, key=Enum.KeyCode.LeftShift},
}

-- ══ COLORS ══
local C = {
    bg=Color3.fromRGB(8,7,2), panel=Color3.fromRGB(20,16,4), hi=Color3.fromRGB(32,26,8),
    gold=Color3.fromRGB(255,200,40), gold2=Color3.fromRGB(255,150,0),
    txt=Color3.fromRGB(255,248,220), dim=Color3.fromRGB(150,130,70),
    off=Color3.fromRGB(45,38,14), sliderBg=Color3.fromRGB(30,24,8),
}

local function corner(p,r) local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,r or 8) c.Parent=p end
local function stroke(p,c,t) local s=Instance.new("UIStroke") s.Color=c or C.gold s.Thickness=t or 1 s.Transparency=0.5 s.Parent=p end

-- ══ GUI ══
local gui = Instance.new("ScreenGui")
gui.Name = "KukemPremium"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() gui.Parent = CoreGui end)
if not gui.Parent then gui.Parent = LP:WaitForChild("PlayerGui") end

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 460, 0, 340)
Main.Position = UDim2.new(0, 60, 0, 100)
Main.BackgroundColor3 = C.bg
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = gui
corner(Main, 12)
stroke(Main, C.gold, 2)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 42)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundColor3 = C.panel
Title.BorderSizePixel = 0
Title.Text = "🌕  KUKEMPREMIUM"
Title.TextColor3 = C.gold
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 20
Title.Parent = Main
corner(Title, 12)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -36, 0, 7)
CloseBtn.BackgroundColor3 = C.panel
CloseBtn.Text = "×"
CloseBtn.TextColor3 = C.gold
CloseBtn.Font = Enum.Font.GothamBlack
CloseBtn.TextSize = 20
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = Title
corner(CloseBtn, 6)
CloseBtn.MouseButton1Click:Connect(function() gui.Enabled = false end)

-- Tab bar
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -16, 0, 34)
TabBar.Position = UDim2.new(0, 8, 0, 50)
TabBar.BackgroundColor3 = C.panel
TabBar.BorderSizePixel = 0
TabBar.Parent = Main
corner(TabBar, 8)
stroke(TabBar, C.gold, 1)

local TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.Padding = UDim.new(0, 4)
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabLayout.Parent = TabBar

local TabPad = Instance.new("UIPadding")
TabPad.PaddingLeft = UDim.new(0, 6)
TabPad.PaddingTop = UDim.new(0, 4)
TabPad.PaddingBottom = UDim.new(0, 4)
TabPad.Parent = TabBar

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -16, 1, -92)
Content.Position = UDim2.new(0, 8, 0, 90)
Content.BackgroundTransparency = 1
Content.Parent = Main

local Pages = {}
local TabButtons = {}
local ActiveTab = nil

local function makePage()
    local s = Instance.new("ScrollingFrame")
    s.Size = UDim2.new(1, 0, 1, 0)
    s.BackgroundTransparency = 1
    s.BorderSizePixel = 0
    s.ScrollBarThickness = 3
    s.ScrollBarImageColor3 = C.gold
    s.CanvasSize = UDim2.new(0, 0, 0, 0)
    s.AutomaticCanvasSize = Enum.AutomaticSize.Y
    s.Visible = false
    s.Parent = Content

    local l = Instance.new("UIListLayout")
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Padding = UDim.new(0, 6)
    l.Parent = s

    local p = Instance.new("UIPadding")
    p.PaddingTop = UDim.new(0, 6)
    p.PaddingRight = UDim.new(0, 4)
    p.PaddingBottom = UDim.new(0, 8)
    p.Parent = s
    return s
end

local function switchTab(name)
    for n, p in pairs(Pages) do p.Visible = (n == name) end
    for n, b in pairs(TabButtons) do
        b.BackgroundColor3 = (n == name) and C.hi or C.panel
        b.TextColor3 = (n == name) and C.gold or C.dim
    end
    ActiveTab = name
end

local function addTab(name, label)
    local page = makePage()
    Pages[name] = page

    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 82, 1, -8)
    b.BackgroundColor3 = C.panel
    b.Text = label
    b.TextColor3 = C.dim
    b.Font = Enum.Font.GothamBlack
    b.TextSize = 13
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    b.Parent = TabBar
    corner(b, 6)

    TabButtons[name] = b
    b.MouseButton1Click:Connect(function() switchTab(name) end)
    return page
end

-- ══ COMPONENTS ══
local function section(parent, text)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 26)
    f.BackgroundTransparency = 1
    f.Parent = parent

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 1, 0)
    l.BackgroundTransparency = 1
    l.Text = "◆ " .. text
    l.TextColor3 = C.gold
    l.Font = Enum.Font.GothamBlack
    l.TextSize = 13
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = f

    local ln = Instance.new("Frame")
    ln.Size = UDim2.new(1, 0, 0, 1)
    ln.Position = UDim2.new(0, 0, 1, -2)
    ln.BackgroundColor3 = C.gold
    ln.BackgroundTransparency = 0.5
    ln.BorderSizePixel = 0
    ln.Parent = f
end

local function toggle(parent, label, default, cb)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = C.panel
    btn.Text = ""
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = parent
    corner(btn, 8)
    stroke(btn, C.gold, 1)

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -80, 1, 0)
    l.Position = UDim2.new(0, 14, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = label
    l.TextColor3 = C.txt
    l.Font = Enum.Font.GothamMedium
    l.TextSize = 13
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = btn

    local st = Instance.new("TextLabel")
    st.Size = UDim2.new(0, 50, 0, 24)
    st.Position = UDim2.new(1, -58, 0.5, -12)
    st.BackgroundColor3 = default and C.gold or C.off
    st.Text = default and "ON" or "OFF"
    st.TextColor3 = default and C.bg or C.dim
    st.Font = Enum.Font.GothamBlack
    st.TextSize = 11
    st.BorderSizePixel = 0
    st.Parent = btn
    corner(st, 6)

    local v = default
    btn.MouseButton1Click:Connect(function()
        v = not v
        st.Text = v and "ON" or "OFF"
        st.BackgroundColor3 = v and C.gold or C.off
        st.TextColor3 = v and C.bg or C.dim
        if cb then pcall(cb, v) end
    end)
end

local function slider(parent, label, minV, maxV, default, suf, cb)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 56)
    f.BackgroundColor3 = C.panel
    f.BorderSizePixel = 0
    f.Parent = parent
    corner(f, 8)
    stroke(f, C.gold, 1)

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -90, 0, 22)
    l.Position = UDim2.new(0, 14, 0, 6)
    l.BackgroundTransparency = 1
    l.Text = label
    l.TextColor3 = C.txt
    l.Font = Enum.Font.GothamMedium
    l.TextSize = 13
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = f

    local vl = Instance.new("TextLabel")
    vl.Size = UDim2.new(0, 70, 0, 22)
    vl.Position = UDim2.new(1, -80, 0, 6)
    vl.BackgroundTransparency = 1
    vl.Text = tostring(default) .. (suf or "")
    vl.TextColor3 = C.gold
    vl.Font = Enum.Font.GothamBlack
    vl.TextSize = 12
    vl.TextXAlignment = Enum.TextXAlignment.Right
    vl.Parent = f

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -28, 0, 6)
    track.Position = UDim2.new(0, 14, 0, 38)
    track.BackgroundColor3 = C.sliderBg
    track.BorderSizePixel = 0
    track.Parent = f
    corner(track, 3)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - minV)/(maxV - minV), 0, 1, 0)
    fill.BackgroundColor3 = C.gold
    fill.BorderSizePixel = 0
    fill.Parent = track
    corner(fill, 3)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = UDim2.new((default - minV)/(maxV - minV), -7, 0.5, -7)
    knob.BackgroundColor3 = C.gold
    knob.BorderSizePixel = 0
    knob.ZIndex = 3
    knob.Parent = track
    corner(knob, 7)

    local drag = false
    local function upd(x)
        local rel = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local v = math.floor(minV + rel * (maxV - minV))
        fill.Size = UDim2.new(rel, 0, 1, 0)
        knob.Position = UDim2.new(rel, -7, 0.5, -7)
        vl.Text = tostring(v) .. (suf or "")
        if cb then pcall(cb, v) end
    end
    track.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag = true; upd(i.Position.X)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            upd(i.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag = false
        end
    end)
end

local function input(parent, label, default, cb)
    local f = Instance.new("Frame")
        f.Size = UDim2.new(1, 0, 0, 56)
    f.BackgroundColor3 = C.panel
    f.BorderSizePixel = 0
    f.Parent = parent
    corner(f, 8)
    stroke(f, C.gold, 1)

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -24, 0, 20)
    l.Position = UDim2.new(0, 14, 0, 4)
    l.BackgroundTransparency = 1
    l.Text = label
    l.TextColor3 = C.txt
    l.Font = Enum.Font.GothamMedium
    l.TextSize = 12
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = f

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -28, 0, 26)
    box.Position = UDim2.new(0, 14, 0, 24)
    box.BackgroundColor3 = C.bg
    box.Text = default
    box.TextColor3 = C.gold
    box.Font = Enum.Font.GothamBold
    box.TextSize = 12
    box.BorderSizePixel = 0
    box.ClearTextOnFocus = false
    box.Parent = f
    corner(box, 6)
    stroke(box, C.gold, 1)

    box.FocusLost:Connect(function() if cb then pcall(cb, box.Text) end end)
end

local function button(parent, label, cb)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 34)
    b.BackgroundColor3 = C.panel
    b.Text = label
    b.TextColor3 = C.gold
    b.Font = Enum.Font.GothamBold
    b.TextSize = 13
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    b.Parent = parent
    corner(b, 8)
    stroke(b, C.gold, 1)
    b.MouseButton1Click:Connect(function() if cb then pcall(cb) end end)
end

-- ══ HELPERS ══
local function myHum()
    local c = LP.Character
    return c and c:FindFirstChildOfClass("Humanoid") or nil
end

local function validTarget(p)
    if p == LP or not p.Character then return false end
    local h = p.Character:FindFirstChildOfClass("Humanoid")
    local r = p.Character:FindFirstChild("HumanoidRootPart")
    if not h or not r or h.Health <= 0 then return false end
    if Config.Aim.team and p.Team == LP.Team then return false end
    return true
end

local function nearest()
    local best, dist = nil, Config.Aim.fov
    for _, p in ipairs(Players:GetPlayers()) do
        if validTarget(p) then
            local r = p.Character:FindFirstChild("HumanoidRootPart")
            local s, on = Camera:WorldToViewportPoint(r.Position)
            if on then
                local ctr = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
                local m = (Vector2.new(s.X, s.Y) - ctr).Magnitude
                if m < dist then dist = m; best = p end
            end
        end
    end
    return best
end

local function visible(part)
    if not Config.Aim.wall then return true end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {LP.Character, part.Parent}
    local hit = Workspace:Raycast(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * 500, params)
    return hit == nil
end

-- ══ BUILD TABS ══
local aimP = addTab("AIM", "AIM")
local skillP = addTab("SKILL", "SKILL")
local espP = addTab("ESP", "ESP")
local spdP = addTab("SPEED", "SPEED")
local infoP = addTab("INFO", "INFO")

section(aimP, "SILENT AIM")
toggle(aimP, "Bật Silent Aim", false, function(v) Config.Aim.on = v end)
toggle(aimP, "Team Check", true, function(v) Config.Aim.team = v end)
toggle(aimP, "Wall Check", false, function(v) Config.Aim.wall = v end)
toggle(aimP, "Hiện FOV", true, function(v) Config.Aim.showFov = v end)
slider(aimP, "FOV", 20, 500, 140, "px", function(v) Config.Aim.fov = v end)

section(skillP, "AUTO SKILL")
toggle(skillP, "Bật Auto Skill", false, function(v)
    Config.Skill.on = v
    if v then task.spawn(skillLoop) end
end)
toggle(skillP, "Auto Click", true, function(v) Config.Skill.click = v end)
slider(skillP, "Delay", 0, 3, 0.6, "s", function(v) Config.Skill.wait = v end)
input(skillP, "Phím (Z,X,C,V)", "Z,X,C,V", function(txt)
    local list = {}
    for k in string.gmatch(txt, "[^,]+") do table.insert(list, (k:gsub("%s+",""))) end
    if #list > 0 then Config.Skill.keys = list end
end)

section(espP, "ESP")
toggle(espP, "Bật ESP", false, function(v) Config.ESP.on = v end)
toggle(espP, "Box", true, function(v) Config.ESP.box = v end)
toggle(espP, "Tên", true, function(v) Config.ESP.name = v end)
toggle(espP, "Máu", true, function(v) Config.ESP.hp = v end)
toggle(espP, "Khoảng cách", true, function(v) Config.ESP.dist = v end)
toggle(espP, "Team Check", true, function(v) Config.ESP.team = v end)
slider(espP, "Max Distance", 100, 5000, 1000, "s", function(v) Config.ESP.max = v end)

section(spdP, "SPEED (1 - 1000)")
toggle(spdP, "Bật Speed", false, function(v)
    Config.Speed.on = v
    if not v then local h = myHum(); if h then h.WalkSpeed = 16 end end
end)
slider(spdP, "WalkSpeed", 1, 1000, 50, " ws", function(v) Config.Speed.val = v end)
button(spdP, "Reset 16", function()
    Config.Speed.val = 16
    local h = myHum(); if h then h.WalkSpeed = 16 end
end)

section(infoP, "THÔNG TIN")
button(infoP, "Tắt toàn bộ", function()
    Config.Aim.on = false; Config.Skill.on = false
    Config.ESP.on = false; Config.Speed.on = false
    local h = myHum(); if h then h.WalkSpeed = 16 end
end)
button(infoP, "Ẩn menu (RightControl)", function() gui.Enabled = false end)

-- chọn tab đầu — giờ an toàn, dùng TabButtons table
switchTab("AIM")

-- ══ SILENT AIM HOOK ══
pcall(function()
    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    setreadonly(mt, false)
    mt.__namecall = function(self, ...)
        local method = getnamecallmethod()
        if Config.Aim.on and (method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList"
            or method == "FindPartOnRayWithWhitelist" or method == "Raycast") then
            local t = nearest()
            if t and t.Character then
                local part = t.Character:FindFirstChild(Config.Aim.part)
                if part and visible(part) then
                    local args = {...}
                    local dir = (part.Position - Camera.CFrame.Position).Unit * 1000
                    if method == "Raycast" then args[2] = dir
                    else args[1] = Ray.new(Camera.CFrame.Position, dir) end
                    return oldNamecall(self, unpack(args))
                end
            end
        end
        return oldNamecall(self, ...)
    end
    setreadonly(mt, true)
    print("[Kukem] Silent aim hook OK")
end)

-- ══ AUTO SKILL ══
function skillLoop()
    while Config.Skill.on do
        if myHum() then
            for _, k in ipairs(Config.Skill.keys) do
                if not Config.Skill.on then break end
                local vk = Enum.KeyCode[k]
                if vk then keypress(vk); task.wait(0.05); keyrelease(vk) end
                task.wait(Config.Skill.wait)
            end
            if Config.Skill.click then mouse1click(); task.wait(0.1) end
        end
        task.wait(0.1)
    end
end

-- ══ ESP (Drawing + fallback) ══
local HAS_DRAW = pcall(function() local d = Drawing.new("Square") d:Remove() end)
local espList = {}

local function makeESP(p)
    if p == LP then return end
    if HAS_DRAW then
        local ok, data = pcall(function()
            return {
                box = Drawing.new("Square"),
                nm = Drawing.new("Text"),
                hp = Drawing.new("Text"),
                ds = Drawing.new("Text"),
            }
        end)
        if ok then
            data.box.Visible = false; data.box.Thickness = 1; data.box.Filled = false
            data.box.Color = C.gold
            data.nm.Visible = false; data.nm.Size = 14; data.nm.Center = true; data.nm.Outline = true
            data.nm.Color = C.txt
            data.hp.Visible = false; data.hp.Size = 13; data.hp.Center = true; data.hp.Outline = true
            data.hp.Color = Color3.fromRGB(0,255,80)
            data.ds.Visible = false; data.ds.Size = 13; data.ds.Center = true; data.ds.Outline = true
            data.ds.Color = C.gold
            espList[p] = {t="d", d=data}
            return
        end
    end
    -- fallback
    local bb = Instance.new("BillboardGui")
    bb.Size = UDim2.new(0, 100, 0, 60)
    bb.StudsOffset = Vector3.new(0, 3, 0)
    bb.AlwaysOnTop = true
    bb.Enabled = false
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = p.Name
    lbl.TextColor3 = C.gold
    lbl.TextStrokeTransparency = 0
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 14
    lbl.Parent = bb
    espList[p] = {t="bb", d=bb}
end

local function dropESP(p)
    local o = espList[p]
    if not o then return end
    if o.t == "d" then
        for _, v in pairs(o.d) do pcall(function() v:Remove() end) end
    else
        pcall(function() o.d:Destroy() end)
    end
    espList[p] = nil
end

local function updateESP()
    for p, o in pairs(espList) do
        local show = Config.ESP.on and p.Character ~= nil
        local hrp, head, hum
        if show then
            hrp = p.Character:FindFirstChild("HumanoidRootPart")
            head = p.Character:FindFirstChild("Head")
            hum = p.Character:FindFirstChildOfClass("Humanoid")
            if not (hrp and head and hum and hum.Health > 0) then show = false end
            if Config.ESP.team and p.Team == LP.Team then show = false end
            if show then
                local dst = (hrp.Position - Camera.CFrame.Position).Magnitude
                if dst > Config.ESP.max then show = false end
            end
        end
        if o.t == "d" then
            local d = o.d
            if show then
                local sp, on = Camera:WorldToViewportPoint(hrp.Position)
                local hp2 = Camera:WorldToViewportPoint(head.Position)
                if on then
                    local h = math.abs(hp2.Y - sp.Y); local w = h / 2
                    d.box.Size = Vector2.new(w, h)
                    d.box.Position = Vector2.new(sp.X - w/2, sp.Y - h/2)
                    d.box.Visible = Config.ESP.box
                    d.nm.Text = p.Name
                    d.nm.Position = Vector2.new(sp.X, sp.Y - h/2 - 22)
                    d.nm.Visible = Config.ESP.name
                    d.hp.Text = "HP " .. math.floor(hum.Health)
                    d.hp.Position = Vector2.new(sp.X, sp.Y - h/2 - 6)
                    d.hp.Visible = Config.ESP.hp
                    local dd = (hrp.Position - Camera.CFrame.Position).Magnitude
                    d.ds.Text = math.floor(dd) .. "s"
                    d.ds.Position = Vector2.new(sp.X, sp.Y + h/2 + 4)
                    d.ds.Visible = Config.ESP.dist
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
local fovCircle = nil
if HAS_DRAW then
    pcall(function()
        fovCircle = Drawing.new("Circle")
        fovCircle.Thickness = 1.5
        fovCircle.NumSides = 80
        fovCircle.Filled = false
        fovCircle.Color = C.gold
        fovCircle.Visible = false
    end)
end

RunService.RenderStepped:Connect(function()
    if fovCircle then
        fovCircle.Radius = Config.Aim.fov
        fovCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        fovCircle.Visible = Config.Aim.on and Config.Aim.showFov
    end
    updateESP()
    if Config.Speed.on then
        local h = myHum()
        if h then h.WalkSpeed = Config.Speed.val end
    end
end)

-- ══ KEYBIND ══
UserInputService.InputBegan:Connect(function(i, gpe)
    if gpe then return end
    if i.KeyCode == Config.Aim.key then Config.Aim.on = not Config.Aim.on
    elseif i.KeyCode == Config.ESP.key then Config.ESP.on = not Config.ESP.on
    elseif i.KeyCode == Config.Skill.key then
        Config.Skill.on = not Config.Skill.on
        if Config.Skill.on then task.spawn(skillLoop) end
    elseif i.KeyCode == Config.Speed.key then
        Config.Speed.on = not Config.Speed.on
        if not Config.Speed.on then local h = myHum(); if h then h.WalkSpeed = 16 end end
    elseif i.KeyCode == Enum.KeyCode.RightControl then
        gui.Enabled = not gui.Enabled
    end
end)

for _, p in ipairs(Players:GetPlayers()) do makeESP(p) end
Players.PlayerAdded:Connect(makeESP)
Players.PlayerRemoving:Connect(dropESP)

print("[Kukem] Loaded — Drawing:", HAS_DRAW)
