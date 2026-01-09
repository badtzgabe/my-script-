-- SERVICES
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local VIM = game:GetService("VirtualInputManager")
local player = Players.LocalPlayer

-- STATES
local running = false
local fishing = false
local clicking = false

-- ================= UI =================
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name = "SillySealHub"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromScale(0.16, 0.14)
frame.Position = UDim2.fromScale(0.02, 0.4)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0.28,0)
title.BackgroundTransparency = 1
title.Text = "Be a Silly Seal"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Font = Enum.Font.GothamBold
title.TextScaled = true

local toggle = Instance.new("TextButton", frame)
toggle.Position = UDim2.new(0.1,0,0.38,0)
toggle.Size = UDim2.new(0.8,0,0.28,0)
toggle.Text = "LIGAR"
toggle.Font = Enum.Font.GothamBold
toggle.TextScaled = true
toggle.BackgroundColor3 = Color3.fromRGB(60,180,75)
toggle.TextColor3 = Color3.new(1,1,1)

local credit = Instance.new("TextLabel", frame)
credit.Position = UDim2.new(0,0,0.72,0)
credit.Size = UDim2.new(1,0,0.25,0)
credit.BackgroundTransparency = 1
credit.Text = "badtzgabe"
credit.TextColor3 = Color3.fromRGB(160,160,160)
credit.Font = Enum.Font.Gotham
credit.TextScaled = true

local function setState(state)
    running = state
    toggle.Text = state and "DESLIGAR" or "LIGAR"
    toggle.BackgroundColor3 = state and Color3.fromRGB(200,60,60) or Color3.fromRGB(60,180,75)
end

toggle.MouseButton1Click:Connect(function()
    setState(not running)
end)

-- ================= TECLAS =================
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end

    if UIS:IsKeyDown(Enum.KeyCode.LeftControl) and input.KeyCode == Enum.KeyCode.Five then
        setState(true)
    end

    if UIS:IsKeyDown(Enum.KeyCode.LeftControl) and input.KeyCode == Enum.KeyCode.Six then
        setState(false)
    end
end)

-- ================= UI DETECTION =================
local FishingBar, ClickLabel, ELabel

local function scanUI()
    FishingBar, ClickLabel, ELabel = nil, nil, nil

    for _,v in pairs(game:GetDescendants()) do
        if v:IsA("TextLabel") then
            local t = string.lower(v.Text)

            if string.find(t,"pressione") then
                FishingBar = v.Parent
            end

            if string.find(t,"clique") then
                ClickLabel = v
            end

            if string.find(t,"peixe") and string.find(t,"e") then
                ELabel = v
            end
        end
    end
end

scanUI()
player.PlayerGui.DescendantAdded:Connect(scanUI)

-- ================= PESCA LOGIC =================
task.spawn(function()
    while true do
        if running then
            if FishingBar and FishingBar:IsDescendantOf(player.PlayerGui) and FishingBar.Visible then
                fishing = true

                -- SEGURA MOUSE
                VIM:SendMouseButtonEvent(0,0,0,true,game,0)

                if ClickLabel then
                    local c = ClickLabel.TextColor3
                    local isRed = c.R > 0.85 and c.G < 0.35

                    clicking = isRed
                end

                if clicking then
                    VIM:SendMouseButtonEvent(0,0,0,false,game,0)
                    VIM:SendMouseButtonEvent(0,0,0,true,game,0)
                end

            else
                -- FIM DA PESCA
                fishing = false
                clicking = false
                VIM:SendMouseButtonEvent(0,0,0,false,game,0)

                -- PRESSIONA E (Peixe)
                if ELabel and ELabel.Visible then
                    VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                    task.wait(0.05)
                    VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                end
            end
        end
        task.wait(0.01)
    end
end)

-- ================= ANTI AFK / VENDA =================
task.spawn(function()
    while true do
        if running then
            task.wait(900) -- 15 minutos
            VIM:SendKeyEvent(true, Enum.KeyCode.R, false, game)
            task.wait(10)
            VIM:SendKeyEvent(false, Enum.KeyCode.R, false, game)
        else
            task.wait(1)
        end
    end
end)
