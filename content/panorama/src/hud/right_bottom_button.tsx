import React, { useEffect, useRef, useState } from 'react';
import { render } from '@demon673/react-panorama';
import ReactUtils from "./React_utils";

const ButtonList = {
    "Hud_ChangeSchools": "ChangeSchools"
}

function Right_bottom_button(){
    return <Panel id='Right_bottom_button'>
        {
            Object.entries(ButtonList).map(([button_name, hud_name])=>
            {
                
                return <TextButton key={button_name} id={`${hud_name}_button`} text={$.Localize("#"+button_name)} 
                onactivate={()=>{
                    let hud_toggle = $(`#${hud_name}`)
                    if(hud_toggle != undefined){
                        let Visibleclass = `Show${hud_name}`
                        hud_toggle.BHasClass(Visibleclass) ? hud_toggle.SwitchClass("Visible", "") : hud_toggle.SwitchClass("Visible", "ShowChangeSchools")
                    }
                }
                }></TextButton>
            })
        }
    </Panel>
}

render(<Right_bottom_button />, $.GetContextPanel());