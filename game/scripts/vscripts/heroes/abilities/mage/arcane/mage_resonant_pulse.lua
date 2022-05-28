--Abilities
if mage_resonant_pulse == nil then
	mage_resonant_pulse = class({})
end
function mage_resonant_pulse:GetManaCost(iLevel)
    local hCaster = self:GetCaster()
    if self.arcane_bolt_buff ~= nil and self.arcane_bolt_buff > 0 then
        return 0
    end
    return self:GetSpecialValueFor("mana_cost_pct") * hCaster:GetMaxMana() * 0.01
end
function mage_resonant_pulse:OnSpellStart()
	local hCaster = self:GetCaster()
    local radius = self:GetSpecialValueFor("radius")
	local sp_factor = self:GetSpecialValueFor("sp_factor")
	local hit = false

	if self.arcane_bolt_buff ~= nil and self.arcane_bolt_buff > 0 then
		hCaster:FindModifierByName("modifier_mage_arcane_bolt"):DecrementStackCount()
	end

	local particleID = ParticleManager:CreateParticleForPlayer("particles/units/heroes/mage/mage_resonant_pulse.vpcf", PATTACH_ABSORIGIN_FOLLOW, hCaster, hCaster:GetPlayerOwner())
    ParticleManager:SetParticleControl(particleID, 1, Vector(radius, 0, 0))
	ParticleManager:ReleaseParticleIndex(particleID)

	EmitSoundOn("Hero_VoidSpirit.Pulse.Cast", hCaster)
	EmitSoundOn("Hero_VoidSpirit.Pulse", hCaster)

	local enemies = FindUnitsInRadius(hCaster:GetTeamNumber(), hCaster:GetAbsOrigin(), nil, radius, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags(), FIND_CLOSEST, false)
    for _, enemy in pairs(enemies) do
        if enemy ~= nil and enemy:IsAlive() then
			ApplyDamage({
				victim = enemy,
				attacker = hCaster,
				damage =  hCaster:GetDamageforAbility(false) * sp_factor * 0.01,
				damage_type = DAMAGE_TYPE_MAGICAL,
				ability = self,
				damage_flags = DOTA_DAMAGE_FLAG_DIRECT,
			})
			EmitSoundOn("Hero_VoidSpirit.Pulse.Target", enemy)
			hit = true
        end
    end

	--增加充能
	local arcane_buff = hCaster:FindModifierByName("modifier_mage_concussive_shot")
	if arcane_buff ~= nil and hit then
		if arcane_buff:GetStackCount() < arcane_buff.max_stack then
			arcane_buff:IncrementStackCount()
		end
	end

end
