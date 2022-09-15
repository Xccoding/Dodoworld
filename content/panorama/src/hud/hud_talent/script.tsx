import React, { useEffect, useState } from 'react';
import { render, useNetTableValues } from '@demon673/react-panorama';
import { FormatString } from '../Utils';

function Talent() {
    const playerID = Players.GetLocalPlayer();
    const HeroTalentInfo = useNetTableValues("hero_talents")[playerID];
    const Schools_selected = useNetTableValues("hero_schools")[playerID].schools_index || 0;
    const [Talent_tree, SetTalent_tree] = useState<{ talent_name: string, texture: string; }[][]>([]);
    let TalentKv = GameUI.CustomUIConfig().TalentsKv;

    useEffect(() => {
        let tree: { talent_name: string, texture: string; }[][] = [[], [], [], [], []];
        let hero = Players.GetPlayerHeroEntityIndex(playerID);
        let talents = TalentKv[Entities.GetUnitLabel(hero)]?.[Schools_selected] || [];

        for (const talent_name in talents) {
            const floor = talents[talent_name].TalentFloor;
            tree[floor - 1].push({ talent_name: talent_name, texture: talents[talent_name].Texture });
        }
        SetTalent_tree(tree);
        // print("N2O", HeroTalentInfo)
    }, [HeroTalentInfo, Schools_selected]);


    return (<Panel id="Talent_main">
        {
            Talent_tree.map((floor, index) => {
                return (
                    <Panel key={index} id="Talent_floor">
                        <Panel id='Talent_floor_level'>
                            <Label text={index}></Label>
                        </Panel>
                        {
                            floor.map((talentInfo, i) => {
                                let Selected = (HeroTalentInfo?.[index + 1] == talentInfo.talent_name);
                                let TextureName = "s2r://panorama/images/spellicons/" + talentInfo.texture + "_png.vtex";
                                return <Panel key={i} id='Talent_slot'>
                                    <Panel id='Talent_panel' className={Selected ? "Selected" : ""}
                                        onactivate={() => {
                                            GameEvents.SendCustomGameEventToServer("SelectTalent", { talent_name: talentInfo.talent_name });
                                        }}
                                        onmouseover={(p) => {
                                            $.DispatchEvent(
                                                "UIShowCustomLayoutParametersTooltip",
                                                p,
                                                "CustomTalentToolTip",
                                                `file://{resources}/layout/custom_game/hud/Tooltips/CustomTalentToolTip.xml`,
                                                FormatString({ talent_name: talentInfo.talent_name, hero: String(Players.GetPlayerHeroEntityIndex(playerID)) })
                                            );
                                        }}
                                        onmouseout={(p) => {
                                            $.DispatchEvent("UIHideCustomLayoutTooltip", p, "CustomTalentToolTip");
                                        }}>
                                        <Image src={TextureName} scaling="stretch-to-cover-preserve-aspect" />
                                        <Label text={$.Localize("#DOTA_Tooltip_Talent_" + talentInfo.talent_name)}></Label>
                                    </Panel>
                                </Panel>;
                            })
                        }
                    </Panel>
                );
            })
        }
    </Panel>);
}

$.Schedule(1, () => {
    render(<Talent />, $.GetContextPanel());
});
