-- Main [ Alexfeed1990 - 2022 ] --

-- Variables

local players = game.Players
local localPlayer = game.Players.localPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local mainGui = playerGui:WaitForChild("Roblo2DX")
local InsertService = game:GetService("InsertService")


-- Modules And Functions

local module = {}
	
	-- Functions

	function hitboxCheck()
		for i, v in pairs(mainGui:GetChildren()) do
			if v:IsA("Folder") and v.Name == "Hitboxes" then
				print("Hitboxes folder exists.")
				return true
			else
				print("Hitboxes folders does not exist.")
				return false
			end
		end
	end

	-- Module functions

	function module.drawRectangle(posX, posY, sizeX, sizeY, backgroundCol, backgroundTransparency, borderColor, borderSize, name, parent)
		
		for i, v in pairs(parent:GetChildren()) do
			if v.Name == name then
				warn("An object with the same name already exists!")
			end
		end
		
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
		
		for i, v in pairs(parent:GetChildren()) do
			if v.Name == name then
				warn("An object with the same name already exists!")
			end
		end
		
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

function module.CreateParentedHitbox(object, name)
	if hitboxCheck() then
		local hitbox = Instance.new("Frame", mainGui.Hitboxes)
		hitbox.Name = name
		
	else
		local hitboxes = Instance.new("Folder", mainGui)
		hitboxes.Parent = mainGui
		hitboxes.Name = "Hitboxes"
		local hitbox = Instance.new("Frame", hitboxes)
		hitbox.Name = name
		coroutine.wrap(function ()
			wait() -- Waits a frame
			hitbox.Position = object.Position
			hitbox.Size = object.Size
		end)()
	end
end

function module.CreateUnparentedHitbox(posX, posY, sizeX, sizeY, name)
	if hitboxCheck() then
		local hitbox = Instance.new("Frame", mainGui.Hitboxes)
		hitbox.Name = name
		hitbox.Position = UDim2.new(posX, 0, posY, 0)
		hitbox.Size = UDim2.new(sizeX, 0, sizeY, 0)
	else
		local hitboxes = Instance.new("Folder", mainGui)
		hitboxes.Parent = mainGui
		hitboxes.Name = "Hitboxes"
		local hitbox = Instance.new("Frame", hitboxes)
		hitbox.Name = name
		hitbox.Position = UDim2.new(posX, 0, posY, 0)
		hitbox.Size = UDim2.new(sizeX, 0, sizeY, 0)
	end
end

return module
