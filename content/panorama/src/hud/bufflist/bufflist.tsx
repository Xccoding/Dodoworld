import React, { useEffect, useRef, useState } from "react";
import { render } from '@demon673/react-panorama';
import ReactUtils from "../../utils/React_utils";
import { print, RGBToHex}  from '../Utils'

export function Buffpanel(){
    const player = Players.GetLocalPlayer()
    const [iTime, SetTime] = useState(() => Game.Time());
    const [hero, Sethero] = useState(Players.GetPlayerHeroEntityIndex(player))
    ReactUtils.useSchedule(
        ()=>{
            SetTime(Game.Time());
            Sethero(Players.GetPlayerHeroEntityIndex(player))
		    return Math.max(1 / 30, Game.GetGameFrameTime());
        }, [])

    return (<Panel id="Buffpanel">
        <BuffList bShowBuff={true}></BuffList>
        <BuffList bShowBuff={false}></BuffList>
    </Panel>);
}

function BuffList({bShowBuff}: {bShowBuff: boolean}){
    let player = Players.GetLocalPlayer()
    let hero = Players.GetPlayerHeroEntityIndex(player)
    const iBuffCount = Entities.GetNumBuffs(hero);
    const buff_array:number[]=[];

    for (let index = 0; index < iBuffCount; index++) {
		let iBuff = Entities.GetBuff(hero, index);
		if (Buffs.IsHidden(hero, iBuff)) continue;
		if (bShowBuff == Buffs.IsDebuff(hero, iBuff)) continue;
        buff_array.push(index)
	}

    let sListid = "BuffList"
    if(!bShowBuff){
        sListid = "DebuffList"
    }

    return <Panel id={sListid}>
        {
            buff_array.map((buff_index)=>
            {
                return <Buff key={buff_index} buff_index={buff_index}></Buff>
            })
        }
    </Panel>
}

function Buff({buff_index}: {buff_index:number}){
    const player = Players.GetLocalPlayer()
    const hero = Players.GetPlayerHeroEntityIndex(player)
    const thisBuff = Entities.GetBuff(hero, buff_index)

    let sTexture = Buffs.GetTexture(hero, thisBuff);
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
    
    

    let fDuration = Buffs.GetDuration(hero, thisBuff);
    // 计算时间格式
	let fTimeRemain = Buffs.GetRemainingTime(hero, thisBuff);
    let dTimeRemain = Math.floor(fTimeRemain)
    let sTimeRemain = "0s"
    if(dTimeRemain / 3600 >= 1){
        dTimeRemain = dTimeRemain / 3600
        sTimeRemain = Math.floor(dTimeRemain) + "h"
    }
    else if(dTimeRemain / 60 >= 1){
        dTimeRemain = dTimeRemain / 60
        sTimeRemain = Math.floor(dTimeRemain) + "m"
    }
    else if(dTimeRemain < 1 && dTimeRemain >= 0)
    {
        sTimeRemain = fTimeRemain.toFixed(1) + "s"
    }
    else if(dTimeRemain >= 1){
        sTimeRemain = dTimeRemain + "s"
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
    
    let iStackCount = Buffs.GetStackCount(hero, thisBuff);
	let bIsDebuff = Buffs.IsDebuff(hero, thisBuff);
    let classNames: string[] = ["CustomBuff",]
    
    if(bIsDebuff){
        classNames.push(`is_debuff`)
    }
    if(iStackCount != 0){
        classNames.push(`has_stacks`)
    }

    return <Panel className={classNames.join(" ")}
    onactivate={p => Players.BuffClicked(hero, thisBuff, GameUI.IsAltDown())}
    onmouseover={p => $.DispatchEvent("DOTAShowBuffTooltip", p, hero, thisBuff, Entities.IsEnemy(hero))}
    onmouseout={p => $.DispatchEvent("DOTAHideBuffTooltip", p)} >
    <Button className="BuffBorder">
        <Image id="BuffImage" src={sTexture} scaling="stretch-to-fit-y-preserve-aspect" />
        <Panel id="CircularDuration" style={{ clip, backgroundColor }} />
    </Button>
    <Label id="StackCount" text={iStackCount} />
    <Label id="BuffTime" text={fTimeRemain > 0 ? sTimeRemain : "永久"} />
</Panel >
}



