import React, { useEffect, useRef, useState } from "react";

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
}

export default ReactUtils;