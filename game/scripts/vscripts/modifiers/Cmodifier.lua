--自定义事件
CMODIFIER_EVENT_ON_ATTACK_CRIT = "C_OnAttackCrit"--攻击暴击
CMODIFIER_EVENT_ON_ATTACK_NOTCRIT = "C_OnAttackNotCrit"--攻击未暴击
CMODIFIER_EVENT_ON_SPELL_CRIT = "C_OnSpellCrit"--技能暴击
CMODIFIER_EVENT_ON_SPELL_NOTCRIT = "C_OnSpellNotCrit"--技能未暴击
CMODIFIER_EVENT_ON_HEAL = "C_OnHeal"--主动输出治疗
CMODIFIER_EVENT_ON_HEALED = "C_OnHealed"--被动承受治疗
CMODIFIER_EVENT_ON_COMBAT_START = "C_OnCombatStart"--进入战斗
CMODIFIER_EVENT_ON_COMBAT_END = "C_OnCombatEnd"--离开战斗
CMODIFIER_EVENT_ON_INTERACTIVE = "C_OnInterActive"--右键交互事件
CMODIFIER_EVENT_ON_PASSENGER_GETON = "C_OnPassengerGetOn"--乘客登上载具
--自定义属性函数
--暴击
CMODIFIER_PROPERTY_BONUS_PHYSICAL_CRIT_CHANCE_CONSTANT = "C_GetModifierBonusPhysicalCritChance_Constant"--物理暴击几率加算
CMODIFIER_PROPERTY_BONUS_MAGICAL_CRIT_CHANCE_CONSTANT = "C_GetModifierBonusMagicalCritChance_Constant"--魔法暴击几率加算
CMODIFIER_PROPERTY_BONUS_PHYSICAL_CRIT_CHANCE_PERCENT = "C_GetModifierBonusPhysicalCritChance_Percent"--物理暴击几率乘算
CMODIFIER_PROPERTY_BONUS_MAGICAL_CRIT_CHANCE_PERCENT = "C_GetModifierBonusMagicalCritChance_Percent"--魔法暴击几率乘算
CMODIFIER_PROPERTY_BONUS_PHYSICAL_CRIT_CHANCE_TOTAL_PERCENT = "C_GetModifierBonusPhysicalCritChance_Total_Percent"--物理暴击几率总乘算
CMODIFIER_PROPERTY_BONUS_MAGICAL_CRIT_CHANCE_TOTAL_PERCENT = "C_GetModifierBonusMagicalCritChance_Total_Percent"--魔法暴击几率总乘算

CMODIFIER_PROPERTY_BONUS_PHYSICAL_CRIT_DAMAGE_CONSTANT = "C_GetModifierBonusPhysicalCritDamage_Constant"--物理暴击伤害加算
CMODIFIER_PROPERTY_BONUS_MAGICAL_CRIT_DAMAGE_CONSTANT = "C_GetModifierBonusMagicalCritDamage_Constant"--魔法暴击伤害加算
CMODIFIER_PROPERTY_BONUS_PHYSICAL_CRIT_DAMAGE_PERCENT = "C_GetModifierBonusPhysicalCritDamage_Percent"--物理暴击伤害乘算
CMODIFIER_PROPERTY_BONUS_MAGICAL_CRIT_DAMAGE_PERCENT = "C_GetModifierBonusMagicalCritDamage_Percent"--魔法暴击伤害乘算
--攻击间隔
CMODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT = "C_GetModifierBaseAttackTime_Constant"--基础攻击间隔
--法术强度
CMODIFIER_PROPERTY_SPELL_POWER_CONSTANT = "C_GetModifierSpellPower_Constant"--法术强度加算
CMODIFIER_PROPERTY_SPELL_POWER_PERCENT = "C_GetModifierSpellPower_Percent"--法术强度乘算
--格挡
CMODIFIER_PROPERTY_BLOCK_CHANCE_CONSTANT = "C_GetModifierBlockChance_Constant"--格挡几率加算
CMODIFIER_PROPERTY_BLOCK_CHANCE_PERCENT = "C_GetModifierBlockChance_Percent"--格挡几率乘算
CMODIFIER_PROPERTY_BLOCK_PERCENT_CONSTANT = "C_GetModifierBlockPercent_Constant"--格挡伤害加算
CMODIFIER_PROPERTY_BLOCK_PERCENT_PERCENT = "C_GetModifierBlockPercent_Percent"--格挡伤害乘算
--物理护甲
CMODIFIER_PROPERTY_PHYSICAL_ARMOR_CONSTANT = "C_GetModifierPhysicalArmor_Constant"--物理护甲加算
CMODIFIER_PROPERTY_PHYSICAL_ARMOR_PERCENT = "C_GetModifierPhysicalArmor_Percent"--物理护甲乘算
--魔法护甲
CMODIFIER_PROPERTY_MAGICAL_ARMOR_CONSTANT = "C_GetModifierMagicalArmor_Constant"--魔法护甲加算
CMODIFIER_PROPERTY_MAGICAL_ARMOR_PERCENT = "C_GetModifierMagicalArmor_Percent"--魔法护甲乘算
--护盾血量
CMODIFIER_PROPERTY_SHIELD_HP_CONSTANT = "C_GetModifierShieldHp_Constant"--护盾血量加算
CMODIFIER_PROPERTY_SHIELD_BLOCK_CONSTANT = "C_GetModifierShieldBlock_Constant"  --护盾格挡定值伤害
--三维
CMODIFIER_PROPERTY_STRENGTH_CONSTANT = "C_GetModifierStrength_Constant" --力量点数
CMODIFIER_PROPERTY_STRENGTH_PERCENT = "C_GetModifierStrength_Percent" --力量百分比
CMODIFIER_PROPERTY_AGILITY_CONSTANT = "C_GetModifierAgility_Constant" --敏捷点数
CMODIFIER_PROPERTY_AGILITY_PERCENT = "C_GetModifierAgility_Percent" --敏捷百分比
CMODIFIER_PROPERTY_INTELLECT_CONSTANT = "C_GetModifierIntellect_Constant" --智力点数
CMODIFIER_PROPERTY_INTELLECT_PERCENT = "C_GetModifierIntellect_Percent" --智力百分比


--自定义属性
STRENGTH = "STRENGTH"--力量
AGILITY = "AGILITY"--敏捷
INTELLECT = "INTELLECT"--智力
BONUS_PHYSICAL_CRIT_CHANCE = "BONUS_PHYSICAL_CRIT_CHANCE"--物理暴击几率
BONUS_MAGICAL_CRIT_CHANCE = "BONUS_MAGICAL_CRIT_CHANCE"--魔法暴击几率
BONUS_PHYSICAL_CRIT_DAMAGE = "BONUS_PHYSICAL_CRIT_DAMAGE"--物理暴击伤害
BONUS_MAGICAL_CRIT_DAMAGE = "BONUS_MAGICAL_CRIT_DAMAGE"--魔法暴击伤害
BASE_ATTACK_TIME = "BASE_ATTACK_TIME"--攻击间隔，会取最长的
SPELL_POWER = "SPELL_POWER"--法术强度
BLOCK_CHANCE = "BLOCK_CHANCE"--格挡几率
BLOCK_PERCENT = "BLOCK_PERCENT"--格挡伤害
PHYSICAL_ARMOR = "PHYSICAL_ARMOR"--物理护甲
MAGICAL_ARMOR = "MAGICAL_ARMOR"--魔法护甲
SHIELD_HP = "SHIELD_HP"--护盾血量


if IsServer() then
    function CFireModifierEvent(hUnit, iEvent, params)
        local buffs = hUnit:FindAllModifiers()
        for _, buff in pairs(buffs) do
            if buff[iEvent] ~= nil and type(buff[iEvent]) == "function" then
                buff[iEvent](buff, params)
            end
        end
    end
    function CDOTA_Modifier_Lua:CheckUseOrb(iRecord)
        if self.records == nil then
            self.records = {}
        end
        for index = 1, #self.records do
            if self.records[index].iRecord == iRecord and self.records[index].bOrb == true then
                return true
            end
        end
        return false
    end

    function CDOTA_Modifier_Lua:RemoveRecord(iRecord)
        if self.records == nil then
            self.records = {}
        end
        for index = 1, #self.records do
            if self.records[index].iRecord == iRecord then
                table.remove(self.records, index)
                break
            end
        end
    end

end

function CDOTA_Buff:GetAbilitySpecialValueFor( sKey )
    if self:GetAbility() ~= nil and not self:GetAbility():IsNull() then
        return self:GetAbility():GetSpecialValueFor(sKey) or 0
    else
        return 0
    end
end

