LinkLuaModifier( "modifier_mine_driller_dash", "units/abilities/dungeon/kobold_mine_cave/mine_driller_dash.lua", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier( "modifier_mine_driller_dash_debuff", "units/abilities/dungeon/kobold_mine_cave/mine_driller_dash.lua", LUA_MODIFIER_MOTION_BOTH )
--Abilities
if mine_driller_dash == nil then
	mine_driller_dash = class({})
end
function mine_driller_dash:OnSpellStart()
	local hCaster = self:GetCaster()
	
	if hCaster.spawn_entity ~= nil then
		hCaster:SetAbsOrigin(hCaster.spawn_entity:GetAbsOrigin())
	end
	hCaster:SetForwardVector(Vector(0, -1, 0))
	hCaster:AddNewModifier(hCaster, self, "modifier_mine_driller_dash", {})
end
---------------------------------------------------------------------
--Modifiers
if modifier_mine_driller_dash == nil then
	modifier_mine_driller_dash = class({})
end
function modifier_mine_driller_dash:OnCreated(params)
	local hCaster = self:GetCaster()
	self.traveled = 0
	self.length = RandomFloat(self:GetAbilitySpecialValueFor("length_min"), self:GetAbilitySpecialValueFor("length_max"))
	self.speed = self:GetAbilitySpecialValueFor("speed")
	self.width = self:GetAbilitySpecialValueFor("width")
	
	if IsServer() then
		if not self:ApplyHorizontalMotionController() then
			self:Destroy()
		else
			self.direction = Vector(0, -1, 0)
		end
		if not self:ApplyVerticalMotionController() then
			self:Destroy()
		end
	end
end
function modifier_mine_driller_dash:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_mine_driller_dash:OnDestroy()
	if IsServer() then
	end
end
function modifier_mine_driller_dash:DeclareFunctions()
	return {
	}
end
function modifier_mine_driller_dash:UpdateHorizontalMotion(hParent, dt)
	if IsServer() then
		if self.traveled < self.length then			
			hParent:SetAbsOrigin(self.direction * self.speed + hParent:GetAbsOrigin())
			self.traveled = self.traveled + self.speed

			if RandomFloat(0, 100) < 10 then
				EmitSoundOn("Hero_Gyrocopter.Rocket_Barrage", hParent)
			end
			
			local enemies = FindUnitsInRadius(hParent:GetTeamNumber(), hParent:GetAbsOrigin(), nil, self.width * 0.5, self:GetAbility():GetAbilityTargetTeam(), self:GetAbility():GetAbilityTargetType(), self:GetAbility():GetAbilityTargetFlags(), FIND_ANY_ORDER, false)
			for _, enemy in pairs(enemies) do
				if IsValid(enemy) and enemy:IsAlive() and not enemy:HasModifier("modifier_mine_driller_dash_debuff") then
					local particleID = ParticleManager:CreateParticle("particles/econ/items/gyrocopter/hero_gyrocopter_gyrotechnics/gyro_guided_missile_explosion.vpcf", PATTACH_CUSTOMORIGIN, nil)
					ParticleManager:SetParticleControl(particleID, 0, enemy:GetAbsOrigin())
					ParticleManager:ReleaseParticleIndex(particleID)
					EmitSoundOn("Hero_Gyrocopter.HomingMissile.Target", enemy)

					enemy:AddNewModifier(hParent, self:GetAbility(), "modifier_mine_driller_dash_debuff", {})
				end
			end
		else
			local particleID = ParticleManager:CreateParticle("particles/econ/items/gyrocopter/hero_gyrocopter_gyrotechnics/gyro_guided_missile_explosion.vpcf", PATTACH_CUSTOMORIGIN, nil)
			ParticleManager:SetParticleControl(particleID, 0, hParent:GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex(particleID)
			EmitSoundOn("Hero_Gyrocopter.HomingMissile.Destroy", hParent)

			hParent:ForceKill(false)
			hParent:RemoveSelf()
		end
	end
end
function modifier_mine_driller_dash:CheckState()
	return {
		[MODIFIER_STATE_STUNNED] = true,
	}
end
function modifier_mine_driller_dash:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}
end
function modifier_mine_driller_dash:GetOverrideAnimation()
	return ACT_DOTA_RUN
end
--=======================================modifier_mine_driller_dash_debuff=======================================
if modifier_mine_driller_dash_debuff == nil then
	modifier_mine_driller_dash_debuff = class({})
end
function modifier_mine_driller_dash_debuff:IsHidden()
	return true
end
function modifier_mine_driller_dash_debuff:IsDebuff()
	return true
end
function modifier_mine_driller_dash_debuff:IsPurgable()
	return false
end
function modifier_mine_driller_dash_debuff:IsPurgeException()
	return false
end
function modifier_mine_driller_dash_debuff:OnCreated(params)
	self.start_speed = self:GetAbilitySpecialValueFor("start_speed")
	
	if IsServer() then
		self.start_time = GameRules:GetGameTime()
		if not self:ApplyHorizontalMotionController() then
			self:Destroy()
		end
		if not self:ApplyVerticalMotionController() then
			self:Destroy()
		end
	end
end
function modifier_mine_driller_dash_debuff:OnRefresh(params)
end
function modifier_mine_driller_dash_debuff:OnDestroy(params)
end
function modifier_mine_driller_dash_debuff:RemoveOnDeath()
	return false
end
function modifier_mine_driller_dash_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
		MODIFIER_EVENT_ON_RESPAWN,
	}
end
function modifier_mine_driller_dash_debuff:CDeclareFunctions()
	return {
	}
end
function modifier_mine_driller_dash_debuff:CheckState()
	return {
		[MODIFIER_STATE_STUNNED] = true,
	}
end
function modifier_mine_driller_dash_debuff:UpdateHorizontalMotion(hParent, dt)
	if IsServer() then
		hParent:SetAbsOrigin(hParent:GetAbsOrigin() + self.start_speed * Vector(0, -1, 0))
	end
end
function modifier_mine_driller_dash_debuff:UpdateVerticalMotion(hParent, dt)
	if IsServer() then
		local dLength = 9.8 * dt * (2 * (GameRules:GetGameTime() - self.start_time) - dt) / 2
		hParent:SetAbsOrigin(hParent:GetAbsOrigin() + dLength * Vector(0, 0, -30))
	end
end
function modifier_mine_driller_dash_debuff:OnRespawn( params )
	local hParent = self:GetParent()
	if params.unit == hParent then
		self:Destroy()
	end
end
function modifier_mine_driller_dash_debuff:GetOverrideAnimation()
	return ACT_DOTA_FLAIL
end
function modifier_mine_driller_dash_debuff:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end
function modifier_mine_driller_dash_debuff:GetEffectName()
	return "particles/units/heroes/hero_sniper/sniper_headshot_slow.vpcf"
end
