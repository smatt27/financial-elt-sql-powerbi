
--Estados del mercado  
--Medias móviles en una tabla virtual temporal
WITH CalculoMedias AS (
    SELECT 
        Date,
        [Close] AS Precio_Cierre,
        AVG([Close]) OVER(ORDER BY Date ASC ROWS BETWEEN 49 PRECEDING AND CURRENT ROW) AS SMA_50,
        AVG([Close]) OVER(ORDER BY Date ASC ROWS BETWEEN 199 PRECEDING AND CURRENT ROW) AS SMA_200
    FROM precios_historicos
)
-- Evaluamos la tendencia usando las columnas que acabamos de crear
SELECT 
    Date,
    ROUND(Precio_Cierre, 2) AS Precio,
    ROUND(SMA_50, 2) AS SMA_50,
    ROUND(SMA_200, 2) AS SMA_200,
    -- Aquí creamos nuestro semáforo financiero
    CASE 
        WHEN SMA_50 > SMA_200 THEN 'Tendencia Alcista'
        WHEN SMA_50 < SMA_200 THEN 'Tendencia Bajista'
        ELSE 'Sin Señal'
    END AS Senal_Mercado
FROM CalculoMedias
ORDER BY Date DESC; --Dias recientes 

--Salto diario
WITH PreciosAyer AS (
    SELECT 
        Date,
        [Close] AS Precio_Hoy,
        -- mira una 1 fila hacia atrás ordenando por fecha
        LAG([Close], 1) OVER(ORDER BY Date ASC) AS Precio_Ayer
    FROM precios_historicos
)
SELECT 
    Date,
    ROUND(Precio_Hoy, 2) AS Precio_Hoy,
    ROUND(Precio_Ayer, 2) AS Precio_Ayer,
    --  fórmula de Retorno Diario en % 
    ROUND(((Precio_Hoy - Precio_Ayer) / Precio_Ayer) * 100, 2) AS Retorno_Diario_Pct
FROM PreciosAyer
ORDER BY Date DESC;

--Riesgo total 
WITH PreciosAyer AS (
    SELECT 
        Date,
        [Close] AS Precio_Hoy,
        LAG([Close], 1) OVER(ORDER BY Date ASC) AS Precio_Ayer
    FROM precios_historicos
),
Retornos AS (
    SELECT 
        Date,
        (Precio_Hoy - Precio_Ayer) / Precio_Ayer AS Retorno_Diario
    FROM PreciosAyer
    WHERE Precio_Ayer IS NOT NULL
)
SELECT 
    -- Volatilidad Diaria
    ROUND(STDEV(Retorno_Diario) * 100, 2) AS Volatilidad_Diaria_Pct,
    
    --Volatilidad Anualizada 
    ROUND(STDEV(Retorno_Diario) * SQRT(252) * 100, 2) AS Volatilidad_Anualizada_Pct
FROM Retornos;

--Drawdown (Caída maxima)
WITH PicosHistoricos AS (
    SELECT 
        Date,
        [Close] AS Precio_Cierre,
        --Precio max hasta el día actual 
        MAX([Close]) OVER(
            ORDER BY Date ASC 
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS Precio_Maximo
    FROM precios_historicos
)
SELECT 
    Date,
    ROUND(Precio_Cierre, 2) AS Precio_Actual,
    ROUND(Precio_Maximo, 2) AS Precio_Pico,
    --Porcentaje de caída desde el pico
    ROUND(((Precio_Cierre - Precio_Maximo) / Precio_Maximo) * 100, 2) AS Drawdown_Pct
FROM PicosHistoricos
ORDER BY Drawdown_Pct ASC; --La peor arriba 
GO

--Vista 
CREATE OR ALTER VIEW v_portfolio_analytics AS
WITH MetricasBase AS (
    SELECT 
        Date,
        [Close] AS Precio_Cierre,
        
        -- Precio de ayer 
        LAG([Close], 1) OVER(ORDER BY Date ASC) AS Precio_Ayer,
        
        -- Medias Móviles
        AVG([Close]) OVER(ORDER BY Date ASC ROWS BETWEEN 49 PRECEDING AND CURRENT ROW) AS SMA_50,
        AVG([Close]) OVER(ORDER BY Date ASC ROWS BETWEEN 199 PRECEDING AND CURRENT ROW) AS SMA_200,
        
        -- Precio Máximo Histórico 
        MAX([Close]) OVER(ORDER BY Date ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS Precio_Maximo
    FROM precios_historicos
)
SELECT 
    Date,
    ROUND(Precio_Cierre, 2) AS Precio_Cierre,
    
    --Tendencia
    ROUND(SMA_50, 2) AS SMA_50,
    ROUND(SMA_200, 2) AS SMA_200,
    CASE 
        WHEN SMA_50 > SMA_200 THEN 'Alcista'
        WHEN SMA_50 < SMA_200 THEN 'Bajista'
        ELSE 'Sin Señal'
    END AS Estado_Tendencia,
    
    -- Riesgo
    ROUND(((Precio_Cierre - Precio_Ayer) / Precio_Ayer) * 100, 2) AS Retorno_Diario_Pct,
    ROUND(((Precio_Cierre - Precio_Maximo) / Precio_Maximo) * 100, 2) AS Drawdown_Pct
    
FROM MetricasBase;
GO 

SELECT TOP 10 * FROM v_portfolio_analytics ORDER BY Date DESC;
