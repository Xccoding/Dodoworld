require('ai.boss_base_ai')

if ai_creature_foreman_calgima == nil then
	ai_creature_foreman_calgima = class( boss_base_ai )
end

function Spawn( tEntityKeyValues )
    if IsServer() then
		if thisEntity == nil then
			return
		end

        thisEntity.current_order = {order = nil, fEndtime = nil}
		thisEntity.AI = ai_creature_foreman_calgima( thisEntity, 0.25 )

	end
end

function ai_creature_foreman_calgima:SetupBehaviors()
    boss_base_ai.SetupBehaviors(self)

    self.behaviors = {
        "NormalAttack",
        "foreman_calgima_crystal_nova",
        "foreman_calgima_crystal_armor",
    }
end

function ai_creature_foreman_calgima:constructor(hUnit, fInterval)
    boss_base_ai.constructor(self, hUnit, fInterval)
    self.me:SetThink( 'On_foreman_calgima_think', self, 'On_foreman_calgima_think', fInterval )
end

function ai_creature_foreman_calgima:On_foreman_calgima_think()
    self.Available_pct = self:GetAvailableAbilityPercent()
    return self:OnCommonThink()
end

function ai_creature_foreman_calgima:GetDesireFor_NormalAttack( behavior_name )
    return {
        desire = 10 / (10 + self.Available_pct) * 100,
    }
end

function ai_creature_foreman_calgima:GetDesireFor_foreman_calgima_crystal_nova( ability_name )
    local unit = self.me
    local hAbility = unit:FindAbilityByName(ability_name)
    local find_radius = hAbility:GetCastRange(unit:GetAbsOrigin(), nil)
    local hTarget = nil
    local desire = 30

    local tTargets = FindUnitsInRadius(unit:GetTeamNumber(), unit:GetAbsOrigin(), nil, find_radius, hAbility:GetAbilityTargetTeam(), hAbility:GetAbilityTargetType(), hAbility:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)
    if #tTargets > 0 then
        for _, enemy in pairs(tTargets) do
            if enemy ~= nil and enemy:IsAlive() then
                if hTarget == nil then
                    hTarget = enemy   
                end
                if enemy:GetHealth() <= hAbility:GetSpecialValueFor("damage") then
                    hTarget = enemy
                    desire = 50
                    break
                end
            end
        end
    end

    if hTarget == nil then
        return {
            desire = 0,
        }
    else
        return {
            order_table = {
                UnitIndex = unit:entindex(),
                OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
                AbilityIndex = hAbility:entindex(),
                Position = hTarget:GetAbsOrigin() + RandomVector(RandomFloat(0, hAbility:GetAOERadius())),
                Queue = false,
            },
            desire = desire,
            cost_time = hAbility:GetCastPoint() + 0.5,
        }
    end
    
end

function ai_creature_foreman_calgima:GetDesireFor_foreman_calgima_crystal_armor( ability_name )
    local unit = self.me
    local hAbility = unit:FindAbilityByName(ability_name)
    local desire = 20

    if unit:GetHealth() < 40 then
        desire = 40
    end
    return {
        order_table = {
                UnitIndex = unit:entindex(),
                OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
                AbilityIndex = hAbility:entindex(),
                TargetIndex = unit:entindex(),
                Queue = false,
            },
            desire = desire,
            cost_time = hAbility:GetCastPoint() + 0.5,
    }
end