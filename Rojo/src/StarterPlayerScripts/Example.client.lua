local module = require(game.ReplicatedStorage.Roblo2DX.Main)
local mainGui = game.Players.LocalPlayer.PlayerGui:WaitForChild("Roblo2DX")

local maths = _G.maths
local worl = _G.world
local bod = _G.body

local backgroundStyle = {color = Color3.new(0.094117, 0.094117, 0.094117)}

local rectangleStyle = {
	bgColor = Color3.new(0.168627, 0.168627, 0.168627), -- read comment below
	bgTransparency = 0, -- this is ignored in the sprite function
	borderColor = Color3.new(0.921569, 0.921569, 0.921569),
	borderWidth = 2,
}

local rec1 = module.drawRectangle(6, 4, 5, 9, "Rectangle1", mainGui, rectangleStyle)
local rec2 = module.drawRectangle(4, 3, 8, 3, "Rectangle2", mainGui, rectangleStyle)
local background = module.drawBackground(backgroundStyle)

-- Mess with camera

task.wait(5)

module.setCameraRotation(45)

task.wait(2)

module.setCameraZoom(2, 2)

--[[ Physics testing  

local rects = {}

for i = 0,4 do
	rects[i] = module.drawRectangle(0,0,0,0, "box", mainGui, rectangleStyle)
end

local bodies = {}
local joints = {}

local timeStep = 1 / 60 -- 60 fps
local iterations = 10
local gravity = maths.Vec2:new(0, 900)

local numBodies = 0;
local numJoints = 0;

local demoIndex = 0;

--local width = mainGui.width;
--local height = mainGui.height;
local zoom = 0 -- waiting on renderer
local pan_y = 0 -- waiting on renderer

local world = worl.World:new(gravity, iterations)

math.randomseed(os.time())

bodies[numBodies] = bod.Body:new()
bodies[numBodies]:Set(maths.Vec2:new(1000,100), math.huge)
bodies[numBodies].position:Set(600, 400)
bodies[numBodies].friction = 20

world:AddB(bodies[numBodies])
numBodies += 1

bodies[numBodies] = bod.Body:new() 
bodies[numBodies]:Set(maths.Vec2:new(100,100), 100)
bodies[numBodies].position:Set(300, 80)
bodies[numBodies].angularVelocity = 1
bodies[numBodies].friction = 20

world:AddB(bodies[numBodies])
numBodies += 1

bodies[numBodies] = bod.Body:new()
bodies[numBodies]:Set(maths.Vec2:new(100,100), 100)
bodies[numBodies].position:Set(700, 0)
bodies[numBodies].angularVelocity = 6
bodies[numBodies].friction = 20

world:AddB(bodies[numBodies])
numBodies += 1

bodies[numBodies] = bod.Body:new()
bodies[numBodies]:Set(maths.Vec2:new(100,100), 100)
bodies[numBodies].position:Set(690, 120)
bodies[numBodies].angularVelocity = -8
bodies[numBodies].friction = 20

world:AddB(bodies[numBodies])
numBodies += 1


stop = false

function waitFrame()
	while not stop do
		local input = game:GetService("UserInputService").InputBegan:Wait()
		if input.KeyCode == Enum.KeyCode.Z then
			stop = true
		elseif input.KeyCode == Enum.KeyCode.X then
			return
		end
	end
	stop = false
end

function _G.waitStep()
	while not stop do
		local input = game:GetService("UserInputService").InputBegan:Wait()
		if input.KeyCode == Enum.KeyCode.Z then
			stop = true
		elseif input.KeyCode == Enum.KeyCode.X then
			return
		end
	end
end

while true do
	world:Step(timeStep)
	for i,v in pairs(bodies) do
		local pos = UDim2.new(0, v.position.x - v.width.x / 2, 0, v.position.y - v.width.y / 2)
		local scale = UDim2.new(0, v.width.x, 0, v.width.y)
		rects[i].Position = pos;
		rects[i].Size = scale;
		rects[i].Rotation = math.deg(v.rotation);
	end
	task.wait()
	print("-------------------------------------")
	waitFrame()
end

--]]

