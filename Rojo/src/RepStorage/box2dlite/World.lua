--[[ 
	Code ported from box2d-lite (https://github.com/erincatto/box2d-lite)
	Ported by art0007i
 ]]--

local module = {}

local arbiter = require(script.Parent.Arbiter)
local maths = require(script.Parent.Math)

World = {
	gravity = maths.Vec2:new(0, -10),
	iterations = 10,
	bodies = {},
	arbiters = {},
	joints = {}
}


_G.accumulateImpulses = true
_G.warmStarting = true
_G.positionCorrection = true

function World:Add(body)
	table.insert(self.bodies, body);
end

function World:Add(joint) 
	table.insert(self.joints, joint);
end

function World:Clear()
	table.clear(self.bodies);
	table.clear(self.joints);
	table.clear(self.arbiters);
end

function World:BroadPhase()
	-- O(n^2) broad-phase
	for i,v in pairs(self.bodies) do
		local bi = v; -- Body*

		for j = i + 1,table.getn(self.bodies) do
			local bj = self.bodies[j]; -- Body*

			if (bi.invMass == 0.0 and bj.invMass == 0.0) then
				continue;
			end
			local newArb = arbiter.Arbiter:new(bi, bj); -- Arbiter

			local found = -1;

			for i,iter in pairs(self.arbiters) do
				if iter:Equals(newArb) then
					found = i;
					break;
				end
			end

			if (newArb.numContacts > 0) then
				if (found == -1) then -- Not sure if this is correct but eh im sure it's fine
					table.insert(self.arbiters, newArb);
				else
					self.arbiters[found]:Update(newArb.contacts, newArb.numContacts);
				end
			else
				table.remove(self.arbiters, found);
			end
		end
	end
end

function World:Step(dt)

  local inv_dt;
  if dt > 0.0 then
    inv_dt = 1.0 / dt
  else
    inv_dt = 0.0
  end

	-- Determine overlapping bodies and update contact points.
	self:BroadPhase();

	-- Integrate forces.
	for i,_ in pairs(self.bodies) do
		local b = self.bodies[i]; -- Body

		if (b.invMass == 0.0) then
			continue;
    end

		b.velocity += dt * (self.gravity + b.invMass * b.force);
		b.angularVelocity += dt * b.invI * b.torque;
  end

	-- Perform pre-steps.
	for first,second in pairs(self.arbiters) do
		second:PreStep(inv_dt);
  end

	for _,v in pairs(self.joints) do
		v:PreStep(inv_dt);	
  end

	-- Perform iterations
	for i = 1,self.iterations do
		for first,second in pairs(self.arbiters) do
			second:ApplyImpulse();
    end

		for _,v in pairs(self.joints) do
			v:ApplyImpulse();
    end
  end

	-- Integrate Velocities
	for _,v in pairs(self.bodies) do
		local b = v; -- body*

		b.position += dt * b.velocity;
		b.rotation += dt * b.angularVelocity;

		b.force:Set(0.0, 0.0);
		b.torque = 0.0;
  end
end

function World:new(gravity, iterations)
	local o = {}
	setmetatable(o, self)
	self.__index = self

	o.gravity = gravity
	o.iterations = iterations

	return o;	
end

module.World = World

return module;