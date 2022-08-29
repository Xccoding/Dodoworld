
--计算两向量夹角
function AngleBetweenVectors(v1, v2)
    local angle_1 = VectorAngles(v1)
    local angle_2 = VectorAngles(v2)
    
    return math.min(math.abs( angle_1.y - angle_2.y), 360 - math.abs( angle_1.y - angle_2.y))
end

--拷贝?
-- function DeepCopy(t)
--     local new_table = {}
--     for k, v in pairs(t) do
--         if type(v) == "table" then
--             new_table[k] = DeepCopy(v)
--         else
--             new_table[k] = v
--         end
--     end

--     return new_table
-- end

--获取表的元素个数
function GetElementCount(t)
    local count = 0
    for key, value in pairs(t) do
        count = count + 1
    end
    return count
end

--四舍五入
function Rounding(num)
    return math.floor(num + 0.5)
end

--判断handle是否可用
function IsValid( h )
    if h ~= nil and not h:IsNull() then
        return true
    else
        return false
    end 
end

--获取两点间的中点
function GetMidPoint( v1, v2)
    local dir = (v2 - v1):Normalized()
    local range = (v2 - v1):Length()
    return v1 + dir * range
end

--打印一个table
function TablePrint( t )
    if type(t) == "table" then
        for key, value in pairs(t) do
            print("N2O", key, value)
        end
    end
end

--阶乘函数
function Factorial(n)
    if n == 0 then
        return 1;
    else
        return n * Factorial(n - 1);
    end
end

--组合数函数
function Combinatorial(n, m)
    if n == m or m == 0 then
        return 1
    else
        return Factorial(n) / (Factorial(n - m) * Factorial(m))
    end
end

--- 判断变量是否是向量
function IsVector(v)
	return  type(v.x) == "number" and type(v.y) == "number" and type(v.z) == "number" and type(v) == "userdata"
end
