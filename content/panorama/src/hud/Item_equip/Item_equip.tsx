import React, { useEffect, useRef, useState } from 'react';
import { createPortal, render, useNetTableValues } from '@demon673/react-panorama';
import ReactUtils from "../../utils/React_utils";
import { print, RGBToHex}  from '../Utils'

export function Item_equip(){
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
    </Panel>
}

function Item_equip_slot({item_name}: {item_name: string}){
    return <Panel id='Item_equip_slot'>
        <DOTAItemImage itemname={item_name} contextEntityIndex={-1 as ItemEntityIndex}/>
    </Panel>
}