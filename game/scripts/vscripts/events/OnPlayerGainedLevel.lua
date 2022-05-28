function DodoWorld:OnPlayerGainedLevel( params )
    local unit = EntIndexToHScript(params.hero_entindex)

    unit:AutoUpgradeAbilities()

end