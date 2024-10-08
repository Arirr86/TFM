USE [DW_Guaguas]
GO
/****** Object:  Table [dbo].[Calendario]    Script Date: 08/09/2024 17:52:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Calendario](
	[fecha] [date] NOT NULL,
	[diaSemana] [tinyint] NULL,
	[diaTipo] [nvarchar](1) NULL,
	[idDiaTipo] [tinyint] NULL,
 CONSTRAINT [PK_Calendario] PRIMARY KEY CLUSTERED 
(
	[fecha] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Estados]    Script Date: 08/09/2024 17:52:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Estados](
	[idEstado] [tinyint] NOT NULL,
	[estado] [nvarchar](30) NOT NULL,
 CONSTRAINT [PK_Estados] PRIMARY KEY CLUSTERED 
(
	[idEstado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ExpedicionesPlanificadas]    Script Date: 08/09/2024 17:52:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ExpedicionesPlanificadas](
	[idExpedicion] [bigint] NOT NULL,
	[linea] [tinyint] NOT NULL,
	[servicio] [nvarchar](10) NOT NULL,
	[idTemporada] [smallint] NOT NULL,
	[kms] [float] NOT NULL,
	[horaSalidaTeorica] [time](7) NOT NULL,
	[horaLlegadaTeorica] [time](7) NOT NULL,
	[origen] [nvarchar](50) NOT NULL,
	[destino] [nvarchar](50) NOT NULL,
	[sentido] [nvarchar](10) NOT NULL,
	[tiempoRecorridoTeorico] [int] NOT NULL,
	[tiempoRegulacionTeorico] [int] NOT NULL,
 CONSTRAINT [PK_ExpedicionesPlanificadas] PRIMARY KEY CLUSTERED 
(
	[idExpedicion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ExpedicionesRealizadas]    Script Date: 08/09/2024 17:52:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ExpedicionesRealizadas](
	[idVehiculo] [smallint] NULL,
	[idConductor] [smallint] NULL,
	[idExpedicion] [bigint] NULL,
	[fecha] [date] NULL,
	[horaSalidaReal] [time](7) NULL,
	[horaLlegadaReal] [time](7) NULL,
	[tiempoRecorridoReal] [int] NULL,
	[tiempoRegulacionReal] [int] NULL,
	[tiempoSalidaRealTeorica] [int] NULL,
	[expedicionValida] [tinyint] NULL,
	[salidaPuntual] [tinyint] NULL,
	[avisoCompleto] [tinyint] NULL,
	[velocidadMedia] [float] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Temporadas]    Script Date: 08/09/2024 17:52:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Temporadas](
	[idTemporada] [smallint] NOT NULL,
	[fechaInicio] [date] NOT NULL,
	[fechaFin] [date] NOT NULL,
 CONSTRAINT [PK_Temporadas] PRIMARY KEY CLUSTERED 
(
	[idTemporada] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Vehiculos]    Script Date: 08/09/2024 17:52:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Vehiculos](
	[idVehiculo] [smallint] NOT NULL,
	[fMatriculacion] [date] NULL,
	[tipoVehiculoLongitud] [int] NULL,
	[estado] [tinyint] NULL,
 CONSTRAINT [PK_Vehiculos] PRIMARY KEY CLUSTERED 
(
	[idVehiculo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[VehiculosDisponibilidad]    Script Date: 08/09/2024 17:52:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[VehiculosDisponibilidad](
	[fecha] [date] NOT NULL,
	[fechaHora] [datetime] NOT NULL,
	[long7] [int] NOT NULL,
	[long10] [int] NOT NULL,
	[long12] [int] NOT NULL,
	[long18] [int] NOT NULL,
	[long21] [int] NOT NULL,
	[total] [int] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[VehiculosEstados]    Script Date: 08/09/2024 17:52:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[VehiculosEstados](
	[idVehiculo] [smallint] NOT NULL,
	[fecha] [date] NOT NULL,
	[fechaHoraInicio] [datetime] NOT NULL,
	[fechaHoraFin] [datetime] NULL,
	[idEstado] [tinyint] NOT NULL,
	[tiempoEstado] [int] NOT NULL,
	[taller] [nvarchar](100) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[VehiculosRepostajes]    Script Date: 08/09/2024 17:52:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[VehiculosRepostajes](
	[idVehiculo] [smallint] NOT NULL,
	[fecha] [date] NOT NULL,
	[hora] [time](7) NOT NULL,
	[odometro] [int] NOT NULL,
	[kmsRecorridos] [smallint] NOT NULL,
	[litrosRepostados] [smallint] NOT NULL,
	[consumo] [float] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[VehiculosTipos]    Script Date: 08/09/2024 17:52:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[VehiculosTipos](
	[idTipoVehiculoLongitud] [int] NOT NULL,
	[longitud] [nvarchar](50) NOT NULL,
	[color] [nvarchar](7) NOT NULL,
 CONSTRAINT [PK_VehiculosTipos] PRIMARY KEY CLUSTERED 
(
	[idTipoVehiculoLongitud] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ExpedicionesPlanificadas]  WITH CHECK ADD  CONSTRAINT [FK_ExpedicionesPlanificadas_Temporadas] FOREIGN KEY([idTemporada])
REFERENCES [dbo].[Temporadas] ([idTemporada])
GO
ALTER TABLE [dbo].[ExpedicionesPlanificadas] CHECK CONSTRAINT [FK_ExpedicionesPlanificadas_Temporadas]
GO
ALTER TABLE [dbo].[ExpedicionesRealizadas]  WITH CHECK ADD  CONSTRAINT [FK_ExpedicionesRealizadas_Calendario] FOREIGN KEY([fecha])
REFERENCES [dbo].[Calendario] ([fecha])
GO
ALTER TABLE [dbo].[ExpedicionesRealizadas] CHECK CONSTRAINT [FK_ExpedicionesRealizadas_Calendario]
GO
ALTER TABLE [dbo].[ExpedicionesRealizadas]  WITH CHECK ADD  CONSTRAINT [FK_ExpedicionesRealizadas_ExpedicionesPlanificadas] FOREIGN KEY([idExpedicion])
REFERENCES [dbo].[ExpedicionesPlanificadas] ([idExpedicion])
GO
ALTER TABLE [dbo].[ExpedicionesRealizadas] CHECK CONSTRAINT [FK_ExpedicionesRealizadas_ExpedicionesPlanificadas]
GO
ALTER TABLE [dbo].[ExpedicionesRealizadas]  WITH CHECK ADD  CONSTRAINT [FK_ExpedicionesRealizadas_Vehiculos] FOREIGN KEY([idVehiculo])
REFERENCES [dbo].[Vehiculos] ([idVehiculo])
GO
ALTER TABLE [dbo].[ExpedicionesRealizadas] CHECK CONSTRAINT [FK_ExpedicionesRealizadas_Vehiculos]
GO
ALTER TABLE [dbo].[Vehiculos]  WITH CHECK ADD  CONSTRAINT [FK_Vehiculos_VehiculosTipos] FOREIGN KEY([tipoVehiculoLongitud])
REFERENCES [dbo].[VehiculosTipos] ([idTipoVehiculoLongitud])
GO
ALTER TABLE [dbo].[Vehiculos] CHECK CONSTRAINT [FK_Vehiculos_VehiculosTipos]
GO
ALTER TABLE [dbo].[VehiculosDisponibilidad]  WITH CHECK ADD  CONSTRAINT [FK_VehiculosDisponibilidad_Calendario] FOREIGN KEY([fecha])
REFERENCES [dbo].[Calendario] ([fecha])
GO
ALTER TABLE [dbo].[VehiculosDisponibilidad] CHECK CONSTRAINT [FK_VehiculosDisponibilidad_Calendario]
GO
ALTER TABLE [dbo].[VehiculosEstados]  WITH CHECK ADD  CONSTRAINT [FK_VehiculosEstados_Calendario] FOREIGN KEY([fecha])
REFERENCES [dbo].[Calendario] ([fecha])
GO
ALTER TABLE [dbo].[VehiculosEstados] CHECK CONSTRAINT [FK_VehiculosEstados_Calendario]
GO
ALTER TABLE [dbo].[VehiculosEstados]  WITH CHECK ADD  CONSTRAINT [FK_VehiculosEstados_Estados] FOREIGN KEY([idEstado])
REFERENCES [dbo].[Estados] ([idEstado])
GO
ALTER TABLE [dbo].[VehiculosEstados] CHECK CONSTRAINT [FK_VehiculosEstados_Estados]
GO
ALTER TABLE [dbo].[VehiculosEstados]  WITH CHECK ADD  CONSTRAINT [FK_VehiculosEstados_Vehiculos] FOREIGN KEY([idVehiculo])
REFERENCES [dbo].[Vehiculos] ([idVehiculo])
GO
ALTER TABLE [dbo].[VehiculosEstados] CHECK CONSTRAINT [FK_VehiculosEstados_Vehiculos]
GO
ALTER TABLE [dbo].[VehiculosRepostajes]  WITH CHECK ADD  CONSTRAINT [FK_VehiculosRepostajes_Calendario] FOREIGN KEY([fecha])
REFERENCES [dbo].[Calendario] ([fecha])
GO
ALTER TABLE [dbo].[VehiculosRepostajes] CHECK CONSTRAINT [FK_VehiculosRepostajes_Calendario]
GO
ALTER TABLE [dbo].[VehiculosRepostajes]  WITH CHECK ADD  CONSTRAINT [FK_VehiculosRepostajes_Vehiculos] FOREIGN KEY([idVehiculo])
REFERENCES [dbo].[Vehiculos] ([idVehiculo])
GO
ALTER TABLE [dbo].[VehiculosRepostajes] CHECK CONSTRAINT [FK_VehiculosRepostajes_Vehiculos]
GO
