import React, { useEffect, useRef, useState } from "react";
import { render } from '@demon673/react-panorama';
import ReactUtils from "../../utils/React_utils";
import { print }  from '../Utils'
import {Character} from "../Character/Character"

export function Backpack(){
    return <Panel id="Backpack">
        <Panel id="Backpack_left" hittest={false}>
            <Character />
        </Panel>
        <Panel id="Backpack_right">
            
        </Panel>
    </Panel>
}
