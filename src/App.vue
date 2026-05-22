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
          <div
            class="card-content"
            v-html="cardHtml[card.id]"
            @click="handleCardContentClick"
          ></div>
        </article>
      </div>

      <ThreeAvatar class="avatar-scene" />

      <aside class="side-nav" aria-label="Profile sections">
        <div class="identity">
          <div>
            <strong>FELIX HUANG</strong>
            <small>Software Engineer</small>
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
    contentUrl: "/cards/about.html",
  },
  {
    id: "career",
    label: "career",
    contentUrl: "/cards/career.html",
  },
  {
    id: "contact",
    label: "contact",
    contentUrl: "/cards/contact.html",
  },
  {
    id: "web2",
    label: "web2",
    contentUrl: "/cards/web2.html",
  },
];

const cardHtml = ref({});

function setActive(index) {
  activeIndex.value = index;
}

function setActiveById(id) {
  const index = cards.findIndex((card) => card.id === id);
  if (index >= 0) setActive(index);
}

function handleCardContentClick(event) {
  const target = event.target.closest("[data-card-target]");
  if (!target) return;

  event.preventDefault();
  setActiveById(target.dataset.cardTarget);
}

function cardState(index) {
  const total = cards.length;
  const offset = (index - activeIndex.value + total) % total;

  if (offset === 0) return "is-front";
  if (offset === 1) return "is-next";
  if (offset === 2) return "is-back";
  return "is-far";
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

async function loadCardHtml() {
  const entries = await Promise.all(
    cards.map(async (card) => {
      const response = await fetch(card.contentUrl);
      if (!response.ok) throw new Error(`Unable to load ${card.contentUrl}`);
      return [card.id, await response.text()];
    }),
  );

  cardHtml.value = Object.fromEntries(entries);
}

let clockTimer;

onMounted(() => {
  loadCardHtml();
  clockTimer = window.setInterval(() => {
    clock.value = formatClock();
  }, 1000);
});

onUnmounted(() => {
  window.clearInterval(clockTimer);
});
</script>
