--=======================================mage_blink=======================================
if mage_blink == nil then
    mage_blink = class({})
end
LinkLuaModifier("modifier_mage_fire_shield", "heroes/abilities/mage/common/mage_blink.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mage_arcane_shield", "heroes/abilities/mage/common/mage_blink.lua", LUA_MODIFIER_MOTION_NONE)
function mage_blink:GetManaCost(iLevel)
    local hCaster = self:GetCaster()
    return self:GetSpecialValueFor("mana_cost_pct") * hCaster:GetMaxMana() * 0.01
end
function mage_blink:C_OnSpellStart()
    local hCaster = self:GetCaster()
    local distance = self:GetSpecialValueFor("distance")
    local dir = hCaster:GetForwardVector()
    local start_pos = hCaster:GetAbsOrigin()
    local end_pos = hCaster:GetAbsOrigin()
    local fire_shield_duration = self:GetSpecialValueFor("fire_shield_duration")

    EmitSoundOnLocationWithCaster(start_pos, "Hero_Antimage.Blink_out", hCaster)

    local particleID = ParticleManager:CreateParticle("particles/units/heroes/hero_antimage/antimage_blink_start.vpcf", PATTACH_CUSTOMORIGIN, hCaster)
    ParticleManager:SetParticleControl(particleID, 0, start_pos)
    ParticleManager:SetParticleControlEnt(particleID, 1, hCaster, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0, 0, 0), true)
    ParticleManager:ReleaseParticleIndex(particleID)

    for i = 1, distance do
        if GridNav:CanFindPath(start_pos, end_pos + dir * 1) then
            end_pos = end_pos + dir * 1
        else
            break
        end
    end

    FindClearSpaceForUnit(hCaster, end_pos, true)
    EmitSoundOnLocationWithCaster(end_pos, "Hero_Antimage.Blink_in", hCaster)

    local particleID = ParticleManager:CreateParticle("particles/units/heroes/hero_antimage/antimage_blink_end.vpcf", PATTACH_CUSTOMORIGIN, hCaster)
    ParticleManager:SetParticleControl(particleID, 0, end_pos)
    ParticleManager:SetParticleControlEnt(particleID, 1, hCaster, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0, 0, 0), true)
    ParticleManager:ReleaseParticleIndex(particleID)

    if fire_shield_duration > 0 then
        hCaster:AddNewModifier(hCaster, self, "modifier_mage_fire_shield", {duration = fire_shield_duration})
        hCaster:AddNewModifier(hCaster, self, "modifier_mage_arcane_shield", {duration = fire_shield_duration})
    end

end
function mage_blink:OnProjectileHit_ExtraData(hTarget, vLocation, ExtraData)
    if IsValid(hTarget) then
        local hCaster = self:GetCaster()
        local type = ExtraData.type
        local sp_factor = self:GetSpecialValueFor(type.."_shield_sp_factor")

        EmitSoundOn("Hero_OgreMagi.FireShield.Damage", hTarget)

        ApplyDamage({
            victim = hTarget,
            attacker = hCaster,
            damage = hCaster:GetDamageforAbility(ABILITY_DAMAGE_CALCULATE_TYPE_SP) * sp_factor * 0.01,
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability = self,
            damage_flags = DOTA_DAMAGE_FLAG_DIRECT,
        })
        
    end
end
--=======================================modifier_mage_fire_shield=======================================
if modifier_mage_fire_shield == nil then
    modifier_mage_fire_shield = class({})
end
function modifier_mage_fire_shield:IsHidden()
    return false
end
function modifier_mage_fire_shield:IsDebuff()
    return false
end
function modifier_mage_fire_shield:IsPurgable()
    return false
end
function modifier_mage_fire_shield:IsPurgeException()
    return false
end
function modifier_mage_fire_shield:GetAbilityValues()
    self.fire_shield_speed = self:GetAbilitySpecialValueFor("fire_shield_speed")
    self.fire_shield_max_hp_factor = self:GetAbilitySpecialValueFor("fire_shield_max_hp_factor")
end
function modifier_mage_fire_shield:OnCreated(params)
    self:GetAbilityValues()
    local hParent = self:GetParent()
    if IsServer() then
        self:SetStackCount(hParent:GetMaxHealth() * self.fire_shield_max_hp_factor * 0.01)

        local particleID = ParticleManager:CreateParticle("particles/units/heroes/hero_ogre_magi/ogre_magi_fire_shield.vpcf", PATTACH_CUSTOMORIGIN, hParent)
        ParticleManager:SetParticleControlEnt(particleID, 0, hParent, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0, 0, 0), false)
        self:AddParticle(particleID, false, false, -1, false, false)

        EmitSoundOn("Hero_OgreMagi.FireShield.Target", hParent)
    end
end
function modifier_mage_fire_shield:OnRefresh(params)
    self:GetAbilityValues()
    if IsServer() then
        local hParent = self:GetParent()
        self:SetStackCount(hParent:GetMaxHealth() * self.fire_shield_max_hp_factor * 0.01)
        EmitSoundOn("Hero_OgreMagi.FireShield.Target", hParent)
    end
end
function modifier_mage_fire_shield:OnDestroy(params)
end
function modifier_mage_fire_shield:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK,
        MODIFIER_PROPERTY_TOOLTIP,
    }
end
function modifier_mage_fire_shield:CDeclareFunctions()
    return {
        CMODIFIER_PROPERTY_SHIELD_BLOCK_CONSTANT
    }
end
function modifier_mage_fire_shield:OnAttackLanded(params)
    local hParent = self:GetParent()
    if params.target == hParent and not params.ranged_attack then
        local hAttacker = params.attacker
        local info = {
            Target = hAttacker,
            Source = hParent,
            Ability = self:GetAbility(),
            EffectName = "particles/units/heroes/hero_ogre_magi/ogre_magi_fire_shield_projectile.vpcf",
            iMoveSpeed = self.fire_shield_speed,
            bDodgeable = true,    
            vSourceLoc = hParent:GetAbsOrigin(),
            bIsAttack = false,            
            ExtraData = {
                type = "fire"
            },
        }

        ProjectileManager:CreateTrackingProjectile(info)

        EmitSoundOn("Hero_OgreMagi.FireShield.Damage", hParent)
    end
end
function modifier_mage_fire_shield:C_GetModifierShieldBlock_Constant(params)
    if params.damage >= self:GetStackCount() then
        local block_value = self:GetStackCount()
        self:Destroy()
        return block_value
    else
        self:SetStackCount(self:GetStackCount() - params.damage)
        return params.damage
    end
end
function modifier_mage_fire_shield:GetTexture()
    return "ogre_magi_smash"
end
function modifier_mage_fire_shield:OnTooltip()
    return self:GetStackCount()
end
--=======================================modifier_mage_arcane_shield=======================================
if modifier_mage_arcane_shield == nil then
    modifier_mage_arcane_shield = class({})
end
function modifier_mage_arcane_shield:IsHidden()
    return false
end
function modifier_mage_arcane_shield:IsDebuff()
    return false
end
function modifier_mage_arcane_shield:IsPurgable()
    return false
end
function modifier_mage_arcane_shield:IsPurgeException()
    return false
end
function modifier_mage_arcane_shield:GetAbilityValues()
    self.fire_shield_speed = self:GetAbilitySpecialValueFor("fire_shield_speed")
    self.fire_shield_max_hp_factor = self:GetAbilitySpecialValueFor("fire_shield_max_hp_factor")
end
function modifier_mage_arcane_shield:OnCreated(params)
    self:GetAbilityValues()
    local hParent = self:GetParent()
    if IsServer() then
        self:SetStackCount(hParent:GetMaxHealth() * self.fire_shield_max_hp_factor * 0.01)

        local particleID = ParticleManager:CreateParticle("particles/units/heroes/hero_ogre_magi/ogre_magi_fire_shield.vpcf", PATTACH_CUSTOMORIGIN, hParent)
        ParticleManager:SetParticleControlEnt(particleID, 0, hParent, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0, 0, 0), false)
        self:AddParticle(particleID, false, false, -1, false, false)

        EmitSoundOn("Hero_OgreMagi.FireShield.Target", hParent)
    end
end
function modifier_mage_arcane_shield:OnRefresh(params)
    self:GetAbilityValues()
    if IsServer() then
        local hParent = self:GetParent()
        self:SetStackCount(hParent:GetMaxHealth() * self.fire_shield_max_hp_factor * 0.01)
        EmitSoundOn("Hero_OgreMagi.FireShield.Target", hParent)
    end
end
function modifier_mage_arcane_shield:OnDestroy(params)
end
function modifier_mage_arcane_shield:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK,
        MODIFIER_PROPERTY_TOOLTIP,
    }
end
function modifier_mage_arcane_shield:CDeclareFunctions()
    return {
        CMODIFIER_PROPERTY_SHIELD_BLOCK_CONSTANT
    }
end
function modifier_mage_arcane_shield:OnAttackLanded(params)
    local hParent = self:GetParent()
    if params.target == hParent and not params.ranged_attack then
        local hAttacker = params.attacker
        local info = {
            Target = hAttacker,
            Source = hParent,
            Ability = self:GetAbility(),
            EffectName = "particles/units/heroes/hero_ogre_magi/ogre_magi_fire_shield_projectile.vpcf",
            iMoveSpeed = self.fire_shield_speed,
            bDodgeable = true,    
            vSourceLoc = hParent:GetAbsOrigin(),
            bIsAttack = false,            
            ExtraData = {
                type = "fire"
            },
        }

        ProjectileManager:CreateTrackingProjectile(info)

        EmitSoundOn("Hero_OgreMagi.FireShield.Damage", hParent)
    end
end
function modifier_mage_arcane_shield:C_GetModifierShieldBlock_Constant(params)
    if params.damage >= self:GetStackCount() then
        local block_value = self:GetStackCount()
        self:Destroy()
        return block_value
    else
        self:SetStackCount(self:GetStackCount() - params.damage)
        return params.damage
    end
end
