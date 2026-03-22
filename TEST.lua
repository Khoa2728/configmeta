local P_Serv = game:GetService("Players")
local LP = P_Serv.LocalPlayer
local SaveFile = "Config_Vip_" .. LP.UserId .. ".txt" 

local function FormatNumber(n)
    local left, num, right = string.match(tostring(math.floor(math.abs(n))), '^([^%d]*%d)(%d*)(.-)$')
    local formatted = left .. (num:reverse():gsub('(%d%d%d)', '%1.'):reverse()) .. right
    return (n < 0 and "-" or "") .. formatted
end

if not game:IsLoaded() then
    pcall(function() game.Loaded:Wait() end)
end

local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local StatsService = game:GetService("Stats")
local UserInputService = game:GetService("UserInputService")

local SafeGui = (type(gethui) == "function" and gethui()) or game:GetService("CoreGui") or (LP:FindFirstChild("PlayerGui") or LP:WaitForChild("PlayerGui", 10))

local Stats = {Kills = 0, Earned = 0}

pcall(function() 
    if isfile and isfile(SaveFile) then 
        local data = HttpService:JSONDecode(readfile(SaveFile))
        if data then 
            Stats.Kills = data.Kills or 0
            Stats.Earned = data.Earned or 0
        end
    end 
end)

local function Save() 
    pcall(function() 
        if writefile then
            writefile(SaveFile, HttpService:JSONEncode(Stats)) 
        end
    end) 
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

local MainGui = Instance.new("ScreenGui")
MainGui.Name = "BountyTracker_" .. LP.Name
MainGui.ResetOnSpawn = false
MainGui.Parent = SafeGui

local MainFrame = Instance.new("Frame", MainGui)
MainFrame.Size = UDim2.new(0, 320, 0, 130)
MainFrame.Position = UDim2.new(0.5, -160, 0.1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Thickness = 2
MakeDraggable(MainFrame)

local ToggleBtn = Instance.new("TextButton", MainGui)
ToggleBtn.Size = UDim2.new(0, 45, 0, 45)
ToggleBtn.Position = UDim2.new(0, 10, 0.5, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
ToggleBtn.Text = "VIP"
ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
ToggleBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)
local TStroke = Instance.new("UIStroke", ToggleBtn)
TStroke.Thickness = 2
ToggleBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

RunService.RenderStepped:Connect(function()
    local color = Color3.fromHSV(tick() % 5 / 5, 0.8, 1)
    MainStroke.Color = color
    TStroke.Color = color
end)

local function AddLabel(txt, pos, size, clr)
    local l = Instance.new("TextLabel", MainFrame)
    l.Size = size
    l.Position = pos
    l.BackgroundTransparency = 1
    l.Font = Enum.Font.GothamBold
    l.TextSize = 13
    l.TextColor3 = clr
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Text = txt
    return l
end

local BountyLbl = AddLabel("💎 BOUNTY: --", UDim2.new(0, 15, 0, 15), UDim2.new(0.5, -15, 0, 20), Color3.new(1,1,1))
local EarnedLbl = AddLabel("📈 EARNED: 0", UDim2.new(0, 15, 0, 40), UDim2.new(0.5, -15, 0, 20), Color3.fromRGB(0, 255, 150))
local KillsLbl  = AddLabel("⚔️ KILLS: 0", UDim2.new(0, 15, 0, 65), UDim2.new(0.5, -15, 0, 20), Color3.fromRGB(255, 80, 80))
local TimeLbl   = AddLabel("🕒 00:00:00", UDim2.new(0.5, 5, 0, 15), UDim2.new(0.5, -15, 0, 20), Color3.fromRGB(255, 200, 0))
local FPSLbl    = AddLabel("🚀 FPS: --", UDim2.new(0.5, 5, 0, 40), UDim2.new(0.5, -15, 0, 20), Color3.fromRGB(0, 200, 255))
local PingLbl   = AddLabel("📶 PING: --", UDim2.new(0.5, 5, 0, 65), UDim2.new(0.5, -15, 0, 20), Color3.fromRGB(200, 100, 255))

local ResetBtn = Instance.new("TextButton", MainFrame)
ResetBtn.Size = UDim2.new(0.9, 0, 0, 25)
ResetBtn.Position = UDim2.new(0.05, 0, 0.75, 0)
ResetBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
ResetBtn.Text = "RESET DATA (".. LP.Name ..")"
ResetBtn.TextColor3 = Color3.new(1, 0.6, 0.6)
ResetBtn.Font = Enum.Font.GothamBold
ResetBtn.TextSize = 11
Instance.new("UICorner", ResetBtn).CornerRadius = UDim.new(0, 4)

ResetBtn.MouseButton1Click:Connect(function() 
    Stats.Kills = 0
    Stats.Earned = 0
    Save()
end)

local StartTime = tick()
local leaderstats = LP:WaitForChild("leaderstats", 20)
local bounty_stat = leaderstats and leaderstats:WaitForChild("Bounty/Honor", 20)
local last_bounty = bounty_stat and bounty_stat.Value or 0

task.spawn(function()
    while task.wait(0.5) do
        local current_bounty = bounty_stat and bounty_stat.Value or 0
        
        if last_bounty ~= 0 and current_bounty ~= last_bounty then
            local diff = current_bounty - last_bounty
            Stats.Earned = Stats.Earned + diff
            if diff > 0 then
                Stats.Kills = Stats.Kills + 1
            end
            last_bounty = current_bounty
            Save()
        elseif last_bounty == 0 and current_bounty > 0 then
            last_bounty = current_bounty
        end

        BountyLbl.Text = "💎 BOUNTY: " .. FormatNumber(current_bounty)
        EarnedLbl.Text = "📈 EARNED: " .. (Stats.Earned >= 0 and "+" or "") .. FormatNumber(Stats.Earned)
        KillsLbl.Text = "⚔️ KILLS: " .. FormatNumber(Stats.Kills)
        
        local ping = 0
        pcall(function() ping = math.floor(StatsService.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
        PingLbl.Text = "📶 PING: " .. ping .. " ms"
        
        local d = tick() - StartTime
        TimeLbl.Text = string.format("🕒 %02d:%02d:%02d", math.floor(d/3600), math.floor((d%3600)/60), math.floor(d%60))
    end
end)

task.spawn(function()
    while task.wait(1) do
        FPSLbl.Text = "🚀 FPS: " .. math.floor(StatsService.Workspace.Heartbeat:GetValue())
    end
end)
