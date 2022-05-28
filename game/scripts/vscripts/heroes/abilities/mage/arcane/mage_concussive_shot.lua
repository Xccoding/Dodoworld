if  mage_concussive_shot == nil then
    mage_concussive_shot = class({})
end
LinkLuaModifier( "modifier_mage_concussive_shot", "heroes/abilities/mage/arcane/mage_concussive_shot.lua", LUA_MODIFIER_MOTION_NONE )
--ability
function mage_concussive_shot:GetCastAnimation()
	local hCaster = self:GetCaster()
	if hCaster:GetUnitName() == "npc_dota_hero_lina" then
		return ACT_DOTA_CAST_ABILITY_1
	elseif hCaster:GetUnitName() == "npc_dota_hero_silencer" then
		return ACT_DOTA_CAST_ABILITY_4
	end
end
function mage_concussive_shot:GetIntrinsicModifierName()
    return "modifier_mage_concussive_shot"
end
function mage_concussive_shot:OnSpellStart()
    local hCaster = self:GetCaster()
    local radius = self:GetSpecialValueFor("radius")
    local target_count = self:GetSpecialValueFor("target_count")
    local arcane_mana_get_pct = self:GetSpecialValueFor("arcane_mana_get_pct")
    local arcane_bonus_target_count = self:GetSpecialValueFor("arcane_bonus_target_count")
    local arcane_stack = 0

    if hCaster:HasModifier("modifier_mage_concussive_shot") then
        arcane_stack = hCaster:FindModifierByName("modifier_mage_concussive_shot"):GetStackCount()
    end

    --奥术充能回蓝
    hCaster:CGiveMana(hCaster:GetMaxMana() * arcane_mana_get_pct * 0.01 * arcane_stack, self, hCaster)
    --奥术充能增加目标
    target_count = target_count + arcane_stack * arcane_bonus_target_count

    EmitSoundOn("Hero_SkywrathMage.ConcussiveShot.Cast", hCaster)

    if IsServer() then
        local count = 0
        local enemies = FindUnitsInRadius(hCaster:GetTeamNumber(), hCaster:GetAbsOrigin(), nil, radius, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags(), FIND_CLOSEST, false)
        for _, enemy in pairs(enemies) do
            if enemy ~= nil and enemy:IsAlive() then
                self:shot(enemy, arcane_stack)
                local particleID = ParticleManager:CreateParticleForPlayer("particles/units/heroes/hero_skywrath_mage/skywrath_mage_concussive_shot_cast.vpcf", PATTACH_CUSTOMORIGIN, hCaster, hCaster:GetPlayerOwner())
                ParticleManager:SetParticleControl(particleID, 0, enemy:GetAbsOrigin())
                ParticleManager:SetParticleControl(particleID, 2, Vector(1, 0, 0))
                ParticleManager:ReleaseParticleIndex(particleID)
                count = count + 1
                if count >= target_count then
                    break
                end
            end
        end
        if count == 0 then
            local particleID = ParticleManager:CreateParticleForPlayer("particles/units/heroes/hero_skywrath_mage/skywrath_mage_concussive_shot_failure.vpcf", PATTACH_ABSORIGIN_FOLLOW, hCaster, hCaster:GetPlayerOwner())
            ParticleManager:ReleaseParticleIndex(particleID)
        end
    end
    hCaster:FindModifierByName("modifier_mage_concussive_shot"):SetStackCount(0)
end
function mage_concussive_shot:shot(hTarget, stack)
    local hCaster = self:GetCaster()
    local speed = self:GetSpecialValueFor("speed")

    local info = {
        Target = hTarget,
        Source = hCaster,
        Ability = self,		
        EffectName = "particles/units/heroes/hero_skywrath_mage/skywrath_mage_concussive_shot.vpcf",
        iMoveSpeed = speed,
        bDodgeable = true,                           
        vSourceLoc = hCaster:GetAbsOrigin(),               
        bIsAttack = false,                                
        ExtraData = {
            stack = stack
        },
        }

    ProjectileManager:CreateTrackingProjectile(info)
end
function mage_concussive_shot:OnProjectileHit_ExtraData(hTarget, vLocation, ExtraData)
    if not IsServer() then
        return
    end
    local hCaster = self:GetCaster()
    local sp_factor = self:GetSpecialValueFor("sp_factor")
    local fDamage = hCaster:GetDamageforAbility(false) * sp_factor * 0.01
    local arcane_bonus_damage_pct = self:GetSpecialValueFor("arcane_bonus_damage_pct")
    local equilibrium = hCaster:FindAbilityByName("mage_equilibrium")
	local equilibrium_pct = 0

    if equilibrium ~= nil and equilibrium.equilibrium_pct ~= nil then
        equilibrium_pct = equilibrium.equilibrium_pct
    end

    ApplyDamage({
		victim = hTarget,
		attacker = hCaster,
		damage =  fDamage * (100 + arcane_bonus_damage_pct * ExtraData.stack + equilibrium_pct) * 0.01,
		damage_type = DAMAGE_TYPE_MAGICAL,
		ability = self,
		damage_flags = DOTA_DAMAGE_FLAG_DIRECT,
	})

    EmitSoundOn("Hero_SkywrathMage.ConcussiveShot.Target", hTarget)
end

--modifiers
if modifier_mage_concussive_shot == nil then
	modifier_mage_concussive_shot = class({})
end
function modifier_mage_concussive_shot:IsHidden()
    return false
end
function modifier_mage_concussive_shot:IsDebuff()
    return false
end 
function modifier_mage_concussive_shot:IsPurgable()
    return false
end
function modifier_mage_concussive_shot:GetTexture()
    return "mage_arcane_supremacy"
end
function modifier_mage_concussive_shot:GetAttributes()
    return MODIFIER_ATTRIBUTE_PERMANENT
end
function modifier_mage_concussive_shot:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_TOOLTIP
    }
end
function modifier_mage_concussive_shot:OnTooltip()
    local hCaster = self:GetCaster()
    local equilibrium = hCaster:FindAbilityByName("mage_equilibrium")
	local equilibrium_pct = 0
    if equilibrium ~= nil and equilibrium.equilibrium_pct ~= nil then
        equilibrium_pct = equilibrium.equilibrium_pct
    end

    self._tooltip = (self._tooltip or 0) % 6 + 1
	if self._tooltip == 1 then
		return self.tooltip_orb_damage_pct * self:GetStackCount() + equilibrium_pct
	elseif self._tooltip == 2 then
		return self.tooltip_orb_mana_pct * self:GetStackCount()
	elseif self._tooltip == 3 then
		return self.tooltip_orb_attack_time * self:GetStackCount()
    elseif self._tooltip == 4 then
        return self.arcane_bonus_target_count * self:GetStackCount()
    elseif self._tooltip == 5 then
        return self.arcane_bonus_damage_pct * self:GetStackCount() + equilibrium_pct
    elseif self._tooltip == 6 then
        return self.arcane_mana_get_pct * self:GetStackCount()
	end
end
function modifier_mage_concussive_shot:OnCreated( params )
    self.max_stack = self:GetAbility():GetSpecialValueFor("max_stack")
    self.tooltip_orb_damage_pct = self:GetAbility():GetSpecialValueFor("tooltip_orb_damage_pct")
    self.tooltip_orb_mana_pct = self:GetAbility():GetSpecialValueFor("tooltip_orb_mana_pct")
    self.tooltip_orb_attack_time = self:GetAbility():GetSpecialValueFor("tooltip_orb_attack_time")
    self.arcane_bonus_damage_pct = self:GetAbility():GetSpecialValueFor("arcane_bonus_damage_pct")
    self.arcane_bonus_target_count = self:GetAbility():GetSpecialValueFor("arcane_bonus_target_count")
    self.arcane_mana_get_pct = self:GetAbility():GetSpecialValueFor("arcane_mana_get_pct")
    self:StartIntervalThink(0)
end
function modifier_mage_concussive_shot:OnRefresh( params )
    self.max_stack = self:GetAbility():GetSpecialValueFor("max_stack")
    self.tooltip_orb_damage_pct = self:GetAbility():GetSpecialValueFor("tooltip_orb_damage_pct")
    self.tooltip_orb_mana_pct = self:GetAbility():GetSpecialValueFor("tooltip_orb_mana_pct")
    self.tooltip_orb_attack_time = self:GetAbility():GetSpecialValueFor("tooltip_orb_attack_time")
    self.arcane_bonus_damage_pct = self:GetAbility():GetSpecialValueFor("arcane_bonus_damage_pct")
    self.arcane_bonus_target_count = self:GetAbility():GetSpecialValueFor("arcane_bonus_target_count")
    self.arcane_mana_get_pct = self:GetAbility():GetSpecialValueFor("arcane_mana_get_pct")
end
function modifier_mage_concussive_shot:OnIntervalThink()
    local hCaster = self:GetCaster()
    local arcane_orb = hCaster:FindAbilityByName("mage_arcane_orb")
    arcane_orb.arcane_stack = self:GetStackCount()
end