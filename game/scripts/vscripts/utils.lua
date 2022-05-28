
--计算两向量夹角
function AngleBetweenVectors(v1, v2)
    local angle_1 = VectorAngles(v1)
    local angle_2 = VectorAngles(v2)
    
    return math.min(math.abs( angle_1.y - angle_2.y), 360 - math.abs( angle_1.y - angle_2.y))
end