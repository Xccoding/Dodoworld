if  death_knight_hellfire_blast == nil then
    death_knight_hellfire_blast = class({})
end
LinkLuaModifier( "modifier_death_knight_hellfire_blast", "heroes/abilities/death_knight/blood/death_knight_hellfire_blast.lua", LUA_MODIFIER_MOTION_NONE )
--ability
function death_knight_hellfire_blast:OnAbilityPhaseStart()
    local hCaster = self:GetCaster()

    return true
end
function death_knight_hellfire_blast:OnAbilityPhaseInterrupted()
    local hCaster = self:GetCaster()

    return true
end
function death_knight_hellfire_blast:OnSpellStart()
    local hCaster = self:GetCaster()
    local hTarget = self:GetCursorTarget()
    local search_radius = self:GetSpecialValueFor("search_radius")
    local bonus_target_count = self:GetSpecialValueFor("bonus_target_count")
    local pulse_bonus_target_count = self:GetSpecialValueFor("pulse_bonus_target_count")

    if hCaster:HasModifier("modifier_death_knight_midnight_pulse_buff") then
        bonus_target_count = bonus_target_count + pulse_bonus_target_count
    end
    
    if IsServer() then
        self:blast(hTarget)

        local count = 0
        local enemies = FindUnitsInRadius(hCaster:GetTeamNumber(), hCaster:GetAbsOrigin(), nil, search_radius, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)
        for _, enemy in pairs(enemies) do
            if enemy ~= nil and enemy:IsAlive() and enemy ~= hTarget then
                self:blast(enemy)
                count = count + 1
                if count >= bonus_target_count then
                    break
                end
            end
        end
    end
end
function death_knight_hellfire_blast:blast(hTarget)
    local hCaster = self:GetCaster()
    local blast_Target = hTarget
    local speed = self:GetSpecialValueFor("speed")

    local info = {
        Target = blast_Target,
        Source = hCaster,
        Ability = self,		
        EffectName = "particles/units/heroes/hero_skeletonking/skeletonking_hellfireblast.vpcf",
        iMoveSpeed = speed,
        bDodgeable = true,                           
        vSourceLoc = hCaster:GetAbsOrigin(),               
        bIsAttack = false,                                
        ExtraData = {},
        }

    ProjectileManager:CreateTrackingProjectile(info)

    EmitSoundOn("Hero_SkeletonKing.Hellfire_Blast", hCaster)
end
function death_knight_hellfire_blast:OnProjectileHit_ExtraData(hTarget, vLocation, ExtraData)
    if not IsServer() then
        return
    end
    local hCaster = self:GetCaster()
    local blast_Target = hTarget
    local ap_factor_hit = self:GetSpecialValueFor("ap_factor_hit")
    local debuff_duration = self:GetSpecialValueFor("debuff_duration")

    ApplyDamage({
		victim = blast_Target,
		attacker = hCaster,
		damage = hCaster:GetDamageforAbility(true) * ap_factor_hit * 0.01,
		damage_type = DAMAGE_TYPE_PHYSICAL,
		ability = self,
		damage_flags = DOTA_DAMAGE_FLAG_DIRECT,
	})

    blast_Target:AddNewModifier(hCaster, self, "modifier_death_knight_hellfire_blast", {duration = debuff_duration})

    EmitSoundOn("Hero_SkeletonKing.Hellfire_BlastImpact", blast_Target)
end

--modifiers
if modifier_death_knight_hellfire_blast == nil then
	modifier_death_knight_hellfire_blast = class({})
end
function modifier_death_knight_hellfire_blast:IsHidden()
    return false
end
function modifier_death_knight_hellfire_blast:IsDebuff()
    return true
end 
function modifier_death_knight_hellfire_blast:IsPurgable()
    return false
end
function modifier_death_knight_hellfire_blast:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_death_knight_hellfire_blast:GetEffectName()
    return "particles/units/heroes/hero_skeletonking/skeletonking_hellfireblast_debuff.vpcf"
end
function modifier_death_knight_hellfire_blast:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }
end
function modifier_death_knight_hellfire_blast:OnAttackLanded(params)
    if params.target == self:GetParent() and params.attacker == self:GetCaster() then
        local hCaster = self:GetCaster()
        local hAbility = self:GetAbility()
        if hAbility == nil then
            return
        end

        if RandomFloat(0, 100) < self.reset_chance then
            local pulse = hCaster:FindAbilityByName("death_knight_midnight_pulse")
            if pulse ~= nil then
                pulse:EndCooldown() 
            end
        end
    end
end
function modifier_death_knight_hellfire_blast:OnCreated(params)
    self.ap_factor_dot= self:GetAbility():GetSpecialValueFor("ap_factor_dot")
    self.dot_interval= self:GetAbility():GetSpecialValueFor("dot_interval")
    self.reset_chance= self:GetAbility():GetSpecialValueFor("reset_chance")

    if IsServer() then
        self:StartIntervalThink(self.dot_interval)
        self:OnIntervalThink()
    end
end
function modifier_death_knight_hellfire_blast:OnRefresh(params)
    self.ap_factor_dot= self:GetAbility():GetSpecialValueFor("ap_factor_dot")
    self.dot_interval= self:GetAbility():GetSpecialValueFor("dot_interval")
    self.reset_chance= self:GetAbility():GetSpecialValueFor("reset_chance")

    if IsServer() then
        self:OnIntervalThink()
    end
end
function modifier_death_knight_hellfire_blast:OnIntervalThink()
    if IsServer() then
        local hCaster = self:GetCaster()
        local blast_Target = self:GetParent()
        local fDamage = hCaster:GetDamageforAbility(true) * self.ap_factor_dot * 0.01

        ApplyDamage({
            victim = blast_Target,
            attacker = hCaster,
            damage = fDamage,
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability = self,
            damage_flags = DOTA_DAMAGE_FLAG_INDIRECT,
        })

        hCaster:CHeal(fDamage, self:GetAbility(), false, true, hCaster, false)

        local particleID = ParticleManager:CreateParticleForPlayer("particles/units/heroes/hero_undying/undying_soul_rip_heal.vpcf", PATTACH_ABSORIGIN_FOLLOW, hCaster, hCaster:GetPlayerOwner())
        ParticleManager:SetParticleControlEnt(particleID, 0, hCaster, PATTACH_POINT_FOLLOW, "attach_hitloc", hCaster:GetAbsOrigin(), false)
        ParticleManager:SetParticleControlEnt(particleID, 1, blast_Target, PATTACH_POINT_FOLLOW, "attach_hitloc", blast_Target:GetAbsOrigin(), false)
        ParticleManager:ReleaseParticleIndex(particleID)
    end
end