import React, { useEffect, useRef, useState } from 'react';
import { createPortal, render, useNetTableValues } from '@demon673/react-panorama';
import ReactUtils from "../../utils/React_utils";
import { print } from '../Utils';

function HasOverheadBar(unit_index: EntityIndex){
    return Entities.IsValidEntity(unit_index) && Entities.IsAlive(unit_index) && !Entities.NoHealthBar(unit_index)
}

interface OverheadBarContainer extends Panel
{
    deletetime?: number
    unit_index?: EntityIndex
}

export function OverheadBar_Init(){
    (()=>{
        const OverheadBar_Root: Panel = $("#OverheadBar_Root")
        const OverheadBar_Garbage: Panel = $("#OverheadBar_Garbage")
        OverheadBar_Root.RemoveAndDeleteChildren()
        function update(){
            // OverheadBar_Root.RemoveAndDeleteChildren()
            $.Schedule(Game.GetGameFrameTime(), update)
            const unit_in_vision = Entities.GetAllEntitiesByClassname("npc_dota_creature")
            unit_in_vision.map((unit_index, index)=>{
                if(!HasOverheadBar(unit_index)){
                    if(!Entities.IsAlive(unit_index)){
                        // 尝试找血条
                        let pOverheadBar = OverheadBar_Root.FindChildTraverse(String(unit_index)) as OverheadBarContainer
                        if(pOverheadBar != undefined && pOverheadBar != null){
                            //血条存在
                            if(pOverheadBar.deletetime != undefined){
                                if(Game.GetGameTime() > pOverheadBar.deletetime){
                                    pOverheadBar.SetParent(OverheadBar_Garbage)
                                    return
                                }
                            }
                            else{
                                pOverheadBar.deletetime = Game.GetGameTime() + 0.3
                            }
                        }
                        }
                    
                }
                
                if(Entities.IsEnemy(unit_index)){
                    // 尝试找血条
                    let pOverheadBar = OverheadBar_Root.FindChildTraverse(String(unit_index)) as OverheadBarContainer
                    if((pOverheadBar == undefined || pOverheadBar == null) && HasOverheadBar(unit_index)){
                        pOverheadBar = $.CreatePanel("Panel", OverheadBar_Root, String(unit_index)) as OverheadBarContainer
                        pOverheadBar.AddClass("OverheadBarContainer")
                    }
                    if(HasOverheadBar(unit_index) || (pOverheadBar != undefined)){
                        render(<OverheadBar unit_index={unit_index}/>, pOverheadBar)
                        let offset = Entities.GetHealthBarOffset(unit_index)
                        let position = Entities.GetAbsOrigin(unit_index)
                        let ScreenX = Game.WorldToScreenX(position[0], position[1], position[2] + offset)
                        let ScreenY = Game.WorldToScreenY(position[0], position[1], position[2] + offset)

                        pOverheadBar.unit_index = unit_index
                        pOverheadBar.SetPositionInPixels((ScreenX - pOverheadBar.actuallayoutwidth / 2) / pOverheadBar.actualuiscale_x, (ScreenY - pOverheadBar.actuallayoutheight / 2) / pOverheadBar.actualuiscale_y, 0)
                    }
                    
                }
            })

            for (let index = 0; index < OverheadBar_Root.GetChildCount(); index++) {
                let pPanel = OverheadBar_Root.GetChild(index) as OverheadBarContainer
                if(unit_in_vision.find((index)=>{return index == pPanel.unit_index}) == undefined){
                    pPanel.SetParent(OverheadBar_Garbage)
                }
            }

            OverheadBar_Garbage.RemoveAndDeleteChildren()

        }
        update()
    })()
}

function OverheadBar({unit_index}: {unit_index: EntityIndex}){
    return <Panel className="OverheadBar">
        <Label className='OverheadBar_name' text={$.Localize(`#${Entities.GetUnitName(unit_index)}`)}/>
        <OverheadhpBar unit_index={unit_index}/>
        <OverheadChannelBar unit_index={unit_index}/>
    </Panel>
}

function OverheadhpBar({unit_index}:{unit_index: EntityIndex}){
    let health = Entities.GetHealth(unit_index)
    let max_health = Entities.GetMaxHealth(unit_index)
    let percent = health / max_health

    let width = `${percent * 100 > 100 ? 100: percent * 100 + 1}%`
    let health_unit = ""
    let max_health_unit = ""
    if(max_health >= 10000){
        max_health = Number((max_health * 0.0001).toFixed(1))
        max_health_unit = "万"
    }
    if(health >= 10000){
        health = Number((health * 0.0001).toFixed(1))
        health_unit = "万"
    }
    
    return <ProgressBar id ="OverheadhpBar" value={percent}>
        <Label id="hp_maxhp" text={`${health + health_unit}/ ${max_health + max_health_unit}(${(percent * 100).toFixed(0)}%)`}></Label>
        <Panel id="OverheadhpBar_BG" style={{width}} ></Panel>
    </ProgressBar>
}

function OverheadChannelBar({unit_index}:{unit_index: EntityIndex}){
    const channel_table = useNetTableValues("channel_list")
    let bShowBar = false
    let channel_info = channel_table[unit_index]
    let ability_index = -1 as AbilityEntityIndex
    let channel_percent = 0
    
    if(channel_info != undefined){
        if(channel_info.channel_ability != -1){
            bShowBar = true
            ability_index = channel_info.channel_ability
            channel_percent = channel_info.channel_percent
        }
        else{
            bShowBar = false
        }
    }
    else{
        bShowBar = false
    }

    let width = `${channel_percent * 100 > 100 ? 100: channel_percent * 100 + 1}%`

    return <Panel id='ChannelBarContainer'>
        {
            bShowBar ? <ProgressBar id ="OverheadChannelBar" value={channel_percent}>
            <Label id="channel_ability_name" text={$.Localize("#DOTA_Tooltip_ability_" + Abilities.GetAbilityName(ability_index))}></Label>
            <Panel id="OverheadChannelBar_BG" style={{width}} ></Panel>
        </ProgressBar> : <Panel/>
        }
    </Panel>

}


