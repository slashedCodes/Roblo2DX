--[[ 
	Code ported from box2d-lite (https://github.com/erincatto/box2d-lite)
	Ported by art0007i
 ]]--

local maths = require(script.Parent.Math)
local arbiter = require(script.Parent.Arbiter)

local module = {}
Axis = {
  FACE_A_X=0,
  FACE_A_Y=1,
  FACE_B_X=2,
  FACE_B_Y=3
}

ClipVertex = {
  v = maths.Vec2:new(0, 0),
  fp = arbiter.FeaturePair:new()
}

function ClipVertex:new()
	local o = {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function Flip(fp)
	local temp = fp.e.inEdge1
	fp.e.inEdge1 = fp.e.inEdge2
	fp.e.inEdge2 = temp
	
	temp = fp.e.outEdge1
	fp.e.outEdge1 = fp.e.outEdge2
	fp.e.outEdge2 = temp
end

function ClipSegmentToLine(vOut, vIn, normal, offset, clipEdge)
	-- Start with no output points
	local numOut = 0;

	-- Calculate the distance of end points to the line
	local distance0 = (maths.Dot(normal, vIn[0].v) - offset);
	local distance1 = (maths.Dot(normal, vIn[1].v) - offset);

	-- If the points are behind the plane
	if (distance0 <= 0.0) then 
		vOut[numOut] = vIn[0];
		numOut += 1
	end
	if (distance1 <= 0.0) then 
		vOut[numOut] = vIn[1];
		numOut += 1;
	end

	-- If the points are on different sides of the plane
	if (distance0 * distance1 < 0.0) then
		-- Find intersection point of edge and plane
		local interp = distance0 / (distance0 - distance1);
		vOut[numOut].v = vIn[0].v + interp * (vIn[1].v - vIn[0].v);
		if (distance0 > 0.0) then
			vOut[numOut].fp = vIn[0].fp;
			vOut[numOut].fp.e.inEdge1 = clipEdge;
			vOut[numOut].fp.e.inEdge2 = 0; -- NO_EDGE
		else
			vOut[numOut].fp = vIn[1].fp;
			vOut[numOut].fp.e.outEdge1 = clipEdge;
			vOut[numOut].fp.e.outEdge2 = 0; -- NO_EDGE
		end
		numOut += 1;
	end

	return numOut;
end

function ComputeIncidentEdge(c, h, pos, Rot, normal)
	-- The normal is from the reference box. Convert it
	-- to the incident boxe's frame and flip sign.
	local RotT = Rot:Transpose();
	local n = maths.MulMV(RotT, normal):neg() -- vec2
	local nAbs = n:Abs();

	if (nAbs.x > nAbs.y) then
		if (math.sign(n.x) > 0.0) then
			c[0].v = maths.Vec2:new(h.x, -h.y);
			c[0].fp.e.inEdge2 = 3; -- EDGE3
			c[0].fp.e.outEdge2 = 4;

			c[1].v = maths.Vec2:new(h.x, h.y);
			c[1].fp.e.inEdge2 = 4;
			c[1].fp.e.outEdge2 = 1;
		else
			c[0].v = maths.Vec2:new(-h.x, h.y);
			c[0].fp.e.inEdge2 = 1;
			c[0].fp.e.outEdge2 = 2;

			c[1].v = maths.Vec2:new(-h.x, -h.y);
			c[1].fp.e.inEdge2 = 2;
			c[1].fp.e.outEdge2 = 3;
		end
	else
		if (math.sign(n.y) > 0.0) then
			c[0].v = maths.Vec2:new(h.x, h.y);
			c[0].fp.e.inEdge2 = 4;
			c[0].fp.e.outEdge2 = 1;

			c[1].v = maths.Vec2:new(-h.x, h.y);
			c[1].fp.e.inEdge2 = 1;
			c[1].fp.e.outEdge2 = 2;
		else
			c[0].v = maths.Vec2:new(-h.x, -h.y);
			c[0].fp.e.inEdge2 = 2;
			c[0].fp.e.outEdge2 = 3;

			c[1].v = maths.Vec2:new(h.x, -h.y);
			c[1].fp.e.inEdge2 = 3;
			c[1].fp.e.outEdge2 = 4;
		end
	end

	c[0].v = maths.AddVV(pos + maths.MulMV(Rot, c[0].v));
	c[1].v = maths.AddVV(pos + maths.MulMV(Rot, c[1].v));
end

function Collide(contacts, bodyA, bodyB)
	-- Setup
	local hA = maths.MulFV(0.5, bodyA.width); -- vec2
	local hB = maths.MulFV(0.5, bodyB.width);

	local posA = bodyA.position; -- vec2
	local posB = bodyB.position;

	local RotA = maths.Mat22:new(bodyA.rotation) -- mat22
  local RotB = maths.Mat22:new(bodyB.rotation);

	local RotAT = RotA:Transpose(); -- mat22
	local RotBT = RotB:Transpose();

	local dp = maths.SubVV(posB, posA); -- vec2
	local dA = maths.MulMV(RotAT, dp);
	local dB = maths.MulMV(RotBT, dp);

	local C = maths.MulMM(RotAT, RotB); -- mat22
	local absC = C:Abs(); -- mat22
	local absCT = absC:Transpose();

	-- Box A faces
	local faceA = maths.SubVV(maths.SubVV(dA:Abs(), hA), maths.MulMV(absC, hB)); -- vec2
	if faceA.x > 0.0 or faceA.y > 0.0 then
		return 0;
  end

	-- Box B faces
	local faceB = maths.SubVV(maths.SubVV(dB:Abs(), maths.MulMV(absCT * hA)), hB); -- vec2
	if faceB.x > 0.0 or faceB.y > 0.0 then
		return 0;
  end

	-- Find best axis
	local axis; -- Axis
	local separation; -- float
	local normal; -- vec2

	-- Box A faces
	axis = Axis.FACE_A_X;
	separation = faceA.x;
  if dA.x > 0.0 then
    normal = RotA.col1
  else
    normal = RotA.col1:neg()
  end

	local relativeTol = 0.95;
	local absoluteTol = 0.01;

	if (faceA.y > relativeTol * separation + absoluteTol * hA.y) then
		axis = Axis.FACE_A_Y;
		separation = faceA.y;
    if dA.y > 0.0 then
      normal = RotA.col2
    else
      normal = RotA.col2:neg()
    end
  end

	-- Box B faces
	if (faceB.x > relativeTol * separation + absoluteTol * hB.x) then
		axis = Axis.FACE_B_X;
		separation = faceB.x;
    if dB.x > 0.0 then
      normal = RotB.col1
    else
      normal = RotB.col1:neg()
    end
  end

	if (faceB.y > relativeTol * separation + absoluteTol * hB.y) then
		axis = Axis.FACE_B_Y;
		separation = faceB.y;
    if dB.y > 0.0 then
      normal = RotB.col2
    else
      normal = RotB.col2:neg()
    end
  end

	-- Setup clipping plane data based on the separating axis
	local frontNormal, sideNormal; -- vec2
	local incidentEdge = {[0] = ClipVertex:new(), ClipVertex:new()}; -- ClipVertex[2]
	local front, negSide, posSide; -- float
	local negEdge, posEdge; -- char

	-- Compute the clipping lines and the line segment to be clipped.
	if axis == Axis.FACE_A_X then
			frontNormal = normal;
			front = maths.Dot(posA, frontNormal) + hA.x; -- float
			sideNormal = RotA.col2;
			local side = maths.Dot(posA, sideNormal); -- float
			negSide = -side + hA.y;
			posSide =  side + hA.y;
			negEdge = 3; -- EDGE3
			posEdge = 1;
			ComputeIncidentEdge(incidentEdge, hB, posB, RotB, frontNormal);
  elseif axis == Axis.FACE_A_Y then

			frontNormal = normal;
			front = maths.Dot(posA, frontNormal) + hA.y;
			sideNormal = RotA.col1;
			local side = maths.Dot(posA, sideNormal); -- float
			negSide = -side + hA.x;
			posSide =  side + hA.x;
			negEdge = 2;
			posEdge = 4;
			ComputeIncidentEdge(incidentEdge, hB, posB, RotB, frontNormal);
	elseif axis == Axis.FACE_B_X then

			frontNormal = -normal;
			front = maths.Dot(posB, frontNormal) + hB.x;
			sideNormal = RotB.col2;
			local side = maths.Dot(posB, sideNormal); -- float
			negSide = -side + hB.y;
			posSide =  side + hB.y;
			negEdge = 3;
			posEdge = 1;
			ComputeIncidentEdge(incidentEdge, hA, posA, RotA, frontNormal);
  elseif axis == Axis.FACE_B_Y then
			frontNormal = -normal;
			front = maths.Dot(posB, frontNormal) + hB.y;
			sideNormal = RotB.col1;
			local side = maths.Dot(posB, sideNormal); -- float
			negSide = -side + hB.x;
			posSide =  side + hB.x;
			negEdge = 2;
			posEdge = 4;
			ComputeIncidentEdge(incidentEdge, hA, posA, RotA, frontNormal);
	end

	-- clip other face with 5 box planes (1 face plane, 4 edge planes)

	local clipPoints1 = {[0] = ClipVertex:new(), ClipVertex:new()}; -- ClipVertex[2]
	local clipPoints2 = {[0] = ClipVertex:new(), ClipVertex:new()};
	local np; -- int

	-- Clip to box side 1
	np = ClipSegmentToLine(clipPoints1, incidentEdge, -sideNormal, negSide, negEdge);

	if (np < 2) then
		return 0;
  end

	-- Clip to negative box side 1
	np = ClipSegmentToLine(clipPoints2, clipPoints1,  sideNormal, posSide, posEdge)

	if (np < 2) then
		return 0
  end

	-- Now clipPoints2 contains the clipping points.
	-- Due to roundoff, it is possible that clipping removes all points.

	local numContacts = 0;
	for i=0,1 do
		local separation = maths.Dot(frontNormal, clipPoints2[i].v) - front;

		if (separation <= 0) then
			contacts[numContacts].separation = separation;
			contacts[numContacts].normal = normal;
			-- slide contact point onto reference face (easy to cull)
			contacts[numContacts].position = clipPoints2[i].v - separation * frontNormal
			contacts[numContacts].feature = clipPoints2[i].fp
			if (axis == Axis.FACE_B_X or axis == Axis.FACE_B_Y) then
				Flip(contacts[numContacts].feature)
      end
			numContacts += 1
    end
	end

	return numContacts;
end

module.Collide = Collide;

return module;