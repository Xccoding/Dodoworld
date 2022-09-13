require('GameConfig')
require('common.managers.attribute_manager')
require('modifiers.Cmodifier')
require('common.managers.combat_manager')
require('KeyValues')
require('utils')
Abilities_manager = require('common.managers.abilities_manager')
require('common.managers.Talent_manager')
_G.GetAbilityValueTexture = ""


function OnGetAbilityValue( params )
    local ability = EntIndexToHScript(params.ability)
    local value = Abilities_manager:GetAbilityValue(ability, params.key_name)

    GetAbilityValueTexture = tostring(value)
end

ListenToGameEvent("GetAbilityValue", OnGetAbilityValue, nil)


