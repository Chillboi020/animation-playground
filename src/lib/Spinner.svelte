<script lang="ts">
	export let size = 25;
	export let duration = 2.5;
	export let circleCount = 15;
	export let mirror = false;

	const minSize = size - (circleCount - 1);
	const maxDelay = 0.5;

	const colorThemes = {
		light: {
			start: [247, 190, 103],
			end: [247, 96, 39]
		},
		dark: {
			start: [50, 68, 182],
			end: [0, 132, 246]
		}
	};

	function getColor(index: number, total: number, mode: 'light' | 'dark' = 'light') {
		const startColor = colorThemes[mode].start;
		const endColor = colorThemes[mode].end;

		// Farbinterpolation zwischen Start- und Endfarbe
		const r = Math.round(startColor[0] + ((endColor[0] - startColor[0]) * index) / total);
		const g = Math.round(startColor[1] + ((endColor[1] - startColor[1]) * index) / total);
		const b = Math.round(startColor[2] + ((endColor[2] - startColor[2]) * index) / total);

		return `rgb(${r}, ${g}, ${b})`;
	}

	function getGlow(index: number, total: number, mode: 'light' | 'dark' = 'light') {
		let color = getColor(index, total, mode);
		return `0px 0px 10px ${color}, 0px 0px 20px ${color}`; // Doppelte Schattierung für besseren Glow
	}

	// Dynamische Erzeugung der Kreise
	const circles = Array.from({ length: circleCount }, (_, index) => ({
		size: minSize + index, // Größe nimmt mit jedem Kreis zu
		delay: maxDelay * (1 - index / circleCount), // Verzögerung nimmt schrittweise ab
		backgroundColor: getColor(index, circleCount),
		darkModeColor: getColor(index, circleCount, 'dark'),
		glow: getGlow(index, circleCount), // Glow für Normal-Mode
		darkGlow: getGlow(index, circleCount, 'dark') // Glow für Dark-Mode
	}));
</script>

{#each circles as circle}
	<div
		class="{mirror ? 'circle-mirrored' : 'circle'}"
		style="
            --size: {circle.size}px; 
            --duration: {duration}s; 
            --delay: {circle.delay}s; 
            --background-color: {circle.backgroundColor}; 
            --dark-mode-color: {circle.darkModeColor};
            --glow: {circle.glow};
            --dark-glow: {circle.darkGlow};
		"
	></div>
{/each}

<style>
	@keyframes rotate {
		0% {
			transform: rotate(0deg) translateX(75px);
		}
		50% {
			transform: rotate(180deg) translateX(75px);
		}
		100% {
			transform: rotate(360deg) translateX(75px);
		}
	}

	@keyframes rotateMirrored {
		0% {
			transform: rotate(0deg) translateX(-75px);
		}
		50% {
			transform: rotate(-180deg) translateX(-75px);
		}
		100% {
			transform: rotate(-360deg) translateX(-75px);
		}
	}

	.circle {
		background-color: var(--background-color);
		width: var(--size);
		height: var(--size);
		border-radius: 50%;
		position: absolute;
		animation: rotate var(--duration) ease-in-out infinite;
		animation-delay: var(--delay);
		transition: all 0.25s;
		box-shadow: var(--glow);
	}

	.circle-mirrored {
		background-color: var(--background-color);
		width: var(--size);
		height: var(--size);
		border-radius: 50%;
		position: absolute;
		animation: rotateMirrored var(--duration) ease-in-out infinite;
		animation-delay: var(--delay);
		transition: all 0.25s;
		box-shadow: var(--glow);
	}

	:global(body.dark-mode) .circle {
		background-color: var(--dark-mode-color);
		box-shadow: var(--dark-glow);
	}

	:global(body.dark-mode) .circle-mirrored {
		background-color: var(--dark-mode-color);
		box-shadow: var(--dark-glow);
	}
</style>
