<template>
  <main class="page-shell">
    <header class="top-panel">
      <div class="hello-mark" aria-label="Hello World">
        <img
          v-if="showWelcomeImage"
          :src="helloImage"
          alt="Hello, Web3"
          @error="showWelcomeImage = false"
        />
        <div v-else class="welcome-placeholder">
          <span>Hello,</span>
          <span>&nbsp;&nbsp;&nbsp;&nbsp;Web3_</span>
        </div>
      </div>

      <div class="clock-panel">
        <span>{{ clock.day }}</span>
        <strong>{{ clock.time }}</strong>
        <span>UTC+8 Taipei</span>
      </div>
    </header>

    <CryptoTicker />

    <section class="stage">
      <div class="cards-stack">
        <article
          v-for="(card, index) in cards"
          :key="card.id"
          class="content-card"
          :class="cardState(index)"
          :aria-hidden="index !== activeIndex"
        >
          <div class="window-bar" aria-hidden="true">
            <span></span>
            <span></span>
            <span></span>
          </div>
          <div class="card-content">
            <p class="eyebrow">{{ card.eyebrow }}</p>
            <h1 v-html="card.title"></h1>
            <p class="terminal-line">{{ card.command }}</p>
            <p class="card-copy">{{ card.copy }}</p>
            <div class="action-row">
              <button class="primary-button" type="button">
                {{ card.primary }}
              </button>
              <button class="ghost-button" type="button">
                {{ card.secondary }}
              </button>
            </div>
          </div>
        </article>
      </div>

      <ThreeAvatar class="avatar-scene" />

      <aside class="side-nav" aria-label="Profile sections">
        <div class="identity">
          <span class="diamond">AQ</span>
          <div>
            <strong>AARON QUIRK</strong>
            <small>CTO</small>
          </div>
        </div>

        <button
          v-for="(card, index) in cards"
          :key="card.id"
          class="card-nav-item"
          :class="{ selected: index === activeIndex }"
          type="button"
          @click="setActive(index)"
        >
          <span>{{ String(index + 1).padStart(2, "0") }}</span>
          <strong>{{ card.label }}</strong>
        </button>

        <a
          class="web2-nav-link"
          href="https://hi.ohno104.dev"
          target="_blank"
          rel="noreferrer"
        >
          <span>04</span>
          <strong>web2</strong>
        </a>

        <div class="made-with">
          <span>Made with CodeX</span>
        </div>
      </aside>
    </section>
  </main>
</template>

<script setup>
import { onMounted, onUnmounted, ref } from "vue";
import CryptoTicker from "./components/CryptoTicker.vue";
import ThreeAvatar from "./components/ThreeAvatar.vue";
import helloImage from "./assets/hello.webp";

const activeIndex = ref(0);
const clock = ref(formatClock());
const showWelcomeImage = ref(true);

const cards = [
  {
    id: "about",
    label: "about",
    eyebrow: "CTO.SH",
    title: "Aaron <span>Quirk.</span>",
    command: "$ building domain infrastructure",
    copy: "Lifelong programmer with a passion for building things that scale. Deep in the domain industry, the infrastructure that keeps the internet's address book running.Lifelong programmer with a passion for building things that scale. Deep in the domain industry, the infrastructure that keeps the internet's address book running.Lifelong programmer with a passion for building things that scale. Deep in the domain industry, the infrastructure that keeps the internet's address book running.Lifelong programmer with a passion for building things that scale. Deep in the domain industry, the infrastructure that keeps the internet's address book running.",
    primary: "view work",
    secondary: "say hi",
  },
  {
    id: "work",
    label: "work",
    eyebrow: "SHIP.LOG",
    title: "Protocol <span>Work.</span>",
    command: "$ deploying resilient web3 products",
    copy: "From wallet-aware identity surfaces to trading dashboards, every screen is tuned for speed, clarity, and useful motion.",
    primary: "open cases",
    secondary: "stack",
  },
  {
    id: "stack",
    label: "stack",
    eyebrow: "NODE.LAB",
    title: "Modern <span>Stack.</span>",
    command: "$ vue three binance realtime",
    copy: "Vue drives the interface, Three.js renders the character, and Binance market data feeds the live crypto ticker across the top rail.",
    primary: "inspect",
    secondary: "contact",
  },
];

function setActive(index) {
  activeIndex.value = index;
}

function cardState(index) {
  const total = cards.length;
  const offset = (index - activeIndex.value + total) % total;

  if (offset === 0) return "is-front";
  if (offset === 1) return "is-next";
  return "is-back";
}

function formatClock() {
  const formatter = new Intl.DateTimeFormat("en-CA", {
    timeZone: "Asia/Taipei",
    weekday: "short",
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
    hour: "2-digit",
    minute: "2-digit",
    second: "2-digit",
    hour12: false,
  });

  const parts = Object.fromEntries(
    formatter.formatToParts(new Date()).map((part) => [part.type, part.value]),
  );

  return {
    day: `${parts.weekday.toUpperCase()} ${parts.year}-${parts.month}-${parts.day}`,
    time: `${parts.hour}:${parts.minute}:${parts.second}`,
  };
}

let clockTimer;

onMounted(() => {
  clockTimer = window.setInterval(() => {
    clock.value = formatClock();
  }, 1000);
});

onUnmounted(() => {
  window.clearInterval(clockTimer);
});
</script>
