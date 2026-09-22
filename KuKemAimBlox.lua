--[[
    ═══════════════════════════════════════════════
    🌕 KUKEMPREMIUM — Blox Fruits Script
    Gold Neon Menu | SilentAim · AutoSkill · ESP · Speed
    ═══════════════════════════════════════════════
]]

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- ═══════════════ SERVICES ═══════════════
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
        Keybind = "RightAlt",
    },
    AutoSkill = {
        Enabled = false, Skills = {"Z","X","C","V"},
        WaitBetween = 0.6, AutoClick = true, Keybind = "G",
    },
    ESP = {
        Enabled = false, ShowBox = true, ShowName = true,
        ShowHealth = true, ShowDistance = true, MaxDistance = 1000,
        TeamCheck = true, Keybind = "F",
    },
    Speed = {
        Enabled = false, Value = 50, Keybind = "LeftShift",
    },
}

-- ═══════════════ WINDOW VÀNG NEON ═══════════════
local Window = Rayfield:CreateWindow({
    Name = "🌕 KukemPremium",
    LoadingTitle = "KukemPremium đang tải...",
    LoadingSubtitle = "Gold Neon Edition",
    ConfigurationSaving = { Enabled = true, FolderName = "KukemPremium", FileName = "BF_Config" },
    Discord = { Enabled = false },
    KeySystem = false,
})

Rayfield:ChangeTheme({
    Background = Color3.fromRGB(12, 10, 2),
    Primary = Color3.fromRGB(255, 200, 40),
    Secondary = Color3.fromRGB(255, 170, 0),
    Tertiary = Color3.fromRGB(30, 24, 5),
    Text = Color3.fromRGB(255, 245, 210),
    Accent = Color3.fromRGB(255, 215, 0),
})
Rayfield:ChangeColor(Color3.fromRGB(255, 200, 40), 0)

-- ═══════════════ TABS ═══════════════
local TabAim    = Window:CreateTab("🎯 Silent Aim", 4483362458)
local TabSkill  = Window:CreateTab("⚔️ Auto Skill", 4483362458)
local TabESP    = Window:CreateTab("👁️ ESP", 4483362458)
local TabSpeed  = Window:CreateTab("⚡ Speed", 4483362458)
local TabKey    = Window:CreateTab("⌨️ Keybind", 4483362458)
local TabInfo   = Window:CreateTab("⚙️ Info", 4483362458)

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

-- ═══════════════ TAB: SILENT AIM ═══════════════
TabAim:CreateSection("Cấu hình Silent Aim")

TabAim:CreateToggle({
    Name = "Bật Silent Aim",
    CurrentValue = false,
    Flag = "Aim_Enabled",
    Callback = function(v) Config.SilentAim.Enabled = v end,
})

TabAim:CreateToggle({
    Name = "Kiểm tra đồng đội",
    CurrentValue = true,
    Flag = "Aim_Team",
    Callback = function(v) Config.SilentAim.TeamCheck = v end,
})

TabAim:CreateToggle({
    Name = "Kiểm tra tường",
    CurrentValue = false,
    Flag = "Aim_Wall",
    Callback = function(v) Config.SilentAim.WallCheck = v end,
})

TabAim:CreateToggle({
    Name = "Hiển thị vòng FOV",
    CurrentValue = true,
    Flag = "Aim_FOVShow",
    Callback = function(v) Config.SilentAim.ShowFOV = v end,
})

TabAim:CreateSlider({
    Name = "FOV",
    Range = {10, 500},
    Increment = 10,
    Suffix = "px",
    CurrentValue = 120,
    Flag = "Aim_FOV",
    Callback = function(v) Config.SilentAim.FOV = v end,
})

TabAim:CreateDropdown({
    Name = "Vị trí ngắm",
    Options = {"Head", "HumanoidRootPart", "UpperTorso"},
    CurrentOption = {"Head"},
    Flag = "Aim_Part",
    Callback = function(opt) Config.SilentAim.TargetPart = opt[1] or "Head" end,
})

-- ═══════════════ TAB: AUTO SKILL ═══════════════
TabSkill:CreateSection("Cấu hình Auto Skill")

TabSkill:CreateToggle({
    Name = "Bật Auto Skill",
    CurrentValue = false,
    Flag = "Skill_Enabled",
    Callback = function(v)
        Config.AutoSkill.Enabled = v
        if v then task.spawn(autoSkillLoop) end
    end,
})

TabSkill:CreateToggle({
    Name = "Auto Click",
    CurrentValue = true,
    Flag = "Skill_Click",
    Callback = function(v) Config.AutoSkill.AutoClick = v end,
})

TabSkill:CreateSlider({
    Name = "Delay giữa các skill",
    Range = {0, 3},
    Increment = 0.1,
    Suffix = "s",
    CurrentValue = 0.6,
    Flag = "Skill_Wait",
    Callback = function(v) Config.AutoSkill.WaitBetween = v end,
})

TabSkill:CreateInput({
    Name = "Danh sách phím (cách nhau dấu phẩy)",
    CurrentValue = "Z,X,C,V",
    PlaceholderText = "Z,X,C,V",
    RemoveTextAfterFocusLost = false,
    Flag = "Skill_Keys",
    Callback = function(txt)
        local list = {}
        for k in string.gmatch(txt, "[^,]+") do
            table.insert(list, (k:gsub("%s+", "")))
        end
        if #list > 0 then Config.AutoSkill.Skills = list end
    end,
})

-- ═══════════════ TAB: ESP ═══════════════
TabESP:CreateSection("Cấu hình ESP")

TabESP:CreateToggle({
    Name = "Bật ESP",
    CurrentValue = false,
    Flag = "ESP_Enabled",
    Callback = function(v) Config.ESP.Enabled = v end,
})

TabESP:CreateToggle({
    Name = "Hiển thị Box",
    CurrentValue = true,
    Flag = "ESP_Box",
    Callback = function(v) Config.ESP.ShowBox = v end,
})

TabESP:CreateToggle({
    Name = "Hiển thị Tên",
    CurrentValue = true,
    Flag = "ESP_Name",
    Callback = function(v) Config.ESP.ShowName = v end,
})

TabESP:CreateToggle({
    Name = "Hiển thị Máu",
    CurrentValue = true,
    Flag = "ESP_HP",
    Callback = function(v) Config.ESP.ShowHealth = v end,
})

TabESP:CreateToggle({
    Name = "Hiển thị Khoảng cách",
    CurrentValue = true,
    Flag = "ESP_Dist",
    Callback = function(v) Config.ESP.ShowDistance = v end,
})

TabESP:CreateToggle({
    Name = "Kiểm tra đồng đội",
    CurrentValue = true,
    Flag = "ESP_Team",
    Callback = function(v) Config.ESP.TeamCheck = v end,
})

TabESP:CreateSlider({
    Name = "Khoảng cách tối đa",
    Range = {100, 5000},
    Increment = 100,
    Suffix = " studs",
    CurrentValue = 1000,
    Flag = "ESP_Max",
    Callback = function(v) Config.ESP.MaxDistance = v end,
})

-- ═══════════════ TAB: SPEED ═══════════════
TabSpeed:CreateSection("Tốc độ chạy (1 - 1000)")

TabSpeed:CreateToggle({
    Name = "Bật Speed",
    CurrentValue = false,
    Flag = "Speed_Enabled",
    Callback = function(v)
        Config.Speed.Enabled = v
        if not v then
            local hum = getMyHum()
            if hum then hum.WalkSpeed = 16 end
        end
    end,
})

TabSpeed:CreateSlider({
    Name = "WalkSpeed",
    Range = {1, 1000},
    Increment = 1,
    Suffix = " ws",
    CurrentValue = 50,
    Flag = "Speed_Value",
    Callback = function(v) Config.Speed.Value = v end,
})

TabSpeed:CreateButton({
    Name = "Reset về 16 (mặc định)",
    Callback = function()
        Config.Speed.Value = 16
        local hum = getMyHum()
        if hum then hum.WalkSpeed = 16 end
    end,
})

-- ═══════════════ TAB: KEYBIND ═══════════════
TabKey:CreateSection("Gán phím tắt (bấm để đổi)")

TabKey:CreateKeybind({
    Name = "Silent Aim",
    CurrentKeybind = "RightAlt",
    HoldToInteract = false,
    Flag = "Key_Aim",
    Callback = function(key)
        Config.SilentAim.Enabled = not Config.SilentAim.Enabled
        Rayfield:Notify({Title = "KukemPremium", Content = "Silent Aim: " .. (Config.SilentAim.Enabled and "BẬT" or "TẮT"), Duration = 2})
    end,
})

TabKey:CreateKeybind({
    Name = "Auto Skill",
    CurrentKeybind = "G",
    HoldToInteract = false,
    Flag = "Key_Skill",
    Callback = function(key)
        Config.AutoSkill.Enabled = not Config.AutoSkill.Enabled
        if Config.AutoSkill.Enabled then task.spawn(autoSkillLoop) end
        Rayfield:Notify({Title = "KukemPremium", Content = "Auto Skill: " .. (Config.AutoSkill.Enabled and "BẬT" or "TẮT"), Duration = 2})
    end,
})

TabKey:CreateKeybind({
    Name = "ESP",
    CurrentKeybind = "F",
    HoldToInteract = false,
    Flag = "Key_ESP",
    Callback = function(key)
        Config.ESP.Enabled = not Config.ESP.Enabled
        Rayfield:Notify({Title = "KukemPremium", Content = "ESP: " .. (Config.ESP.Enabled and "BẬT" or "TẮT"), Duration = 2})
    end,
})

TabKey:CreateKeybind({
    Name = "Speed",
    CurrentKeybind = "LeftShift",
    HoldToInteract = false,
    Flag = "Key_Speed",
    Callback = function(key)
        Config.Speed.Enabled = not Config.Speed.Enabled
        if not Config.Speed.Enabled then
            local hum = getMyHum()
            if hum then hum.WalkSpeed = 16 end
        end
        Rayfield:Notify({Title = "KukemPremium", Content = "Speed: " .. (Config.Speed.Enabled and "BẬT" or "TẮT"), Duration = 2})
    end,
})

-- ═══════════════ TAB: INFO ═══════════════
TabInfo:CreateSection("Thông tin")
TabInfo:CreateLabel("🌕 KukemPremium — Gold Neon Edition")
TabInfo:CreateLabel("Executor: Delta · Fluxus · Hydrogen · Arceus X")
TabInfo:CreateLabel("Game: Blox Fruits")

TabInfo:CreateButton({
    Name = "Tắt toàn bộ chức năng",
    Callback = function()
        Config.SilentAim.Enabled = false
        Config.AutoSkill.Enabled = false
        Config.ESP.Enabled = false
        Config.Speed.Enabled = false
        local hum = getMyHum()
        if hum then hum.WalkSpeed = 16 end
        Rayfield:Notify({Title = "KukemPremium", Content = "Đã tắt toàn bộ chức năng", Duration = 3})
    end,
})

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
    -- FOV circle
    fovCircle.Radius = Config.SilentAim.FOV
    fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    fovCircle.Visible = Config.SilentAim.Enabled and Config.SilentAim.ShowFOV

    -- ESP
    updateESP()

    -- Speed
    if Config.Speed.Enabled then
        local hum = getMyHum()
        if hum then hum.WalkSpeed = Config.Speed.Value end
    end
end)

-- ═══════════════ INIT ESP ═══════════════
for _, p in ipairs(Players:GetPlayers()) do createESP(p) end
Players.PlayerAdded:Connect(createESP)
Players.PlayerRemoving:Connect(removeESP)

Rayfield:LoadConfiguration()

Rayfield:Notify({
    Title = "🌕 KukemPremium",
    Content = "Đã tải — Gold Neon Edition sẵn sàng",
    Duration = 5,
})

print("[KukemPremium] Loaded. Menu KuKemPremium sẵn sàng ✨")
