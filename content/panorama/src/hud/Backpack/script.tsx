import React, { useEffect, useRef, useState } from "react";
import { render, useNetTableValues } from '@demon673/react-panorama';
import ReactUtils from "../../utils/React_utils";
import { print, useToggleHud }  from '../Utils'

function Backpack(){
    const [ShowState, SetShowState] = useToggleHud("Backpack")

    return <Panel id="Backpack"  className={ShowState ? "Show" : ""}>
        <Panel id="Backpack_left" hittest={false}>
            <Character />
        </Panel>
        <Panel id="Backpack_right">
            <Item_equip/>
            <Item_unequip/>
        </Panel>
    </Panel>
}

function Character(){
    const Character_info = useNetTableValues("hero_attributes")
    const Schools_selected = useNetTableValues("hero_schools")[Players.GetLocalPlayer()].schools_index || 0;
    let attributes_array_stat: {attribute_name: string, attribute_number: number, bIsPercent: boolean}[] = []
    let attributes_array_attack: {attribute_name: string, attribute_number: number, bIsPercent: boolean}[] = []
    let attributes_array_defense: {attribute_name: string, attribute_number: number | object, bIsPercent: boolean}[] = []
    let hero_index: EntityIndex = -1 as EntityIndex

    if(Character_info[Players.GetLocalPlayer()] != undefined){
        const hero_attributes_info = Character_info[Players.GetLocalPlayer()]
        // 三维属性
        attributes_array_stat.push({attribute_name: "strength", attribute_number: Number(hero_attributes_info.strength.toFixed(0)), bIsPercent: false})
        attributes_array_stat.push({attribute_name: "agility", attribute_number: Number(hero_attributes_info.agility.toFixed(0)), bIsPercent: false})
        attributes_array_stat.push({attribute_name: "intellect", attribute_number: Number(hero_attributes_info.intellect.toFixed(0)), bIsPercent: false})
        // 攻击属性
        attributes_array_attack.push({attribute_name: "total_attack_damage", attribute_number: hero_attributes_info.total_attack_damage, bIsPercent: false})
        attributes_array_attack.push({attribute_name: "attack_speed", attribute_number: Number(hero_attributes_info.attack_speed.toFixed(2)), bIsPercent: false})
        attributes_array_attack.push({attribute_name: "spell_power", attribute_number: hero_attributes_info.spell_power, bIsPercent: false})
        attributes_array_attack.push({attribute_name: "cooldown_reduction", attribute_number: hero_attributes_info.cooldown_reduction, bIsPercent: true})
        // 攻击-暴击属性
        attributes_array_attack.push({attribute_name: "physical_crit_chance", attribute_number: Number(hero_attributes_info.physical_crit_chance.toFixed(2)), bIsPercent: true})
        attributes_array_attack.push({attribute_name: "magical_crit_chance", attribute_number: Number(hero_attributes_info.magical_crit_chance.toFixed(2)), bIsPercent: true})
        attributes_array_attack.push({attribute_name: "physical_crit_damage", attribute_number: Number(hero_attributes_info.physical_crit_damage.toFixed(2)), bIsPercent: true})
        attributes_array_attack.push({attribute_name: "magical_crit_damage", attribute_number: Number(hero_attributes_info.magical_crit_damage.toFixed(2)), bIsPercent: true})
        // 防御属性
        attributes_array_defense.push({attribute_name: "physical_armor", attribute_number: hero_attributes_info.physical_armor, bIsPercent: false})
        attributes_array_defense.push({attribute_name: "magical_armor", attribute_number: hero_attributes_info.magical_armor, bIsPercent: false})
        attributes_array_defense.push({attribute_name: "movespeed", attribute_number: hero_attributes_info.movespeed, bIsPercent: false})
        attributes_array_defense.push({attribute_name: "evasion", attribute_number: hero_attributes_info.evasion, bIsPercent: true})
        attributes_array_defense.push({attribute_name: "block", attribute_number: hero_attributes_info.block, bIsPercent: true})

        if(Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer()) != -1){
            hero_index = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer())
        }
    }

    return <Panel id="Character">
            <Panel className="Character_part">
                <Panel className="Character_attributes_title">
                    <Label text={$.Localize("#Character_attributes_stat")}/>
                </Panel>
                {
                    attributes_array_stat.map((value)=>{
                        let primary_stat = "strength"
                        if(hero_index != -1){
                            primary_stat = GameUI.CustomUIConfig().SchoolsKv[Entities.GetUnitLabel(hero_index)][Schools_selected].primary_stat
                        }
                        let sTextTooltip = $.Localize("#hud_text_tooltip_Character_" + value.attribute_name)
                        let sTextTooltip_primary = $.Localize("#hud_text_tooltip_Character_primary_stat")
                        if(primary_stat == value.attribute_name){
                            sTextTooltip = sTextTooltip_primary + sTextTooltip
                        }

                        return <Panel key={"stat"+value.attribute_name} className="Character_attributes_panel" 
                        onmouseover={p=>{
                            $.DispatchEvent("DOTAShowTextTooltip", p, sTextTooltip)
                        }
                        }
                        onmouseout={
                            ()=>{
                                $.DispatchEvent("DOTAHideTextTooltip")
                            }
                        }>
                            <Image className="Character_attributes_icon" src={`file://{images}/hud_icons/character_attribute_${value.attribute_name}.png`}/>
                            <Label className="Character_attributes_name" text={$.Localize("#Character_attribute_" + value.attribute_name)}/>
                            <Label className="Character_attributes_number" text={value.attribute_number + `${value.bIsPercent ? "%": ""}`}/>
                        </Panel>
                    })
                }
            </Panel>
            <Panel className="Character_part">
            <Panel className="Character_attributes_title">
                    <Label text={$.Localize("#Character_attributes_attack")}/>
                </Panel>
                {
                    attributes_array_attack.map((value)=>{
                        return <Panel key={"attack"+value.attribute_name} className="Character_attributes_panel"
                        onmouseover={p=>{
                            $.DispatchEvent("DOTAShowTextTooltip", p, $.Localize("#hud_text_tooltip_Character_"+value.attribute_name))
                        }
                        }
                        onmouseout={
                            ()=>{
                                $.DispatchEvent("DOTAHideTextTooltip")
                            }
                        }>
                            <Image className="Character_attributes_icon" src={`file://{images}/hud_icons/character_attribute_${value.attribute_name}.png`} scaling="stretch-to-fit-preserve-aspect"/>
                            <Label className="Character_attributes_name" text={$.Localize("#Character_attribute_" + value.attribute_name)}/>
                            <Label className="Character_attributes_number" text={value.attribute_number + `${value.bIsPercent ? "%": ""}`}/>
                        </Panel>
                    })
                }
            </Panel>
            <Panel className="Character_part">
                <Panel className="Character_attributes_title">
                    <Label text={$.Localize("#Character_attributes_defense")}/>
                </Panel>
                {
                    attributes_array_defense.map((value)=>{
                        let attribute_num = 0

                        if(typeof(value.attribute_number) == "object"){
                            attribute_num = Number(Number((value.attribute_number as number[])[1]).toFixed(1))
                        }
                        let sTextTooltip = $.Localize("#hud_text_tooltip_Character_"+value.attribute_name)
                        sTextTooltip = sTextTooltip.replace("attribute_num", String(attribute_num))
                        return <Panel key={"defense" + value.attribute_name} className="Character_attributes_panel"
                        onmouseover={p=>{
                            $.DispatchEvent("DOTAShowTextTooltip", p, sTextTooltip)
                        }
                        }
                        onmouseout={
                            ()=>{
                                $.DispatchEvent("DOTAHideTextTooltip")
                            }
                        }  dialogVariables={{ attribute_num: attribute_num }}>
                            <Image className="Character_attributes_icon" src={`file://{images}/hud_icons/character_attribute_${value.attribute_name}.png`}/>
                            <Label className="Character_attributes_name" text={$.Localize("#Character_attribute_" + value.attribute_name)}/>
                            <Label className="Character_attributes_number" text={(typeof(value.attribute_number) == "object"? (value.attribute_number as number[])[0] : value.attribute_number) + `${value.bIsPercent == true ? "%": ""}`}/>
                        </Panel>
                    })
                }
            </Panel>
    </Panel>
}

function Item_equip(){
    const [hero_items, Setitems] = useState(update_items)

    function update_items(){
        const player = Players.GetLocalPlayer()
        const hero = Players.GetPlayerHeroEntityIndex(player)
        let item_array: string[] = ["", "", "", "", "", "",]
        if(hero != -1){
            for (let index = 0; index <= 5; index++) {
                const this_item = Entities.GetItemInSlot(hero, index)
                if(this_item != undefined){
                    item_array[index] = Abilities.GetAbilityName(this_item)
                }
            }
        }
        return item_array
    }

    useEffect(() => {
		let func = () => {
			Setitems(update_items);
		}

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
		}
	}, []);


    return <Panel id='Item_equip'>
        <DOTAScenePanel id='backpack_portrait' map='scene/backpack_portrait' light='light' camera='camera1' antialias={true} allowrotation={true} particleonly={false} >
        {
            hero_items.map((item_name, slot_index)=>{
                return <Button key={slot_index} id={`item_slot_${slot_index}`} hittest={true} 
                oncontextmenu={()=>{
                    if(item_name != ""){
                        GameEvents.SendCustomGameEventToServer("UnEquipItem",{
                            hero_index: Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer()),
                            unequip_slot: slot_index 
                        })
                    }
                }}>
                    <Item_equip_slot item_name={item_name}/>
                </Button>
            })
        }
        </DOTAScenePanel>
    </Panel>
}

function Item_equip_slot({item_name}: {item_name: string}){
    return <Panel id='Item_equip_slot'>
        <DOTAItemImage itemname={item_name} contextEntityIndex={-1 as ItemEntityIndex}/>
    </Panel>
}

function Item_unequip(){
    const [item_arrays, Setitem_arrays] = useState(update_items)

    function update_items(){
        let item_array_group: {type_name: string, item_list: {item_name: string, equip: number}[]}[] = []
        let hero_items = CustomNetTables.GetTableValue("hero_items", Players.GetLocalPlayer())


        if(hero_items != undefined){
            for(const item_type_index in hero_items){
                let item_array: {item_name: string, equip: number}[] = []
                for (let j = 0; j < 12; j++) {
                    item_array[j] = {item_name: "", equip: -1}
                }

                const item_type_info = hero_items[item_type_index]
                for(const index in item_type_info.item_list){
                    item_array[Number(index) - 1] = {item_name: item_type_info.item_list[index].item_name, equip: item_type_info.item_list[index].equip}
                }
                item_array_group.push({type_name: item_type_info.item_type, item_list: item_array})
            }
        }

        return item_array_group
    }

    useEffect(() => {
		let func = () => {
			Setitem_arrays(update_items);
		}

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
		}
	}, []);

    return <Panel id='Item_unequip'>
        {
            item_arrays.map((item_type, index)=>{
                return <Item_unequip_type key={item_type.type_name} type_name={item_type.type_name} item_list={item_type.item_list}/>
            })
        }
    </Panel>
}

function Item_unequip_type({type_name, item_list}: {type_name: string, item_list: {item_name: string, equip: number}[]}){
 
    return <Panel id='Item_unequip_type'>
        <Label id='Item_unequip_type_title' text={$.Localize(`#${type_name}`)}/>
        <Panel id='item_list'>
            {
                item_list.map((item_info, index)=>{       
                              
                    return <Button key={type_name + index} hittest={true} id='Item_slot_panel' oncontextmenu={()=>{
                        if(item_info.item_name != ""){
                            
                            if(item_info.equip == -1){
                                // 未装备
                                GameEvents.SendCustomGameEventToServer("EquipItem", {hero_index: Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer()), type_name: type_name, item_index: index + 1})
                            }
                            else
                            {
                                // 已装备
                                GameEvents.SendCustomGameEventToServer("UnEquipItem",{
                                    hero_index: Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer()),
                                    unequip_slot: item_info.equip 
                                })
                            }
                        }
                    }}>
                    <Item_unequip_slot item_name={item_info.item_name}/>
                    <Label id='Item_equip_tag' className={item_info.equip == -1? "" : "show_equip_tag"} text={$.Localize("#Item_in_equip_tip")}/>
                    </Button>
                })
            }
        </Panel>
    </Panel>
}

function Item_unequip_slot({item_name}: {item_name: string}){
    return <Panel id='Item_unequip_slot'>
        <DOTAItemImage id='Item_unequip_image' itemname={item_name} contextEntityIndex={-1 as ItemEntityIndex}/>
    </Panel>
}

$.Schedule(0.5, ()=>{
    render(<Backpack/>, $.GetContextPanel())
})

