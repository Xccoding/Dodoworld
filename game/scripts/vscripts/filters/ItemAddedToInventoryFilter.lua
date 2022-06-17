

BACKPACK_ITEM_COUNT_MAX = 10
BACKPACK_ITEM_COUNT_MAX_OTHERS = 20

function DodoWorld:ItemAddedToInventoryFilter( params )
    if params.item_parent_entindex_const == -1 then
        return true
    end

    local unit = EntIndexToHScript(params.item_parent_entindex_const)
    local inventory = EntIndexToHScript(params.inventory_parent_entindex_const)
    local item = EntIndexToHScript(params.item_entindex_const)
    local item_name = item:GetAbilityName()
    print("filter")
    --print(item:GetAbilityName(), unit:GetUnitName(), inventory:GetUnitName())
    local sItem_type = item_type[item_name]
    local sug_slot = -1
    local slot_count = 1
    if sItem_type ~= nil then
        sug_slot = Item_slot_usage[sItem_type][1]
        slot_count = Item_slot_usage[sItem_type][2]
    end

    --print(sug_slot, slot_count)
    local slot_free = true --需要使用的格子上有没有物品
    for index = sug_slot, sug_slot + slot_count - 1 do
        if unit:GetItemInSlot(index) ~= nil then
            slot_free = false
            break
        end
    end

    --把物品塞进背包
    if slot_free and sug_slot ~= 999 then
        params.suggested_slot = sug_slot
    else
        --尝试放进背包
        local hero_items = CustomNetTables:GetTableValue("hero_items", tostring(unit:GetPlayerOwnerID()))
        local item_count_limit = BACKPACK_ITEM_COUNT_MAX
        if sug_slot == 999 then
            item_count_limit = BACKPACK_ITEM_COUNT_MAX_OTHERS
        end
        if GetElementCount(hero_items[sItem_type]) >= item_count_limit then
            return false
        else
            local new_sug_slot = -1

            for bin_slot = DOTA_ITEM_SLOT_7, DOTA_ITEM_SLOT_9 do
                if unit:GetItemInSlot(bin_slot) == nil then
                    --塞到7-9格，一会儿删
                    new_sug_slot = bin_slot
                    params.suggested_slot = new_sug_slot
                    break
                end
            end

            if new_sug_slot ~= -1 then
                --塞进背包网表
                hero_items[sItem_type][GetElementCount(hero_items[sItem_type]) + 1] = item_name
                CustomNetTables:SetTableValue("hero_items", tostring(unit:GetPlayerOwnerID()), hero_items)
            else
                return false
            end
        end
    end
    
    return true
end