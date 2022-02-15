-- Main [ Alexfeed1990 - 2022 ] --

-- Variables

_G.maths = require(script.Parent.box2dlite.Math)
_G.arbiter = require(script.Parent.box2dlite.Arbiter)
_G.collide = require(script.Parent.box2dlite.Collide)
_G.body = require(script.Parent.box2dlite.Body)
_G.world = require(script.Parent.box2dlite.World)
_G.arbiter.Init()

local players = game.Players
local localPlayer = game.Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local mainGui = playerGui:WaitForChild("Roblo2DX")
local InsertService = game:GetService("InsertService")
local compFolder = script.Parent.Components

local components = {
	"TestComponent"
}

-- Modules And Functions

local module = {}
	
-- Functions

function checkCollisions(object, parent)
    local objectsArray = {}

    for i, v in pairs(parent:GetChildren()) do
        if v:IsA("Folder") then
            checkCollisions(object, v)
        elseif v:IsA("GuiObject") then
            if module.areObjectsIntersecting(object, v) then
                table.add(objectsArray, v)
            end
        end
    end

    return objectsArray
end

-- Test if 2 rotated rectangles are intersecting
function module.areObjectsIntersecting(object1, object2)
	-- TODO: check if the objects are even close to intersecting

	-- TODO: possible to make a lookup table of frames to polygons, so we don't have to calculate every time
	print("running complex collide check")
	return intersectionCheck(createPolygon(object1), createPolygon(object2))
end

-- Checks if the two polygons are intersecting.
function intersectionCheck(polyA, polyB)
	local polys = { polyA, polyB }

	for _,polygon in ipairs(polys) do
		for i1, _ in pairs(polygon["points"]) do
			-- get the next point to form a line

			local i2 = i1 % polygon["pointCount"] + 1

			local p1 = polygon["points"][i1]
			local p2 = polygon["points"][i2]
			
			-- the nomral is a vector perpendicular to the line
			local normal = Vector2.new(p2.Y - p1.Y, p1.X - p2.X)

			-- this is the separating axis theorem
			-- basically we check if there is any point in the other polygon that is on the correct side of the normal
			local minA, maxA
			for p, v in pairs(polyA["points"]) do
				-- project the point onto the normal
				-- this simplifies it to 1d instead of 2d
				-- we record the min and max values of the 1d points
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
				-- do the same as the first poly, simplify to 1d
				local projected = normal.X * v.X + normal.Y * v.Y
				if minB == nil or projected < minB then
					minB = projected
				end
				if maxB == nil or projected > maxB then
					maxB = projected
				end
			end

			-- now we can check easily if the two projections overlap
			-- in 1d this is easy, just check if the max of one is less than the min of the other

			if maxA < minB or maxB < minA then
				-- this means that the sections don't overlap, so the polygons don't intersect
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
	polygon["baseElement"] = frame
	local point1 = frame.AbsolutePosition + Vector2.new(frame.AbsoluteSize.X, 0)
	local point2 = frame.AbsolutePosition
	local point3 = frame.AbsolutePosition + Vector2.new(0, frame.AbsoluteSize.Y)
	local point4 = frame.AbsolutePosition + frame.AbsoluteSize
	polygon["points"] = {rotatePoint(point1, center, frame.Rotation), rotatePoint(point2, center, frame.Rotation), rotatePoint(point3, center, frame.Rotation), rotatePoint(point4, center, frame.Rotation)}
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

function fill(style, name, default)
	if style[name] == nil then
		style[name] = default
	end
end

function translateUnitToPx(value)
	return value/50 -- this is incorrect, need to account for scale/zoom
end

function translatePxToUnit(value)
	return value*50
end

-- Module functions

function module.defaultStyle(style)
	fill(style, "borderColor", Color3.new(1, 1, 1))
	fill(style, "borderSize", 2)
	fill(style, "borderTransparency", 0)
	fill(style, "bgColor", Color3.new(0.1, 0.1, 0.1))
	fill(style, "bgTransparency", 0)
	fill(style, "textColor", Color3.new(1, 1, 1))
	fill(style, "textTransparency", 0)
	fill(style, "text", "")
	fill(style, "spriteID", 0)
	fill(style, "spriteColor", Color3.new(1, 1, 1))
	fill(style, "spriteTransparency", 0)
end

function fillObject(object, posX, posY, sizeX, sizeY, name, style)
	-- ensures that provided styles are valid
	module.defaultStyle(style)

	object:SetAttribute("PosX", posX) -- 1 in unit space is 50px in real screen space.
	object:SetAttribute("PosY", posY)

	object:SetAttribute("ScaleX", sizeX)
	object:SetAttribute("ScaleY", sizeY)

	object:SetAttribute("Rotation", 0)

	-- all of these are properties of GuiObject so we can set them without worrying about the object type
	object.Name = name
	object.Position = UDim2.new(0, translateUnitToPx(object:GetAttribute("PosX")), 0, translateUnitToPx(object:GetAttribute("PosY")))
	object.Size = UDim2.new(0, translateUnitToPx(object:GetAttribute("ScaleX")), 0, translateUnitToPx(object:GetAttribute("ScaleY")))	
	object.BackgroundColor3 = style["bgColor"]
	object.BackgroundTransparency = style["bgTransparency"]
	object.BorderColor3 = style["borderColor"]
	object.BorderSizePixel = style["borderSize"]


end

function module.drawRectangle(posX, posY, sizeX, sizeY, name, parent, style)
	local newFrame = Instance.new("Frame", parent)
	fillObject(newFrame, posX, posY, sizeX, sizeY, name, style)
	return newFrame
end

function module.drawSprite(posX, posY, sizeX, sizeY, name, parent, style)
	local newImg = Instance.new("ImageLabel", mainGui)
	fillObject(newImg, posX, posY, sizeX, sizeY, name, style)
	newImg.ImageColor3 = style["spriteColor"]
	newImg.ImageTransparency = style["spriteTransparency"]
	newImg.Image = "rbxthumb://type=Asset&id=".. style["spriteID"].. "&w=420&h=420"
	return newImg
end

function module.drawText(posX, posY, sizeX, sizeY, name, parent, style)
	local newText = Instance.new("TextLabel", parent)
	fillObject(newText, posX, posY, sizeX, sizeY, name, style)
	newText.TextColor3 = style["textColor"]
	newText.TextTransparency = style["textTransparency"]
	-- this is one case where an extra argument wouldn't hurt in my opinion
	newText.Text = style["text"]
	return newText
end

function module.rotateObject(object, rotation)
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
		object.Position = UDim2.new(0, translateUnitToPx(Instance:GetAttribute("PosX")), 0, translateUnitToPx(Instance:GetAttribute("PosY")))
    end
end

function module.MoveObjectToCollisions(object, X, Y)
    if object:IsA("GuiObject") then
        object.Postion = UDim2.new(X, 0, Y, 0)

        local collisionArray = checkCollisions(object)
        print(collisionArray)

        local revX = -X
        local revY = -Y

        if #collisionArray > 0 then
            print("Object is colliding with other objects.")
            print(collisionArray)
        end

        -- move object away from the objects that collided with it ba ba bldb ala 
    end
end

return module
