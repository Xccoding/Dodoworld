import React, { ReactNodeArray, useEffect, useRef, useState } from 'react';
import { render } from '@demon673/react-panorama';
import ReactUtils from "../../utils/React_utils";
import { FindModifierByName, print } from '../Utils';

const SchoolsBarConfig = {
    mage_0: {
        MaxCharge: 2,
    }
};

export function HealthMana() {
    const [thealth_info, setHealth] = useState(refresHealth);
    const [tmana_info, setMana] = useState(refreshMana);
    let hero = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer());
    let schools_index = CustomNetTables.GetTableValue("hero_schools", Players.GetLocalPlayer())?.schools_index || 0;
    function refresHealth() {
        let unit = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer());
        let max_health = Entities.GetMaxHealth(unit);
        let health: number = 0, health_regen: number = 0, percent: number = 0;
        if (max_health > 0) {
            health = Entities.GetHealth(unit);
            health_regen = Entities.GetHealthThinkRegen(unit);
            percent = health / max_health;
        }
        return { max_health: max_health, health: health, health_regen: health_regen, percent: percent };
    }

    function refreshMana() {
        let unit = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer());
        let max_mana = Entities.GetMaxMana(unit);
        let mana: number = 0, mana_regen: number = 0, percent: number = 0;
        if (max_mana > 0) {
            mana = Entities.GetMana(unit);
            mana_regen = Entities.GetManaThinkRegen(unit);
            percent = mana / max_mana;
        }
        return { max_mana: max_mana, mana: mana, mana_regen: mana_regen, percent: percent };
    }

    ReactUtils.useSchedule(
        () => {
            setHealth(refresHealth);
            setMana(refreshMana);
            return Math.max(1 / 30, Game.GetGameFrameTime());
        }, []);

    return (
        <Panel id="HealthAndManaContainer" >
            <HealthBar max_health={thealth_info.max_health} health={thealth_info.health} health_regen={thealth_info.health_regen} percent={thealth_info.percent} />
            <Panel id='SchoolsBar'>
                {
                    (()=>{
                        if(`${Entities.GetUnitLabel(hero)}_${schools_index}` == "mage_0"){
                            return <SchoolsBar_Fire_Mage/>
                        }
                    })()
                }
            </Panel>
            <ManaBar max_mana={tmana_info.max_mana} mana={tmana_info.mana} mana_regen={tmana_info.mana_regen} percent={tmana_info.percent} />
        </Panel>
    );
}

function HealthBar({ max_health, health, health_regen, percent }: { max_health: number, health: number, health_regen: number, percent: number; }) {
    let width = `${percent * 100 > 100 ? 100 : percent * 100 + 1}%`;
    // 处理数字长度
    let health_unit = "";
    let max_health_unit = "";
    let health_regen_unit = "";
    if (max_health >= 10000) {
        max_health = Number((max_health * 0.0001).toFixed(1));
        max_health_unit = "万";
    }
    if (health >= 10000) {
        health = Number((health * 0.0001).toFixed(1));
        health_unit = "万";
    }
    if (health_regen >= 10000) {
        health_regen = Number((health_regen * 0.0001).toFixed(1));
        health_regen_unit = "万";
    }

    return <ProgressBar id="HealthProgressBar" value={percent} onmouseover={p => {
        $.DispatchEvent("DOTAShowTextTooltip", p, $.Localize("#hud_text_tooltip_HealthBar"));
    }
    }
        onmouseout={
            () => {
                $.DispatchEvent("DOTAHideTextTooltip");
            }
        }>
        <Label id="hp_maxhp" text={`${health + health_unit} /  ${max_health + max_health_unit}`}></Label>
        <Label id="hp_regen" text={`+ ${health_regen.toFixed(1) + health_regen_unit}`}></Label>
        <Panel id="HealthBarBG" style={{ width }} ></Panel>
    </ProgressBar>;
}

function ManaBar({ max_mana, mana, mana_regen, percent }: { max_mana: number, mana: number, mana_regen: number, percent: number; }) {
    let width = `${percent * 100 > 100 ? 100 : percent * 100 + 1}%`;
    let hero_index = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer());
    let hero_label = Entities.GetUnitLabel(hero_index);

    let bShowMpRegen = true;
    if (hero_label == "death_knight") {
        bShowMpRegen = false;
    }

    // 处理数字长度
    let mana_unit = "";
    let max_mana_unit = "";
    let mana_regen_unit = "";
    if (max_mana >= 10000) {
        max_mana = Number((max_mana * 0.0001).toFixed(1));
        max_mana_unit = "万";
    }
    if (mana >= 10000) {
        mana = Number((mana * 0.0001).toFixed(1));
        mana_unit = "万";
    }
    if (mana_regen >= 10000) {
        mana_regen = Number((mana_regen * 0.0001).toFixed(1));
        mana_regen_unit = "万";
    }

    return <ProgressBar id="ManaProgressBar" value={percent} onmouseover={p => {
        $.DispatchEvent("DOTAShowTextTooltip", p, $.Localize("#hud_text_tooltip_ManaBar_" + hero_label));
    }
    }
        onmouseout={
            () => {
                $.DispatchEvent("DOTAHideTextTooltip");
            }
        }>
        <Label id="mp_maxmp" text={`${mana + mana_unit} /  ${max_mana + max_mana_unit}`}></Label>
        {
            bShowMpRegen ? <Label id="mp_regen" text={`+ ${mana_regen.toFixed(1) + mana_regen_unit}`}></Label> : <></>
        }
        <Panel id="ManaBarBG" className={"ManaBarBG_" + hero_label} style={{ width }}></Panel>
    </ProgressBar>;
}

function SchoolsBar_Fire_Mage({}: {}) {
    let unit = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer());
    let count = 0;
    let MaxCharge = SchoolsBarConfig.mage_0.MaxCharge;
    let combo_points = [false, false];
    if (unit != -1) {
        let buffIndex = FindModifierByName(unit, "modifier_mage_fiery_soul_combo");
        
        if (buffIndex != -1) {
            count = MaxCharge;
        }
        else {
            buffIndex = FindModifierByName(unit, "modifier_mage_fiery_soul");
            if (buffIndex != -1) {
                count = Buffs.GetStackCount(unit, buffIndex as BuffID);
            }
        }
    }

    for (let index = 0; index < count; index++) {
        combo_points[index] = true;
    }

    return <Panel id='SchoolsBar_Fire_Mage' className={count == MaxCharge ? "Full" : ""}>
        {
            combo_points.map((bFlag, index) => {
                return <Panel key={index} id='Fire_Mage_ComboPoint' className={`${bFlag ? "Show" : ""} ${count == MaxCharge ? "Full" : ""}`} />;
            })
        }
    </Panel>;
}
