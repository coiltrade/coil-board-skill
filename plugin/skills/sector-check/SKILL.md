---
name: sector-check
description: Use when the user asks which sectors are leading or lagging, where money is rotating, whether a sector such as energy or technology is strong, what the strongest stocks in a sector are, or how bonds, gold or commodities are behaving against stocks.
---

# Sector check

Reads sector and macro rotation from the Coil connector using the free tools. The free tools are one market day delayed; say so when you report.

## Steps

1. For a broad question ("which sectors are leading"), call `get_rotation`. It labels about 50 sector ETFs and macro instruments (bond, income, metals and commodity ETFs and a few single stocks) as GO (money already here), HOLDING (here but paused), TURNING (money arriving) or OUT (money left). It is a state map, not a buy list.
2. For one sector, call `get_sector_read` with `sector` set to a sector name (for example `Energy` or `Information Technology`) or its ETF symbol (for example `XLE` or `XLK`). It returns the top three member stocks, the member count, a count of members by state and the sector's ETF row. For an unknown value it returns the sector directory; use it to correct the input.
3. For market context, call `get_market_regime` and `get_market_leaders`, which include the sector money flows.

## Live data

Use the `_live` versions (`get_rotation_live` or `get_sector_read_live`) only when the user asks for live or intraday data. After any `_live` call, check `data_tier.tier` in the result. If it is `delayed`, the call returned the free delayed read, not live data: tell the user so, and say that live data needs a Coil Live sign-in. Some clients other than Claude get a PaymentRequired object and no data instead; treat that the same way and give the delayed read. Do not retry in a loop.

## How to present results

- Group sectors by state (GO, HOLDING, TURNING, OUT) and report what the tool returned. Name the data date and the one-day delay.
- Use the tool's own state definitions: GO is money already here, HOLDING is here but paused, TURNING is money arriving, OUT is money left.
- Present the output as research, not advice. Do not rank sectors as picks or invent figures the tools did not return.
- Never place or suggest placing an order. This plugin has no trading capability.
