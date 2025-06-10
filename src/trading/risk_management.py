def calculate_stop_loss(entry_price, atr, multiplier=1.25):
    return entry_price - (multiplier * atr)

def calculate_position_size(capital, entry_price, stop_price, risk_pct=0.01):
    risk_amount = capital * risk_pct
    qty = risk_amount / (entry_price - stop_price)
    return max(1, int(qty))
