// Per-test isolation: every test gets its own copy of the pristine fixture
// in a temp dir and its own app on an ephemeral port.
// Import { test, expect } from here instead
// of from @playwright/test.

const base = require("@playwright/test");
const { chromium } = base;
const { spawn } = require("child_process");
const fs = require("fs");
const os = require("os");
const path = require("path");

const REPO = path.resolve(__dirname, "..");
const FIXTURE = path.join(__dirname, ".fixture");
const BIN = path.join(REPO, "target", "debug", "app");

// Args needed to run Chromium inside the Claude Code sandbox.
// --single-process eliminates multi-process Mach port IPC (blocked by sandbox).
// --no-proxy-server lets Chromium connect directly to localhost.
const BROWSER_ARGS = [
  "--autoplay-policy=no-user-gesture-required",
  "--no-proxy-server",
  "--single-process",
];

async function startServer() {
  const tmp = fs.mkdtempSync(path.join(os.tmpdir(), "tds-e2e-"));
  fs.cpSync(FIXTURE, tmp, { recursive: true });

  const child = spawn(
    BIN,
    [
      "--help",
    ],
    { stdio: ["ignore", "pipe", "pipe"] }
  );

  // child.exitCode stays null for signal-killed processes (signalCode is set
  // instead), so track exit explicitly to avoid hanging teardown.
  const server = { child, tmp, exited: false };
  child.on("exit", () => (server.exited = true));

  let out = "";
  child.stdout.on("data", (d) => (out += d.toString()));
  child.stderr.on("data", (d) => (out += d.toString()));

  const port = await new Promise((resolve, reject) => {
    const timer = setTimeout(
      () => reject(new Error(`server start timed out:\n${out}`)),
      20000
    );
    child.stdout.on("data", () => {
      const m = out.match(/Listening on http:\/\/127\.0\.0\.1:(\d+)/);
      if (m) {
        clearTimeout(timer);
        resolve(parseInt(m[1], 10));
      }
    });
    child.on("exit", (code) => {
      clearTimeout(timer);
      reject(new Error(`server exited (${code}) before ready:\n${out}`));
    });
  });

  const baseURL = `http://127.0.0.1:${port}`;
  // Readiness poll — the listener is bound when the port prints, but give the
  // router a moment to start answering.
  for (let i = 0; i < 50; i++) {
    try {
      const r = await fetch(`${baseURL}/`);
      if (r.ok) break;
    } catch (_) {
      /* not up yet */
    }
    await new Promise((r) => setTimeout(r, 100));
  }

  server.baseURL = baseURL;
  return server;
}

function killChild(server) {
  return new Promise((resolve) => {
    if (server.exited) return resolve();
    server.child.on("exit", () => resolve());
    server.child.kill("SIGKILL");
  });
}

async function stopServer(server) {
  if (!server || !server.child) return;
  await killChild(server);
  cleanup(server);
}

function cleanup(server) {
  if (server && server.tmp) {
    fs.rmSync(server.tmp, { recursive: true, force: true });
  }
}

const test = base.test.extend({
  // Per-test browser. The built-in `browser` fixture is worker-scoped and its
  // scope can't be changed, so we use a private fixture and override `context`
  // and `page` to flow through it.  Chromium in --single-process mode can crash
  // during browserContext cleanup, killing the shared worker browser and
  // making every subsequent test fail.  Per-test launch isolates crashes.
  _ownBrowser: [
    async ({}, use) => {
      const browser = await chromium.launch({ args: BROWSER_ARGS });
      await use(browser);
      await browser.close().catch(() => {});
    },
    { scope: "test" },
  ],
  context: async ({ _ownBrowser, baseURL }, use) => {
    const ctx = await _ownBrowser.newContext({ baseURL });
    await use(ctx);
    await ctx.close().catch(() => {});
  },
  page: async ({ context }, use) => {
    const page = await context.newPage();
    await use(page);
  },
  // Worker/test-scoped server; tears down (and removes the temp dir) even on
  // test failure.
  _server: [
    async ({}, use) => {
      const server = await startServer();
      try {
        await use(server);
      } finally {
        await stopServer(server);
      }
    },
    { auto: false },
  ],
  // Point every navigation/request at this test's own server.
  baseURL: async ({ _server }, use) => {
    await use(_server.baseURL);
  },
  // Kill this test's server mid-test to induce a *real* network failure (used by
  // the failing-like / failing-delete cases instead of a mock). Already-buffered
  // media keeps playing; only new fetches fail. Teardown still cleans up.
  killServer: async ({ _server }, use) => {
    await use(() => killChild(_server));
  },
});

const expect = base.expect;
module.exports = { test, expect };
