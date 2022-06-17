
--计算两向量夹角
function AngleBetweenVectors(v1, v2)
    local angle_1 = VectorAngles(v1)
    local angle_2 = VectorAngles(v2)
    
    return math.min(math.abs( angle_1.y - angle_2.y), 360 - math.abs( angle_1.y - angle_2.y))
end

--拷贝?
function DeepCopy(t)
    local new_table = {}
    for k, v in pairs(t) do
        if type(v) == "table" then
            new_table[k] = DeepCopy(v)
        else
            new_table[k] = v
        end
    end

    return new_table
end

function GetElementCount(t)
    local count = 0
    for key, value in pairs(t) do
        count = count + 1
    end
    return count
end
