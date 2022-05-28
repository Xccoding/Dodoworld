local BaseNPC

if IsServer() then
    BaseNPC = CDOTA_BaseNPC
end

if IsClient() then
    BaseNPC = C_DOTA_BaseNPC
end

function BaseNPC:CHeal(amount, inflictor, lifesteal, amplify, source, spellLifesteal)
    local number_length = math.log(math.floor(amount),10) + 1

    local particleID = ParticleManager:CreateParticleForPlayer("particles/msg_fx/msg_heal.vpcf", PATTACH_OVERHEAD_FOLLOW, self, self:GetPlayerOwner())
    ParticleManager:SetParticleControl(particleID, 1, Vector(0, amount, 0))
    ParticleManager:SetParticleControl(particleID, 2, Vector(1, number_length + 1, 0))
    ParticleManager:SetParticleControl(particleID, 3, Vector(50, 205, 50))
    ParticleManager:ReleaseParticleIndex(particleID)

    self:HealWithParams(amount, inflictor, lifesteal, amplify, source, spellLifesteal)
    CFireModifierEvent(source, CMODIFIER_EVENT_ON_HEAL, {amount = amount, inflictor = inflictor, lifesteal = lifesteal, amplify = amplify, source = source, spellLifesteal = spellLifesteal})
    CFireModifierEvent(self, CMODIFIER_EVENT_ON_HEALED, {amount = amount, inflictor = inflictor, lifesteal = lifesteal, amplify = amplify, source = source, spellLifesteal = spellLifesteal})
end

function BaseNPC:CGiveMana(amount, inflictor, source)
    local number_length = math.log(math.floor(amount),10) + 1

    local particleID = ParticleManager:CreateParticleForPlayer("particles/msg_fx/msg_mana_add.vpcf", PATTACH_OVERHEAD_FOLLOW, self, self:GetPlayerOwner())
    ParticleManager:SetParticleControl(particleID, 1, Vector(0, amount, 0))
    ParticleManager:SetParticleControl(particleID, 2, Vector(1, number_length + 1, 0))
    ParticleManager:SetParticleControl(particleID, 3, Vector(30, 144, 255))
    ParticleManager:ReleaseParticleIndex(particleID)

    self:GiveMana(amount)
end




