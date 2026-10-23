---
name: market-check
description: Use when the user asks how the market is set up today, whether conditions favor buying, whether it is risk-on or risk-off, what the leaders are, or what to look at before the open. Also for a quick morning market read.
---

# Market check

Reads the overall market from the Coil connector, top-down, using the free tools. Most free tools are one market day delayed; the crypto tools have their own timing (see below). Say which applies when you report.

## Steps

1. Call `get_market_regime`. It returns a verdict per book (S&P 500, Nasdaq-100, macro, BTC/ETH crypto). Report the verdict as returned, with its note, for the book the user cares about. If the user did not name one, lead with the S&P 500 and Nasdaq-100.
2. Call `get_market_leaders` for the top leadership names per book.
3. Call `get_rotation` to see which sectors and macro instruments money is moving into or out of.
4. For a crypto question, call `get_crypto_trend` as well (long or cash state for Bitcoin and Ethereum). It is one completed UTC close behind and stamped with `signal_close_date`; report that date, not "one market day delayed". `get_crypto_night` is a free preview trimmed to the top coin.
5. If the user wants everything in one call, `get_morning_brief` combines the regime, top candidates, movers, crypto state and a leaders sample.

If the user asks what changed since a previous read, call `get_board_changes` with no arguments to get the current `state_hash`, which is current, not delayed. With `since` set to a stored hash it needs a Coil Live sign-in; without one it returns a sign-in error, so tell the user that and do not retry.

## Live data

Use the `_live` versions (for example `get_market_regime_live`, `get_market_leaders_live`, `get_rotation_live`) only when the user asks for live or intraday data. After any `_live` call, check `data_tier.tier` in the result. If it is `delayed`, the call returned the free delayed read, not live data: tell the user so, and say that live data needs a Coil Live sign-in. Some clients other than Claude get a PaymentRequired object and no data instead; treat that the same way and give the delayed read. Do not retry in a loop.

## How to present results

- State the data date. Stock-market reads on the free tier are one market day delayed; crypto reads carry their own close date or are a preview, as described above.
- Report what the tools returned in plain language. Do not invent numbers, levels or targets that the tools did not return.
- Present the output as research on market conditions, not as advice or a recommendation. The user decides what to do.
- Never place, suggest placing, or simulate an order. This plugin has no trading capability.
- Do not ask for the user's holdings, account, entry prices or sizes.
