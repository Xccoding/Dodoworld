
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
