import React from 'react';
import { render } from '@demon673/react-panorama';

interface AbilityPanel extends Panel{
    overrideentityindex: number,
    overridedisplaykeybind: number
}

function CustomAbilityPanel(){
    return <></>
}

render(<CustomAbilityPanel />, $.GetContextPanel()); 
