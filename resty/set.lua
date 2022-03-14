local pairs = pairs
local select = select
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
  print(a+b)
  print(a*b)
  print(a^b)
  print(a-b)
  print(b-a)
end

return set
