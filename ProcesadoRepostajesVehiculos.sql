--Se obtiene la fecha del repostaje anterior
UPDATE R 
SET R.FechaRepostajeAnterior = T.FechaRepostajeAnterior
FROM [DL_Guaguas].[dbo].[Repostajes] R INNER JOIN (SELECT R2.[Vehículo], R2.Fecha, MAX(R1.Fecha) FechaRepostajeAnterior 
												FROM [DL_Guaguas].[dbo].[Repostajes] R1 INNER JOIN [DL_Guaguas].[dbo].[Repostajes] R2 ON R1.[Vehículo] = R2.[Vehículo] AND R1.Fecha < R2.Fecha
													GROUP BY R2.[Vehículo], R2.Fecha) T ON R.[Vehículo] = T.[Vehículo] AND R.Fecha = T.Fecha
WHERE R.FechaRepostajeAnterior IS NULL


--Se obtienen los Kms del repostaje anterior
UPDATE R
SET R.KmsRepostajeAnterior = T.Kms
FROM [DL_Guaguas].[dbo].[Repostajes] R INNER JOIN (SELECT [Vehículo], Fecha, Kms 
											FROM [DL_Guaguas].[dbo].[Repostajes]) T ON R.[Vehículo] = T.[Vehículo] AND R.FechaRepostajeAnterior = T.Fecha
WHERE R.KmsRepostajeAnterior IS NULL


--Se obtienen los Kms recorridos
--Diferencia de Kms dentro de lo normal
UPDATE R
SET R.KmsAcumulados = T.KmsRecorridos,
	R.SeEstimanKms = 0
FROM [DL_Guaguas].[dbo].[Repostajes] R INNER JOIN (SELECT [Vehículo], Fecha, (Kms - KmsRepostajeAnterior) KmsRecorridos 
											FROM [DL_Guaguas].[dbo].[Repostajes] 
												WHERE (Kms - KmsRepostajeAnterior) > 2 AND (Kms - KmsRepostajeAnterior) < 500) T ON R.[Vehículo] = T.[Vehículo] AND R.Fecha = T.Fecha 
WHERE R.KmsAcumulados IS NULL


--Diferencia de Kms fuera de rango
UPDATE R
SET R.KmsAcumulados = ROUND((R.Litros * 100) / T.MediaConsumo, 0),
	R.SeEstimanKms = 1
FROM [DL_Guaguas].[dbo].[Repostajes] R INNER JOIN (SELECT [Vehículo], AVG(Consumo) MediaConsumo
											FROM [DL_Guaguas].[dbo].[Repostajes] 
												WHERE SeEstimanKms = 0
													GROUP BY [Vehículo]) T ON R.[Vehículo] = T.[Vehículo]
WHERE R.KmsAcumulados IS NULL
	AND (((R.Kms - R.KmsRepostajeAnterior) <= 2) OR ((R.Kms - R.KmsRepostajeAnterior) >= 500))

-- Se calculan los kms a partir del consumo medio
UPDATE R 
  SET R.[KmsAcumulados] = (R.Litros * 100) / C.Consumo,
	  R.SeEstimanKms = 1	
  FROM [DL_Guaguas].[dbo].[Repostajes] R 
  INNER JOIN (SELECT Vehículo, AVG(ROUND((Litros / KmsAcumulados) * 100,2)) AS Consumo 
				FROM [DL_Guaguas].[dbo].[Repostajes] 
					WHERE SeEstimanKms = 0 GROUP BY Vehículo) C ON R.Vehículo = C.Vehículo
  WHERE R.[KmsAcumulados] IS NULL

--Se calcula el consumo
UPDATE [DL_Guaguas].[dbo].[Repostajes]
SET Consumo = ROUND((Litros / KmsAcumulados) * 100,2)
WHERE Litros > 0 AND KmsAcumulados > 0
	AND Consumo IS NULL
