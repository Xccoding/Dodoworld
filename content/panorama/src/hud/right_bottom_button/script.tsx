import React, { useEffect, useRef, useState } from 'react';
import { render, useGameEvent } from '@demon673/react-panorama';
import { print, useToggleHud } from '../Utils';
import ReactUtils from '../../utils/React_utils';

const ButtonList = {
    "Hud_ChangeSchools": "ChangeSchools",
    "Hud_Backpack": "Backpack"
}

function Right_bottom_button(){

    return <Panel id='Right_bottom_button'>
        {
            Object.entries(ButtonList).map(([button_name, hud_name])=>
            {
                return <TextButton key={button_name} id={`${hud_name}_button`} text={$.Localize("#" + button_name+"_button")} 
                onactivate={()=>{
                    GameEvents.SendEventClientSide("CustomToggleHud", {hud_name: hud_name})
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

render(<Right_bottom_button/>, $.GetContextPanel())
