item_type_define = {
    "weapon_one_hand",
    "weapon_double_hand",
    "item_cape",
    "item_chest",
    "item_helmet",
    "item_shoulder",
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

function InitBackpack()
    for playerID = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
        local array = {}
        for i = 1, #item_type_define do
            array[item_type_define[i]] = {}
        end
        CustomNetTables:SetTableValue("hero_items", tostring(playerID), array)
    end
end

function ItemChangeFilter(unit, item)
    
end