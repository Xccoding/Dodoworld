

function OnTouchWater( trigger )
    local unit = trigger.activator
    local trigger_area = trigger.caller

    unit:ForceKill(false)

    local particleID = ParticleManager:CreateParticle("particles/econ/items/lion/fish_stick/fish_stick_spell_fish.vpcf", PATTACH_CUSTOMORIGIN, unit)
    ParticleManager:SetParticleControl(particleID, 0, unit:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(particleID)

    --EmitSoundOn("Hero_Lion.Hex.Fishstick", unit)
    EmitSoundOnLocationWithCaster(Vector(unit:GetAbsOrigin().x, unit:GetAbsOrigin().y, 0), "Hero_Lion.Hex.Fishstick", unit)
    if IsClient() then
        --EmitGlobalSound("Hero_Lion.Hex.Fishstick")
    end

end
