-- Simple Menu GUI + Infinite Slide & Speed (Evade)
-- Dán toàn bộ vào executor

--// GUI Menu
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local Button = Instance.new("TextButton")

ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "MyEvadeMenu"

Frame.Parent = ScreenGui
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.Position = UDim2.new(0, 50, 0, 150)
Frame.Size = UDim2.new(0, 215, 0, 90)
Frame.Active = true
Frame.Draggable = true

Button.Parent = Frame
Button.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
Button.Position = UDim2.new(0, 15, 0, 25)
Button.Size = UDim2.new(0, 185, 0, 40)
Button.Font = Enum.Font.SourceSansBold
Button.Text = "Bật Infinite Slide + Speed"
Button.TextColor3 = Color3.fromRGB(255, 255, 255)
Button.TextSize = 20

--// Biến kích hoạt
local enabled = false
local thread = nil

--// Lệnh chạy khi nhấn nút
Button.MouseButton1Click:Connect(function()
    if not enabled then
        enabled = true
        Button.Text = "Đang chạy... (Nhấn để tắt)"
        -- Script Infinite Slide
        thread = coroutine.create(function()
            local player = game.Players.LocalPlayer
            local char = player.Character or player.CharacterAdded:Wait()
            local humanoid = char:WaitForChild("Humanoid")
            while enabled do
                humanoid.WalkSpeed = 55.5
                -- Kích hoạt slide nếu có event (tuỳ game Evade có RemoteEvent Slide hay không)
                for _,v in pairs(char:GetDescendants()) do
                    if v:IsA("RemoteEvent") and v.Name:lower():find("slide") then
                        -- Slide event
                        v:FireServer()
                    end
                end
                wait(0.5)
            end
            humanoid.WalkSpeed = 16 -- Trả lại speed mặc định khi tắt
        end)
        coroutine.resume(thread)
    else
        enabled = false
        Button.Text = "Bật Infinite Slide + Speed"
    end
end)
