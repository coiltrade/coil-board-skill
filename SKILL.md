---
name: coil-board
description: >-
  Buy Coil's scored, ranked stock board over x402 instead of building a scanner.
  Use when an agent needs a market read — is the tape risk-on or risk-off, which
  S&P 500 / Nasdaq-100 / macro names are set up to buy right now, or the full
  ~565-name board with opportunity, entry-timing and hold-strength scores. Pays
  per read in USDC on Base (eip155:8453) via the x402 protocol — no account, no
  card, no email. Research, not investment advice.
license: See https://coil.trade/terms
homepage: https://coil.trade/agents
---

# Coil Board API

Coil publishes a scored, ranked read of the US equity market (and a long-only
BTC/ETH trend book) that an agent can buy one read at a time over
[x402](https://x402.org). You are not buying raw OHLCV — that is free everywhere.
You are buying the **judgment**: which names are set up to buy, how strong the
regime is, and how the board ranks today, read top-down.

Everything here is an **impersonal research publication** — identical for every
buyer, scores and states only, never stop or target prices, never individualized
advice. Markets can lose money.

## When to use this skill

- You need a market-regime gate before doing something expensive: *is it risk-on
  or risk-off right now?* → call `/api/board/regime` ($0.005).
- You want today's ranked buy candidates without scanning 500 names yourself →
  call `/api/board/buylist` ($0.05).
- You want the whole board — every scored name across four books, sector lanes,
  both buy-list lanes — to do your own selection → call `/api/board/agent` ($0.25).

## The endpoints (23 — full catalogue at `GET https://coil.trade/api`)

| Endpoint | Price (USDC) | Returns |
|---|---|---|
| `GET https://coil.trade/api/live/session`  | 0.25 | A 1-hour Coil Live session token, minted on payment. Send it as `X-License-Key` to unlock every `*_live` tool, `get_engine_feed` and `get_live_rules` — the wallet-native way to try the $49/mo Coil Live tier by the hour; the subscription wins past about 196 hours a month (break-even ≈196 hours). |
| `GET https://coil.trade/api/board/regime`  | 0.005 | Regime verdict per book (risk-on / be-selective / stand-down) + the index→sector→name permission ladder. |
| `GET https://coil.trade/api/board/crypto`  | 0.005 | BTC/ETH long-only trend signal: LONG or CASH per sleeve, 50-day gates + the BTC 200-day master gate (UTC daily closes). |
| `GET https://coil.trade/api/board/indices` | 0.005 | The scored index row per book (SPY, QQQ, macro, BTC/ETH) — the cheapest top-down read. |
| `GET https://coil.trade/api/board/name?sym=NVDA` | 0.005 | One stock's full read + its book's regime — or up to **10 names in one call** (`?sym=NVDA,AMD,MSFT`). Any of ~565 names. |
| `GET https://coil.trade/api/board/hold?sym=NVDA` | 0.005 | Per-symbol HOLD state (up to 10 per call): trend state, hold strength, readiness, maturity-late flag, gap-risk grade + book regime; BTC-USD/ETH-USD return the crypto IN\|CASH daily-close state. Never ingests your entry or size. |
| `GET https://coil.trade/api/board/movers`  | 0.005 | Top 10 gainers + 10 losers, fully scored. |
| `GET https://coil.trade/api/board/sectors` | 0.01  | Every sector ETF scored + the regime's green sectors. |
| `GET https://coil.trade/api/board/sector?name=Energy` | 0.01 | One sector's members, fully scored and ranked (`?etf=XLE` works too). |
| `GET https://coil.trade/api/board/leaders` | 0.01  | Top 10 leadership names per book by opportunity. |
| `GET https://coil.trade/api/board/buylist` | 0.05  | Today's ranked candidates per book across two lanes, with entry windows and leadership flags. |
| `GET https://coil.trade/api/board/top-volume` | 0.05 | Top-5 by 20-day dollar volume in every sector, fully scored. |
| `GET https://coil.trade/api/crypto/gate`   | 0.001 | The cheapest check: is the BTC 200-day master gate open? LONG/CASH per sleeve + verdict. |
| `GET https://coil.trade/api/crypto/night`  | 0.001 | Overnight continuation read: the top-5 session-momentum coins into the 20:00 UTC signal + the BTC 200-day regime gate + the pre-registered study receipts (beat its null at every fee tier; REFUTED at Robinhood retail taker fees — the refutation ships in the read). ~15-min refresh, 24/7. |
| `GET https://coil.trade/api/crypto/setup`  | 0.05  | Crypto SETUP scan: washed-shape hits across all 81 RH-tradable coins — GO, fuel vs BTC, grade, room, plus the setup column for the whole universe (~5-min recompute, 24/7; equity-validated shapes, forward-graded on crypto). |
| `GET https://coil.trade/api/crypto/day`    | 0.005 | 24/7 crypto day-state board: 81 RH-tradable coins — trend distances, tape lights, ATR%, RS vs BTC, room, volume z, UP/CHOP/DOWN state + ranks, plus the daily gate and breadth (publishes ~every 5 min around the clock when the market moved; a state map, not a ranking). |
| `GET https://coil.trade/api/tradfi-risk`   | 0.003 | TradFi risk-on/off for crypto agents: S&P + Nasdaq regime, sector breadth, ladder + the BTC/ETH gate. |
| `GET https://coil.trade/api/board/brief`   | 0.05  | The morning brief: regime per book + top-5 picks + biggest movers + crypto gate, in one call. |
| `GET https://coil.trade/api/board/day`   | 0.01  | day-trade state map: intraday lights grid, GO, FUEL vs anchor ETF, entry-window state, ROOM per name (~70 names, ~5-min refresh; a state map, not a ranking) |
| `GET https://coil.trade/api/board/rotation` | 0.005 | Sector + macro rotation: ~50 ETFs as GO / HOLDING / TURNING / OUT on their own X/SPY ratio vs its 50-day, with distance, slope and ratio RSI. A state map — confirmed rotation is LATE for a pullback buyer. |
| `GET https://coil.trade/api/board/diff?since=<hash>` | 0.01 | What CHANGED since the state hash you stored: who entered/left the READY candidate pool, per-name trend/light/leadership/hold-band flips, regime and ladder moves. Poll `/api/board/state` free, buy this only when the hash moves — an unchanged hash is answered free and never billed. |
| `GET https://coil.trade/api/board/asof?date=YYYY-MM-DD` | 0.05 | Point-in-time archived scores, verbatim from the append-only log — immutable, never revised; verifiable against the free `/api/board/proof`. |
| `GET https://coil.trade/api/board/agent`   | 0.25  | The full board: ~565 scored names, all four books, sector boards, both buy-list lanes. |

Free and unlimited: `GET /api/board/state` returns per-book hashes (`books.spx`, `books.qqq`) plus optional
`?syms=NVDA,AMD` per-name hashes — poll it and
buy only when it changes (`If-None-Match` gives you a 304).

Free, before any payment: `GET /api/perf` (the engine's record vs SPY/QQQ) and
`GET /api/board/proof` (append-only sha256 commitments with a reproducible verification
recipe) — check the publisher before trusting it. `POST /api/key` with an email returns an
instant free key (~25 live calls/day on the cheap slices, `X-Coil-Key` header). Have a wallet
but no email? Sign in with it instead (SIWX — the signature moves no funds): every 402
declares `extensions["sign-in-with-x"]`; sign the message and send it back as the
`SIGN-IN-WITH-X` header, or mint a durable key via `GET /api/auth/nonce` → `POST /api/auth/verify`.

No wallet? The same board is also a **remote MCP server** — free tier, full board one market
day delayed: `claude mcp add --transport http coil https://coil.trade/mcp`

## Pairing with a broker (closing the loop)

Coil publishes **what to look at**; it never places orders and never sees an account. If the
agent also has execution — Robinhood's Trading MCP (agentic accounts, budgeted sub-account) or
Alpaca's MCP/CLI (paper trading, no funded account required) — load both servers in the same
client and follow this read order:

1. `get_market_regime` — if the ladder does not permit names, stand down. Do not place orders.
2. `get_buy_list` — consider only names that appear on it.
3. `get_stock_read` / `get_sector_read` — drill into candidates before committing.
4. Only then the broker's tools, sized by the operator's own rules.

`get_morning_brief` collapses steps 1–2 into one call. **Coil emits no position sizes, no stop
prices and no target prices** — risk definition belongs to the operator, not the publisher.
Full recipe: <https://coil.trade/agents/robinhood>

All live slices read from the **same freshest payload** (two exceptions: the as-of
archive serves its requested date, and `/api/crypto/day` is its own 24/7 artifact,
published ~every 5 minutes around the clock when the market moved, self-dated via `computed_at`), so a cheap
slice is never staler than the full board. During US market hours the board
recomputes about every 5 minutes; the payload carries `computed_at` and an
`intraday` flag, plus a `freshness` block telling you when it is worth paying again.

## Try it free first

Before paying, validate your parser against the free preview — identical schema
to the paid board — live intraday timestamps, trimmed to the top-3 names per book:

```
GET https://coil.trade/api/board/agent?preview=1
```

There is also `GET https://coil.trade/api/board/free` — today's MORNING publish, top-3 per
book. It is not one market day delayed (that is the free MCP tier) and it is not intraday-fresh
either, so during a session it lags the preview above by hours; `x-coil-data-age` and the
payload's `freshness` block say by exactly how much.

## How payment works (x402)

1. `GET` the endpoint with no payment. It returns **HTTP 402** with a JSON body
   whose `accepts[0]` describes the requirement in BOTH x402 dialects: `amount`
   and `maxAmountRequired` (same value — atomic USDC, 6 decimals, `5000` =
   $0.005), `asset` (USDC `0x8335…2913`), `network` (`base`) plus
   `networkCaip2` (`eip155:8453`), and `payTo`. The `PAYMENT-REQUIRED` response
   header carries the canonical v2 (CAIP-2) form.
2. Sign an EIP-3009 `TransferWithAuthorization` for that amount to `payTo` and
   resend the request with the `PAYMENT-SIGNATURE` header (base64 x402 v2 payload).
3. On success you get **HTTP 200** with the JSON board and an on-chain receipt in
   the `PAYMENT-RESPONSE` header.

Any standard x402 client handles this loop for you — e.g. `x402-fetch` with an
EVM signer, Coinbase AgentKit, or an x402 MCP bridge. The endpoints are indexed
in the Coinbase CDP x402 Bazaar; discovery metadata is also at
`https://coil.trade/.well-known/x402` and the OpenAPI spec at
`https://coil.trade/openapi.json`.

## The default loop (copy-paste; expected cost $1–3/month)

Every retention-minded buyer converges on the same loop, so here it is as the documented
default. It spends nothing while the board is materially unchanged, $0.005 when the regime
moves, and $0.05 more only when the regime says names are enterable:

```js
// coil_loop.mjs — poll free, buy on change, escalate on permission.
// npm i x402-fetch viem   (funded Base USDC wallet; each call auto-pays via x402)
import { wrapFetchWithPayment, createSigner } from "x402-fetch";
const signer = await createSigner("base", process.env.PRIVATE_KEY);
const paid = wrapFetchWithPayment(fetch, signer, BigInt(50_000)); // hard cap $0.05/call

let etag = null, last = null;
async function tick() {
  // 1. FREE change detection — regime, ladder, candidate set, hashed per book
  const r = await fetch("https://coil.trade/api/board/state",
                        { headers: etag ? { "If-None-Match": etag } : {} });
  if (r.status === 304) return;                      // nothing moved — spend nothing
  etag = r.headers.get("ETag");
  const s = await r.json();
  const h = JSON.stringify(s.books);
  if (h === last) return;
  last = h;

  // 2. $0.005 — the regime verdict, only because something materially changed
  const regime = await (await paid("https://coil.trade/api/board/regime")).json();
  const spx = regime.books?.spx?.regime;             // { mode, verdict, ladder: { rung } … }

  // 3. $0.05 — the ranked buy-list, only when the ladder says names are enterable
  if (spx?.ladder?.rung === "NAMES") {
    const buylist = await (await paid("https://coil.trade/api/board/buylist")).json();
    // …your sizing and exit rules here. Coil publishes scores and states —
    // never position sizes, stop prices, or target prices. That half is yours.
  }
}
setInterval(tick, 15 * 60 * 1000);
tick();
```

At a 15-minute poll with typical regime-change frequency this runs **$1–3/month** — the
state-hash endpoint exists so you spend less, not more. Verify the scores are worth even
that before wiring it: `/api/board/signal-audit` marks every committed score to market
(forward returns vs a sector-matched control, published even when negative), and
`/api/board/asof?sample=1` serves one complete committed day free — diff it against your
own scanner, and if your replica matches, don't pay us.

## Reading the payload

Each scored name carries (field names as returned):

- `opp_pct` — opportunity, 0–100. The board's headline blend.
- `entry_q` — entry quality, 0–100. Buyable now vs extended. Timing, not advice.
- `hold_q` — hold strength, 0–100. Trend durability.
- `state` — `firing` / `ready` / `setup` / `wait` / `chase` / `falling`.
- `sector`, `is_leader`, and (in buy-list lanes) a `window` note like `READY`.

Each book carries a `regime` object: `mode`, a plain-language `verdict`, which
sectors are green, and a `ladder` (index → sector → name) saying whether
individual names are enterable at all. **Read top-down**: if the regime says
stand down, the ranked names below it are context, not a green light.

## Knowing when to come back

The board is a moving read, not a one-time file. Poll `regime` cheaply to decide
whether to buy the fuller slices. The `freshness.next_refresh_at` field tells you
the earliest a new payload is worth paying for; polling faster returns the same
bytes. Outside US market hours you get the morning snapshot.

## When to stop

Just as important as when to call, and cheaper. Stop when:

- **The change-hash has not moved.** `GET /api/board/state` is free. If `state_hash`
  is unchanged, every paid read returns the bytes you already hold. Poll the hash, not
  the board.
- **`freshness.next_refresh_at` is still in the future.** Calling earlier costs the same
  and returns the same payload.
- **The regime says stand down.** When a book is risk-off, drilling into individual
  names cannot produce an entry the ladder permits — you are paying to confirm a no.
  Re-check the regime, not the names.
- **US equities are closed.** The equity board holds the last session's close until the
  next open; only the crypto book (and its 24/7 day board) keeps moving.
- **You already have your answer.** This is a state map, not a ranking to re-query until
  it says something different. Re-reading an unchanged board does not make it change.

A loop that respects these costs a few dollars a month. One that ignores them can spend
that in an afternoon and learn nothing new — so the ceiling on a wallet is a real safeguard,
not a formality.

## What this is not

Not investment advice, not a managed account, not a signal service promising
returns, and not a guarantee of profit. Scores are derived from historical and
technical data and do not predict future results. See
<https://coil.trade/terms>.
