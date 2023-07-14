USE dbPiquele;
GO

-- Nuevas solicitudes de negocios
CREATE TABLE tbGraficoNuevasSolicitudesNegocios
(
    idtbGraficoNuevasSolicitudesNegocios INT IDENTITY (1, 1) PRIMARY KEY,
    fecha                                VARCHAR(MAX) DEFAULT (CONVERT(VARCHAR(10), GETDATE(), 103)),
    conteo                               INT
);
GO

CREATE TRIGGER UpdateGraphData
    ON tbSolicitudesNegocios
    AFTER INSERT
    AS
BEGIN
    SET NOCOUNT ON;

    -- Check if the inserted record is for today
    IF EXISTS (SELECT 1 FROM inserted WHERE CAST(fechaSolicitud AS DATE) = CAST(GETDATE() AS DATE))
        BEGIN
            -- Update the today's value in the GraphData table
            UPDATE tbGraficoNuevasSolicitudesNegocios
            SET conteo = conteo + 1
            WHERE fecha = CAST(GETDATE() AS DATE);
        END
END;
GO

-- Daily sales in dollars
CREATE FUNCTION dbo.GetDailySales()
    RETURNS MONEY
AS
BEGIN
    DECLARE @dailySales MONEY;

    SELECT @dailySales = SUM(subtotal)
    FROM tbItemsCarrito ic
             JOIN tbCarritos c ON c.idCarrito = ic.idCarrito
    WHERE CONVERT(DATE, c.date) = CONVERT(DATE, GETDATE());

    RETURN @dailySales;
END
GO

-- Percentage of daily sales compared to the previous period
CREATE FUNCTION dbo.GetSalesPercentage(@daysPeriod INT)
    RETURNS DECIMAL(10, 2)
AS
BEGIN
    DECLARE @previousSales MONEY;
    DECLARE @currentSales MONEY;
    DECLARE @percentage DECIMAL(10, 2);

    SELECT @previousSales = SUM(subtotal)
    FROM tbItemsCarrito ic
             JOIN tbCarritos c ON c.idCarrito = ic.idCarrito
    WHERE CONVERT(DATE, c.date) >= DATEADD(DAY, -@daysPeriod, GETDATE())
      AND CONVERT(DATE, c.date) < CONVERT(DATE, GETDATE());

    SELECT @currentSales = SUM(subtotal)
    FROM tbItemsCarrito ic
             JOIN tbCarritos c ON c.idCarrito = ic.idCarrito
    WHERE CONVERT(DATE, c.date) = CONVERT(DATE, GETDATE());

    IF @previousSales IS NULL OR @previousSales = 0
        SET @percentage = 0.0;
    ELSE
        SET @percentage = ((@currentSales - @previousSales) / @previousSales) * 100.0;

    RETURN @percentage;
END
GO

-- Number of deliverers compared to the previous period
CREATE FUNCTION dbo.GetDeliverersComparison(@daysPeriod INT)
    RETURNS INT
AS
BEGIN
    DECLARE @previousDeliverers INT;
    DECLARE @currentDeliverers INT;
    DECLARE @comparison INT;

    SELECT @previousDeliverers = COUNT(*)
    FROM tbRepartidores
    WHERE CONVERT(DATE, autorizadoDesde) >= DATEADD(DAY, -@daysPeriod, GETDATE())
      AND CONVERT(DATE, autorizadoDesde) < CONVERT(DATE, GETDATE());

    SELECT @currentDeliverers = COUNT(*)
    FROM tbRepartidores
    WHERE CONVERT(DATE, autorizadoDesde) = CONVERT(DATE, GETDATE());

    SET @comparison = @currentDeliverers - @previousDeliverers;

    RETURN @comparison;
END
GO

-- Number of new businesses
CREATE FUNCTION dbo.GetNewBusinesses(@daysPeriod INT)
    RETURNS INT
AS
BEGIN
    DECLARE @newBusinesses INT;

    SELECT @newBusinesses = COUNT(*)
    FROM tbNegocios
    WHERE CONVERT(DATE, fechaCreacion) >= DATEADD(DAY, -@daysPeriod, GETDATE());

    RETURN @newBusinesses;
END
GO

-- Number of businesses compared to the previous period
CREATE FUNCTION dbo.GetBusinessesComparison(@daysPeriod INT)
    RETURNS INT
AS
BEGIN
    DECLARE @previousBusinesses INT;
    DECLARE @currentBusinesses INT;
    DECLARE @comparison INT;

    SELECT @previousBusinesses = COUNT(*)
    FROM tbNegocios
    WHERE CONVERT(DATE, fechaCreacion) >= DATEADD(DAY, -@daysPeriod, GETDATE())
      AND CONVERT(DATE, fechaCreacion) < CONVERT(DATE, GETDATE());

    SELECT @currentBusinesses = COUNT(*)
    FROM tbNegocios
    WHERE CONVERT(DATE, fechaCreacion) = CONVERT(DATE, GETDATE());

    SET @comparison = @currentBusinesses - @previousBusinesses;

    RETURN @comparison;
END
GO

CREATE FUNCTION dbo.GetAppVisits(@day DATE)
    RETURNS INT
AS
BEGIN
    DECLARE @appVisits INT;

    SELECT @appVisits = SUM(visitas)
    FROM tbPiqueleEstado
    WHERE @day = CONVERT(DATE, GETDATE());

    RETURN @appVisits;
END
GO

CREATE FUNCTION dbo.GetAppVisitsEver()
    RETURNS INT
AS
BEGIN
    DECLARE @appVisits INT;

    SELECT @appVisits = SUM(visitas)
    FROM tbPiqueleEstado;

    RETURN @appVisits;
END
GO

--Percentage increase or decrease in app visits compared to the previous period
CREATE FUNCTION dbo.GetAppVisitsPercentage(@daysPeriod INT)
    RETURNS DECIMAL(10, 2)
AS
BEGIN
    DECLARE @previousVisits INT;
    DECLARE @currentVisits INT;
    DECLARE @percentage DECIMAL(10, 2);

    SELECT @previousVisits = COUNT(*)
    FROM tbPiqueleEstado
    WHERE CONVERT(DATE, fecha) >= DATEADD(DAY, -@daysPeriod, GETDATE())
      AND CONVERT(DATE, fecha) < CONVERT(DATE, GETDATE());

    SELECT @currentVisits = COUNT(*)
    FROM tbPiqueleEstado
    WHERE CONVERT(DATE, fecha) = CONVERT(DATE, GETDATE());

    IF @previousVisits = 0
        SET @percentage = 100.0;
    ELSE
        SET @percentage = ((@currentVisits - @previousVisits) / CAST(@previousVisits AS DECIMAL(10, 2))) * 100.0;

    RETURN @percentage;
END
GO

CREATE FUNCTION dbo.GetDeliveriesInProgressToday()
    RETURNS INT
AS
BEGIN
    DECLARE @deliveriesInProgress INT;

    SELECT @deliveriesInProgress = COUNT(*)
    FROM tbEnvios
    WHERE CONVERT(DATE, fechaEnvio) = CONVERT(DATE, GETDATE())
      AND idEstadoEnvio NOT IN (SELECT idEstadoEnvio FROM tbEstadoEnvios WHERE estado = 'Entregado');

    RETURN @deliveriesInProgress;
END
GO

CREATE FUNCTION dbo.GetDeliveriesCompletedToday()
    RETURNS INT
AS
BEGIN
    DECLARE @deliveriesInProgress INT;

    SELECT @deliveriesInProgress = COUNT(*)
    FROM tbEnvios
    WHERE CONVERT(DATE, fechaEnvio) = CONVERT(DATE, GETDATE())
      AND idEstadoEnvio IN (SELECT idEstadoEnvio FROM tbEstadoEnvios WHERE estado = 'Entregado');

    RETURN @deliveriesInProgress;
END
GO


CREATE FUNCTION dbo.GetDeliveriesInProgressPercentage()
    RETURNS DECIMAL(10, 2)
AS
BEGIN
    DECLARE @totalDeliveriesToday INT;
    DECLARE @deliveriesInProgress INT;
    DECLARE @percentage DECIMAL(10, 2);

    SELECT @totalDeliveriesToday = COUNT(*)
    FROM tbEnvios
    WHERE CONVERT(DATE, fechaEnvio) = CONVERT(DATE, GETDATE());

    SELECT @deliveriesInProgress = COUNT(*)
    FROM tbEnvios
    WHERE CONVERT(DATE, fechaEnvio) = CONVERT(DATE, GETDATE())
      AND idEstadoEnvio NOT IN (SELECT idEstadoEnvio FROM tbEstadoEnvios WHERE estado = 'Entregado');

    IF @totalDeliveriesToday = 0
        SET @percentage = 0.0;
    ELSE
        SET @percentage = (@deliveriesInProgress / CAST(@totalDeliveriesToday AS DECIMAL(10, 2))) * 100.0;

    RETURN @percentage;
END
GO

--  Reunite all the functions of this file into a single view, take the argument daysPeriod and pass it to the functions that need it
CREATE VIEW dbo.vwDashboard
AS
SELECT dbo.GetDeliverersComparison(1)          AS deliverersComparisonYesterday,
       dbo.GetDeliverersComparison(7)          AS deliverersComparisonLastWeek,
       dbo.GetDeliverersComparison(30)         AS deliverersComparisonLastMonth,
       dbo.GetNewBusinesses(1)                 AS newBusinessesYesterday,
       dbo.GetNewBusinesses(7)                 AS newBusinessesLastWeek,
       dbo.GetNewBusinesses(30)                AS newBusinessesLastMonth,
       dbo.GetBusinessesComparison(1)          AS businessesComparisonYesterday,
       dbo.GetBusinessesComparison(7)          AS businessesComparisonLastWeek,
       dbo.GetBusinessesComparison(30)         AS businessesComparisonLastMonth,
       dbo.GetAppVisits(GETDATE())             AS appVisitsToday,
       dbo.GetAppVisitsEver()                  AS appVisitsEver,
       dbo.GetAppVisitsPercentage(1)           AS appVisitsPercentageYesterday,
       dbo.GetAppVisitsPercentage(7)           AS appVisitsPercentageLastWeek,
       dbo.GetAppVisitsPercentage(30)          AS appVisitsPercentageLastMonth,
       dbo.GetDeliveriesInProgressToday()      AS deliveriesInProgressToday,
       dbo.GetDeliveriesCompletedToday()       AS deliveriesCompletedToday,
       dbo.GetDeliveriesInProgressPercentage() AS deliveriesInProgressPercentage
GO

--  Create a stored procedure that returns the view
CREATE PROCEDURE dbo.GetDashboard
AS
BEGIN
    SELECT *
    FROM dbo.vwDashboard;
END
GO

SELECT *
FROM vwDashboard;
GO