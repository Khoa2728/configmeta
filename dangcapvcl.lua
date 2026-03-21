local HttpService = game:GetService("HttpService")

local Players = game:GetService("Players")

local player = Players.LocalPlayer

local WEBHOOK_URL = _G.WebhookURL



if not WEBHOOK_URL or WEBHOOK_URL == "" then

    warn("⚠️ [LỖI] Chưa nhập link Webhook vào biến _G.WebhookURL")

    return

end




local stats = player:WaitForChild("leaderstats", 10)

local bounty_stat = stats and stats:WaitForChild("Bounty/Honor", 10)



if not bounty_stat then

    warn("⚠️ [LỖI] Không tìm thấy chỉ số Bounty/Honor")

    return

end




local last_bounty = bounty_stat.Value



function send_notif(status_title, display_gained, color)

    local current_bounty = bounty_stat.Value

    

    local data = {

        ["embeds"] = {{

            ["title"] = "📈 " .. status_title,

            ["description"] = "Real-time report for: **@" .. player.Name .. "**",

            ["color"] = color,

            ["fields"] = {

                {

                    ["name"] = "🏷️ Username",

                    ["value"] = "```" .. player.DisplayName .. "```",

                    ["inline"] = true

                },

                {

                    ["name"] = "💰 Bounty/Honor (Current)",

                    ["value"] = "```" .. tostring(current_bounty) .. "```",

                    ["inline"] = true

                },

                {

                    ["name"] = "⚔️ Bounty/Honor Gained",

                    ["value"] = "```" .. display_gained .. "```",

                    ["inline"] = true

                },

                {

                    ["name"] = "✅ Status",

                    ["value"] = "🟢 Online",

                    ["inline"] = false

                }

            },

            ["image"] = {

                ["url"] = "https://photo.znews.vn/Uploaded/mdf_drkydd/2016_12_18/12.gif" 

            },

            ["footer"] = {

                ["text"] = "Script by tuitenphaa • " .. os.date("%X"),

            },

            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")

        }}

    }



    local payload = HttpService:JSONEncode(data)

    pcall(function()

        local req = (syn and syn.request or http_request or request or HttpPost)

        if req then

            req({Url = WEBHOOK_URL, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = payload})

        else

            HttpService:PostAsync(WEBHOOK_URL, payload)

        end

    end)

end




send_notif("BOUNTY NOTIFICATION ⚔️", "+0", 16777215)




task.spawn(function()

    while task.wait(1) do 

        local current_bounty = bounty_stat.Value

        

        if current_bounty ~= last_bounty then

            local diff = current_bounty - last_bounty

            local prefix = (diff > 0) and "+" or ""

            


            send_notif("BOUNTY UPDATE ✅", prefix .. tostring(diff), (diff > 0 and 65280 or 16711680))

            


            last_bounty = current_bounty 

        end

    end

end)
