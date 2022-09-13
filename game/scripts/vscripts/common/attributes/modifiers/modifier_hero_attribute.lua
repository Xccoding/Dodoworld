--英雄属性modifiers
if modifier_hero_attribute == nil then
    modifier_hero_attribute = class({})
end
function modifier_hero_attribute:IsHidden()
    return true
end
function modifier_hero_attribute:IsDebuff()
    return false
end
function modifier_hero_attribute:IsPurgable()
    return false
end
function modifier_hero_attribute:RemoveOnDeath()
    return false
end
function modifier_hero_attribute:OnCreated(params)
    if IsServer() then
        self:StartIntervalThink(0.1)
        self:SetHasCustomTransmitterData(true)
    end
end
function modifier_hero_attribute:CDeclareFunctions()
    return {
        CMODIFIER_PROPERTY_AGILITY_CONSTANT,
        CMODIFIER_PROPERTY_STRENGTH_CONSTANT,
        CMODIFIER_PROPERTY_INTELLECT_CONSTANT,
        CMODIFIER_PROPERTY_SPELL_POWER_CONSTANT,
        CMODIFIER_PROPERTY_BONUS_MAGICAL_CRIT_CHANCE_CONSTANT,
        CMODIFIER_PROPERTY_BONUS_PHYSICAL_CRIT_CHANCE_CONSTANT,
        CMODIFIER_PROPERTY_PHYSICAL_ARMOR_CONSTANT,
        CMODIFIER_PROPERTY_MAGICAL_ARMOR_CONSTANT,
    }
end
function modifier_hero_attribute:DeclareFunctions()
    return {

        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
        MODIFIER_PROPERTY_MANA_BONUS,
        MODIFIER_PROPERTY_HEALTH_BONUS,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
        MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
        MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
    }
end
-- function modifier_hero_attribute:GetModifierPercentageCooldown()
--     return 50
-- end
function modifier_hero_attribute:OnIntervalThink()
    if IsServer() then
        local hCaster = self:GetCaster()

        local attr_new =        {
            -- base_attack_damage = math.floor((hCaster:GetBaseDamageMin() + hCaster:GetBaseDamageMax()) * 0.5),--基础攻击力
            attack_damage = math.floor(hCaster:GetAverageTrueAttackDamage(hCaster)), --全额攻击力
            movespeed = math.floor(hCaster:GetIdealSpeed()), --移动速度
            physical_armor = string.format("%.1f", hCaster:GetUnitAttribute(PHYSICAL_ARMOR, {}, MODIFIER_CALCULATE_TYPE_SUM)), --护甲
            physical_armor_value1 = hCaster:GetPhysicalDamageReduction(), --护甲减伤率
            magical_armor = string.format("%.1f", hCaster:GetUnitAttribute(MAGICAL_ARMOR, {}, MODIFIER_CALCULATE_TYPE_SUM)), --魔法护甲
            magical_armor_value1 = hCaster:GetMagicalDamageReduction(), --魔法护甲减伤率
            evasion = hCaster:GetEvasion(), --闪避
            attack_speed = hCaster:GetAttacksPerSecond(), --攻击速度(每秒攻击次数)
            cooldown_reduction = math.floor(100 - hCaster:GetCooldownReduction() * 100), --冷却缩减
            spell_power = math.floor(hCaster:GetUnitAttribute(SPELL_POWER, {}, MODIFIER_CALCULATE_TYPE_SUM)), --法术强度
            intellect = hCaster:GetIntellect(), --智力
            strength = hCaster:GetStrength(), --力量
            agility = hCaster:GetAgility(), --敏捷
            physical_crit_chance = hCaster:GetUnitAttribute(BONUS_PHYSICAL_CRIT_CHANCE, {}, MODIFIER_CALCULATE_TYPE_SUM), --物理暴击概率
            magical_crit_chance = hCaster:GetUnitAttribute(BONUS_MAGICAL_CRIT_CHANCE, {}, MODIFIER_CALCULATE_TYPE_SUM), --魔法暴击概率
            physical_crit_damage = 100 + CDOTA_BASE_CRIT_DAMAGE + hCaster:GetUnitAttribute(BONUS_PHYSICAL_CRIT_DAMAGE, {}, MODIFIER_CALCULATE_TYPE_SUM), --物理暴击倍率
            magical_crit_damage = 100 + CDOTA_BASE_CRIT_DAMAGE + hCaster:GetUnitAttribute(BONUS_MAGICAL_CRIT_DAMAGE, {}, MODIFIER_CALCULATE_TYPE_SUM), --魔法暴击倍率
            block = hCaster:GetUnitAttribute(BLOCK_CHANCE, {}, MODIFIER_CALCULATE_TYPE_SUM), --格挡率
            block_value1 = hCaster:GetUnitAttribute(BLOCK_PERCENT, {}, MODIFIER_CALCULATE_TYPE_SUM) --格挡减伤率
        }

        self.attributeString = json.encode(attr_new)
        self:SendBuffRefreshToClients()

    end
end
function modifier_hero_attribute:AddCustomTransmitterData()
    return {
        attributeString = self.attributeString
    }
end
function modifier_hero_attribute:HandleCustomTransmitterData(data)
    self.attributeString = data.attributeString
end
--力量
function modifier_hero_attribute:C_GetModifierStrength_Constant()
    local hParent = self:GetParent()
    local base = hParent:GetBaseStrength()
    local perlvl = hParent:GetStrengthGain()
    local level = hParent:GetLevel()
    return base + (level - 1) * perlvl
end
--敏捷
function modifier_hero_attribute:C_GetModifierAgility_Constant()
    local hParent = self:GetParent()
    local base = hParent:GetBaseAgility()
    local perlvl = hParent:GetAgilityGain()
    local level = hParent:GetLevel()
    return base + (level - 1) * perlvl
end
--智力
function modifier_hero_attribute:C_GetModifierIntellect_Constant()
    local hParent = self:GetParent()
    local base = hParent:GetBaseIntellect()
    local perlvl = hParent:GetIntellectGain()
    local level = hParent:GetLevel()
    return base + (level - 1) * perlvl
end
--额外生命值
function modifier_hero_attribute:GetModifierHealthBonus()
    local hParent = self:GetParent()
    local label = hParent:GetUnitLabel()
    if label ~= nil and CDOTA_ATTRIBUTE_LEVEL_HEALTH[hParent:GetUnitLabel()] ~= nil then
        local bonus_health = (CDOTA_ATTRIBUTE_LEVEL_HEALTH[label][1] + CDOTA_ATTRIBUTE_LEVEL_HEALTH[label][1] + (hParent:GetLevel() - 2) * CDOTA_ATTRIBUTE_LEVEL_HEALTH[label][2]) * (hParent:GetLevel() - 1) * 0.5
        return math.floor(bonus_health)
    end
    return hParent:GetLevel() * 100
end
--智力提供法术强度
function modifier_hero_attribute:C_GetModifierSpellPower_Constant(params)
    local hParent = self:GetParent()
    if hParent:GetPrimaryAttribute() == DOTA_ATTRIBUTE_INTELLECT then
        return self:GetParent():GetIntellect() * CDOTA_ATTRIBUTE_INTELLIGENCE_SPELL_POWER
    end
    return 0
end
--魔法恢复
function modifier_hero_attribute:GetModifierConstantManaRegen()
    local unit = self:GetParent()

    if not unit:IsUseMana() then
        return -self:GetParent():GetIntellect() * 0.05
    else
        return -self:GetParent():GetIntellect() * 0.05 + self:GetParent():GetIntellect() * CDOTA_ATTRIBUTE_INTELLIGENCE_MANA_REGEN
    end
end
--额外魔法值
function modifier_hero_attribute:GetModifierManaBonus()
    local unit = self:GetParent()

    if unit:IsUseMana() then
        local bonus_mana = (CDOTA_ATTRIBUTE_LEVEL_MANA_BASE_FACTOR + CDOTA_ATTRIBUTE_LEVEL_MANA_BASE_FACTOR + (unit:GetLevel() - 2) * CDOTA_ATTRIBUTE_LEVEL_MANA_INCREASE_FACTOR) * (unit:GetLevel() - 1) * 0.5
        return math.floor(bonus_mana)
    else
        return 0
    end
end
--魔法暴击
function modifier_hero_attribute:C_GetModifierBonusMagicalCritChance_Constant(params)
    return self:GetParent():GetIntellect() * CDOTA_ATTRIBUTE_INTELLIGENCE_MAGICAL_CRIT_CHANCE
end
--魔法护甲
function modifier_hero_attribute:C_GetModifierMagicalArmor_Constant(params)
    return self:GetParent():GetIntellect() * CDOTA_ATTRIBUTE_INTELLIGENCE_MAGICAL_ARMOR
end
--物理暴击
function modifier_hero_attribute:C_GetModifierBonusPhysicalCritChance_Constant(params)
    return self:GetParent():GetAgility() * CDOTA_ATTRIBUTE_AGILITY_PHYSICAL_CRIT_CHANCE
end
--护甲
function modifier_hero_attribute:C_GetModifierPhysicalArmor_Constant(params)
    return self:GetParent():GetAgility() * CDOTA_ATTRIBUTE_AGILITY_PHYSICAL_ARMOR
end
--生命恢复
function modifier_hero_attribute:GetModifierConstantHealthRegen()
    return -self:GetParent():GetStrength() * 0.01 + self:GetParent():GetStrength() * CDOTA_ATTRIBUTE_STRENGTH_HEALTH_REGEN
end
--战斗外生命恢复
function modifier_hero_attribute:GetModifierHealthRegenPercentage()
    local hParent = self:GetParent()
    if hParent:InCombat() then
        return 0
    end
    return CDOTA_ATTRIBUTE_HEALTH_REGEN_NO_COMBAT
end
--力量敏捷攻击力
function modifier_hero_attribute:GetModifierBaseAttack_BonusDamage()
    local hParent = self:GetParent()
    if hParent:GetPrimaryAttribute() == DOTA_ATTRIBUTE_STRENGTH then
        return hParent:GetStrength() * (CDOTA_ATTRIBUTE_STRENGTH_ATTACK_DAMAGE + 1)
    elseif hParent:GetPrimaryAttribute() == DOTA_ATTRIBUTE_AGILITY then
        return hParent:GetStrength() * CDOTA_ATTRIBUTE_STRENGTH_ATTACK_DAMAGE + hParent:GetAgility()
    else
        return hParent:GetStrength() * CDOTA_ATTRIBUTE_STRENGTH_ATTACK_DAMAGE
    end

end
--用texture同步属性
function modifier_hero_attribute:GetTexture()
    return self.attributeString
end