repeat task.wait() until game:IsLoaded()

local P_Serv = game:GetService("Players")
local LP = P_Serv.LocalPlayer
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local StatsService = game:GetService("Stats")

local SafeGui = (type(gethui) == "function" and gethui()) or game:GetService("CoreGui") or LP:WaitForChild("PlayerGui")

local SaveFile = "Config_Vip_Stats.txt"
local Stats = {Kills = 0, Earned = 0}
local SessionKills = 0

pcall(function() 
    if isfile and isfile(SaveFile) then 
        local data = HttpService:JSONDecode(readfile(SaveFile))
        if data then Stats = data end
    end 
end)

local function Save() 
    pcall(function() 
        if writefile then
            writefile(SaveFile, HttpService:JSONEncode(Stats)) 
        end
    end) 
end

local function FormatNumber(n)
    local absN = math.abs(n)
    if absN >= 1000000 then 
        local val = n / 1000000
        return string.format(val % 1 == 0 and "%dM" or "%.1fM", val)
    elseif absN >= 1000 then 
        local val = n / 1000
        return string.format(val % 1 == 0 and "%dK" or "%.1fK", val)
    end 
    return tostring(math.floor(n))
end

local function MakeDraggable(gui)
    local dragging, dragInput, dragStart, startPos
    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = gui.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    gui.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

local LoadGui = Instance.new("ScreenGui", SafeGui)
local LFrame = Instance.new("Frame", LoadGui)
LFrame.Size = UDim2.new(0, 300, 0, 120); LFrame.Position = UDim2.new(0.5, -150, 0.5, -60)
LFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15); Instance.new("UICorner", LFrame)
local LStroke = Instance.new("UIStroke", LFrame); LStroke.Thickness = 2; LStroke.Color = Color3.fromRGB(0, 255, 150)

local LTitle = Instance.new("TextLabel", LFrame)
LTitle.Size = UDim2.new(1, 0, 0, 40); LTitle.Text = "INJECTING BOUNTY VIP..."; LTitle.TextColor3 = Color3.new(1,1,1)
LTitle.Font = Enum.Font.GothamBold; LTitle.TextSize = 16; LTitle.BackgroundTransparency = 1

local PBarBg = Instance.new("Frame", LFrame)
PBarBg.Size = UDim2.new(0.8, 0, 0, 6); PBarBg.Position = UDim2.new(0.1, 0, 0.7, 0)
PBarBg.BackgroundColor3 = Color3.fromRGB(30, 30, 40); Instance.new("UICorner", PBarBg)
local PBar = Instance.new("Frame", PBarBg)
PBar.Size = UDim2.new(0, 0, 1, 0); PBar.BackgroundColor3 = Color3.fromRGB(0, 255, 150); Instance.new("UICorner", PBar)

local stages = {"Loading Stats...", "Optimizing UI...", "Config VIP by khoa...", "Ready!"}
for i, msg in ipairs(stages) do
    LTitle.Text = msg
    TweenService:Create(PBar, TweenInfo.new(0.3), {Size = UDim2.new(i/#stages, 0, 1, 0)}):Play()
    task.wait(0.3)
end
LoadGui:Destroy()

local bounty_stat = LP:WaitForChild("leaderstats"):WaitForChild("Bounty/Honor")
while bounty_stat.Value <= 0 do task.wait(0.5) end
local last_bounty = bounty_stat.Value

local MainGui = Instance.new("ScreenGui", SafeGui)
local MainFrame = Instance.new("Frame", MainGui)
MainFrame.Size = UDim2.new(0, 220, 0, 230); MainFrame.Position = UDim2.new(0.5, -110, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 12); Instance.new("UICorner", MainFrame)
local MainStroke = Instance.new("UIStroke", MainFrame); MainStroke.Thickness = 2; MakeDraggable(MainFrame)

local ToggleBtn = Instance.new("TextButton", MainGui)
ToggleBtn.Size = UDim2.new(0, 45, 0, 45); ToggleBtn.Position = UDim2.new(0.05, 0, 0.8, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(10, 10, 12); ToggleBtn.Text = "VIP"; ToggleBtn.Font = Enum.Font.GothamBold; ToggleBtn.TextSize = 12; ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)
local TStroke = Instance.new("UIStroke", ToggleBtn); TStroke.Thickness = 2; MakeDraggable(ToggleBtn)
ToggleBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

RunService.RenderStepped:Connect(function()
    local color = Color3.fromHSV(tick() % 5 / 5, 0.8, 1)
    MainStroke.Color = color; TStroke.Color = color
end)

local function AddRow(txt, pos, clr)
    local l = Instance.new("TextLabel", MainFrame)
    l.Size = UDim2.new(1, -20, 0, 25); l.Position = pos; l.BackgroundTransparency = 1
    l.Font = Enum.Font.GothamBold; l.TextSize = 13; l.TextColor3 = clr; l.TextXAlignment = Enum.TextXAlignment.Left; l.Text = txt
    return l
end

local CreditLbl = AddRow("Config VIP by khoa", UDim2.new(0, 15, 0, 5), Color3.fromRGB(255, 255, 255))
CreditLbl.TextSize = 10; CreditLbl.TextTransparency = 0.5; CreditLbl.TextXAlignment = Enum.TextXAlignment.Center
Instance.new("UIStroke", CreditLbl).Thickness = 0.5

local BountyLbl = AddRow("💎 BOUNTY: --", UDim2.new(0, 15, 0, 25), Color3.new(1,1,1))
local EarnedLbl = AddRow("📈 EARNED: 0", UDim2.new(0, 15, 0, 50), Color3.fromRGB(0, 255, 150))
local KillsLbl  = AddRow("⚔️ KILLS: 0", UDim2.new(0, 15, 0, 75), Color3.fromRGB(255, 80, 80))
local TimeLbl   = AddRow("🕒 TIME: 00:00:00", UDim2.new(0, 15, 0, 100), Color3.fromRGB(255, 200, 0))
local FPSLbl    = AddRow("🚀 FPS: --", UDim2.new(0, 15, 0, 125), Color3.fromRGB(0, 200, 255))
local PingLbl   = AddRow("📶 PING: --", UDim2.new(0, 15, 0, 150), Color3.fromRGB(200, 100, 255))

local ResetBtn = Instance.new("TextButton", MainFrame)
ResetBtn.Size = UDim2.new(0.7, 0, 0, 25); ResetBtn.Position = UDim2.new(0.15, 0, 0.85, 0)
ResetBtn.BackgroundColor3 = Color3.fromRGB(30, 10, 10); ResetBtn.Text = "RESET DATA"; ResetBtn.TextColor3 = Color3.new(1, 0.4, 0.4); ResetBtn.Font = Enum.Font.GothamBold; ResetBtn.TextSize = 11
Instance.new("UICorner", ResetBtn)
ResetBtn.MouseButton1Click:Connect(function() 
    Stats.Kills = 0; Stats.Earned = 0; SessionKills = 0; Save() 
    EarnedLbl.Text = "📈 EARNED: 0"; KillsLbl.Text = "⚔️ KILLS: 0"
end)

local StartTime = tick()
local FPS = 0
local LastKillUpdate = 0

task.spawn(function()
    while task.wait(0.1) do
        local fr = 1 / RunService.RenderStepped:Wait()
        FPS = math.floor(fr)
        local ping = math.floor(StatsService.Network.ServerStatsItem["Data Ping"]:GetValue())
        
        local current_bounty = bounty_stat.Value
        if current_bounty ~= last_bounty then
            local diff = current_bounty - last_bounty
            Stats.Earned = Stats.Earned + diff
            
            if diff > 500 and (tick() - LastKillUpdate) > 1 then 
                SessionKills = SessionKills + 1
                Stats.Kills = Stats.Kills + 1
                LastKillUpdate = tick()
            end

            last_bounty = current_bounty
            Save()
        end
        
        BountyLbl.Text = "💎 BOUNTY: " .. FormatNumber(current_bounty)
        
        if Stats.Earned == 0 then
            EarnedLbl.Text = "📈 EARNED: 0"
        else
            EarnedLbl.Text = "📈 EARNED: " .. (Stats.Earned > 0 and "+" or "") .. FormatNumber(Stats.Earned)
        end

        KillsLbl.Text = "⚔️ KILLS: " .. SessionKills .. " (" .. Stats.Kills .. ")"
        FPSLbl.Text = "🚀 FPS: " .. FPS
        PingLbl.Text = "📶 PING: " .. ping .. " ms"
        
        local d = tick() - StartTime
        TimeLbl.Text = string.format("🕒 TIME: %02d:%02d:%02d", math.floor(d/3600), math.floor((d%3600)/60), math.floor(d%60))
    end
end)

task.spawn(function()
    while task.wait(0.3) do
        local target = getgenv().LockedTarget or getgenv().CurrentTarget or getgenv().enemy
        
        if target and target:FindFirstChild("Humanoid") then
            local hum = target.Humanoid
            if hum.Health > 0 and not hum:FindFirstChild("VipTag") then
                pcall(function()
                    local tag = Instance.new("BoolValue", hum); tag.Name = "VipTag"
                    hum.Died:Connect(function() 
                        SessionKills = SessionKills + 1
                        Stats.Kills = Stats.Kills + 1
                        LastKillUpdate = tick()
                        Save() 
                    end)
                end)
            end
        end
        
        for _, p in pairs(P_Serv:GetPlayers()) do
            if p ~= LP and p.Character and p.Character:FindFirstChild("Humanoid") then
                local hum = p.Character.Humanoid
                if hum.Health > 0 and hum.Health < 30 and not hum:FindFirstChild("VipTag") then
                    if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("HumanoidRootPart") then
                        local dist = (LP.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
                        if dist < 65 then
                            pcall(function()
                                local tag = Instance.new("BoolValue", hum); tag.Name = "VipTag"
                                hum.Died:Connect(function()
                                    SessionKills = SessionKills + 1
                                    Stats.Kills = Stats.Kills + 1
                                    LastKillUpdate = tick()
                                    Save()
                                end)
                            end)
                        end
                    end
                end
            end
        end
    end
end)
