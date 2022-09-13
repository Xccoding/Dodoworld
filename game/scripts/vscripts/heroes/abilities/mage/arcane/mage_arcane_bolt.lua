if mage_arcane_bolt == nil then
    mage_arcane_bolt = class({})
end
LinkLuaModifier("modifier_mage_arcane_bolt", "heroes/abilities/mage/arcane/mage_arcane_bolt.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mage_arcane_bolt_channel", "heroes/abilities/mage/arcane/mage_arcane_bolt.lua", LUA_MODIFIER_MOTION_NONE)
--ability
function mage_arcane_bolt:GetChannelAnimation()
    return ACT_DOTA_GENERIC_CHANNEL_1
end
function mage_arcane_bolt:GetChannelTime()
    local hCaster = self:GetCaster()
    if self.arcane_bolt_buff ~= nil and self.arcane_bolt_buff > 0 then
        return self:GetSpecialValueFor("duration") * (100 - self:GetSpecialValueFor("energy_duration_reduce_pct")) * 0.01
    end
    return self:GetSpecialValueFor("duration")
end
function mage_arcane_bolt:GetManaCost(iLevel)
    local hCaster = self:GetCaster()
    if self.arcane_bolt_buff ~= nil and self.arcane_bolt_buff > 0 then
        return 0
    end
    return self:GetSpecialValueFor("mana_cost_pct") * hCaster:GetMaxMana() * 0.01
end
function mage_arcane_bolt:GetIntrinsicModifierName()
    return "modifier_mage_arcane_bolt"
end
function mage_arcane_bolt:C_OnSpellStart()
    local hCaster = self:GetCaster()
    local hTarget = self:GetCursorTarget()
    local duration = self:GetSpecialValueFor("duration")
    local base_count = self:GetSpecialValueFor("base_count")
    local energy_duration_reduce_pct = self:GetSpecialValueFor("energy_duration_reduce_pct")
    local energy_bonus_count = self:GetSpecialValueFor("energy_bonus_count")
    local fDuration = duration
    local fInterval = duration / (base_count - 1) - 0.01

    if self.arcane_bolt_buff ~= nil and self.arcane_bolt_buff > 0 then
        fDuration = duration * (100 - energy_duration_reduce_pct) * 0.01
        fInterval = fDuration / (base_count + energy_bonus_count - 1) - 0.01
        hCaster:FindModifierByName("modifier_mage_arcane_bolt"):DecrementStackCount()
    end

    hCaster:AddNewModifier(hCaster, self, "modifier_mage_arcane_bolt_channel", { duration = fDuration, interval = fInterval, index = hTarget:entindex() })
end
function mage_arcane_bolt:C_OnChannelFinish(bInterrupted)
    local hCaster = self:GetCaster()
    StopSoundOn("Hero_SkywrathMage.ArcaneBolt.Cast", hCaster)
    hCaster:RemoveModifierByName("modifier_mage_arcane_bolt_channel")
end
function mage_arcane_bolt:bolt(hTarget)
    local hCaster = self:GetCaster()
    local blast_Target = hTarget
    local speed = self:GetSpecialValueFor("speed")

    local info = {
        Target = blast_Target,
        Source = hCaster,
        Ability = self,    
        EffectName = "particles/units/heroes/hero_skywrath_mage/skywrath_mage_arcane_bolt.vpcf",
        iMoveSpeed = speed,
        bDodgeable = true,                    
        vSourceLoc = hCaster:GetAbsOrigin(),        
        bIsAttack = false,                            
        ExtraData = {},
    }

    ProjectileManager:CreateTrackingProjectile(info)

    EmitSoundOn("Hero_SkywrathMage.ArcaneBolt.Cast", hCaster)
end
function mage_arcane_bolt:OnProjectileHit_ExtraData(hTarget, vLocation, ExtraData)
    if not IsServer() then
        return
    end
    local hCaster = self:GetCaster()
    local sp_factor = self:GetSpecialValueFor("sp_factor")

    ApplyDamage({
        victim = hTarget,
        attacker = hCaster,
        damage = hCaster:GetDamageforAbility(ABILITY_DAMAGE_CALCULATE_TYPE_SP) * sp_factor * 0.01,
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = self,
        damage_flags = DOTA_DAMAGE_FLAG_DIRECT,
    })

    EmitSoundOn("Hero_SkywrathMage.ArcaneBolt.Impact", hTarget)
end
--节能施法监控modifiers
if modifier_mage_arcane_bolt == nil then
    modifier_mage_arcane_bolt = class({})
end
function modifier_mage_arcane_bolt:IsHidden()
    if self:GetStackCount() >= 1 then
        return false
    end
    return true
end
function modifier_mage_arcane_bolt:IsDebuff()
    return false
end
function modifier_mage_arcane_bolt:IsPurgable()
    return false
end
function modifier_mage_arcane_bolt:GetAttributes()
    return MODIFIER_ATTRIBUTE_PERMANENT
end
function modifier_mage_arcane_bolt:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_SPENT_MANA,
        MODIFIER_PROPERTY_TOOLTIP,
    }
end
function modifier_mage_arcane_bolt:GetAbilityValues()
    self.energy_chance = self:GetAbilitySpecialValueFor("energy_chance")
    self.energy_threshold = self:GetAbilitySpecialValueFor("energy_threshold")
    self.max_stack = self:GetAbilitySpecialValueFor("max_stack")
end
function modifier_mage_arcane_bolt:OnCreated(params)
    self:GetAbilityValues()
    self:SetStackCount(0)
    self:StartIntervalThink(0)
end
function modifier_mage_arcane_bolt:OnRefresh(params)
    self:GetAbilityValues()
end
function modifier_mage_arcane_bolt:OnIntervalThink()
    local hCaster = self:GetCaster()
    if IsServer() then
        if self:GetStackCount() >= 1 then
            if self.particleID == nil then
                self.particleID = ParticleManager:CreateParticleForPlayer("particles/units/heroes/mage/mage_arcane_bolt_buff.vpcf", PATTACH_ABSORIGIN_FOLLOW, hCaster, hCaster:GetPlayerOwner())
            end
            if self:GetStackCount() > self.max_stack then
                self:SetStackCount(self.max_stack)
            end
        else
            if self.particleID ~= nil then
                ParticleManager:DestroyParticle(self.particleID, false)
                self.particleID = nil
            end
        end
    end
    hCaster:FindAbilityByName("mage_arcane_bolt").arcane_bolt_buff = self:GetStackCount()
    
    if hCaster:FindAbilityByName("mage_resonant_pulse") ~= nil then
        hCaster:FindAbilityByName("mage_resonant_pulse").arcane_bolt_buff = self:GetStackCount()
    end
end
function modifier_mage_arcane_bolt:GetTexture()
    return "mage/mage_arcane_bolt_buff"
end
function modifier_mage_arcane_bolt:OnDestroy()
    if self.particleID ~= nil then
        ParticleManager:DestroyParticle(self.particleID, false)
        self.particleID = nil
    end
end
function modifier_mage_arcane_bolt:OnTooltip()
    return self:GetStackCount()
end
function modifier_mage_arcane_bolt:OnSpentMana(params)
    if IsServer() then
        if params.unit == self:GetParent() then
            local hCaster = params.unit
            local mana = params.cost
            local chance = math.floor(mana / (hCaster:GetMaxMana() * self.energy_threshold * 0.01)) * self.energy_chance
            if RandomFloat(0, 100) < chance then
                hCaster:SetContextThink(DoUniqueString("modifier_mage_arcane_bolt"), function()
                    hCaster:FindModifierByName("modifier_mage_arcane_bolt"):IncrementStackCount()
                    EmitSoundOnEntityForPlayer("Rune.Arcane", hCaster, hCaster:GetPlayerOwnerID())
                end, FrameTime())
            end
        end
    end
end
--飞弹modifiers
if modifier_mage_arcane_bolt_channel == nil then
    modifier_mage_arcane_bolt_channel = class({})
end
function modifier_mage_arcane_bolt_channel:IsHidden()
    return true
end
function modifier_mage_arcane_bolt_channel:IsDebuff()
    return false
end
function modifier_mage_arcane_bolt_channel:IsPurgable()
    return false
end
function modifier_mage_arcane_bolt_channel:OnCreated(params)
    if IsServer() then
        self.hTarget = EntIndexToHScript(params.index)
        self.interval = params.interval
        self:StartIntervalThink(self.interval)
        self:OnIntervalThink()
    end
end
function modifier_mage_arcane_bolt_channel:OnIntervalThink()
    if IsServer() then
        local hCaster = self:GetCaster()
        local hAbility = self:GetAbility()    
        if (not self.hTarget:IsNull()) and self.hTarget ~= nil then
            if not hAbility:IsNull() and hAbility ~= nil then
                hAbility:bolt(self.hTarget)
            end
        end
    end
end