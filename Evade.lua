--[[
    Good ell Hub
    SJAD © 2025
]]
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Mid Journey Hub (discord.gg/6UaRDjBY42)",
    LoadingTitle = "Evade VIP rewritten",
    LoadingSubtitle = "Credits: (SJAD) - Advanced Sea Journeys Dev",
    Theme = "Light",
    ShowText = "MidWare UI",
    Icon = 105495960707973,
    SaveConfig = {
        Enabled = true,
        FolderName = "SJAD_Evade",
        FileName = "EvadeConfig"
    },
    Discord = {
        Enabled = true,
        Invite = "6UaRDjBY42",
        RememberJoins = true
    },
    KeySystem = false,
    KeySettings = {
        Title = "SJAD Key System",
        Subtitle = "Sorry, need more members :)",
        Note = "Get from Discord: discord.gg/6UaRDjBY42",
        FileName = "SJAD",
        SaveKey = false,
        GrabKeyFromSite = false,
        Key = {"SJAD-0001-111"}
    }
})

local Confirmed = false
local autoRespawnMethod = nil
local respawnConnection
local lastSavedPosition
local localPlayerESPThread
local vehicleESPThread
local nextbotESPThread
local tracerThread = nil
local tracerList = {}
local infiniteSlideEnabled = false
local Humanoid = LocalPlayer.Character:WaitForChild("Humanoid")
Humanoid.WalkSpeed = 66.6
local lagGui
local lagGuiButton

-- Gradient helper
local function gradient(text, startColor, endColor)
    local result = ""
    local length = #text
    for i = 1, length do
        local t = (i - 1) / math.max(length - 1, 1)
        local r = math.floor((startColor.R + (endColor.R - startColor.R) * t) * 255)
        local g = math.floor((startColor.G + (endColor.G - startColor.G) * t) * 255)
        local b = math.floor((startColor.B + (endColor.B - startColor.B) * t) * 255)
        local char = text:sub(i, i)
        result = result .. "<font color=\"rgb(" .. r .. "," .. g .. "," .. b .. ")\">" .. char .. "</font>"
    end
    return result
end

-- Tabs
local MainTab = Window:CreateTab("Main")
local VisualsTab = Window:CreateTab("Visuals")
local MiscTab = Window:CreateTab("Misc")

-- 1. Auto Respawn
MainTab:CreateToggle({
    Name = "Auto Respawn",
    CurrentValue = false,
    Flag = "AutoRespawn",
    Callback = function(state)
        getgenv().AutoRespawnEnabled = state

        if respawnConnection then
            respawnConnection:Disconnect()
            respawnConnection = nil
        end

        if state then
            local player = game:GetService("Players").LocalPlayer
            task.defer(function()
                while not player.Character do task.wait() end
                respawnConnection = player.CharacterAdded:Connect(function(character)
                    task.defer(function()
                        character:WaitForChild("HumanoidRootPart", 5)
                        character:WaitForChild("Humanoid", 5)

                        character:GetAttributeChangedSignal("Down"):Connect(function()
                            if not getgenv().AutoRespawnEnabled then return end
                            if character:GetAttribute("Down") ~= true then return end
                            if autoRespawnMethod ~= "Fake Revive" then return end

                            local hrp = character:FindFirstChild("HumanoidRootPart")
                            if hrp then lastSavedPosition = hrp.Position end

                            task.wait(3)
                            local startTime = tick()
                            repeat
                                game:GetService("ReplicatedStorage"):WaitForChild("Event", 9e9)
                                    :WaitForChild("Player", 9e9)
                                    :WaitForChild("ChangePlayerMode", 9e9)
                                    :FireServer(true)
                                task.wait(1)
                            until character:GetAttribute("Down") ~= true or tick() - startTime > 1

                            local newChar
                            repeat
                                newChar = player.Character
                                task.wait()
                            until newChar and newChar:FindFirstChild("HumanoidRootPart")

                            local newHRP = newChar:FindFirstChild("HumanoidRootPart")
                            if lastSavedPosition and newHRP then
                                newHRP.CFrame = CFrame.new(lastSavedPosition)
                                task.wait(0.5)
                                if (newHRP.Position - lastSavedPosition).Magnitude > 1 then return end
                            end
                        end)
                    end)
                end)
                player.CharacterAdded:Fire(player.Character)
            end)
        end
    end
})

MainTab:CreateDropdown({
    Name = "Respawn Method",
    Options = {"Random", "Fake Revive"},
    CurrentOption = {"Random"},
    MultipleOptions = false,
    Flag = "RespawnMethod",
    Callback = function(value)
        autoRespawnMethod = value[1]
    end
})

-- 2. Show Game Time
VisualsTab:CreateToggle({
    Name = "Show Game Time",
    CurrentValue = false,
    Flag = "ShowGameTime",
    Callback = function(state)
        local screenGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("LightningWareTimer")
        if screenGui then screenGui.Enabled = state end
    end
})

-- 3. Player ESP
VisualsTab:CreateToggle({
    Name = "ESP Player",
    CurrentValue = false,
    Flag = "EspPlayer",
    Callback = function(state)
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer

        local function getDistance(pos)
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            return hrp and (pos - hrp.Position).Magnitude or nil
        end

        local function createPlayerESP(part)
            local billboard = Instance.new("BillboardGui")
            billboard.Name = "PlayerESP"
            billboard.Adornee = part
            billboard.Size = UDim2.new(0,180,0,25)
            billboard.StudsOffset = Vector3.new(0,3.2,0)
            billboard.AlwaysOnTop = true
            billboard.LightInfluence = 0
            billboard.Parent = part

            local label = Instance.new("TextLabel")
            label.Name = "Label"
            label.Size = UDim2.new(1,0,1,0)
            label.BackgroundTransparency = 1
            label.TextStrokeTransparency = 0.25
            label.TextScaled = true
            label.RichText = true
            label.Font = Enum.Font.GothamBold
            label.Text = ""
            label.TextColor3 = Color3.fromRGB(100,180,255)
            label.Parent = billboard

            return label
        end

        local function removeAllESPs()
            local folder = workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Players")
            if folder then
                for _, char in ipairs(folder:GetChildren()) do
                    if char:IsA("Model") then
                        local hrp = char:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            local existing = hrp:FindFirstChild("PlayerESP")
                            if existing then existing:Destroy() end
                        end
                    end
                end
            end
        end
    end
})
