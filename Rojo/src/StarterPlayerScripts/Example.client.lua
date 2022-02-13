local module = require(game.ReplicatedStorage.Roblo2DX.Main)
local mainGui = game.Players.LocalPlayer.PlayerGui:WaitForChild("Roblo2DX")

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

module.drawRectangle(200, 200, 500, 300, "ExampleRectangle", mainGui, rectangleStyle)
module.drawText(200, 200, 400, 30, "ExampleText", mainGui, textStyle)
