# Browser Capability

When browser verification is required, use an available browser automation capability.

Playwright MCP is the preferred browser capability in this environment when available.

If a browser-capable task cannot access a usable browser tool, report the missing capability instead of treating source inspection as equivalent verification.

## Headless remote sessions only

This section applies **only** when the session runs in a remote command-line
environment with no graphical session. Typically that is a server reached over
SSH: `SSH_CONNECTION` is set and neither `DISPLAY` nor `WAYLAND_DISPLAY` is set.
On a normal local development machine with a desktop, ignore this section and
use the usual browser capability above.

In that remote environment, a missing GUI is not a missing browser: run one
headless.

1. **Check what is installed before installing anything.**
   `command -v google-chrome chromium`, and `ls ~/.cache/ms-playwright`.
   Cached Playwright browsers alone are not enough; something has to drive them.
2. **Drive the browser from a throwaway script, not from the repository.**
   If no Playwright package is installed, use
   `uv run --with playwright python script.py` from a scratch directory, and
   launch the system Chrome with
   `chromium.launch(executable_path="/bin/google-chrome", headless=True)`.
   Do not add Playwright to a project's dependencies just to verify a change.
3. **Get past login without credentials.** When the frontend redirects to
   Keycloak on load, use a verification-only Vite config outside the
   repository that is identical to the repository's config except that it
   replaces the Keycloak module with a stub. The IJOOZ workspaces keep a
   ready-made one in `ijooz-debug-kit/harnesses/frontend-auth-stub`. Symlink
   the target repository's `node_modules` next to that config so its plugins
   resolve.
4. **Stub the backend at the browser.** Intercept the app's API requests in the
   page (Playwright `page.route`) and answer them from the frozen contract.
   This also lets you produce the hard-to-reach states (busy, rate-limited,
   failed, legacy response shape) on purpose. Route only the API origin and
   prefix (for example `http://127.0.0.1:<port>/api/**`); a broad `**/api/**`
   also catches dev-server source files such as `/src/api/*.ts`.
5. **Check ports before starting a dev server.** Other projects' dev servers
   are often already listening (5173, 5174, 8899 have been taken). Use
   `ss -ltn` and pass an explicit free port with `--strictPort`.
6. **Inspect, don't just assert.** Take screenshots and read them, collect
   console errors and page errors, and check narrow widths for horizontal
   scrolling.
7. **State the limit in the report.** Stubbed responses prove that the frontend
   handles each contract response correctly. They do not prove the real
   gateway and backend path; say so, and name the environment where that
   still has to be checked.

Stop the dev servers you started when you are done.
