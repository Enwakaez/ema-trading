import os, sys
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))
import pytest

from src.trading.risk_management import calculate_stop_loss, calculate_position_size


def test_calculate_stop_loss_default_multiplier():
    entry_price = 100
    atr = 10
    expected = entry_price - 1.25 * atr
    assert calculate_stop_loss(entry_price, atr) == expected


def test_calculate_stop_loss_custom_multiplier():
    entry_price = 50
    atr = 5
    multiplier = 2
    expected = entry_price - multiplier * atr
    assert calculate_stop_loss(entry_price, atr, multiplier) == expected


def test_calculate_position_size_standard():
    capital = 10000
    entry_price = 100
    stop_price = 95
    risk_pct = 0.01
    # risk_amount = capital * risk_pct = 100
    # qty = 100 / (100 - 95) = 20
    expected = 20
    assert calculate_position_size(capital, entry_price, stop_price, risk_pct) == expected


def test_calculate_position_size_minimum_one():
    capital = 1000
    entry_price = 50
    stop_price = 20
    risk_pct = 0.0001
    # risk_amount = 0.1, qty = 0.1 / (50 - 20) = ~0.0033 -> int -> 0 -> max(1, 0) -> 1
    assert calculate_position_size(capital, entry_price, stop_price, risk_pct) == 1
