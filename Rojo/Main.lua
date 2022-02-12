-- Main [ Alexfeed1990 - 2022 ] --

-- Variables

local players = game.Players
local localPlayer = game.Players.localPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local mainGui = playerGui:WaitForChild("Roblo2DX")
local InsertService = game:GetService("InsertService")

-- Modules And Functions

local module = {}

function module.drawRectangle(posX, posY, sizeX, sizeY, backgroundCol, backgroundTransparency, borderColor, borderSize, name, parent)
	if parent == "gui" then
		local newFrame = Instance.new("Frame", parent)
		newFrame.Name = name
		newFrame.Position = UDim2.new(posX, 0, posY, 0)
		newFrame.Size = UDim2.new(sizeX, 0, sizeY, 0)
		newFrame.BackgroundColor3 = backgroundCol
		newFrame.BorderColor3 = borderColor
		newFrame.BackgroundTransparency = backgroundTransparency
		newFrame.BorderSizePixel = borderSize
	else
		local newFrame = Instance.new("Frame", parent)
		newFrame.Name = name
		newFrame.Position = UDim2.new(posX, 0, posY, 0)
		newFrame.Size = UDim2.new(sizeX, 0, sizeY, 0)
		newFrame.BackgroundColor3 = backgroundCol
		newFrame.BorderColor3 = borderColor
		newFrame.BackgroundTransparency = backgroundTransparency
		newFrame.BorderSizePixel = borderSize
	end
end

function module.drawSprite(posX, posY, sizeX, sizeY, spriteId, spriteTransparency, borderColor, borderSize, name, parent)
	if parent == "gui" then
		local newImg = Instance.new("ImageLabel", mainGui)
		newImg.Name = name
		newImg.Image = "rbxthumb://type=Asset&id=".. spriteId.. "&w=420&h=420"
		newImg.Position = UDim2.new(posX, 0, posY, 0)
		newImg.Size = UDim2.new(sizeX, 0, sizeY, 0)
		newImg.BorderColor3 = borderColor
		newImg.ImageTransparency = spriteTransparency
		newImg.BorderSizePixel = borderSize
	else
		local newImg = Instance.new("ImageLabel", mainGui)
		newImg.Name = name
		newImg.Image = "rbxthumb://type=Asset&id=".. spriteId.. "&w=420&h=420"
		newImg.Position = UDim2.new(posX, 0, posY, 0)
		newImg.Size = UDim2.new(sizeX, 0, sizeY, 0)
		newImg.BorderColor3 = borderColor
		newImg.ImageTransparency = spriteTransparency
		newImg.BorderSizePixel = borderSize
	end
end

return module
