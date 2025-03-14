<script lang="ts">
	import { cubeEyes, cubeMouths } from '$lib/cubeFaceExpressions';
	import { onMount } from 'svelte';
	import { fade, fly } from 'svelte/transition';
	let isLoaded = false;
	let isControlPanelVisible = false;
	const delayFactor = 1;

	let cubeSize: number, rotationSpeed: number, posX: number, posY: number, glow: number;
	let faceChangeSpeed: number = 5,
		perspective: number = 5;
	let hue: number = 0,
		hueSpeed: number = 1;
	let isPaused: boolean, isRGBMode: boolean;
	let color: string, bgColor: string, borderColor: string;

	let trueX: number = 0,
		trueY: number = 0;

	const startRotationX = Math.floor(Math.random() * 360);
	const startRotationY = Math.floor(Math.random() * 360);

	const defaultCubeProps = {
		size: 20,
		rotationSpeed: 5,
		posX: 50,
		posY: 45,
		isPaused: false,
		isRGBMode: false,
		faceChangeSpeed: 5,
		perspective: 5,
		glow: 10,
		hueSpeed: 1
	};

	const defaultColors = {
		light: {
			color: '#000',
			bgColor: '#f76027a6',
			borderColor: '#ffb14c'
		},
		dark: {
			color: '#fff',
			bgColor: '#0084f6a6',
			borderColor: '#35bfff'
		}
	};

	const cubeProps = [
		{
			face: 'front',
			text: '',
			transform: {
				rotateX: 0,
				rotateY: 0
			}
		},
		{
			face: 'back',
			text: '',
			transform: {
				rotateX: 0,
				rotateY: 180
			}
		},
		{
			face: 'left',
			text: '',
			transform: {
				rotateX: 0,
				rotateY: -90
			}
		},
		{
			face: 'right',
			text: '',
			transform: {
				rotateX: 0,
				rotateY: 90
			}
		},
		{
			face: 'top',
			text: '',
			transform: {
				rotateX: 90,
				rotateY: 0
			}
		},
		{
			face: 'bottom',
			text: '',
			transform: {
				rotateX: -90,
				rotateY: 0
			}
		}
	];

	function hslToRgb(h: number, s: number, l: number) {
		s /= 100;
		l /= 100;
		const k = (n: number) => (n + h / 30) % 12;
		const a = s * Math.min(l, 1 - l);
		const f = (n: number) => l - a * Math.max(Math.min(k(n) - 3, 9 - k(n), 1), -1);
		return [Math.round(f(0) * 255), Math.round(f(8) * 255), Math.round(f(4) * 255)];
	}

	function animateColor() {
		if (isRGBMode) {
			hue = (hue + 1) % 360;
			const [r, g, b] = hslToRgb(hue, 100, 50); // Convert HSL to RGB
			bgColor = `rgba(${r}, ${g}, ${b}, 0.5)`; // Transparency for the background
			borderColor = `rgb(${r - 75}, ${g - 75}, ${b - 75})`; // Darker color for the border
			color = `rgb(${r - 100}, ${g - 100}, ${b - 100})`; // Darker color for the text
			setTimeout(animateColor, 100 / hueSpeed);
		}
	}

	function randomizeText(faceSetter: (text: string) => void) {
		faceSetter(
			cubeEyes[Math.floor(Math.random() * cubeEyes.length)] +
				cubeMouths[Math.floor(Math.random() * cubeMouths.length)] +
				cubeEyes[Math.floor(Math.random() * cubeEyes.length)]
		);
		setTimeout(
			() => {
				randomizeText(faceSetter);
			},
			(Math.random() * 7500) / faceChangeSpeed
		);
	}

	function toggleRotation() {
		isPaused = !isPaused;
		localStorage.setItem('cubeIsPaused', isPaused.toString());
	}

	function toggleRGB() {
		if (isRGBMode) {
			localStorage.setItem('cubeHueSpeed', hueSpeed.toString());
			animateColor();
		} else {
			const savedTheme = localStorage.getItem('theme');
			if (savedTheme === 'dark') {
				color = defaultColors.dark.color;
				bgColor = defaultColors.dark.bgColor;
				borderColor = defaultColors.dark.borderColor;
			} else {
				color = defaultColors.light.color;
				bgColor = defaultColors.light.bgColor;
				borderColor = defaultColors.light.borderColor;
			}
			localStorage.removeItem('cubeHueSpeed');
			hueSpeed = defaultCubeProps.hueSpeed;
		}
	}

	function toggleControlPanel() {
		isControlPanelVisible = !isControlPanelVisible;
		localStorage.setItem('cubeControlPanelVisible', isControlPanelVisible.toString());
	}

	function setDefaults() {
		hue = 0;
		cubeSize = defaultCubeProps.size;
		rotationSpeed = defaultCubeProps.rotationSpeed;
		posX = defaultCubeProps.posX;
		posY = defaultCubeProps.posY;
		isPaused = defaultCubeProps.isPaused;
		isRGBMode = defaultCubeProps.isRGBMode;
		faceChangeSpeed = defaultCubeProps.faceChangeSpeed;
		perspective = defaultCubeProps.perspective;
		glow = defaultCubeProps.glow;
		hueSpeed = defaultCubeProps.hueSpeed;
		localStorage.setItem('cubeSize', cubeSize.toString());
		localStorage.setItem('cubeRotationSpeed', rotationSpeed.toString());
		localStorage.setItem('cubePosX', posX.toString());
		localStorage.setItem('cubePosY', posY.toString());
		localStorage.setItem('cubeIsPaused', isPaused.toString());
		localStorage.setItem('cubeIsRGBMode', isRGBMode.toString());
		localStorage.setItem('cubeFaceChangeSpeed', faceChangeSpeed.toString());
		localStorage.setItem('cubePerspective', perspective.toString());
		localStorage.setItem('cubeGlow', glow.toString());
		localStorage.removeItem('cubeHueSpeed');
		toggleRGB();
	}

	onMount(() => {
		cubeSize = parseInt(localStorage.getItem('cubeSize') || defaultCubeProps.size.toString());
		rotationSpeed = parseInt(
			localStorage.getItem('cubeRotationSpeed') || defaultCubeProps.rotationSpeed.toString()
		);
		posX = parseInt(localStorage.getItem('cubePosX') || defaultCubeProps.posX.toString());
		posY = parseInt(localStorage.getItem('cubePosY') || defaultCubeProps.posY.toString());
		isPaused = localStorage.getItem('cubeIsPaused') === 'true';
		isRGBMode = localStorage.getItem('cubeIsRGBMode') === 'true';
		faceChangeSpeed = parseInt(
			localStorage.getItem('cubeFaceChangeSpeed') || defaultCubeProps.faceChangeSpeed.toString()
		);
		perspective = parseInt(
			localStorage.getItem('cubePerspective') || defaultCubeProps.perspective.toString()
		);
		isControlPanelVisible = localStorage.getItem('cubeControlPanelVisible') === 'true';
		glow = parseInt(localStorage.getItem('cubeGlow') || defaultCubeProps.glow.toString());
		hueSpeed = parseInt(
			localStorage.getItem('cubeHueSpeed') || defaultCubeProps.hueSpeed.toString()
		);

		trueX = posX;
		trueY = posY;
		randomizeText((text) => (cubeProps[0].text = text));
		randomizeText((text) => (cubeProps[1].text = text));
		randomizeText((text) => (cubeProps[2].text = text));
		randomizeText((text) => (cubeProps[3].text = text));
		randomizeText((text) => (cubeProps[4].text = text));
		randomizeText((text) => (cubeProps[5].text = text));

		// Set the colors based on the theme
		const themeObserver = new MutationObserver(() => {
			if (!isRGBMode) {
				const savedTheme = localStorage.getItem('theme');
				if (savedTheme === 'dark') {
					color = defaultColors.dark.color;
					bgColor = defaultColors.dark.bgColor;
					borderColor = defaultColors.dark.borderColor;
				} else {
					color = defaultColors.light.color;
					bgColor = defaultColors.light.bgColor;
					borderColor = defaultColors.light.borderColor;
				}
			}
		});
		themeObserver.observe(document.body, { attributes: true });

		toggleRGB();
		document.title = 'Cuby';
		isLoaded = true;
	});
</script>

{#if isLoaded}
	<div class="flex justify-center">
		<h1
			class="title mt-10 text-center text-5xl font-bold"
			transition:fly={{ y: -250, duration: 100, delay: 100 * delayFactor }}
		>
			Cuby - the cube with many faces
		</h1>
	</div>

	<div
		class="mt-5 flex justify-center text-gray-500"
		transition:fly={{ y: -25, duration: 1000, delay: 1000 * delayFactor }}
	>
		<span>Over {cubeEyes.length * cubeMouths.length * cubeEyes.length} possible expressions!</span
		>
	</div>

	<!-- Control Panel -->
	<div
		class="control-panel absolute top-[25%] w-[450px] p-5"
		transition:fly={{ x: -500, duration: 500, delay: 200 }}
		style="transform: translateX({isControlPanelVisible ? '0px' : '-380px'});"
	>
		<div class="flex items-center justify-between">
			<h2 class="text-xl font-bold">Cube Control</h2>
			<button
				class="toggle-btn"
				on:click={toggleControlPanel}
				style="transform: rotate({isControlPanelVisible ? '180deg' : '0deg'});"
			>
				&#11166;
			</button>
		</div>
		<div class="flex">
			<div
				class="mt-4 grid grid-cols-2 gap-x-4 gap-y-3 {isControlPanelVisible
					? 'basis-11/12'
					: 'basis-10/12'}"
			>
				<!-- Cube Size -->
				<label>
					Size: {cubeSize}
					<input
						type="range"
						min="1"
						max="35"
						step="1"
						bind:value={cubeSize}
						on:input={() => localStorage.setItem('cubeSize', cubeSize.toString())}
					/>
				</label>
				<!-- Rotation Speed -->
				<label>
					Rotation Speed: {rotationSpeed != 0 ? `${rotationSpeed}` : '-'}
					<input
						type="range"
						min="1"
						max="30"
						step="1"
						bind:value={rotationSpeed}
						on:input={() => localStorage.setItem('cubeRotationSpeed', rotationSpeed.toString())}
					/>
				</label>
				<!-- Face Change Speed -->
				<label>
					Face change speed: {faceChangeSpeed}
					<input
						type="range"
						min="1"
						max="25"
						step="1"
						bind:value={faceChangeSpeed}
						on:input={() => localStorage.setItem('cubeFaceChangeSpeed', faceChangeSpeed.toString())}
					/>
				</label>
				<!-- Perspective -->
				<label>
					Perspective: {perspective}
					<input
						type="range"
						min="1"
						max="15"
						step="1"
						bind:value={perspective}
						on:input={() => localStorage.setItem('cubePerspective', perspective.toString())}
					/>
				</label>
				<!-- X-Position -->
				<label>
					X: {posX}
					<input
						type="range"
						min="25"
						max="75"
						step="1"
						bind:value={posX}
						on:input={() => {
							localStorage.setItem('cubePosX', posX.toString());
						}}
					/>
				</label>
				<!-- Y-Position -->
				<label>
					Y: {posY}
					<input
						type="range"
						min="30"
						max="60"
						step="1"
						bind:value={posY}
						on:input={() => {
							localStorage.setItem('cubePosY', posY.toString());
						}}
					/>
				</label>
				<!-- Glow strength -->
				<label class="col-span-2">
					Glow: {glow}
					<input
						type="range"
						min="0"
						max="20"
						step="1"
						bind:value={glow}
						on:input={() => localStorage.setItem('cubeGlow', glow.toString())}
					/>
				</label>

				<!-- Control Buttons -->
				<button class="btn" on:click={toggleRotation}>
					{isPaused ? 'Resume' : 'Pause'}
				</button>
				<button
					class="btn"
					on:click={() => {
						isRGBMode = !isRGBMode;
						localStorage.setItem('cubeIsRGBMode', isRGBMode.toString());
						toggleRGB();
					}}
				>
					{isRGBMode ? 'RGB Modus (Stop)' : 'RGB Modus (Start)'}
				</button>
				<button class="btn col-span-2" on:click={setDefaults}>Reset to Default</button>
				{#if isRGBMode}
					<label class="col-span-2">
						RGB Color Shift: {hueSpeed}
						<input
							type="range"
							min="1"
							max="10"
							step="1"
							bind:value={hueSpeed}
							on:input={() => localStorage.setItem('cubeHueSpeed', hueSpeed.toString())}
						/>
					</label>
				{/if}
			</div>
			<div
				class="absolute translate-x-[345px] rotate-[-90deg] font-bold {isRGBMode
					? 'translate-y-[150px]'
					: 'translate-y-32'}"
			>
				{#if !isControlPanelVisible}
					<div in:fade={{ duration: 150 }} out:fade={{ duration: 100 }}>Cube Control</div>
				{/if}
			</div>
		</div>
	</div>

	<div
		class="scene"
		style="top: {posY}%; left: {posX}%;
			transform: translate(-50%, -50%); perspective: {2500 / perspective}px;"
		transition:fly={{ y: 300, duration: 500, delay: 100 * delayFactor }}
	>
		<div
			class="cube"
			style="
        width: {cubeSize * 10}px;
        height: {cubeSize * 10}px;
        animation-duration: {30 / rotationSpeed}s;
        animation-play-state: {isPaused ? 'paused' : 'running'};
        transform: rotateX({startRotationX}deg) rotateY({startRotationY}deg);"
		>
			{#each cubeProps as cube}
				<div
					class="face"
					style="background: {bgColor};
                       color: {color};
                       border: {cubeSize}px solid {borderColor};
                       box-shadow: 0 0 {glow}px {borderColor}, 0 0 {glow * 2}px {borderColor};
                       transform: {cube.transform.rotateX !== 0
						? `rotateX(${cube.transform.rotateX}deg)`
						: ''} 
                                  {cube.transform.rotateY !== 0
						? `rotateY(${cube.transform.rotateY}deg)`
						: ''}
                       translateZ({cubeSize * 5}px); font-size: {cubeSize * 3.75}px;"
				>
					{cube.text}
				</div>
			{/each}
		</div>
	</div>
{/if}

<style>
	/* Control Panel Styling */
	.control-panel {
		border-radius: 0 1.5rem 1.5rem 0;
		background-color: lightgray;
		box-shadow: 0 0 10px rgba(0, 0, 0, 0.5);
		transition: all 0.5s;
	}

	:global(body.dark-mode) .control-panel {
		background-color: #062b4b;
	}

	.control-panel label {
		display: flex;
		flex-direction: column;
		font-size: 14px;
		font-weight: bold;
	}

	.toggle-btn {
		background: #f76027;
		color: white;
		padding: 2.5px 7.75px;
		border-radius: 50%;
		border: 2px solid #f76027;
		font-size: 1rem;
		cursor: pointer;
		transition:
			transform 0.25s,
			background 0.25s,
			border-color 0.25s,
			color 0.25s;
	}

	.toggle-btn:hover {
		background: white;
		color: #f76027;
	}

	:global(body.dark-mode) .toggle-btn {
		border-color: #0084f6;
		background: #0084f6;
		color: black;
	}

	:global(body.dark-mode) .toggle-btn:hover {
		background: #061b2b;
		color: #0084f6;
	}

	.scene {
		position: absolute;
	}

	.cube {
		transform-style: preserve-3d;
		animation: rotate infinite linear;
	}

	@keyframes rotate {
		0% {
			transform: rotateX(0deg) rotateY(0deg);
		}
		100% {
			transform: rotateX(360deg) rotateY(360deg);
		}
	}

	.face {
		position: absolute;
		width: 100%;
		height: 100%;
		display: flex;
		justify-content: center;
		align-items: center;
		font-weight: bold;
		transition:
			background 0.25s,
			border-color 0.25s,
			color 0.25s;
	}

	:global(body.dark-mode) .face {
		background: #0084f6e6;
		border-color: #35bfff;
		color: white;
	}

	@keyframes titleSwing {
		0% {
			transform: rotate(5deg);
		}
		25% {
			transform: rotate(-5deg);
		}
		50% {
			transform: rotate(5deg) scale(1.1);
		}
		75% {
			transform: rotate(-5deg);
		}
		100% {
			transform: rotate(5deg);
		}
	}

	@keyframes shiftColor {
		50% {
			color: #f76027;
		}
	}

	@keyframes shiftColorDark {
		50% {
			color: #0084f6;
		}
	}

	.title {
		animation:
			titleSwing 7s infinite,
			shiftColor 7s infinite;
		transition: all 0.25s;
	}

	:global(body.dark-mode) .title {
		animation:
			titleSwing 7s infinite,
			shiftColorDark 7s infinite;
	}

	.btn {
		background-color: #f76027;
		color: white;
		padding: 2.5px;
		border-color: #f76027;
		border-width: 2px;
		border-radius: 8px;
		cursor: pointer;
		transition: all 0.25s;
	}

	.btn:hover {
		background-color: white;
		color: #f76027;
	}

	:global(body.dark-mode) .btn {
		border-color: #0084f6;
		background-color: #0084f6;
		color: black;
	}

	:global(body.dark-mode) .btn:hover {
		background-color: #061b2b;
		color: #0084f6;
	}
</style>
