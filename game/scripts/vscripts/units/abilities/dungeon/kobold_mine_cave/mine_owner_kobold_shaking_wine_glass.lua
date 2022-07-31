LinkLuaModifier( "modifier_mine_owner_kobold_shaking_wine_glass", "units/abilities/dungeon/kobold_mine_cave/mine_owner_kobold_shaking_wine_glass.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_mine_owner_kobold_shaking_wine_glass_channel", "units/abilities/dungeon/kobold_mine_cave/mine_owner_kobold_shaking_wine_glass.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if mine_owner_kobold_shaking_wine_glass == nil then
	mine_owner_kobold_shaking_wine_glass = class({})
end
function mine_owner_kobold_shaking_wine_glass:GetChannelTime()
    return self:GetSpecialValueFor("channel_time")
end
function mine_owner_kobold_shaking_wine_glass:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end
function mine_owner_kobold_shaking_wine_glass:OnSpellStart()
	local hCaster = self:GetCaster()
	local vPos = self:GetCursorPosition()
	local radius = self:GetSpecialValueFor("radius")

	hCaster:AddNewModifier(hCaster, self, "modifier_mine_owner_kobold_shaking_wine_glass_channel", {duration = self:GetSpecialValueFor("channel_time")})

	self.alert_particleID = ParticleManager:CreateParticle("particles/spell_alert/generic_alert_aoe.vpcf", PATTACH_CUSTOMORIGIN, hCaster)
	ParticleManager:SetParticleControl(self.alert_particleID, 0, vPos)
	ParticleManager:SetParticleControl(self.alert_particleID, 1, Vector(radius, 0, 0))
	ParticleManager:SetParticleControl(self.alert_particleID, 2, Vector(100, 0, 0))
end
function mine_owner_kobold_shaking_wine_glass:OnChannelFinish(bInterrupted)
	local hCaster = self:GetCaster()
	local vPos = self:GetCursorPosition()
	local radius = self:GetSpecialValueFor("radius")
	local duration = self:GetSpecialValueFor("duration")

	
	hCaster:RemoveModifierByName("modifier_mine_owner_kobold_shaking_wine_glass_channel")
	if not bInterrupted and IsValidEntity(hCaster) and hCaster:IsAlive() then
		local particleID = ParticleManager:CreateParticle("particles/units/neutrals/mine_owner_kobold/mine_owner_kobold_shaking_wine_glass_cast.vpcf", PATTACH_CUSTOMORIGIN, hUnit)
		--ParticleManager:SetParticleControl(particleID, 0, hCaster:GetAbsOrigin() + Vector(0, 0, 100))
		ParticleManager:SetParticleControlEnt(particleID, 0, hCaster, PATTACH_POINT_FOLLOW, "attach_attack2", Vector(0, 0, 0), false)
		ParticleManager:SetParticleControl(particleID, 1, vPos)
		ParticleManager:ReleaseParticleIndex(particleID)

		EmitSoundOn("Hero_Brewmaster.CinderBrew.Cast", hCaster)

		Timers:CreateTimer(0.3,function ()
			if self.alert_particleID ~= nil then
				ParticleManager:DestroyParticle(self.alert_particleID, true)
				self.alert_particleID = nil
			end
			
			EmitSoundOnLocationWithCaster(vPos, "Hero_Brewmaster.CinderBrew", hCaster)
			local enemies = FindUnitsInRadius(hCaster:GetTeamNumber(), vPos, nil, radius, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)
			for _, enemy in pairs(enemies) do
				if IsValid(enemy) and enemy:IsAlive() then
					--减少皮开肉绽层数
					if enemy:HasModifier("modifier_mine_owner_kobold_open_wound") then
						enemy:FindModifierByName("modifier_mine_owner_kobold_open_wound"):DecrementStackCount()
					end
					enemy:AddNewModifier(hCaster, self, "modifier_mine_owner_kobold_shaking_wine_glass", {duration = duration})
					EmitSoundOn("Hero_Brewmaster.CinderBrew.Target", enemy)
				end
			end
		end)
	else
		ParticleManager:DestroyParticle(self.alert_particleID, true)
	end
end
---------------------------------------------------------------------
--Modifiers
if modifier_mine_owner_kobold_shaking_wine_glass == nil then
	modifier_mine_owner_kobold_shaking_wine_glass = class({})
end
function modifier_mine_owner_kobold_shaking_wine_glass:OnCreated(params)
	self.ap_reduce = self:GetAbilitySpecialValueFor("ap_reduce")
	self.sp_reduce = self:GetAbilitySpecialValueFor("sp_reduce")
	if IsServer() then
		self:SetStackCount(1)
	end
end
function modifier_mine_owner_kobold_shaking_wine_glass:OnRefresh(params)
	if IsServer() then
		self:IncrementStackCount()
	end
end
function modifier_mine_owner_kobold_shaking_wine_glass:OnDestroy()
	if IsServer() then
	end
end
function modifier_mine_owner_kobold_shaking_wine_glass:OnStackCountChanged(iStackCount)
	if self:GetStackCount() <= 0 then
		self:Destroy()
	end
end
function modifier_mine_owner_kobold_shaking_wine_glass:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_TOOLTIP,
	}
end
function modifier_mine_owner_kobold_shaking_wine_glass:CDeclareFunctions()
	return {
		CMODIFIER_PROPERTY_SPELL_POWER_CONSTANT
	}
end
function modifier_mine_owner_kobold_shaking_wine_glass:GetModifierPreAttack_BonusDamage()
	return -self.ap_reduce * self:GetStackCount()
end
function modifier_mine_owner_kobold_shaking_wine_glass:C_GetModifierSpellPower_Constant()
	return -self.sp_reduce * self:GetStackCount()
end
function modifier_mine_owner_kobold_shaking_wine_glass:OnTooltip()
	return -self.sp_reduce * self:GetStackCount()
end
--=======================================modifier_mine_owner_kobold_shaking_wine_glass_channel=======================================
if modifier_mine_owner_kobold_shaking_wine_glass_channel == nil then
	modifier_mine_owner_kobold_shaking_wine_glass_channel = class({})
end
function modifier_mine_owner_kobold_shaking_wine_glass_channel:IsHidden()
	return true
end
function modifier_mine_owner_kobold_shaking_wine_glass_channel:IsDebuff()
	return false
end
function modifier_mine_owner_kobold_shaking_wine_glass_channel:IsPurgable()
	return false
end
function modifier_mine_owner_kobold_shaking_wine_glass_channel:IsPurgeException()
	return false
end
function modifier_mine_owner_kobold_shaking_wine_glass_channel:OnCreated(params)
end
function modifier_mine_owner_kobold_shaking_wine_glass_channel:OnRefresh(params)
end
function modifier_mine_owner_kobold_shaking_wine_glass_channel:OnDestroy(params)
end
function modifier_mine_owner_kobold_shaking_wine_glass_channel:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION_RATE,
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}
end
function modifier_mine_owner_kobold_shaking_wine_glass_channel:CDeclareFunctions()
	return {
	}
end
function modifier_mine_owner_kobold_shaking_wine_glass_channel:GetOverrideAnimationRate()
	return 0.12
end
function modifier_mine_owner_kobold_shaking_wine_glass_channel:GetOverrideAnimation()
	return ACT_DOTA_ATTACK2
end