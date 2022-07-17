item_type_define = {
    "weapon_one_hand",
    "weapon_double_hand",
    "item_offhand",
    "item_helmet",
    "item_chest",
    "item_shoulder",
    "item_cape",
    "others",--杂项，免得我想加其他物品
}

--根据物品类型区分装备的位置和格子数
_G.Item_slot_usage = {
    ["weapon_double_hand"] = {DOTA_ITEM_SLOT_1, 2},
    ["weapon_one_hand"] = {DOTA_ITEM_SLOT_1, 1},
    ["item_offhand"] = {DOTA_ITEM_SLOT_2, 1},
    ["item_cape"] = {DOTA_ITEM_SLOT_3, 1},
    ["item_chest"] = {DOTA_ITEM_SLOT_4, 1},
    ["item_helmet"] = {DOTA_ITEM_SLOT_5, 1},
    ["item_shoulder"] = {DOTA_ITEM_SLOT_6, 1},
    ["others"] = {999, 1},
}

_G.bEquipingItem = false

function InitBackpack()
    for playerID = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
        local array = {}
        for i = 1, #item_type_define do
            table.insert(array, {item_type = item_type_define[i], item_list = {}})
        end
        CustomNetTables:SetTableValue("hero_items", tostring(playerID), array)
    end
end

function OnEquipItem(userid, params)
    local hero = EntIndexToHScript(params.hero_index)
    local playerID = hero:GetPlayerOwnerID()
    local sItem_type = params.type_name
    local item_index = params.item_index
    local hero_items = CustomNetTables:GetTableValue("hero_items", tostring(playerID))

    local sug_slot = -1
    local slot_count = 1
    if sItem_type ~= nil then
        sug_slot = Item_slot_usage[sItem_type][1]
        slot_count = Item_slot_usage[sItem_type][2]
    end

    if sItem_type == "weapon_double_hand" then
        --双手武器，把主副手卸了
        OnUnEquipItem(-1, {hero_index = params.hero_index, unequip_slot = DOTA_ITEM_SLOT_1})
        OnUnEquipItem(-1, {hero_index = params.hero_index, unequip_slot = DOTA_ITEM_SLOT_2})
        hero_items = CustomNetTables:GetTableValue("hero_items", tostring(playerID))
    end

    if sItem_type == "weapon_one_hand" then
        local slot_1_item = hero:GetItemInSlot(DOTA_ITEM_SLOT_1)
        local slot_2_item = hero:GetItemInSlot(DOTA_ITEM_SLOT_2)
        if slot_1_item ~= nil and not slot_1_item:IsNull() then
            if KeyValues.item_type[slot_1_item:GetAbilityName()] == "weapon_double_hand" then
                --装着双手武器，卸掉
                OnUnEquipItem(-1, {hero_index = params.hero_index, unequip_slot = DOTA_ITEM_SLOT_1})
            elseif KeyValues.item_type[slot_1_item:GetAbilityName()] == "weapon_one_hand" then
                --主手有单手武器，尝试装副手
                --TODO判断流派能不能双武器
                if slot_2_item ~= nil and not slot_2_item:IsNull() then
                    if KeyValues.item_type[slot_2_item:GetAbilityName()] == "weapon_one_hand" then
                        --副手位置也是单手武器，换掉主手武器
                        OnUnEquipItem(-1, {hero_index = params.hero_index, unequip_slot = DOTA_ITEM_SLOT_1})
                    end
                else
                    sug_slot = DOTA_ITEM_SLOT_2
                end
            end
            
        end
        hero_items = CustomNetTables:GetTableValue("hero_items", tostring(playerID))
    end

    if sItem_type == "item_offhand" then
        local slot_1_item = hero:GetItemInSlot(DOTA_ITEM_SLOT_1)
        local slot_2_item = hero:GetItemInSlot(DOTA_ITEM_SLOT_2)
        if slot_1_item ~= nil then
            if KeyValues.item_type[slot_1_item:GetAbilityName()] == "weapon_double_hand" then
                --装着双手武器，卸掉
                OnUnEquipItem(-1, {hero_index = params.hero_index, unequip_slot = DOTA_ITEM_SLOT_1})
            end
            if KeyValues.item_type[slot_2_item:GetAbilityName()] == "weapon_one_hand" then
                --副手位置是单手武器，换掉副手武器
                OnUnEquipItem(-1, {hero_index = params.hero_index, unequip_slot = DOTA_ITEM_SLOT_2})
            end
        end
        hero_items = CustomNetTables:GetTableValue("hero_items", tostring(playerID))
    end
    
    for index, type_item in pairs(hero_items) do
        if type_item.item_type == sItem_type then
            if type_item.item_list[tostring(item_index)].equip == -1 then
                type_item.item_list[tostring(item_index)].equip = sug_slot
                CustomNetTables:SetTableValue("hero_items", tostring(hero:GetPlayerOwnerID()), hero_items)
                bEquipingItem = true
                hero:AddItemByName(type_item.item_list[tostring(item_index)].item_name)
                break
            end
        end
    end

end

function OnUnEquipItem(userid, params)
    local hero = EntIndexToHScript(params.hero_index)
    local unequip_slot = params.unequip_slot
    local hero_items = CustomNetTables:GetTableValue("hero_items", tostring(hero:GetPlayerOwnerID()))

    for index, type_item in pairs(hero_items) do
        for i = 1, GetElementCount(type_item.item_list) do
            if type_item.item_list[tostring(i)].equip == unequip_slot then
                type_item.item_list[tostring(i)].equip = -1
                CustomNetTables:SetTableValue("hero_items", tostring(hero:GetPlayerOwnerID()), hero_items)
                break
            end
        end
    end

    if hero:GetItemInSlot(unequip_slot) ~= nil then
        hero:RemoveItem(hero:GetItemInSlot(unequip_slot))
    end

end