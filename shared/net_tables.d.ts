declare interface CustomNetTableDeclarations {
    game_timer: {
        game_timer: {
            current_time: number;
            current_state: 1 | 2 | 3 | 4 | 5;
            current_round: number;
        };
    };
    hero_list: {
        hero_list: Record<string, string> | string[];
    };
    DHPS: {
        DHPS: {
            DPS: number;
            HPS: number;
        };
    };
    hero_schools: {
        [player_index: number]: {
            schools_index: number;
        };
    };
    hero_attributes: {
        [player_index: number]: {
            // base_attack_damage: number // 基础攻击力
            total_attack_damage: number; // 全额攻击力
            movespeed: number; // 移动速度
            physical_armor: number[]; // 护甲
            magical_armor: number[]; // 魔法抗性
            evasion: number; // 闪避
            attack_speed: number; // 攻击速度
            cooldown_reduction: number; // 冷却缩减
            spell_power: number; // 法术强度
            intellect: number; // 智力
            strength: number; // 力量
            agility: number; // 敏捷
            physical_crit_chance: number; // 物理暴击概率
            magical_crit_chance: number; // 魔法暴击概率
            physical_crit_damage: number; // 物理暴击倍率
            magical_crit_damage: number; // 魔法暴击倍率
            block: number[]; // 格挡
        };
    };
    channel_list: {
        [unit_index: number]: {
            channel_ability: AbilityEntityIndex; // 正在持续施法技能
            channel_percent: number; // 施法进度
        };
    };
    hero_items: {
        [player_index: number]: {
            item_type: string,
            item_list: {
                item_name: string,
                equip: number,
            }[];
        }[];
    };
    hero_talents: {
        [player_index: number]: number[];
    };
}