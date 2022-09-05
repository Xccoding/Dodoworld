if  mage_fireblast == nil then
    mage_fireblast = class({})
end
LinkLuaModifier( "modifier_mage_fireblast", "heroes/abilities/mage/fire/mage_fireblast.lua", LUA_MODIFIER_MOTION_NONE )
--ability
function mage_fireblast:GetIntrinsicModifierName()
    return "modifier_mage_fireblast"
end
function mage_fireblast:GetManaCost(iLevel)
    local hCaster = self:GetCaster()
    return self:GetSpecialValueFor("mana_cost_pct") * hCaster:GetMaxMana() * 0.01
end
function mage_fireblast:GetBehavior()
    if self:GetLevel() >= 3 then
        return tonumber(tostring(self.BaseClass.GetBehavior(self))) + DOTA_ABILITY_BEHAVIOR_IGNORE_PSEUDO_QUEUE + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
    else
        return tonumber(tostring(self.BaseClass.GetBehavior(self)))
    end
end
function mage_fireblast:C_OnSpellStart()
    local hCaster = self:GetCaster()
    local target = self:GetCursorTarget()
    local sp_factor = self:GetSpecialValueFor("sp_factor")

    local iParticleID = ParticleManager:CreateParticle("particles/units/heroes/hero_ogre_magi/ogre_magi_fireblast.vpcf", PATTACH_ABSORIGIN, target)
    ParticleManager:SetParticleControlEnt(iParticleID, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0, 0, 0), false)
    ParticleManager:SetParticleControlEnt(iParticleID, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0, 0, 0), false)
    ParticleManager:ReleaseParticleIndex(iParticleID)

    EmitSoundOn("Hero_OgreMagi.Fireblast.Target", target)
    
    ApplyDamage(
        {
            victim = target,
			attacker = hCaster,
			damage = hCaster:GetDamageforAbility(ABILITY_DAMAGE_CALCULATE_TYPE_SP) * sp_factor * 0.01,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self,
			damage_flags = DOTA_DAMAGE_FLAG_DIRECT,
        }
    )
end
--火焰爆轰必爆modifiers
if modifier_mage_fireblast == nil then
	modifier_mage_fireblast = class({})
end
function modifier_mage_fireblast:IsHidden()
    return true
end
function modifier_mage_fireblast:IsDebuff()
    return false
end 
function modifier_mage_fireblast:IsPurgable()
    return false
end
function modifier_mage_fireblast:GetAbilityValues()
end
function modifier_mage_fireblast:OnCreated(params)
    self:GetAbilityValues()
end
function modifier_mage_fireblast:OnRefresh(params)
    self:GetAbilityValues()
end
function modifier_mage_fireblast:CDeclareFunctions()
    return {
        CMODIFIER_PROPERTY_BONUS_MAGICAL_CRIT_CHANCE_CONSTANT
    }
end
function modifier_mage_fireblast:C_GetModifierBonusMagicalCritChance_Constant( params )
    if params.inflictor ~= nil and params.inflictor == self:GetAbility() then
        if bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_DIRECT) == DOTA_DAMAGE_FLAG_DIRECT then
            return 100
        end
    end
    return 0
end
