if Alert_manager == nil then
    Alert_manager = {}
end

ALERT_PARTICLE_ICE = 2

function Alert_manager:CreateParticleAlert(vPos, fRadius, fDelay, iAlertType)
    if iAlertType == ALERT_PARTICLE_ICE then
        local particleID = ParticleManager:CreateParticle( "particles/spell_alert/generic_alert_ice.vpcf", PATTACH_CUSTOMORIGIN, nil )
        ParticleManager:SetParticleControl( particleID, 0, vPos )
        ParticleManager:SetParticleControl( particleID, 1, Vector( fRadius, fDelay, 1.0 ) )
        ParticleManager:SetParticleControl( particleID, 15, Vector( 100, 100, 255 ) )
        ParticleManager:SetParticleControl( particleID, 16, Vector( 1, 0, 0 ) )
        ParticleManager:ReleaseParticleIndex( particleID )
    end
end

return Alert_manager