# lua-resty-set
implement union, except, intersect and symmetric except for a set
# Synopsis
```
local a = set{1,2,3}
local b = set{3,4,5}
print(a+b)
print(a*b)
print(a^b)
print(a-b)
print(b-a)
```
output:
```
{1,2,3,4,5}
{3}
{1,2,4,5}
{1,2}
{5,4}
```