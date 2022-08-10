
--Abilities
if lamper_maurice_head_butt == nil then
	lamper_maurice_head_butt = class({})
end
function lamper_maurice_head_butt:OnSpellStart()
	local hCaster = self:GetCaster()
	local hTarget = self:GetCursorTarget()
	local duration = self:GetSpecialValueFor("duration")

	hTarget:AddStun(hCaster, self, {duration = duration})
	hTarget:AddNewModifier(hCaster, self, "modifier_lamper_maurice_head_butt", {duration = duration})

	EmitSoundOn("Hero_DragonKnight.DragonTail.Target", hTarget)

	local particleID = ParticleManager:CreateParticle("particles/units/heroes/hero_dragon_knight/dragon_knight_dragon_tail.vpcf", PATTACH_ABSORIGIN_FOLLOW, hTarget)
	-- ParticleManager:SetParticleControl(particleID, 2, Vector(0, 0, 0))
	ParticleManager:ReleaseParticleIndex(particleID)
	
end
