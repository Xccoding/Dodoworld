import React, { useEffect, useRef, useState } from 'react';
import { render, useGameEvent } from '@demon673/react-panorama';
import ReactUtils from "./React_utils";

const MIN_ABILITY_SLOT = 0
const MAX_ABILITY_SLOT = 18
const MIN_SCHOOLS_INDEX = 0
const MAX_SCHOOLS_INDEX = 2

function ChangeSchools(){
    const [schools_array, setschools_array] = useState(GetSchools)
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
            if((GameUI.CustomUIConfig() as any).role_abilities?.role_abilities_pool[`${hero_label}_${index}`] != undefined)
            {
                schools.push(`${hero_label}_${index}`)
            }
        }
        return schools
    }


    return <Panel id='ChangeSchools'>
        {
            schools_array.map((schools_name, schools_index)=>{
                return <Schools key={schools_name} schools_name={schools_name} schools_index={schools_index}/>
            })
        }
    </Panel>
}

function Schools({schools_name, schools_index}: {schools_name: string, schools_index: number}){
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
        <Label id='schools_name'/>
        <Label id='schools_desc'/>
        <Panel id='schools_abilities'>
        {
            abilities.map((ability_name)=>{
                // $.Msg(ability_name)
                return <DOTAAbilityImage key={ability_name} abilityname={ability_name}
                onmouseover={p=>{
                    $.DispatchEvent("DOTAShowAbilityTooltipForEntityIndex", p, ability_name, Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer()))
                }}
                onmouseout={p=>{
                    $.DispatchEvent("DOTAHideAbilityTooltip", p)
                }}
                ></DOTAAbilityImage>
            })
        }
        </Panel>
        <TextButton id='choose_school'></TextButton>
    </Panel>
}

render(<ChangeSchools />, $.GetContextPanel());