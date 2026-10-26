# Reading the Coil board

## The per-name scores

**`opp_pct` (opportunity)** — 0–100 percentile rank of a name across the entire scored universe
on the publish date. Higher = a stronger current opportunity read. It is a **rank**, not a return
forecast. (The free tier abbreviates this to `opp`.)

**`entry_q` (entry quality)** — 0–100. Buyable now versus extended. Timing only, never advice.

**`hold_q` (hold strength)** — 0–100. Trend durability if a position already exists.

**`state`** — the entry lane, timing only:
- `firing` — an entry lane is active right now
- `ready` / `setup` — structure is forming
- `wait` / `cold` — on the board, not in an entry window today
- `chase` — extended; buying here is chasing
- `falling` — broken structure

State is never a buy or sell instruction.

## The regime, and why it comes first

Each book carries a regime verdict plus a **permission ladder** (index → sector → name) saying
whether individual names are enterable at all. Read it top-down: **if the ladder says `CASH`, the
ranked names below it are context, not a green light.** An agent that skips this step and buys the
top-ranked name every day is not running the strategy.

`regime_mode` values:
- `NAMES_ON` — index and sectors green; individual names are tradeable
- `SELECTIVE` — index mixed; only names inside green sectors qualify
- `SECTORS_ON` / `INDEX_ONLY` — express via ETFs, if at all
- `RISK_OFF` — index structure broken; stand down. Cash is a position.

## The books

`spx` (S&P 500) · `qqq` (Nasdaq-100) · `macro` (bonds / income / gold & metals / commodities) ·
`crypto` (BTC and ETH, long-only trend evaluated on UTC daily closes: 50-day gates per sleeve plus the BTC 200-day master gate).

The free tier shows the top few names per book, one market day delayed. The hosted board shows all
650+ names, live states, sector boards and both ranked buy-list lanes.

## Checking the publisher before trusting it

Both are free and need no key:

- `GET https://coil.trade/api/perf` — the engine's own return versus SPY and QQQ, funding-adjusted,
  published with its sample size. Omitted rather than estimated when unavailable.
- `GET https://coil.trade/api/board/proof` — an append-only sha256 commitment over every archived
  day, written at publish time **before the outcome was known**, with a verification recipe that
  reproduces byte-identically in Python and JavaScript.

## Honesty rider — carry it whenever you quote a number

Coil is an impersonal research publication: identical for every reader, scores and states only,
**never stop prices, never target prices, never individualized advice**. Free-tier names are one
market day delayed. Markets can lose money and an agent trading on someone's behalf can lose it
faster. Past scores do not predict future results. Terms: https://coil.trade/terms
