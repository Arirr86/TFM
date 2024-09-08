--DataLake Vehiculos a DataWarehouse Vehiculos
INSERT INTO [DW_Guaguas].[dbo].[Vehiculos]
	([idVehiculo]
    ,[fMatriculacion]
    ,[tipoVehiculoLongitud]
    ,[estado])
	SELECT [Unidad]
		,(CASE WHEN 
			(LEN([FMatriculacion]) > 10) 
             THEN DATEFROMPARTS(left([FMatriculacion],4),substring([FMatriculacion],6,2),substring([FMatriculacion],9,2))
		END)
		,[idVehiculoLongitud]
		,[idEstado] 
		FROM [DL_Guaguas].[dbo].[Vehiculos]			
			ORDER BY [Unidad]
			

------------------------------------------------------------------			
-- Se cargan las fechas en la tabla Calendario
------------------------------------------------------------------

DECLARE @FechaDesde as smalldatetime, @FechaHasta as smalldatetime

DECLARE @DiaSemana smallint
DECLARE @NDiaSemana char(10)

SET DATEFORMAT dmy
SET DATEFIRST 1

BEGIN TRANSACTION
 --Rango de fechas a generar: del 01/01/2022 al 30/04/2024 
 SELECT @FechaDesde = CAST('20220101' AS smalldatetime)
 SELECT @FechaHasta = CAST('20240430' AS smalldatetime)

 WHILE (@FechaDesde <= @FechaHasta) BEGIN
 
 SELECT @DiaSemana = DATEPART(DW, @FechaDesde)
 SELECT @NDiaSemana = DATENAME(dw, @FechaDesde)
 
 INSERT INTO dbo.Calendario
 (
  Fecha,
  diaSemana,
  diaTipo,
  idDiaTipo
 ) 
 VALUES(
	CONVERT(DATE,@FechaDesde),
	@DiaSemana,
	CASE WHEN @NDiaSemana = 'Sábado' THEN 'S'
		WHEN @NDiaSemana = 'Domingo' THEN 'F'
		ELSE 'L'
	END,
	CASE WHEN @NDiaSemana = 'Sábado' THEN 2
		WHEN @NDiaSemana = 'Domingo' THEN 3
		ELSE 1
	END  
 )

 --Incremento del bucle
 SELECT @FechaDesde = DATEADD(DAY, 1, @FechaDesde)
END

COMMIT TRANSACTION

--Se actualizan los festivos
UPDATE dbo.Calendario
SET diaTipo = 'F',
	idDiaTipo = 3
WHERE fecha IN('01/01/2022','06/01/2022','01/03/2022','14/04/2022','15/04/2022','30/05/2022',
				'24/06/2022','15/08/2022','08/09/2022','12/10/2022','01/11/2022','06/12/2022',
				'08/12/2022','26/12/2022','06/01/2023','21/02/2023','06/04/2023','07/04/2023',
				'01/05/2023','30/05/2023','24/06/2023','15/08/2023','08/09/2023','12/10/2023',
				'01/11/2023','06/12/2023','08/12/2023','25/12/2023','01/01/2024','06/01/2024',
				'28/03/2024','29/04/2024','01/05/2024','30/05/2024')
				
	
	
------------------------------------------------------------------------------------------			
--------------------------------------------Temporadas------------------------------------
------------------------------------------------------------------------------------------
INSERT INTO [DW_Guaguas].[dbo].[Temporadas]
	(	
		[idTemporada]
		,[fechaInicio]
		,[fechaFin]
	)
	SELECT [idTemporada]
		,[FechaInicio]
		,[FechaFin]
  FROM [DL_Guaguas].[dbo].[Temporadas]
  ORDER BY idTemporada


------------------------------------------------------------------------------------------
-------------------------------------Expediciones Planificadas----------------------------
------------------------------------------------------------------------------------------
INSERT INTO [DW_Guaguas].[dbo].[ExpedicionesPlanificadas]
	(
	   [idExpedicion]
      ,[linea]
      ,[servicio]
      ,[idTemporada]
      ,[kms]
      ,[horaSalidaTeorica]
      ,[horaLlegadaTeorica]
      ,[origen]
      ,[destino]
      ,[sentido]
      ,[tiempoRecorridoTeorico]
      ,[tiempoRegulacionTeorico]
	)

  SELECT 
	CONCAT(
	CASE WHEN LEN([Servicio]) = 4 THEN CAST([Servicio] AS NVARCHAR(4))
		ELSE CONCAT('0', CAST([Servicio] AS NVARCHAR(4))) 
	END,
	CASE WHEN LEN(DATEPART(HOUR,[Hora ini])) = 2 THEN CAST(DATEPART(HOUR,[Hora ini]) AS NVARCHAR(2))
		ELSE CONCAT('0', CAST(DATEPART(HOUR,[Hora ini]) AS NVARCHAR(2)))
	END,
	CASE WHEN LEN(DATEPART(MINUTE,[Hora ini])) = 2 THEN CAST(DATEPART(MINUTE,[Hora ini]) AS NVARCHAR(2))
		ELSE CONCAT('0', CAST(DATEPART(MINUTE,[Hora ini]) AS NVARCHAR(2)))
	END,
	CASE WHEN LEN([idTemporada]) = 2 THEN CAST([idTemporada] AS NVARCHAR(2))
		ELSE CONCAT('0', CAST([idTemporada] AS NVARCHAR(2)))
	END,
	CASE WHEN [TipoJornada] = 'L' THEN 1
		 WHEN [TipoJornada] = 'S' THEN 2
		 WHEN [TipoJornada] = 'F' THEN 3
	END),
	P.Linea,
	CASE WHEN LEN([Servicio]) = 4 THEN [Servicio]
		ELSE CONCAT('0', [Servicio]) 
	END,
	[idTemporada],
	T.Kms,
	CAST([Hora ini] AS TIME),
	CAST([Hora fin] AS TIME),
    RTRIM(SUBSTRING([Descripcion], 1, CHARINDEX('-', [Descripcion])-1)),
    LTRIM(SUBSTRING([Descripcion], CHARINDEX('-', [Descripcion]) + 1, LEN([Descripcion]))),
	CASE WHEN CAST([idTrayectoExcel] AS INT) % 2 = 0 
			THEN 'Vuelta' ELSE 'Ida'
	END,
	DATEDIFF(SECOND, [Hora ini], [hora fin]),
	[DuracionParadaFin] * 60
  FROM [DL_Guaguas].[dbo].[ExpedicionesPlanificadas] P 
	INNER JOIN [DL_Guaguas].[dbo].[LineasTrayectos] T 
		ON P.IdTrayecto = T.idTrayectoExcel AND P.Linea = T.Linea
	INNER JOIN [DL_Guaguas].[dbo].[Lineas] L 
		ON T.Linea = L.Linea
  
  ORDER BY IniTemporada DESC


  ------------------------------------------------------------------------------------------------
  ------------------------------------Expediciones Realizadas-------------------------------------
  ------------------------------------------------------------------------------------------------
INSERT INTO [DW_Guaguas].[dbo].[ExpedicionesRealizadas]
	(
		[idVehiculo]
		,[idConductor]
		,[idExpedicion]
		,[fecha]
		,[horaSalidaReal]
		,[horaLlegadaReal]
		,[tiempoRecorridoReal]
		,[tiempoRegulacionReal]
		,[tiempoSalidaRealTeorica]
	)
   
   SELECT [sCodAutobus]
	,[sCodConductor]
	,CONCAT(	
	CASE WHEN LEN([sCodigoServicioAutobus]) = 4 THEN CAST([sCodigoServicioAutobus] AS NVARCHAR(4))
		ELSE CONCAT('0', CAST([sCodigoServicioAutobus] AS NVARCHAR(4)))
	END,
	CASE WHEN LEN(DATEPART(HOUR,[Hora_Teorica_SalidaCabecera])) = 2 THEN CAST(DATEPART(HOUR,[Hora_Teorica_SalidaCabecera]) AS NVARCHAR(2))
		ELSE CONCAT('0', CAST(DATEPART(HOUR,[Hora_Teorica_SalidaCabecera]) AS NVARCHAR(2)))
	END,
	CASE WHEN LEN(DATEPART(MINUTE,[Hora_Teorica_SalidaCabecera])) = 2 THEN CAST(DATEPART(MINUTE,[Hora_Teorica_SalidaCabecera]) AS NVARCHAR(2))
		ELSE CONCAT('0', CAST(DATEPART(MINUTE,[Hora_Teorica_SalidaCabecera]) AS NVARCHAR(2)))
	END,
	CASE WHEN LEN(T.[idTemporada]) = 2 THEN CAST(T.[idTemporada] AS NVARCHAR(2))
		ELSE CONCAT('0', CAST(T.[idTemporada] AS NVARCHAR(2)))
	END,
	CASE WHEN [DiaTipo] = 'L' THEN 1
		 WHEN [DiaTipo] = 'S' THEN 2
		 WHEN [DiaTipo] = 'F' THEN 3
	END) AS idExpedicion
	,[dtJornada]
	,[Hora_Salida_Cabecera]
	,[dtHora_LlegadaReal]
	,DATEDIFF(SECOND,[Hora_Salida_Cabecera],[dtHora_LlegadaReal]) AS tiempoRecorridoReal
	,DATEDIFF(SECOND,[Hora_Llegada_Expedicion_Anterior],[Hora_Salida_Cabecera]) AS tiempoRegulacionReal
	,DATEDIFF(SECOND,[Hora_Teorica_SalidaCabecera],[Hora_Salida_Cabecera]) AS tiempoSalidaRealTeorica
  FROM [DL_Guaguas].[dbo].[ExpedicionesSAE] R INNER JOIN [DL_Guaguas].[dbo].[Temporadas] T ON (R.dtJornada >= T.FechaInicio AND R.dtJornada <= T.FechaFin)
  WHERE [sCodigoServicioAutobus] <> 9999 
	AND [sCodAutobus] <> 999
	AND [iIdTrayecto] < 800
	AND [iIdLinea] < 92
  ORDER BY dtJornada

  ------------------------------------------------------------------------------------------------
  ----------------------------------------Expediciones Válidas------------------------------------
  ------------------------------------------------------------------------------------------------
  --Expediciones dentro del rango establecido
  UPDATE R
  SET R.expedicionValida = 1
  FROM [DW_Guaguas].[dbo].[ExpedicionesRealizadas] R
	INNER JOIN [DW_Guaguas].[dbo].[ExpedicionesPlanificadas] P ON R.idExpedicion = P.idExpedicion 
		WHERE R.expedicionValida IS NULL
			AND R.tiempoRecorridoReal < 2 * P.tiempoRecorridoTeorico
			AND R.tiempoRecorridoReal > P.tiempoRecorridoTeorico / 3
			AND DATEDIFF(SECOND,P.horaSalidaTeorica,R.horaSalidaReal) BETWEEN -900 AND 900

  --Expediciones fuera del rango
  UPDATE [DW_Guaguas].[dbo].[ExpedicionesRealizadas] 
  SET expedicionValida = 0
  WHERE expedicionValida IS NULL

  ------------------------------------------------------------------------------------------------
  --------------------------------------Expediciones Puntuales------------------------------------
  ------------------------------------------------------------------------------------------------
  --Expediciones adelantadas
  UPDATE [DW_Guaguas].[dbo].[ExpedicionesRealizadas]
  SET salidaPuntual = 0
   WHERE salidaPuntual IS NULL
   AND tiempoSalidaRealTeorica < -60

   --Expediciones retrasadas
  UPDATE [DW_Guaguas].[dbo].[ExpedicionesRealizadas]
  SET salidaPuntual = 2
   WHERE salidaPuntual IS NULL
   AND tiempoSalidaRealTeorica > 300

   --Expediciones puntuales
  UPDATE [DW_Guaguas].[dbo].[ExpedicionesRealizadas]
  SET salidaPuntual = 1
   WHERE salidaPuntual IS NULL
   AND tiempoSalidaRealTeorica >= -60 
   AND tiempoSalidaRealTeorica <= 300



  ------------------------------------------------------------------------------------------------
  --------------------------------------Expediciones con Completo---------------------------------
  ------------------------------------------------------------------------------------------------
  UPDATE R
  SET avisoCompleto = 1
  FROM [DW_Guaguas].[dbo].[ExpedicionesRealizadas] R 
  INNER JOIN [DW_Guaguas].[dbo].[ExpedicionesPlanificadas] P ON R.idExpedicion = P.idExpedicion
  INNER JOIN [DL_Guaguas].[dbo].[Completos] C
	ON R.fecha = C.Dia 
	AND P.servicio = C.Servicio
	AND P.horaSalidaTeorica = C.Hora_Teorica_Exp
	WHERE R.avisoCompleto IS NULL

  UPDATE [DW_Guaguas].[dbo].[ExpedicionesRealizadas]
  SET avisoCompleto = 0
  WHERE avisoCompleto IS NULL


  ------------------------------------------------------------------------------------------------
  --------------------------------------------Velocidad Media-------------------------------------
  ------------------------------------------------------------------------------------------------
  UPDATE R
  SET R.velocidadMedia = ROUND(P.kms/(CAST(R.tiempoRecorridoReal AS FLOAT) / 3600), 2)
  FROM [DW_Guaguas].[dbo].[ExpedicionesRealizadas] R
  INNER JOIN [DW_Guaguas].[dbo].[ExpedicionesPlanificadas] P ON R.idExpedicion = P.idExpedicion
  AND R.velocidadMedia IS NULL

  ------------------------------------------------------------------------------------------------
  --------------------------------------------Vehiculos Estados-----------------------------------
  ------------------------------------------------------------------------------------------------
  INSERT INTO [DW_Guaguas].[dbo].[VehiculosEstados]
  (	
	[idVehiculo]
    ,[fecha]
    ,[fechaHoraInicio]
    ,[fechaHoraFin]
    ,[idEstado]
    ,[tiempoEstado]
    ,[taller])
  SELECT Vehiculo,
	CAST(Fecha AS DATE),
	Fecha,
	DATEADD(MINUTE,TiempoMinutos,Fecha),
	IdEstado,
	TiempoMinutos * 60,
	Taller  
  FROM [DL_Guaguas].[dbo].[EventosVehiculos]
	WHERE TiempoMinutos IS NOT NULL
		ORDER BY Fecha


  ------------------------------------------------------------------------------------------------
  --------------------------------------Vehiculos Repostajes--------------------------------------
  ------------------------------------------------------------------------------------------------
  INSERT INTO [DW_Guaguas].[dbo].[VehiculosRepostajes] 
(
	[idVehiculo]
    ,[fecha]
    ,[hora]
    ,[odometro]
    ,[kmsRecorridos]
    ,[litrosRepostados]
    ,[consumo]
)

SELECT [Vehículo],
	CAST([Fecha] AS DATE),
	CAST([Fecha] AS TIME),
	[Kms],
	[KmsAcumulados],
	[Litros],
	[Consumo]  
FROM [DL_Guaguas].[dbo].[Repostajes]


  ------------------------------------------------------------------------------------------------
  --------------------------------------Vehiculos Disponibles-------------------------------------
  ------------------------------------------------------------------------------------------------
 INSERT INTO [DW_Guaguas].[dbo].[VehiculosDisponibilidad] ([fecha]
      ,[fechaHora]
      ,[long7]
      ,[long10]
      ,[long12]
      ,[long18]
      ,[long21]
      ,[total])
SELECT CAST([Fecha] AS DATE)
	  ,[Fecha]
      ,[_7_5M]
      ,[_10M]
      ,[_12M]
      ,[_18M]
      ,[_21M]
      ,[Total]
  FROM [DL_Guaguas].[dbo].[VehiculosDisponibles]