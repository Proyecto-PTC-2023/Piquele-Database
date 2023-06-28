-- USE master;
-- DROP DATABASE dbPiquele;
-- CREATE DATABASE dbPiquele
-- GO
-- USE dbPiquele
-- GO

CREATE TABLE tbUsuarios
(
    idUsuario          INT PRIMARY KEY IDENTITY (1,1),
    correoUsuario      VARCHAR(100) UNIQUE,
    pass               CHAR(88),
    verificacionEmail  BIT DEFAULT 0,
    codigoVerificacion VARCHAR(255),
);
GO

CREATE TABLE tbClientes
(
    idCliente       INT IDENTITY (1,1) PRIMARY KEY NOT NULL,
    foto            VARBINARY(max)                 NULL,
    nombreCliente   VARCHAR(150)                   NOT NULL,
    duiCliente      VARCHAR(10)                    NOT NULL UNIQUE,
    fechaNacimiento DATE,
    celular         VARCHAR(10)                    NOT NULL,
    idUsuario       INT
);
GO

ALTER TABLE tbClientes
    ADD CONSTRAINT FK_usuario_cliente
        FOREIGN KEY (idUsuario)
            REFERENCES tbUsuarios (idUsuario)
GO

CREATE TABLE tbDireccionesCliente
(
    idDireccion           INT PRIMARY KEY IDENTITY (1,1),
    idCliente             INT,
    titulo                VARCHAR(50),
    direccion             VARCHAR(150),
    latitud               VARCHAR(50),
    longitud              VARCHAR(50),
    numeroInmueble        VARCHAR(10),
    indicacionesDeEntrega VARCHAR(200),
    telefono              VARCHAR(10)
);

ALTER TABLE tbDireccionesCliente
    ADD CONSTRAINT FK_cliente_direccion
        FOREIGN KEY (idCliente)
            REFERENCES tbClientes (idCliente)

CREATE TABLE tbTipoTransporte
(
    idTipoTransporte INT PRIMARY KEY IDENTITY (1,1),
    nombreTransporte VARCHAR(50)
);

INSERT INTO tbTipoTransporte (nombreTransporte)
VALUES ('Bicicleta'),
       ('Motocicleta'),
       ('Automóvil');


CREATE TABLE tbRepartidores
(
    idRepartidor             INT IDENTITY (1,1) PRIMARY KEY NOT NULL,
    idUsuario                INT,
    idCliente                INT,
    estado                   BIT  DEFAULT 0,
    idTipoTransporte         INT,
    numeroLicencia           VARCHAR(15),
    fechaVencimientoLicencia DATE,
    autorizado               BIT  DEFAULT 0,
    autorizadoDesde          DATE DEFAULT GETDATE(),
);
GO

ALTER TABLE tbRepartidores
    ADD CONSTRAINT FK_tipo_transporte_repartidor
        FOREIGN KEY (idTipoTransporte) REFERENCES tbTipoTransporte (idTipoTransporte);
GO

ALTER TABLE tbRepartidores
    ADD CONSTRAINT FK_usuario_repartidor
        FOREIGN KEY (idUsuario)
            REFERENCES tbUsuarios (idUsuario)
GO

ALTER TABLE tbRepartidores
    ADD CONSTRAINT FK_cliente_repartidor
        FOREIGN KEY (idCliente)
            REFERENCES tbClientes (idCliente)
GO

CREATE TABLE tbSolicitudRepartidor
(
    idSolicitudRepartidor INT PRIMARY KEY IDENTITY (1,1),
    idRepartidor          INT,
    fechaSolicitud        DATE,
    fechaRespuesta        DATE,
    respuesta             BIT DEFAULT 0,
    observaciones         VARCHAR(200)
);

ALTER TABLE tbSolicitudRepartidor
    ADD CONSTRAINT FK_repartidor_solicitud
        FOREIGN KEY (idRepartidor)
            REFERENCES tbRepartidores (idRepartidor)
GO

-- When insert to tbRepartidores trigger a tbSolicitudRepartidor creation
CREATE TRIGGER tr_solicitud_repartidor
    ON tbRepartidores
    AFTER INSERT
    AS
    DECLARE @idRepartidor INT;

    SELECT @idRepartidor = idRepartidor
    FROM inserted;

    INSERT INTO tbSolicitudRepartidor (idRepartidor, fechaSolicitud)
    VALUES (@idRepartidor, GETDATE());
GO

CREATE TABLE tbAdmins
(
    idAdmin             INT IDENTITY (1,1) PRIMARY KEY NOT NULL,
    nombreAdministrador VARCHAR(150)                   NOT NULL,
    fechaCreacion       DATE DEFAULT GETDATE(),
    idUsuario           INT
);
GO

ALTER TABLE tbAdmins
    ADD CONSTRAINT FK_usuario_admin
        FOREIGN KEY (idUsuario)
            REFERENCES tbUsuarios (idUsuario)
GO

CREATE TABLE tbNegocios
(
    idNegocio          INT PRIMARY KEY IDENTITY (1,1),
    fotoNegocio        VARBINARY(max),
    nombreNegocio      VARCHAR(50),
    cantidadSucursales INT DEFAULT 1,
    idUsuario          INT,
    idCliente          INT,
    telefono           VARCHAR(10),
    correo             VARCHAR(100),
    horaApertura       SMALLINT,
    horaCierre         SMALLINT,
    direccionNegocio   VARCHAR(150),
    coordenadasNegocio VARCHAR(50),
);
GO

ALTER TABLE tbNegocios
    ADD CONSTRAINT FK_usuario_Negocios
        FOREIGN KEY (idUsuario)
            REFERENCES tbUsuarios (idUsuario);
GO

ALTER TABLE tbNegocios
    ADD CONSTRAINT FK_cliente_Negocios
        FOREIGN KEY (idCliente)
            REFERENCES tbClientes (idCliente);
GO

CREATE TABLE tbComentarios
(
    idComentario     INT PRIMARY KEY IDENTITY (1,1),
    idCliente        INT,
    idNegocio        INT,
    comentario       VARCHAR(200),
    fecha            DATE,
    calificacionDada FLOAT
);
GO

ALTER TABLE tbComentarios
    ADD CONSTRAINT FK_Negocio_comentario
        FOREIGN KEY (idNegocio)
            REFERENCES tbNegocios (idNegocio);


ALTER TABLE tbComentarios
    ADD CONSTRAINT FK_cliente_comentario
        FOREIGN KEY (idCliente)
            REFERENCES tbClientes (idCliente)
GO

CREATE FUNCTION dbo.GetAverageRating(@idNegocio INT)
    RETURNS DECIMAL(10, 2)
AS
BEGIN
    DECLARE @averageRating DECIMAL(10, 2);

    SELECT @averageRating = AVG(calificacionDada)
    FROM tbComentarios
    WHERE idNegocio = @idNegocio;

    RETURN @averageRating;
END
GO

ALTER TABLE tbNegocios
    ADD promedioCalificacion AS dbo.GetAverageRating(idNegocio);
GO

CREATE FUNCTION dbo.GetRatingCount(@idNegocio INT)
    RETURNS INT
AS
BEGIN
    DECLARE @ratingCount INT;

    SELECT @ratingCount = COUNT(calificacionDada)
    FROM tbComentarios
    WHERE idNegocio = @idNegocio;

    RETURN @ratingCount;
END
GO

ALTER TABLE tbNegocios
    ADD numeroCalificaciones AS dbo.GetRatingCount(idNegocio);
GO


CREATE TABLE tbProductos
(
    idProducto           INT PRIMARY KEY IDENTITY (1,1),
    nombreProducto       VARCHAR(100),
    fotoProducto         VARBINARY(MAX),
    presentacionProducto VARCHAR(15),
    vecesComprado        INT,
    descripcionProducto  VARCHAR(500),
    disponibilidad       BIT,
    pedidoMaximo         SMALLINT,
    idNegocio            INT
);
GO

ALTER TABLE tbProductos
    ADD CONSTRAINT FK_productos_Negocio
        FOREIGN KEY (idNegocio)
            REFERENCES tbNegocios (idNegocio)
GO

-- Información específica
CREATE TABLE tbTamanos
(
    idTamano   INT PRIMARY KEY IDENTITY (1,1),
    nombre     VARCHAR(15),
    precio     DECIMAL(10, 2),
    idProducto INT
);
GO

ALTER TABLE tbTamanos
    ADD CONSTRAINT FK_tamanos_productos
        FOREIGN KEY (idProducto)
            REFERENCES tbProductos (idProducto);
GO

CREATE TABLE tbTiposProductos
(
    idTipoProducto INT PRIMARY KEY IDENTITY (1,1),
    nombreTipo     VARCHAR(50),
    idProducto     INT
);

ALTER TABLE tbTiposProductos
    ADD CONSTRAINT FK_tipos_productos
        FOREIGN KEY (idProducto)
            REFERENCES tbProductos (idProducto);
GO


CREATE TABLE tbTags
(
    idTag          INT PRIMARY KEY IDENTITY (1,1),
    nombreTag      VARCHAR(35),
    descriptionTag VARCHAR(100),
    fotoTag        VARBINARY(MAX)
);
GO

CREATE TABLE tbProductosTag
(
    idProductoTag INT PRIMARY KEY IDENTITY (1,1),
    idTag         INT,
    idProducto    INT
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

-- Tabla de carritos
CREATE TABLE tbCarritos
(
    idCarrito INT PRIMARY KEY IDENTITY (1,1),
    idCliente INT,
    idNegocio INT,
    date      DATE DEFAULT GETDATE(),
    activo    BIT  DEFAULT 1,
    enviado   BIT  DEFAULT 0,
);
GO

-- total as a computed column
CREATE FUNCTION dbo.GetCartTotal(@idCarrito INT)
    RETURNS DECIMAL(10, 2)
AS
BEGIN
    DECLARE @total DECIMAL(10, 2);

    SELECT @total = SUM(subtotal)
    FROM tbItemsCarrito
    WHERE idCarrito = @idCarrito;

    RETURN @total;
END
GO

ALTER TABLE tbCarritos
    ADD total DECIMAL(10, 2) NULL;
GO

-- Items carrito
CREATE TABLE tbItemsCarrito
(
    idItemCarrito  INT PRIMARY KEY IDENTITY (1,1),
    idCarrito      INT,
    idProducto     INT,
    idTamano       INT,
    idTipoProducto INT,
    cantidad       INT,
);
GO

ALTER TABLE tbItemsCarrito
    ADD CONSTRAINT FK_itemsCarrito_producto
        FOREIGN KEY (idProducto)
            REFERENCES tbProductos (idProducto);

ALTER TABLE tbItemsCarrito
    ADD CONSTRAINT FK_itemsCarrito_tamano
        FOREIGN KEY (idTamano)
            REFERENCES tbTamanos (idTamano);
GO

ALTER TABLE tbItemsCarrito
    ADD CONSTRAINT FK_itemsCarrito_tipoProducto
        FOREIGN KEY (idTipoProducto)
            REFERENCES tbTiposProductos (idTipoProducto);
GO


ALTER TABLE tbItemsCarrito
    ADD CONSTRAINT FK_itemsCarrito_carrito
        FOREIGN KEY (idCarrito)
            REFERENCES tbCarritos (idCarrito);
GO

-- Get precioProducto from tbTamano

-- Subtotal as a computed column
CREATE FUNCTION dbo.GetSubtotal(@idProducto INT)
    RETURNS DECIMAL(10, 2)
AS
BEGIN
    DECLARE @subtotal DECIMAL(10, 2);

    SELECT @subtotal = SUM(cantidad * tbTamanos.precio)
    FROM tbProductos,
         tbItemsCarrito,
         tbTamanos
    WHERE tbProductos.idProducto = tbItemsCarrito.idProducto
      AND tbProductos.idProducto = @idProducto
      AND tbProductos.idProducto = tbTamanos.idProducto;

    RETURN @subtotal;
END
GO

ALTER TABLE tbItemsCarrito
    ADD subtotal DECIMAL(10, 2) NULL;
GO

CREATE TRIGGER tr_UpdateItemSubtotal
    ON tbItemsCarrito
    AFTER INSERT, UPDATE, DELETE
    AS
BEGIN
    UPDATE tbItemsCarrito
    SET subtotal = dbo.GetSubtotal(idProducto)
    WHERE idProducto IN (SELECT idProducto FROM inserted)
       OR idProducto IN (SELECT idProducto FROM deleted);
END
GO


CREATE TABLE tbEnvios
(
    idEnvio      INT PRIMARY KEY IDENTITY (1,1),
    idRepartidor INT,
    idCarrito    INT,
    costoEnvio   MONEY,
    fechaEnvio   DATE,
    activo       BIT,
);
GO

ALTER TABLE tbEnvios
    ADD CONSTRAINT FK_envios_carrito
        FOREIGN KEY (idCarrito)
            REFERENCES tbCarritos (idCarrito)

ALTER TABLE tbEnvios
    ADD CONSTRAINT FK_envios_repartidor
        FOREIGN KEY (idRepartidor)
            REFERENCES tbRepartidores (idRepartidor)
GO

-- Repartidor asignado bit based on the idRepartidor
ALTER TABLE tbEnvios
    ADD repartidorAsignado AS (CASE WHEN idRepartidor IS NULL THEN 0 ELSE 1 END);
GO

--------------------------
CREATE TABLE tbSolicitudesNegocios
(
    idSolicitud           INT IDENTITY (1,1) PRIMARY KEY NOT NULL,
    solicitud             BIT DEFAULT 0,
    nombreNegocio         VARCHAR(100),
    especialidadesNegocio VARCHAR(100),
    cantidadSucursales    INT DEFAULT 1,
    nombrePropietario     VARCHAR(50),
    telefono              VARCHAR(10),
    email                 VARCHAR(100),
    fechaSolicitud        DATE,
    horaApertura          TIME,
    horaCierre            TIME,
    imagenNegocio         VARBINARY(MAX),
    idUsuario             INT
);
GO

ALTER TABLE tbSolicitudesNegocios
    ADD CONSTRAINT FK_usuarios_solicitudes
        FOREIGN KEY (idUsuario)
            REFERENCES tbUsuarios (idUsuario)
GO
