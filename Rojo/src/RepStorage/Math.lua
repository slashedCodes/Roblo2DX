-- Code taken from https://github.com/erincatto/box2d-lite --

local module = {}

Vec2 = {
  x = 0,
  y = 0
}

function Vec2:neg()
  return Vec2:new(-self.x, -self.y)
end

function Vec2:add(vec)
  self.x += vec.x
  self.y += vec.y
end

function Vec2:sub(vec)
  self.x -= vec.x
  self.y -= vec.y
end

function Vec2:mul(vec)
  self.x *= vec.x
  self.y *= vec.y
end

function Vec2:mag(args)
  return math.sqrt(self.x * self.x + self.y * self.y)
end

function Vec2:new(x, y)
  local v = {x = x, y = y}
  setmetatable(v, self)
  self.__index = self
  return v
end

module["Vec2"] = Vec2

Mat22 = {
  col1 = Vec2:new(0, 0),
  col2 = Vec2:new(0, 0)
}

function Mat22:Transpose()
  local t = Mat22:new()
  -- [ 1, 2 ]
  -- [ 3, 4 ]
  --    V
  -- [ 1, 3 ]
  -- [ 2, 4 ]
  t.col1.x = self.col1.x
  t.col1.y = self.col2.x
  t.col2.x = self.col1.y
  t.col2.y = self.col2.y
  return t
end

function Mat22:Invert()
  local a, b, c, d = self.col1.x, self.col2.x, self.col1.y, self.col2.y
  local B = Mat22:new()
  local det = a * d - b * c
  if det == 0 then
    print("TRIED TO INVERT INVALID MATRIX")
    return nil
  end

  det = 1 / det
  B.col1.x =  det * d
  B.col2.x = -det * b
	B.col1.y = -det * c
  B.col2.y =  det * a
  return B
end

function Mat22:new()
  local o = {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Mat22:new(x, y)
  local o = Mat22:new()
  o.col1 = x
  o.col2 = y
  return o
end

function Mat22:new(angle)
  local o = Mat22:new()
  o.col1 = {math.cos(angle), math.sin(angle)}
  o.col2 = {-o.col1.y, o.col1.x}
  --  [ c,  -s ]
  --  [ s,   c ]
  return o
end

module["Mat22"] = Mat22

function module.Dot(a, b)
  return a.x * b.x + a.y * b.y
end

-- Vec2 x Vec2
function module.CrossVV(a, b)
  return a.x * b.y - a.y * b.x
end

-- Vec2 x float
function module.CrossVF(a, s)
  return Vec2:new(s * a.y, -s * a.x);
end

-- float x Vec2
function module.CrossFV(s, a)
	return Vec2:new(-s * a.y, s * a.x);
end

function module.MulMV(A, v)
  return Vec2:new(A.col1.x * v.x + A.col2.x * v.y, A.col1.y * v.x + A.col2.y * v.y)
end

function module.AddVV(a, b)
  return Vec2:new(a.x + b.x, a.y + b.y)
end

function module.SubVV(a, b)
  return Vec2:new(a.x - b.x, a.y - b.y)
end

function module.MulFV(s, v)
  return Vec2:new(s * v.x, s * v.y)
end

function module.AddMM(A, B)
  return Mat22:new(module.AddVV(A.col1, B.col1), module.AddVV(A.col2, B.col2))
end

function module.MulMM(A, B)
  return Mat22:new(module.MulMV(A, B.col1), module.MulMV(A, B.col2));
end

-- math.abs(a)

function Vec2:Abs()
  return Vec2:new(math.abs(self.x), math.abs(self.y))
end

function Mat22:Abs()
  return Mat22:new(self.col1:Abs(), self.col2:Abs())
end

-- math.sign(a)
-- math.min(a)
-- math.max(a)
-- math.clamp(a, low, high)

function module.Random(lo, hi)
  local r = math.random();
	r = (hi - lo) * r + lo;
	return r;
end

return module