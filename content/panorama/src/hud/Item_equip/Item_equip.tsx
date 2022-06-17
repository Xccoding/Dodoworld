import React, { useEffect, useRef, useState } from 'react';
import { createPortal, render, useNetTableValues } from '@demon673/react-panorama';
import ReactUtils from "../../utils/React_utils";
import { print, RGBToHex}  from '../Utils'

export function Item_equip(){
    const [hero_items, Setitems] = useState(update_items)

    function update_items(){
        const player = Players.GetLocalPlayer()
        const hero = Players.GetPlayerHeroEntityIndex(player)
        let item_array: string[] = []
        if(hero != -1){
            for (let index = 0; index < 5; index++) {
                const this_item = Entities.GetItemInSlot(hero, index)
                if(this_item != undefined){
                    item_array.push(Abilities.GetAbilityName(this_item))
                }
            }
        }
        return item_array
    }

    useEffect(() => {
		let func = () => {
            print("update")
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

    return <Panel>

    </Panel>
}

function Item_equip_slot(){
    return <Panel>
        
    </Panel>
}