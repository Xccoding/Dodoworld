import React, { ReactNodeArray, useEffect, useRef, useState } from 'react';
import { render, useNetTableValues } from '@demon673/react-panorama';
import ReactUtils from "../../utils/React_utils";
import { FindModifierByName, print } from '../Utils';

function Talent() {
    const playerID = Players.GetLocalPlayer();
    const hero = Players.GetPlayerHeroEntityIndex(playerID);
    const TalentKv = GameUI.CustomUIConfig().TalentsKv;
    const HeroTalentInfo = useNetTableValues("hero_talents")[playerID] || [];
    const Schools_selected = useNetTableValues("hero_schools")[playerID].schools_index || 0;
    const [Talent_tree, SetTalent_tree] = useState<string[][]>([]);

    useEffect(() => {
        let tree: string[][] = [[], [], []];
        let talents = TalentKv[Entities.GetUnitLabel(hero)][Schools_selected];

        for (const talent_name in talents) {
            const floor = talents[talent_name].TalentFloor;
            tree[floor - 1].push(talent_name);
        }
        SetTalent_tree(tree);
    }, [HeroTalentInfo, Schools_selected]);


    return (<Panel id="Talent_main">
        {
            Talent_tree.map((floor, index) => {
                floor.map((talent_name, i) => {
                    print("N2O", talent_name);
                });
            })
        }
    </Panel>);
}

$.Schedule(1.5, () => {
    render(<Talent />, $.GetContextPanel());
});
