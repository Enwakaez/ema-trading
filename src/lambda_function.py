import os
import logging
import datetime
import pytz
from trading.strategy import run_strategy
from utils.webull_client import WebullClient

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def is_market_open() -> bool:
    eastern = pytz.timezone("US/Eastern")
    now = datetime.datetime.now(eastern)
    if now.weekday() > 4:
        return False
    open_dt  = now.replace(hour=9,  minute=30, second=0, microsecond=0)
    close_dt = now.replace(hour=16, minute=30, second=0, microsecond=0)
    return open_dt <= now <= close_dt

def handler(event, context):
    if not is_market_open():
        logger.info("Market closed (outside 9:30–16:30 ET). Skipping run.")
        return

    try:
        secret_arn = os.getenv("SECRET_ARN")
        client     = WebullClient(secret_arn)
        run_strategy(client, ["NVDA", "PLTR"])
    except Exception as e:
        logger.error(f"Error in lambda handler: {e}", exc_info=True)
        raise
