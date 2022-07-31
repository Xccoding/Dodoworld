LinkLuaModifier( "modifier_mine_owner_kobold_throw_money", "units/abilities/dungeon/kobold_mine_cave/mine_owner_kobold_throw_money.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if mine_owner_kobold_throw_money == nil then
	mine_owner_kobold_throw_money = class({})
end
function mine_owner_kobold_throw_money:OnSpellStart()
	local hCaster = self:GetCaster()
	local speed = self:GetSpecialValueFor("speed")
	local radius = self:GetSpecialValueFor("radius")

	local enemies = FindUnitsInRadius(hCaster:GetTeamNumber(), hCaster:GetAbsOrigin(), nil, radius, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)
	for _, enemy in pairs(enemies) do
		if IsValid(enemy) and enemy:IsAlive() then
			local info = {
				Target = enemy,
				Source = hCaster,
				Ability = self,
				EffectName = "particles/units/neutrals/mine_owner_kobold/mine_owner_kobold_throw_moneyuriken_toss.vpcf",
				iMoveSpeed = speed,
				bDodgeable = true,                           
				vSourceLoc = hCaster:GetAbsOrigin(),               
				bIsAttack = false,                                
				ExtraData = {},
			}
			EmitSoundOn("Hero_BountyHunter.Shuriken", enemy)
			ProjectileManager:CreateTrackingProjectile(info)
		end
	end

	

end
function mine_owner_kobold_throw_money:OnProjectileHit_ExtraData(hTarget, vLocation, ExtraData)
	local hCaster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")
	local damage = self:GetSpecialValueFor("damage")
	local bonus_dmg_pct = self:GetSpecialValueFor("bonus_dmg_pct")
	if IsValid(hTarget) and IsValid(hCaster) and hCaster:IsAlive() then
		if hTarget:HasModifier("modifier_mine_owner_kobold_throw_money") then
			damage = (hTarget:FindModifierByName("modifier_mine_owner_kobold_throw_money"):GetStackCount() * bonus_dmg_pct + 100) * 0.01 * damage
		end
		EmitSoundOn("General.Coins", hTarget)
		ApplyDamage({
			victim = hTarget,
			attacker = hCaster,
			damage = damage,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self,
			damage_flags = DOTA_DAMAGE_FLAG_DIRECT,
		})
		hTarget:AddNewModifier(hCaster, self, "modifier_mine_owner_kobold_throw_money", {duration = duration})
	end
end
---------------------------------------------------------------------
--Modifiers
if modifier_mine_owner_kobold_throw_money == nil then
	modifier_mine_owner_kobold_throw_money = class({})
end
function modifier_mine_owner_kobold_throw_money:OnCreated(params)
	self.bonus_dmg_pct = self:GetAbilitySpecialValueFor("bonus_dmg_pct")
	if IsServer() then
		self:SetStackCount(1)
	end
end
function modifier_mine_owner_kobold_throw_money:OnRefresh(params)
	if IsServer() then
		self:IncrementStackCount()
	end
end
function modifier_mine_owner_kobold_throw_money:OnDestroy()
	if IsServer() then
	end
end
function modifier_mine_owner_kobold_throw_money:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TOOLTIP
	}
end
function modifier_mine_owner_kobold_throw_money:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_mine_owner_kobold_throw_money:GetEffectName()
	return "particles/killstreak/killstreak_treasure_coins_hud.vpcf"
end
function modifier_mine_owner_kobold_throw_money:OnTooltip()
	return self.bonus_dmg_pct * self:GetStackCount()
end
function modifier_mine_owner_kobold_throw_money:RemoveOnCombatEnd()
	return true
end