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
        local bUpdate = false
        local attr_old = CustomNetTables:GetTableValue("hero_attributes", tostring(hCaster:entindex())) or
        {
            -- base_attack_damage = 0,--基础攻击力
            total_attack_damage = 0, --全额攻击力
            movespeed = 0, --移动速度
            physical_armor = { 0, 0 }, --护甲
            magical_armor = 0, --魔法抗性
            evasion = 0, --闪避
            attack_speed = 0, --攻击速度
            cooldown_reduction = 0, --冷却缩减
            spell_power = 0, --法术强度
            intellect = 0, --智力
            strength = 0, --力量
            agility = 0, --敏捷
            physical_crit_chance = 0, --物理暴击概率
            magical_crit_chance = 0, --魔法暴击概率
            physical_crit_damage = 0, --物理暴击倍率
            magical_crit_damage = 0, --魔法暴击倍率
            block = 0, --格挡
        }

        local attr_new =        {
            -- base_attack_damage = math.floor((hCaster:GetBaseDamageMin() + hCaster:GetBaseDamageMax()) * 0.5),--基础攻击力
            total_attack_damage = math.floor(hCaster:GetAverageTrueAttackDamage(hCaster)), --全额攻击力
            movespeed = math.floor(hCaster:GetIdealSpeed()), --移动速度
            physical_armor = {[0] = string.format("%.1f", hCaster:GetUnitAttribute(PHYSICAL_ARMOR, {}, MODIFIER_CALCULATE_TYPE_SUM)), [1] = hCaster:GetPhysicalDamageReduction() }, --护甲及减伤率
            magical_armor = {[0] = string.format("%.1f", hCaster:GetUnitAttribute(MAGICAL_ARMOR, {}, MODIFIER_CALCULATE_TYPE_SUM)), [1] = hCaster:GetMagicalDamageReduction() }, --魔法护甲及减伤率
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
            block = {[0] = hCaster:GetUnitAttribute(BLOCK_CHANCE, {}, MODIFIER_CALCULATE_TYPE_SUM), [1] = hCaster:GetUnitAttribute(BLOCK_PERCENT, {}, MODIFIER_CALCULATE_TYPE_SUM) }, --格挡及减伤率
        }

        self.attributeString = json.encode(attr_new)
        self:SendBuffRefreshToClients()

        for attr, value in pairs(attr_new) do
            if value ~= attr_old[attr] then
                bUpdate = true
                break
            end
        end

        if bUpdate then
            --有属性变化再更新网表
            CustomNetTables:SetTableValue("hero_attributes", tostring(hCaster:GetPlayerOwnerID()), attr_new)
        end

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
--力量攻击力
function modifier_hero_attribute:GetModifierBaseAttack_BonusDamage()
    return self:GetParent():GetStrength() * CDOTA_ATTRIBUTE_STRENGTH_ATTACK_DAMAGE
end
--用texture同步属性
function modifier_hero_attribute:GetTexture()
    return self.attributeString
end