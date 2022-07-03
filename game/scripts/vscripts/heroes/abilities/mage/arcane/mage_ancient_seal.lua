if  mage_ancient_seal == nil then
    mage_ancient_seal = class({})
end
LinkLuaModifier( "modifier_mage_ancient_seal", "heroes/abilities/mage/arcane/mage_ancient_seal.lua", LUA_MODIFIER_MOTION_NONE )
--ability
function mage_ancient_seal:GetManaCost(iLevel)
    local hCaster = self:GetCaster()
    return self:GetSpecialValueFor("mana_cost_pct") * hCaster:GetMaxMana() * 0.01
end
function mage_ancient_seal:OnSpellStart()
    local hCaster = self:GetCaster()
    local hTarget = self:GetCursorTarget()
    local duration = self:GetSpecialValueFor("duration")
    local stack_per_time = self:GetSpecialValueFor("stack_per_time")

    EmitSoundOn("Hero_SkywrathMage.AncientSeal.Target", hTarget)
    
    hTarget:AddNewModifier(hCaster, self, "modifier_mage_ancient_seal", {duration = duration})

    --增加充能
	local arcane_buff = hCaster:FindModifierByName("modifier_mage_concussive_shot")
	if arcane_buff ~= nil then
        for i = 1, stack_per_time do
            if arcane_buff:GetStackCount() < arcane_buff.max_stack then
                arcane_buff:IncrementStackCount()
            end
        end
	end
end
--上古封印modifiers
if modifier_mage_ancient_seal == nil then
	modifier_mage_ancient_seal = class({})
end
function modifier_mage_ancient_seal:IsHidden()
    return false
end
function modifier_mage_ancient_seal:IsDebuff()
    return true
end 
function modifier_mage_ancient_seal:IsPurgable()
    return true
end
function modifier_mage_ancient_seal:OnCreated(params)
    local hCaster = self:GetCaster()
    local hTarget = self:GetParent()
    self.save_pct = self:GetAbilitySpecialValueFor("save_pct")
    self.radius = self:GetAbilitySpecialValueFor("radius")
    self.damage_pool = 0
    if IsServer() then
        local particleID = ParticleManager:CreateParticleForPlayer("particles/units/heroes/mage/mage_ancient_sealrune.vpcf", PATTACH_ABSORIGIN_FOLLOW, hTarget, hCaster:GetPlayerOwner())
        -- ParticleManager:SetParticleControlEnt(particleID, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0, 0, 0), false)
        -- ParticleManager:SetParticleControlEnt(particleID, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0, 0, 0), false)
        self:AddParticle(particleID, false, false, -1, false, true)
    end
end
function modifier_mage_ancient_seal:OnRefresh(params)
    self.save_pct = self:GetAbilitySpecialValueFor("save_pct")
    self.radius = self:GetAbilitySpecialValueFor("radius")
end
function modifier_mage_ancient_seal:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_PROPERTY_TOOLTIP,
    }
end
function modifier_mage_ancient_seal:OnTakeDamage( params )
    if params.attacker == self:GetCaster() then
        self.damage_pool = self.damage_pool + math.floor(params.damage * self.save_pct * 0.01)
        self:SetStackCount(math.floor(self.damage_pool))
    end
end
function modifier_mage_ancient_seal:OnDestroy()
    local hCaster = self:GetCaster()
    local hTarget = self:GetParent()
    local hAbility = self:GetAbility()
    if IsServer() then
        local particleID = ParticleManager:CreateParticle("particles/units/heroes/hero_obsidian_destroyer/obsidian_destroyer_sanity_eclipse_area.vpcf", PATTACH_CUSTOMORIGIN, hCaster)
        ParticleManager:SetParticleControl(particleID, 0, hTarget:GetAbsOrigin())
        ParticleManager:SetParticleControl(particleID, 1, Vector(self.radius, 0, 0))
        ParticleManager:ReleaseParticleIndex(particleID)

        local enemies = FindUnitsInRadius(hCaster:GetTeamNumber(), hTarget:GetAbsOrigin(), nil, self.radius, hAbility:GetAbilityTargetTeam(), hAbility:GetAbilityTargetType(), hAbility:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)
        for _, enemy in pairs(enemies) do
            if enemy ~= nil and enemy:IsAlive() then
                ApplyDamage({
                    victim = enemy,
                    attacker = hCaster,
                    damage = self.damage_pool,
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    ability = self,
                    damage_flags = DOTA_DAMAGE_FLAG_DIRECT,
                })
            end
        end
        EmitSoundOnLocationWithCaster(hTarget:GetAbsOrigin(), "Hero_ObsidianDestroyer.SanityEclipse", hCaster)
    end
end
function modifier_mage_ancient_seal:OnTooltip()
    return self:GetStackCount()
end
