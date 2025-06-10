import os
import logging
import boto3
import json
from webull import webull
import pandas as pd

logger = logging.getLogger(__name__)

class WebullClient:
    def __init__(self, secret_arn):
        self.sm = boto3.client("secretsmanager")
        creds = self._get_creds(secret_arn)
        self.client = webull()
        self.client.login(creds["WEBULL_USERNAME"], creds["WEBULL_PASSWORD"])
        self.portfolio_value = self._get_account_value()

    def _get_creds(self, secret_arn):
        resp = self.sm.get_secret_value(SecretId=secret_arn)
        data = json.loads(resp["SecretString"])
        return data

    def get_historical_data(self, ticker):
        data = self.client.get_bars(stock=ticker, interval="5min", count=50)
        df = pd.DataFrame(data)
        df.columns = ["open", "high", "low", "close", "volume", "timestamp"]
        return df

    def place_order(self, ticker, action, qty):
        if action == "BUY":
            return self.client.place_order(stock=ticker, price=None, action="BUY", orderType="LMT", enforce="GTC", quant=qty)
        else:
            return self.client.place_order(stock=ticker, price=None, action="SELL", orderType="LMT", enforce="GTC", quant=qty)

    def get_position_qty(self, ticker):
        positions = self.client.get_positions()
        for p in positions:
            if p["ticker"] == ticker:
                return p["quantity"]
        return 0
