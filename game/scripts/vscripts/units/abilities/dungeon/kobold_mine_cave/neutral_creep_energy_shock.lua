
--Abilities
if neutral_creep_energy_shock == nil then
	neutral_creep_energy_shock = class({})
end
function neutral_creep_energy_shock:OnSpellStart()
	local hCaster = self:GetCaster()
	local hTarget = self:GetCursorTarget()
	local damage = self:GetSpecialValueFor("damage")

	local particleID = ParticleManager:CreateParticle("particles/units/heroes/hero_rubick/rubick_fade_bolt_head.vpcf", PATTACH_CUSTOMORIGIN, hUnit)
	ParticleManager:SetParticleControlEnt(particleID, 0, hCaster, PATTACH_POINT_FOLLOW, "attach_attack1", Vector(0, 0, 0), false)
	ParticleManager:SetParticleControl(particleID, 1, hTarget:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(particleID)

	EmitSoundOn("Hero_Rubick.FadeBolt.Cast", hTarget)

	ApplyDamage({
        victim = hTarget,
        attacker = hCaster,
        damage = damage,
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = self,
        damage_flags = DOTA_DAMAGE_FLAG_DIRECT,
    })

end
