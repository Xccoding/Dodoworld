LinkLuaModifier( "modifier_neutral_creep_blink_strike", "units/abilities/dungeon/kobold_mine_cave/neutral_creep_blink_strike.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if neutral_creep_blink_strike == nil then
	neutral_creep_blink_strike = class({})
end
function neutral_creep_blink_strike:OnSpellStart()
	local hCaster = self:GetCaster()
	local hTarget = self:GetCursorTarget()
	local damage = self:GetSpecialValueFor("damage")
	local vPos = -100 * hTarget:GetForwardVector():Normalized() + hTarget:GetAbsOrigin()

	local particleID = ParticleManager:CreateParticle("particles/units/heroes/hero_riki/riki_blink_strike.vpcf", PATTACH_CUSTOMORIGIN, hUnit)
	ParticleManager:SetParticleControl(particleID, 0, vPos)
	ParticleManager:SetParticleControl(particleID, 1, hCaster:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(particleID)

	FindClearSpaceForUnit(hCaster, vPos, true)

	EmitSoundOn("Hero_Riki.Blink_Strike", hTarget)

	ApplyDamage({
        victim = hTarget,
        attacker = hCaster,
        damage = damage,
        damage_type = DAMAGE_TYPE_PHYSICAL,
        ability = self,
        damage_flags = DOTA_DAMAGE_FLAG_DIRECT,
    })

end
