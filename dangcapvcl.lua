_G.WebhookURL = _G.WebhookURL or "" -- Dán link vào đây hoặc để ở script ngoài

repeat task.wait() until game:IsLoaded()

local P_Serv = game:GetService("Players")
local LP = P_Serv.LocalPlayer
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local SafeGui = (type(gethui) == "function" and gethui()) or game:GetService("CoreGui") or LP:WaitForChild("PlayerGui")

local function FormatNumber(n)
    local absN = math.abs(n)
    if absN >= 1000000 then return string.format("%.1fM", n / 1000000)
    elseif absN >= 1000 then return string.format("%.1fK", n / 1000)
    end return tostring(math.floor(n))
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
local LStroke = Instance.new("UIStroke", LFrame); LStroke.Thickness = 2

local LTitle = Instance.new("TextLabel", LFrame)
LTitle.Size = UDim2.new(1, 0, 0, 40); LTitle.Text = "INJECTING BOUNTY VIP..."; LTitle.TextColor3 = Color3.new(1,1,1)
LTitle.Font = Enum.Font.GothamBold; LTitle.TextSize = 16; LTitle.BackgroundTransparency = 1

local PBarBg = Instance.new("Frame", LFrame)
PBarBg.Size = UDim2.new(0.8, 0, 0, 6); PBarBg.Position = UDim2.new(0.1, 0, 0.7, 0)
PBarBg.BackgroundColor3 = Color3.fromRGB(30, 30, 40); Instance.new("UICorner", PBarBg)
local PBar = Instance.new("Frame", PBarBg)
PBar.Size = UDim2.new(0, 0, 1, 0); PBar.BackgroundColor3 = Color3.fromRGB(0, 255, 150); Instance.new("UICorner", PBar)

local stages = {"Loading Stats...", "Checking Webhook...", "Bypassing...", "Ready!"}
for i, msg in ipairs(stages) do
    LTitle.Text = msg
    TweenService:Create(PBar, TweenInfo.new(0.4), {Size = UDim2.new(i/#stages, 0, 1, 0)}):Play()
    task.wait(0.4)
end
LoadGui:Destroy()

local SaveFile = "Config_Vip_Stats.txt"
local Stats = {Kills = 0, Earned = 0}
pcall(function() if isfile(SaveFile) then Stats = HttpService:JSONDecode(readfile(SaveFile)) end end)
local function Save() pcall(function() writefile(SaveFile, HttpService:JSONEncode(Stats)) end) end

local bounty_stat = LP:WaitForChild("leaderstats"):WaitForChild("Bounty/Honor")
while bounty_stat.Value <= 0 do task.wait(0.5) end
local last_bounty = bounty_stat.Value

local function send_notif(title, display_gained, color)
    if not _G.WebhookURL or _G.WebhookURL == "" then return end
    local current_bounty = bounty_stat.Value
    local data = {
        ["embeds"] = {{
            ["title"] = "📈 " .. title,
            ["description"] = "Real-time report for: **@" .. LP.Name .. "**",
            ["color"] = color,
            ["fields"] = {
                {["name"] = "🏷️ Username", ["value"] = "```" .. LP.DisplayName .. "```", ["inline"] = true},
                {["name"] = "💰 Bounty (Current)", ["value"] = "```" .. tostring(current_bounty) .. "```", ["inline"] = true},
                {["name"] = "⚔️ Bounty Gained", ["value"] = "```" .. display_gained .. "```", ["inline"] = true},
                {["name"] = "✅ Status", ["value"] = "🟢 Online | Session Kills: " .. Stats.Kills, ["inline"] = false}
            },
            ["image"] = {["url"] = "https://photo.znews.vn/Uploaded/mdf_drkydd/2016_12_18/12.gif"},
            ["footer"] = {["text"] = "Bounty VIP Tracker • " .. os.date("%X")},
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }}
    }
    pcall(function()
        local req = (syn and syn.request or http_request or request or HttpPost)
        local payload = HttpService:JSONEncode(data)
        if req then req({Url = _G.WebhookURL, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = payload})
        else HttpService:PostAsync(_G.WebhookURL, payload) end
    end)
end

send_notif("INITIALIZED ⚔️", "+0", 16777215)

local MainGui = Instance.new("ScreenGui", SafeGui)
local MainFrame = Instance.new("Frame", MainGui)
MainFrame.Size = UDim2.new(0, 220, 0, 180); MainFrame.Position = UDim2.new(0.5, -110, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 12); Instance.new("UICorner", MainFrame)
local MainStroke = Instance.new("UIStroke", MainFrame); MainStroke.Thickness = 2; MakeDraggable(MainFrame)

local ToggleBtn = Instance.new("TextButton", MainGui)
ToggleBtn.Size = UDim2.new(0, 45, 0, 45); ToggleBtn.Position = UDim2.new(0.05, 0, 0.8, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(10, 10, 12); ToggleBtn.Text = "VIP"; ToggleBtn.Font = Enum.Font.GothamBold; ToggleBtn.TextSize = 12
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)
local TStroke = Instance.new("UIStroke", ToggleBtn); TStroke.Thickness = 2; MakeDraggable(ToggleBtn)
ToggleBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

RunService.RenderStepped:Connect(function()
    local color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
    MainStroke.Color = color; TStroke.Color = color
end)

local function AddRow(txt, pos, clr)
    local l = Instance.new("TextLabel", MainFrame)
    l.Size = UDim2.new(1, -20, 0, 25); l.Position = pos; l.BackgroundTransparency = 1
    l.Font = Enum.Font.GothamBold; l.TextSize = 13; l.TextColor3 = clr; l.TextXAlignment = Enum.TextXAlignment.Left; l.Text = txt
    return l
end

local BountyLbl = AddRow("💎 BOUNTY: --", UDim2.new(0, 15, 0, 15), Color3.new(1,1,1))
local EarnedLbl = AddRow("📈 EARNED: 0", UDim2.new(0, 15, 0, 45), Color3.fromRGB(0, 255, 150))
local KillsLbl  = AddRow("⚔️ KILLS: 0", UDim2.new(0, 15, 0, 75), Color3.fromRGB(255, 80, 80))
local TimeLbl   = AddRow("🕒 TIME: 00:00:00", UDim2.new(0, 15, 0, 105), Color3.fromRGB(255, 200, 0))

local ResetBtn = Instance.new("TextButton", MainFrame)
ResetBtn.Size = UDim2.new(0.7, 0, 0, 25); ResetBtn.Position = UDim2.new(0.15, 0, 0.8, 0)
ResetBtn.BackgroundColor3 = Color3.fromRGB(30, 10, 10); ResetBtn.Text = "RESET DATA"; ResetBtn.TextColor3 = Color3.new(1, 0.4, 0.4); ResetBtn.Font = Enum.Font.GothamBold; ResetBtn.TextSize = 11
Instance.new("UICorner", ResetBtn)
ResetBtn.MouseButton1Click:Connect(function() Stats.Kills = 0; Stats.Earned = 0; Save() end)

local StartTime = tick()

task.spawn(function()
    while task.wait(1) do
        local current_bounty = bounty_stat.Value
        if current_bounty ~= last_bounty then
            local diff = current_bounty - last_bounty
            local prefix = (diff > 0) and "+" or ""
            
            send_notif("BOUNTY UPDATE ✅", prefix .. tostring(diff), (diff > 0 and 65280 or 16711680))
            
            Stats.Earned = Stats.Earned + diff
            last_bounty = current_bounty
            Save()
        end
        
        BountyLbl.Text = "💎 BOUNTY: " .. FormatNumber(current_bounty)
        EarnedLbl.Text = "📈 EARNED: " .. (Stats.Earned >= 0 and "+" or "") .. FormatNumber(Stats.Earned)
        KillsLbl.Text = "⚔️ KILLS: " .. Stats.Kills
        local d = tick() - StartTime
        TimeLbl.Text = string.format("🕒 TIME: %02d:%02d:%02d", math.floor(d/3600), math.floor((d%3600)/60), math.floor(d%60))
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        local t = getgenv().LockedTarget
        if t and t:FindFirstChild("Humanoid") and t.Humanoid.Health > 0 and not t.Humanoid:FindFirstChild("Tag") then
            local tag = Instance.new("BoolValue", t.Humanoid); tag.Name = "Tag"
            t.Humanoid.Died:Connect(function() 
                Stats.Kills = Stats.Kills + 1
                Save() 
            end)
        end
    end
end)
