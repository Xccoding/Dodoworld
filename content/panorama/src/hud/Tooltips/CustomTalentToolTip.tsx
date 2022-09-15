import React, { useEffect, useRef, useState } from 'react';
import { render, useGameEvent } from '@demon673/react-panorama';
import { print } from '../Utils';
import { FormatDesc } from './TooltipUtils';
import { CustomAbilityToolTip } from './CustomAbilityToolTip';
import ReactUtils from '../../utils/React_utils';

const pSelf: Panel = $.GetContextPanel();

function ShowTooltip() {
    let talent_name: any = pSelf.GetAttributeString("talent_name", "");
    let hero: any = Number(pSelf.GetAttributeString("hero", "0")) as EntityIndex;

    render(<CustomTalentToolTip talent_name={talent_name} hero={hero} />, pSelf);
}

function CustomTalentToolTip({ talent_name, hero }: { talent_name: string, hero: EntityIndex; }) {
    let TalentKv = GameUI.CustomUIConfig().TalentsKv;
    let playerID = Entities.GetPlayerOwnerID(hero);
    let Schools_selected = CustomNetTables.GetTableValue("hero_schools", playerID)?.schools_index || 0;
    let TalentType = "Upgrade";
    let new_ability_name = "";

    for (const roleName in TalentKv) {
        const role = TalentKv[roleName];

        if (role[Schools_selected] != undefined) {
            const tKV = role[Schools_selected][talent_name];
            if (tKV.UpgradeAbilities != undefined) {
                TalentType = "Upgrade";
            }
            else if (tKV.NewAbility != undefined) {
                TalentType = "NewAbility";
                new_ability_name = tKV.NewAbility;
            }
        }
    }

    return (
        <Panel id="CustomTalentToolTips">
            <Panel id='CustomTalentToolTips_title'>
                <Label text={$.Localize("#DOTA_Tooltip_Talent_" + talent_name)}></Label>
            </Panel>
            <Panel id='CustomTalentToolTips_main'>
                <Panel id='CustomTalentToolTips_topbar'>
                    <Label text={$.Localize("#TalentType_" + TalentType)}></Label>
                </Panel>
                <Panel id='CustomTalentToolTips_content'>
                    {
                        (() => {
                            if (TalentType == 'Upgrade') {
                                return <CustomAbilityUpgrade talent_name={talent_name} hero={hero} />;
                            }
                            else if (TalentType == 'NewAbility') {
                                return <CustomAbilityToolTip ability={Entities.GetAbilityByName(hero, new_ability_name)} ability_name={new_ability_name} forHero={true} />;
                            }
                        })()
                    }
                </Panel>
            </Panel>
            <Panel id='CustomTalentToolTips_bottombar' className={TalentType == 'Upgrade' ? "Show" : ""}>
                <Panel id='bottom_content'>
                    <Label id='bottom_text_alt_tip' html={true} text={$.Localize("#AbilityTooltip_AltTip")} />
                </Panel>
            </Panel>
        </Panel>
    );
}

export function CustomAbilityUpgrade({ talent_name, hero }: { talent_name: string, hero: EntityIndex; }) {
    const [AltDown, SetAltDown] = useState(GameUI.IsAltDown());
    let Desc = $.Localize("#DOTA_Tooltip_Talent_" + talent_name + "_Desc");
    Desc = FormatDesc(Desc, AltDown, talent_name, "talent", hero, -1 as AbilityEntityIndex, 1);

    ReactUtils.useSchedule(() => {
        SetAltDown(GameUI.IsAltDown());
        return Math.max(Game.GetGameFrameTime(), 1 / 30);
    }, []);

    return (<Panel id='CustomAbilityUpgrade'>
        <Label id='CustomAbilityUpgrade_text' text={Desc}></Label>
    </Panel>);
}

(function () {
    pSelf.SetPanelEvent("ontooltiploaded", ShowTooltip);
})();
