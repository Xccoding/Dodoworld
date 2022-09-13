import React, { useState } from 'react';
import { render } from '@demon673/react-panorama';
import { GetAbilityValueFromClient, GetAbilityValueFromKV, GetUnitAttribute, IsPassive } from '../Utils';
import ReactUtils from '../../utils/React_utils';
import { FormatDesc } from './TooltipUtils';

const pSelf: Panel = $.GetContextPanel();

function ShowTooltip() {
    let ability = Number(pSelf.GetAttributeString("ability", ""));
    let ability_name: any = pSelf.GetAttributeString("ability_name", "");
    let level: any = pSelf.GetAttributeString("level", "0");
    let forHero: any = pSelf.GetAttributeString("forHero", "0");
    if (ability == 0) {
        ability = -1;
    }
    render(<CustomAbilityToolTip ability={ability as AbilityEntityIndex} ability_name={ability_name} level={level} forHero={forHero == "1"} />, pSelf);
}

export function CustomAbilityToolTip({ ability, ability_name, forHero, level }: { ability: AbilityEntityIndex, ability_name: string, forHero: boolean, level?: number; }) {
    const [AltDown, SetAltDown] = useState(GameUI.IsAltDown());
    let Level = 0;
    let bPassive = false;
    let CooldownReduction = 0;
    let abilityName = "";
    let abilityManaCost = 0;
    let abilityCastRange = 0;
    let CooldownTime = 0;
    let CastPoint = 0;
    let ChannelTime = 0;
    let MovingCastTime = 0;
    let Costtype = "";
    let ChargeRestoreTime = 0;
    let unit = -1 as EntityIndex;
    let bCostManaPct = false;

    if (ability != -1) {
        // 有技能实体
        Level = Abilities.GetLevel(ability);
        abilityName = Abilities.GetAbilityName(ability);
        unit = Abilities.GetCaster(ability);
        bPassive = (Abilities.IsPassive(ability));
        CooldownReduction = GetUnitAttribute("cooldown_reduction", unit);
        CooldownTime = Number(GetAbilityValueFromClient(ability, "AbilityCooldown")) * (100 - CooldownReduction) * 0.01;
        ChannelTime = Abilities.GetChannelTime(ability);
        MovingCastTime = GetAbilityValueFromKV(abilityName, Level, "MovingCastTime");
        ChargeRestoreTime = Number(GetAbilityValueFromClient(ability, "AbilityChargeRestoreTime")) * (100 - CooldownReduction) * 0.01;
        CastPoint = Number(Abilities.GetCastPoint(ability).toFixed(2));
        bCostManaPct = (GetAbilityValueFromKV(abilityName, Level, "mana_cost_pct") != 0);
        if (Level > 0) {
            if (!AltDown) {
                abilityManaCost = Abilities.GetManaCost(ability);
            }
            else {
                abilityManaCost = bCostManaPct ? GetAbilityValueFromKV(abilityName, Level, "mana_cost_pct") : GetAbilityValueFromKV(abilityName, Level, "AbilityManaCost");
            }

            abilityCastRange = Abilities.GetCastRange(ability);
        }
        else {
            abilityManaCost = bCostManaPct ? GetAbilityValueFromKV(abilityName, Level, "mana_cost_pct") : GetAbilityValueFromKV(abilityName, Level, "AbilityManaCost");

            abilityCastRange = GetAbilityValueFromKV(abilityName, Level, "AbilityCastRange");

        }
    }
    else if (ability_name != "") {
        // 没有技能实体
        Level = level || 1;
        abilityName = ability_name;
        bPassive = IsPassive(abilityName);
        abilityCastRange = GetAbilityValueFromKV(abilityName, Level, "AbilityCastRange");
        CooldownTime = Number(GetAbilityValueFromKV(abilityName, Level, "AbilityCooldown"));
        MovingCastTime = GetAbilityValueFromKV(abilityName, Level, "MovingCastTime");
        ChannelTime = GetAbilityValueFromKV(abilityName, Level, "AbilityChannelTime");
        CastPoint = Number(Number(GetAbilityValueFromKV(abilityName, Level, "AbilityCastPoint")).toFixed(2));
        ChargeRestoreTime = GetAbilityValueFromKV(abilityName, Level, "AbilityChargeRestoreTime") * (100 - CooldownReduction) * 0.01;
        bCostManaPct = (GetAbilityValueFromKV(abilityName, Level, "mana_cost_pct") != 0);
        abilityManaCost = bCostManaPct ? GetAbilityValueFromKV(abilityName, Level, "mana_cost_pct") : GetAbilityValueFromKV(abilityName, Level, "AbilityManaCost");
    }

    Costtype = GetAbilityValueFromKV(abilityName, Level, "AbilityCosttype");

    let CD_text = "";
    let Cost_text = "";
    let CRange_text = "";
    let CPoint_text = "";

    // 特殊处理不受缩减的冷却时间
    if (GetAbilityValueFromKV(abilityName, Level, "ConstantCooldown") != 0) {
        CooldownTime = Number(GetAbilityValueFromKV(abilityName, Level, "ConstantCooldown"));
    }

    if (ChargeRestoreTime > CooldownTime) {
        CD_text = ChargeRestoreTime.toFixed(1) + $.Localize("#AbilityTooltip_ChargeTime");
    }
    else {
        CD_text = CooldownTime.toFixed(1) + $.Localize("#AbilityTooltip_CooldownTime");
    }

    if (abilityManaCost > 0) {

        if (ability != -1) {
            Cost_text = String(abilityManaCost) + ((AltDown || Level <= 0) && bCostManaPct ? "%" : "") + $.Localize(`#AbilityTooltip_Costtype_${Costtype}`);
        }
        else {
            Cost_text = String(abilityManaCost) + (bCostManaPct ? "%" : "") + $.Localize(`#AbilityTooltip_Costtype_${Costtype}`);
        }
    }
    else {
        Cost_text = $.Localize("#AbilityTooltip_NoCost");
    }

    if (abilityCastRange > 0) {
        CRange_text = abilityCastRange + $.Localize("#AbilityTooltip_CastRange");
    }

    if (ChannelTime > 0) {
        CPoint_text = ChannelTime.toFixed(1) + $.Localize("#AbilityTooltip_ChannelTime");
    }
    else if (CastPoint > 0) {
        CPoint_text = CastPoint + $.Localize("#AbilityTooltip_CastPoint");
    }
    else if (MovingCastTime > 0) {
        CPoint_text = MovingCastTime + $.Localize("#AbilityTooltip_CastPoint");
    }
    else {
        CPoint_text = $.Localize("#AbilityTooltip_Prompt");
    }

    let localize_key = `#DOTA_Tooltip_ability_${abilityName}_Description_lv${Level != undefined && Level > 0 ? Abilities.GetLevel(ability!) : 1}`;
    let abilityDesc_origin = $.Localize(localize_key);
    let abilityDesc = FormatDesc(abilityDesc_origin, AltDown, abilityName, "ability", unit, ability, Level);


    let abilityNextLevel = $.Localize("#AbilityTooltip_MaxLevel");
    if (GameUI.CustomUIConfig().AbilityKv[abilityName]?.MaxLevel > Level) {
        let abilityLevels: string[] = (GameUI.CustomUIConfig().AbilityKv[abilityName]?.CustomRequiredLevel || "0").split(" ");
        let NextLevel = abilityLevels[Level > 0 ? Level : 0];
        if (GetAbilityValueFromKV(abilityName, 1, "UnlockTalent") != 0) {
            let talent_name_local = $.Localize("#DOTA_Tooltip_Talent_" + GetAbilityValueFromKV(abilityName, 1, "UnlockTalent"));
            abilityNextLevel = $.Localize("#AbilityTooltip_UnlockTalent").replace("[!s:talent_name]", talent_name_local);
        }
        else if (Level > 0) {
            abilityNextLevel = $.Localize("#AbilityTooltip_NextLevel").replace("[!s:next_level]", NextLevel);
        }
        else {
            abilityNextLevel = $.Localize("#AbilityTooltip_NextLevel_NotLearned").replace("[!s:next_level]", NextLevel);
        }
    }

    let TalentsArray: string[] = [];
    if (unit != -1) {
        let TalentKv = GameUI.CustomUIConfig().TalentsKv;
        let Schools_selected = CustomNetTables.GetTableValue("hero_schools", Entities.GetPlayerOwnerID(unit))?.schools_index || 0;
        let HeroTalentInfo = CustomNetTables.GetTableValue("hero_talents", Entities.GetPlayerOwnerID(unit)) || [];
        for (const roleName in TalentKv) {
            const role = TalentKv[roleName];

            if (role[Schools_selected] != undefined) {
                const Talents = role[Schools_selected];
                for (const talent_name in Talents) {
                    if (Talents[talent_name].UpgradeAbilities != undefined) {
                        if (Talents[talent_name].UpgradeAbilities[abilityName] != undefined) {
                            let bTalentSelected = (Object.entries(HeroTalentInfo).find((value, index) => {
                                if (value[1] == talent_name) {
                                    return true;
                                }
                            }) != undefined);
                            if (bTalentSelected) {
                                TalentsArray.push(talent_name);
                            }
                        }
                    }
                }
            }
        }
    }



    ReactUtils.useSchedule(() => {
        SetAltDown(GameUI.IsAltDown());
        return Math.max(Game.GetGameFrameTime(), 1 / 30);
    }, []);

    return <Panel id='CustomAbilityToolTips'>
        <Panel id='CustomAbilityToolTips_title'>
            <Label id='abilityName' text={$.Localize(`#DOTA_Tooltip_ability_${abilityName}`)} />
            <Label id='abilityLevel' text={$.Localize("#AbilityTooltip_Level") + Level} />
        </Panel>
        <Panel id='CustomAbilityToolTips_header' className={bPassive ? "Passive" : ""}>
            <Label id='AbilityManaCost' text={Cost_text} className={bPassive ? "Passive" : ""} />
            <Label id='AbilityCastRange' text={CRange_text} className={bPassive ? "Passive" : ""} />
            <Label id='AbilityCastPoint' text={CPoint_text} className={bPassive ? "Passive" : ""} />
            <Label id='AbilityCooldown' text={CD_text} className={bPassive ? "Passive" : ""} />
        </Panel>
        <Panel id='CustomAbilityToolTips_main'>
            <Label id='main_description' html={true} text={abilityDesc} />
            {
                (() => {
                    if (unit != -1) {
                        return (TalentsArray.map((talent_name, index) => {
                            let Desc = $.Localize("#DOTA_Tooltip_Talent_" + talent_name + "_Desc");
                            Desc = FormatDesc(Desc, false, talent_name, "talent", unit, -1 as AbilityEntityIndex, 1);
                            Desc = `[${$.Localize("#Talent")} · ${$.Localize("#DOTA_Tooltip_Talent_" + talent_name)}]` + Desc;
                            return <Label id='talent_description' key={index} html={true} text={Desc} />;
                        }));
                    }
                })()
            }

        </Panel>
        <Panel id='CustomAbilityToolTips_bottom' className={forHero ? "Show" : ""}>
            <Label id='bottom_text_level' html={true} text={abilityNextLevel} />
            <Label id='bottom_text_alt_tip' html={true} text={$.Localize("#AbilityTooltip_AltTip")} />
        </Panel>
    </Panel>;
}


(function () {
    pSelf.SetPanelEvent("ontooltiploaded", ShowTooltip);
})();