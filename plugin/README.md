# Coil Live

This plugin adds four skills that teach Claude how to use the Coil market-read connector: checking the overall market, reading one stock, checking sector rotation, and finding published research studies. It does not add commands, hooks or scripts, and it never places trades.

Free to use. The plugin reads the free morning board; a Coil Live subscription is optional and only adds live intraday data.

## Not personal investment advice

Coil is an impersonal research publication. Every user gets the same reads, prepared with no knowledge of your account, holdings, goals or finances. Nothing here is personal investment advice, a recommendation, or an offer or solicitation to buy or sell any security. Coil Technologies LLC is not an investment adviser, a broker-dealer or a fiduciary. Free reads describe the board as of the date each reply states. Past or described conditions do not predict future results. You make your own decisions, and the plugin cannot place orders.

## Disclosure: paid promotion and positions

Paid promotion: none. Coil Technologies LLC is not paid by any company, issuer, fund or other third party to cover, rank or promote any security.

Positions: yes. Coil trades its own capital in one live brokerage account, run by the Coil Engine (beta). That account holds, adds to and sells securities these reads name, including leveraged and inverse ETFs. It may trade before or after you see a read, and it may trade against positions you hold. Coil's interests and yours are not the same. Full disclosures: <https://coil.trade/disclosures>

## What it connects to

The plugin declares one remote MCP server, `https://mcp.coil.trade/mcp`, operated by Coil Technologies LLC. This is the address of Coil's MCP connector, so installing the connector and the plugin together gives one set of tools. The plugin makes no other network requests.

## What data is sent

Only the arguments of the tool calls Claude makes for your question, for example a ticker such as NVDA, a sector name such as Energy, or a list of up to three tickers for a hold check. These arguments reach Coil's server and may appear in its request logs; see the privacy policy: <https://coil.trade/privacy>. The skills do not send account data, brokerage details, positions, entry prices, position sizes or conversation text. The free tools need no sign-in.

## Free tier and Coil Live

The free tools return a sample of each read. Stock-market reads are the latest session's morning read, dated in each reply; the crypto tools are one completed UTC close behind or a trimmed preview. The skills use the free tools by default. Tools whose names end in `_live` return intraday data to Coil Live subscribers, and the skills call them only when you ask for live or intraday data. In Claude, a `_live` call without a Coil Live sign-in returns the free morning read, and the skills tell you so; some other clients receive a payment-required response instead. Terms: <https://coil.trade/terms>

Coil's other products (Scanner, Mirror, the Brief) are described at <https://coil.trade/plans>; this plugin does not use them.

## Skills

- `market-check`: how the market is set up, regime, leaders, rotation.
- `stock-check`: a single stock read, plus a hold check for names you already own.
- `sector-check`: which sectors the money is moving into or out of, and a sector drill-down.
- `research-studies`: whether Coil has published a backtest on a topic, with the pre-registered verdict.

## License

MIT. See the LICENSE file.
