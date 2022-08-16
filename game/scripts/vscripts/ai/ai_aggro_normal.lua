
function Spawn( kv )
    if not IsServer() then
		return
	end

    if thisEntity == nil then
        return
    end
    SaveSpawnKV( thisEntity, kv )
    thisEntity.current_order = {order = nil, fEndtime = nil}
    thisEntity:SetContextThink(DoUniqueString("NormalThink"), NormalThink, 1)
end

function NormalThink()
    local unit = thisEntity
    if not IsServer() then
        return
    end
    --存在判断
    if unit == nil then
        --print("unit == nil")
        return
    end
    --存活判断
    if not unit:IsAlive() then
        --print("unit is dead")
        return
    end
    local MaxPursueRange = unit.kv_ai_table.MaxPursueRange or 0
    local MaxWanderRange = unit.kv_ai_table.MaxWanderRange or 0
    local CombatFindRadius = unit.kv_ai_table.CombatFindRadius or 0
    local WanderType = unit.kv_ai_table.WanderType or AI_WANDER_TYPE_PASSIVE

    local NeedCombatBehavior = false

    -----------------更新仇恨目标---------------------------
    --超距返回
    if (unit:GetAbsOrigin() - unit.spawn_entity:GetAbsOrigin()):Length2D() > MaxPursueRange then
        if not (unit.current_order.order == DOTA_UNIT_ORDER_MOVE_TO_POSITION and unit.current_order.bForce == false) then
            NewWander(true)
            AI_manager:ClearAggroTarget(unit)
            unit:RemoveModifierByName("modifier_combat")
            unit:AddNewModifier(unit, nil, "modifier_escape", {duration = 0.35})
            return 0.25
        else
            if unit.current_order.fEndtime >= GameRules:GetGameTime() then
                NewWander(true)
                AI_manager:ClearAggroTarget(unit)
                unit:RemoveModifierByName("modifier_combat")
                unit:AddNewModifier(unit, nil, "modifier_escape", {duration = 0.35})
                return 0.25
            end
        end
    else
        if unit.current_order.order == DOTA_UNIT_ORDER_MOVE_TO_POSITION and unit.current_order.bForce == true and (unit:GetAbsOrigin() - unit.spawn_entity:GetAbsOrigin()):Length2D() >= MaxWanderRange then
            NewWander(true)
            AI_manager:ClearAggroTarget(unit)
            unit:RemoveModifierByName("modifier_combat")
            unit:AddNewModifier(unit, nil, "modifier_escape", {duration = 0.35})
            return 0.25
        end
    end
    
    --未超距，判断根据什么条件更新
    -- if unit:InCombat() then
    --     unit:C_RefreshAggroTarget(AI_GET_TARGET_ORDER_DHPS, math.max(unit:GetAcquisitionRange(), CombatFindRadius), nil)
    -- else
    --     if unit:GetAcquisitionRange() > 0 then
    --         unit:C_RefreshAggroTarget(AI_GET_TARGET_ORDER_RANGE, math.max(unit:GetAcquisitionRange(), CombatFindRadius), nil)
    --     else
    --         unit:C_ClearAggroTarget()
    --     end
    -- end

    --如果没有仇恨目标，脱战
    if AI_manager:GetWishAttackTarget(unit) == nil and unit:InCombat() then
        unit:RemoveModifierByName("modifier_combat")
        unit:AddNewModifier(unit, nil, "modifier_escape", {duration = 0.35})
    end
    -----------------战斗行为----------------------------
    --非战斗中
    if not unit:InCombat() then
        --主动攻击距离>0，会主动攻击
        if AI_manager:GetWishAttackTarget(unit) ~= nil then
            NeedCombatBehavior = true
        end
        if WanderType ~= nil then 
            --是否会主动游荡
            if WanderType == AI_WANDER_TYPE_ACTIVE or WanderType == AI_WANDER_TYPE_ALWAYS then
                if unit.current_order.order == nil or (unit.current_order.order ~= nil and unit.current_order.fEndtime < GameRules:GetGameTime()) then
                    -- print("new wander")
                    NewWander(false)
                    return 0.25
                end
            end
        end
    else
        NeedCombatBehavior = true
    end
    ------------------战斗中-----------------
    if NeedCombatBehavior and unit.current_order.order == nil or (unit.current_order.order ~= nil and unit.current_order.fEndtime < GameRules:GetGameTime() and not unit:IsChanneling()) or unit.current_order.order == DOTA_UNIT_ORDER_MOVE_TO_POSITION then
        ------------------需要新行为-------------------
        local desires = {}
        local max_desires = {}
        local max_desire = 0
        local behavior_can_excute = 0
        --计算主动技能数量
        for index = 0, unit:GetAbilityCount() - 1 do
            local hAbility = unit:GetAbilityByIndex(index)
            if hAbility ~= nil and (not hAbility:IsPassive()) then
                behavior_can_excute = behavior_can_excute + 1
            end
        end
        --判断要不要加上攻击
        --找单位A的order
        if unit:GetAttackCapability() ~= DOTA_UNIT_CAP_NO_ATTACK then
            --可以攻击
            if AI_manager:GetWishAttackTarget(unit) ~= nil then
                table.insert(desires, {desire = 1 / behavior_can_excute, ordertable = {
                    UnitIndex = unit:entindex(),
                    OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
                    TargetIndex = AI_manager:GetWishAttackTarget(unit):entindex(),
                    Queue = false,
                }})
            end
        end
        --寻找能放的技能
        if behavior_can_excute > 0 then
            for index = 0, unit:GetAbilityCount() - 1 do
                local hAbility = unit:GetAbilityByIndex(index)
                --local behaviors = hAbility:GetAIBehavior()
                -- if desires[index] == nil then
                --     desires[index] = 0
                -- end
                if hAbility ~= nil and (not hAbility:IsPassive()) then
                    if hAbility:IsFullyCastable() then
                        local find_radius = 0
                        local param_target = false
                        local param_position = false
                        local has_target = false
                        local order_type = nil
                        if AbilityBehaviorFilter(hAbility:GetBehaviorInt(), DOTA_ABILITY_BEHAVIOR_UNIT_TARGET) then
                            --单体技能
                            find_radius = hAbility:GetCastRange(unit:GetAbsOrigin(), nil)
                            param_target = true
                        elseif AbilityBehaviorFilter(hAbility:GetBehaviorInt(), DOTA_ABILITY_BEHAVIOR_NO_TARGET) then
                            --无目标范围技能
                            find_radius = hAbility:GetCastRange(unit:GetAbsOrigin(), nil)
                        elseif AbilityBehaviorFilter(hAbility:GetBehaviorInt(), DOTA_ABILITY_BEHAVIOR_POINT) then
                            --点目标范围技能
                            find_radius = hAbility:GetCastRange(unit:GetAbsOrigin(), nil) - hAbility:GetAOERadius()
                            param_position = true
                        end
    
                        local tTargets = FindUnitsInRadius(unit:GetTeamNumber(), unit:GetAbsOrigin(), nil, find_radius, hAbility:GetAbilityTargetTeam(), hAbility:GetAbilityTargetType(), hAbility:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)
                        if #tTargets > 0 then
                            for _, target in pairs(tTargets) do
                                if target ~= nil and target:IsAlive() then
                                    if param_target and (not param_position) then
                                        param_target = target:entindex()
                                        param_position = nil
                                        order_type = DOTA_UNIT_ORDER_CAST_TARGET
                                    elseif (not param_target) and param_position then
                                        param_target = nil
                                        param_position = target:GetAbsOrigin() + RandomVector(RandomFloat(0, hAbility:GetAOERadius()))
                                        order_type = DOTA_UNIT_ORDER_CAST_POSITION
                                    elseif (not param_target) and (not param_position) then
                                        param_target = nil
                                        param_position = nil
                                        order_type = DOTA_UNIT_ORDER_CAST_NO_TARGET
                                    end
                                    has_target = true
                                    break
                                end
                            end
                            if has_target then
                                table.insert(desires, {desire = 1 / behavior_can_excute, ordertable = {
                                    UnitIndex = unit:entindex(),
                                    OrderType = order_type,
                                    TargetIndex = param_target,
                                    AbilityIndex = hAbility:entindex(),
                                    Position = param_position,
                                    Queue = false,
                            }})
                            else
                                --table.insert(desires,{desire = 0,})
                            end
                        else
                            --table.insert(desires,{desire = 0,})
                        end
    
                    end
                end
            end
        end

        --遍历desires，取最大的desire
        if #desires > 0 then
            for index = 1, #desires do
                if desires[index].desire ~= nil then
                    if desires[index].desire > max_desire and desires[index].desire > 0 then
                        max_desires = {}
                        table.insert(max_desires, desires[index])
                    elseif desires[index].desire == max_desire and desires[index].desire > 0 then
                        table.insert(max_desires, desires[index])
                    end
                end
            end
        end
        if #max_desires >= 1 then
            local order_table = max_desires[RandomInt(1, #max_desires)].ordertable
            ExecuteOrderFromTable(
                order_table
            )
            if order_table.OrderType == DOTA_UNIT_ORDER_ATTACK_TARGET then
                unit.current_order = {order = order_table.OrderType, fEndtime = GameRules:GetGameTime() + 2, bForce = false}
            else
                unit.current_order = {order = order_table.OrderType, fEndtime = GameRules:GetGameTime() + EntIndexToHScript(order_table.AbilityIndex):GetCastPoint() + EntIndexToHScript(order_table.AbilityIndex):GetChannelTime() + RandomFloat(1, 2), bForce = false}
            end
        elseif #max_desires == 0 then
            --不再处理没有max_desires的情况
            if WanderType == AI_WANDER_TYPE_ALWAYS then
                NewWander(false)
            end
        end
        return 0.25
    end

    return 0.25
end

function NewWander(bForce)
    local unit = thisEntity
    local spawn_entity = unit.spawn_entity
    local pos = spawn_entity:GetAbsOrigin()
    local time = (pos - unit:GetAbsOrigin()):Length2D()
    local MaxWanderRange = unit.kv_ai_table.MaxWanderRange or 0
    for i = 1, 100 do
        local pos_try = spawn_entity:GetAbsOrigin() + RandomVector(RandomFloat(0, MaxWanderRange))
        if GridNav:CanFindPath(unit:GetAbsOrigin(), pos_try) then
            pos = pos_try
            time = GridNav:FindPathLength(unit:GetAbsOrigin(), pos_try) / unit:GetIdealSpeed()
            break
        end
    end
    ExecuteOrderFromTable({
        UnitIndex = unit:entindex(),
        OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
        Position = pos,
        Queue = not bForce,
    })
    unit.current_order = {order = DOTA_UNIT_ORDER_MOVE_TO_POSITION, fEndtime = GameRules:GetGameTime() + time, bForce = bForce}
end

