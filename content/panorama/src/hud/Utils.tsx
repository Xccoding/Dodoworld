import { useGameEvent } from "@demon673/react-panorama";
import { useState } from "react";

export function Clamp(num: number, min: number, max: number) {
	return num <= min ? min : (num >= max ? max : num);
}
export function RGBToHex(rgba: string) {
	let str = rgba.slice(5, rgba.length - 1),
		arry = str.split(','),
		opa = Math.ceil(Math.max(2, Number(arry[3].trim()) * 30) + 210),
		strHex = "#",
		r = Number(arry[0].trim()),
		g = Number(arry[1].trim()),
		b = Number(arry[2].trim());

	strHex += ((1 << 24) + (r << 16) + (g << 8) + b).toString(16).slice(1);
	strHex += opa.toString(16).slice(0, 2);

	return strHex;
}

export function print(...args: any[]) {
	if (!Game.IsInToolsMode()) {
		return;
	}
	let s = "";
	let a = [...args];
	a.forEach(e => {
		if (s != "") {
			s += "\t";
		}
		if (typeof (e) == "object") {
			s = s + JSON.stringify(e);
		} else {
			s = s + String(e);
		}
	});
	$.Msg(s);
}

export function InCombat(hero_index: EntityIndex) {
	const iBuffCount = Entities.GetNumBuffs(hero_index);

	for (let index = 0; index < iBuffCount; index++) {
		if (Buffs.GetName(hero_index, Entities.GetBuff(hero_index, index)) == "modifier_combat") {
			return true;
		}
	}
	return false;
}

export function FindModifierByName(unit_index: EntityIndex, buff_name: string) {
	const iBuffCount = Entities.GetNumBuffs(unit_index);

	for (let index = 0; index < iBuffCount; index++) {
		if (Buffs.GetName(unit_index, Entities.GetBuff(unit_index, index)) == buff_name) {
			return Entities.GetBuff(unit_index, index);
		}
	}
	return -1 as BuffID;
}

export function band(a: number, b: number): boolean {
	return (a & b) == b;
}

export function FormatString(data: { [x: string]: string; }) {
	var retStr = "";
	for (var key in data) {
		if (data[key]) {
			retStr += key + "=" + data[key] + "&";
		}
	}
	return retStr;
}

export function replaceAll(s1: string, s2: string, s3: string) {
	return s1.replace(new RegExp(s2, "gm"), s3);
}

export function GetUnitAttribute(attrName: string, unit?: EntityIndex) {
	if (unit != undefined) {
		let i = FindModifierByName(unit, "modifier_hero_attribute");
		let t = Buffs.GetTexture(unit, i);

		if (t == "") {
			return 0;
		}
		if (JSON.parse(t) != undefined && JSON.parse(t)[attrName] != undefined) {
			let value = JSON.parse(t)[attrName];
			return Number(JSON.parse(t)[attrName]);
		}
		else {
			return 0;
		}
	}
	else {
		return 0;
	}

}

export function GetAbilityValueFromClient(ability: AbilityEntityIndex, key_name: string) {
	GameEvents.SendEventClientSide("GetAbilityValue", { ability: ability, key_name: key_name });
	let getter_ability = Entities.GetAbilityByName(Abilities.GetCaster(ability), "common_AbilityDataGetter");
	let value = Abilities.GetAbilityTextureName(getter_ability);
	return value;
}

export function IsPassive(ability_name: string) {
	let behavior = GetAbilityValueFromKV(ability_name, 1, "AbilityBehavior") as string;

	return (behavior.indexOf("DOTA_ABILITY_BEHAVIOR_PASSIVE") != -1);
}

export function GetAbilityValueFromKV(ability_name: string, Level: number, key_name: string) {
	if (GameUI.CustomUIConfig().AbilityKv[ability_name] == undefined) {
		return 0;
	}

	if (Level < 1) {
		Level = 1;
	}

	const kv = GameUI.CustomUIConfig().AbilityKv[ability_name];
	if (kv != undefined) {
		let value = FindValueInObj(kv, key_name);
		if (value == undefined) {
			return 0;
		}
		else {
			let value_array = value.split(" ");
			if (value_array.length > 1) {
				return value_array[Level - 1];
			}
			else {
				return value_array[0];
			}

		}
	}
}

export function GetTalentValueFromKV(talent_name: string, key_name: string, hero: EntityIndex) {
	let TalentKv = GameUI.CustomUIConfig().TalentsKv;
	let playerID = Entities.GetPlayerOwnerID(hero);
	let Schools_selected = CustomNetTables.GetTableValue("hero_schools", playerID)?.schools_index || 0;

	for (const roleName in TalentKv) {
		const role = TalentKv[roleName];
		if (role[Schools_selected] != undefined) {
			if (role[Schools_selected][talent_name] != undefined) {
				const tKV = role[Schools_selected][talent_name];
				if (tKV.UpgradeAbilities != undefined) {
					for (const ability_name in tKV.UpgradeAbilities) {
						for (const upgrade_key in tKV.UpgradeAbilities[ability_name]) {
							if (upgrade_key == key_name) {
								return tKV.UpgradeAbilities[ability_name][upgrade_key].value;
							}
						}
					}
				}
				else {
					return 0;
				}
			}
		}
	}
	return 0;
}

export function FindValueInObj(t: any, key_name: string) {
	if (typeof (t) == "object") {
		for (const k in t) {
			if (k == key_name) {
				return t[k];
			}
			else {
				if (typeof (t[k]) == "object") {
					let x: any = FindValueInObj(t[k], key_name);
					if (x != undefined) {
						return x;
					}
					else {
						continue;
					}
				}
			}
		}
		return undefined;
	}
	else {
		return undefined;
	}
}

export function GetAbilityMaxCharges(ability: AbilityEntityIndex, unit: EntityIndex) {
	for (let index = 0; index < Entities.GetNumBuffs(unit); index++) {
		const modifier = Entities.GetBuff(unit, index);
		const buff_ability = Buffs.GetAbility(unit, modifier);
		if (buff_ability == ability && Buffs.GetName(unit, modifier) == "modifier_AbilityCharge") {
			return Number(Buffs.GetTexture(unit, modifier));
		}
	}
	return 0;
}

export function GetAbilityCurrentCharges(ability: AbilityEntityIndex, unit: EntityIndex) {
	for (let index = 0; index < Entities.GetNumBuffs(unit); index++) {
		const modifier = Entities.GetBuff(unit, index);
		const buff_ability = Buffs.GetAbility(unit, modifier);
		if (buff_ability == ability && Buffs.GetName(unit, modifier) == "modifier_AbilityCharge") {
			return Buffs.GetStackCount(unit, modifier);
		}
	}
	return 0;
}

export function GetAbilityChargeRestoreTimeRemaining(ability: AbilityEntityIndex, unit: EntityIndex) {
	if (ability == (-1 as AbilityEntityIndex)) {
		return 0;
	}
	for (let index = 0; index < Entities.GetNumBuffs(unit); index++) {
		const modifier = Entities.GetBuff(unit, index);
		const buff_ability = Buffs.GetAbility(unit, modifier);
		if (buff_ability == ability && Buffs.GetName(unit, modifier) == "modifier_AbilityCharge") {
			return Buffs.GetRemainingTime(unit, modifier);
		}
	}

	return 0;
}


export function useToggleHud(hud_name: string): [boolean, (arg0?: boolean) => void] {
	const [State, SetState] = useState(false);

	useGameEvent("CustomToggleHud", (event) => {
		if (hud_name == event.hud_name) {
			if (event.wish_state != undefined) {
				SetState(event.wish_state == 1);
			}
			else {
				SetState((old_state) => !old_state);
			}
		}
		else {
			if (event.wish_state != undefined) {
				SetState(event.wish_state == 1);
			}
			else {
				SetState(false);
			}

		}

	}, []);

	return [State, (wish_state?: boolean) => {
		GameEvents.SendEventClientSide("CustomToggleHud", { hud_name: hud_name, wish_state: wish_state });
	}];

}


