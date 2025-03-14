<script lang="ts">
	import Spinner from '$lib/Spinner.svelte';
	import TextTyper from '$lib/TextTyper.svelte';
	import { onMount } from 'svelte';
	import { fade, fly } from 'svelte/transition';

	const title = 'Animation Sandbox';
	let isLoaded = false;
	let titleText = title;

	onMount(() => {
		window.document.title = titleText;
		isLoaded = true;
	});
</script>

{#if isLoaded}
	<div class="flex mt-64 flex-col items-center justify-center">
		<h1 class="title text-5xl font-bold" transition:fade={{ duration: 1000 }}>
			My Animation-Sandbox
		</h1>
		<div class="mt-10" transition:fade={{ duration: 1000, delay: 100 }}>
			<TextTyper />
		</div>
		<div class="grid grid-cols-2 mt-32 gap-x-32">
			<div class="flex flex-col items-center" transition:fade={{ duration: 1000, delay: 500 }}>
				<Spinner mirror={true} />
				<a href="/dice" class="link primary text-2xl font-bold ">Dice</a>
			</div>
			<div class="flex flex-col items-center" transition:fade={{ duration: 1000, delay: 500 }}>
				<Spinner />
				<a href="/cuby" class="link secondary text-2xl font-bold">Cuby</a>
			</div>
		</div>
	</div>
{/if}

<style>
	@keyframes titlePulse {
		0% {
			transform: rotate(5deg);
		}
		25% {
			transform: rotate(-5deg);
		}
		50% {
			transform: scale(1.25) rotate(5deg);
		}
		75% {
			transform: scale(1.25) rotate(-5deg);
		}
		100% {
			transform: rotate(5deg);
		}
	}

	@keyframes titleColorChange {
		50% {
			color: #f76027;
		}
	}

	@keyframes titleColorChangeDark {
		50% {
			color: #0084f6;
		}
	}

	.title {
		animation: titlePulse 5s infinite, titleColorChange 5s infinite;
		transition: all 0.25s;
	}

	:global(body.dark-mode) .title {
		animation: titlePulse 5s infinite, titleColorChangeDark 5s infinite;
	}

	.link {
		color: #f76027;
		transition: all 0.25s;
	}

	.link:hover {
		opacity: 0.75;
	}

	.primary:hover {
		transform: scale(1.25) rotate(5deg);
	}

	.secondary:hover {
		transform: scale(1.25) rotate(-5deg);
	}

	:global(body.dark-mode) .link {
		color: #0084f6;
	}
</style>
