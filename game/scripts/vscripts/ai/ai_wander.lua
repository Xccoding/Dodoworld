
function Spawn()
    if not IsServer() then
		return
	end

    if thisEntity == nil then
        return
    end
    thisEntity:SetContextThink(DoUniqueString("NormalThink"), NormalThink, 1)
end

function NormalThink()
    local unit = thisEntity
    --存在判断
    if unit == nil or unit:IsNull() then
        return
    end
    --存活判断
    if not unit:IsAlive() then
        return
    end

    local spawn_entity = unit.spawn_entity
    if spawn_entity ~= nil then
        if (unit:GetAbsOrigin() - spawn_entity:GetAbsOrigin()):Length2D() > 500 then
            NewWander()
        elseif not unit:IsMoving() then
            NewWander()
        end
    end
    
    return 0.5
end

function NewWander()
    local unit = thisEntity
    local spawn_entity = unit.spawn_entity
    local pos = spawn_entity:GetAbsOrigin() + RandomVector(RandomFloat(0, 500))
    unit:MoveToPosition(pos)
end