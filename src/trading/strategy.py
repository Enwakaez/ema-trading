import logging
from trading.indicators import ema, rsi, atr
from trading.risk_management import calculate_position_size, calculate_stop_loss

logger = logging.getLogger(__name__)

def run_strategy(client, tickers):
    for ticker in tickers:
        df = client.get_historical_data(ticker)
        df["EMA9"] = ema(df["close"], 9)
        df["EMA21"] = ema(df["close"], 21)
        df["EMA50"] = ema(df["close"], 50)
        df["RSI"] = rsi(df["close"])
        df["ATR"] = atr(df)
        latest = df.iloc[-1]
        if latest["EMA9"] > latest["EMA21"] and latest["RSI"] < 70:
            entry_price = latest["close"]
            stop_price = calculate_stop_loss(entry_price, latest["ATR"])
            qty = calculate_position_size(client.portfolio_value, entry_price, stop_price)
            logger.info(f"Placing buy order for {ticker} - qty: {qty}")
            client.place_order(ticker, "BUY", qty)
        elif latest["EMA9"] < latest["EMA21"]:
            qty = client.get_position_qty(ticker)
            if qty > 0:
                logger.info(f"Placing sell order for {ticker} - qty: {qty}")
                client.place_order(ticker, "SELL", qty)
