<script lang="ts">
	import { onMount } from 'svelte';
	import { page } from '$app/stores';
	import '../app.css';
	import ThemeToggle from '$lib/ThemeToggle.svelte';
	import { fade, fly } from 'svelte/transition';
	let { children } = $props();

	onMount(() => {
		const savedTheme = localStorage.getItem('theme');
		if (savedTheme === 'dark') {
			window.document.body.classList.add('dark-mode');
		}
	});
</script>

{@render children()}
<nav class="absolute top-0 w-full px-5 py-4">
	<div class="flex items-center">
		{#if $page.url.pathname !== '/'}
			<a href="/" class="link text-xl font-bold" transition:fade={{ duration: 100 }}>Home</a>
		{:else}
			<div class="mt-7"></div>
		{/if}
		<div class="ml-auto flex items-center gap-2 text-sm">
			{#if $page.url.pathname !== '/'}
				<div class="flex gap-2" transition:fade={{ duration: 100 }}>
					<a href="/dice" class="link">Dice</a>|
				</div>
				<div class="flex gap-2" transition:fade={{ duration: 100 }}>
					<a href="/cuby" class="link">Cuby</a>|
				</div>
			{/if}
			<ThemeToggle />
		</div>
	</div>
</nav>
<div
	class="watermark absolute bottom-14 left-2 text-xs"
	transition:fly={{ x: -500, duration: 1000 }}
>
	Powered by
	<a href="https://vite.dev/" class="vite-link" target="_blank">Vite</a> +
	<a href="https://svelte.dev/" class="svelte-link" target="_blank">Svelte</a>
</div>

<footer class="absolute bottom-0 flex w-full items-center px-5 py-4">
	<div class="text-sm">
		&copy; <a href="https://github.com/Chillboi020" class="link font-bold" target="_blank">Chillizard</a> 2025
	</div>
</footer>

<style>
	:global(body) {
		transition: background-color 0.5s;
	}
	:global(body.dark-mode) {
		background-color: #061b2b;
		color: #bfc2c7;
	}

	footer {
		background-color: lightgray;
		color: rgb(90, 90, 90);
		transition: all 0.5s;
	}

	:global(body.dark-mode) footer {
		background-color: #062b4b;
		color: #afafaf;
	}

	.link {
		color: #f76027;
		transition: all 0.25s;
	}

	.link:hover {
		color: #d74007;
	}

	:global(body.dark-mode) .link {
		color: #0084f6;
	}

	:global(body.dark-mode) .link:hover {
		color: #0056b3;
	}

	.watermark {
		color: #999;
		transition: all 0.5s;
	}

	:global(body.dark-mode) .watermark {
		color: #666;
	}

	/* Color gradient of the Vite Logo */
	.vite-link:hover {
		background: linear-gradient(90deg, #64acff, #8a2be2);
		-webkit-background-clip: text;
		background-clip: text;
		color: transparent;
		transition: all 0.5s;
	}

	.svelte-link:hover {
		background: linear-gradient(90deg, #ffa33b, #f76027);
		-webkit-background-clip: text;
		background-clip: text;
		color: transparent;
		transition: all 0.5s;
	}
</style>
