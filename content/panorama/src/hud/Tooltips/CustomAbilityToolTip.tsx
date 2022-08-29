import React, { useEffect, useRef, useState } from 'react';
import { render, useGameEvent } from '@demon673/react-panorama';
import { FindModifierByName, GetAbilityValue, GetUnitAttribute, print, replaceAll, useToggleHud } from '../Utils';
import ReactUtils from '../../utils/React_utils';

const pSelf: Panel = $.GetContextPanel();

function ShowTooltip() {
    let ability = Number(pSelf.GetAttributeString("ability", "")) as AbilityEntityIndex;
    let unit: any = pSelf.GetAttributeString("unit", "");

    if (unit != undefined) {
        unit = Number(unit) as EntityIndex;
    }
    render(<CustomAbilityToolTip ability={ability} unit={unit} />, pSelf);
}

const ValueCalculate = {
    ["ap_factor"]: {
        attrName: "total_attack_damage"
    },
    ["sp_factor"]: {
        attrName: "spell_power"
    },
    ["int_factor"]: {
        attrName: "intellect"
    },
};

function FormatDesc(ability: AbilityEntityIndex, desc: string, bAltDown: boolean, hero?: EntityIndex) {
    let abilityName = Abilities.GetAbilityName(ability);
    let match_array = desc.match(/\%[a-zA-Z_0-9]+\%/g);

    if (match_array != null) {
        for (const key_string of match_array) {
            let key_name = replaceAll(key_string, "%", "");
            let value = Abilities.GetLevelSpecialValueFor(ability, key_name, Math.max(Abilities.GetLevel(ability), 1));
            let bReplaced = false;

            for (const k in ValueCalculate) {
                if (key_name.indexOf(k) != -1) {
                    if (bAltDown) {
                        desc = desc.replace(key_string, "[" + String(value.toFixed(0)) + "%" + $.Localize("#Character_attribute_" + (ValueCalculate as any)[k].attrName) + "]");
                    }
                    else {
                        let attrValue = GetUnitAttribute((ValueCalculate as any)[k].attrName, hero);
                        desc = desc.replace(key_string, (value * attrValue * 0.01).toFixed(1));
                    }

                    bReplaced = true;
                    break;
                }
            }

            if (!bReplaced) {
                desc = desc.replace(key_string, String(value));
            }
        }
    }
    desc = replaceAll(desc, "%%", "%");

    return desc;
}

function CustomAbilityToolTip({ ability, unit }: { ability: AbilityEntityIndex, unit?: EntityIndex; }) {
    const [AltDown, SetAltDown] = useState(GameUI.IsAltDown());
    let Level = Abilities.GetLevel(ability);
    let bPassive = Abilities.IsPassive(ability)
    let CooldownReduction = GetUnitAttribute("cooldown_reduction", unit);
    let abilityName = Abilities.GetAbilityName(ability);
    let abilityManaCost = Level > 0 ? Abilities.GetManaCost(ability) : GetAbilityValue(abilityName, Level, "AbilityManaCost");
    let abilityCastRange = Level > 0 ? Abilities.GetCastRange(ability) : GetAbilityValue(abilityName, Level, "AbilityCastRange");
    let MaxCharge = Abilities.GetMaxAbilityCharges(ability);
    let CooldownTime = (Level > 0 ? Abilities.GetCooldown(ability) : GetAbilityValue(abilityName, Level, "AbilityCooldown")) * (100 - CooldownReduction) * 0.01; // TODO从kv读取数值后重新计算冷却缩减
    let CastPoint = Number((Level > 0 ? Abilities.GetCastPoint(ability) : Number(GetAbilityValue(abilityName, Level, "AbilityCastPoint"))).toFixed(2));
    let ChannelTime = Abilities.GetChannelTime(ability);
    let Costtype = GameUI.CustomUIConfig().AbilityKv[abilityName]?.AbilityCosttype;
    let ChargeRestoreTime = GameUI.CustomUIConfig().AbilityKv[abilityName]?.AbilityChargeRestoreTime * (100 - CooldownReduction) * 0.01 || 0;
    let CD_text = "";
    let Cost_text = "";
    let CRange_text = "";
    let CPoint_text = "";

    if (ChargeRestoreTime > CooldownTime) {
        CD_text = ChargeRestoreTime + $.Localize("#AbilityTooltip_ChargeTime");
    }
    else {
        CD_text = CooldownTime + $.Localize("#AbilityTooltip_CooldownTime");
    }

    if (abilityManaCost > 0) {
        Cost_text = abilityManaCost + $.Localize(`#AbilityTooltip_Costtype_${Costtype}`);
    }
    else {
        Cost_text = $.Localize("#AbilityTooltip_NoCost");
    }

    if (abilityCastRange > 0) {
        CRange_text = abilityCastRange + $.Localize("#AbilityTooltip_CastRange");
    }

    if (ChannelTime > 0) {
        CPoint_text = ChannelTime + $.Localize("#AbilityTooltip_CastPoint");
    }
    else if (CastPoint > 0) {
        CPoint_text = CastPoint + $.Localize("#AbilityTooltip_CastPoint");
    }
    else {
        CPoint_text = $.Localize("#AbilityTooltip_Prompt");
    }

    let localize_key = `#DOTA_Tooltip_ability_${abilityName}_Description_lv${Level > 0 ? Abilities.GetLevel(ability) : 1}`;
    let abilityDesc_origin = $.Localize(localize_key);
    let abilityDesc = FormatDesc(ability, abilityDesc_origin, AltDown, unit);

    let abilityNextLevel = $.Localize("#AbilityTooltip_MaxLevel");
    if (Abilities.GetMaxLevel(ability) > Abilities.GetLevel(ability)) {
        let abilityLevels: string[] = (GameUI.CustomUIConfig().AbilityKv[abilityName].CustomRequiredLevel).split(" ");
        let NextLevel = abilityLevels[(Abilities.GetLevel(ability) - 1) + 1];
        if(Level > 0){
            abilityNextLevel = $.Localize("#AbilityTooltip_NextLevel").replace("[!s:next_level]", NextLevel);
        }
        else{
            abilityNextLevel = $.Localize("#AbilityTooltip_NextLevel_NotLearned").replace("[!s:next_level]", NextLevel);
        }
    }

    ReactUtils.useSchedule(() => {
        SetAltDown(GameUI.IsAltDown());
        return Math.max(Game.GetGameFrameTime(), 1 / 30);
    }, []);

    return <Panel id='CustomAbilityToolTips'>
        <Panel id='CustomAbilityToolTips_title'>
            <Label id='abilityName' text={$.Localize(`#DOTA_Tooltip_ability_${abilityName}`)} />
            <Label id='abilityLevel' text={$.Localize("#AbilityTooltip_Level") + Abilities.GetLevel(ability)} />
        </Panel>
        <Panel id='CustomAbilityToolTips_header' className={bPassive? "Passive" : ""}>
            <Label id='AbilityManaCost' text={Cost_text} className={bPassive? "Passive" : ""}/>
            <Label id='AbilityCastRange' text={CRange_text} className={bPassive? "Passive" : ""}/>
            <Label id='AbilityCastPoint' text={CPoint_text} className={bPassive? "Passive" : ""}/>
            <Label id='AbilityCooldown' text={CD_text} className={bPassive? "Passive" : ""}/>
        </Panel>
        <Panel id='CustomAbilityToolTips_main'>
            <Label id='main_description' html={true} text={abilityDesc} />
        </Panel>
        <Panel id='CustomAbilityToolTips_bottom'>
            <Label id='bottom_text_level' html={true} text={abilityNextLevel} />
            <Label id='bottom_text_alt_tip' html={true} text={$.Localize("#AbilityTooltip_AltTip")} />
        </Panel>
    </Panel>;
}


(function () {
    pSelf.SetPanelEvent("ontooltiploaded", ShowTooltip);
})();