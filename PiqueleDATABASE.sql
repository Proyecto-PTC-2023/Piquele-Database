
---CREATE DATABASE dbPiquele
GO
USE dbPiquele
GO

CREATE TABLE tbUsuarios
(
	idUsuario INT PRIMARY KEY IDENTITY(1,1),
	correoUsuario VARCHAR(100) UNIQUE,
	pass CHAR(88),
	verificacionEmail BIT DEFAULT 0
);
GO

CREATE TABLE tbClientes
(
	idCliente INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	foto IMAGE NULL,
	nombreCliente VARCHAR(150) NOT NULL,
	duiCliente VARCHAR(10) NOT NULL UNIQUE,
	fechaNacimiento DATE,
	celular VARCHAR(10) NOT NULL,
	idUsuario INT
);
GO

ALTER TABLE tbClientes
ADD CONSTRAINT FK_usuario_cliente
FOREIGN KEY (idUsuario)
REFERENCES tbUsuarios(idUsuario)
GO


CREATE TABLE tbPuntuacionRepartidores
(
	idPuntuacionRepartidor INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	puntuacion FLOAT NOT NULL,
	idCliente INT
);
GO

CREATE TABLE tbRepartidores
(
	idRepartidor INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	foto IMAGE NULL,
	nombreRepartidor VARCHAR(150) NOT NULL,
	duiRepartidor VARCHAR(10) NOT NULL UNIQUE,
	fechaNacimiento DATE,
	celular VARCHAR(10),
	idUsuario INT,
	estado BIT DEFAULT 0,
	idPuntuacionRepartidor INT
);
GO

ALTER TABLE tbRepartidores
ADD CONSTRAINT FK_usuario_repartidor
FOREIGN KEY (idUsuario)
REFERENCES tbUsuarios(idUsuario)
GO


ALTER TABLE tbRepartidores
ADD CONSTRAINT FK_repartidor_puntuacion
FOREIGN KEY (idPuntuacionRepartidor)
REFERENCES tbPuntuacionRepartidores(idPuntuacionRepartidor)
GO

CREATE TABLE tbAdmins
(
	idAdmin INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	foto IMAGE NULL,
	nombreAdministrador VARCHAR(150) NOT NULL,
	dui VARCHAR(10) UNIQUE, 
	fechaNacimiento DATE,
	celular VARCHAR(10),
	fechaCreacion DATE DEFAULT  GETDATE(),
	idUsuario INT
);
GO

ALTER TABLE tbAdmins
ADD CONSTRAINT FK_usuario_admin
FOREIGN KEY (idUsuario)
REFERENCES tbUsuarios(idUsuario)
GO

CREATE TABLE tbEntregas
(
    idEntrega INT PRIMARY KEY IDENTITY(1,1),
    activo BIT,
    posicionCoordenadas VARCHAR(25),
	idRepartidor INT
);
GO

ALTER TABLE tbEntregas
ADD CONSTRAINT FK_entregas_repartidor
FOREIGN KEY (idRepartidor)
REFERENCES tbRepartidores (idRepartidor)
GO

CREATE TABLE tbCategoria(
	idCategoria INT IDENTITY(1,1) PRIMARY KEY,
	nombreCategoria VARCHAR(100)
);


CREATE TABLE tbTiendas
(
	idTienda INT PRIMARY KEY IDENTITY(1,1),
	fotoTienda IMAGE,
	nombreTienda VARCHAR(50),
	idCategoria INT,
	cantidadSucursales INT DEFAULT 1,
	nombrePropietario VARCHAR (50),
	telefono VARCHAR(10),
	correo VARCHAR(100),
	horaApertura SMALLINT,
	horaCierre SMALLINT,
	direccionTienda VARCHAR(150),
	coordenadasTienda VARCHAR(50),
	promedioCalificacion FLOAT,
	numeroDeCalificaciones SMALLINT,
);
GO

CREATE TABLE tbProductos
(
	idProducto INT PRIMARY KEY IDENTITY(1,1),
	nombreProducto VARCHAR(100),
	fotoProducto IMAGE,
	detallesProducto VARCHAR(500),
	presenationProducto VARCHAR(15),
	calificacioProducto FLOAT,
	reviews SMALLINT,
	disponibilidad BIT,
	cantidadMaxima SMALLINT,
	idTienda INT
);
GO

ALTER TABLE tbProductos
ADD CONSTRAINT FK_productos_tienda
FOREIGN KEY (idTienda)
REFERENCES tbTiendas (idTienda)
GO

CREATE TABLE tbOpciones
(
	idOpcion INT PRIMARY KEY IDENTITY(1,1),
	nombreOpcion VARCHAR(35),
	precioOpcion MONEY,
	disponibilidadOpcion BIT,
	idProducto INT
);
GO

ALTER TABLE tbOpciones
ADD CONSTRAINT FK_opciones_productos
FOREIGN KEY (idProducto)
REFERENCES tbProductos (idProducto)
GO

CREATE TABLE tbTags
(
	idTag INT PRIMARY KEY IDENTITY(1,1),
	nombreTag VARCHAR(35),
	fotoTag IMAGE
);
GO

CREATE TABLE tbProductosTag
(
	idProductoTag INT PRIMARY KEY IDENTITY(1,1),
	idTag INT,
	idProducto INT
);
GO

ALTER TABLE tbProductosTag
ADD CONSTRAINT FK_tag_produvcTag
FOREIGN KEY (idTag)
REFERENCES tbTags (idTag)
GO

ALTER TABLE tbProductosTag
ADD CONSTRAINT FK_productos_produvcTag
FOREIGN KEY (idProducto)
REFERENCES tbProductos (idProducto)
GO

CREATE TABLE tbResenias
(
	idResenia INT PRIMARY KEY IDENTITY(1,1),
	idCliente INT,
	idTienda INT,
	cuerpoResenia VARCHAR(200)
);
GO

ALTER TABLE tbResenias
ADD CONSTRAINT FK_resenias_clientes
FOREIGN KEY (idCliente)
REFERENCES tbClientes (idCliente)
GO

ALTER TABLE tbResenias
ADD CONSTRAINT FK_resenias_productos
FOREIGN KEY (idTienda)
REFERENCES tbTienda (idTienda)
GO

CREATE TABLE tbOpcionEntrega
(
	idOpcionEntrega  INT PRIMARY KEY IDENTITY(1,1),
	nombreOpcionEntrega VARCHAR(100),
	descripcionOpcionEntrega VARCHAR(100),
	fotoOpcionEntrega IMAGE
);
GO

CREATE TABLE tbPerfilEntrega
(
	idPerfilEntrega INT IDENTITY(1,1) PRIMARY KEY,
	coordenadasPerfil VARCHAR(50),
	direccion VARCHAR(150),
	puerta VARCHAR(10),
	nombreNegocio VARCHAR(30),
	notaEntrega VARCHAR(150),
	estadoEntrega VARCHAR (20),
	idRepartidor INT,
	idOpcionEntrega INT
);
GO


ALTER TABLE tbPerfilEntrega
ADD CONSTRAINT FK_perfilEntrega_cliente
FOREIGN KEY (idRepartidor)
REFERENCES tbRepartidores (idRepartidor)
GO

ALTER TABLE tbPerfilEntrega
ADD CONSTRAINT FK_perfilEntrega_opcionEntrega
FOREIGN KEY (idOpcionEntrega)
REFERENCES tbOpcionEntrega (idOpcionEntrega)
GO

CREATE TABLE tbOrdenProductos
(
	idOrdenProducto INT  PRIMARY KEY IDENTITY(1,1),
	ordenEnviada BIT, 
	fechaCompra MONEY,
	precioCompra MONEY,
	idCliente INT,
	idPerfilEntrega INT
);

GO

ALTER TABLE tbOrdenProductos
ADD CONSTRAINT FK_ordenProducto_Cliente
FOREIGN KEY (idCliente)
REFERENCES tbClientes (idCliente)
GO

ALTER TABLE tbOrdenProductos
ADD CONSTRAINT FK_perfilEntrega
FOREIGN KEY (idPerfilEntrega)
REFERENCES tbPerfilEntrega (idPerfilEntrega)
GO

CREATE TABLE tbEnvios
(	
	idEnvio INT PRIMARY KEY IDENTITY(1,1),
	estadoEnvio SMALLINT,
    entregasId_s CHAR(64),
	idOrdenProducto INT
);
GO

ALTER TABLE tbEnvios
ADD CONSTRAINT FK_orden_envio
FOREIGN KEY (idOrdenProducto)
REFERENCES tbOrdenProductos (idOrdenProducto)
GO

CREATE TABLE tbCompraItems
(
	idCompraItem INT PRIMARY KEY IDENTITY(1,1),
	nombreCompraItem VARCHAR(100),
	detalleCompraItem VARCHAR(300),
	unidadMedida VARCHAR(15),
	nombreOpcionCompraItem VARCHAR(15),
	precioCompraItem MONEY,
	idOrdenProducto INT
);
GO
ALTER TABLE tbCompraItems
ADD CONSTRAINT FK_compraItem_ordenProducto
FOREIGN KEY (idOrdenProducto)
REFERENCES tbOrdenProductos (idOrdenProducto)
GO


CREATE TABLE tbSolicitudes
(
	idSolicitud INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	solicitud BIT DEFAULT 0,
	nombreTiendaSolicitud VARCHAR(100),
	cantidadSucursales INT DEFAULT 1,
	nombrePropietario VARCHAR (50),
	telefono VARCHAR(10),
	correo VARCHAR(100),
	fechaSolicitud DATE,
	imagenTienda IMAGE,
	idUsuario INT
);
GO

ALTER TABLE tbSolicitudes
ADD CONSTRAINT FK_usuarios_solicitudes 
FOREIGN KEY (idUsuario)
REFERENCES tbUsuarios(idUsuario)
GO

CREATE TABLE tbChatSoporte
(
	idChatSoporte INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	fecha DATETIME DEFAULT GETDATE(),
);
GO

CREATE TABLE tbUsuariosChat
(	
	idUsuariosChat INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	 idCliente INT,
	 idRepartidor INT,
	 idTienda INT,
	 idUsuario INT,
	 idChatSoporte INT
);
GO

ALTER TABLE tbUsuariosChat
ADD CONSTRAINT FK_chatUsuario_cliente 
FOREIGN KEY (idCliente)
REFERENCES tbClientes(idCliente)
GO

ALTER TABLE tbUsuariosChat
ADD CONSTRAINT FK_chatUsuario_repartidor
FOREIGN KEY (idRepartidor)
REFERENCES tbRepartidores(idRepartidor)
GO

ALTER TABLE tbUsuariosChat
ADD CONSTRAINT FK_chatUsuario_tienda 
FOREIGN KEY (idTienda)
REFERENCES tbTiendas(idTienda)
GO

ALTER TABLE tbUsuariosChat
ADD CONSTRAINT FK_chatUsuario_admin
FOREIGN KEY (idUsuario)
REFERENCES tbUsuarios(idUsuario)
GO

ALTER TABLE tbUsuariosChat
ADD CONSTRAINT FK_chatUsuario_chatSoporte
FOREIGN KEY (idChatSoporte)
REFERENCES tbChatSoporte(idChatSoporte)
GO

CREATE TABLE tbTipoMensajeS
(
	idTipoMensaje INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	nombre VARCHAR(50)
);
INSERT INTO tbTipoMensajeS (nombre) 
VALUES 
('Mensaje de texto'), 
('Audio'), 
('Foto'); 


CREATE TABLE tbMensajesChat
(
	idMensajeChat INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	idUsuariosChat INT,
	fechaMensaje DATETIME DEFAULT GETDATE(),
	mensaje VARCHAR(MAX),
	idTipoMensaje INT UNIQUE,
	ulrMensaje VARCHAR(2000)
);

ALTER TABLE tbMensajesChat
ADD CONSTRAINT FK_mensaje_usuario_chat
FOREIGN KEY (idUsuariosChat)
REFERENCES tbUsuariosChat(idUsuariosChat)
GO

ALTER TABLE tbMensajesChat
ADD CONSTRAINT FK_mensaje_tipo
FOREIGN KEY (idTipoMensaje)
REFERENCES tbTipoMensajeS(idTipoMensaje)
GO
