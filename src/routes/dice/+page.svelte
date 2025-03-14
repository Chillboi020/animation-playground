<script lang="ts">
	import type { Cube } from '$lib/cube';
	import { onMount, tick } from 'svelte';
	import { fade, fly } from 'svelte/transition';
	let isLoaded = false;
	const delayFactor = 1;

	const defaultCubeProps = {
		size: 200,
		rotationSpeed: 1,
		posX: 50,
		posY: 45,
		isPaused: false,
		isRGBMode: false
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

	let cubeSize: number, rotationSpeed: number, posX: number, posY: number;
	let isRolling: boolean, isControlPanelVisible: boolean;
	let color: string, bgColor: string, borderColor: string;

	const cubePropDefaults = ['1', '2', '3', '4', '5', '6'];

	const cubeProps: Cube[] = [
		{
			face: 'front',
			text: '1',
			x: 0,
			y: 0
		},
		{
			face: 'left',
			text: '2',
			x: 0,
			y: -90
		},
		{
			face: 'bottom',
			text: '3',
			x: -90,
			y: 0
		},
		{
			face: 'top',
			text: '4',
			x: 90,
			y: 0
		},
		{
			face: 'right',
			text: '5',
			x: 0,
			y: 90
		},
		{
			face: 'back',
			text: '6',
			x: 0,
			y: 180
		}
	];

	let resultTitle: string | undefined = ''; // Title for the result modal
	let result: string | undefined = ''; // Saves the result of the dice roll
	let cubeElement: HTMLDivElement | null = null; // Reference of the cube element

	let lastRotationX = 0; // Saves the last X rotation
	let lastRotationY = 0; // Saves the last Y rotation
	const directions = [
		'tl',
		// 't',
		'tr',
		// 'r',
		'br',
		// 'b',
		'bl'
		// 'l'
	]; // Possible directions for the dice to roll

	function getDiceFaceValue() {
		if (!cubeElement) return;
		let rotationDirection = directions[Math.floor(Math.random() * directions.length)];
		isRolling = true;

		let wasControlPanelVisible = isControlPanelVisible;
		if (isControlPanelVisible) {
			toggleControlPanel();
		}

		// Random duration for the animation
		const totalDuration = Math.random() * 2000 + 3000;

		const intervalTime = 10; // Interval-time for the rotation
		const totalSteps = totalDuration / intervalTime; // Total steps for the rotation
		let currentStep = 0;

		// Easing-function for the rotation
		function easeInOutQuad(t: number): number {
			return t < 0.5 ? 2 * t * t : -1 + (4 - 2 * t) * t;
		}

		let rotationX = lastRotationX;
		let rotationY = lastRotationY;

		let rotationXFactor = 1;
		let rotationYFactor = 1;

		switch (rotationDirection) {
			case 'l':
				// Left
				rotationXFactor = 0;
				rotationYFactor = -1;
			case 'tl':
				// Top-left
				rotationYFactor = -1;
				break;
			case 't':
				// Top
				rotationYFactor = 0;
				break;
			case 'r':
				// Right
				rotationXFactor = 0;
				break;
			case 'br':
				// Bottom-right
				rotationXFactor = -1;
				break;
			case 'b':
				// Bottom
				rotationYFactor = 0;
				rotationXFactor = -1;
				break;
			case 'bl':
				// Bottom-left
				rotationYFactor = -1;
				rotationXFactor = -1;
				break;
		}

		let rotationInterval = setInterval(() => {
			currentStep++;
			let progress = currentStep / totalSteps;
			let easeFactor = easeInOutQuad(progress);

			// The calculation for the rotation
			rotationX += easeFactor * 10 * rotationXFactor;
			rotationY += easeFactor * 12 * rotationYFactor;

			cubeElement!.style.transform = `rotateX(${rotationX}deg) rotateY(${rotationY}deg)`; // Set the rotation

			// Stops the rotation after the total steps
			if (currentStep >= totalSteps) {
				clearInterval(rotationInterval);

				// final rotation for the dice
				const chosenRotation = cubeProps[Math.floor(Math.random() * cubeProps.length)];

				cubeElement!.style.transition = 'transform 1s ease-out';
				cubeElement!.style.transform = `rotateX(${chosenRotation.x * -1}deg) rotateY(${chosenRotation.y * -1}deg)`;

				// Save the last rotation
				lastRotationX = chosenRotation.x * -1;
				lastRotationY = chosenRotation.y * -1;

				// Set the result after the animation
				setTimeout(() => {
					isRolling = false;
					let index = cubeProps.findIndex((cube) => cube.face === chosenRotation.face);
					result = `You rolled a ${cubePropDefaults[index]}!`;
					if (cubeProps[index].prompt) {
						result = `"${cubeProps[index].prompt}"`;
					}
					isControlPanelVisible = wasControlPanelVisible;
					localStorage.setItem('diceControlPanelVisible', isControlPanelVisible.toString());
				}, 1000);
			}
		}, intervalTime);
	}

	onMount(async () => {
		cubeSize = defaultCubeProps.size;
		rotationSpeed = defaultCubeProps.rotationSpeed;
		posX = defaultCubeProps.posX;
		posY = defaultCubeProps.posY;
		isRolling = false;
		isControlPanelVisible = localStorage.getItem('diceControlPanelVisible') === 'true';

		document.title = 'Magic Dice';

		isLoaded = true;
		await tick();

		cubeElement = document.querySelector('.cube');
		if (!cubeElement) {
			console.error('Cube element not found!');
			return;
		}

		cubeElement.style.animation = `rotate ${rotationSpeed}s infinite linear`;

		// Set the colors based on the theme
		const themeObserver = new MutationObserver(() => {
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
		});
		themeObserver.observe(document.body, { attributes: true });

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
	});

	function toggleControlPanel() {
		isControlPanelVisible = !isControlPanelVisible;
		localStorage.setItem('diceControlPanelVisible', isControlPanelVisible.toString());
	}

	function resetResult() {
		setTimeout(() => {
			result = '';
		}, 100);
	}
</script>

{#if isLoaded}
	<div
		class="flex justify-center"
		transition:fly={{ y: -250, duration: 500, delay: 650 * delayFactor }}
	>
		<h1 class="title mt-10 text-center text-5xl font-bold">!!! Magic Dice !!!</h1>
	</div>

	<div
		class="mt-5 flex justify-center text-gray-500"
		transition:fly={{ y: -250, duration: 500, delay: 400 * delayFactor }}
	>
		Press it!
	</div>

	<!-- Control Panel -->
	<div
		class="control-panel absolute top-[25%] w-[450px] p-5"
		transition:fly={{ x: -500, duration: 500, delay: 700 * delayFactor }}
		style="transform: translateX({isControlPanelVisible && result === '' ? '0px' : '-380px'});"
	>
		<div class="flex items-center justify-between">
			<h2 class="text-xl font-bold">Text values for the dice</h2>
			<button
				class="toggle-btn px-[7.75px] py-[2.5px]"
				on:click={toggleControlPanel}
				style="transform: rotate({isControlPanelVisible && result === '' ? '180deg' : '0deg'});"
				disabled={isRolling || result !== ''}
			>
				&#11166;
			</button>
		</div>
		<div class="flex">
			<div class=" mt-4 flex w-[360px]">
				<!-- Settings -->
				<ul class="w-full">
					<li class="mt-2 mb-5 flex items-center justify-between">
						<label class="basis-2/12" for="prompt">Title:</label>
						<input
							type="text"
							id="prompt"
							placeholder="Title"
							bind:value={resultTitle}
							maxlength="30"
							class="prompt-input basis-10/12 rounded-md border border-black px-2 py-1"
						/>
					</li>
					{#each cubeProps as cube}
						<li class="mt-2 flex items-center justify-between">
							<label class="basis-1/12" for={cube.text}>{cube.text}:</label>
							<input
								type="text"
								id={cube.face}
								placeholder={`Text for ${cube.text}`}
								bind:value={cube.prompt}
								class="prompt-input basis-11/12 rounded-md border border-black px-2 py-0.5"
							/>
						</li>
					{/each}
				</ul>
			</div>
			<div class="absolute translate-x-[360px] translate-y-32 rotate-[-90deg] font-bold">
				{#if !isControlPanelVisible || result !== ''}
					<div in:fade={{ duration: 150 }} out:fade={{ duration: 100 }}>Settings</div>
				{/if}
			</div>
		</div>
	</div>

	<!-- Dice -->
	<button
		class="scene hover:cursor-pointer disabled:cursor-default"
		style="top: {posY}%; left: {posX}%; transform: translate(-50%, -50%);"
		on:click={getDiceFaceValue}
		disabled={isRolling || result !== ''}
		transition:fly={{ y: -500, duration: 500, delay: 100 * delayFactor }}
	>
		<div
			id="cube"
			class="cube"
			style="
        width: {cubeSize}px;
        height: {cubeSize}px;
        transform: rotateX(0deg) rotateY(0deg);"
		>
			{#each cubeProps as cube}
				<div
					class="face"
					id={cube.face}
					style="background: {bgColor};
                       color: {color};
                       border: {cubeSize / 10}px solid {borderColor};
                       transform: {cube.x !== 0 ? `rotateX(${cube.x}deg)` : ''} 
                                  {cube.y !== 0 ? `rotateY(${cube.y}deg)` : ''}
                       translateZ({cubeSize / 2.025}px); font-size: {cubeSize / 1.5}px;"
				>
					{cube.text}
				</div>
			{/each}
		</div>
	</button>

	<!-- Result -->
	{#if result}
		<!-- svelte-ignore a11y_click_events_have_key_events -->
		<!-- svelte-ignore a11y_no_static_element_interactions -->
		<div
			class="fixed inset-0 flex items-center justify-center bg-[#00000060]"
			transition:fade={{ duration: 250 }}
			on:click={resetResult}
		>
			<div
				class="modal flex h-1/6 w-1/4 items-center rounded-lg p-2"
				in:fly={{ y: -150, duration: 500 }}
				out:fly={{ y: 350, duration: 250 }}
				on:click|stopPropagation
			>
				<div class="modal-inner h-full w-full rounded-lg px-5 py-2">
					<div class="modal-header mb-5 flex justify-between text-2xl font-bold">
						<h2 class="text-center">{resultTitle !== '' ? resultTitle : 'Result'}</h2>
						<button class="justify-self-end hover:cursor-pointer" on:click={resetResult}>
							&times;
						</button>
					</div>
					<div class="modal-content">
						<p class="text-center">{result}</p>
					</div>
				</div>
			</div>
		</div>
	{/if}
{/if}

<style>
	.modal {
		background: #f76027;
		transition: all 0.25s;
	}

	:global(body.dark-mode) .modal {
		background: #0084f6;
	}

	.modal-header {
		color: #f76027;
		transition: all 0.25s;
	}

	:global(body.dark-mode) .modal-header {
		color: #0084f6;
	}

	.modal-inner {
		background: white;
		color: black;
		transition: all 0.25s;
	}

	:global(body.dark-mode) .modal-inner {
		background: #062b4b;
		color: white;
	}

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
		border-radius: 50%;
		border: 2px solid #f76027;
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

	.toggle-btn:disabled {
		background-color: #ccc;
		color: #666;
		border-color: #666;
		cursor: default;
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

	:global(body.dark-mode) .toggle-btn:disabled {
		background-color: #333;
		color: #666;
		border-color: #666;
	}

	.prompt-input {
		border: 2px solid #f76027;
		background: white;
		font-size: 14px;
		transition: all 0.25s;
	}

	:global(body.dark-mode) .prompt-input {
		border-color: #0084f6;
		background: #061b2b;
		color: white;
	}

	.scene {
		width: 200px;
		height: 200px;
		perspective: 800px;
		position: absolute;
	}

	.cube {
		position: relative;
		transform-style: preserve-3d;
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

	@keyframes titleAnimation {
		0% {
			transform: scale(1);
		}
		50% {
			transform: scale(1.25);
		}
		100% {
			transform: scale(1);
		}
	}

	.title {
		animation: titleAnimation 3s infinite;
		transition: all 0.25s;
	}
</style>
