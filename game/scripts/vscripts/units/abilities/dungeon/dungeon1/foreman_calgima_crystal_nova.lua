if  foreman_calgima_crystal_nova == nil then
    foreman_calgima_crystal_nova = class({})
end
LinkLuaModifier( "modifier_foreman_calgima_crystal_nova", "units/abilities/dungeon/dungeon1/foreman_calgima_crystal_nova.lua", LUA_MODIFIER_MOTION_NONE )
--ability
function foreman_calgima_crystal_nova:OnSpellStart()
    local hCaster = self:GetCaster()
    local vPos = self:GetCursorPosition()
    local duration = self:GetSpecialValueFor("duration")
    local delay = self:GetSpecialValueFor("delay")
    local radius = self:GetSpecialValueFor("radius")
    local damage = self:GetSpecialValueFor("damage")
    
    EmitSoundOnLocationWithCaster(vPos, "Hero_Tusk.IceShards.Projectile", hCaster)

    local particleID = ParticleManager:CreateParticle( "particles/test_particle/dungeon_generic_blast_ovr_pre.vpcf", PATTACH_CUSTOMORIGIN, nil )
	ParticleManager:SetParticleControl( particleID, 0, self:GetCursorPosition() )
	ParticleManager:SetParticleControl( particleID, 1, Vector( radius, delay, 1.0 ) )
	ParticleManager:SetParticleControl( particleID, 15, Vector( 100, 100, 255 ) )
	ParticleManager:SetParticleControl( particleID, 16, Vector( 1, 0, 0 ) )
	ParticleManager:ReleaseParticleIndex( particleID )

    Timers:CreateTimer(delay, function()
        EmitSoundOnLocationWithCaster( vPos, "Hero_Crystal.CrystalNova", hCaster )
        local particleID = ParticleManager:CreateParticle( "particles/act_2/frostbitten_icicle.vpcf", PATTACH_WORLDORIGIN, nil )
        ParticleManager:SetParticleControl( particleID, 0, vPos + Vector( 0, 0, 40 ) )
        ParticleManager:ReleaseParticleIndex( particleID )

        local enemies = FindUnitsInRadius( hCaster:GetTeamNumber(), vPos, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false )
        for _,enemy in pairs( enemies ) do
            if enemy ~= nil and enemy:IsMagicImmune() == false and enemy:IsInvulnerable() == false then
                enemy:AddNewModifier( hCaster, self, "modifier_foreman_calgima_crystal_nova", { duration = duration } )
                
                ApplyDamage({
                    victim = enemy,
                    attacker = hCaster,
                    damage = damage,
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    ability = self,
                })
                
            end
        end
    end)
end
--=======================================modifier_foreman_calgima_crystal_nova=======================================
function modifier_foreman_calgima_crystal_nova:IsHidden()
    return true
end
function modifier_foreman_calgima_crystal_nova:IsDebuff()
    return false
end
function modifier_foreman_calgima_crystal_nova:IsPurgable()
    return false
end
function modifier_foreman_calgima_crystal_nova:IsPurgeException()
    return false
end
function modifier_foreman_calgima_crystal_nova:OnCreated(params)
    self.slow_down = self:GetAbilitySpecialValueFor("slow_down")
end
function modifier_foreman_calgima_crystal_nova:OnRefresh(params)
end
function modifier_foreman_calgima_crystal_nova:OnDestroy(params)
end
function modifier_foreman_calgima_crystal_nova:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
end
function modifier_foreman_calgima_crystal_nova:CDeclareFunctions()
    return {
    }
end
function modifier_foreman_calgima_crystal_nova:GetModifierMoveSpeedBonus_Percentage()
    return -self.slow_down
end