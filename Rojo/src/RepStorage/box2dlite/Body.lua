--[[ 
	Code ported from box2d-lite (https://github.com/erincatto/box2d-lite)
  Ported by art0007i


local maths = require(script.Parent.Math)
]]--

local maths = _G.maths

_G.bodyCount = 0

local module = {}
Body = {
  position = maths.Vec2:new(0, 0),
  rotation = 0,
  
  velocity = maths.Vec2:new(0, 0),
  angularVelocity = 0,
  
  force = maths.Vec2:new(0, 0),
  torque = 0,

  width = maths.Vec2:new(1, 1),

  friction = 0.2,
  mass = math.huge,
  invMass = 0,
  I = math.huge,
  invI = 0,

  globalIndex = 0,
}

function Body:AddForce(f)
  self.force = maths.AddVV(self.force, f)
end

function Body:Set(w, m)
  self.position:Set(0.0, 0.0);
	self.rotation = 0.0;
	self.velocity:Set(0.0, 0.0);
	self.angularVelocity = 0.0;
	self.force:Set(0.0, 0.0);
	self.torque = 0.0;
	self.friction = 0.2;

	self.width = w;
	self.mass = m;

  -- TODO: add check if mass is largest possible value
  if self.mass < math.huge then 
    self.invMass = 1.0 / self.mass;
    self.I = self.mass * (self.width.x * self.width.x + self.width.y * self.width.y) / 12.0;
    self.invI = 1.0 / self.I;
  else
    self.invMass = 0.0;
		self.I = math.huge;
		self.invI = 0.0;
  end
end


function Body:new()
  local o = {}
  setmetatable(o, self)
  self.__index = self
  o.globalIndex = _G.bodyCount
  _G.bodyCount += 1
  return o
end

module.Body = Body

return module;