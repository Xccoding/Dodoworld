import React, { useEffect, useRef, useState } from "react";
import { render, useNetTableValues } from '@demon673/react-panorama';
import ReactUtils from "../../utils/React_utils";
import { print}  from '../Utils'

export function Character(){
    const Character_info = useNetTableValues("hero_attributes")
    let attributes_array_stat: {attribute_name: string, attribute_number: number, bIsPercent: boolean}[] = []
    let attributes_array_attack: {attribute_name: string, attribute_number: number, bIsPercent: boolean}[] = []
    let attributes_array_defense: {attribute_name: string, attribute_number: number, bIsPercent: boolean}[] = []
    let attributes_array_crit: {attribute_name: string, attribute_number: number, bIsPercent: boolean}[] = []
    let hero_index: EntityIndex = -1 as EntityIndex

    if(Character_info[Players.GetLocalPlayer()] != undefined){
        const hero_attributes_info = Character_info[Players.GetLocalPlayer()]
        attributes_array_stat.push({attribute_name: "strength", attribute_number: hero_attributes_info.strength, bIsPercent: false})
        attributes_array_stat.push({attribute_name: "agility", attribute_number: hero_attributes_info.agility, bIsPercent: false})
        attributes_array_stat.push({attribute_name: "intellect", attribute_number: hero_attributes_info.intellect, bIsPercent: false})
        attributes_array_attack.push({attribute_name: "total_attack_damage", attribute_number: hero_attributes_info.total_attack_damage, bIsPercent: false})
        attributes_array_attack.push({attribute_name: "attack_speed", attribute_number: Number(hero_attributes_info.attack_speed.toFixed(2)), bIsPercent: false})
        attributes_array_attack.push({attribute_name: "spell_power", attribute_number: hero_attributes_info.spell_power, bIsPercent: false})
        attributes_array_attack.push({attribute_name: "cooldown_reduction", attribute_number: hero_attributes_info.cooldown_reduction, bIsPercent: true})
        attributes_array_defense.push({attribute_name: "physical_armor", attribute_number: hero_attributes_info.physical_armor, bIsPercent: false})
        attributes_array_defense.push({attribute_name: "magical_armor", attribute_number: hero_attributes_info.magical_armor, bIsPercent: true})
        attributes_array_defense.push({attribute_name: "movespeed", attribute_number: hero_attributes_info.movespeed, bIsPercent: false})
        attributes_array_crit.push({attribute_name: "physical_crit_chance", attribute_number: hero_attributes_info.physical_crit_chance, bIsPercent: true})
        attributes_array_crit.push({attribute_name: "magical_crit_chance", attribute_number: hero_attributes_info.magical_crit_chance, bIsPercent: true})
        attributes_array_crit.push({attribute_name: "physical_crit_damage", attribute_number: hero_attributes_info.physical_crit_damage, bIsPercent: true})
        attributes_array_crit.push({attribute_name: "magical_crit_damage", attribute_number: hero_attributes_info.magical_crit_damage, bIsPercent: true})

        if(Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer()) != -1){
            hero_index = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer())
        }
    }
    

    return <Panel id="Character">
            <Panel className="Character_part">
                <Label className="Character_attributes_title" text={$.Localize("#Character_attributes_stat")}/>
                {
                    attributes_array_stat.map((value)=>{
                        return <Panel key={"stat"+value.attribute_name} className="Character_attributes_panel" 
                        onmouseover={p=>{
                            $.DispatchEvent("DOTAShowTextTooltip", p, $.Localize("#hud_text_tooltip_Character_"+value.attribute_name))
                        }
                        }
                        onmouseout={
                            ()=>{
                                $.DispatchEvent("DOTAHideTextTooltip")
                            }
                        }>
                            <Label className="Character_attributes_name" text={$.Localize("#Character_attribute_" + value.attribute_name)}/>
                            <Label className="Character_attributes_number" text={value.attribute_number + `${value.bIsPercent ? "%": ""}`}/>
                        </Panel>
                    })
                }
            </Panel>
            <Panel className="Character_part">
                <Label className="Character_attributes_title" text={$.Localize("#Character_attributes_attack")}/>
                {
                    attributes_array_attack.map((value)=>{
                        return <Panel key={"attack"+value.attribute_name} className="Character_attributes_panel">
                            <Label className="Character_attributes_name" text={$.Localize("#Character_attribute_" + value.attribute_name)}/>
                            <Label className="Character_attributes_number" text={value.attribute_number + `${value.bIsPercent ? "%": ""}`}/>
                        </Panel>
                    })
                }
            </Panel>
            <Panel className="Character_part">
                <Label className="Character_attributes_title" text={$.Localize("#Character_attributes_defense")}/>
                {
                    attributes_array_defense.map((value)=>{
                        return <Panel key={"defense"+value.attribute_name} className="Character_attributes_panel">
                            <Label className="Character_attributes_name" text={$.Localize("#Character_attribute_" + value.attribute_name)}/>
                            <Label className="Character_attributes_number" text={value.attribute_number + `${value.bIsPercent ? "%": ""}`}/>
                        </Panel>
                    })
                }
            </Panel>
            <Panel className="Character_part">
                <Label className="Character_attributes_title" text={$.Localize("#Character_attributes_crit")}/>
                {
                    attributes_array_crit.map((value)=>{
                        return <Panel key={"crit"+value.attribute_name} className="Character_attributes_panel">
                            <Label className="Character_attributes_name" text={$.Localize("#Character_attribute_" + value.attribute_name)}/>
                            <Label className="Character_attributes_number" text={value.attribute_number + `${value.bIsPercent ? "%": ""}`}/>
                        </Panel>
                    })
                }
            </Panel>
    </Panel>
}

