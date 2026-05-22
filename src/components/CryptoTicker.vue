<template>
  <div
    class="ticker"
    aria-label="15-minute cryptocurrency price changes from Binance"
  >
    <div class="ticker-track" :class="{ paused: isLoading }">
      <div v-for="loop in 2" :key="loop" class="ticker-group">
        <span
          v-for="coin in tickerCoins"
          :key="`${loop}-${coin.symbol}`"
          class="ticker-item"
        >
          <strong>{{ coin.base }}/USDT</strong>
          <span>{{ formatPrice(coin.price) }}</span>
          <em
            v-if="coin.change !== null"
            :class="coin.change >= 0 ? 'up' : 'down'"
          >
            {{ coin.change >= 0 ? "▲" : "▼" }}
            {{ Math.abs(coin.change).toFixed(2) }}%
          </em>
          <em v-else>----</em>
        </span>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed, onMounted, onUnmounted, ref } from "vue";

const symbols = [
  "BTCUSDT",
  "ETHUSDT",
  "XRPUSDT",
  "SOLUSDT",
  "DOGEUSDT",
  "BNBUSDT",
  "UNIUSDT",
  "LINKUSDT",
  "XLMUSDT",
  "BCHUSDT",
];
const refreshInterval = 15 * 60 * 1000;
const prices = ref(new Map());

const isLoading = computed(() => prices.value.size === 0);

const tickerCoins = computed(() => {
  return symbols.map((symbol) => {
    const coin = prices.value.get(symbol);

    return {
      symbol,
      price: coin?.price ?? null,
      change: coin?.change ?? null,
      base: symbol.replace("USDT", ""),
    };
  });
});

function formatPrice(price) {
  if (price === null || price === undefined) return "----";

  const value = Number(price);
  return new Intl.NumberFormat("en-US", {
    style: "currency",
    currency: "USD",
    maximumFractionDigits: value > 100 ? 0 : 3,
  }).format(value);
}

async function loadBinancePrices() {
  const candles = await Promise.allSettled(
    symbols.map(loadFifteenMinuteCandle),
  );
  const nextPrices = new Map(prices.value);

  for (const result of candles) {
    if (result.status === "fulfilled" && result.value) {
      nextPrices.set(result.value.symbol, result.value);
    } else if (result.status === "rejected") {
      console.warn(result.reason);
    }
  }

  prices.value = nextPrices;
}

async function loadFifteenMinuteCandle(symbol) {
  const params = new URLSearchParams({
    symbol,
    interval: "15m",
    limit: "1",
  });
  const response = await fetch(
    `https://api.binance.com/api/v3/klines?${params}`,
  );
  if (!response.ok)
    throw new Error(`Unable to load Binance 15m candle for ${symbol}`);

  const [latestCandle] = await response.json();
  if (!latestCandle) return null;

  const open = Number(latestCandle[1]);
  const close = Number(latestCandle[4]);
  const change = open ? ((close - open) / open) * 100 : 0;

  return {
    symbol,
    price: close,
    change,
  };
}

let refreshTimer;

onMounted(() => {
  loadBinancePrices();
  refreshTimer = window.setInterval(loadBinancePrices, refreshInterval);
});

onUnmounted(() => {
  window.clearInterval(refreshTimer);
});
</script>
