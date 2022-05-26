import React, { useEffect, useRef, useState } from 'react';
import { render } from '@demon673/react-panorama';
import ReactUtils from "../utils/React_utils";

function HealthMana(){
    const [thealth_info, setHealth] = useState(refresHealth)
    const [tmana_info, setMana] = useState(refreshMana)

    function refresHealth(){
        let unit = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer())
        let max_health = Entities.GetMaxHealth(unit)
        let health: number = 0, health_regen: number = 0, percent: number = 0
        if(max_health > 0){
            health = Entities.GetHealth(unit)
            health_regen = Entities.GetHealthThinkRegen(unit)
            percent = health / max_health
        }
        return {max_health: max_health, health: health, health_regen: health_regen, percent: percent}
    }

    function refreshMana(){
        let unit = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer())
        let max_mana = Entities.GetMaxMana(unit)
        let mana: number = 0, mana_regen: number = 0, percent: number = 0
        if(max_mana > 0){
            mana = Entities.GetMana(unit)
            mana_regen = Entities.GetManaThinkRegen(unit)
            percent = mana / max_mana
        }
        return {max_mana: max_mana, mana: mana, mana_regen: mana_regen, percent: percent}
    }

    ReactUtils.useSchedule(
        ()=>{
            setHealth(refresHealth)
            setMana(refreshMana)
		    return Math.max(1 / 30, Game.GetGameFrameTime());
        }, [])

    return (
        <Panel id="HealthAndManaContainer" >
            <HealthBar max_health={thealth_info.max_health} health={thealth_info.health} health_regen={thealth_info.health_regen} percent={thealth_info.percent}/>
            <ManaBar max_mana={tmana_info.max_mana} mana={tmana_info.mana} mana_regen={tmana_info.mana_regen} percent={tmana_info.percent}/>
        </Panel>
    );
}

function HealthBar({max_health, health, health_regen, percent}:{max_health: number, health: number, health_regen: number, percent: number}){
    let width = `${percent * 100}%`
    return <ProgressBar id ="HealthProgressBar" value={percent}>
        <Label id="hp_maxhp" text={`${health} /  ${max_health}`}></Label>
        <Label id="hp_regen" text={`+ ${health_regen.toFixed(1)}`}></Label>
        <Panel id="HealthBarBG" style={{width}}></Panel>
    </ProgressBar>
}

function ManaBar({max_mana, mana, mana_regen, percent}:{max_mana: number, mana: number, mana_regen: number, percent: number}){
    let width = `${percent * 100}%`
    return <ProgressBar id ="ManaProgressBar" value={percent}>
        <Label id="mp_maxmp" text={`${mana} /  ${max_mana}`}></Label>
        <Label id="mp_regen" text={`+ ${mana_regen.toFixed(1)}`}></Label>
        <Panel id="ManaBarBG" style={{width}}></Panel>
    </ProgressBar>
}

render(<HealthMana />, $("#HealthManaRoot")); 
