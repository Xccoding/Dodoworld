if  foreman_calgima_crystal_armor == nil then
    foreman_calgima_crystal_armor = class({})
end
LinkLuaModifier( "modifier_foreman_calgima_crystal_armor", "units/abilities/dungeon/kobold_mine_cave/foreman_calgima_crystal_armor.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_foreman_calgima_crystal_armor_debuff", "units/abilities/dungeon/kobold_mine_cave/foreman_calgima_crystal_armor.lua", LUA_MODIFIER_MOTION_NONE )
--ability
function foreman_calgima_crystal_armor:OnSpellStart()
    local hCaster = self:GetCaster()
    local hTarget = self:GetCursorTarget()
    local duration = self:GetSpecialValueFor("duration")
    hTarget:AddNewModifier(hCaster, self, "modifier_foreman_calgima_crystal_armor", {duration = duration})
    EmitSoundOn("n_creep_OgreMagi.FrostArmor", hTarget)
end
--=======================================modifier_foreman_calgima_crystal_armor=======================================
if modifier_foreman_calgima_crystal_armor == nil then
    modifier_foreman_calgima_crystal_armor = class({})
end
function modifier_foreman_calgima_crystal_armor:IsHidden()
    return false
end
function modifier_foreman_calgima_crystal_armor:IsDebuff()
    return false
end
function modifier_foreman_calgima_crystal_armor:IsPurgable()
    return false
end
function modifier_foreman_calgima_crystal_armor:IsPurgeException()
    return false
end
function modifier_foreman_calgima_crystal_armor:OnCreated(params)
    self.bonus_armor = self:GetAbilitySpecialValueFor("bonus_armor")
    self.debuff_duration = self:GetAbilitySpecialValueFor("debuff_duration")
end
function modifier_foreman_calgima_crystal_armor:OnRefresh(params)
end
function modifier_foreman_calgima_crystal_armor:OnDestroy(params)
end
function modifier_foreman_calgima_crystal_armor:GetEffectName()
    return "particles/units/neutrals/foreman_calgima/foreman_calgima_crystal_armor.vpcf"
end
function modifier_foreman_calgima_crystal_armor:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end
function modifier_foreman_calgima_crystal_armor:GetStatusEffectName()
    return "particles/status_fx/status_effect_frost.vpcf"
end
function modifier_foreman_calgima_crystal_armor:StatusEffectPriority()
    return 1
end
function modifier_foreman_calgima_crystal_armor:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_TOOLTIP,
    }
end
function modifier_foreman_calgima_crystal_armor:CDeclareFunctions()
    return {
        CMODIFIER_PROPERTY_PHYSICAL_ARMOR_CONSTANT
    }
end
function modifier_foreman_calgima_crystal_armor:C_GetModifierPhysicalArmor_Constant()
    return self.bonus_armor
end
function modifier_foreman_calgima_crystal_armor:OnAttackLanded( params )
    local hParent = self:GetParent()
    if params.target == hParent then
        params.attacker:AddNewModifier(hParent, self:GetAbility(), "modifier_foreman_calgima_crystal_armor_debuff", {duration = self.debuff_duration} )
    end
end
function modifier_foreman_calgima_crystal_armor:OnTooltip()
    return self.bonus_armor
end
--=======================================modifier_foreman_calgima_crystal_armor_debuff=======================================
if modifier_foreman_calgima_crystal_armor_debuff == nil then
    modifier_foreman_calgima_crystal_armor_debuff = class({})
end
function modifier_foreman_calgima_crystal_armor_debuff:IsHidden()
    return false
end
function modifier_foreman_calgima_crystal_armor_debuff:IsDebuff()
    return true
end
function modifier_foreman_calgima_crystal_armor_debuff:IsPurgable()
    return false
end
function modifier_foreman_calgima_crystal_armor_debuff:IsPurgeException()
    return false
end
function modifier_foreman_calgima_crystal_armor_debuff:OnCreated(params)
    self.slow_down = self:GetAbilitySpecialValueFor("slow_down")
end
function modifier_foreman_calgima_crystal_armor_debuff:OnRefresh(params)
end
function modifier_foreman_calgima_crystal_armor_debuff:OnDestroy(params)
end
function modifier_foreman_calgima_crystal_armor_debuff:GetStatusEffectName()
    return "particles/status_fx/status_effect_frost.vpcf"
end
function modifier_foreman_calgima_crystal_armor_debuff:StatusEffectPriority()
    return 1
end
function modifier_foreman_calgima_crystal_armor_debuff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
    }
end
function modifier_foreman_calgima_crystal_armor_debuff:CDeclareFunctions()
    return {
    }
end
function modifier_foreman_calgima_crystal_armor_debuff:GetModifierAttackSpeedBonus_Constant()
    return -self.slow_down
end