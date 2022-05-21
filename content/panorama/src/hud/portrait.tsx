import React from 'react';
import { render } from '@demon673/react-panorama';

function Portrait()
{   
    return (
        <Panel>
            {/* <DOTAHeroMovie heroname = {Game.GetLocalPlayerInfo().player_selected_hero}/> */}
        </Panel>
    );
}

render(<Portrait />, $.GetContextPanel());