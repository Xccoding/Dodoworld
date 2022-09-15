LinkLuaModifier("modifier_mage_searing_arrows", "heroes/abilities/mage/fire/mage_searing_arrows.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mage_searing_arrows_burning_arrows", "heroes/abilities/mage/fire/mage_searing_arrows.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if mage_searing_arrows == nil then
    mage_searing_arrows = class({})
end
function mage_searing_arrows:GetIntrinsicModifierName()
    return "modifier_mage_searing_arrows"
end
function mage_searing_arrows:C_OnSpellStart()
    local hCaster = self:GetCaster()
    local hTarget = self:GetCursorTarget()
    local speed = self:GetSpecialValueFor("speed")

    local info = {
        Target = hTarget,
        Source = hCaster,
        Ability = self,
        EffectName = "particles/units/heroes/hero_clinkz/clinkz_searing_arrow.vpcf",
        iMoveSpeed = speed,
        bDodgeable = true,
        vSourceLoc = hCaster:GetAbsOrigin(),
        bIsAttack = false,    
        ExtraData = {},
    }

    ProjectileManager:CreateTrackingProjectile(info)

    EmitSoundOn("Hero_Clinkz.SearingArrows", hCaster)
end
function mage_searing_arrows:GetManaCost(iLevel)
    local hCaster = self:GetCaster()
    return self:GetSpecialValueFor("mana_cost_pct") * hCaster:GetMaxMana() * 0.01
end
function mage_searing_arrows:OnProjectileHit_ExtraData(hTarget, vLocation, ExtraData)
    if IsValid(hTarget) then
        local hCaster = self:GetCaster()
        local sp_factor = self:GetSpecialValueFor("sp_factor")
        local burning_arrows_duration = self:GetSpecialValueFor("burning_arrows_duration")

        EmitSoundOn("Hero_Clinkz.SearingArrows.Impact", hTarget)

        if burning_arrows_duration > 0 then
            hTarget:AddNewModifier(hCaster, self, "modifier_mage_searing_arrows_burning_arrows", {duration = burning_arrows_duration})
        end

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
---------------------------------------------------------------------
--Modifiers
if modifier_mage_searing_arrows == nil then
    modifier_mage_searing_arrows = class({})
end
function modifier_mage_searing_arrows:IsHidden()
    if self:GetAbility():GetLevel() >= 2 then
        return false
    else
        return true
    end
end
function modifier_mage_searing_arrows:IsPurgable()
    return false
end
function modifier_mage_searing_arrows:RemoveOnDeath()
    return false
end
function modifier_mage_searing_arrows:GetAbilityValues()
    self.bonus_crit_chance = self:GetAbilitySpecialValueFor("bonus_crit_chance")
    self.crit_hp_pct = self:GetAbilitySpecialValueFor("crit_hp_pct")
    self.burning_arrows_duration = self:GetAbilitySpecialValueFor("burning_arrows_duration")
    self.burning_arrows_sp_factor = self:GetAbilitySpecialValueFor("burning_arrows_sp_factor")
    self.burning_arrows_explode_chance = self:GetAbilitySpecialValueFor("burning_arrows_explode_chance")
    self.burning_arrows_explode_radius = self:GetAbilitySpecialValueFor("burning_arrows_explode_radius")
end
function modifier_mage_searing_arrows:OnCreated(params)
    self:GetAbilityValues()
end
function modifier_mage_searing_arrows:OnRefresh(params)
    self:GetAbilityValues()
end
function modifier_mage_searing_arrows:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_TOOLTIP,
        MODIFIER_EVENT_ON_MODIFIER_ADDED,
    }
end
function modifier_mage_searing_arrows:CDeclareFunctions()
    return {
        CMODIFIER_EVENT_ON_SPELL_CRIT,
        CMODIFIER_EVENT_ON_SPELL_NOTCRIT,
        CMODIFIER_PROPERTY_BONUS_MAGICAL_CRIT_CHANCE_CONSTANT,
    }
end
function modifier_mage_searing_arrows:C_OnSpellCrit(params)
    if not IsServer() then
        return
    end
    if self:IsHidden() then
        return
    end
    if params.inflictor ~= nil and params.inflictor == self:GetAbility() and params.attacker == self:GetParent() then
        self:SetStackCount(0)
    end
end
function modifier_mage_searing_arrows:C_OnSpellNotCrit(params)
    if not IsServer() then
        return
    end

    if self:IsHidden() then
        return
    end
    if params.inflictor ~= nil and params.inflictor == self:GetAbility() and params.attacker == self:GetParent() then
        if self:GetAbility():GetLevel() >= 2 then
            self:IncrementStackCount()
        end
    end
end
function modifier_mage_searing_arrows:C_GetModifierBonusMagicalCritChance_Constant(params)
    if params.inflictor ~= nil and params.inflictor == self:GetAbility() then
        if self.crit_hp_pct > 0 and params.target:GetHealthPercent() > self.crit_hp_pct then
            return 100
        end
        return self:GetStackCount() * self.bonus_crit_chance
    else
        return 0
    end
end
function modifier_mage_searing_arrows:OnTooltip()
    return self:GetStackCount() * self.bonus_crit_chance
end
function modifier_mage_searing_arrows:OnModifierAdded(params)
    local hParent = self:GetParent()
    local tBuff = params.added_buff
    local hCaster = tBuff:GetCaster()
    local hAbility = self:GetAbility()

    if hCaster == hParent and self.burning_arrows_duration > 0 then
        if tBuff:GetName() == "modifier_mage_searing_arrows_burning_arrows" or tBuff:GetName() == "modifier_mage_liquid_fire_debuff" then
            if RandomFloat(0, 100) <= self.burning_arrows_explode_chance then

                local particleID = ParticleManager:CreateParticle("particles/units/heroes/hero_clinkz/clinkz_burning_army_start.vpcf", PATTACH_CUSTOMORIGIN, hCaster)
                ParticleManager:SetParticleControl(particleID, 0, params.unit:GetAbsOrigin())
                ParticleManager:ReleaseParticleIndex(particleID)

                EmitSoundOn("Hero_Clinkz.WindWalk", params.unit)

                local enemies = FindUnitsInRadius(hCaster:GetTeamNumber(), params.unit:GetAbsOrigin(), nil, self.burning_arrows_explode_radius, hAbility:GetAbilityTargetTeam(), hAbility:GetAbilityTargetType(), hAbility:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)
                for _, enemy in pairs(enemies) do
                    if IsValid(enemy) and enemy:IsAlive() then
                        ApplyDamage({
                            victim = enemy,
                            attacker = hCaster,
                            damage = hCaster:GetDamageforAbility(ABILITY_DAMAGE_CALCULATE_TYPE_SP) * self.burning_arrows_sp_factor * 0.01,
                            damage_type = DAMAGE_TYPE_MAGICAL,
                            ability = hAbility,
                            damage_flags = DOTA_DAMAGE_FLAG_INDIRECT,
                        })
                    end
                end

            end
        end
    end
end
--=======================================modifier_mage_searing_arrows_burning_arrows=======================================
if modifier_mage_searing_arrows_burning_arrows == nil then
    modifier_mage_searing_arrows_burning_arrows = class({})
end
function modifier_mage_searing_arrows_burning_arrows:IsHidden()
    return true
end
function modifier_mage_searing_arrows_burning_arrows:IsDebuff()
    return false
end
function modifier_mage_searing_arrows_burning_arrows:IsPurgable()
    return false
end
function modifier_mage_searing_arrows_burning_arrows:IsPurgeException()
    return false
end
function modifier_mage_searing_arrows_burning_arrows:GetAbilityValues()
    self.burning_arrows_sp_factor_ps = self:GetAbilitySpecialValueFor("burning_arrows_sp_factor_ps")
    self.burning_arrows_dot_interval = self:GetAbilitySpecialValueFor("burning_arrows_dot_interval")
end
function modifier_mage_searing_arrows_burning_arrows:OnCreated(params)
    self:GetAbilityValues()
    if IsServer() then
        self:StartIntervalThink(self.burning_arrows_dot_interval)
    end
end
function modifier_mage_searing_arrows_burning_arrows:OnRefresh(params)
    self:GetAbilityValues()
end
function modifier_mage_searing_arrows_burning_arrows:OnDestroy(params)
end
function modifier_mage_searing_arrows_burning_arrows:DeclareFunctions()
    return {
    }
end
function modifier_mage_searing_arrows_burning_arrows:CDeclareFunctions()
    return {
    }
end
function modifier_mage_searing_arrows_burning_arrows:OnIntervalThink()
    local hCaster = self:GetCaster()
    local hParent = self:GetParent()
    local hAbility = self:GetAbility()
    
    ApplyDamage({
        victim = hParent,
        attacker = hCaster,
        damage = hCaster:GetDamageforAbility(ABILITY_DAMAGE_CALCULATE_TYPE_SP) * self.burning_arrows_sp_factor_ps * 0.01,
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = hAbility,
        damage_flags = DOTA_DAMAGE_FLAG_INDIRECT,
    })
end