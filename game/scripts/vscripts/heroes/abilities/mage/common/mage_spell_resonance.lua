LinkLuaModifier("modifier_mage_spell_resonance", "heroes/abilities/mage/common/mage_spell_resonance.lua", LUA_MODIFIER_MOTION_NONE)
--=======================================mage_spell_resonance=======================================
if mage_spell_resonance == nil then
    mage_spell_resonance = class({})
end
function mage_spell_resonance:GetManaCost(iLevel)
    local hCaster = self:GetCaster()
    return self:GetSpecialValueFor("mana_cost_pct") * hCaster:GetMaxMana() * 0.01
end
function mage_spell_resonance:CastFilterResultTarget(hTarget)
    local hCaster = self:GetCaster()
    if hTarget == hCaster then
        return UF_FAIL_OTHER
    end
    return UF_SUCCESS
end
function mage_spell_resonance:C_OnSpellStart()
    local hCaster = self:GetCaster()
    local hTarget = self:GetCursorTarget()
    local duration = self:GetSpecialValueFor("duration")

    if IsValid(self.hTarget) then
        self.hTarget:RemoveModifierByNameAndCaster("modifier_mage_spell_resonance", hCaster)
    end

    EmitSoundOn("Rune.Arcane", hTarget)

    hTarget:AddNewModifier(hCaster, self, "modifier_mage_spell_resonance", { duration = duration })

end
--=======================================modifier_mage_spell_resonance=======================================
if modifier_mage_spell_resonance == nil then
    modifier_mage_spell_resonance = class({})
end
function modifier_mage_spell_resonance:IsHidden()
    return false
end
function modifier_mage_spell_resonance:IsDebuff()
    return false
end
function modifier_mage_spell_resonance:IsPurgable()
    return false
end
function modifier_mage_spell_resonance:IsPurgeException()
    return false
end
function modifier_mage_spell_resonance:GetAbilityValues()
    self.bonus_magical_crit_chance = self:GetAbilitySpecialValueFor("bonus_magical_crit_chance")
    self.bonus_intellect_pct = self:GetAbilitySpecialValueFor("bonus_intellect_pct")
    self.caster_duration = self:GetAbilitySpecialValueFor("caster_duration")
end
function modifier_mage_spell_resonance:OnCreated(params)
    self:GetAbilityValues()
    if IsServer() then
        local hParent = self:GetParent()
        local particleID = ParticleManager:CreateParticle("particles/econ/items/crystal_maiden/crystal_maiden_lady_whitewind/crystal_maiden_lady_whitewind_staff_ambient.vpcf", PATTACH_CUSTOMORIGIN, hUnit)
        ParticleManager:SetParticleControlEnt(particleID, 6, hParent, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0, 0, 0), false)
        self:AddParticle(particleID, false, false, -1, false, false)
    end
end
function modifier_mage_spell_resonance:OnRefresh(params)
    self:GetAbilityValues()
end
function modifier_mage_spell_resonance:OnDestroy(params)
end
function modifier_mage_spell_resonance:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_TOOLTIP,
    }
end
function modifier_mage_spell_resonance:CDeclareFunctions()
    return {
        CMODIFIER_PROPERTY_BONUS_MAGICAL_CRIT_CHANCE_PERCENT,
        CMODIFIER_EVENT_ON_SPELL_CRIT,
    }
end
function modifier_mage_spell_resonance:C_GetModifierBonusMagicalCritChance_Percent(params)
    return self.bonus_magical_crit_chance
end
function modifier_mage_spell_resonance:C_OnSpellCrit(params)
    local hCaster = self:GetCaster()
    local hParent = self:GetParent()
    if params.damage_type == DAMAGE_TYPE_MAGICAL and params.attacker == hParent then
        hCaster:AddNewModifier(hCaster, self:GetAbility(), "modifier_mage_spell_resonance_caster", { duration = self.caster_duration })
    end
end
function modifier_mage_spell_resonance:OnTooltip()
    return self.bonus_magical_crit_chance
end
--=======================================modifier_mage_spell_resonance_caster=======================================
if modifier_mage_spell_resonance_caster == nil then
    modifier_mage_spell_resonance_caster = class({})
end
function modifier_mage_spell_resonance_caster:IsHidden()
    return false
end
function modifier_mage_spell_resonance_caster:IsDebuff()
    return false
end
function modifier_mage_spell_resonance_caster:IsPurgable()
    return false
end
function modifier_mage_spell_resonance_caster:IsPurgeException()
    return false
end
function modifier_mage_spell_resonance_caster:GetAbilityValues()
    self.bonus_magical_crit_chance = self:GetAbilitySpecialValueFor("bonus_magical_crit_chance")
    self.bonus_intellect_pct = self:GetAbilitySpecialValueFor("bonus_intellect_pct")
end
function modifier_mage_spell_resonance_caster:OnCreated(params)
    self:GetAbilityValues()
    if IsServer() then
        local hParent = self:GetParent()
        local particleID = ParticleManager:CreateParticle("particles/econ/items/crystal_maiden/crystal_maiden_lady_whitewind/crystal_maiden_lady_whitewind_staff_ambient.vpcf", PATTACH_CUSTOMORIGIN, hUnit)
        ParticleManager:SetParticleControlEnt(particleID, 6, hParent, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0, 0, 0), false)
        self:AddParticle(particleID, false, false, -1, false, false)
    end
end
function modifier_mage_spell_resonance_caster:OnRefresh(params)
    self:GetAbilityValues()
end
function modifier_mage_spell_resonance_caster:OnDestroy(params)
end
function modifier_mage_spell_resonance_caster:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_TOOLTIP,
        MODIFIER_PROPERTY_TOOLTIP2,
    }
end
function modifier_mage_spell_resonance_caster:CDeclareFunctions()
    return {
        CMODIFIER_PROPERTY_BONUS_MAGICAL_CRIT_CHANCE_PERCENT,
        CMODIFIER_PROPERTY_INTELLECT_PERCENT,
    }
end
function modifier_mage_spell_resonance_caster:C_GetModifierBonusMagicalCritChance_Percent(params)
    return self.bonus_magical_crit_chance
end
function modifier_mage_spell_resonance_caster:C_GetModifierIntellect_Percent()
    return self.bonus_intellect_pct
end
function modifier_mage_spell_resonance_caster:OnTooltip()
    return self.bonus_magical_crit_chance
end
function modifier_mage_spell_resonance_caster:OnTooltip2()
    return self.bonus_intellect_pct
end