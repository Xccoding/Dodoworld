import React, { useEffect, useRef, useState } from 'react';
import { createPortal, render, useNetTableValues } from '@demon673/react-panorama';
import ReactUtils from "../../utils/React_utils";
import { print, RGBToHex}  from '../Utils'

const OVERHEAD_BUFF_COUNT_LIMIT = 5
const OVERHEAD_BUFF_TIME_LIMIT = 60

function HasOverheadBar(unit_index: EntityIndex){
    let vOrigin = Entities.GetAbsOrigin(unit_index);
    let fScreenX = Game.WorldToScreenX(vOrigin[0], vOrigin[1], vOrigin[2]);
	let fScreenY = Game.WorldToScreenY(vOrigin[0], vOrigin[1], vOrigin[2]);

    return Entities.IsValidEntity(unit_index) && Entities.IsAlive(unit_index) && !Entities.NoHealthBar(unit_index) && (fScreenX > 100 && fScreenX < Game.GetScreenWidth() - 100) && (fScreenY > 100 && fScreenY < Game.GetScreenHeight() - 100)
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
                        let offset = Entities.GetHealthBarOffset(unit_index) + 20
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

            for (let index = 0; index < OverheadBar_Garbage.GetChildCount(); index++) {
                let pPanel = OverheadBar_Garbage.GetChild(index)
                if(pPanel != null){
                    pPanel.RemoveAndDeleteChildren()
                }
                
            }
            OverheadBar_Garbage.RemoveAndDeleteChildren()

        }
        update()
    })()
}

function OverheadBar({unit_index}: {unit_index: EntityIndex}){
    let full_name = ""
    let lv_string = `(Lv${Entities.GetLevel(unit_index)})`
    let label_string = ""
    if(Entities.GetUnitLabel(unit_index) != ""){
        label_string = $.Localize(`#${Entities.GetUnitLabel(unit_index)}`) + "·"
    }
    let unit_name = $.Localize(`#${Entities.GetUnitName(unit_index)}`)
    full_name = lv_string + label_string + unit_name

    return <Panel className="OverheadBar">
        <OverheadBuffBar unit_index={unit_index}/>
        <Label id='OverheadBar_name' className={Entities.GetUnitLabel(unit_index)} text={full_name}/>
        <OverheadhpBar unit_index={unit_index}/>
        <OverheadChannelBar unit_index={unit_index}/>
    </Panel>
}

function OverheadhpBar({unit_index}:{unit_index: EntityIndex}){
    let health = Entities.GetHealth(unit_index)
    let max_health = Entities.GetMaxHealth(unit_index)
    let percent = health / max_health
    let width = `${percent * 100}% + 1px`
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
    let channel_info = CustomNetTables.GetTableValue("channel_list", unit_index)
    let bShowBar = false
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

    let width = `${channel_percent}% + 1px`
    if(channel_percent * 100 >= 100){
        width = "100px"
    }
    else if(channel_percent * 100 == 0){
        width = "0px"
    }

    return <Panel id='ChannelBarContainer'>
        {
            <ProgressBar id ="OverheadChannelBar" value={channel_percent} className={bShowBar ? "bShowBar" : ""}>
            <Label id="channel_ability_name" text={$.Localize("#DOTA_Tooltip_ability_" + Abilities.GetAbilityName(ability_index))}></Label>
            <Panel id="OverheadChannelBar_BG" style={{width}} ></Panel>
        </ProgressBar>
        }
    </Panel>

}

function OverheadBuffBar({unit_index}:{unit_index: EntityIndex}){
    let player = Players.GetLocalPlayer()
    let hero = Players.GetPlayerHeroEntityIndex(player)
    const iBuffCount = Entities.GetNumBuffs(unit_index);
    const buff_array:number[]=[];
    let count = 0

    for (let index = 0; index < iBuffCount; index++) {
		let iBuff = Entities.GetBuff(unit_index, index);
		if (Buffs.IsHidden(unit_index, iBuff)) continue;
		if (false == Buffs.IsDebuff(unit_index, iBuff)) continue;
        if (Buffs.GetCaster(unit_index, iBuff) != hero) continue;
        if (Buffs.GetRemainingTime(unit_index, iBuff) > OVERHEAD_BUFF_TIME_LIMIT) continue;
        buff_array.push(index)
        count++;
        if(count >= OVERHEAD_BUFF_COUNT_LIMIT){
            break
        }
	}

    return <Panel id="OverheadBuffBar">
        {
            buff_array.map((buff_index)=>
            {
                return <OverheadBuff key={buff_index} buff_index={buff_index} unit_index={unit_index}/>
            })
        }
    </Panel>
}

function OverheadBuff({buff_index, unit_index}: {buff_index: number, unit_index: EntityIndex}){
    const thisBuff = Entities.GetBuff(unit_index, buff_index)

    let sTexture = Buffs.GetTexture(unit_index, thisBuff);
    if(sTexture == ""){
        sTexture = `file://{images}/spellicons/goose.png`;
    }
    else{
        if(sTexture.indexOf("item_") != -1){
            sTexture = `file://{images}/items/${sTexture.replace("item_", "")}.png`;
        }
        else{
            sTexture = `file://{images}/spellicons/${sTexture}.png`;
        }
    }
    
    

    let fDuration = Buffs.GetDuration(unit_index, thisBuff);
    // 计算时间格式
	let fTimeRemain = Buffs.GetRemainingTime(unit_index, thisBuff);
    let dTimeRemain = Math.floor(fTimeRemain)
    let sTimeRemain = ""
    if(dTimeRemain >= 1){
        sTimeRemain = String(dTimeRemain)
    }

	let clip = "radial(50% 50%, 0deg, -360deg);";
	if (fDuration > 0 && fTimeRemain > 0) {
		clip = `radial(50% 50%, 0deg, ${360 * (fDuration - fTimeRemain) / fDuration}deg)`;
	}

    let backgroundColor = `none`
    if(fDuration > 0){
        backgroundColor = `rgba(0,0,0,${((fDuration - fTimeRemain)/ fDuration).toFixed(2)})`
        backgroundColor = RGBToHex(backgroundColor)
    }
    
    let iStackCount = Buffs.GetStackCount(unit_index, thisBuff);
	let bIsDebuff = Buffs.IsDebuff(unit_index, thisBuff);
    let classNames: string[] = ["CustomBuff",]
    
    if(bIsDebuff){
        classNames.push(`is_debuff`)
    }
    if(iStackCount != 0){
        classNames.push(`has_stacks`)
    }

    return <Panel className={classNames.join(" ")}
    onactivate={p => Players.BuffClicked(unit_index, thisBuff, GameUI.IsAltDown())}
    onmouseover={p => $.DispatchEvent("DOTAShowBuffTooltip", p, unit_index, thisBuff, Entities.IsEnemy(unit_index))}
    onmouseout={p => $.DispatchEvent("DOTAHideBuffTooltip", p)} >
    <Button className="BuffBorder">
        <Image id="BuffImage" src={sTexture} scaling="stretch-to-fit-y-preserve-aspect" />
        <Panel id="CircularDuration" style={{ clip, backgroundColor }} />
    </Button>
    <Label id="BuffTime" text={fTimeRemain > 0 ? sTimeRemain : ""} />
</Panel >
}

