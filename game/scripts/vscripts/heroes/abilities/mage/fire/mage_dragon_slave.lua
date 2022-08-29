LinkLuaModifier( "modifier_mage_dragon_slave", "heroes/abilities/mage/fire/mage_dragon_slave.lua", LUA_MODIFIER_MOTION_NONE )
if  mage_dragon_slave == nil then
    mage_dragon_slave = class({})
end
--ability
function mage_dragon_slave:GetCastAnimation()
	local hCaster = self:GetCaster()
	if hCaster:GetUnitName() == "npc_dota_hero_lina" then
		return ACT_DOTA_CAST_ABILITY_1
	elseif hCaster:GetUnitName() == "npc_dota_hero_silencer" then
		return ACT_DOTA_ATTACK
	end
end
function mage_dragon_slave:GetIntrinsicModifierName()
    return "modifier_mage_dragon_slave"
end
function mage_dragon_slave:OnSpellStart()
    local hCaster = self:GetCaster()
    local hTarget = self:GetCursorTarget()

    self:blast(hTarget)
end
function mage_dragon_slave:blast(hTarget)
    local hCaster = self:GetCaster()
    local blast_Target = hTarget
    local speed = self:GetSpecialValueFor("speed")

    local info = {
        Target = blast_Target,
        Source = hCaster,
        Ability = self,		
        EffectName = "particles/units/heroes/mage/mage_dragon_slave.vpcf",
        iMoveSpeed = speed,
        bDodgeable = true,                           
        vSourceLoc = hCaster:GetAbsOrigin(),               
        bIsAttack = false,                                
        ExtraData = {},
        }

    ProjectileManager:CreateTrackingProjectile(info)

    EmitSoundOn("Hero_Lina.DragonSlave", hCaster)
end
function mage_dragon_slave:OnProjectileHit_ExtraData(hTarget, vLocation, ExtraData)
    if not IsServer() then
        return
    end
    local hCaster = self:GetCaster()
    local sp_factor = self:GetSpecialValueFor("sp_factor")
    local radius = self:GetSpecialValueFor("radius")
    local duration = self:GetSpecialValueFor("duration")

    local enemies = FindUnitsInRadius(hCaster:GetTeamNumber(), hTarget:GetAbsOrigin(), nil, radius, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)
    for _, enemy in pairs(enemies) do
        if IsValid(enemy) and enemy:IsAlive() then
            ApplyDamage({
                victim = enemy,
                attacker = hCaster,
                damage = hCaster:GetDamageforAbility(ABILITY_DAMAGE_CALCULATE_TYPE_SP) * sp_factor * 0.01,
                damage_type = DAMAGE_TYPE_MAGICAL,
                ability = self,
                damage_flags = DOTA_DAMAGE_FLAG_DIRECT,
            })
        end
    end

    local debuff = hTarget:FindModifierByNameAndCaster("modifier_mage_liquid_fire_debuff", hCaster)
    if debuff ~= nil then
        local damage_pool = debuff.damage_pool
        for _, enemy in pairs(enemies) do
            if enemy ~= nil and enemy:IsAlive() and enemy ~= hCaster then
                enemy:AddNewModifier(hCaster, self, "modifier_mage_liquid_fire_debuff", {duration = duration, damage_pool = damage_pool})
            end
        end
    end

    local particleID = ParticleManager:CreateParticle("particles/units/heroes/hero_jakiro/jakiro_liquid_fire_explosion.vpcf", PATTACH_ABSORIGIN_FOLLOW, hTarget)
    ParticleManager:SetParticleControl(particleID, 1, Vector(radius, 0, 0))
    ParticleManager:ReleaseParticleIndex(particleID)

end

--=======================================modifier_mage_dragon_slave=======================================
if modifier_mage_dragon_slave == nil then
    modifier_mage_dragon_slave = class({})
end
function modifier_mage_dragon_slave:IsHidden()
    return true
end
function modifier_mage_dragon_slave:IsDebuff()
    return false
end
function modifier_mage_dragon_slave:IsPurgable()
    return false
end
function modifier_mage_dragon_slave:IsPurgeException()
    return false
end
function modifier_mage_dragon_slave:OnCreated(params)
end
function modifier_mage_dragon_slave:OnRefresh(params)
end
function modifier_mage_dragon_slave:OnDestroy(params)
end
function modifier_mage_dragon_slave:DeclareFunctions()
    return {
    }
end
function modifier_mage_dragon_slave:CDeclareFunctions()
    return {
        CMODIFIER_PROPERTY_BONUS_MAGICAL_CRIT_CHANCE_CONSTANT
    }
end
function modifier_mage_dragon_slave:C_GetModifierBonusMagicalCritChance_Constant( params )
    if params.inflictor ~= nil and params.inflictor == self:GetAbility() then
        return 100
    end
    return 0
end
