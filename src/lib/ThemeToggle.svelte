<script lang="ts">
	import { onMount } from 'svelte';

	let themeLight = true;
	function toggle() {
		const body = window.document.body;
		body.classList.toggle('dark-mode');

		const isDarkMode = body.classList.contains('dark-mode');
        themeLight = !isDarkMode;
		localStorage.setItem('theme', isDarkMode ? 'dark' : 'light');
	}

	onMount(() => {
		const savedTheme = localStorage.getItem('theme');
		if (savedTheme === 'dark') {
			window.document.body.classList.add('dark-mode');
			themeLight = false;
		}
	});
</script>

<button on:click={toggle}>
	{#if themeLight}
		Light
	{:else}
		Dark
	{/if}
</button>

<style>
	button {
		background-color: #f76027;
		color: white;
		border-color: #f76027;
		border-width: 2px;
		border-radius: 8px;
		padding: 0.05rem 0.5rem;
		transition: all 0.25s;
		cursor: pointer;
        width: 75px;
	}

	button:hover {
		color: #f76027;
        font-weight: bold;
		background-color: white;
	}

	:global(body.dark-mode) button {
		background-color: #0084f6;
		color: black;
		border-color: #0084f6;
	}

	:global(body.dark-mode) button:hover {
		color: #0084f6;
		background-color: #061b2b;
	}
</style>
