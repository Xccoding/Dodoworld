LinkLuaModifier("modifier_mine_owner_kobold_open_wound", "units/abilities/dungeon/kobold_mine_cave/mine_owner_kobold_open_wound.lua", LUA_MODIFIER_MOTION_NONE)
--=======================================mine_owner_kobold_open_wound=======================================
if mine_owner_kobold_open_wound == nil then
    mine_owner_kobold_open_wound = class({})
end
function mine_owner_kobold_open_wound:OnAbilityPhaseStart()
    local hCaster = self:GetCaster()
    EmitSoundOn("Item.Bullwhip.Cast", hCaster)
    return true
end
function mine_owner_kobold_open_wound:OnSpellStart()
    local hCaster = self:GetCaster()
    local hTarget = self:GetCursorTarget()
    local duration = self:GetSpecialValueFor("duration")

    EmitSoundOn("Item.Bullwhip.Enemy", hTarget)
    
    local particleID = ParticleManager:CreateParticle("particles/units/neutrals/mine_owner_kobold/mine_owner_kobold_open_wound.vpcf", PATTACH_CUSTOMORIGIN, hCaster)
    ParticleManager:SetParticleControlEnt(particleID, 0, hCaster, PATTACH_POINT_FOLLOW, "attach_attack", Vector(0, 0, 0), false)
    ParticleManager:SetParticleControlEnt(particleID, 1, hTarget, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0, 0, 0), false)
    ParticleManager:ReleaseParticleIndex(particleID)

    hTarget:AddNewModifier(hCaster, self, "modifier_mine_owner_kobold_open_wound", { duration = duration })
end
--=======================================modifier_mine_owner_kobold_open_wound=======================================
if modifier_mine_owner_kobold_open_wound == nil then
    modifier_mine_owner_kobold_open_wound = class({})
end
function modifier_mine_owner_kobold_open_wound:IsHidden()
    return false
end
function modifier_mine_owner_kobold_open_wound:IsDebuff()
    return true
end
function modifier_mine_owner_kobold_open_wound:IsPurgable()
    return false
end
function modifier_mine_owner_kobold_open_wound:IsPurgeException()
    return false
end
function modifier_mine_owner_kobold_open_wound:OnCreated(params)
    local hCaster = self:GetCaster()
    local hParent = self:GetParent()
    self.dot_interval = self:GetAbilitySpecialValueFor("dot_interval")
    self.damage = self:GetAbilitySpecialValueFor("damage")
    if IsServer() then
        EmitSoundOn("Hero_LifeStealer.OpenWounds.Cast", hParent)
        self:SetStackCount(1)
        self:StartIntervalThink(self.dot_interval)
    end
end
function modifier_mine_owner_kobold_open_wound:OnRefresh(params)
    if IsServer() then
        self:IncrementStackCount()
    end
end
function modifier_mine_owner_kobold_open_wound:OnDestroy(params)
end
function modifier_mine_owner_kobold_open_wound:OnStackCountChanged(iStackCount)
    if self:GetStackCount() <= 0 then
        self:Destroy()
    end
end
function modifier_mine_owner_kobold_open_wound:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_TOOLTIP,
        MODIFIER_PROPERTY_TOOLTIP2,
    }
end
function modifier_mine_owner_kobold_open_wound:CDeclareFunctions()
    return {
    }
end
function modifier_mine_owner_kobold_open_wound:OnIntervalThink()
    local hCaster = self:GetCaster()
    local hParent = self:GetParent()
    
    ApplyDamage({
        victim = hParent,
        attacker = hCaster,
        damage = self:GetStackCount() * self.damage,
        damage_type = DAMAGE_TYPE_PHYSICAL,
        ability = self:GetAbility(),
        damage_flags = DOTA_DAMAGE_FLAG_INDIRECT,
    })
end
function modifier_mine_owner_kobold_open_wound:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_mine_owner_kobold_open_wound:GetEffectName()
    return "particles/units/heroes/hero_life_stealer/life_stealer_open_wounds.vpcf"
end
function modifier_mine_owner_kobold_open_wound:OnTooltip()
    return self.dot_interval
end
function modifier_mine_owner_kobold_open_wound:OnTooltip2()
    return self.damage * self:GetStackCount()
end
function modifier_mine_owner_kobold_open_wound:RemoveOnCombatEnd()
	return true
end