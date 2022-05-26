namespace Utils{
	export function Clamp(num: number, min: number, max: number) {
		return num <= min ? min : (num >= max ? max : num);
	}
	
	export function RGBToHex(rgba: string){
		let str = rgba.slice(5,rgba.length - 1),
			arry = str.split(','),
			opa = Math.ceil( Math.max(2, Number(arry[3].trim()) * 30)  + 210),
			strHex = "#",
			r = Number(arry[0].trim()),
			g = Number(arry[1].trim()),
			b = Number(arry[2].trim());
		
		strHex += ((1 << 24) + (r << 16) + (g << 8) + b).toString(16).slice(1);
		strHex += opa.toString(16).slice(0, 2)
		
		return strHex;
	}
}

function print(...args: any[]) {
	if (!Game.IsInToolsMode()) {
		return;
	}
	let s = "";
	let a = [...args];
	a.forEach(e => {
		if (s != "") {
			s += "\t";
		}
		if (typeof (e) == "object") {
			s = s + JSON.stringify(e);
		} else {
			s = s + String(e);
		}
	});
	$.Msg(s);
}

export default Utils;