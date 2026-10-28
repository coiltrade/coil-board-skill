# Coil Live

This plugin adds four skills that teach Claude how to use the Coil market-read connector: checking the overall market, reading one stock, checking sector rotation, and finding published research studies. It does not add commands, hooks or scripts, and it never places trades.

## What it connects to

The plugin declares one remote MCP server, `https://mcp.coil.trade/mcp`, operated by Coil Technologies LLC. This is the address of Coil's MCP connector, so installing the connector and the plugin together gives one set of tools. The plugin makes no other network requests.

## What data is sent

Only the arguments of the tool calls Claude makes for your question, for example a ticker such as NVDA, a sector name such as Energy, or a list of up to three tickers for a hold check. These arguments reach Coil's server and may appear in its request logs; see the privacy policy: <https://coil.trade/privacy>. The skills do not send account data, brokerage details, positions, entry prices, position sizes or conversation text. The free tools need no sign-in.

## Free tier and Coil Live

The free tools return a sample of each read. Stock-market reads are one market day delayed; the crypto tools are one completed UTC close behind or a trimmed preview. The skills use the free tools by default. Tools whose names end in `_live` return intraday data to Coil Live subscribers, and the skills call them only when you ask for live or intraday data. In Claude, a `_live` call without a Coil Live sign-in returns the free delayed read, and the skills tell you so; some other clients receive a payment-required response instead. Terms: <https://coil.trade/terms>

## Skills

- `market-check`: how the market is set up, regime, leaders, rotation.
- `stock-check`: a single stock read, plus a hold check for names you already own.
- `sector-check`: which sectors the money is moving into or out of, and a sector drill-down.
- `research-studies`: whether Coil has published a backtest on a topic, with the pre-registered verdict.

## Not investment advice

The output is market research, not personalized investment advice, and not an offer or solicitation to buy or sell any security. Reads describe conditions on a delayed board and do not account for your situation. Past or described conditions do not predict future results. You make your own decisions, and the plugin cannot place orders. Coil Technologies LLC is not affiliated with any broker or exchange.

## License

MIT. See the LICENSE file.
