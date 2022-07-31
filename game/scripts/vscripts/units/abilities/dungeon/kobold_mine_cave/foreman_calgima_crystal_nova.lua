if  foreman_calgima_crystal_nova == nil then
    foreman_calgima_crystal_nova = class({})
end
LinkLuaModifier( "modifier_foreman_calgima_crystal_nova", "units/abilities/dungeon/kobold_mine_cave/foreman_calgima_crystal_nova.lua", LUA_MODIFIER_MOTION_NONE )
--ability
function foreman_calgima_crystal_nova:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end
function foreman_calgima_crystal_nova:OnSpellStart()
    local hCaster = self:GetCaster()
    local vPos = self:GetCursorPosition()
    local duration = self:GetSpecialValueFor("duration")
    local delay = self:GetSpecialValueFor("delay")
    local radius = self:GetSpecialValueFor("radius")
    local damage = self:GetSpecialValueFor("damage")
    
    EmitSoundOnLocationWithCaster(vPos, "Hero_Tusk.IceShards.Projectile", hCaster)

    Alert_manager:CreateParticleAlert(self:GetCursorPosition(), radius, delay, ALERT_PARTICLE_ICE)

    Timers:CreateTimer(delay, function()
        if IsValidEntity(hCaster) and hCaster:IsAlive() then
            EmitSoundOnLocationWithCaster( vPos, "Hero_Crystal.CrystalNova", hCaster )
            local particleID = ParticleManager:CreateParticle( "particles/units/heroes/hero_crystalmaiden/maiden_crystal_nova.vpcf", PATTACH_CUSTOMORIGIN, nil )
            ParticleManager:SetParticleControl( particleID, 0, vPos + Vector( 0, 0, 40 ) )
            ParticleManager:SetParticleControl( particleID, 1, Vector( radius, 1, 0 ) )
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
                        damage_flags = DOTA_DAMAGE_FLAG_DIRECT,
                    })
                    
                end
            end
        end
    end)
end
--=======================================modifier_foreman_calgima_crystal_nova=======================================
if  modifier_foreman_calgima_crystal_nova == nil then
    modifier_foreman_calgima_crystal_nova = class({})
end
function modifier_foreman_calgima_crystal_nova:IsHidden()
    return false
end
function modifier_foreman_calgima_crystal_nova:IsDebuff()
    return true
end
function modifier_foreman_calgima_crystal_nova:IsPurgable()
    return true
end
function modifier_foreman_calgima_crystal_nova:IsPurgeException()
    return true
end
function modifier_foreman_calgima_crystal_nova:OnCreated(params)
    self.slow_down = self:GetAbilitySpecialValueFor("slow_down")
end
function modifier_foreman_calgima_crystal_nova:OnRefresh(params)
end
function modifier_foreman_calgima_crystal_nova:OnDestroy(params)
end
function modifier_foreman_calgima_crystal_nova:GetStatusEffectName()
    return "particles/status_fx/status_effect_frost.vpcf"
end
function modifier_foreman_calgima_crystal_nova:StatusEffectPriority()
    return 1
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