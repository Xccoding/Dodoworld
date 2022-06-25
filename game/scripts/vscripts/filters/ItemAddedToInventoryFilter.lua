

BACKPACK_ITEM_COUNT_MAX = 12
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

    --如果是从背包里装备物品，直接成功
    if bEquipingItem then
        if sItem_type == "weapon_one_hand" then
            local slot_1_item = unit:GetItemInSlot(DOTA_ITEM_SLOT_1)
            local slot_2_item = unit:GetItemInSlot(DOTA_ITEM_SLOT_2)
            if slot_1_item ~= nil then
                if item_type[slot_1_item:GetAbilityName()] == "weapon_one_hand" then
                    --主手有单手武器，尝试装副手
                    --TODO判断流派能不能双武器
                    if slot_2_item == nil then
                        sug_slot = DOTA_ITEM_SLOT_2
                    end
                end
            end
        end

        bEquipingItem = false
        params.suggested_slot = sug_slot
        return true
    end

    --把物品塞进背包
    if false and slot_free and sug_slot ~= 999 then--去掉了默认装备的逻辑，会直接走else
        params.suggested_slot = sug_slot
    else
        --尝试放进背包
        local hero_items = CustomNetTables:GetTableValue("hero_items", tostring(unit:GetPlayerOwnerID()))
        local item_count_limit = BACKPACK_ITEM_COUNT_MAX
        -- if sug_slot == 999 then
        --     item_count_limit = BACKPACK_ITEM_COUNT_MAX_OTHERS
        -- end
        local type_index = 0
        for index, type_item in pairs(hero_items) do
            if type_item.item_type == sItem_type then
                type_index = index
                break
            end
        end
        if type_index ~= 0 then
            if GetElementCount(hero_items[type_index].item_list) >= item_count_limit then
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
                    (hero_items[type_index].item_list)[GetElementCount(hero_items[type_index].item_list) + 1] = {item_name = item_name, equip = -1}
                    CustomNetTables:SetTableValue("hero_items", tostring(unit:GetPlayerOwnerID()), hero_items)
                else
                    return false
                end
            end
        else
            return false
        end
        
    end
    
    return true
end