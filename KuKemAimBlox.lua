local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- ============================================================
-- SERVICES
-- ============================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ============================================================
-- CONFIG
-- ============================================================
local Config = {
    SilentAim = { Enabled=false, TeamCheck=true, WallCheck=false, FOV=120, TargetPart="Head", ShowFOV=true },
    AutoSkill = { Enabled=false, Skills={"Z","X","C","V"}, WaitBetween=0.6, AutoClick=true },
    ESP = { Enabled=false, ShowBox=true, ShowName=true, ShowHealth=true, ShowDistance=true, MaxDistance=1000, TeamCheck=true },
    Speed = { Enabled=false, Value=50 },
}

-- ============================================================
-- WINDOW VÀNG NEON
-- ============================================================
local Window = Rayfield:CreateWindow({
    Name = "🌕 KukemPremium",
    LoadingTitle = "KukemPremium đang tải...",
    LoadingSubtitle = "by dj",
    ConfigurationSaving = { Enabled=true, FolderName="KukemPremium", FileName="BF_Config" },
    Discord = { Enabled=false },
    KeySystem = false,
})

-- Màu vàng neon
Rayfield:ChangeTheme({
    Background = Color3.fromRGB(15, 12, 0),
    Primary = Color3.fromRGB(255, 200, 40),
    Secondary = Color3.fromRGB(255, 170, 0),
    Tertiary = Color3.fromRGB(35, 28, 5),
    Text = Color3.fromRGB(255, 245, 210),
    Accent = Color3.fromRGB(255, 215, 0),
})
Rayfield:ChangeColor(Color3.fromRGB(255, 200, 40), 0)

-- ============================================================
-- TABS
-- ============================================================
local TabAim = Window:CreateTab("🎯 Silent Aim", 4483362458)
local TabSkill = Window:CreateTab("⚔️ Auto Skill", 4483362458)
local TabESP = Window:CreateTab("👁️ ESP", 4483362458)
local TabSpeed = Window:CreateTab("⚡ Speed", 4483362458)
local TabSettings = Window:CreateTab("⚙️ Cài đặt", 4483362458)

-- ============================================================
-- SECTION: SILENT AIM
-- ============================================================
local AimSection = TabAim:CreateSection("Cấu hình Silent Aim")

TabAim:CreateToggle({
    Name = "Bật Silent Aim",
    CurrentValue = false,
    Flag = "SilentAim_Enabled",
    Callback = function(v) Config.SilentAim.Enabled = v end,
})

TabAim:CreateToggle({
    Name = "Kiểm tra đồng đội",
    CurrentValue = true,
    Flag = "SilentAim_TeamCheck",
    Callback = function(v) Config.SilentAim.TeamCheck = v end,
})

TabAim:CreateToggle({
    Name = "Kiểm tra tường",
    CurrentValue = false,
    Flag = "SilentAim_WallCheck",
    Callback = function(v) Config.SilentAim.WallCheck = v end,
})

TabAim:CreateToggle({
    Name = "Hiển thị vòng FOV",
    CurrentValue = true,
    Flag = "SilentAim_ShowFOV",
    Callback = function(v) Config.SilentAim.ShowFOV = v end,
})

TabAim:CreateSlider({
    Name = "FOV",
    Range = {10, 500},
    Increment = 10,
    Suffix = "px",
    CurrentValue = 120,
    Flag = "SilentAim_FOV",
    Callback = function(v) Config.SilentAim.FOV = v end,
})

TabAim:CreateDropdown({
    Name = "Vị trí ngắm",
    Options = {"Head", "HumanoidRootPart", "UpperTorso"},
    CurrentOption = {"Head"},
    Flag = "SilentAim_Part",
    Callback = function(opt)
        Config.SilentAim.TargetPart = opt[1] or "Head"
    end,
})

-- ============================================================
-- SECTION: AUTO SKILL
-- ============================================================
local SkillSection = TabSkill:CreateSection("Cấu hình Skill")

TabSkill:CreateToggle({
    Name = "Bật Auto Skill",
    CurrentValue = false,
    Flag = "AutoSkill_Enabled",
    Callback = function(v)
        Config.AutoSkill.Enabled = v
        if v then task.spawn(autoSkillLoop) end
    end,
})

TabSkill:CreateToggle({
    Name = "Auto Click",
    CurrentValue = true,
    Flag = "AutoSkill_Click",
    Callback = function(v) Config.AutoSkill.AutoClick = v end,
})

TabSkill:CreateSlider({
    Name = "Delay giữa các skill",
    Range = {0, 3},
    Increment = 0.1,
    Suffix = "s",
    CurrentValue = 0.6,
    Flag = "AutoSkill_Wait",
    Callback = function(v) Config.AutoSkill.WaitBetween = v end,
})

TabSkill:CreateInput({
    Name = "Danh sách phím (VD: Z,X,C,V)",
    CurrentValue = "Z,X,C,V",
    PlaceholderText = "Z,X,C,V",
    RemoveTextAfterFocusLost = false,
    Flag = "AutoSkill_Keys",
    Callback = function(txt)
        local list = {}
        for k in string.gmatch(txt, "[^,]+") do
            table.insert(list, (k:gsub("%s+", "")))
        end
        Config.AutoSkill.Skills = list
    end,
})

-- ============================================================
-- SECTION: ESP
-- ============================================================
local ESPSection = TabESP:CreateSection("Cấu hình ESP")

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
    Flag = "ESP_Health",
    Callback = function(v) Config.ESP.ShowHealth = v end,
})

TabESP:CreateToggle({
    Name = "Hiển thị Khoảng cách",
    CurrentValue = true,
    Flag = "ESP_Distance",
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
    Flag = "ESP_MaxDist",
    Callback = function(v) Config.ESP.MaxDistance = v end,
})

-- ============================================================
-- SECTION: SPEED 1-1000
-- ============================================================
local SpeedSection = TabSpeed:CreateSection("Tốc độ chạy (1 - 1000)")

TabSpeed:CreateToggle({
    Name = "Bật Speed Hack",
    CurrentValue = false,
    Flag = "Speed_Enabled",
    Callback = function(v)
        Config.Speed.Enabled = v
        if not v then
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = 16 end
        end
    end,
})

TabSpeed:CreateSlider({
    Name = "Tốc độ",
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
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = 16 end
    end,
})

-- ============================================================
-- SETTINGS
-- ============================================================
TabSettings:CreateSection("Thông tin")
TabSettings:CreateLabel("🌕 KukemPremium | Gold Neon Edition")
TabSettings:CreateLabel("Executor: Delta / Fluxus / Hydrogen")
TabSettings:CreateLabel("Game: Blox Fruits")

TabSettings:CreateButton({
    Name = "Hủy tất cả chức năng",
    Callback = function()
        Config.SilentAim.Enabled = false
        Config.AutoSkill.Enabled = false
        Config.ESP.Enabled = false
        Config.Speed.Enabled = false
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = 16 end
    end,
})

-- ============================================================
-- LOGIC: NEAREST PLAYER
-- ============================================================
local function getNearestPlayer()
    local nearest, shortest = nil, Config.SilentAim.FOV
    local char = LocalPlayer.Character
    if not char then return nil end
    local myRoot = char:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            local head = p.Character:FindFirstChild("Head")
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hrp and head and hum and hum.Health > 0 then
                if Config.SilentAim.TeamCheck and p.Team == LocalPlayer.Team then
                    -- skip
                else
                    local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                    if onScreen then
                        local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
                        local mag = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                        if mag < shortest then
                            shortest = mag
                            nearest = p
                        end
                    end
                end
            end
        end
    end
    return nearest
end

local function isVisible(part)
    if not Config.SilentAim.WallCheck then return true end
    local ray = Ray.new(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * 500)
    local hit = Workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, part.Parent})
    return hit == nil
end

-- ============================================================
-- HOOK SILENT AIM
-- ============================================================
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    if Config.SilentAim.Enabled and (method == "FindPartOnRay" or method == "Raycast") then
        local target = getNearestPlayer()
        if target and target.Character then
            local aimPart = target.Character:FindFirstChild(Config.SilentAim.TargetPart)
            if aimPart and isVisible(aimPart) then
                if method == "FindPartOnRay" then
                    args[1] = Ray.new(Camera.CFrame.Position, (aimPart.Position - Camera.CFrame.Position).Unit * 500)
                elseif method == "Raycast" then
                    args[2] = (aimPart.Position - Camera.CFrame.Position).Unit * 500
                end
            end
        end
    end
    return oldNamecall(self, unpack(args))
end)

-- ============================================================
-- AUTO SKILL LOOP
-- ============================================================
local function pressKey(key)
    local vk = Enum.KeyCode[key]
    if vk then
        keypress(vk); task.wait(0.05); keyrelease(vk)
    end
end

function autoSkillLoop()
    while Config.AutoSkill.Enabled do
        local char = LocalPlayer.Character
        if char and char:FindFirstChildOfClass("Humanoid") then
            for _, k in ipairs(Config.AutoSkill.Skills) do
                if not Config.AutoSkill.Enabled then break end
                pressKey(k)
                task.wait(Config.AutoSkill.WaitBetween)
            end
            if Config.AutoSkill.AutoClick then
                mouse1click(); task.wait(0.1)
            end
        end
        task.wait(0.1)
    end
end

-- ============================================================
-- ESP SYSTEM
-- ============================================================
local espObjects = {}

local function createESP(player)
    if player == LocalPlayer then return end
    local box = Drawing.new("Square")
    box.Visible=false; box.Thickness=1; box.Filled=false; box.Color=Color3.fromRGB(255,200,40)
    local name = Drawing.new("Text"); name.Size=14; name.Center=true; name.Outline=true
    name.Color=Color3.fromRGB(255,245,210); name.Visible=false
    local health = Drawing.new("Text"); health.Size=14; health.Center=true; health.Outline=true
    health.Color=Color3.fromRGB(0,255,80); health.Visible=false
    local dist = Drawing.new("Text"); dist.Size=13; dist.Center=true; dist.Outline=true
    dist.Color=Color3.fromRGB(255,200,40); dist.Visible=false
    espObjects[player] = {box=box, name=name, health=health, dist=dist}
end

local function removeESP(player)
    local o = espObjects[player]
    if o then for _, v in pairs(o) do v:Remove() end; espObjects[player]=nil end
end

local function updateESP()
    for p, o in pairs(espObjects) do
        local show = Config.ESP.Enabled and p.Character
        if show then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            local head = p.Character:FindFirstChild("Head")
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if not (hrp and head and hum and hum.Health > 0) then show = false end
            if Config.ESP.TeamCheck and p.Team == LocalPlayer.Team then show = false end
            local dst = hrp and (hrp.Position - Camera.CFrame.Position).Magnitude or 0
            if dst > Config.ESP.MaxDistance then show = false end
            if show then
                local screen, on = Camera:WorldToViewportPoint(hrp.Position)
                if not on then show = false end
                if show then
                    local headScreen = Camera:WorldToViewportPoint(head.Position)
                    local h = math.abs(headScreen.Y - screen.Y)
                    local w = h / 2
                    o.box.Size = Vector2.new(w, h)
                    o.box.Position = Vector2.new(screen.X - w/2, screen.Y - h/2)
                    o.box.Visible = Config.ESP.ShowBox
                    o.name.Text = p.Name
                    o.name.Position = Vector2.new(screen.X, screen.Y - h/2 - 22)
                    o.name.Visible = Config.ESP.ShowName
                    o.health.Text = "HP: " .. math.floor(hum.Health)
                    o.health.Position = Vector2.new(screen.X, screen.Y - h/2 - 6)
                    o.health.Visible = Config.ESP.ShowHealth
                    o.dist.Text = math.floor(dst) .. "s"
                    o.dist.Position = Vector2.new(screen.X, screen.Y + h/2 + 4)
                    o.dist.Visible = Config.ESP.ShowDistance
                end
            end
        end
        if not show then
            for _, v in pairs(o) do v.Visible = false end
        end
    end
end

-- ============================================================
-- SPEED + FOV + ESP LOOP
-- ============================================================
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness=1.5; fovCircle.NumSides=80; fovCircle.Filled=false
fovCircle.Color=Color3.fromRGB(255,200,40); fovCircle.Visible=false

RunService.RenderStepped:Connect(function()
    fovCircle.Radius = Config.SilentAim.FOV
    fovCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    fovCircle.Visible = Config.SilentAim.Enabled and Config.SilentAim.ShowFOV
    updateESP()
    if Config.Speed.Enabled then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = Config.Speed.Value end
    end
end)

for _, p in ipairs(Players:GetPlayers()) do createESP(p) end
Players.PlayerAdded:Connect(createESP)
Players.PlayerRemoving:Connect(removeESP)

Rayfield:LoadConfiguration()

print("[KukemPremium] Đã tải — Menu KuKemPremium sẵn sàng ✨")