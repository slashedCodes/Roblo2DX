local module = require(game.ReplicatedStorage.Roblo2DX.Main)
local mainGui = game.Players.LocalPlayer.PlayerGui:WaitForChild("Roblo2DX")

local boxPath = game.ReplicatedStorage.Roblo2DX.box2dlite
local maths = require(boxPath.Math)
local worl = require(boxPath.World)
local bod = require(boxPath.Body)

local rectangleStyle = {
	bgColor = Color3.new(0.168627, 0.168627, 0.168627), -- read comment below
	bgTransparency = 0, -- this is ignored in the sprite function
	borderColor = Color3.new(0.921569, 0.921569, 0.921569),
	borderWidth = 2,
}

local textStyle = {
    bgTransparency = 1,
    text = "Hello from Roblo2DX!"
}

local rec1 = module.drawRectangle(200, 200, 500, 300, "ExampleRectangle", mainGui, rectangleStyle)
local rec2 = module.drawText(200, 150, 400, 30, "ExampleText", mainGui, textStyle)
module.rotateObject(rec2, 90)
-- try this to see debug infos
--print(module.areObjectsIntersecting(rec1,rec2)) 

local rects = {}

for i = 0,4 do
	rects[i] = module.drawRectangle(0,0,0,0, "box", mainGui, rectangleStyle)
end

local bodies = {}
local joints = {}

local timeStep = 1 / 60 -- 60 fps
local iterations = 10
local gravity = maths.Vec2:new(0, -10)

local numBodies = 0;
local numJoints = 0;

local demoIndex = 0;

local width = mainGui.width;
local height = mainGui.height;
local zoom = 0 -- waiting on renderer
local pan_y = 0 -- waiting on renderer

local world = worl.World:new(iterations, gravity)

local stop = false;

bodies[numBodies] = bod.Body:new()
bodies[numBodies]:Set(maths.Vec2:new(1000,10), math.huge)
bodies[numBodies].Position:Set(0, -400)
numBodies += 1

bodies[numBodies] = bod.Body:new()
bodies[numBodies]:Set(maths.Vec2:new(10,10), 10)
bodies[numBodies].Position:Set(math.random(0,400), 80)
numBodies += 1

bodies[numBodies] = bod.Body:new()
bodies[numBodies]:Set(maths.Vec2:new(10,10), 10)
bodies[numBodies].Position:Set(math.random(0,400), 80)
numBodies += 1

while not stop do
	world:Step(timeStep)
	for i,v in pairs(bodies) do
		local pos = UDim2.new(0, v.position.x, 0, v.position.y)
		local scale = UDim2.new(0, v.width.x * 10, 0, v.width.y * 10)
		rects[i].Position = pos;
		rects[i].Size = scale;
	end
	task.wait(timeStep)
end