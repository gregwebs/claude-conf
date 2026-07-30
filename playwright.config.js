const { defineConfig } = require("@playwright/test");

module.exports = defineConfig({
  testDir: "./e2e",
  timeout: 45000,
  globalSetup: require.resolve("./e2e/global-setup.js"),
  use: {
    browserName: "chromium",
    // launchOptions are set per-test in e2e/fixtures.js (needed for sandbox).
    launchOptions: { args: ["--autoplay-policy=no-user-gesture-required", "--no-proxy-server", "--single-process"] },
  },
});
