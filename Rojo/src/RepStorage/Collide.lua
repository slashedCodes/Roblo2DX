local maths = require(game.ReplicatedStorage.Roblo2DX.Math)

Axis = {
  FACE_A_X=0,
  FACE_A_Y=1,
  FACE_B_X=2,
  FACE_B_Y=3
}

ClipVertex = {
  v = maths.Vec2:new(),
  --fp = 
}

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
	--ClipVertex incidentEdge[2]; this is scary shit, basically in c++ its a struct with a union and we dont have that in lua
	local front, negSide, posSide; -- float
	local negEdge, posEdge; -- char

	-- Compute the clipping lines and the line segment to be clipped.
	if axis == Axis.FACE_A_X then
			frontNormal = normal;
			front = maths.Dot(posA, frontNormal) + hA.x; -- float
			sideNormal = RotA.col2;
			local side = maths.Dot(posA, sideNormal);
			negSide = -side + hA.y;
			posSide =  side + hA.y;
			negEdge = EDGE3;
			posEdge = EDGE1;
			ComputeIncidentEdge(incidentEdge, hB, posB, RotB, frontNormal);
  elseif axis == Axis.FACE_A_Y then

			frontNormal = normal;
			front = Dot(posA, frontNormal) + hA.y;
			sideNormal = RotA.col1;
			float side = Dot(posA, sideNormal);
			negSide = -side + hA.x;
			posSide =  side + hA.x;
			negEdge = EDGE2;
			posEdge = EDGE4;
			ComputeIncidentEdge(incidentEdge, hB, posB, RotB, frontNormal);
	elseif axis == Axis.FACE_B_X then

			frontNormal = -normal;
			front = Dot(posB, frontNormal) + hB.x;
			sideNormal = RotB.col2;
			float side = Dot(posB, sideNormal);
			negSide = -side + hB.y;
			posSide =  side + hB.y;
			negEdge = EDGE3;
			posEdge = EDGE1;
			ComputeIncidentEdge(incidentEdge, hA, posA, RotA, frontNormal);
  elseif axis == Axis.FACE_B_Y then
			frontNormal = -normal;
			front = Dot(posB, frontNormal) + hB.y;
			sideNormal = RotB.col1;
			float side = Dot(posB, sideNormal);
			negSide = -side + hB.x;
			posSide =  side + hB.x;
			negEdge = EDGE2;
			posEdge = EDGE4;
			ComputeIncidentEdge(incidentEdge, hA, posA, RotA, frontNormal);
	end

	-- clip other face with 5 box planes (1 face plane, 4 edge planes)

	ClipVertex clipPoints1[2];
	ClipVertex clipPoints2[2];
	int np;

	// Clip to box side 1
	np = ClipSegmentToLine(clipPoints1, incidentEdge, -sideNormal, negSide, negEdge);

	if (np < 2)
		return 0;

	-- Clip to negative box side 1
	np = ClipSegmentToLine(clipPoints2, clipPoints1,  sideNormal, posSide, posEdge)

	if (np < 2) then
		return 0
  end

	-- Now clipPoints2 contains the clipping points.
	-- Due to roundoff, it is possible that clipping removes all points.

	local numContacts = 0;
	for (int i = 0; i < 2; ++i) do
		local separation = Dot(frontNormal, clipPoints2[i].v) - front;

		if (separation <= 0) then
			contacts[numContacts].separation = separation;
			contacts[numContacts].normal = normal;
			-- slide contact point onto reference face (easy to cull)
			contacts[numContacts].position = clipPoints2[i].v - separation * frontNormal
			contacts[numContacts].feature = clipPoints2[i].fp
			if (axis == FACE_B_X or axis == FACE_B_Y) then
				Flip(contacts[numContacts].feature)
      end
			numContacts += 1
    end
	end

	return numContacts;
end