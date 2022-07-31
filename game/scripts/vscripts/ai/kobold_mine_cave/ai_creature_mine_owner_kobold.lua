require('ai.boss_base_ai')

if ai_creature_mine_owner_kobold == nil then
	ai_creature_mine_owner_kobold = class( boss_base_ai )
end

function Spawn( kv )
    if IsServer() then
		if thisEntity == nil then
			return
		end
        SaveSpawnKV( thisEntity, kv )
        thisEntity.current_order = {order = nil, fEndtime = nil}
		thisEntity.AI = ai_creature_mine_owner_kobold( thisEntity, 0.25 )

	end
end

function ai_creature_mine_owner_kobold:SetupBehaviors()
    boss_base_ai.SetupBehaviors(self)

    self.behaviors = {
        "NormalAttack",
        "mine_owner_kobold_open_wound",
        "mine_owner_kobold_shaking_wine_glass",
        "mine_owner_kobold_throw_money",
    }
end

function ai_creature_mine_owner_kobold:constructor(hUnit, fInterval)
    boss_base_ai.constructor(self, hUnit, fInterval)
    self.me:SetThink( 'On_mine_owner_kobold_think', self, 'On_mine_owner_kobold_think', fInterval )
end

function ai_creature_mine_owner_kobold:On_mine_owner_kobold_think()
    self.Available_pct = self:GetAvailableAbilityPercent()
    return self:OnCommonThink()
end

function ai_creature_mine_owner_kobold:GetDesireFor_NormalAttack( behavior_name )
    return {
        desire = 10 / (10 + self.Available_pct) * 100,
    }
end

function ai_creature_mine_owner_kobold:GetDesireFor_mine_owner_kobold_open_wound( ability_name )
    local unit = self.me
    local hAbility = unit:FindAbilityByName(ability_name)
    local find_radius = hAbility:GetCastRange(unit:GetAbsOrigin(), nil)
    local hTarget = nil
    local desire = 30

    local tTargets = FindUnitsInRadius(unit:GetTeamNumber(), unit:GetAbsOrigin(), nil, find_radius, hAbility:GetAbilityTargetTeam(), hAbility:GetAbilityTargetType(), hAbility:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)
    if #tTargets > 0 then
        for _, enemy in pairs(tTargets) do
            if IsValid(enemy) and enemy:IsAlive() then
                hTarget = enemy
                break
            end
        end
    end

    if hTarget ~= nil then
        return {
            order_table = {
                    UnitIndex = unit:entindex(),
                    OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
                    AbilityIndex = hAbility:entindex(),
                    TargetIndex = hTarget:entindex(),
                    Queue = false,
                },
                desire = desire,
                cost_time = hAbility:GetCastPoint() + 0.5,
        }
    else
        return {
            desire = 0,
        }
    end
end

function ai_creature_mine_owner_kobold:GetDesireFor_mine_owner_kobold_shaking_wine_glass( ability_name )
    local unit = self.me
    local hAbility = unit:FindAbilityByName(ability_name)
    local find_radius = hAbility:GetCastRange(unit:GetAbsOrigin(), nil)
    local hTarget = nil
    local desire = 30

    local tTargets = FindUnitsInRadius(unit:GetTeamNumber(), unit:GetAbsOrigin(), nil, find_radius, hAbility:GetAbilityTargetTeam(), hAbility:GetAbilityTargetType(), hAbility:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)
    if #tTargets > 0 then
        for _, enemy in pairs(tTargets) do
            if IsValid(enemy) and enemy:IsAlive() then
                hTarget = enemy
                break
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
                Position = hTarget:GetAbsOrigin() + RandomVector(RandomFloat(0, hAbility:GetAOERadius() * 0.3)),
                Queue = false,
            },
            desire = desire,
            cost_time = hAbility:GetCastPoint() + hAbility:GetChannelTime() + 0.3,
        }
    end
    
end

function ai_creature_mine_owner_kobold:GetDesireFor_mine_owner_kobold_throw_money( ability_name )
    local unit = self.me
    local hAbility = unit:FindAbilityByName(ability_name)
    -- local find_radius = hAbility:GetCastRange(unit:GetAbsOrigin(), nil)
    -- local hTarget = nil
    local desire = 100

    return {
        order_table = {
                UnitIndex = unit:entindex(),
                OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
                AbilityIndex = hAbility:entindex(),
                Queue = false,
            },
            desire = desire,
            cost_time = hAbility:GetCastPoint() + 0.5,
        }

end