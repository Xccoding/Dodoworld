import React, { useEffect, useRef, useState } from "react";
import { print } from "../hud/Utils";

namespace ReactUtils {
    // 定时器hook
    export function useSchedule(Tick: () => boolean | number | void, deps?: any[]) {
		useEffect(() => {
			let id: ScheduleID;
			function Timer() {
				// 最多每30帧更新一次
				let result = Tick();
				if (typeof (result) == "number" && result >= 0) {
					id = $.Schedule(result, Timer);
				} else {
					id = -1 as ScheduleID;
				}
			}
			Timer();

			return () => {
				try {
					if (id && id != -1)
						$.CancelScheduled(id);
				} catch (error) {
				}
			};

		}, deps);
	}

	function ToggleHud(hud_name: string){
		let hud_toggle = $(`#ChangeSchools`)
		// print("N2O", this)
        if(hud_toggle != undefined){
            let Visibleclass = `Show${hud_name}`
            hud_toggle.BHasClass(Visibleclass) ? hud_toggle.SwitchClass("Visible", "") : hud_toggle.SwitchClass("Visible", Visibleclass)
        }
	}
}

export default ReactUtils;