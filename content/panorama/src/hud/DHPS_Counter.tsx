import React, { useEffect, useRef, useState } from 'react';
import { render } from '@demon673/react-panorama';
import ReactUtils from "../utils/React_utils";

function DHPS_Counter(){
    

    return <Panel id="DHPS_Counter">
        <DPS_Counter/>
        <HPS_Counter/>
    </Panel>
}

function DPS_Counter(){

    // CustomNetTables.SubscribeNetTableListener()

    return <Panel id='DPS_Counter'>

    </Panel>
}

function HPS_Counter(){
    return <Panel></Panel>
}

render(<DHPS_Counter />, $("#DHPS_CounterRoot")); 