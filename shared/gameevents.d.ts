declare interface CustomGameEventDeclarations {
    c2s_test_event: {};

    ChangeRoleMastery: {
        entindex: EntityIndex;
        new_schools: number;
    };

    EquipItem: {
        hero_index: EntityIndex,
        type_name: string,
        item_index: number,
    };

    UnEquipItem: {
        hero_index: EntityIndex,
        unequip_slot: number,
    };

    Custom_Cast_Ability: {
        ability: AbilityEntityIndex,
        cursor_pos: {
            x: number,
            y: number,
            z: number,
        };
        cursor_target?: EntityIndex,
    };

    SelectTalent:{
        talent_name: string,
    }
}

interface GameEventDeclarations {
    CustomToggleHud: {
        hud_name: string,
        wish_state?: boolean,
    };
    GetAbilityValue: {
        ability: AbilityEntityIndex,
        key_name: string,
    }
}