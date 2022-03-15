local pairs = pairs
local select = select
local next = next
local table_concat = table.concat
local table_clear
if ngx then
  table_clear = table.clear
else
  table_clear = function(t)
    for key, _ in pairs(t) do
      t[key] = nil
    end
  end
end

local function set_from_array(cls, t)
  local s = {}
  if t then
    for i=1, #t do
      s[t[i]] = true
    end
  end
  return setmetatable(s, cls)
end
local set = setmetatable({}, {
  __call = set_from_array
})
set.__index = set
set.__tostring = function(t)
  local keys = {}
  for k, _ in pairs(t) do
    keys[#keys+1] = tostring(k)
  end
  return '{'..table_concat(keys, ',')..'}'
end
set.new = set_from_array
-- set operator:
-- + (union)
-- - (except)
-- * (intersect)
-- ^ (sym_except)
-- == (equals test)
-- + (UNION)
function set.__add(t, o)
  local res = set:new()
  for k, _ in pairs(t) do
    res[k] = true
  end
  for k, _ in pairs(o) do
    res[k] = true
  end
  return res
end
set.union = set.__add
-- * (INTERSECT)
function set.__mul(t, o)
  local res = set:new()
  for k, _ in pairs(t) do
    if o[k] then
      res[k] = true
    end
  end
  return res
end
set.intersect = set.__mul
-- - (EXCEPT)
function set.__sub(t, o)
  local res = set:new()
  for k, v in pairs(t) do
    if not o[k] then
      res[k] = true
    end
  end
  return res
end
set.except = set.__sub
-- ^ (symmetric except)
function set.__pow(t, o)
  local res = set:new()
  for k, v in pairs(t) do
    if not o[k] then
      res[k] = true
    end
  end
  for k, v in pairs(o) do
    if not t[k] then
      res[k] = true
    end
  end
  return res
end
set.sym_except = set.__pow
-- == (equals)
function set.__eq(t, o)
  return next(set.__pow(t, o)) == nil
end
set.equals = set.__eq

function set.add(t, ele)
  t[ele] = true
  return t
end

function set.clear(t)
  return table_clear(t)
end

function set.keys(t)
  local keys = {}
  for k, _ in pairs(t) do
    keys[#keys+1] = k
  end
  return keys
end


if select('#', ...) == 0 then
  local a = set{1,2,3}
  local b = set{3,4,5}
  assert(a+b == set{1,2,3,4,5})
  assert(a*b == set{3})
  assert(a^b == set{1,2,4,5})
  assert(a-b == set{1,2})
  assert(b-a == set{4,5})
  print("all test passed!")
end

return set
