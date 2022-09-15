LinkLuaModifier("modifier_mage_chaos_meteor", "heroes/abilities/mage/fire/mage_chaos_meteor.lua", LUA_MODIFIER_MOTION_NONE)
--=======================================mage_chaos_meteor=======================================
if mage_chaos_meteor == nil then
    mage_chaos_meteor = class({})
end
function mage_chaos_meteor:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end
function mage_chaos_meteor:C_OnSpellStart()
    local hCaster = self:GetCaster()
    local vPos = self:GetCursorPosition()
    local delay = self:GetSpecialValueFor("delay")
    local sp_factor = self:GetSpecialValueFor("sp_factor")
    local radius = self:GetSpecialValueFor("radius")
    local duration = self:GetSpecialValueFor("duration")

    EmitSoundOn("Hero_Invoker.ChaosMeteor.Cast", hCaster)
    EmitSoundOn("Hero_Invoker.ChaosMeteor.Loop", hCaster)

    local particleID = ParticleManager:CreateParticle("particles/units/heroes/mage/mage_chaos_meteor_fly.vpcf", PATTACH_CUSTOMORIGIN, hCaster)
    ParticleManager:SetParticleControl(particleID, 0, hCaster:GetAbsOrigin() + Vector(0, 0, 1300))
    ParticleManager:SetParticleControl(particleID, 1, vPos + Vector(0, 0, 40))
    ParticleManager:SetParticleControl(particleID, 2, Vector(delay + 0.1, 0, 0))
    ParticleManager:ReleaseParticleIndex(particleID)

    hCaster:SetContextThink(DoUniqueString("mage_chaos_meteor"), function()
        StopSoundOn("Hero_Invoker.ChaosMeteor.Loop", hCaster)
        EmitSoundOnLocationWithCaster(vPos, "Hero_Invoker.ChaosMeteor.Impact", hCaster)

        local explode_particleID = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_chaos_meteor.vpcf", PATTACH_CUSTOMORIGIN, hCaster)
        ParticleManager:SetParticleControl(explode_particleID, 0, vPos)
        ParticleManager:SetParticleControl(explode_particleID, 1, Vector(1, 0, 0))
        ParticleManager:DestroyParticle(explode_particleID, false)
        ParticleManager:ReleaseParticleIndex(explode_particleID)

        local damage_array = {}
        local enemies = FindUnitsInRadius(hCaster:GetTeamNumber(), vPos, nil, radius, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)
        for _, enemy in pairs(enemies) do
            if IsValid(enemy) and enemy:IsAlive() then
                table.insert(damage_array, enemy)
            end
        end

        local damage_per_enemy = (hCaster:GetDamageforAbility(ABILITY_DAMAGE_CALCULATE_TYPE_SP) * sp_factor * 0.01) / (#damage_array)

        for _, enemy in pairs(damage_array) do
            if IsValid(enemy) and enemy:IsAlive() then
                ApplyDamage({
                    victim = enemy,
                    attacker = hCaster,
                    damage = damage_per_enemy,
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    ability = self,
                    damage_flags = DOTA_DAMAGE_FLAG_DIRECT,
                })
            end
        end

        CreateModifierThinker(hCaster, self, "modifier_mage_chaos_meteor", { duration = duration }, vPos, hCaster:GetTeamNumber(), false)

        return nil
    end, delay)

end
--=======================================modifier_mage_chaos_meteor=======================================
if modifier_mage_chaos_meteor == nil then
    modifier_mage_chaos_meteor = class({})
end
function modifier_mage_chaos_meteor:IsHidden()
    return true
end
function modifier_mage_chaos_meteor:IsDebuff()
    return false
end
function modifier_mage_chaos_meteor:IsPurgable()
    return false
end
function modifier_mage_chaos_meteor:IsPurgeException()
    return false
end
function modifier_mage_chaos_meteor:GetAbilityValues()
    self.sp_factor_ps = self:GetAbilitySpecialValueFor("sp_factor_ps")
    self.radius = self:GetAbilitySpecialValueFor("radius")
end
function modifier_mage_chaos_meteor:OnCreated(params)
    self:GetAbilityValues()
    if IsServer() then
        self:StartIntervalThink(1)
        local hParent = self:GetParent()
        local particleID = ParticleManager:CreateParticle("particles/units/heroes/mage/mage_chaos_meteor_fire.vpcf", PATTACH_CUSTOMORIGIN, hParent)
        ParticleManager:SetParticleControl(particleID, 0, hParent:GetAbsOrigin())
        ParticleManager:SetParticleControl(particleID, 1, hParent:GetAbsOrigin())
        ParticleManager:SetParticleControl(particleID, 2, Vector(self:GetDuration(), 0, 0))
        self:AddParticle(particleID, false, false, -1, false, false)
    end
end
function modifier_mage_chaos_meteor:OnRefresh(params)
    self:GetAbilityValues()
end
function modifier_mage_chaos_meteor:OnDestroy(params)
end
function modifier_mage_chaos_meteor:DeclareFunctions()
    return {
    }
end
function modifier_mage_chaos_meteor:CDeclareFunctions()
    return {
    }
end
function modifier_mage_chaos_meteor:OnIntervalThink()
    local hCaster = self:GetCaster()
    local hAbility = self:GetAbility()
    local hParent = self:GetParent()

    local enemies = FindUnitsInRadius(hCaster:GetTeamNumber(), hParent:GetAbsOrigin(), nil, self.radius, hAbility:GetAbilityTargetTeam(), hAbility:GetAbilityTargetType(), hAbility:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)
    for _, enemy in pairs(enemies) do
        if IsValid(enemy) and enemy:IsAlive() then
            ApplyDamage({
                victim = enemy,
                attacker = hCaster,
                damage = hCaster:GetDamageforAbility(ABILITY_DAMAGE_CALCULATE_TYPE_SP) * self.sp_factor_ps * 0.01,
                damage_type = DAMAGE_TYPE_MAGICAL,
                ability = hAbility,
                damage_flags = DOTA_DAMAGE_FLAG_INDIRECT,
            })
        end
    end
end