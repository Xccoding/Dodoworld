LinkLuaModifier( "modifier_neutral_creep_whip", "units/abilities/dungeon/kobold_mine_cave/neutral_creep_whip.lua", LUA_MODIFIER_MOTION_NONE )
--=======================================neutral_creep_whip=======================================
if neutral_creep_whip == nil then
    neutral_creep_whip = class({})
end
function neutral_creep_whip:OnSpellStart()
    local hCaster = self:GetCaster()
    local hTarget = self:GetCursorTarget()
    local duration = self:GetSpecialValueFor("duration")
    
    EmitSoundOn("Item.Bullwhip.Enemy", hTarget)
    
    local particleID = ParticleManager:CreateParticle("particles/items4_fx/bull_whip_enemy.vpcf", PATTACH_CUSTOMORIGIN, hCaster)
    ParticleManager:SetParticleControl(particleID, 0, hCaster:GetAbsOrigin())
    ParticleManager:SetParticleControlEnt(particleID, 1, hTarget, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0, 0, 0), false)
    ParticleManager:ReleaseParticleIndex(particleID)

    hTarget:AddNewModifier(hCaster, self, "modifier_neutral_creep_whip", {duration = duration})
end
--=======================================modifier_neutral_creep_whip=======================================
if modifier_neutral_creep_whip == nil then
    modifier_neutral_creep_whip = class({})
end
function modifier_neutral_creep_whip:IsHidden()
    return true
end
function modifier_neutral_creep_whip:IsDebuff()
    return false
end
function modifier_neutral_creep_whip:IsPurgable()
    return false
end
function modifier_neutral_creep_whip:IsPurgeException()
    return false
end
function modifier_neutral_creep_whip:OnCreated(params)
    self.bonus_ap = self:GetAbilitySpecialValueFor("bonus_ap")
    self.bonus_atk_speed = self:GetAbilitySpecialValueFor("bonus_atk_speed")
end
function modifier_neutral_creep_whip:OnRefresh(params)
end
function modifier_neutral_creep_whip:OnDestroy(params)
end
function modifier_neutral_creep_whip:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    }
end
function modifier_neutral_creep_whip:CDeclareFunctions()
    return {
    }
end
function modifier_neutral_creep_whip:GetModifierPreAttack_BonusDamage()
    return self.bonus_ap
end
function modifier_neutral_creep_whip:GetModifierAttackSpeedBonus_Constant()
    return self.bonus_atk_speed
end
function modifier_neutral_creep_whip:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_neutral_creep_whip:GetEffectName()
    return "particles/items4_fx/bull_whip_enemy_debuff.vpcf"
end