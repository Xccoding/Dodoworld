--根据物品类型区分装备的位置和格子数
_G.Item_slot_usage = {
    ["weapon_double_hand"] = {DOTA_ITEM_SLOT_1, 2},
    ["weapon_one_hand"] = {DOTA_ITEM_SLOT_1, 1},
    ["item_offhand"] = {DOTA_ITEM_SLOT_2, 1},
    ["item_cape"] = {DOTA_ITEM_SLOT_3, 1},
    ["item_chest"] = {DOTA_ITEM_SLOT_4, 1},
    ["item_helmet"] = {DOTA_ITEM_SLOT_5, 1},
    ["item_shoulder"] = {DOTA_ITEM_SLOT_6, 1},
}


function DodoWorld:ItemAddedToInventoryFilter( params )
    if params.item_parent_entindex_const == -1 then
        return true
    end

    local unit = EntIndexToHScript(params.item_parent_entindex_const)
    local inventory = EntIndexToHScript(params.inventory_parent_entindex_const)
    local item = EntIndexToHScript(params.item_entindex_const)
    local item_name = item:GetAbilityName()
    
    print(item:GetAbilityName(), unit:GetUnitName(), inventory:GetUnitName())
    local sItem_type = item_type[item_name]
    local sug_slot = -1
    local slot_count = 1
    if sItem_type ~= nil then
        sug_slot = Item_slot_usage[sItem_type][1]
        slot_count = Item_slot_usage[sItem_type][2]
    end

    print(sug_slot, slot_count)
    for index = sug_slot, sug_slot + slot_count - 1 do
        if unit:GetItemInSlot(index) ~= nil then
            --TODO把物品塞进背包

            unit:RemoveItem(unit:GetItemInSlot(index))
        end
    end
    params.suggested_slot = sug_slot
    
    return true
end