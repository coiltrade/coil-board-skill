---
name: stock-check
description: Use when the user asks whether a specific stock or ETF looks like a buy, whether to hold or sell something they own, whether a position's case is still intact, how a ticker ranks right now, or whether earnings are close.
---

# Stock check

Reads a single name from the Coil connector using the free tools. The free stock tools are one market day delayed; say so when you report.

## Steps

1. Take the ticker from the user's message. If it is ambiguous, ask which ticker they mean.
2. Call `get_stock_read` with `symbol` set to the ticker, one symbol per call. It covers S&P 500, Nasdaq-100 and macro names. It returns the name's percentile band on the board, entry-window state, hold label, leadership flag, price move, trading days to the next earnings report and the regime of its book. For an unknown symbol it returns a directory of valid symbols; use it to correct the ticker or tell the user the name is not covered.
3. If the user already owns the name, or asks whether to sell or hold it, also call `get_hold_state` with `symbol` set to the ticker. It returns at most three symbols per call (comma-separated, for example `NVDA,AMD,BTC-USD`). Compare the symbols you requested with the symbols returned, and tell the user about any that were dropped. It reports the hold label and which deterioration conditions are currently true (the `watch_flags`). It reports conditions only and never reads the user's entry, size or account, so do not ask for them.
4. For context on the surrounding market, call `get_market_regime`.
5. For Bitcoin or Ethereum, use `BTC-USD` or `ETH-USD` with `get_hold_state`, or call `get_crypto_trend`, which is one completed UTC close behind (report its `signal_close_date`) rather than one market day.

## Live data

Use the `_live` versions (`get_stock_read_live` or `get_hold_state_live`) only when the user asks for live or intraday data. After any `_live` call, check `data_tier.tier` in the result. If it is `delayed`, the call returned the free delayed read, not live data: tell the user so, and say that live data needs a Coil Live sign-in. Some clients other than Claude get a PaymentRequired object and no data instead; treat that the same way and give the delayed read. Do not retry in a loop.

## How to present results

- Lead with what the tools returned: the band, the entry-window state, the hold label and any watch flags that are true. Name the data date and the one-day delay.
- Describe conditions. Do not turn them into a buy or sell instruction, and do not invent prices, targets or stop levels.
- Present the output as research, not advice. The decision and the position size belong to the user.
- Never place or suggest placing an order. This plugin has no trading capability.
- Send only ticker symbols to the tools. Do not send or ask for account details.
