from dataclasses import dataclass
from datetime import datetime

from pandas import DataFrame


@dataclass
class InputData:
    date: datetime
    transactions: DataFrame
    terminals: DataFrame
    blacklist: DataFrame
