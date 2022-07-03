import React, { useEffect, useRef, useState } from 'react';
import { createPortal, render, useNetTableKey, useNetTableValues } from '@demon673/react-panorama';
import ReactUtils from "../../utils/React_utils";
import { print }  from '../Utils'

export function Item_unequip(){
    //const hero_items = useNetTableValues("hero_items")
    const [item_arrays, Setitem_arrays] = useState(update_items)

    function update_items(){
        let item_array_group: {type_name: string, item_list: {item_name: string, equip: number}[]}[] = []

        let hero_items = CustomNetTables.GetTableValue("hero_items", Players.GetLocalPlayer())

        // print(hero_items)

        if(hero_items != undefined){
            
            //const player_items = hero_items[Players.GetLocalPlayer()]
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
                    {/* <Label id='Item_equip_tag' className={"show_equip_tag"} text={item_info.equip}/> */}
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