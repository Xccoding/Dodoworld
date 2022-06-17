import React, { useEffect, useRef, useState } from 'react';
import { createPortal, render, useNetTableValues } from '@demon673/react-panorama';
import ReactUtils from "../../utils/React_utils";
import { print, RGBToHex}  from '../Utils'

export function Item_unequip(){
    const hero_items = useNetTableValues("hero_items")
    const [item_arrays, Setitem_arrays] = useState()

    if(hero_items[Players.GetLocalPlayer()] != undefined){
        const player_items = hero_items[Players.GetLocalPlayer()]
        for(const type_name in player_items){
            let item_array = []
            const item_list = player_items[type_name]
            for(const index in item_list){
                //print(index)
            }
            
        }
    }

    return <Panel>

    </Panel>
}

function Item_equip_slot(){
    return <Panel>
        
    </Panel>
}