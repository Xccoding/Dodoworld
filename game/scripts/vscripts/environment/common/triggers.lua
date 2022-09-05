

function OnTouchWater( trigger )
    local unit = trigger.activator
    local trigger_area = trigger.caller

    if unit:IsAlive() then
        unit:AddNewModifier(unit, nil, "modifier_forcekill_custom", {})

        local particleID = ParticleManager:CreateParticle("particles/econ/items/lion/fish_stick/fish_stick_spell_fish.vpcf", PATTACH_CUSTOMORIGIN, unit)
        ParticleManager:SetParticleControl(particleID, 0, unit:GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(particleID)
        EmitSoundOnLocationWithCaster(Vector(unit:GetAbsOrigin().x, unit:GetAbsOrigin().y, 0), "Hero_Lion.Hex.Fishstick", unit)
    end

end
