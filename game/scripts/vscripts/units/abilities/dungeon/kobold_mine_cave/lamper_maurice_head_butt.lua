LinkLuaModifier( "modifier_lamper_maurice_head_butt", "units/abilities/dungeon/kobold_mine_cave/lamper_maurice_head_butt.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if lamper_maurice_head_butt == nil then
	lamper_maurice_head_butt = class({})
end
function lamper_maurice_head_butt:OnSpellStart()
	local hCaster = self:GetCaster()
	local hTarget = self:GetCursorTarget()
	local duration = self:GetSpecialValueFor("duration")

	hTarget:AddNewModifier(hCaster, self, "modifier_lamper_maurice_head_butt", {duration = duration})

	EmitSoundOn("Hero_DragonKnight.DragonTail.Target", hTarget)

	local particleID = ParticleManager:CreateParticle("particles/units/heroes/hero_dragon_knight/dragon_knight_dragon_tail.vpcf", PATTACH_ABSORIGIN_FOLLOW, hTarget)
	-- ParticleManager:SetParticleControl(particleID, 2, Vector(0, 0, 0))
	ParticleManager:ReleaseParticleIndex(particleID)
	
end
---------------------------------------------------------------------
--Modifiers
if modifier_lamper_maurice_head_butt == nil then
	modifier_lamper_maurice_head_butt = class({})
end
function modifier_lamper_maurice_head_butt:OnCreated(params)
	if IsServer() then
	end
end
function modifier_lamper_maurice_head_butt:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_lamper_maurice_head_butt:OnDestroy()
	if IsServer() then
	end
end
function modifier_lamper_maurice_head_butt:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}
end
function modifier_lamper_maurice_head_butt:CheckState()
	return {
		[MODIFIER_STATE_STUNNED] = true,
	}
end
function modifier_lamper_maurice_head_butt:GetOverrideAnimation()
	return ACT_DOTA_DISABLED
end