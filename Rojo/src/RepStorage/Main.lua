-- Main [ Alexfeed1990 - 2022 ] --




-- Variables

local players = game.Players
local localPlayer = game.Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local mainGui = playerGui:WaitForChild("Roblo2DX")
local InsertService = game:GetService("InsertService")


-- Modules And Functions

local module = {}
	
-- Functions

-- Test if 2 rotated rectangles are intersecting
function checkCollisions(object, parent)
    local objectsArray = {}

    for i, v in pairs(mainGui:GetChildren()) do
        if v:IsA("Folder") then
            checkCollisions(object, v)
        elseif v:IsA("GuiObject") then
            if areRectanglesIntersecting(object, v) then
                table.add(objectsArray, v)
            end
        end
    end

    return objectsArray
end

function areRectanglesIntersecting(object1, object2)
	local x1, y1, w1, h1, r1 = object1.Position.X, object1.Position.Y, object1.Size.X, object1.Size.Y, object1.Rotation
	local x2, y2, w2, h2, r2 = object2.Position.X, object2.Position.Y, object2.Size.X, object2.Size.Y, object2.Rotation
	local dx = math.abs(x1 + w1/2 - x2 - w2/2) - (w1/2 + w2/2)
	local dy = math.abs(y1 + h1/2 - y2 - h2/2) - (h1/2 + h2/2)
	if dx < 0 and dy < 0 then
		-- use separating axis theorem to test overlap
		
	else
		return false
	end
end

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
	
    local newFrame = Instance.new("Frame", parent)
    newFrame.Name = name
    newFrame.Position = UDim2.new(posX, 0, posY, 0)
    newFrame.Size = UDim2.new(sizeX, 0, sizeY, 0)
    newFrame.BackgroundColor3 = backgroundCol
    newFrame.BorderColor3 = borderColor
    newFrame.BackgroundTransparency = backgroundTransparency
    newFrame.BorderSizePixel = borderSize
	
end

function module.drawSprite(posX, posY, sizeX, sizeY, spriteId, spriteTransparency, borderColor, borderSize, name, parent)
	
	for i, v in pairs(parent:GetChildren()) do
		if v.Name == name then
			warn("An object with the same name already exists!")
		end
	end
	
    local newImg = Instance.new("ImageLabel", mainGui)
    newImg.Name = name
    newImg.Image = "rbxthumb://type=Asset&id=".. spriteId.. "&w=420&h=420"
    newImg.Position = UDim2.new(posX, 0, posY, 0)
    newImg.Size = UDim2.new(sizeX, 0, sizeY, 0)
    newImg.BorderColor3 = borderColor
    newImg.ImageTransparency = spriteTransparency
    newImg.BorderSizePixel = borderSize
	
end

function rotateObject(object, rotation)
	if object:isA("GuiObject") then
        object.Rotation = rotation
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
			task.wait() -- Waits a frame
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

function module.MoveObjectTo(object, X, Y)
    if object:IsA("GuiObject") then
        object.Postion = UDim2.new(X, 0, Y, 0)
    end
end

function module.MoveObjectToCollisions(object, X, Y)
    if object:IsA("GuiObject") then
        object.Postion = UDim2.new(X, 0, Y, 0)

        local collisionArray = checkCollisions(object)
        print(collisionArray)
        -- move object away from the objects that collided with it ba ba bldb ala 
    end
end

return module
