import React, { useEffect, useRef, useState } from 'react';
import { render } from '@demon673/react-panorama';
import ReactUtils from "../../utils/React_utils";
import { print } from '../Utils';
import { AbilityBar } from '../AbilityPanel/script';
import { Buffpanel } from '../bufflist/script';
import { HealthMana } from '../hp_mana/script';
import { Xpbar } from '../xpbar/script';

function ActionPanel(){

    return <Panel id='ActionPanel_main'>
        <AbilityBar />
        <Buffpanel />
        <HealthMana />
        <Xpbar />
    </Panel>
}

$.Schedule(1, ()=>{
    render(<ActionPanel/>, $.GetContextPanel())
})
