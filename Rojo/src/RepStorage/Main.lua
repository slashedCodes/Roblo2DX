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

function checkCollisions(object, parent)
    local objectsArray = {}

    for i, v in pairs(mainGui:GetChildren()) do
        if v:IsA("Folder") then
            checkCollisions(object, v)
        elseif v:IsA("GuiObject") then
            if areFramesIntersecting(object, v) then
                table.add(objectsArray, v)
            end
        end
    end

    return objectsArray
end

-- Test if 2 rotated rectangles are intersecting
function areFramesIntersecting(object1, object2)
	local x1, y1, w1, h1 = object1.AbsolutePosition.X, object1.AbsolutePosition.Y, object1.AbsoluteSize.X, object1.AbsoluteSize.y
	local x2, y2, w2, h2 = object2.AbsolutePosition.X, object2.AbsolutePosition.Y, object2.AbsoluteSize.X, object2.AbsoluteSize.Y
	local dx = math.abs(x1 + w1 / 2 - x2 - w2 / 2) - (w1 / 2 + w2 / 2)
	local dy = math.abs(y1 + h1 / 2 - y2 - h2 / 2) - (h1 / 2 + h2 / 2)
	if dx < 0 and dy < 0 then
		-- use separating axis theorem to test overlap
		-- TODO: possible to make a lookup table of frames to polygons, so we don't have to calculate every time
		return intersectionCheck(createPolygon(object1), createPolygon(object2))
	else
		return false
	end
end

-- Checks if the two polygons are intersecting.
function intersectionCheck(polyA, polyB)
	local polys = { polyA, polyB }
	for polygon in polys do
		for i1, v in pairs(polygon["points"]) do
			-- get the next point to form a line
			local i2 = (i1 + 1) % polygon["pointCount"]

			local p1 = v
			local p2 = polygon["points"][i2]

			-- the normal is a line facing away from the rectangle
			local normal = Vector2.new(p2.Y - p1.Y, p1.X - p2.X)

			local minA, maxA
			for p, v in pairs(polyA["points"]) do
				local projected = normal.X * v.X + normal.Y * v.Y
				if minA == nil or projected < minA then
					minA = projected
				end
				if maxA == nil or projected > maxA then
					maxA = projected
				end
			end

			local minB, maxB
			for p, v in pairs(polyB["points"]) do
				local projected = normal.X * v.X + normal.Y * v.Y
				if minB == nil or projected < minB then
					minB = projected
				end
				if maxB == nil or projected > maxB then
					maxB = projected
				end
			end

			if maxA < minB or maxB < minA then
				return false
			end
		end
	end
	return true
end

function createPolygon(frame)
	local polygon = {}

	local center = frame.AbsolutePosition + frame.AbsoluteSize / 2
	
	polygon["center"] = center

	local point1 = frame.AbsolutePosition
	local point2 = frame.AbsolutePosition + Vector2.new(frame.AbsoluteSize.X, 0)
	local point3 = frame.AbsolutePosition + Vector2.new(0, frame.AbsoluteSize.Y)
	local point4 = frame.AbsolutePosition + frame.AbsoluteSize
	polygon["points"] = {rotatePoint(point1, center), rotatePoint(point2, center), rotatePoint(point3, center), rotatePoint(point4, center)}
	polygon["pointCount"] = 4
	
	return polygon
end

function rotatePoint(point, center, angle)
  local px = point.X
  local py = point.Y
  
  local cx = center.X
  local cy = center.Y

  local s = math.sin(angle)
  local c = math.cos(angle)

  -- translate point back to origin:
  px -= cx
  py -= cy

  -- rotate point
  local xnew = px * c - py * s
  local ynew = px * s + py * c

  -- translate point back:
  px = xnew + cx
  py = ynew + cy
  return Vector2.new(px, py)
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
