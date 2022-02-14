local module = require(game.ReplicatedStorage.Roblo2DX.Main)
local mainGui = game.Players.LocalPlayer.PlayerGui:WaitForChild("Roblo2DX")

local maths = _G.maths
local worl = _G.world
local bod = _G.body

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
--local rec2 = module.drawText(200, 150, 400, 30, "ExampleText", mainGui, textStyle)
--module.rotateObject(rec2, 90)
-- try this to see debug infos
--print(module.areObjectsIntersecting(rec1,rec2)) 


module.CreateComponent("TestComponent", rec1)



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

local stop = false;

math.randomseed(os.time())

bodies[numBodies] = bod.Body:new()
bodies[numBodies]:Set(maths.Vec2:new(1000,100), math.huge)
bodies[numBodies].position:Set(600, 400)
bodies[numBodies].friction = 20

world:AddB(bodies[numBodies])
print(tostring(bodies[0].position))
numBodies += 1

bodies[numBodies] = bod.Body:new() 
bodies[numBodies]:Set(maths.Vec2:new(100,100), 100)
bodies[numBodies].position:Set(300, 80)
bodies[numBodies].angularVelocity = 1
bodies[numBodies].friction = 20

world:AddB(bodies[numBodies])
print(tostring(bodies[1].position))
numBodies += 1

bodies[numBodies] = bod.Body:new()
bodies[numBodies]:Set(maths.Vec2:new(100,100), 100)
bodies[numBodies].position:Set(700, 120)
bodies[numBodies].angularVelocity = 6
bodies[numBodies].friction = 20

world:AddB(bodies[numBodies])
print(tostring(bodies[2].position))
numBodies += 1

while not stop do
	world:Step(timeStep)
	for i,v in pairs(bodies) do
		local pos = UDim2.new(0, v.position.x - v.width.x / 2, 0, v.position.y - v.width.y / 2)
		local scale = UDim2.new(0, v.width.x, 0, v.width.y)
		rects[i].Position = pos;
		rects[i].Size = scale;
		rects[i].Rotation = v.rotation;
	end
	game:GetService("UserInputService").InputBegan:Wait()
end
