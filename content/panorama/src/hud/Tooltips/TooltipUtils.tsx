import { GetAbilityValueFromClient, GetAbilityValueFromKV, GetTalentValueFromKV, GetUnitAttribute, print, replaceAll } from "../Utils";

const ValueCalculate = {
    ["ap_factor"]: {
        attrName: "attack_damage"
    },
    ["sp_factor"]: {
        attrName: "spell_power"
    },
    ["int_factor"]: {
        attrName: "intellect"
    },
    ["str_factor"]: {
        attrName: "strength"
    },
    ["agi_factor"]: {
        attrName: "agility"
    },
    ["max_hp_factor"]: {
        attrName: "max_health",
        func: Entities.GetMaxHealth
    },
    ["max_mana_factor"]: {
        attrName: "max_mana",
        func: Entities.GetMaxMana
    },
};

export function FormatDesc(desc: string, bAltDown: boolean, ability_name: string, type: string, hero: EntityIndex, ability: AbilityEntityIndex, level?: number) {
    let abilityName = ability_name;
    level = level || 0;
    let match_array = desc.match(/\%[a-zA-Z_0-9]+\%/g);

    if (match_array != null) {
        for (const key_string of match_array) {
            let key_name = replaceAll(key_string, "%", "");
            let value = 0;
            let bReplaced = false;
            if (type == "ability") {
                if (ability != -1) {
                    value = Number(GetAbilityValueFromClient(ability, key_name));
                }
                else {
                    value = Number(GetAbilityValueFromKV(abilityName, level, key_name));
                }
            }
            else if (type == "talent") {
                value = Number(GetTalentValueFromKV(ability_name, key_name, hero));
            }

            for (const k in ValueCalculate) {
                if (key_name.indexOf(k) != -1) {
                    if (bAltDown || (ability == -1 && type != "talent")) {
                        desc = desc.replace(key_string, "[" + String(value.toFixed(0)) + "%" + $.Localize("#Character_attribute_" + (ValueCalculate as any)[k].attrName) + "]");
                    }
                    else if (hero != undefined) {
                        let attrValue = 0;

                        if ((ValueCalculate as any)[k].attrName == "max_health") {
                            attrValue = Entities.GetMaxHealth(hero);
                        }
                        else if ((ValueCalculate as any)[k].attrName == "max_mana_factor") {
                            attrValue = Entities.GetMaxMana(hero);
                        }
                        else {
                            attrValue = GetUnitAttribute((ValueCalculate as any)[k].attrName, hero);
                        }

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
