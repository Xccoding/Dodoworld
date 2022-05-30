--标记战斗用modifiers
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
    end
end
function modifier_hero_attribute:CDeclareFunctions()
    return {
        CMODIFIER_PROPERTY_SPELL_POWER_CONSTANT
    }
end
function modifier_hero_attribute:DeclareFunctions()
    return {
        
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
        MODIFIER_PROPERTY_MANA_BONUS,
    }
end
function modifier_hero_attribute:OnIntervalThink()
    if IsServer() then
        local hCaster = self:GetCaster()
        local bUpdate = false
        local attr_old = CustomNetTables:GetTableValue("hero_attributes", tostring(hCaster:entindex())) or 
        {
            -- base_attack_damage = 0,--基础攻击力
            total_attack_damage = 0,--全额攻击力
            movespeed = 0,--移动速度
            physical_armor = 0,--护甲
            magical_armor = 0,--魔法抗性
            attack_speed = 0,--攻击速度
            cooldown_reduction = 0,--冷却缩减
            spell_power = 0,--法术强度
            intellect = 0,--智力
            strength = 0,--力量
            agility = 0,--敏捷
            physical_crit_chance = 0,--物理暴击概率
            magical_crit_chance = 0,--魔法暴击概率
            physical_crit_damage = 0,--物理暴击倍率
            magical_crit_damage = 0,--魔法暴击倍率
        }

        local attr_new = 
        {
            -- base_attack_damage = math.floor((hCaster:GetBaseDamageMin() + hCaster:GetBaseDamageMax()) * 0.5),--基础攻击力
            total_attack_damage = math.floor((hCaster:GetDamageMin() + hCaster:GetDamageMax()) * 0.5),--全额攻击力
            movespeed = math.floor(hCaster:GetIdealSpeed()),--移动速度
            physical_armor = math.floor(hCaster:GetPhysicalArmorValue(false)),--护甲
            magical_armor = math.floor(hCaster:GetMagicalArmorValue()),--魔法抗性
            attack_speed = hCaster:GetAttacksPerSecond(),--攻击速度(每秒攻击次数)
            cooldown_reduction = math.floor(100 - hCaster:GetCooldownReduction() * 100),--冷却缩减
            spell_power = math.floor(hCaster:GetUnitAttribute(SPELL_POWER, {}, MODIFIER_CALCULATE_TYPE_SUM)),--法术强度
            intellect = hCaster:GetIntellect(),--智力
            strength = hCaster:GetStrength(),--力量
            agility = hCaster:GetAgility(),--敏捷
            physical_crit_chance = hCaster:GetUnitAttribute(BONUS_PHYSICAL_CRIT_CHANCE, {}, MODIFIER_CALCULATE_TYPE_SUM),--物理暴击概率
            magical_crit_chance = hCaster:GetUnitAttribute(BONUS_MAGICAL_CRIT_CHANCE, {}, MODIFIER_CALCULATE_TYPE_SUM),--魔法暴击概率
            physical_crit_damage = 100 + CDOTA_BASE_CRIT_DAMAGE + hCaster:GetUnitAttribute(BONUS_PHYSICAL_CRIT_DAMAGE, {}, MODIFIER_CALCULATE_TYPE_SUM),--物理暴击倍率
            magical_crit_damage = 100 + CDOTA_BASE_CRIT_DAMAGE + hCaster:GetUnitAttribute(BONUS_MAGICAL_CRIT_DAMAGE, {}, MODIFIER_CALCULATE_TYPE_SUM),--魔法暴击倍率
        }

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
--智力提供法术强度
function modifier_hero_attribute:C_GetModifierSpellPower_Constant( params )
    return self:GetParent():GetIntellect() * CDOTA_ATTRIBUTE_INTELLIGENCE_SPELL_POWER
end
--魔法恢复
function modifier_hero_attribute:GetModifierConstantManaRegen()
    local unit = self:GetParent()

    if not unit:IsUseMana() then
        return -self:GetParent():GetIntellect() * 0.05
    else
        return 0
    end
end
--额外魔法值
function modifier_hero_attribute:GetModifierManaBonus()
    local unit = self:GetParent()

    if unit:IsUseMana() then
        return self:GetParent():GetIntellect() * CDOTA_ATTRIBUTE_INTELLIGENCE_MANA
    else
        return 0
    end
end