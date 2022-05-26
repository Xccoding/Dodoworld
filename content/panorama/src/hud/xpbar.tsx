import React, { useEffect, useRef, useState } from 'react';
import { render } from '@demon673/react-panorama';
import ReactUtils from "./React_utils";

function Xpbar(){
    const [xpbar, setxp] = useState(updatexp)

    function updatexp(){
        let hero = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer())
        let LevelConfig = GameUI.CustomUIConfig().levels?.levels_formula

        if(hero == -1){
            return [0, 1, 1]
        }
        
        let total_xp = Entities.GetNeededXPToLevel(hero)
        let current_xp = Entities.GetCurrentXP(hero)
        let level = Entities.GetLevel(hero)
        let past_xp = 0

        if(level > 1){
            past_xp += (level - 1) * Number(LevelConfig.level_factor) + Number(LevelConfig.other_param)
            current_xp -= past_xp
            total_xp -= past_xp
        }

        return [current_xp, total_xp, level]
    }

    ReactUtils.useSchedule(() => {
		setxp(updatexp)
		return Math.max(1 / 30, Game.GetGameFrameTime());
	}, []);

    let width = `${xpbar[0] / xpbar[1] * 100}%`
    let hero_name = ""
    let hero = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer())
    if(hero != -1){
        hero_name = Entities.GetUnitName(hero)
    }

    return <ProgressBar id='xpbar' value={xpbar[0] / xpbar[1]}>
        <Label id='xpbar_level' text={`${$.Localize("#"+hero_name)} ${xpbar[2]}级`}/>
        <Label id='xpbar_number' text={`${xpbar[0]} / ${xpbar[1]}`}/>
        <Panel id='xpbar_BG' style={{width}}/>
    </ProgressBar>
}

render(<Xpbar />, $("#XpbarRoot")); 