DOTA_ITEM_PICK_UP_RANGE = 400
DOTA_ITEM_GIVE_RANGE = 200

function DodoWorld:ExecuteOrderFilter( params )
    if params.order_type == DOTA_UNIT_ORDER_GIVE_ITEM then
        return false
    end

    local hTarget
    if params.entindex_target ~= nil then
        hTarget = EntIndexToHScript(params.entindex_target)
    end

    for _, unit_index in pairs(params.units) do
        if EntIndexToHScript(unit_index):IsHero() then
            local hUnit = EntIndexToHScript(unit_index)

            --print("N2O", params.order_type)
            
            if IsValid(hUnit) and IsValid(hTarget) then
                --交互目标修改
                if (
                    params.order_type == DOTA_UNIT_ORDER_ATTACK_TARGET or 
                    (params.order_type == DOTA_UNIT_ORDER_CAST_TARGET and AbilityBehaviorFilter(EntIndexToHScript(params.entindex_ability):GetBehaviorInt(), DOTA_ABILITY_BEHAVIOR_ATTACK)) 
                )
                and KeyValues:GetUnitSpecialValue(hTarget, "IsInteractiveNPC") then

                    ExecuteOrderFromTable({
                        UnitIndex = unit_index,
                        OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
                        TargetIndex = params.entindex_target,
                        AbilityIndex = hUnit:FindAbilityByName("common_interactive"):entindex(),
                        Queue = false
                    })

                    return false
                end

                --拾取物品修改
                if params.order_type == DOTA_UNIT_ORDER_PICKUP_ITEM and (hUnit:GetAbsOrigin() - hTarget:GetAbsOrigin()):Length2D() <= DOTA_ITEM_PICK_UP_RANGE then
                    --TODO这也太蠢了
                    hUnit:AddItemByName(hTarget:GetContainedItem():GetAbilityName())
                    hTarget:RemoveSelf()
                    return false
                end
            end
        end
    end

    return true
end