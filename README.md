# coil-board — an Agent Skill for reading a scored US stock market board

Gives an AI agent a **top-down market read** — is the tape risk-on or risk-off, which S&P 500 /
Nasdaq-100 / macro names are set up today — instead of having it screen hundreds of tickers and
buy whatever it saw most recently.

Works with **no API key, no wallet and no account**.

## Install

Point your skill-capable client at this repo, or drop the folder into your skills directory.
The skill is the standard shape: [`SKILL.md`](SKILL.md) at the root, with
[`reference.md`](reference.md) for field meanings and a helper script.

Try the free board right now, no install:

```bash
python3 scripts/coil_board.py --record
```

Prefer tools over a script? The same board is a remote **MCP server** (33 tools in Claude clients;
the free ones return a sample of the board, one market day delayed):

```bash
claude mcp add --transport http coil https://mcp.coil.trade/mcp
```

## What it reads

[Coil, a rules-based long-only stock scanner](https://coil.trade) scores 650+ US names (S&P 500, Nasdaq-100, macro ETFs) plus a long-only
BTC/ETH trend book each market morning: opportunity percentile, entry quality, hold strength, a
state, and a regime verdict per book with a permission ladder. Field meanings: [`reference.md`](reference.md).

Free tiers: the delayed board and MCP server (above), plus `POST /api/key` with an email for ~25
live calls/day on the cheap slices. Paid slices are read over
[x402](https://x402.org) (live price list: <https://coil.trade/.well-known/x402>), and the live
intraday board is a Coil Live subscription (see <https://coil.trade>).

## Check the publisher before trusting it

```bash
curl https://coil.trade/api/perf         # engine vs SPY and QQQ, funding-adjusted
curl https://coil.trade/api/board/proof  # sha256 committed at publish time, each day
```

The commitment log is append-only and each digest is written **before** the outcome is known, so a
day's published scores cannot be quietly improved afterwards.

## Canonical source

`SKILL.md` here is a byte-identical mirror of
<https://coil.trade/skills/coil-board/SKILL.md>, which is what
`/.well-known/agent-skills/index.json` publishes a sha256 for. **CI fails if this copy drifts** —
a skill that quietly diverges from its source is how one starts telling people things that are no
longer true.

## Disclaimer

Impersonal research publication — **not investment advice**, not a managed account, not a signal
service, not a guarantee of any outcome. Scores and states only: never stop prices, never target
prices. Markets can lose money. MIT licensed; not affiliated with Anthropic, Robinhood or Alpaca.
