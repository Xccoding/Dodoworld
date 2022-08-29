import React, { useEffect, useRef, useState } from 'react';
import { render, useGameEvent, useNetTableKey, useNetTableValues } from '@demon673/react-panorama';
import ReactUtils from "../../utils/React_utils";
import { InCombat, print, useToggleHud } from '../Utils';

const MIN_ABILITY_SLOT = 0;
const MAX_ABILITY_SLOT = 18;
const MIN_SCHOOLS_INDEX = 0;
const MAX_SCHOOLS_INDEX = 2;
const SCHOOLS_DUTY_DPS = 1;
const SCHOOLS_DUTY_HEALER = 2;
const SCHOOLS_DUTY_TANK = 4;


function ChangeSchools() {

    const [ShowState, SetShowState] = useToggleHud("ChangeSchools");
    const [schools_array, setschools_array] = useState(GetSchools);
    const Schools_selected = useNetTableValues("hero_schools")[Players.GetLocalPlayer()].schools_index || 0;

    ReactUtils.useSchedule(() => {
        let player = Players.GetLocalPlayer();
        let hero_index = Players.GetPlayerHeroEntityIndex(player);

        if (hero_index != -1) {
            setschools_array(GetSchools);
        }
        return Math.max(1 / 30, Game.GetGameFrameTime());
    }, []);

    function GetSchools() {
        let schools: number[] = [];
        let hero = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer());
        let hero_label = Entities.GetUnitLabel(hero);
        if (hero != -1) {
            for (let index = MIN_SCHOOLS_INDEX; index < MAX_SCHOOLS_INDEX; index++) {

                if (GameUI.CustomUIConfig().SchoolsKv[hero_label]?.[index] != undefined) {

                    schools.push(index);
                }
            }
        }

        return schools;
    }


    return <Panel id="ChangeSchools" className={ShowState ? "Show" : ""}>
        <Button className="Close_button" onactivate={() => {
            SetShowState(false);
        }} />
        <Label id='ChangeSchools_title' text={$.Localize("#Hud_ChangeSchools_title")} />
        <Label id='ChangeSchools_desc' text={$.Localize("#Hud_ChangeSchools_desc")} />
        <Panel id='SchoolsList'>
            {
                schools_array.map((schools_index) => {
                    return <Schools key={schools_index} label_name={Entities.GetUnitLabel(Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer()))} schools_index={schools_index} Schools_selected={Schools_selected} />;
                })
            }
        </Panel>
    </Panel>;
}

function Schools({ label_name, schools_index, Schools_selected }: { label_name: string, schools_index: number, Schools_selected: number; }) {
    let schools = GameUI.CustomUIConfig().SchoolsKv[label_name]?.[schools_index];
    let duty = GameUI.CustomUIConfig().SchoolsKv[label_name]?.[schools_index].duty;
    let duty_class = "schools_duty_dps";// 默认是DPS
    if (duty == SCHOOLS_DUTY_DPS) {
        duty_class = "schools_duty_dps";
    }
    else if (duty == SCHOOLS_DUTY_HEALER) {
        duty_class = "schools_duty_healer";
    } else if (duty == SCHOOLS_DUTY_TANK) {
        duty_class = "schools_duty_tank";
    }
    let hero_index = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer());
    let abilities: string[] = [];

    if (schools != undefined) {
        for (let index = MIN_ABILITY_SLOT + 1; index < MAX_ABILITY_SLOT; index++) {

            if (schools[`Ability${index}`] == undefined) {
                break;
            }
            else {
                abilities.push(schools[`Ability${index}`]);
            }
        }
    }


    return <Panel id='schools'>
        <Panel id='schools_title'>
            <Image id='schools_position_icon' className={duty_class} />
            <Label id='schools_name' text={$.Localize("#" + label_name + "_schools_" + schools_index) + $.Localize("#" + duty_class)} />
        </Panel>
        <Label id='schools_desc' text={$.Localize("#" + label_name + "_schools_" + schools_index + "_desc")} />
        <Panel id='schools_abilities'>
            {
                abilities.map((ability_name) => {
                    // $.Msg(ability_name)
                    return <DOTAAbilityImage key={ability_name} className="schools_abilities_panel" abilityname={ability_name}
                        onmouseover={p => {
                            $.DispatchEvent("DOTAShowAbilityTooltipForEntityIndex", p, ability_name, hero_index);
                        }}
                        onmouseout={p => {
                            $.DispatchEvent("DOTAHideAbilityTooltip", p);
                        }}
                    ></DOTAAbilityImage>;
                })
            }
        </Panel>
        <TextButton id='choose_school' text={$.Localize(schools_index == Schools_selected ? "#current_school" : "#choose_school")} className={schools_index == Schools_selected ? "disable" : ""} enabled={schools_index != Schools_selected} onactivate={() => {
            if (InCombat(hero_index)) {
                GameUI.SendCustomHUDError($.Localize("#dota_hud_error_change_schools_in_combat"), "General.CastFail_Custom");
            }
            else {
                Game.EmitSound("underdraft_drafted");
                GameEvents.SendCustomGameEventToServer("ChangeRoleMastery", { entindex: hero_index, new_schools: schools_index });
            }

        }}></TextButton>
    </Panel>;
}

{ render(<ChangeSchools />, $.GetContextPanel()); }