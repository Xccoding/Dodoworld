// import React from 'react';
// import { render } from '@demon673/react-panorama';

// let inputSpell0:string = Game.GetKeybindForAbility(0)
// let inputSpell1:string = Game.GetKeybindForAbility(1)
// let inputSpell2:string = Game.GetKeybindForAbility(2)
// let inputSpell3:string = Game.GetKeybindForAbility(3)
// let inputSpell4:string = Game.GetKeybindForAbility(4)
// let inputSpell5:string = Game.GetKeybindForAbility(5)
// let inputSpell6:string = Game.GetKeybindForInventorySlot(0)
// let inputSpell7:string = Game.GetKeybindForInventorySlot(1)
// let inputSpell8:string = Game.GetKeybindForInventorySlot(2)
// let inputSpell9:string = Game.GetKeybindForInventorySlot(3)
// let inputSpell10:string = Game.GetKeybindForInventorySlot(4)
// let inputSpell11:string = Game.GetKeybindForInventorySlot(5)
// let inputSpell12:string = Game.GetKeybindForCommand(DOTAKeybindCommand_t.DOTA_KEYBIND_INVENTORYNEUTRAL)
// let inputSpelltp:string = Game.GetKeybindForCommand(DOTAKeybindCommand_t.DOTA_KEYBIND_INVENTORYTP)

// Game.CreateCustomKeyBind(inputSpell0, "CastSpell0")
// Game.CreateCustomKeyBind(inputSpell1, "CastSpell1")
// Game.CreateCustomKeyBind(inputSpell2, "CastSpell2")
// Game.CreateCustomKeyBind(inputSpell3, "CastSpell3")
// Game.CreateCustomKeyBind(inputSpell4, "CastSpell4")
// Game.CreateCustomKeyBind(inputSpell5, "CastSpell5")
// Game.CreateCustomKeyBind(inputSpell6, "CastSpell6")
// Game.CreateCustomKeyBind(inputSpell7, "CastSpell7")
// Game.CreateCustomKeyBind(inputSpell8, "CastSpell8")
// Game.CreateCustomKeyBind(inputSpell9, "CastSpell9")
// Game.CreateCustomKeyBind(inputSpell10, "CastSpell10")
// Game.CreateCustomKeyBind(inputSpell11, "CastSpell11")
// Game.CreateCustomKeyBind(inputSpell12, "CastSpell12")
// Game.CreateCustomKeyBind(inputSpelltp, "CastSpelltp")

// function CastAbility0():void
// {
//     let player = Players.GetLocalPlayer()
//     let hero = Players.GetPlayerHeroEntityIndex(player)
//     let ability = Entities.GetAbility(hero, 0)
//     SendAbilityEventToServer(ability, hero)
// }
// function CastAbility1():void
// {
//     let player = Players.GetLocalPlayer()
//     let hero = Players.GetPlayerHeroEntityIndex(player)
//     let ability = Entities.GetAbility(hero, 1)
//     SendAbilityEventToServer(ability, hero)
// }
// function CastAbility2():void
// {
//     let player = Players.GetLocalPlayer()
//     let hero = Players.GetPlayerHeroEntityIndex(player)
//     let ability = Entities.GetAbility(hero, 2)
//     SendAbilityEventToServer(ability, hero)
// }
// function CastAbility3():void
// {
//     let player = Players.GetLocalPlayer()
//     let hero = Players.GetPlayerHeroEntityIndex(player)
//     let ability = Entities.GetAbility(hero, 3)
//     SendAbilityEventToServer(ability, hero)
// }
// function CastAbility4():void
// {
//     let player = Players.GetLocalPlayer()
//     let hero = Players.GetPlayerHeroEntityIndex(player)
//     let ability = Entities.GetAbility(hero, 4)
//     SendAbilityEventToServer(ability, hero)
// }
// function CastAbility5():void
// {
//     let player = Players.GetLocalPlayer()
//     let hero = Players.GetPlayerHeroEntityIndex(player)
//     let ability = Entities.GetAbility(hero, 5)
//     SendAbilityEventToServer(ability, hero)
// }
// function CastAbility6():void
// {
//     let player = Players.GetLocalPlayer()
//     let hero = Players.GetPlayerHeroEntityIndex(player)
//     let ability = Entities.GetAbility(hero, 6)
//     SendAbilityEventToServer(ability, hero)
// }
// function CastAbility7():void
// {
//     let player = Players.GetLocalPlayer()
//     let hero = Players.GetPlayerHeroEntityIndex(player)
//     let ability = Entities.GetAbility(hero, 7)
//     SendAbilityEventToServer(ability, hero)
// }
// function CastAbility8():void
// {
//     let player = Players.GetLocalPlayer()
//     let hero = Players.GetPlayerHeroEntityIndex(player)
//     let ability = Entities.GetAbility(hero, 8)
//     SendAbilityEventToServer(ability, hero)
// }
// function CastAbility9():void
// {
//     let player = Players.GetLocalPlayer()
//     let hero = Players.GetPlayerHeroEntityIndex(player)
//     let ability = Entities.GetAbility(hero, 9)
//     SendAbilityEventToServer(ability, hero)
// }
// function CastAbility10():void
// {
//     let player = Players.GetLocalPlayer()
//     let hero = Players.GetPlayerHeroEntityIndex(player)
//     let ability = Entities.GetAbility(hero, 10)
//     SendAbilityEventToServer(ability, hero)
// }
// function CastAbility11():void
// {
//     let player = Players.GetLocalPlayer()
//     let hero = Players.GetPlayerHeroEntityIndex(player)
//     let ability = Entities.GetAbility(hero, 11)
//     SendAbilityEventToServer(ability, hero)
// }
// function CastAbility12():void
// {
//     let player = Players.GetLocalPlayer()
//     let hero = Players.GetPlayerHeroEntityIndex(player)
//     let ability = Entities.GetAbility(hero, 12)
//     SendAbilityEventToServer(ability, hero)
// }


// function SendAbilityEventToServer(ability: AbilityEntityIndex,hero: EntityIndex) {
//     if (Abilities.GetBehavior(ability) <= DOTA_ABILITY_BEHAVIOR.DOTA_ABILITY_BEHAVIOR_DONT_CANCEL_CHANNEL) {
//       Abilities.ExecuteAbility(ability, hero, false )
//     } else {
//       if (Abilities.AbilityReady(ability) == -1) {
//         // VectorTargetStart(ability)矢量技能的拖行效果
//       } else {
//         Abilities.ExecuteAbility(ability, hero, false )
//       }
//     }
//   }

// (
//     function(){
//         Game.AddCommand("CastSpell0", CastAbility0, "", 0)
//         Game.AddCommand("CastSpell1", CastAbility1, "", 0)
//         Game.AddCommand("CastSpell2", CastAbility2, "", 0)
//         Game.AddCommand("CastSpell3", CastAbility3, "", 0)
//         Game.AddCommand("CastSpell4", CastAbility4, "", 0)
//         Game.AddCommand("CastSpell5", CastAbility5, "", 0)
//         Game.AddCommand("CastSpell6", CastAbility6, "", 0)
//         Game.AddCommand("CastSpell7", CastAbility7, "", 0)
//         Game.AddCommand("CastSpell8", CastAbility8, "", 0)
//         Game.AddCommand("CastSpell9", CastAbility9, "", 0)
//         Game.AddCommand("CastSpell10", CastAbility10, "", 0)
//         Game.AddCommand("CastSpell11", CastAbility11, "", 0)
//         Game.AddCommand("CastSpell12", CastAbility12, "", 0)
//         //Game.AddCommand("CastSpelltp", CastAbility12, "", 0)
//     }
// )();

// function KeysBinding(){
//     return (
//         <Panel>
//         </Panel>
//     );
// }

// render(<KeysBinding />, $.GetContextPanel()); 
// function AbilitiesPanel(){
//     return (
//         <Panel>
//             {/* <DOTAAbilityImage abilityname="phantom_assassin_stifling_dagger" showtooltip={true} onactivate={CastAbility0}></DOTAAbilityImage> */}
//         </Panel>
//     );
// }

// render(<AbilitiesPanel />, $.GetContextPanel()); 