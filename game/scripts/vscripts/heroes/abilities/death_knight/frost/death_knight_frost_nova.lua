if  death_knight_frost_nova == nil then
    death_knight_frost_nova = class({})
end
LinkLuaModifier( "modifier_death_knight_frost_nova", "heroes/abilities/death_knight/frost/death_knight_frost_nova.lua", LUA_MODIFIER_MOTION_NONE )
--ability
function death_knight_frost_nova:OnAbilityPhaseStart()
    local hCaster = self:GetCaster()

    return true
end
function death_knight_frost_nova:OnAbilityPhaseInterrupted()
    local hCaster = self:GetCaster()

    return true
end
function death_knight_frost_nova:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end
function death_knight_frost_nova:OnSpellStart()
    local hCaster = self:GetCaster()
    local hTarget = self:GetCursorTarget()
    local radius = self:GetSpecialValueFor("radius")
    local main_target_damage_pct = self:GetSpecialValueFor("main_target_damage_pct")
    local ap_factor_hit = self:GetSpecialValueFor("ap_factor_hit")
    local duration = self:GetSpecialValueFor("duration")
    local nova_bonus_damage_pct = self:GetSpecialValueFor("nova_bonus_damage_pct")
    local mana_get = self:GetSpecialValueFor("mana_get")
    local fDamage = hCaster:GetDamageforAbility(ABILITY_DAMAGE_CALCULATE_TYPE_AP) * ap_factor_hit * 0.01

    if hCaster:HasModifier("modifier_death_knight_mortal_strike_free_nova") then
        fDamage = fDamage * (100 + nova_bonus_damage_pct) * 0.01
    end

    hCaster:CGiveMana(hCaster:GetMaxMana() * mana_get * 0.01, self, hCaster)

    local particleID = ParticleManager:CreateParticle("particles/units/heroes/death_knight/death_knight_frost_nova.vpcf", PATTACH_ABSORIGIN_FOLLOW, hTarget)
    ParticleManager:ReleaseParticleIndex(particleID)

    EmitSoundOn("Ability.FrostNova", hTarget)
    
    if IsServer() then
        local enemies = FindUnitsInRadius(hCaster:GetTeamNumber(), hTarget:GetAbsOrigin(), nil, radius, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)
        for _, enemy in pairs(enemies) do
            if IsValid(enemy) and enemy:IsAlive()then
                local this_damage = fDamage
                if enemy == hTarget then
                    this_damage = this_damage * (100 + main_target_damage_pct) * 0.01
                end

                ApplyDamage({
                    victim = enemy,
                    attacker = hCaster,
                    damage = this_damage,
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    ability = self,
                    damage_flags = DOTA_DAMAGE_FLAG_DIRECT,
                })

                enemy:AddNewModifier(hCaster, self, "modifier_death_knight_frost_nova", {duration = duration})
            end
        end
    end

    if hCaster:HasModifier("modifier_death_knight_mortal_strike_free_nova") then
        self:EndCooldown()
        hCaster:RemoveModifierByName("modifier_death_knight_mortal_strike_free_nova")
    end

end
--modifiers
if modifier_death_knight_frost_nova == nil then
	modifier_death_knight_frost_nova = class({})
end
function modifier_death_knight_frost_nova:IsHidden()
    return false
end
function modifier_death_knight_frost_nova:IsDebuff()
    return true
end 
function modifier_death_knight_frost_nova:IsPurgable()
    return true
end
function modifier_death_knight_frost_nova:GetStatusEffectName()
    return "particles/status_fx/status_effect_iceblast.vpcf"
end
function modifier_death_knight_frost_nova:StatusEffectPriority()
    return 1
end
function modifier_death_knight_frost_nova:OnCreated(params)
    self.ap_factor_dot = self:GetAbilitySpecialValueFor("ap_factor_dot")
    self.dot_interval = self:GetAbilitySpecialValueFor("dot_interval")
    self.mana_get_tick = self:GetAbilitySpecialValueFor("mana_get_tick")

    if IsServer() then
        self:StartIntervalThink(self.dot_interval)
        self:OnIntervalThink()
    end
end
function modifier_death_knight_frost_nova:OnRefresh(params)
    self.ap_factor_dot = self:GetAbilitySpecialValueFor("ap_factor_dot")
    self.dot_interval = self:GetAbilitySpecialValueFor("dot_interval")
    self.mana_get_tick = self:GetAbilitySpecialValueFor("mana_get_tick")
    if IsServer() then
        self:OnIntervalThink()
    end
end
function modifier_death_knight_frost_nova:OnIntervalThink()
    if IsServer() then
        local hCaster = self:GetCaster()
        local hTarget = self:GetParent()
        local fDamage = hCaster:GetDamageforAbility(ABILITY_DAMAGE_CALCULATE_TYPE_AP) * self.ap_factor_dot * 0.01

        ApplyDamage({
            victim = hTarget,
            attacker = hCaster,
            damage = fDamage,
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability = self:GetAbility(),
            damage_flags = DOTA_DAMAGE_FLAG_INDIRECT,
        })
        hCaster:CGiveMana(hCaster:GetMaxMana() * self.mana_get_tick * 0.01, self:GetAbility(), hCaster)
    end
end