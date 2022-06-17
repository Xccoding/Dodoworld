function DodoWorld:OnInventoryItemAdded( params )
    print("on!")
    if params.inventory_parent_entindex == -1 then
        return
    end

    local unit = EntIndexToHScript(params.inventory_parent_entindex)

    unit:SetContextThink(DoUniqueString("remove_item_in_DOTA_ITEM_SLOT_7"), 
    function ()
        if unit:GetItemInSlot(DOTA_ITEM_SLOT_7) ~= nil then
            unit:RemoveItem(unit:GetItemInSlot(DOTA_ITEM_SLOT_7))
        end
        if unit:GetItemInSlot(DOTA_ITEM_SLOT_8) ~= nil then
            unit:RemoveItem(unit:GetItemInSlot(DOTA_ITEM_SLOT_8))
        end
        if unit:GetItemInSlot(DOTA_ITEM_SLOT_9) ~= nil then
            unit:RemoveItem(unit:GetItemInSlot(DOTA_ITEM_SLOT_9))
        end
        return nil
    end, 0)
    
end