import pandas as pd 
import yfinance as yf 
from sqlalchemy import create_engine 

#Definimos el activo y la ventade de tiempo 
ticker = 'AAPL'
start_date = '2020-01-01' 

#Fecha reciente 
fecha_fin = "2026-09-23"

print(f"Descargando del mercado: {ticker}...")
 
df_mercado = yf.download(ticker, start=start_date, end=fecha_fin)


#Empezamos a limpiar para SQL 
df_mercado.columns = df_mercado.columns.droplevel(1) 

df_mercado.reset_index(inplace=True) 

print(df_mercado.head(5))  

print("Estructura de datos")
print(df_mercado.info()) 

nombre_servidor = "localhost\SQLEXPRESS"
nombre_bd = "PortfolioBD" 

cadena_conexion = f"mssql+pyodbc://{nombre_servidor}/{nombre_bd}?driver=ODBC+Driver+17+for+SQL+Server&Trusted_Connection=yes"
engine = create_engine(cadena_conexion) 

print("Guardando en SQL Server...")
df_mercado.to_sql(name="precios_historicos", con=engine, if_exists="replace", index=False)