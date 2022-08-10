LinkLuaModifier( "modifier_neutral_mine_boom", "units/abilities/dungeon/kobold_mine_cave/neutral_mine_boom.lua", LUA_MODIFIER_MOTION_NONE )
--=======================================neutral_mine_boom=======================================
if neutral_mine_boom == nil then
    neutral_mine_boom = class({})
end
function neutral_mine_boom:GetIntrinsicModifierName()
    return "modifier_neutral_mine_boom"
end
--=======================================modifier_neutral_mine_boom=======================================
if modifier_neutral_mine_boom == nil then
    modifier_neutral_mine_boom = class({})
end
function modifier_neutral_mine_boom:IsHidden()
    return true
end
function modifier_neutral_mine_boom:IsDebuff()
    return false
end
function modifier_neutral_mine_boom:IsPurgable()
    return false
end
function modifier_neutral_mine_boom:IsPurgeException()
    return false
end
function modifier_neutral_mine_boom:OnCreated(params)
    self.radius = self:GetAbilitySpecialValueFor("radius")
    self.damage = self:GetAbilitySpecialValueFor("damage")
    self.delay = self:GetAbilitySpecialValueFor("delay")
    self.bExpoded = false
end
function modifier_neutral_mine_boom:OnRefresh(params)
end
function modifier_neutral_mine_boom:OnDestroy(params)
end
function modifier_neutral_mine_boom:DeclareFunctions()
    return {
    }
end
function modifier_neutral_mine_boom:CDeclareFunctions()
    return {
    }
end
function modifier_neutral_mine_boom:CheckState()
    local hCaster = self:GetCaster()

    local enemies = FindUnitsInRadius(hCaster:GetTeamNumber(), hCaster:GetAbsOrigin(), nil, self.radius, self:GetAbility():GetAbilityTargetTeam(), self:GetAbility():GetAbilityTargetType(), self:GetAbility():GetAbilityTargetFlags(), FIND_ANY_ORDER, false)
    if self.expode_time ~= nil and self.expode_time <= GameRules:GetGameTime() and not self.bExpoded then
        for _, enemy in pairs(enemies) do
            if IsValid(enemy) and enemy:IsAlive() then
                ApplyDamage({
                    victim = enemy,
                    attacker = hCaster,
                    damage = self.damage,
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    ability = self:GetAbility(),
                damage_flags = DOTA_DAMAGE_FLAG_DIRECT,
                })
            end
        end
        EmitSoundOnLocationWithCaster(hCaster:GetAbsOrigin(), "Hero_Techies.StickyBomb.Detonate", hCaster)
        local particleID = ParticleManager:CreateParticle("particles/units/heroes/hero_techies/techies_land_mine_explode.vpcf", PATTACH_CUSTOMORIGIN, nil)
        ParticleManager:SetParticleControl(particleID, 0, hCaster:GetAbsOrigin())
        ParticleManager:SetParticleControl(particleID, 1, Vector(self.radius, 0, 0))
        ParticleManager:ReleaseParticleIndex(particleID)
        hCaster:ForceKill(false)
        self.bExpoded = true
    end
    
    if #enemies > 0 then
        if self.expode_time == nil then
            self.expode_time = GameRules:GetGameTime() + self.delay
            EmitSoundOnLocationWithCaster(hCaster:GetAbsOrigin(), "Hero_Techies.StickyBomb.Priming", hCaster)
        end
        return {
            [MODIFIER_STATE_INVISIBLE] = false,
            [MODIFIER_STATE_INVULNERABLE] = true,
            [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
            [MODIFIER_STATE_UNSELECTABLE] = true,
            [MODIFIER_STATE_STUNNED] = true,
            [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        }
    else
        return {
        [MODIFIER_STATE_INVISIBLE] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
    }
    end
    
    
end