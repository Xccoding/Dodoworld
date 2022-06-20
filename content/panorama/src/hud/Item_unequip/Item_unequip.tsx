import React, { useEffect, useRef, useState } from 'react';
import { createPortal, render, useNetTableValues } from '@demon673/react-panorama';
import ReactUtils from "../../utils/React_utils";
import { print }  from '../Utils'

const Item_slot_map = {
    [""]: 1
} 

export function Item_unequip(){
    const hero_items = useNetTableValues("hero_items")
    let item_arrays: {type_name: string, item_list: {item_name: string, equip: number}[]}[] = []

    if(hero_items[Players.GetLocalPlayer()] != undefined){
        
        const player_items = hero_items[Players.GetLocalPlayer()]
        for(const item_type_index in player_items){
            let item_array: {item_name: string, equip: number}[] = []
            for (let j = 0; j < 10; j++) {
                item_array[j] = {item_name: "", equip: -1}
            }

            const item_type_info = player_items[item_type_index]
            for(const index in item_type_info.item_list){
                item_array[Number(index) - 1] = {item_name: item_type_info.item_list[index].item_name, equip: item_type_info.item_list[index].equip}
            }
            item_arrays.push({type_name: item_type_info.item_type, item_list: item_array})
        }
    }

    //print(item_arrays)

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
        <Label text={$.Localize(`#${type_name}`)}/>
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
                    </Button>
                })
            }
        </Panel>
    </Panel>
}

function Item_unequip_slot({item_name}: {item_name: string}){
    return <Panel id='Item_unequip_slot'>
        <DOTAItemImage itemname={item_name} contextEntityIndex={-1 as ItemEntityIndex}/>
    </Panel>
}