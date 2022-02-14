
bodies = {}

function Step(dt)

  local inv_dt;
  if dt > 0.0 then
    inv_dt = 1.0 / dt
  else
    inv_dt = 0.0
  end

	-- Determine overlapping bodies and update contact points.
	BroadPhase();

	-- Integrate forces.
	for i,_ in pairs(bodies) do
		local b = bodies[i]; -- Body

		if (b.invMass == 0.0) then
			continue;
    end

		b.velocity += dt * (gravity + b.invMass * b.force);
		b.angularVelocity += dt * b.invI * b.torque;
  end

	-- Perform pre-steps.
	for (ArbIter arb = arbiters.begin(); arb != arbiters.end(); ++arb) do
		arb->second.PreStep(inv_dt);
  end

	for (int i = 0; i < (int)joints.size(); ++i) do
		joints[i]->PreStep(inv_dt);	
  end

	-- Perform iterations
	for (int i = 0; i < iterations; ++i) do
		for (ArbIter arb = arbiters.begin(); arb != arbiters.end(); ++arb) do
			arb->second.ApplyImpulse();
    end

		for (int j = 0; j < (int)joints.size(); ++j) do
			joints[j]->ApplyImpulse();
    end
  end

	-- Integrate Velocities
	for (int i = 0; i < (int)bodies.size(); ++i) do
		Body* b = bodies[i];

		b->position += dt * b->velocity;
		b->rotation += dt * b->angularVelocity;

		b->force.Set(0.0f, 0.0f);
		b->torque = 0.0f;
  end
end