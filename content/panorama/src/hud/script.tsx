import React from 'react';
import { render } from '@demon673/react-panorama';
import ReactUtils from "./../utils/React_utils";
import { Buffpanel } from './bufflist/bufflist'
import { ChangeSchools } from './ChangeSchools/ChangeSchools'
import { DHPS_Counter } from './DHPS_Counter/DHPS_Counter'
import { HealthMana } from './hp_mana/hp_mana'
import { Right_bottom_button } from './right_bottom_button/right_bottom_button'
import { Xpbar } from './xpbar/xpbar'
import { Backpack } from './Backpack/Backpack';
import { OverheadBar_Init } from './OverheadBar/OverheadBar';
import { print}  from './Utils'

render(<Buffpanel />, $("#Buffs")); 
render(<DHPS_Counter />, $("#DHPS_CounterRoot")); 
render(<HealthMana />, $("#HealthManaRoot")); 
render(<Xpbar />, $("#XpbarRoot")); 
render(<Right_bottom_button />, $("#Right_bottom_button_Root"));
render(<ChangeSchools />, $("#ChangeSchools_Root"));
render(<Backpack />, $("#Backpack_Root"));

OverheadBar_Init()


// function ReactPanoramaPanel(){
    
//     $.Msg(new_1())
//     return (
//         <Panel>
//             {/* <DOTAHeroImage heroimagestyle="icon" heroname="npc_dota_hero_lina"/> */}
//         </Panel>
//     );
// }

// render(<ReactPanoramaPanel />, $.GetContextPanel()); 