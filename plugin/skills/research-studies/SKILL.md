---
name: research-studies
description: Use when the user asks whether a trading idea has been tested, whether a strategy or signal has published evidence, what a backtest found, or which studies exist on a topic such as breakouts, gap-ups, market breadth, chasing strong stocks or sector laggards.
---

# Research studies

Finds published studies through the Coil connector. The index is free and needs no sign-in.

## Steps

1. Call `list_research` with no arguments. It returns every published backtest study with its question, pre-registered verdict, evidence class and data window, plus where the full text is.
2. Match the user's topic against the study questions. Report the studies that fit: the question, the verdict, the evidence class and the data window.
3. If no study fits, say so plainly. Do not guess what a study would have found.
4. For the overnight crypto study specifically, `get_crypto_night` returns a free preview, trimmed to the top coin, that includes the study receipts.

## Full study texts

The index lists each study's question, verdict and evidence; the full text is a paid read on coil.trade. Tell the user where it is; do not try to reproduce, reconstruct or infer a study's contents from its title.

## How to present results

- Report verdicts as published, including refuted and failed ones. A refuted verdict is a result, not a gap to explain away.
- A backtest describes a historical period and does not predict future results.
- Present the output as research, not advice. Never place or suggest placing an order. This plugin has no trading capability.
