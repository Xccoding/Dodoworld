import React, { useRef, useState } from 'react';
import { useGameEvent } from '@demon673/react-panorama';
import ReactUtils from "../../utils/React_utils";
import { band, FormatString, GetAbilityChargeRestoreTimeRemaining, GetAbilityCurrentCharges, GetAbilityMaxCharges, GetAbilityValueFromClient, GetAbilityValueFromKV, GetUnitAttribute, print } from '../Utils';

const DOTA_ITEM_SLOT_MIN = 7;
const DOTA_ITEM_SLOT_MAX = 12;
const CUSTOM_ABILITY_SLOT_MIN = 7;
const CUSTOM_ABILITY_SLOT_MAX = 30;
const CUSTOM_ABILITY_SLOT_PASSIVE_MIN = 19;

const KeyMap = new Map(
    [
        ["`", "Backquote"],
        ["-", "Minus"],
        ["=", "Equal"],
        ["\\", "Backslash"],
        [";", "Semicolon"],
        [",", "Comma"],
        [".", "Period"],
        ["/", "Slash"],
        ["RETURN", "Enter"],
    ]
);


function AbilityTargetFilter(ability: AbilityEntityIndex, target: EntityIndex) {
    let FlagPass = true;
    let TypePass = false;
    let TeamPass = false;
    const Teams = Abilities.GetAbilityTargetTeam(ability);
    const Types = Abilities.GetAbilityTargetType(ability);
    const Flags = Abilities.GetAbilityTargetFlags(ability);

    // 队伍部分
    if (band(Teams, DOTA_UNIT_TARGET_TEAM.DOTA_UNIT_TARGET_TEAM_ENEMY) && Entities.IsEnemy(target)) {
        TeamPass = true;
    }
    else if (band(Teams, DOTA_UNIT_TARGET_TEAM.DOTA_UNIT_TARGET_TEAM_FRIENDLY) && !Entities.IsEnemy(target)) {
        TeamPass = true;
    }
    else if (band(Teams, DOTA_UNIT_TARGET_TEAM.DOTA_UNIT_TARGET_TEAM_BOTH)) {
        TeamPass = true;
    }

    // 类型部分
    if (band(Types, DOTA_UNIT_TARGET_TYPE.DOTA_UNIT_TARGET_BASIC) && !Entities.IsConsideredHero(target)) {
        TypePass = true;
    }
    else if (band(Types, DOTA_UNIT_TARGET_TYPE.DOTA_UNIT_TARGET_BUILDING) && Entities.IsBuilding(target)) {
        TypePass = true;
    }
    else if (band(Types, DOTA_UNIT_TARGET_TYPE.DOTA_UNIT_TARGET_HERO) && Entities.IsConsideredHero(target)) {
        TypePass = true;
    }
    else if (band(Types, DOTA_UNIT_TARGET_TYPE.DOTA_UNIT_TARGET_COURIER) && Entities.IsCourier(target)) {
        TypePass = true;
    }
    else if (band(Types, DOTA_UNIT_TARGET_TYPE.DOTA_UNIT_TARGET_CREEP) && Entities.IsCreep(target)) {
        TypePass = true;
    }
    else if (band(Types, DOTA_UNIT_TARGET_TYPE.DOTA_UNIT_TARGET_ALL)) {
        TypePass = true;
    }

    // flag部分
    if (!band(Flags, DOTA_UNIT_TARGET_FLAGS.DOTA_UNIT_TARGET_FLAG_INVULNERABLE) && Entities.IsInvulnerable(target)) {
        FlagPass = false;
    }
    if (!band(Flags, DOTA_UNIT_TARGET_FLAGS.DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES) && Entities.IsMagicImmune(target) && Entities.IsEnemy(target)) {
        FlagPass = false;
    }
    if (band(Flags, DOTA_UNIT_TARGET_FLAGS.DOTA_UNIT_TARGET_FLAG_NOT_MAGIC_IMMUNE_ALLIES) && Entities.IsMagicImmune(target) && !Entities.IsEnemy(target)) {
        FlagPass = false;
    }
    if (band(Flags, DOTA_UNIT_TARGET_FLAGS.DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE) && Entities.IsAttackImmune(target)) {
        FlagPass = false;
    }
    if (band(Flags, DOTA_UNIT_TARGET_FLAGS.DOTA_UNIT_TARGET_FLAG_MANA_ONLY) && Entities.GetMaxMana(target) <= 0) {
        FlagPass = false;
    }
    if (band(Flags, DOTA_UNIT_TARGET_FLAGS.DOTA_UNIT_TARGET_FLAG_NOT_ANCIENTS) && Entities.IsAncient(target)) {
        FlagPass = false;
    }
    if (band(Flags, DOTA_UNIT_TARGET_FLAGS.DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS) && Entities.IsIllusion(target)) {
        FlagPass = false;
    }
    if (band(Flags, DOTA_UNIT_TARGET_FLAGS.DOTA_UNIT_TARGET_FLAG_NOT_NIGHTMARED) && Entities.IsNightmared(target)) {
        FlagPass = false;
    }
    if (band(Flags, DOTA_UNIT_TARGET_FLAGS.DOTA_UNIT_TARGET_FLAG_NOT_NIGHTMARED) && Entities.IsNightmared(target)) {
        FlagPass = false;
    }
    if (band(Flags, DOTA_UNIT_TARGET_FLAGS.DOTA_UNIT_TARGET_FLAG_NOT_SUMMONED) && Entities.IsSummoned(target)) {
        FlagPass = false;
    }

    if (GetAbilityValueFromClient(ability, "CastFilterRejectCaster") == "1"){
        if (target == Abilities.GetCaster(ability)){
            return false
        }
    }

    return FlagPass && TeamPass && TypePass;
}

interface CastBar extends Panel {
    ability: AbilityEntityIndex,
    startTime: number,
    duration: number,
    castType: string,
}

export function AbilityBar() {
    const [AbiltyList, SetAbiltyList] = useState<AbilityEntityIndex[]>([]);
    let ActiveAbility = Abilities.GetLocalPlayerActiveAbility();
    const refCastBar = useRef<CastBar>(null);

    ReactUtils.useSchedule(() => {
        let abilities = [];
        let player = Players.GetLocalPlayer();
        let hero = Players.GetPlayerHeroEntityIndex(player);

        for (let index = CUSTOM_ABILITY_SLOT_MIN; index <= CUSTOM_ABILITY_SLOT_MAX; index++) {
            let ability = Entities.GetAbility(hero, index);
            if (!Abilities.IsHidden(ability)) {
                abilities.push(ability);
            }
        }

        if (GameUI.CustomUIConfig().HudRoot != undefined) {
            let OrdersContainer = GameUI.CustomUIConfig().HudRoot.FindChildTraverse("OrdersContainer");
            if (OrdersContainer != undefined) {
                if (!OrdersContainer.BHasClass("Hidden")) {
                    OrdersContainer.AddClass("Hidden");
                }
            }
        }

        SetAbiltyList(abilities);


        return Math.max(1 / 30, Game.GetGameFrameTime());
    }, []);

    useGameEvent("AbilityStart", (event: any) => {

        if (refCastBar.current != undefined) {
            refCastBar.current.ability = event.ability;
            refCastBar.current.startTime = Game.GetGameTime();
            refCastBar.current.duration = event.duration;
            refCastBar.current.castType = event.casttype;
        }

    });

    useGameEvent("AbilityEnd", () => {
        if (refCastBar.current != undefined) {
            refCastBar.current.ability = -1 as AbilityEntityIndex;
            refCastBar.current.castType = "";
        }
    });

    let fCastPercent = -1;
    let TextureName = "";
    if (refCastBar.current != undefined) {
        if (refCastBar.current.ability != -1 && refCastBar.current.ability != undefined) {
            if (refCastBar.current.startTime != undefined && refCastBar.current.duration != undefined) {
                fCastPercent = (Game.GetGameTime() - refCastBar.current.startTime) / refCastBar.current.duration;
            }
            TextureName = "s2r://panorama/images/spellicons/" + Abilities.GetAbilityTextureName(refCastBar.current.ability) + "_png.vtex";
        }

    }

    return <Panel id='AbilityPanel_main' hittest={false}>
        <Panel id='AbilityPanel_CastBar' className={(refCastBar.current != undefined && refCastBar.current.ability != -1 && refCastBar.current.ability != undefined) ? "Show" : ""} ref={refCastBar}>
            {
                refCastBar.current != undefined && fCastPercent != -1 && refCastBar.current.ability != -1 && refCastBar.current.startTime != undefined && refCastBar.current.duration != undefined ?

                    <Panel id='CastBar_progress'>
                        <Image id='CastBar_progress_ability_img' src={TextureName} scaling="stretch-to-cover-preserve-aspect"></Image>
                        <Panel id='CastBar_progress_main'>
                            <Panel id='CastBar_left' style={{ width: `${refCastBar.current.castType == "phase" ? fCastPercent * 100 : (100 - fCastPercent * 100)}%` }}></Panel>
                            <Panel id='CastBar_right' style={{ width: `${refCastBar.current.castType == "phase" ? 100 - fCastPercent * 100 : fCastPercent * 100}%` }}></Panel>
                            <Label id='CastBar_ability_name' text={$.Localize(`#DOTA_Tooltip_ability_${Abilities.GetAbilityName(refCastBar.current.ability)}`)}></Label>
                            <Label id='CastBar_time' text={`${(refCastBar.current.castType == "phase" ? Game.GetGameTime() - refCastBar.current.startTime : (refCastBar.current.duration - (Game.GetGameTime() - refCastBar.current.startTime))).toFixed(1)} / ${refCastBar.current.duration.toFixed(1)}`}></Label>
                        </Panel>
                    </Panel>
                    :
                    <></>
            }
        </Panel>
        <Panel id='AbilityPanel_bar'>
            {
                AbiltyList.map((ability, index) => {
                    return <AbilityPanel key={index} ability={ability} bActive={ActiveAbility == ability} slotindex={index + 7} />;
                })
            }
        </Panel>
    </Panel>;
}

function AbilityPanel({ ability, bActive, slotindex }: { ability: AbilityEntityIndex, bActive: boolean, slotindex: number; }) {
    let ability_name = Abilities.GetAbilityName(ability);
    let Level = Abilities.GetLevel(ability);
    let player = Players.GetLocalPlayer();
    let hero = Players.GetPlayerHeroEntityIndex(player);
    let cooldown = Math.max(0.01, Abilities.GetCooldownLength(ability));
    let CooldownReduction = GetUnitAttribute("cooldown_reduction", hero);
    let cd_remain = Abilities.GetCooldownTimeRemaining(ability);
    let cooldownText = cd_remain;
    let TextureName = "s2r://panorama/images/spellicons/" + Abilities.GetAbilityTextureName(ability) + "_png.vtex";

    let MaxCharge = GetAbilityMaxCharges(ability, hero)
    let CurrentCharge = GetAbilityCurrentCharges(ability, hero);
    let ChargeRestoreTime = Math.max(GetAbilityValueFromKV(ability_name, Level, "AbilityChargeRestoreTime") * (100 - CooldownReduction) * 0.01, 0.01);
    let ChargeRemainTime = GetAbilityChargeRestoreTimeRemaining(ability, hero);
    let ManaCost = Abilities.GetManaCost(ability);
    let bPassive = Abilities.IsPassive(ability);
    let Hotkey = "";
    let key = "";

    if (slotindex > DOTA_ITEM_SLOT_MAX) {
        key = Game.GetKeybindForInventorySlot(slotindex - DOTA_ITEM_SLOT_MAX - 1);
    }
    else {
        let hotkey_ability = Entities.GetAbility(Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer()), slotindex - (DOTA_ITEM_SLOT_MAX - DOTA_ITEM_SLOT_MIN + 2));
        key = Abilities.GetKeybind(hotkey_ability);
    }

    // 技能状态的flag
    let bIsCooldownReady: boolean = (cd_remain <= 0);
    let bOutofCharge: boolean = (MaxCharge > 0 && CurrentCharge <= 0 && Level > 0);
    let bManaEnough: boolean = (Entities.GetMana(hero) >= ManaCost);
    let bSilenced: boolean = Entities.IsSilenced(hero);
    let bToggleActived: boolean = Abilities.IsToggle(ability) && Abilities.GetToggleState(ability);

    if ((key != "" || key != Hotkey) && slotindex < CUSTOM_ABILITY_SLOT_PASSIVE_MIN) {
        Hotkey = key;
        key = KeyMap.get(key) || key;

        $.RegisterKeyBind("", "key_" + key, (source, presses, panel) => {
            let IsTyping = GameUI.CustomUIConfig().HudRoot.FindChildTraverse("HUDElements")?.FindChildTraverse("HudChat")?.BHasClass("Active");
            if (!IsTyping && !bPassive) {
                if (Level <= 0) {
                    GameUI.SendCustomHUDError($.Localize("#AbilityCastError_NotLearned"), "General.CastFail_AbilityNotLearned");
                }
                else if (bSilenced) {
                    GameUI.SendCustomHUDError($.Localize("#AbilityCastError_Silenced"), "General.CastFail_Silenced");
                }
                else if (!bIsCooldownReady && !(Abilities.IsToggle(ability) && Abilities.GetToggleState(ability))) {
                    GameUI.SendCustomHUDError($.Localize("#AbilityCastError_Cooldown"), "General.CastFail_AbilityInCooldown");
                }
                else if (bOutofCharge) {
                    GameUI.SendCustomHUDError($.Localize("#AbilityCastError_NoCharge"), "General.CastFail_NoCharges");
                }
                else if (!bManaEnough && !(Abilities.IsToggle(ability) && Abilities.GetToggleState(ability))) {
                    GameUI.SendCustomHUDError($.Localize("#AbilityCastError_NoMana"), "General.CastFail_NoMana");
                }
                else if(band(Abilities.GetBehavior(ability), DOTA_ABILITY_BEHAVIOR.DOTA_ABILITY_BEHAVIOR_ROOT_DISABLES) && Entities.IsRooted(hero))
                {
                    GameUI.SendCustomHUDError($.Localize("#AbilityCastError_Rooted"), "General.CastFail_AbilityDisabledByRoot");
                }
                else {
                    let cursor_pos = GameUI.GetCursorPosition();
                    let world_pos = Game.ScreenXYToWorld(cursor_pos[0], cursor_pos[1]);
                    let cursor_target;
                    let hover_group = GameUI.FindScreenEntities(cursor_pos);
                    let canCast = true;

                    if (band(Abilities.GetBehavior(ability), DOTA_ABILITY_BEHAVIOR.DOTA_ABILITY_BEHAVIOR_UNIT_TARGET)) {
                        if (hover_group.length > 0) {
                            for (let index = 0; index < hover_group.length; index++) {
                                const target = hover_group[index].entityIndex;

                                if (AbilityTargetFilter(ability, target)) {
                                    cursor_target = target;
                                    break;
                                }
                            }
                        }
                        else {
                            canCast = false;
                            GameUI.SendCustomHUDError($.Localize("#AbilityCastError_NoTarget"), "General.CastFail_InvalidTarget_Other");
                        }
                        if (cursor_target != undefined) {
                        }
                        else {
                            if (band(Abilities.GetBehavior(ability), DOTA_ABILITY_BEHAVIOR.DOTA_ABILITY_BEHAVIOR_POINT)) {
                            }
                            else {
                                if (hover_group.length > 0) {
                                    GameUI.SendCustomHUDError($.Localize("#AbilityCastError_InvalidTarget"), "General.CastFail_InvalidTarget_Other");
                                    canCast = false;
                                }

                            }

                        }
                    }

                    if (canCast) {
                        GameEvents.SendCustomGameEventToServer("Custom_Cast_Ability", { ability: ability, cursor_pos: { x: world_pos[0], y: world_pos[1], z: world_pos[2] }, cursor_target: cursor_target });
                    }
                }
            }

        });
    }

    // 显示处理
    if (MaxCharge > 0 && CurrentCharge <= 0) {
        cooldownText = Math.max(cd_remain, ChargeRemainTime);
    }
    if (cooldownText >= 1) {
        cooldownText = Number(cooldownText.toFixed(0));
    }
    else {
        cooldownText = Number(cooldownText.toFixed(1));
    }

    return <Panel id='AbilityPanel' hittest={true} onactivate={() => {
        if (ability != -1) {
            if (GameUI.IsAltDown()) {
                Abilities.PingAbility(ability);
            }
            else {
                if (bOutofCharge) {
                    GameUI.SendCustomHUDError($.Localize("#AbilityCastError_NoCharge"), "General.CastFail_NoCharges");
                }
                else {
                    Abilities.ExecuteAbility(ability, Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer()), false);
                }

            }
        }
    }} onmouseover={(p) => {
        if (ability != -1) {
            $.DispatchEvent(
                "UIShowCustomLayoutParametersTooltip",
                p,
                "CustomAbilityToolTip",
                `file://{resources}/layout/custom_game/hud/Tooltips/CustomAbilityToolTip.xml`,
                FormatString({ ability: String(ability), forHero: "1" })
            );
        }

    }} onmouseout={(p) => {
        if (ability != -1) {
            $.DispatchEvent("UIHideCustomLayoutTooltip", p, "CustomAbilityToolTip");
        }
    }
    }>
        <Panel id='AbilityButton' className={`${!bManaEnough ? "NoMana" : ""} ${(!bIsCooldownReady || bOutofCharge) ? "NoChargeorCooldown" : ""} ${Level <= 0 ? "NotLearned" : ""}`}>
            {/* <DOTAAbilityImage id='AbilityPanel_image' abilityname={ability_name} showtooltip={false} /> */}
            <Image id='AbilityPanel_image' src={TextureName} scaling="stretch-to-cover-preserve-aspect"></Image>
            <Panel id="AbilityPanel_Charge" hittest={false} className={`${MaxCharge > 0 && CurrentCharge < MaxCharge && Level > 0 ? "Show" : ""}`} >
                <Panel id="AbilityPanel_Charge_pointer" style={{ clip: `radial(50.0% 50.0%, ${-360 * (ChargeRemainTime / ChargeRestoreTime)}deg, 15deg` }} />
            </Panel>
            <Panel id="AbilityPanel_Cooldown" hittest={false} className={(!bIsCooldownReady || bOutofCharge) ? "Show" : ""}>
                <Panel id="AbilityPanel_CooldownOverlay" hittest={false} style={{ clip: "radial(50.0% 50.0%, 0.0deg, " + -360 * cd_remain / cooldown + "deg)" }} />
                <Label id="AbilityPanel_CooldownTimer" className="MonoNumbersFont" text={cooldownText} hittest={false} />
            </Panel>
            <Panel id='AbilityPanel_ToggleActived' hittest={false} className={bToggleActived ? "Show" : ""} />
            <Panel id='AbilityPanel_Passive' hittest={false} className={bPassive ? "Show" : ""} />
            <Panel id='AbilityPanel_Silenced' hittest={false} className={bSilenced ? "Show" : ""} />
        </Panel>
        <Label id='Current_Charge' className={MaxCharge > 0 ? "Show" : ""} text={CurrentCharge} />
        <Label id='HotKey' text={Hotkey} />
    </Panel>;
}

// render(<AbilityBar />, $.GetContextPanel());