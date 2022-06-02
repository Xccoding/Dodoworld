import React, { useEffect, useRef, useState } from 'react';
import { render } from '@demon673/react-panorama';
import { ChangeSchools } from '../ChangeSchools/ChangeSchools'
import { Backpack } from '../Backpack/Backpack';
import { print } from '../Utils';

const ButtonList = {
    "Hud_ChangeSchools": "ChangeSchools",
    "Hud_Backpack": "Backpack"
}

export function Right_bottom_button(){
    return <Panel id='Right_bottom_button'>
        {
            Object.entries(ButtonList).map(([button_name, hud_name])=>
            {
                return <TextButton key={button_name} id={`${hud_name}_button`} text={$.Localize("#" + button_name+"_button")} 
                onactivate={()=>{
                    let hud_toggle = $(`#${hud_name}`)
                    if(hud_toggle != undefined){
                        let Visibleclass = `Show${hud_name}`
                        hud_toggle.BHasClass(Visibleclass) ? hud_toggle.SwitchClass("Visible", "") : hud_toggle.SwitchClass("Visible", Visibleclass)
                    }
                }
                }
                onmouseover={p=>{
                    $.DispatchEvent("DOTAShowTextTooltip", p, $.Localize("#hud_text_tooltip_" + button_name))
                }
                }
                onmouseout={
                    ()=>{
                        $.DispatchEvent("DOTAHideTextTooltip")
                    }
                }
                ></TextButton>
            })
        }
    </Panel>
}
