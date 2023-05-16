-- CREATE DATABASE dbPiquele
-- GO
USE dbPiquele
GO

CREATE TABLE tbUsuarios
(
    idUsuario           INT PRIMARY KEY IDENTITY (1,1),
    nombreUsuario       VARCHAR(100),
    correoUsuario       VARCHAR(100) UNIQUE,
    pass                CHAR(88),
    fotoUsuario         IMAGE,
    verificacionEmail   BIT DEFAULT 0,
    informacionCompleta BIT DEFAULT 0,

);
GO

CREATE TABLE tbEntregas
(
    idEntrega           INT PRIMARY KEY IDENTITY (1,1),
    activo              BIT,
    posicionCoordenadas VARCHAR(25),
    idUsuario           INT
);
GO

ALTER TABLE tbEntregas
    ADD CONSTRAINT FK_entregas_usuarios
        FOREIGN KEY (idUsuario)
            REFERENCES tbUsuarios (idUsuario)
GO

CREATE TABLE tbTiendas
(
    idTienda               INT PRIMARY KEY IDENTITY (1,1),
    nombreTienda           VARCHAR(50),
    fotoTienda             IMAGE,
    promedioCalificacion   FLOAT,
    numeroDeCalificaciones SMALLINT,
    especialidad           VARCHAR(100),
    horaApertura           SMALLINT,
    horaCierre             SMALLINT,
    direccionTienda        VARCHAR(150),
    coordenadasTienda      VARCHAR(50),
);
GO

CREATE TABLE tbProductos
(
    idProducto          INT PRIMARY KEY IDENTITY (1,1),
    nombreProducto      VARCHAR(100),
    fotoProducto        IMAGE,
    detallesProducto    VARCHAR(500),
    presenationProducto VARCHAR(15),
    calificacioProducto FLOAT,
    reviews             SMALLINT,
    disponibilidad      BIT,
    cantidadMaxima      SMALLINT,
    idTienda            INT
);
GO

ALTER TABLE tbProductos
    ADD CONSTRAINT FK_productos_tienda
        FOREIGN KEY (idTienda)
            REFERENCES tbTiendas (idTienda)
GO

CREATE TABLE tbOpciones
(
    idOpcion             INT PRIMARY KEY IDENTITY (1,1),
    nombreOpcion         VARCHAR(35),
    precioOpcion         MONEY,
    disponibilidadOpcion BIT,
    idProducto           INT
);
GO

ALTER TABLE tbOpciones
    ADD CONSTRAINT FK_opciones_productos
        FOREIGN KEY (idProducto)
            REFERENCES tbProductos (idProducto)
GO

CREATE TABLE tbTags
(
    idTag     INT PRIMARY KEY IDENTITY (1,1),
    nombreTag VARCHAR(35),
    fotoTag   IMAGE
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

CREATE TABLE tbResenias
(
    idResenia     INT PRIMARY KEY IDENTITY (1,1),
    idUsuario     INT,
    idProducto    INT,
    cuerpoResenia VARCHAR(200)
);
GO

ALTER TABLE tbResenias
    ADD CONSTRAINT FK_resenias_usuarios
        FOREIGN KEY (idUsuario)
            REFERENCES tbUsuarios (idUsuario)
GO

ALTER TABLE tbResenias
    ADD CONSTRAINT FK_resenias_productos
        FOREIGN KEY (idProducto)
            REFERENCES tbProductos (idProducto)
GO

CREATE TABLE tbOpcionEntrega
(
    idOpcionEntrega          INT PRIMARY KEY IDENTITY (1,1),
    nombreOpcionEntrega      VARCHAR(100),
    descripcionOpcionEntrega VARCHAR(100),
    fotoOpcionEntrega        IMAGE
);
GO

CREATE TABLE tbPerfilEntrega
(
    idPerfilEntrega   INT IDENTITY (1,1) PRIMARY KEY,
    coordenadasPerfil VARCHAR(50),
    direccion         VARCHAR(150),
    puerta            VARCHAR(10),
    nombreNegocio     VARCHAR(30),
    notaEntrega       VARCHAR(150),
    idUsuario         INT,
    idOpcionEntrega   INT
);
GO

ALTER TABLE tbPerfilEntrega
    ADD CONSTRAINT FK_perfilEntrega_usuarios
        FOREIGN KEY (idUsuario)
            REFERENCES tbUsuarios (idUsuario)
GO

ALTER TABLE tbPerfilEntrega
    ADD CONSTRAINT FK_perfilEntrega_opcionEntrega
        FOREIGN KEY (idOpcionEntrega)
            REFERENCES tbOpcionEntrega (idOpcionEntrega)
GO

CREATE TABLE tbOrdenProductos
(
    idOrdenProducto INT PRIMARY KEY IDENTITY (1,1),
    ordenEnviada    BIT,
    fechaCompra     MONEY,
    precioCompra    MONEY,
    idUsuario       INT,
    idPerfilEntrega INT
);

GO
ALTER TABLE tbOrdenProductos
    ADD CONSTRAINT FK_ordenProducto_Usuario
        FOREIGN KEY (idUsuario)
            REFERENCES tbUsuarios (idUsuario)
GO

ALTER TABLE tbOrdenProductos
    ADD CONSTRAINT FK_perfilEntrega
        FOREIGN KEY (idPerfilEntrega)
            REFERENCES tbPerfilEntrega (idPerfilEntrega)
GO

CREATE TABLE tbEnvios
(
    idEnvio         INT PRIMARY KEY IDENTITY (1,1),
    estadoEnvio     SMALLINT,
    entregasId_s    CHAR(64),
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
    idCompraItem           INT PRIMARY KEY IDENTITY (1,1),
    nombreCompraItem       VARCHAR(100),
    detalleCompraItem      VARCHAR(300),
    unidadMedida           VARCHAR(15),
    nombreOpcionCompraItem VARCHAR(15),
    precioCompraItem       MONEY,
    idOrdenProducto        INT
);
GO

ALTER TABLE tbCompraItems
    ADD CONSTRAINT FK_compraItem_ordenProducto
        FOREIGN KEY (idOrdenProducto)
            REFERENCES tbOrdenProductos (idOrdenProducto)
GO


