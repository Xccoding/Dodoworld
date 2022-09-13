import React, { useEffect, useRef, useState } from "react";
import { render, useNetTableValues } from '@demon673/react-panorama';
import ReactUtils from "../../utils/React_utils";
import { GetUnitAttribute, print, replaceAll, useToggleHud } from '../Utils';

function Backpack() {
    const [ShowState, SetShowState] = useToggleHud("Backpack");

    return <Panel id="Backpack" className={ShowState ? "Show" : ""}>
        <Panel id="Backpack_left" hittest={false}>
            <Character />
        </Panel>
        <Panel id="Backpack_right">
            <Item_equip />
            <Item_unequip />
        </Panel>
    </Panel>;
}

const Character_Attributes = {
    ["stat"]: {
        strength: {
            fixCount: 0,
            bIsPercent: false,
        },
        agility: {
            fixCount: 0,
            bIsPercent: false,
        },
        intellect: {
            fixCount: 0,
            bIsPercent: false,
        },
    },
    ["attack"]: {
        attack_damage: {
            fixCount: 0,
            bIsPercent: false,
        },
        attack_speed: {
            fixCount: 2,
            bIsPercent: false,
        },
        spell_power: {
            fixCount: 0,
            bIsPercent: false,
        },
        cooldown_reduction: {
            fixCount: 0,
            bIsPercent: true,
        },
        physical_crit_chance: {
            fixCount: 2,
            bIsPercent: true,
        },
        magical_crit_chance: {
            fixCount: 2,
            bIsPercent: true,
        },
        physical_crit_damage: {
            fixCount: 2,
            bIsPercent: true,
        },
        magical_crit_damage: {
            fixCount: 2,
            bIsPercent: true,
        },
    },
    ["defense"]: {
        physical_armor: {
            fixCount: 0,
            bIsPercent: false,
        },
        magical_armor: {
            fixCount: 0,
            bIsPercent: false,
        },
        movespeed: {
            fixCount: 0,
            bIsPercent: false,
        },
        evasion: {
            fixCount: 0,
            bIsPercent: true,
        },
        block: {
            fixCount: 0,
            bIsPercent: true,
        },
    },
};

function Character() {
    const [Character_info, SetCharacter_info] = useState<{
        Type: string,
        Info: any[];
    }[]>([]);

    ReactUtils.useSchedule(() => {
        let hero = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer());
        let attrList: {
            Type: string,
            Info: any[];
        }[] = [];
        for (const attrType in Character_Attributes) {
            let temp: {
                attribute_name: string,
                attribute_number: number,
                bIsPercent: boolean,
            }[] = [];
            const TypeArray = (Character_Attributes as any)[attrType];
            for (const attrName in TypeArray) {
                const attrInfo = TypeArray[attrName];
                let value = GetUnitAttribute(attrName, hero);
                temp.push({ attribute_name: attrName, attribute_number: Number(value.toFixed(attrInfo.fixCount)), bIsPercent: attrInfo.bIsPercent });
            }
            attrList.push({ Type: attrType, Info: temp });
        }

        SetCharacter_info(attrList);
        // print("N2O", attrList);
        // print("N2O", GetUnitAttribute("physical_armor", hero))
        return Math.max(Game.GetGameFrameTime(), 1 / 30);
    }, []);
    
    // print("N2O", Character_info);

    return <Panel id="Character">
        {
            Character_info.map((TypeGroup, index) => {
                // print("N2O", TypeGroup.Info)
                return <Panel key={index} id="Character_block">
                    <Panel className="Character_attributes_title">
                        <Label text={$.Localize("#Character_attributes_" + TypeGroup.Type)} />
                    </Panel>
                    {
                        (TypeGroup.Info).map((attrInfo, i) => {
                            let hero = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer());
                            let Schools_selected = CustomNetTables.GetTableValue("hero_schools", Players.GetLocalPlayer())?.schools_index || 0;
                            let primary_stat = GameUI.CustomUIConfig().SchoolsKv[Entities.GetUnitLabel(hero)]?.[Schools_selected]?.primary_stat || "strength";
                            let sTextTooltip = $.Localize("#hud_text_tooltip_Character_" + attrInfo.attribute_name);
                            let sTextTooltip_primary = $.Localize("#hud_text_tooltip_Character_primary_stat");
                            if (primary_stat == attrInfo.attribute_name) {
                                sTextTooltip = sTextTooltip_primary + sTextTooltip;
                            }

                            for (let j = 1; j < 100; j++) {
                                if(sTextTooltip.indexOf(`[!s:value${j}]`) != -1){
                                    sTextTooltip = replaceAll(sTextTooltip, `\[!s:value[${j}]+\]`, GetUnitAttribute(attrInfo.attribute_name + `_value${j}`, hero).toFixed(1))
                                }
                                else{
                                    break
                                }
                            }

                            return <Panel key={i} className="Character_attributes_panel"
                                onmouseover={p => {
                                    $.DispatchEvent("DOTAShowTextTooltip", p, sTextTooltip);
                                }
                                }
                                onmouseout={
                                    () => {
                                        $.DispatchEvent("DOTAHideTextTooltip");
                                    }
                                }>
                                <Image className="Character_attributes_icon" src={`file://{images}/hud_icons/character_attribute_${attrInfo.attribute_name}.png`} />
                                <Label className="Character_attributes_name" text={$.Localize("#Character_attribute_" + attrInfo.attribute_name)} />
                                <Label className="Character_attributes_number" text={attrInfo.attribute_number + `${attrInfo.bIsPercent ? "%" : ""}`} />
                            </Panel>;
                        })
                    }
                </Panel>;
            })
        }
    </Panel>;
}

function Item_equip() {
    const [hero_items, Setitems] = useState(update_items);

    function update_items() {
        const player = Players.GetLocalPlayer();
        const hero = Players.GetPlayerHeroEntityIndex(player);
        let item_array: string[] = ["", "", "", "", "", "",];
        if (hero != -1) {
            for (let index = 0; index <= 5; index++) {
                const this_item = Entities.GetItemInSlot(hero, index);
                if (this_item != undefined) {
                    item_array[index] = Abilities.GetAbilityName(this_item);
                }
            }
        }
        return item_array;
    }

    useEffect(() => {
        let func = () => {
            Setitems(update_items);
        };

        func();
        const listeners = [
            GameEvents.Subscribe("dota_inventory_changed", func),
            GameEvents.Subscribe("dota_inventory_item_changed", func),
            GameEvents.Subscribe("dota_hero_inventory_item_change", func),
            GameEvents.Subscribe("dota_inventory_item_added", func),
        ];

        return () => {
            listeners.forEach((listener) => {
                GameEvents.Unsubscribe(listener);
            });
        };
    }, []);


    return <Panel id='Item_equip'>
        <DOTAScenePanel id='backpack_portrait' map='scene/backpack_portrait' light='light' camera='camera1' antialias={true} allowrotation={true} particleonly={false} >
            {
                hero_items.map((item_name, slot_index) => {
                    return <Button key={slot_index} id={`item_slot_${slot_index}`} hittest={true}
                        oncontextmenu={() => {
                            if (item_name != "") {
                                GameEvents.SendCustomGameEventToServer("UnEquipItem", {
                                    hero_index: Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer()),
                                    unequip_slot: slot_index
                                });
                            }
                        }}>
                        <Item_equip_slot item_name={item_name} />
                    </Button>;
                })
            }
        </DOTAScenePanel>
    </Panel>;
}

function Item_equip_slot({ item_name }: { item_name: string; }) {
    return <Panel id='Item_equip_slot'>
        <DOTAItemImage itemname={item_name} contextEntityIndex={-1 as ItemEntityIndex} />
    </Panel>;
}

function Item_unequip() {
    const [item_arrays, Setitem_arrays] = useState(update_items);

    function update_items() {
        let item_array_group: { type_name: string, item_list: { item_name: string, equip: number; }[]; }[] = [];
        let hero_items = CustomNetTables.GetTableValue("hero_items", Players.GetLocalPlayer());


        if (hero_items != undefined) {
            for (const item_type_index in hero_items) {
                let item_array: { item_name: string, equip: number; }[] = [];
                for (let j = 0; j < 12; j++) {
                    item_array[j] = { item_name: "", equip: -1 };
                }

                const item_type_info = hero_items[item_type_index];
                for (const index in item_type_info.item_list) {
                    item_array[Number(index) - 1] = { item_name: item_type_info.item_list[index].item_name, equip: item_type_info.item_list[index].equip };
                }
                item_array_group.push({ type_name: item_type_info.item_type, item_list: item_array });
            }
        }

        return item_array_group;
    }

    useEffect(() => {
        let func = () => {
            Setitem_arrays(update_items);
        };

        func();
        const listeners = [
            GameEvents.Subscribe("dota_inventory_changed", func),
            GameEvents.Subscribe("dota_inventory_item_changed", func),
            GameEvents.Subscribe("dota_hero_inventory_item_change", func),
            GameEvents.Subscribe("dota_inventory_item_added", func),
        ];

        return () => {
            listeners.forEach((listener) => {
                GameEvents.Unsubscribe(listener);
            });
        };
    }, []);

    return <Panel id='Item_unequip'>
        {
            item_arrays.map((item_type, index) => {
                return <Item_unequip_type key={item_type.type_name} type_name={item_type.type_name} item_list={item_type.item_list} />;
            })
        }
    </Panel>;
}

function Item_unequip_type({ type_name, item_list }: { type_name: string, item_list: { item_name: string, equip: number; }[]; }) {

    return <Panel id='Item_unequip_type'>
        <Label id='Item_unequip_type_title' text={$.Localize(`#${type_name}`)} />
        <Panel id='item_list'>
            {
                item_list.map((item_info, index) => {

                    return <Button key={type_name + index} hittest={true} id='Item_slot_panel' oncontextmenu={() => {
                        if (item_info.item_name != "") {

                            if (item_info.equip == -1) {
                                // 未装备
                                GameEvents.SendCustomGameEventToServer("EquipItem", { hero_index: Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer()), type_name: type_name, item_index: index + 1 });
                            }
                            else {
                                // 已装备
                                GameEvents.SendCustomGameEventToServer("UnEquipItem", {
                                    hero_index: Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer()),
                                    unequip_slot: item_info.equip
                                });
                            }
                        }
                    }}>
                        <Item_unequip_slot item_name={item_info.item_name} />
                        <Label id='Item_equip_tag' className={item_info.equip == -1 ? "" : "show_equip_tag"} text={$.Localize("#Item_in_equip_tip")} />
                    </Button>;
                })
            }
        </Panel>
    </Panel>;
}

function Item_unequip_slot({ item_name }: { item_name: string; }) {
    return <Panel id='Item_unequip_slot'>
        <DOTAItemImage id='Item_unequip_image' itemname={item_name} contextEntityIndex={-1 as ItemEntityIndex} />
    </Panel>;
}

$.Schedule(1.5, () => {
    render(<Backpack />, $.GetContextPanel());
})

