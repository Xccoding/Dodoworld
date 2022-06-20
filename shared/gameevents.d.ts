declare interface CustomGameEventDeclarations {
    c2s_test_event: {};

    ChangeRoleMastery: {
        entindex: EntityIndex;
        new_schools: number;
    }

    EquipItem: {
        hero_index: EntityIndex,
        type_name: string,
        item_index: number,
    }

    UnEquipItem: {
        hero_index: EntityIndex,
        unequip_slot: number,
    }
}