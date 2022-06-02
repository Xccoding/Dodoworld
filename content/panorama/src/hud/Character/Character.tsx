import React, { useEffect, useRef, useState } from "react";
import { render, useNetTableValues } from '@demon673/react-panorama';
import ReactUtils from "../../utils/React_utils";
import { print}  from '../Utils'

export function Character(){
    const Character_info = useNetTableValues("hero_attributes")
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
                        return <Panel key={"defense"+value.attribute_name} className="Character_attributes_panel"
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

