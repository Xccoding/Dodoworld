
_G.KeyValues = {
    UnitLevels = LoadKeyValues("scripts/npc/levels.txt"),
    AbilityKv = LoadKeyValues("scripts/npc/npc_abilities_custom.txt"),
    item_type = LoadKeyValues("scripts/npc/items/item_type.txt"),
    SpawnerKv = LoadKeyValues("scripts/npc/spawner.txt"),
    UnitsKv = LoadKeyValues("scripts/npc/npc_units_custom.txt"),
    HeroesKv = LoadKeyValues("scripts/npc/npc_heroes_custom.txt"),
    SchoolsKv = LoadKeyValues("scripts/npc/Schools.txt"),
}

function KeyValues:GetUnitSpecialValue( hUnit, sKey )
    local UnitKv = KeyValues.UnitsKv[hUnit:GetUnitName()]
    local return_type = "number"
    if string.sub(sKey, 1, 2) == "Is" then
        return_type = "boolean"
    end
    if UnitKv == nil then
        if return_type == "number" then
            return 0
        elseif return_type == "boolean" then
            return false
        end
    else
        if UnitKv[sKey] == nil then
            if return_type == "number" then
                return 0
            elseif return_type == "boolean" then
                return false
            end
        else
            if return_type == "number" then
                return UnitKv[sKey]
            elseif return_type == "boolean" then
                return (UnitKv[sKey] == 1)
            end
        end
    end
end
