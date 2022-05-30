import React, { useEffect, useRef, useState } from 'react';
import { render, useGameEvent, useNetTableKey, useNetTableValues } from '@demon673/react-panorama';
import ReactUtils from "../../utils/React_utils";
import { InCombat, print } from '../Utils';

const MIN_ABILITY_SLOT = 0
const MAX_ABILITY_SLOT = 18
const MIN_SCHOOLS_INDEX = 0
const MAX_SCHOOLS_INDEX = 2
const SCHOOLS_DUTY_DPS = 1
const SCHOOLS_DUTY_HEALER = 2
const SCHOOLS_DUTY_TANK = 4

export function ChangeSchools(){
    const [schools_array, setschools_array] = useState(GetSchools)
    const Schools_selected = useNetTableValues("hero_schools")[Players.GetLocalPlayer()].schools_index | 0
    
    // useGameEvent("dota_on_hero_finish_spawn", (event)=>{        
    //     let hero_index = Players.GetPlayerHeroEntityIndex(player)
    //     if(hero_index == event.heroindex){
    //         sethero(hero_index)
    //         setschools_array(GetSchools)
    //     }
    // }, [Players.GetPlayerHeroEntityIndex(player)])
    ReactUtils.useSchedule(() => {
        let player = Players.GetLocalPlayer()
		let hero_index = Players.GetPlayerHeroEntityIndex(player)
        
        if(hero_index != -1){
            setschools_array(GetSchools)
        }
		return Math.max(1 / 30, Game.GetGameFrameTime());
	}, []);

    function GetSchools(){
        let schools: string[] = []
        let hero_label = Entities.GetUnitLabel(Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer()))
        for (let index = MIN_SCHOOLS_INDEX; index < MAX_SCHOOLS_INDEX; index++) {
            if((GameUI.CustomUIConfig() as any).role_abilities?.role_abilities_pool[`${hero_label}_schools_${index}`] != undefined)
            {
                schools.push(`${hero_label}_schools_${index}`)
            }
        }
        return schools
    }


    return <Panel id='ChangeSchools'>
        <Label id='ChangeSchools_title' text={$.Localize("#Hud_ChangeSchools_title")}/>
        <Label id='ChangeSchools_desc' text={$.Localize("#Hud_ChangeSchools_desc")}/>
        <Panel id='SchoolsList'>
        {
            schools_array.map((schools_name, schools_index)=>{
                return <Schools key={schools_name} schools_name={schools_name} schools_index={schools_index} Schools_selected={Schools_selected}/>
            })
        }
        </Panel>
    </Panel>
}

function Schools({schools_name, schools_index, Schools_selected}: {schools_name: string, schools_index: number, Schools_selected:number}){
    const SchoolsDutyConfig = (GameUI.CustomUIConfig().schools_duty.schools_duty as any)
    let duty = SchoolsDutyConfig[schools_name]
    let duty_class = "schools_duty_dps"// 默认是DPS
    if(duty == SCHOOLS_DUTY_DPS){
        duty_class = "schools_duty_dps"
    }
    else if(duty == SCHOOLS_DUTY_HEALER){
        duty_class = "schools_duty_healer"
    }else if(duty == SCHOOLS_DUTY_TANK){
        duty_class = "schools_duty_tank"
    }
    let hero_index = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer())
    let abilities: string[] = []
    const schools = (GameUI.CustomUIConfig() as any).role_abilities?.role_abilities_pool[schools_name]
    for (let index = MIN_ABILITY_SLOT + 1; index < MAX_ABILITY_SLOT; index++) {
        if(schools[`Ability${index}`] == undefined){
            break
        }
        else{
            abilities.push(schools[`Ability${index}`])
        }
    }

    return <Panel id='schools'>
        <Panel id='schools_title'>
            <Image id='schools_position_icon' className={duty_class}/>
            <Label id='schools_name' text={$.Localize("#"+schools_name)+$.Localize("#"+duty_class)}/>
        </Panel>
        <Label id='schools_desc' text={$.Localize("#"+schools_name+"_desc")}/>
        <Panel id='schools_abilities'>
        {
            abilities.map((ability_name)=>{
                // $.Msg(ability_name)
                return <DOTAAbilityImage key={ability_name} className="schools_abilities_panel" abilityname={ability_name}
                onmouseover={p=>{
                    $.DispatchEvent("DOTAShowAbilityTooltipForEntityIndex", p, ability_name, hero_index)
                }}
                onmouseout={p=>{
                    $.DispatchEvent("DOTAHideAbilityTooltip", p)
                }}
                ></DOTAAbilityImage>
            })
        }
        </Panel>
        <TextButton id='choose_school' text={$.Localize(schools_index == Schools_selected?"#current_school":"#choose_school")} className={schools_index == Schools_selected ? "disable": ""} enabled={schools_index != Schools_selected} onactivate={()=>{
            if(InCombat(hero_index)){
                GameUI.SendCustomHUDError($.Localize("#dota_hud_error_change_schools_in_combat"), "General.CastFail_Custom")
            }
            else
            {
                Game.EmitSound("underdraft_drafted")
                GameEvents.SendCustomGameEventToServer("ChangeRoleMastery", {entindex: hero_index, new_schools: schools_index})
            }
            
        }}></TextButton>
    </Panel>
}

// {render(<ChangeSchools />, $.GetContextPanel());}