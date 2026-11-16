local ProtectionConfig = {
    -- 🔴 CRITICAL: This MUST exactly match the 'Secret' value in your Key System's Config!
    -- If your Key System has: Secret = "Test"
    -- Then this must also be: SecretKey = "Test"
    SecretKey = "Test",
    
    -- The name of your Hub (shown in the kick message if they try to bypass)
    HubName = "OYB HUB"
}

-- Anti-Bypass Logic: Checks if the Key System successfully set the global variable
if not _G[ProtectionConfig.SecretKey] then
    local player = game:GetService("Players").LocalPlayer
    if player then
        player:Kick("\n🛡️ Unauthorized Execution 🛡️\n\nPlease use the official Key System to run " .. ProtectionConfig.HubName)
    end
    return -- Stops the rest of the script from loading!
end

-- Paste this script into your executor to run it.
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Clear previous copy if it exists
if playerGui:FindFirstChild("SellDirtAutoRebirthGui") then
	playerGui.SellDirtAutoRebirthGui:Destroy()
end

-- Coordinates
local REBIRTH_POS = Vector3.new(-162, 3.3, -28.8)
local CASH_POS = Vector3.new(-213.8, 3.6, -30.5)

-- Pixel position of the Rebirth button
local BUTTON_X = 760
local BUTTON_Y = 777

local autoRebirthEnabled = false

-- Safe ScreenGui Creation
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SellDirtAutoRebirthGui"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- Main Panel
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 220, 0, 110)
mainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(60, 60, 70)
mainFrame.Visible = true
mainFrame.Parent = screenGui

-- Title (Draggable)
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
titleLabel.BorderSizePixel = 0
titleLabel.Text = " Sell Dirt | Auto Bot (Hold & Drag)"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 13
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = mainFrame

-- Toggle Button
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0.9, 0, 0, 45)
toggleButton.Position = UDim2.new(0.05, 0, 0.4, 0)
toggleButton.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
toggleButton.Text = "AUTO: OFF"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.TextSize = 15
toggleButton.Parent = mainFrame

-- Panel Dragging Logic
local dragging, dragStart, startPos
titleLabel.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = mainFrame.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

titleLabel.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

-- Button Functionality & Text Update
toggleButton.MouseButton1Click:Connect(function()
	autoRebirthEnabled = not autoRebirthEnabled
	if autoRebirthEnabled then
		toggleButton.BackgroundColor3 = Color3.fromRGB(40, 180, 60)
		toggleButton.Text = "AUTO: ON"
	else
		toggleButton.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
		toggleButton.Text = "AUTO: OFF"
	end
end)

-- Automation Loop
task.spawn(function()
	while true do
		task.wait(1.5)
		if autoRebirthEnabled then
			pcall(function()
				local character = player.Character
				if character and character:FindFirstChild("HumanoidRootPart") then
					-- 1. Teleport to Rebirth location
					character.HumanoidRootPart.CFrame = CFrame.new(REBIRTH_POS)
					task.wait(0.4)
					
					-- 2. Press E key to open the menu
					local vim = game:GetService("VirtualInputManager")
					vim:SendKeyEvent(true, Enum.KeyCode.E, false, game)
					task.wait(0.05)
					vim:SendKeyEvent(false, Enum.KeyCode.E, false, game)
					task.wait(0.6)
					
					-- 3. Click the Rebirth button at (760, 777)
					vim:SendMouseButtonEvent(BUTTON_X, BUTTON_Y, 0, true, game, 1)
					task.wait(0.05)
					vim:SendMouseButtonEvent(BUTTON_X, BUTTON_Y, 0, false, game, 1)
					
					task.wait(0.5)
					
					-- 4. Return to the cash collection location
					if character and character:FindFirstChild("HumanoidRootPart") then
						character.HumanoidRootPart.CFrame = CFrame.new(CASH_POS)
					end
				end
			end)
		end
	end
end)
