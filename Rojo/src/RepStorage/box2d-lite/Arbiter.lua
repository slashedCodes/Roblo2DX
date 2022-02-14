--[[ 
	Code ported from box2d-lite (https://github.com/erincatto/box2d-lite)
	Ported by art0007i
 ]]--

local maths = require(script.Parent.Math)
local collide = require(script.Parent.Collide)

local module = {}

FeaturePair = {
	e = {inEdge1 = "", outEdge1 = "", inEdge2 = "", outEdge2 = ""},
	value = 0
}

function FeaturePair:new()
  local o = {}
  setmetatable(o, self)
  self.__index = self
  return o
end

Contact = {
  position = maths.Vec2:new(0, 0),
  normal = maths.Vec2:new(0, 0),
  r1 = maths.Vec2:new(0, 0),
  r2 = maths.Vec2:new(0, 0),
  separation = 0,
	Pn = 0;	-- accumulated normal impulse
	Pt = 0;	-- accumulated tangent impulse
	Pnb = 0; -- accumulated normal impulse for position bias
	massNormal = 0,
  massTangent = 0,
	bias = 0,
	feature = FeaturePair:new()
};

function Contact:new()
  local o = {}
  setmetatable(o, self)
  self.__index = self
  return o
end

module.FeaturePair = FeaturePair

Arbiter = {
  MAX_POINTS = 2,
  contacts = {[0] = Contact:new(), [1] = Contact:new()},
  numContacts = 0,
  body1 = "",
  body2 = "",
  friction = 0
}

function Arbiter:new(b1, b2)
  local o = {}
  setmetatable(o, self)
  self.__index = self
  if(b1.globalIndex < b2.globalIndex) then
    o.body1 = b1
    o.body2 = b2
  else
    o.body1 = b2
    o.body2 = b1
  end
  o.numContacts = collide.Collide(o.contacts, b1, b2);
  o.friction = math.sqrt(b1.friction * b2.friction)
  return o
end
                      -- contact*,   int
function Arbiter:Update(newContacts, numNewContacts)
	local mergedContacts = {[0] = Contact:new(), Contact:new()}; -- contact[2]

	for i = 0,numNewContacts-1 do
		local cNew = newContacts[i]; -- contact*
		local k = -1; -- int
		for j = 0,self.numContacts-1 do
			local cOld = self.contacts[j]; -- contact*
			if (cNew.feature.value == cOld.feature.value) then
				k = j;
				break;
      end
		end

		if (k > -1) then
			local c = mergedContacts[i]; --Contact*
			local cOld = self.contacts[k]; -- Contact*
			c = cNew;
			if (World.warmStarting) then
				c.Pn = cOld.Pn;
				c.Pt = cOld.Pt;
				c.Pnb = cOld.Pnb;
			else
				c.Pn = 0.0;
				c.Pt = 0.0;
				c.Pnb = 0.0;
      end
		else
			mergedContacts[i] = newContacts[i];
    end
	end

	for i = 0,numNewContacts-1 do
		self.contacts[i] = mergedContacts[i];
  end
	self.numContacts = numNewContacts;
end


function Arbiter:PreStep(inv_dt)
	local k_allowedPenetration = 0.01;
	local k_biasFactor 
  if World.positionCorrection then
    k_biasFactor = 0.2
  else
    k_biasFactor = 0.0
  end

	for i = 0,self.numContacts-1 do
		local c = self.contacts[i];

		local r1 = maths.SubVV(c.position, self.body1.position);
		local r2 = maths.SubVV(c.position, self.body2.position);

		-- Precompute normal mass, tangent mass, and bias.
		local rn1 = maths.Dot(r1, c.normal);
		local rn2 = maths.Dot(r2, c.normal);
		local kNormal = self.body1.invMass + self.body2.invMass;
		kNormal += self.body1.invI * (maths.Dot(r1, r1) - rn1 * rn1) + self.body2.invI * (maths.Dot(r2, r2) - rn2 * rn2);
		c.massNormal = 1.0 / kNormal;

		local tangent = maths.CrossVF(c.normal, 1.0); -- Vec2
		local rt1 = maths.Dot(r1, tangent);
		local rt2 = maths.Dot(r2, tangent);
		local kTangent = self.body1.invMass + self.body2.invMass;
		kTangent += self.body1.invI * (maths.Dot(r1, r1) - rt1 * rt1) + self.body2.invI * (maths.Dot(r2, r2) - rt2 * rt2);
		c.massTangent = 1.0 /  kTangent;

		c.bias = -k_biasFactor * inv_dt * math.min(0.0, c.separation + k_allowedPenetration);

		if (World.accumulateImpulses) then
			-- Apply normal + friction impulse
			local P = maths.AddVV(maths.MulFV(c.Pn, c.normal), maths.MulFV(c.Pt, tangent)); -- Vec2

			self.body1.velocity -= self.body1.invMass * P;
			self.body1.angularVelocity -= self.body1.invI * maths.CrossVV(r1, P);

			self.body2.velocity += self.body2.invMass * P;
			self.body2.angularVelocity += self.body2.invI * maths.CrossVV(r2, P);
    end
	end
end

function Arbiter:ApplyImpulse()
	local b1 = self.body1;
	local b2 = self.body2;

	for i = 0,self.numContacts-1 do
		local c = self.contacts[i];
		c.r1 = c.position - b1.position;
		c.r2 = c.position - b2.position;

		-- Relative velocity at contact
		local dv = b2.velocity + maths.CrossFV(b2.angularVelocity, c.r2) - b1.velocity - maths.CrossFV(b1.angularVelocity, c.r1); -- Vec2

		-- Compute normal impulse
		local vn = maths.Dot(dv, c.normal); -- float

		local dPn = c.massNormal * (-vn + c.bias); -- float

		if (World.accumulateImpulses) then
			-- Clamp the accumulated impulse
			local Pn0 = c.Pn; -- float
			c.Pn = math.max(Pn0 + dPn, 0.0);
			dPn = c.Pn - Pn0;
		else
			dPn = math.max(dPn, 0.0);
    end

		-- Apply contact impulse
		local Pn = maths.MulFV(dPn, c.normal); -- Vec2

		b1.velocity:sub(maths.MulFV(b1.invMass, Pn));
		b1.angularVelocity -= b1.invI * maths.CrossVV(c.r1, Pn);

		b2.velocity:add(maths.MulFV(b2.invMass, Pn));
		b2.angularVelocity += b2.invI * maths.CrossVV(c.r2, Pn);

		-- Relative velocity at contact
		dv = b2.velocity + maths.CrossFV(b2.angularVelocity, c.r2) - b1.velocity - maths.CrossFV(b1.angularVelocity, c.r1);

		local tangent = maths.CrossVF(c.normal, 1.0); -- Vec2
		local vt = maths.Dot(dv, tangent);
		local dPt = c.massTangent * (-vt);

		if (World.accumulateImpulses) then
			-- Compute friction impulse
			local maxPt = self.friction * c.Pn;

			-- Clamp friction
			local oldTangentImpulse = c.Pt;
			c.Pt = math.clamp(oldTangentImpulse + dPt, -maxPt, maxPt);
			dPt = c.Pt - oldTangentImpulse;
		else
			local maxPt = self.friction * dPn;
			dPt = math.clamp(dPt, -maxPt, maxPt);
    end

		-- Apply contact impulse
		local Pt = maths.MulFV(dPt * tangent); -- Vec2

		b1.velocity -= b1.invMass * Pt;
		b1.angularVelocity -= b1.invI * maths.CrossVV(c.r1, Pt);

		b2.velocity += b2.invMass * Pt;
		b2.angularVelocity += b2.invI * maths.CrossVV(c.r2, Pt);
	end
end


return module