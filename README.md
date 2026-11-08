# Financial Market ELT Pipeline & Risk Analytics

An end-to-end automated ELT (Extract, Load, Transform) pipeline that ingests financial market data, processes it through a SQL Server semantic layer, and visualizes trend and risk metrics in a dynamic Power BI dashboard.

## Architecture & Tech Stack

-Extract (Python): Uses `yfinance` to pull historical daily market data (e.g., AAPL).
-Load (Python & SQLAlchemy): Cleans data structures using `pandas` and loads the raw dataset directly into a local SQL Server database (`PortfolioDB`).
-Transform (T-SQL): Utilizes a SQL `VIEW` with advanced Window Functions (`LAG`, `OVER`, `ROWS BETWEEN`) to calculate rolling averages and historical peaks on the fly.
-Visualize (Power BI & DAX): Connects via Direct Import to the SQL View. Uses DAX measures to compute dynamic risk KPIs based on user-selected timeframes.
-Orchestration: Scheduled via Windows Task Scheduler to run the Python extraction script daily after market close.

## Key Financial Metrics Calculated

- Simple Moving Averages (SMA 50 & 200): Calculated in SQL to smooth price action.
- Market Signals (Golden Cross / Death Cross): Automated trend detection.
- Daily Returns: Computed using SQL `LAG()` function.
- Annualized Volatility**: Calculated dynamically in Power BI using DAX (`STDEV.S` * `SQRT(252)`).
- Maximum Drawdown: Worst historical drop from peak, calculated dynamically via DAX (`MIN`).

## How to Run the Project

- Database Setup: Create a SQL Server database named `PortfolioDB`.
- Python Environment: 
   ```bash
   pip install yfinance pandas sqlalchemy pyodbc
