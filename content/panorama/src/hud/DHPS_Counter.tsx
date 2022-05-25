import React, { useEffect, useRef, useState } from 'react';
import { render } from '@demon673/react-panorama';
import ReactUtils from "../utils/React_utils";

function DHPS_Counter(){
    const [DPSdata, SetDPSdata] = useState<{player_index: PlayerID, DPS_number: number}[]>(UpdateDPS)
    const [HPSdata, SetHPSdata] = useState<{player_index: PlayerID, HPS_number: number}[]>(UpdateHPS)

    ReactUtils.useSchedule(() => {
		SetDPSdata(UpdateDPS)
        SetHPSdata(UpdateHPS)
		return Math.max(1 / 30, Game.GetGameFrameTime());
	}, []);

    function UpdateDPS()
    {
        let PlayerDPS: {player_index: PlayerID, DPS_number: number}[] = []
        const All_DHPS = CustomNetTables.GetAllTableValues("DHPS")
        for (let index = 0; index < All_DHPS.length; index++) {
            const DHPS_info = All_DHPS[index]
            const unit_index = Number(DHPS_info.key) as EntityIndex
            const DPS_playerid = Entities.GetPlayerOwnerID(unit_index)
            
            const DPS_number = DHPS_info.value.DPS
            if(DPS_number > 0){
                let pos = PlayerDPS.findIndex((value)=>{
                    return value.player_index == DPS_playerid
                })
                if(pos == -1){
                    PlayerDPS.push({player_index: DPS_playerid, DPS_number: DPS_number})
                }
                else{
                    PlayerDPS[pos].DPS_number = PlayerDPS[DPS_playerid].DPS_number + DPS_number
                }
            }
        }
        return PlayerDPS
    }
    function UpdateHPS()
    {

        let PlayerHPS: {player_index: PlayerID, HPS_number: number}[] = []
        const All_DHPS = CustomNetTables.GetAllTableValues("DHPS")
        for (let index = 0; index < All_DHPS.length; index++) {
            const DHPS_info = All_DHPS[index]
            const unit_index = Number(DHPS_info.key) as EntityIndex
            const HPS_playerid = Entities.GetPlayerOwnerID(unit_index)
            const HPS_number = DHPS_info.value.HPS

            if(HPS_number > 0){
                let pos = PlayerHPS.findIndex((value)=>{
                    return value.player_index == HPS_playerid
                })
                if(pos == -1){
                    PlayerHPS.push({player_index: HPS_playerid, HPS_number: HPS_number})
                }
                else{
                    PlayerHPS[pos].HPS_number = PlayerHPS[HPS_playerid].HPS_number + HPS_number
                }
            }
        }

        return PlayerHPS
    }

    // $.Msg(HPSdata)
    return <Panel id="DHPS_Counter">
        <DPS_Counter DPSdata={DPSdata}/>
        <HPS_Counter HPSdata={HPSdata}/>
    </Panel>
}

function DPS_Counter({DPSdata}: {DPSdata: {player_index: PlayerID, DPS_number: number}[]}){
    DPSdata.sort((a, b)=>b.DPS_number - a.DPS_number)
    return <Panel id='DPS_Counter'>
        <Panel id='DPS_Counter_title'>
            <Label id='DPS_Counter_title_text' text={"每秒伤害"}/>
        </Panel>
        {
            DPSdata.map((info)=>{
                const sPlayername = Players.GetPlayerName(info.player_index)
                const sHeroname = Players.GetPlayerSelectedHero(info.player_index)
                const playercolor = Players.GetPlayerColor(info.player_index).toString(16)
                return <DHPSMeteringBar key={String(info.player_index)} 
                player_name={sPlayername} 
                player_dps={info.DPS_number} 
                player_dps_pct={info.DPS_number / DPSdata[0].DPS_number}
                hero_name={sHeroname}
                player_color={playercolor}
                />
            })
        }
    </Panel>
}

function HPS_Counter({HPSdata}: {HPSdata: {player_index: PlayerID, HPS_number: number}[]}){
    HPSdata.sort((a, b)=>b.HPS_number - a.HPS_number)
    return <Panel id='HPS_Counter'>
        <Panel id='HPS_Counter_title'>
            <Label id='HPS_Counter_title_text' text={"每秒治疗"}/>
        </Panel>
        {
        HPSdata.map((info)=>{
            const sPlayername = Players.GetPlayerName(info.player_index)
            const sHeroname = Players.GetPlayerSelectedHero(info.player_index)
            const playercolor = Players.GetPlayerColor(info.player_index).toString(16)
            return <DHPSMeteringBar key={String(info.player_index)} 
            player_name={sPlayername} 
            player_dps={info.HPS_number} 
            player_dps_pct={info.HPS_number / HPSdata[0].HPS_number}
            hero_name={sHeroname}
            player_color={playercolor}
            />
        })
        }
    </Panel>
}

function DHPSMeteringBar({player_name, player_dps, player_dps_pct, hero_name, player_color}:{player_name: string, player_dps: number, player_dps_pct: number, hero_name: string, player_color: string}){
    let width = `${player_dps_pct * 100}%`
    let backgroundColor = `#${player_color.substring(6,8) + player_color.substring(4,6) + player_color.substring(2,4) + player_color.substring(0,2)}`
    // 处理过低伤害
    player_dps = (player_dps > 0 && player_dps < 1) ? 1 : Number(player_dps.toFixed(0))
    return <ProgressBar value={player_dps_pct} className={"DHPSMeteringBar"}>
        <DOTAHeroImage id="DHPSMeteringBar_icon" heroname={hero_name} heroimagestyle="icon"/>
        <Panel id="DHPSMeteringBarBG" style={{width, backgroundColor}}></Panel>
        <Label id="DHPSMeteringBar_name" text={player_name}/>
        <Label id="DHPSMeteringBar_number" text={player_dps}/>
    </ProgressBar>
}

render(<DHPS_Counter />, $("#DHPS_CounterRoot")); 