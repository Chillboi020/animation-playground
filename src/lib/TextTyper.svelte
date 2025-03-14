<script lang="ts">
	import { onMount } from 'svelte';
	import words from './typer';

	let part = "";
	let i = 0;
	let offset = 0;
	let forwards = true;
	let isPaused = false;
	let cursorVisible = true;

	const writeSpeed = 80; // Schreibgeschwindigkeit
    const deleteSpeed = writeSpeed / 2; // Löschgeschwindigkeit
	const pauseTime = 2000; // Pause nach jedem Wort
	const cursorBlinkSpeed = 500; // Geschwindigkeit des Cursor-Blinkens

	function wordflick() {
		let interval = setInterval(() => {
			if (!isPaused) {
				if (forwards) {
					part = words[i].substring(0, offset);
					offset++;

					if (offset > words[i].length) {
						isPaused = true;
						let blink = cursorBlink();
						setTimeout(() => {
							clearInterval(blink);
							cursorVisible = true;
							forwards = false;
							isPaused = false;
							clearInterval(interval);
							wordflick(); // Neustart mit neuer Geschwindigkeit
						}, pauseTime);
					}
				} else {
					part = words[i].substring(0, offset);
					offset--;

					if (offset < 0) {
						forwards = true;
						i = (i + 1) % words.length;
						offset = 0;
						isPaused = true;
						setTimeout(() => {
							cursorVisible = true;
							isPaused = false;
							clearInterval(interval);
							wordflick(); // Neustart mit neuer Geschwindigkeit
						}, pauseTime / 5);
					}
				}
			}
		}, forwards ? writeSpeed : deleteSpeed); // Unterscheide zwischen Schreiben und Löschen
	}

	function cursorBlink() {
		return setInterval(() => {
			cursorVisible = !cursorVisible;
		}, cursorBlinkSpeed);
	}

	onMount(() => {
		wordflick();
	});
</script>

<div class="word">
	> {part}<span class="cursor" class:visible={cursorVisible}>_</span>
</div>

<style>
	.word {
		color: #d34d00;
		font: 700 normal 2.5em 'Tahoma';
		transition: all 0.25s;
	}

	.cursor {
		opacity: 0;
		transition: opacity 0.1s;
	}

	.cursor.visible {
		opacity: 1;
	}

	:global(body.dark-mode) .word {
		color: #40c4f6;
	}
</style>
