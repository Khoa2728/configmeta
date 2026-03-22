repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer
local P_Serv = game:GetService("Players")
local LP = P_Serv.LocalPlayer
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local StatsService = game:GetService("Stats")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")

_G.WebhookURL = _G.WebhookURL or ""
local Settings = {
    HitboxSize = 50,
    HitboxTransparency = 0.8,
    AttackSpeed = 0.1,
    AttackDistance = 65,
    CameraSmooth = true,
    AntiStuck = true
}

local SafeGui = (type(gethui) == "function" and gethui()) or game:GetService("CoreGui") or (LP:FindFirstChild("PlayerGui") or LP:WaitForChild("PlayerGui", 10))
local Stats = {Kills = 0, Earned = 0}
local SaveFile = "Config_Vip_Stats.txt"

pcall(function() 
    if isfile and isfile(SaveFile) then 
        local data = HttpService:JSONDecode(readfile(SaveFile))
        if data then Stats.Kills = data.Kills or 0; Stats.Earned = data.Earned or 0 end
    end 
end)

local function Save() pcall(function() if writefile then writefile(SaveFile, HttpService:JSONEncode(Stats)) end end) end

local function ExecuteAttack()
    pcall(function()
        local Tool = LP.Character and LP.Character:FindFirstChildOfClass("Tool")
        if Tool then
            VirtualUser:CaptureController()
            VirtualUser:ClickButton1(Vector2.new(0,0))
            local CombatRemote = game:GetService("ReplicatedStorage"):FindFirstChild("Combat") or game:GetService("ReplicatedStorage"):FindFirstChild("RigControllerEvent")
            if CombatRemote then
                if CombatRemote.Name == "RigControllerEvent" then CombatRemote:FireServer("WeaponClick") else CombatRemote:FireServer() end
            end
        end
    end)
end

local MainGui = Instance.new("ScreenGui", SafeGui); MainGui.Name = "BountyTracker_UltraVip"
local ToggleBtn = Instance.new("TextButton", MainGui)
ToggleBtn.Size = UDim2.new(0, 45, 0, 45); ToggleBtn.Position = UDim2.new(0.02, 0, 0.5, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15); ToggleBtn.Text = "VIP"; ToggleBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)
local TStroke = Instance.new("UIStroke", ToggleBtn); TStroke.Thickness = 2

local MainFrame = Instance.new("Frame", MainGui)
MainFrame.Size = UDim2.new(0, 320, 0, 140); MainFrame.Position = UDim2.new(0.5, -160, 0.1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 12); Instance.new("UICorner", MainFrame)
local MainStroke = Instance.new("UIStroke", MainFrame); MainStroke.Thickness = 2

ToggleBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

local function AddLabel(txt, pos, clr)
    local l = Instance.new("TextLabel", MainFrame)
    l.Size = UDim2.new(0.5, -15, 0, 20); l.Position = pos; l.BackgroundTransparency = 1
    l.Font = Enum.Font.GothamBold; l.TextSize = 11; l.TextColor3 = clr; l.Text = txt; return l
end

local BountyLbl = AddLabel("💎 BOUNTY: --", UDim2.new(0, 15, 0, 15), Color3.new(1,1,1))
local EarnedLbl = AddLabel("📈 EARNED: 0", UDim2.new(0, 15, 0, 40), Color3.fromRGB(0, 255, 150))
local KillsLbl  = AddLabel("⚔️ KILLS: 0", UDim2.new(0, 15, 0, 65), Color3.fromRGB(255, 80, 80))
local TimeLbl   = AddLabel("🕒 TIME: --", UDim2.new(0.5, 5, 0, 15), Color3.fromRGB(255, 200, 0))
local FPSLbl    = AddLabel("🚀 FPS: --", UDim2.new(0.5, 5, 0, 40), Color3.fromRGB(0, 200, 255))
local PingLbl   = AddLabel("📶 PING: --", UDim2.new(0.5, 5, 0, 65), Color3.fromRGB(200, 100, 255))

local ResetBtn = Instance.new("TextButton", MainFrame)
ResetBtn.Size = UDim2.new(0.9, 0, 0, 25); ResetBtn.Position = UDim2.new(0.05, 0, 0.75, 0)
ResetBtn.Text = "RESET DATA"; ResetBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
ResetBtn.TextColor3 = Color3.new(1,0.5,0.5); Instance.new("UICorner", ResetBtn)

ResetBtn.MouseButton1Click:Connect(function() Stats.Kills = 0; Stats.Earned = 0; Save(); EarnedLbl.Text = "📈 EARNED: 0"; KillsLbl.Text = "⚔️ KILLS: 0" end)

task.spawn(function()
    while task.wait(0.6) do
        pcall(function()
            local s = Vector3.new(Settings.HitboxSize, Settings.HitboxSize, Settings.HitboxSize)
            -- Quái
            if workspace:FindFirstChild("Enemies") then
                for _, v in pairs(workspace.Enemies:GetChildren()) do
                    local hrp = v:FindFirstChild("HumanoidRootPart")
                    if hrp and hrp.Size ~= s then
                        hrp.Size = s; hrp.Transparency = Settings.HitboxTransparency
                        hrp.CanCollide = false
                    end
                end
            end
            -- Người chơi
            for _, p in pairs(P_Serv:GetPlayers()) do
                if p ~= LP and p.Character then
                    local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                    if hrp and hrp.Size ~= s then
                        hrp.Size = s; hrp.Transparency = Settings.HitboxTransparency
                        hrp.CanCollide = false
                    end
                end
            end
        end)
    end
end)

local lastJump = 0
RunService.RenderStepped:Connect(function()
    local char = LP.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    if root and hum then
        if Settings.CameraSmooth then
            local cam = workspace.CurrentCamera
            local goal = CFrame.new(root.Position + Vector3.new(0, 4.5, 0)) * root.CFrame.Rotation * CFrame.new(0, 10, 30)
            cam.CFrame = cam.CFrame:Lerp(goal, 0.2)
        end
        if tick() - lastJump >= 3 then hum.Jump = true; lastJump = tick() end
    end
    -- Rainbow UI
    local c = Color3.fromHSV(tick() % 5 / 5, 0.8, 1)
    MainStroke.Color = c; TStroke.Color = c
end)

task.spawn(function()
    local last_bounty = 0
    local StartTime = tick()
    
    while task.wait(0.1) do
        -- Anti-Stuck di chuyển nhẹ
        if Settings.AntiStuck then
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.W, false, game)
            task.wait(0.1)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.W, false, game)
        end

        for _, p in pairs(P_Serv:GetPlayers()) do
            if p ~= LP and p.Character and p.Character:FindFirstChild("Humanoid") then
                local hum = p.Character.Humanoid
                local root = p.Character:FindFirstChild("HumanoidRootPart")
                local myRoot = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                
                if hum.Health > 0 and myRoot and root then
                    local dist = (myRoot.Position - root.Position).Magnitude
                    if dist < 100 then
                        if not hum:FindFirstChild("VipTag") then
                            local tag = Instance.new("BoolValue", hum); tag.Name = "VipTag"
                            hum.Died:Connect(function() if dist < 100 then Stats.Kills = Stats.Kills + 1; Save() end end)
                        end
                        if dist <= Settings.AttackDistance then ExecuteAttack() end
                    end
                end
            end
        end

        local b_stat = LP.leaderstats and LP.leaderstats:FindFirstChild("Bounty/Honor")
        if b_stat then
            local current_b = b_stat.Value
            if last_bounty == 0 then last_bounty = current_b end
            if current_b ~= last_bounty then
                local diff = current_b - last_bounty
                Stats.Earned = Stats.Earned + diff
                last_bounty = current_b; Save()
            end
            BountyLbl.Text = "💎 BOUNTY: "..current_b
            EarnedLbl.Text = "📈 EARNED: "..(Stats.Earned >= 0 and "+" or "")..Stats.Earned
            KillsLbl.Text = "⚔️ KILLS: "..Stats.Kills
            FPSLbl.Text = "🚀 FPS: "..math.floor(1/RunService.RenderStepped:Wait())
            PingLbl.Text = "📶 PING: "..math.floor(StatsService.Network.ServerStatsItem["Data Ping"]:GetValue()).."ms"
            local d = tick() - StartTime; TimeLbl.Text = string.format("🕒 TIME: %02d:%02d:%02d", d/3600, (d%3600)/60, d%60)
        end
    end
end)
