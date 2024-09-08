--Se obtiene el Id del Estado
UPDATE E
SET E.IdEstado = T.IdEstado
FROM [DL_Guaguas].[dbo].[EventosVehiculos] E INNER JOIN (SELECT E.Id, VE.IdEstado 
								FROM [DL_Guaguas].[dbo].[EventosVehiculos] E INNER JOIN [DW_Guaguas].[dbo].[Estados] VE ON E.Estado = VE.Estado) T ON E.Id = T.Id
WHERE E.IdEstado IS NULL

--Se obtiene el ID y estado anterior al actual
UPDATE E
SET E.IdAnterior = T.IdAnterior,
	E.FechaAnterior = T.FechaAnterior
FROM [DL_Guaguas].[dbo].[EventosVehiculos] E INNER JOIN (SELECT E1.Id, MAX(E2.Id) IdAnterior, MAX(E2.[Fecha]) FechaAnterior
								FROM [DL_Guaguas].[dbo].[EventosVehiculos] E1 INNER JOIN [DL_Guaguas].[dbo].[EventosVehiculos] E2 ON E1.Vehiculo = E2.Vehiculo AND E2.ID < E1.ID
									WHERE E1.IdAnterior IS NULL
										GROUP BY E1.ID) T ON E.Id = T.Id
													WHERE E.IdAnterior IS NULL

UPDATE E
SET E.EstadoAnterior = T.Estado
FROM [DL_Guaguas].[dbo].[EventosVehiculos] E INNER JOIN (SELECT Id, Estado
								FROM [DL_Guaguas].[dbo].[EventosVehiculos]) T ON E.IdAnterior = T.Id
									WHERE E.EstadoAnterior IS NULL	

--Se obtiene el nombre del taller al que pertenece el evento
UPDATE [DL_Guaguas].[dbo].[EventosVehiculos]
SET Taller = SUBSTRING(Descripcion,CHARINDEX('«', Descripcion) + 1, LEN(Descripcion) - CHARINDEX('«', Descripcion) - 1)
  WHERE Taller IS NULL
	AND Estado = 'En taller interno'
	AND Descripcion <> 'Apertura de incidencia'
	AND Descripcion <> 'Parte de avería'

UPDATE [DL_Guaguas].[dbo].[EventosVehiculos]
SET Taller = SUBSTRING(Descripcion,CHARINDEX('«', Descripcion) + 1, LEN(Descripcion) - CHARINDEX('«', Descripcion) - 1)
  WHERE Taller IS NULL
	AND Estado = 'En taller externo'
	AND Descripcion <> 'Parte de avería'
	AND Descripcion <> 'Apertura de incidencia'

UPDATE [DL_Guaguas].[dbo].[EventosVehiculos]
SET Taller = SUBSTRING(Descripcion,CHARINDEX('«', Descripcion) + 1, LEN(Descripcion) - CHARINDEX('«', Descripcion) - 1)
  WHERE Taller IS NULL
	AND Estado = 'Esperando taller externo'
	AND Descripcion <> 'Apertura de incidencia'
	AND Descripcion <> 'Parte de avería'

UPDATE [DL_Guaguas].[dbo].[EventosVehiculos]
SET Taller = SUBSTRING(Descripcion,CHARINDEX('(', Descripcion) + 1, LEN(Descripcion) - CHARINDEX('(', Descripcion) - 1)
  WHERE Taller IS NULL
	AND Descripcion like '%intervención%'
	AND Estado = 'Averiada'

UPDATE U
SET U.Taller = T1.Taller
FROM [DL_Guaguas].[dbo].[EventosVehiculos] U INNER JOIN (SELECT E.Taller, T.Id 
							FROM [DL_Guaguas].[dbo].[EventosVehiculos] E INNER JOIN (SELECT E1.Id, MAX(E2.id) IdMax
														FROM [DL_Guaguas].[dbo].[EventosVehiculos] E1 INNER JOIN [DL_Guaguas].[dbo].[EventosVehiculos] E2 ON E1.Vehiculo = E2.Vehiculo AND E2.Id < E1.Id 
															WHERE E1.Estado = 'En taller externo'
																AND E1.Descripcion IN ('Apertura de incidencia','Parte de avería')
																AND E2.Taller IS NOT NULL					
																	GROUP BY E1.Id) T ON T.IdMax = E.Id) T1 ON T1.Id = U.id
WHERE U.Taller IS NULL 
	AND U.Estado = 'En taller externo'
	AND U.Descripcion IN ('Apertura de incidencia','Parte de avería')

UPDATE U
SET U.Taller = T1.Taller
FROM [DL_Guaguas].[dbo].[EventosVehiculos] U INNER JOIN (SELECT E.Taller, T.Id 
							FROM [DL_Guaguas].[dbo].[EventosVehiculos] E INNER JOIN (SELECT E1.Id, MAX(E2.id) IdMax
														FROM [DL_Guaguas].[dbo].[EventosVehiculos] E1 INNER JOIN [DL_Guaguas].[dbo].[EventosVehiculos] E2 ON E1.Vehiculo = E2.Vehiculo AND E2.Id < E1.Id 
															WHERE E1.Estado = 'Consultando al taller'
																AND E1.EstadoAnterior = 'En taller externo'
																AND E1.Descripcion IN ('Apertura de incidencia','Parte de avería')
																AND E2.Taller IS NOT NULL					
																	GROUP BY E1.Id) T ON T.IdMax = E.Id) T1 ON T1.Id = U.id
WHERE U.Taller IS NULL 
	AND U.Estado = 'Consultando al taller'
	AND U.Descripcion IN ('Apertura de incidencia','Parte de avería')


--Se calcula el tiempo en minutos que la guagua está en estado disponible
UPDATE E
SET E.TiempoMinutos = T.minutos,
	E.IdSituacion = 1
FROM [DL_Guaguas].[dbo].[EventosVehiculos] E INNER JOIN (SELECT E1.ID AS IDActualizar,E1.[Fecha], DATEDIFF(MINUTE,E1.[Fecha],MIN(E2.[Fecha])) minutos
								FROM [DL_Guaguas].[dbo].[EventosVehiculos] E1 INNER JOIN [DL_Guaguas].[dbo].[EventosVehiculos] E2 ON E1.Vehiculo = E2.Vehiculo AND E2.ID > E1.ID
									WHERE E1.Estado = 'Disponible' 
											AND (E1.EstadoAnterior <> 'Disponible' OR E1.EstadoAnterior IS NULL)
											AND ((E2.Estado <> 'Disponible'
											AND E2.Estado <> 'Consultando al taller'
											AND E2.EstadoAnterior = 'Disponible')
											OR (E2.Estado IN ('Sin asignar','En taller interno','Averiada','Esperando taller externo') AND E2.EstadoAnterior = 'Consultando al taller'))
												GROUP BY E1.ID,E1.[Fecha]) T ON E.ID = T.IDActualizar
													WHERE E.TiempoMinutos IS NULL
														AND E.Estado = 'Disponible'


--Se calcula el tiempo desde que se inmoviliza hasta que entra a taller interno
UPDATE E
SET E.TiempoMinutos = T.minutos,
	E.IdSituacion = 2
FROM [DL_Guaguas].[dbo].[EventosVehiculos] E INNER JOIN (SELECT E1.ID, E1.[Fecha], MAX(E2.ID) IDActualizar, DATEDIFF(MINUTE,MAX(E2.[Fecha]),E1.[Fecha]) minutos
								FROM [DL_Guaguas].[dbo].[EventosVehiculos] E1 INNER JOIN [DL_Guaguas].[dbo].[EventosVehiculos] E2 ON E1.Vehiculo = E2.Vehiculo AND E2.ID < E1.ID
									WHERE E1.Estado = 'En taller interno' 
										AND E1.EstadoAnterior = 'Sin asignar'
										AND E2.Estado = 'Sin asignar'
										AND (E2.EstadoAnterior = 'Disponible' 
												OR E2.EstadoAnterior = 'Esperando taller externo'
												OR E2.EstadoAnterior = 'En taller externo'
												OR E2.EstadoAnterior = 'Averiada'
												OR E2.EstadoAnterior = 'Consultando al taller')
										GROUP BY E1.ID, E1.[Fecha]) T ON E.ID = T.IDActualizar
													WHERE E.TiempoMinutos IS NULL
														AND E.Estado = 'Sin asignar'

--Se calcula el tiempo desde que se inmoviliza hasta que se marca como esperando por taller externo
UPDATE E
SET E.TiempoMinutos = T.minutos,
	E.IdSituacion = 3
FROM [DL_Guaguas].[dbo].[EventosVehiculos] E INNER JOIN (SELECT E1.ID, E1.[Fecha], MAX(E2.ID) IDActualizar, DATEDIFF(MINUTE,MAX(E2.[Fecha]),E1.[Fecha]) minutos
								FROM [DL_Guaguas].[dbo].[EventosVehiculos] E1 INNER JOIN [DL_Guaguas].[dbo].[EventosVehiculos] E2 ON E1.Vehiculo = E2.Vehiculo AND E2.ID < E1.ID
									WHERE E1.Estado = 'Esperando taller externo' 
										AND E1.EstadoAnterior = 'Sin asignar'
										AND E2.Estado = 'Sin asignar'
										AND (E2.EstadoAnterior = 'Disponible' 
												OR E2.EstadoAnterior = 'Esperando taller externo'
												OR E2.EstadoAnterior = 'En taller externo'
												OR E2.EstadoAnterior = 'Averiada'
												OR E2.EstadoAnterior = 'Consultando al taller')
										GROUP BY E1.ID, E1.[Fecha]) T ON E.ID = T.IDActualizar
													WHERE E.TiempoMinutos IS NULL
														AND E.Estado = 'Sin asignar'

--Se calcula el tiempo en que la guagua está en taller interno
UPDATE E
SET E.TiempoMinutos = T.minutos,
	E.IdSituacion = 4
FROM [DL_Guaguas].[dbo].[EventosVehiculos] E INNER JOIN (SELECT E1.Id, E1.[Fecha], DATEDIFF(MINUTE,E1.[Fecha],MIN(E2.[Fecha])) minutos
								FROM [DL_Guaguas].[dbo].[EventosVehiculos] E1 INNER JOIN [DL_Guaguas].[dbo].[EventosVehiculos] E2 ON E1.Vehiculo = E2.Vehiculo AND E2.ID > E1.ID
									WHERE E1.Estado = 'En taller interno'
										AND E1.Descripcion <> 'Apertura de incidencia'
										AND E2.Descripcion <> 'Apertura de incidencia'
										GROUP BY E1.ID, E1.[Fecha]) T ON E.Id = T.Id
											WHERE E.TiempoMinutos IS NULL
												AND E.Estado = 'En taller interno'


--Se calcula el tiempo en que la guagua está en el taller externo
UPDATE E
SET E.TiempoMinutos = T.minutos,
	E.IdSituacion = 5
FROM [DL_Guaguas].[dbo].[EventosVehiculos] E INNER JOIN (SELECT E1.Id, E1.[Fecha], DATEDIFF(MINUTE,E1.[Fecha],MIN(E2.[Fecha])) minutos
								FROM [DL_Guaguas].[dbo].[EventosVehiculos] E1 INNER JOIN [DL_Guaguas].[dbo].[EventosVehiculos] E2 ON E1.Vehiculo = E2.Vehiculo AND E2.ID > E1.ID AND (E1.Taller <> E2.Taller OR E2.Taller IS NULL)
									INNER JOIN [DL_Guaguas].[dbo].[EventosVehiculos] E3 ON E1.IdAnterior = E3.Id AND E3.EstadoAnterior <> 'Consultando al taller'
									WHERE E1.Estado = 'En taller externo'
										AND E1.EstadoAnterior IN('Esperando taller externo','En taller interno','Disponible','Sin asignar','Averiada')										
										AND E2.Estado IN('En taller interno','Sin asignar','En taller externo','Disponible')
										AND E2.Descripcion <> 'Apertura de incidencia'
										AND E2.Descripcion <> 'Parte de avería'
										GROUP BY E1.ID, E1.[Fecha]) T ON E.Id = T.Id
											WHERE E.TiempoMinutos IS NULL
												AND E.Estado = 'En taller externo'


UPDATE E
SET E.TiempoMinutos = T.minutos,
	E.IdSituacion = 5
FROM [DL_Guaguas].[dbo].[EventosVehiculos] E INNER JOIN (SELECT E1.Id, E1.[Fecha], DATEDIFF(MINUTE,E1.[Fecha],MIN(E2.[Fecha])) minutos
								FROM [DL_Guaguas].[dbo].[EventosVehiculos] E1 INNER JOIN [DL_Guaguas].[dbo].[EventosVehiculos] E2 ON E1.Vehiculo = E2.Vehiculo AND E2.ID > E1.ID AND (E1.Taller <> E2.Taller OR E2.Taller IS NULL)
									INNER JOIN [DL_Guaguas].[dbo].[EventosVehiculos] E3 ON E1.IdAnterior = E3.Id AND E3.EstadoAnterior = 'Consultando al taller'
									INNER JOIN [DL_Guaguas].[dbo].[EventosVehiculos] E4 ON E3.IdAnterior = E4.Id AND (E3.Taller <> E4.Taller OR E4.Taller IS NULL)
									WHERE E1.Estado = 'En taller externo'
										AND E1.EstadoAnterior IN('Esperando taller externo')										
										AND E2.Estado IN('En taller interno','Sin asignar','En taller externo','Disponible')
										AND E2.Descripcion <> 'Apertura de incidencia'
										AND E2.Descripcion <> 'Parte de avería'
										GROUP BY E1.ID, E1.[Fecha]) T ON E.Id = T.Id
											WHERE E.TiempoMinutos IS NULL
												AND E.Estado = 'En taller externo'

--Se calcula el tiempo en que la guagua está en un taller externo y pasa a otro taller externo
UPDATE E
SET E.TiempoMinutos = T.minutos,
	E.IdSituacion = 5
FROM [DL_Guaguas].[dbo].[EventosVehiculos] E INNER JOIN (SELECT E1.Id, E1.[Fecha], DATEDIFF(MINUTE,E1.[Fecha],MIN(E3.[Fecha])) minutos
								FROM [DL_Guaguas].[dbo].[EventosVehiculos] E1 INNER JOIN [DL_Guaguas].[dbo].[EventosVehiculos] E2 ON E1.IdAnterior = E2.Id AND (E1.Taller <> E2.Taller OR E2.Taller IS NULL) --AND E2.Descripcion <> 'Apertura de incidencia' AND E2.Descripcion <> 'Parte de avería'
									INNER JOIN [DL_Guaguas].[dbo].[EventosVehiculos] E3 ON E1.Vehiculo = E3.Vehiculo AND E3.ID > E1.ID AND (E1.Taller <> E3.Taller OR E3.Taller IS NULL)
									WHERE E1.Estado = 'En taller externo'
										AND E1.EstadoAnterior = 'En taller externo'	
										AND E1.Descripcion <> 'Apertura de incidencia'
										AND E1.Descripcion <> 'Parte de avería'
										AND E3.Estado IN('En taller interno','Sin asignar','En taller externo')
										AND E3.Descripcion <> 'Apertura de incidencia'
										AND E3.Descripcion <> 'Parte de avería'
											GROUP BY E1.ID, E1.[Fecha]) T ON E.Id = T.Id
												WHERE E.TiempoMinutos IS NULL
													AND E.Estado = 'En taller externo'

--Se calcula el tiempo de espera desde que se comunica la avería al taller externo y entra en él
UPDATE E
SET E.TiempoMinutos = T.minutos,
	E.IdSituacion = 6
FROM [DL_Guaguas].[dbo].[EventosVehiculos] E INNER JOIN (SELECT E1.ID, E1.[Fecha], MAX(E2.ID) IDActualizar, DATEDIFF(MINUTE,MAX(E2.[Fecha]),E1.[Fecha]) minutos
								FROM [DL_Guaguas].[dbo].[EventosVehiculos] E1 INNER JOIN [DL_Guaguas].[dbo].[EventosVehiculos] E2 ON E1.Vehiculo = E2.Vehiculo AND E2.ID < E1.ID
									INNER JOIN [DL_Guaguas].[dbo].[EventosVehiculos] E3 ON E1.IdAnterior = E3.Id AND E3.EstadoAnterior <> 'Consultando al taller'
									WHERE E1.Estado = 'En taller externo' 
										AND E1.EstadoAnterior = 'Esperando taller externo'
										AND (E2.EstadoAnterior <> 'Esperando taller externo' OR E2.EstadoAnterior IS NULL)
										AND E2.Estado = 'Esperando taller externo'			
										GROUP BY E1.ID, E1.[Fecha]) T ON E.ID = T.IDActualizar
													WHERE E.TiempoMinutos IS NULL
														AND E.Estado = 'Esperando taller externo'


--Se calcula el tiempo desde que se avería en carretera hasta que llega a cocheras
UPDATE E
SET E.TiempoMinutos = T.minutos,
	E.IdSituacion = 7
FROM [DL_Guaguas].[dbo].[EventosVehiculos] E INNER JOIN (SELECT E1.Vehiculo, MAX(E2.ID) IDActualizar, DATEDIFF(MINUTE,MAX(E2.[Fecha]),E1.[Fecha]) minutos
								FROM [DL_Guaguas].[dbo].[EventosVehiculos] E1 INNER JOIN [DL_Guaguas].[dbo].[EventosVehiculos] E2 ON E1.Vehiculo = E2.Vehiculo AND E2.ID < E1.ID
									WHERE E1.Estado = 'Sin asignar' 
										AND E1.EstadoAnterior = 'Averiada'
										AND E1.Descripcion = 'Llegada a cocheras'
										AND E2.Estado = 'Averiada'
										AND E2.EstadoAnterior = 'Disponible'												
										GROUP BY E1.Vehiculo, E1.[Fecha]) T ON E.ID = T.IDActualizar
													WHERE E.TiempoMinutos IS NULL
														AND E.Estado = 'Averiada'

--Se calcula el tiempo desde que se avería en carretera hasta que se interviene en ruta
UPDATE E
SET E.TiempoMinutos = T.minutos,
	E.IdSituacion = 8
FROM [DL_Guaguas].[dbo].[EventosVehiculos] E INNER JOIN (SELECT E1.Vehiculo, MAX(E2.ID) IDActualizar, DATEDIFF(MINUTE,MAX(E2.[Fecha]),E1.[Fecha]) minutos
								FROM [DL_Guaguas].[dbo].[EventosVehiculos] E1 INNER JOIN [DL_Guaguas].[dbo].[EventosVehiculos] E2 ON E1.Vehiculo = E2.Vehiculo AND E2.ID < E1.ID
									WHERE E1.Estado = 'Averiada' 
										AND E1.EstadoAnterior = 'Averiada'
										AND E1.Descripcion like 'Intervención en ruta%'
										AND E2.Estado = 'Averiada'
										AND E2.EstadoAnterior = 'Disponible'												
										GROUP BY E1.Vehiculo, E1.[Fecha]) T ON E.ID = T.IDActualizar
													WHERE E.TiempoMinutos IS NULL
														AND E.Estado = 'Averiada'


--Se calcula el tiempo desde que se avería en carretera hasta que se asigna al taller externo
UPDATE E
SET E.TiempoMinutos = T.minutos,
	E.IdSituacion = 9
FROM [DL_Guaguas].[dbo].[EventosVehiculos] E INNER JOIN (SELECT E1.Vehiculo, MAX(E2.ID) IDActualizar, DATEDIFF(MINUTE,MAX(E2.[Fecha]),E1.[Fecha]) minutos
								FROM [DL_Guaguas].[dbo].[EventosVehiculos] E1 INNER JOIN [DL_Guaguas].[dbo].[EventosVehiculos] E2 ON E1.Vehiculo = E2.Vehiculo AND E2.ID < E1.ID
									WHERE E1.Estado = 'En taller externo' 
										AND E1.EstadoAnterior = 'Averiada'
										AND E1.Descripcion like 'Asignación al taller%'
										AND E2.Estado = 'Averiada'
										AND E2.EstadoAnterior = 'Disponible'												
										GROUP BY E1.Vehiculo, E1.[Fecha]) T ON E.ID = T.IDActualizar
													WHERE E.TiempoMinutos IS NULL
														AND E.Estado = 'Averiada'

--Se calcula el tiempo desde que se avería en carretera hasta que se asigna al taller interno (no hay datos de cuando llega a cocheras)
UPDATE E
SET E.TiempoMinutos = T.minutos,
	E.IdSituacion = 10
FROM [DL_Guaguas].[dbo].[EventosVehiculos] E INNER JOIN (SELECT E1.Vehiculo,MAX(E2.ID) IDActualizar, DATEDIFF(MINUTE,MAX(E2.[Fecha]),E1.[Fecha]) minutos
								FROM [DL_Guaguas].[dbo].[EventosVehiculos] E1 INNER JOIN [DL_Guaguas].[dbo].[EventosVehiculos] E2 ON E1.Vehiculo = E2.Vehiculo AND E2.ID < E1.ID
									WHERE E1.Estado = 'En taller interno' 
										AND E1.EstadoAnterior = 'Averiada'
										AND E1.Descripcion like 'Asignación al taller%'
										AND E2.Estado = 'Averiada'
										AND E2.EstadoAnterior = 'Disponible'												
										GROUP BY E1.Vehiculo,E1.[Fecha]) T ON E.ID = T.IDActualizar
													WHERE E.TiempoMinutos IS NULL
														AND E.Estado = 'Averiada'


--Se calcula el tiempo desde que se inicia la intervención en carretera y llega la guagua a cocheras
UPDATE E
SET E.TiempoMinutos = T.minutos,
	E.IdSituacion = 11
FROM [DL_Guaguas].[dbo].[EventosVehiculos] E INNER JOIN (SELECT E1.Vehiculo, MAX(E2.ID) IDActualizar, DATEDIFF(MINUTE,MAX(E2.[Fecha]),E1.[Fecha]) minutos
								FROM [DL_Guaguas].[dbo].[EventosVehiculos] E1 INNER JOIN [DL_Guaguas].[dbo].[EventosVehiculos] E2 ON E1.Vehiculo = E2.Vehiculo AND E2.ID < E1.ID
									INNER JOIN [DL_Guaguas].[dbo].[EventosVehiculos] E3 ON E2.IdAnterior = E3.Id AND E2.Estado <> E3.Estado AND (E2.Taller <> E3.Taller OR E3.Taller IS NULL)
									WHERE E1.Estado = 'Sin asignar' 
										AND E1.EstadoAnterior = 'Averiada'
										AND E1.Descripcion like 'Llegada desde el taller%'
										AND E2.Estado = 'Averiada'
										AND E2.EstadoAnterior = 'Averiada'	
										AND E2.Descripcion like 'Intervención en ruta%'
										GROUP BY E1.Vehiculo, E1.[Fecha]) T ON E.ID = T.IDActualizar
													WHERE E.TiempoMinutos IS NULL
														AND E.Estado = 'Averiada'


--Se calcula el tiempo desde que se inicia la intervención en carretera y pasa a disponible
UPDATE E
SET E.TiempoMinutos = T.minutos,
	E.IdSituacion = 12
FROM [DL_Guaguas].[dbo].[EventosVehiculos] E INNER JOIN (SELECT E1.Vehiculo, MAX(E2.ID) IDActualizar, DATEDIFF(MINUTE,MAX(E2.[Fecha]),E1.[Fecha]) minutos, E1.ID
								FROM [DL_Guaguas].[dbo].[EventosVehiculos] E1 INNER JOIN [DL_Guaguas].[dbo].[EventosVehiculos] E2 ON E1.Vehiculo = E2.Vehiculo AND E2.ID < E1.ID
									INNER JOIN [DL_Guaguas].[dbo].[EventosVehiculos] E3 ON E2.IdAnterior = E3.Id AND (E3.Taller <> E2.Taller OR E3.Taller IS NULL)
									WHERE E1.Estado = 'Disponible' 
										AND E1.EstadoAnterior = 'Averiada'
										AND E2.Estado = 'Averiada'
										AND ((E2.EstadoAnterior = 'Averiada' AND E2.Descripcion like 'Intervención en ruta%')
										OR (E2.EstadoAnterior = 'Disponible') OR (E2.EstadoAnterior = 'Consultando al taller'))	
										GROUP BY E1.Vehiculo, E1.[Fecha], E1.ID) T ON E.ID = T.IDActualizar
													WHERE E.TiempoMinutos IS NULL
														AND E.Estado = 'Averiada'


--Se calcula el tiempo desde que se inicia la intervención en carretera hasta que se pasa a otro taller
UPDATE E
SET E.TiempoMinutos = T.minutos,
	E.IdSituacion = 14
FROM [DL_Guaguas].[dbo].[EventosVehiculos] E INNER JOIN (SELECT E1.Vehiculo, E1.ID AS IDActualizar, DATEDIFF(MINUTE,E1.[Fecha],MIN(E2.[Fecha])) minutos
								FROM [DL_Guaguas].[dbo].[EventosVehiculos] E1 INNER JOIN [DL_Guaguas].[dbo].[EventosVehiculos] E2 ON E1.Vehiculo = E2.Vehiculo AND E2.Id > E1.Id
									INNER JOIN [DL_Guaguas].[dbo].[EventosVehiculos] E3 ON E1.Vehiculo = E3.Vehiculo AND E1.IdAnterior = E3.Id AND (E1.Taller <> E3.Taller OR E3.Taller IS NULL)  
									WHERE E1.Estado = 'Averiada' 
										AND E1.EstadoAnterior = 'Averiada'
										AND E1.Descripcion like 'Intervención en ruta%'
										AND ((E2.Estado <> 'Averiada' AND E2.EstadoAnterior = 'Averiada')
											OR(E2.Estado = 'Averiada' AND E2.EstadoAnterior = 'Averiada' AND E2.Descripcion like 'Intervención en ruta%' AND E1.Taller <> E2.Taller))
										GROUP BY E1.Vehiculo, E1.ID, E1.[Fecha]) T ON E.ID = T.IDActualizar
													WHERE E.TiempoMinutos IS NULL
														AND E.Estado = 'Averiada'



--Se calcula el tiempo desde que se inicia la intervención en carretera hasta que se pasa a otro taller
UPDATE E
SET E.TiempoMinutos = T.minutos,
	E.IdSituacion = 15
FROM [DL_Guaguas].[dbo].[EventosVehiculos] E INNER JOIN (SELECT E1.Vehiculo, E1.ID AS IDActualizar, DATEDIFF(MINUTE,E1.[Fecha],MIN(E2.[Fecha])) minutos
								FROM [DL_Guaguas].[dbo].[EventosVehiculos] E1 INNER JOIN [DL_Guaguas].[dbo].[EventosVehiculos] E2 ON E1.Vehiculo = E2.Vehiculo AND E2.ID > E1.ID
									WHERE E1.Estado = 'Averiada' 
										AND E1.EstadoAnterior = 'Sin asignar'
										AND E1.Descripcion like 'Intervención en ruta%'
										AND E2.Estado <> 'Averiada'
										GROUP BY E1.Vehiculo, E1.[Fecha], E1.ID) T ON E.ID = T.IDActualizar
													WHERE E.TiempoMinutos IS NULL
														AND E.Estado = 'Averiada'


--Se calcula el tiempo desde que se inicia la intervención en carretera hasta que se pasa a otro taller
UPDATE E
SET E.TiempoMinutos = T.minutos,
	E.IdSituacion = 16
FROM [DL_Guaguas].[dbo].[EventosVehiculos] E INNER JOIN (SELECT E1.Vehiculo, MAX(E2.ID) IDActualizar, DATEDIFF(MINUTE,MAX(E2.[Fecha]),E1.[Fecha]) minutos
								FROM [DL_Guaguas].[dbo].[EventosVehiculos] E1 INNER JOIN [DL_Guaguas].[dbo].[EventosVehiculos] E2 ON E1.Vehiculo = E2.Vehiculo AND E2.ID < E1.ID
									WHERE E1.Estado = 'En taller externo' 
										AND E1.EstadoAnterior = 'Averiada'
										AND E2.Estado = 'Averiada'
										AND E2.EstadoAnterior = 'Sin asignar'	
										AND E2.Descripcion like 'Intervención en ruta%'
										GROUP BY E1.Vehiculo, E1.[Fecha]) T ON E.ID = T.IDActualizar
													WHERE E.TiempoMinutos IS NULL
														AND E.Estado = 'Averiada'


--Se calcula el tiempo desde que se inicia la intervención en carretera hasta que se pasa a otro taller interno
UPDATE E
SET E.TiempoMinutos = T.minutos,
	E.IdSituacion = 17
FROM [DL_Guaguas].[dbo].[EventosVehiculos] E INNER JOIN (SELECT E1.Vehiculo, MAX(E2.ID) IDActualizar, DATEDIFF(MINUTE,MAX(E2.[Fecha]),E1.[Fecha]) minutos
								FROM [DL_Guaguas].[dbo].[EventosVehiculos] E1 INNER JOIN [DL_Guaguas].[dbo].[EventosVehiculos] E2 ON E1.Vehiculo = E2.Vehiculo AND E2.ID = E1.IdAnterior									
									WHERE E1.Estado = 'En taller interno' 
										AND E1.EstadoAnterior = 'Averiada'
										AND E2.Estado = 'Averiada'
										AND E2.EstadoAnterior = 'Averiada'	
										AND E2.Descripcion like 'Intervención en ruta%'
										GROUP BY E1.Vehiculo, E1.[Fecha]) T ON E.ID = T.IDActualizar
													WHERE E.TiempoMinutos IS NULL
														AND E.Estado = 'Averiada'


--Se calcula el tiempo desde que llega del taller externo y se pasa a disponible (sin pasar por taller interno)
UPDATE E
SET E.TiempoMinutos = T.minutos,
	E.IdSituacion = 18
FROM [DL_Guaguas].[dbo].[EventosVehiculos] E INNER JOIN (SELECT E1.Vehiculo, MAX(E2.ID) IDActualizar, DATEDIFF(MINUTE,MAX(E2.[Fecha]),E1.[Fecha]) minutos
								FROM [DL_Guaguas].[dbo].[EventosVehiculos] E1 INNER JOIN [DL_Guaguas].[dbo].[EventosVehiculos] E2 ON E1.Vehiculo = E2.Vehiculo AND E2.ID = E1.IdAnterior
									WHERE E1.Estado = 'Disponible' 
										AND E1.EstadoAnterior = 'Sin asignar'
										AND E2.Estado = 'Sin asignar'
										AND E2.EstadoAnterior = 'En taller externo'	
										AND E2.Descripcion like 'Llegada desde el taller%'
										GROUP BY E1.Vehiculo, E1.[Fecha]) T ON E.ID = T.IDActualizar
													WHERE E.TiempoMinutos IS NULL
														AND E.Estado = 'Sin asignar'
UPDATE E
SET E.TiempoMinutos = T.minutos,
	E.IdSituacion = 18
FROM [DL_Guaguas].[dbo].[EventosVehiculos] E INNER JOIN (SELECT E1.Vehiculo, MAX(E2.ID) IDActualizar, DATEDIFF(MINUTE,MAX(E2.[Fecha]),E1.[Fecha]) minutos
								FROM [DL_Guaguas].[dbo].[EventosVehiculos] E1 INNER JOIN [DL_Guaguas].[dbo].[EventosVehiculos] E2 ON E1.Vehiculo = E2.Vehiculo AND E2.ID = E1.IdAnterior
									WHERE E1.Estado = 'Disponible' 
										AND E1.EstadoAnterior = 'Sin asignar'
										AND E2.Estado = 'Sin asignar'
										AND E2.EstadoAnterior = 'Averiada'	
										AND E2.Descripcion like 'Llegada desde el taller%'
										GROUP BY E1.Vehiculo, E1.[Fecha]) T ON E.ID = T.IDActualizar
													WHERE E.TiempoMinutos IS NULL
														AND E.Estado = 'Sin asignar'

--Tiempo en el estado "Sin asignar" hasta que pasa a otro evento (casos no contemplados con anterioridad)
UPDATE E
SET E.TiempoMinutos = T.minutos,
	E.IdSituacion = 19
FROM [DL_Guaguas].[dbo].[EventosVehiculos] E INNER JOIN (SELECT E1.Id, E1.[Fecha], DATEDIFF(MINUTE,E1.[Fecha],MIN(E2.[Fecha])) minutos
								FROM [DL_Guaguas].[dbo].[EventosVehiculos] E1 INNER JOIN [DL_Guaguas].[dbo].[EventosVehiculos] E2 ON E1.Vehiculo = E2.Vehiculo AND E2.ID > E1.ID
									WHERE E1.Estado = 'Sin asignar'
										AND E1.EstadoAnterior <> 'Sin asignar'										
										AND E2.Estado <> 'Sin asignar'
										AND E1.TiempoMinutos IS NULL
										GROUP BY E1.ID, E1.[Fecha]) T ON E.Id = T.Id
											WHERE E.TiempoMinutos IS NULL
												AND E.Estado = 'Sin asignar'

--Tiempo esperando por taller externo
UPDATE E
SET E.TiempoMinutos = T.minutos,
	E.IdSituacion = 20
FROM [DL_Guaguas].[dbo].[EventosVehiculos] E INNER JOIN (SELECT E1.ID,E1.[Fecha], DATEDIFF(MINUTE,E1.[Fecha],MIN(E2.[Fecha])) minutos
								FROM [DL_Guaguas].[dbo].[EventosVehiculos] E1 INNER JOIN [DL_Guaguas].[dbo].[EventosVehiculos] E2 ON E1.Vehiculo = E2.Vehiculo AND E2.ID > E1.ID
									INNER JOIN [DL_Guaguas].[dbo].[EventosVehiculos] E3 ON E1.IdAnterior = E3.Id AND (E3.Taller <> E1.Taller OR E3.Taller IS NULL)
										WHERE E1.Estado = 'Esperando taller externo' 
												AND E1.EstadoAnterior IN ('En taller interno','Averiada','Consultando al taller','Sin asignar')											
												AND E2.Estado IN ('Disponible','Sin asignar','En taller interno','En taller externo')	
												AND E2.Descripcion NOT IN ('Apertura de incidencia','Parte de avería')
													GROUP BY E1.ID,E1.[Fecha]) T ON E.Id = T.Id
												WHERE E.TiempoMinutos IS NULL
													AND E.Estado = 'Esperando taller externo'

--Tiempo Averiada hasta que pasa a otro estado
UPDATE E
SET E.TiempoMinutos = T.minutos,
	E.IdSituacion = 21
FROM [DL_Guaguas].[dbo].[EventosVehiculos] E INNER JOIN (SELECT E1.ID,E1.[Fecha], DATEDIFF(MINUTE,E1.[Fecha],MIN(E2.[Fecha])) minutos
								FROM [DL_Guaguas].[dbo].[EventosVehiculos] E1 INNER JOIN [DL_Guaguas].[dbo].[EventosVehiculos] E2 ON E1.Vehiculo = E2.Vehiculo AND E2.ID > E1.ID
									WHERE E1.Estado = 'Averiada' 
											AND E1.EstadoAnterior IN ('Consultando al taller')											
											AND E2.Estado IN ('Disponible','Sin asignar','En taller interno','En taller externo')
												GROUP BY E1.ID,E1.[Fecha]) T ON E.Id = T.Id
											WHERE E.TiempoMinutos IS NULL
												AND E.Estado = 'Averiada'