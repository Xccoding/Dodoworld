import React from 'react';
import { render } from '@demon673/react-panorama';
import ReactUtils from "./../utils/React_utils";
import { print}  from './Utils'

// render(<Buffpanel />, $("#Buffs")); 
// render(<HealthMana />, $("#HealthManaRoot")); 
// render(<Xpbar />, $("#XpbarRoot")); 



{
    let pHud = $.GetContextPanel();
	while (pHud && pHud.id != "Hud") {
		pHud = pHud.GetParent() as Panel;
	}
    GameUI.CustomUIConfig().HudRoot = pHud
	
	GameUI.CustomUIConfig().AbilityKv = {};
	GameUI.CustomUIConfig().SchoolsKv = {};
	GameUI.CustomUIConfig().HeroesKv = {};
	

	// for(const k in GameUI.CustomUIConfig().AbilityKv){
	// 	print("N2O", k, GameUI.CustomUIConfig().AbilityKv[k])
	// }

	$.Schedule(Game.GetGameFrameTime(), updateKV);

	function updateKV(){
		for(const k in GameUI.CustomUIConfig()){
			if(k.indexOf("_ability") != -1){
				let thisKV = (GameUI.CustomUIConfig() as any)[k].DOTAAbilities
				for(const abilityName in thisKV){
					GameUI.CustomUIConfig().AbilityKv[abilityName] = thisKV[abilityName]
				}
			}
			else if(k.indexOf("_hero") != -1){
				let thisKV = (GameUI.CustomUIConfig() as any)[k].DOTAHeroes
				for(const heroName in thisKV){
					GameUI.CustomUIConfig().HeroesKv[heroName] = thisKV[heroName]
				}
			}
		}

		GameUI.CustomUIConfig().SchoolsKv = (GameUI.CustomUIConfig() as any).Schools.SchoolsList;
	}




}
// function HUD_main(){


//     return(
//         <></>
//     )
// }

// render(<HUD_main/>, $.GetContextPanel())


// function ReactPanoramaPanel(){
    
//     $.Msg(new_1())
//     return (
//         <Panel>
//             {/* <DOTAHeroImage heroimagestyle="icon" heroname="npc_dota_hero_lina"/> */}
//         </Panel>
//     );
// }

// render(<ReactPanoramaPanel />, $.GetContextPanel()); 