function* chain(existingGenerator, toAdd) {
	for (i of existingGenerator) {
		yield i;
	}
	for (i of toAdd) {
		yield i;
	}
}

function* swap(existingGenerator, idx, toAdd) {
	let id = 0;
	for (i of existingGenerator) {
		if (id === idx) {
			yield toAdd;
		} else {
			yield i;
		}
		id += 1;
	}
}

const IMAGE_SAVE_IDX = 1;

// Hook into menu rendering:
let wasm4MenuRender = wasm4.MenuOverlay.prototype.render;
wasm4.MenuOverlay.prototype.render = function () {
	let out = wasm4MenuRender.call(this);
	let listGenerator = out.values[2];
	let strings = [`<li class="${this.selectedIdx === IMAGE_SAVE_IDX ? "selected" : ""}	">`, "</li>"];
	strings.raw = ["<li class=\"\">", "<\\u002Fli>"];
	let obj = {_$litType$: 1, strings: strings, values: [`SAVE IMAGE`]};
	// out.values[2] = chain(listGenerator, []);
	out.values[2] = swap(listGenerator, IMAGE_SAVE_IDX, obj);
	
	return out;
};

let desc = Object.getOwnPropertyDescriptor(wasm4.MenuOverlay.prototype, "options");
let wasm4Options = desc.get;
Object.defineProperty(wasm4.MenuOverlay.prototype, "options", {
	get: function() {
		let out = wasm4Options.call(this);
		if (this.optionContext === 0) {
			out[IMAGE_SAVE_IDX] = "SAVE IMAGE";
		}
		return out;
	}
});

let saveImage = false;

let wasm4Input = wasm4.MenuOverlay.prototype.applyInput;
wasm4.MenuOverlay.prototype.applyInput = function() {
	let gamepad = 0;
	for (const player of this.app.inputState.gamepad) {
		gamepad |= player;
	}

	const pressedThisFrame = gamepad & (gamepad ^ this.lastGamepad);
	if (pressedThisFrame & (1 | 2)) {
		if (this.optionContext === 0 && this.selectedIdx === IMAGE_SAVE_IDX) {
			saveImage = true;
			saveImageAddr[0] = 1;
		}
	}
	wasm4Input.call(this);
}

let app = document.getElementsByTagName("wasm4-app")[0];
let saveImageAddr = new Uint8Array(app.runtime.memory.buffer, 0x2050, 1);
saveImageAddr[0] = 0;

let wasm4Composite = Object.getPrototypeOf(app.runtime.compositor).composite;
Object.getPrototypeOf(app.runtime.compositor).composite = function(palette, framebuffer) {
	wasm4Composite.call(this, palette, framebuffer);
	if (saveImage) {
		var link = document.createElement("a");
		link.download = "image.png";
		link.href = this.gl.canvas.toDataURL("image/png", 1);
		document.body.appendChild(link);
		link.click();
		document.body.removeChild(link);
		saveImage = false;
		saveImageAddr[0] = 0;
	} else if (saveImageAddr[0] == 1) { // Did we load from a previous state?
		saveImageAddr[0] = 0;
	}
}