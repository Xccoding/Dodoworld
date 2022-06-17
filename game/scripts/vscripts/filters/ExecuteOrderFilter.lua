DOTA_ITEM_PICK_UP_RANGE = 400
DOTA_ITEM_GIVE_RANGE = 200

function DodoWorld:ExecuteOrderFilter( params )
    if params.order_type == DOTA_UNIT_ORDER_GIVE_ITEM then
        return false
    end

    for _, unit_index in pairs(params.units) do
        if EntIndexToHScript(unit_index):IsHero() then
            local hUnit = EntIndexToHScript(unit_index)
            local hTarget = EntIndexToHScript(params.entindex_target)
    
            if hUnit ~= nil and hTarget ~= nil then
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