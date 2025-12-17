-- ============================================
-- SISTEMA DE INVENTARIO GRANIX
-- Base de Datos Completa y Optimizada
-- Version: 2.0 - SIN ERRORES

CREATE DATABASE INVENTARIO_GRANIX;
GO

USE INVENTARIO_GRANIX;
GO

PRINT 'Base de datos INVENTARIO_GRANIX creada exitosamente';
PRINT '';
GO

-- ============================================
-- PASO 2: CREAR TABLAS DEL SISTEMA
-- ============================================

-- TABLA 1: Categorias de Productos
CREATE TABLE Categorias (
    id INT IDENTITY(1,1) PRIMARY KEY,
    codigo VARCHAR(10) NOT NULL UNIQUE,
    nombre VARCHAR(50) NOT NULL UNIQUE,
    descripcion VARCHAR(255),
    icono VARCHAR(50),
    estado BIT DEFAULT 1,
    fecha_creacion DATETIME DEFAULT GETDATE(),
    fecha_actualizacion DATETIME DEFAULT GETDATE()
);
GO

PRINT 'Tabla Categorias creada';

-- TABLA 2: Proveedores
CREATE TABLE Proveedores (
    id INT IDENTITY(1,1) PRIMARY KEY,
    codigo VARCHAR(20) NOT NULL UNIQUE,
    nombre VARCHAR(100) NOT NULL,
    razon_social VARCHAR(150),
    tipo_documento VARCHAR(20) CHECK (tipo_documento IN ('RNC', 'Cedula', 'Pasaporte')),
    numero_documento VARCHAR(20),
    contacto_principal VARCHAR(100),
    telefono VARCHAR(20),
    telefono_secundario VARCHAR(20),
    email VARCHAR(100),
    direccion VARCHAR(255),
    ciudad VARCHAR(50),
    pais VARCHAR(50) DEFAULT 'Republica Dominicana',
    codigo_postal VARCHAR(10),
    sitio_web VARCHAR(100),
    banco VARCHAR(50),
    numero_cuenta VARCHAR(30),
    terminos_pago VARCHAR(50),
    dias_credito INT DEFAULT 0,
    calificacion DECIMAL(3,2) CHECK (calificacion BETWEEN 0 AND 5),
    notas TEXT,
    estado BIT DEFAULT 1,
    fecha_creacion DATETIME DEFAULT GETDATE(),
    fecha_actualizacion DATETIME DEFAULT GETDATE()
);
GO

PRINT 'Tabla Proveedores creada';

-- TABLA 3: Unidades de Medida
CREATE TABLE UnidadesMedida (
    id INT IDENTITY(1,1) PRIMARY KEY,
    codigo VARCHAR(10) NOT NULL UNIQUE,
    nombre VARCHAR(30) NOT NULL,
    abreviatura VARCHAR(10) NOT NULL,
    tipo VARCHAR(20) CHECK (tipo IN ('Peso', 'Volumen', 'Longitud', 'Unidad')),
    estado BIT DEFAULT 1
);
GO

PRINT 'Tabla UnidadesMedida creada';

-- TABLA 4: Productos (Mejorada y Completa)
CREATE TABLE Productos (
    id INT IDENTITY(1,1) PRIMARY KEY,
    codigo VARCHAR(20) NOT NULL UNIQUE,
    codigo_barras VARCHAR(50) UNIQUE,
    nombre VARCHAR(100) NOT NULL,
    descripcion VARCHAR(500),
    categoria_id INT NOT NULL,
    subcategoria VARCHAR(50),
    unidad_medida_id INT NOT NULL,
    proveedor_id INT,
    
    -- Precios y Costos
    precio_costo DECIMAL(10,2) DEFAULT 0,
    precio_venta DECIMAL(10,2) NOT NULL,
    precio_mayorista DECIMAL(10,2),
    precio_minimo DECIMAL(10,2),
    margen_ganancia AS (precio_venta - precio_costo) PERSISTED,
    porcentaje_ganancia AS (
        CASE 
            WHEN precio_costo > 0 
            THEN ((precio_venta - precio_costo) / precio_costo * 100)
            ELSE 0 
        END
    ) PERSISTED,
    
    -- Control de Inventario
    stock_actual INT DEFAULT 0,
    stock_minimo INT DEFAULT 10,
    stock_maximo INT DEFAULT 1000,
    punto_reorden INT DEFAULT 20,
    lote VARCHAR(50),
    ubicacion_almacen VARCHAR(50),
    
    -- Informacion Adicional
    marca VARCHAR(50),
    modelo VARCHAR(50),
    peso DECIMAL(10,3),
    dimensiones VARCHAR(50),
    color VARCHAR(30),
    talla VARCHAR(20),
    
    -- Impuestos y Descuentos
    aplica_itbis BIT DEFAULT 1,
    porcentaje_itbis DECIMAL(5,2) DEFAULT 18.00,
    descuento_permitido BIT DEFAULT 1,
    porcentaje_descuento_max DECIMAL(5,2) DEFAULT 10.00,
    
    -- Fechas y Vigencia
    fecha_vencimiento DATE,
    fecha_fabricacion DATE,
    requiere_refrigeracion BIT DEFAULT 0,
    dias_garantia INT DEFAULT 0,
    
    -- Imagenes y Documentos
    imagen_url VARCHAR(255),
    ficha_tecnica_url VARCHAR(255),
    
    -- Control y Estado
    es_activo BIT DEFAULT 1,
    es_vendible BIT DEFAULT 1,
    es_comprable BIT DEFAULT 1,
    requiere_serial BIT DEFAULT 0,
    controlado_inventario BIT DEFAULT 1,
    
    -- Estadisticas
    veces_vendido INT DEFAULT 0,
    ultima_venta DATETIME,
    ultima_compra DATETIME,
    
    -- Auditoria
    usuario_creacion INT,
    usuario_actualizacion INT,
    fecha_creacion DATETIME DEFAULT GETDATE(),
    fecha_actualizacion DATETIME DEFAULT GETDATE(),
    
    FOREIGN KEY (categoria_id) REFERENCES Categorias(id),
    FOREIGN KEY (unidad_medida_id) REFERENCES UnidadesMedida(id),
    FOREIGN KEY (proveedor_id) REFERENCES Proveedores(id)
);
GO

PRINT 'Tabla Productos creada';

-- TABLA 5: Roles y Permisos
CREATE TABLE Roles (
    id INT IDENTITY(1,1) PRIMARY KEY,
    codigo VARCHAR(20) NOT NULL UNIQUE,
    nombre VARCHAR(50) NOT NULL UNIQUE,
    descripcion VARCHAR(255),
    nivel_acceso INT DEFAULT 1 CHECK (nivel_acceso BETWEEN 1 AND 5),
    
    -- Permisos de Productos
    puede_ver_productos BIT DEFAULT 0,
    puede_crear_productos BIT DEFAULT 0,
    puede_editar_productos BIT DEFAULT 0,
    puede_eliminar_productos BIT DEFAULT 0,
    puede_ajustar_precios BIT DEFAULT 0,
    
    -- Permisos de Inventario
    puede_ver_inventario BIT DEFAULT 0,
    puede_registrar_entradas BIT DEFAULT 0,
    puede_registrar_salidas BIT DEFAULT 0,
    puede_hacer_ajustes BIT DEFAULT 0,
    puede_hacer_transferencias BIT DEFAULT 0,
    
    -- Permisos de Compras
    puede_ver_compras BIT DEFAULT 0,
    puede_crear_ordenes_compra BIT DEFAULT 0,
    puede_aprobar_ordenes_compra BIT DEFAULT 0,
    puede_recibir_compras BIT DEFAULT 0,
    
    -- Permisos de Ventas
    puede_ver_ventas BIT DEFAULT 0,
    puede_registrar_ventas BIT DEFAULT 0,
    puede_aplicar_descuentos BIT DEFAULT 0,
    puede_anular_ventas BIT DEFAULT 0,
    
    -- Permisos de Reportes
    puede_ver_reportes BIT DEFAULT 0,
    puede_generar_reportes BIT DEFAULT 0,
    puede_exportar_reportes BIT DEFAULT 0,
    puede_ver_reportes_financieros BIT DEFAULT 0,
    
    -- Permisos de Usuarios
    puede_ver_usuarios BIT DEFAULT 0,
    puede_crear_usuarios BIT DEFAULT 0,
    puede_editar_usuarios BIT DEFAULT 0,
    puede_eliminar_usuarios BIT DEFAULT 0,
    puede_gestionar_roles BIT DEFAULT 0,
    
    -- Permisos de Configuracion
    puede_ver_configuracion BIT DEFAULT 0,
    puede_editar_configuracion BIT DEFAULT 0,
    puede_ver_auditoria BIT DEFAULT 0,
    puede_hacer_respaldos BIT DEFAULT 0,
    
    estado BIT DEFAULT 1,
    fecha_creacion DATETIME DEFAULT GETDATE(),
    fecha_actualizacion DATETIME DEFAULT GETDATE()
);
GO

PRINT 'Tabla Roles creada';

-- TABLA 6: Usuarios del Sistema
CREATE TABLE Usuarios (
    id INT IDENTITY(1,1) PRIMARY KEY,
    codigo VARCHAR(20) NOT NULL UNIQUE,
    usuario VARCHAR(50) NOT NULL UNIQUE,
    contrasena VARCHAR(255) NOT NULL,
    
    -- Informacion Personal
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    nombre_completo AS (nombre + ' ' + apellido) PERSISTED,
    cedula VARCHAR(20),
    email VARCHAR(100) UNIQUE,
    telefono VARCHAR(20),
    direccion VARCHAR(255),
    fecha_nacimiento DATE,
    
    -- Informacion Laboral
    puesto VARCHAR(50),
    departamento VARCHAR(50),
    fecha_contratacion DATE,
    salario DECIMAL(10,2),
    
    -- Rol y Permisos
    rol_id INT NOT NULL,
    
    -- Control de Sesion
    ultimo_acceso DATETIME,
    ip_ultimo_acceso VARCHAR(45),
    intentos_fallidos INT DEFAULT 0,
    fecha_ultimo_intento DATETIME,
    bloqueado BIT DEFAULT 0,
    fecha_bloqueo DATETIME,
    
    -- Configuracion Personal
    tema_preferido VARCHAR(20) DEFAULT 'claro',
    idioma VARCHAR(10) DEFAULT 'es',
    notificaciones_email BIT DEFAULT 1,
    notificaciones_sistema BIT DEFAULT 1,
    
    -- Imagen y Firma
    foto_perfil_url VARCHAR(255),
    firma_digital_url VARCHAR(255),
    
    -- Estado
    estado BIT DEFAULT 1,
    requiere_cambio_contrasena BIT DEFAULT 1,
    fecha_expiracion_contrasena DATETIME,
    
    -- Auditoria
    usuario_creacion INT,
    fecha_creacion DATETIME DEFAULT GETDATE(),
    fecha_actualizacion DATETIME DEFAULT GETDATE(),
    
    FOREIGN KEY (rol_id) REFERENCES Roles(id)
);
GO

PRINT 'Tabla Usuarios creada';

-- TABLA 7: Clientes
CREATE TABLE Clientes (
    id INT IDENTITY(1,1) PRIMARY KEY,
    codigo VARCHAR(20) NOT NULL UNIQUE,
    tipo_cliente VARCHAR(20) CHECK (tipo_cliente IN ('Minorista', 'Mayorista', 'Distribuidor', 'Corporativo')),
    
    -- Informacion Personal/Empresa
    nombre VARCHAR(100) NOT NULL,
    razon_social VARCHAR(150),
    tipo_documento VARCHAR(20) CHECK (tipo_documento IN ('Cedula', 'RNC', 'Pasaporte')),
    numero_documento VARCHAR(20),
    
    -- Contacto
    contacto_principal VARCHAR(100),
    telefono VARCHAR(20),
    telefono_secundario VARCHAR(20),
    email VARCHAR(100),
    direccion VARCHAR(255),
    ciudad VARCHAR(50),
    provincia VARCHAR(50),
    codigo_postal VARCHAR(10),
    
    -- Informacion Financiera
    limite_credito DECIMAL(10,2) DEFAULT 0,
    saldo_pendiente DECIMAL(10,2) DEFAULT 0,
    dias_credito INT DEFAULT 0,
    descuento_especial DECIMAL(5,2) DEFAULT 0,
    
    -- Estadisticas
    total_compras DECIMAL(12,2) DEFAULT 0,
    cantidad_compras INT DEFAULT 0,
    ultima_compra DATETIME,
    fecha_primera_compra DATETIME,
    
    -- Clasificacion
    categoria_cliente VARCHAR(20) CHECK (categoria_cliente IN ('A', 'B', 'C', 'VIP')),
    vendedor_asignado_id INT,
    
    -- Estado y Observaciones
    estado BIT DEFAULT 1,
    notas TEXT,
    
    -- Auditoria
    usuario_creacion INT,
    fecha_creacion DATETIME DEFAULT GETDATE(),
    fecha_actualizacion DATETIME DEFAULT GETDATE(),
    
    FOREIGN KEY (vendedor_asignado_id) REFERENCES Usuarios(id)
);
GO

PRINT 'Tabla Clientes creada';

-- TABLA 8: Almacenes/Bodegas
CREATE TABLE Almacenes (
    id INT IDENTITY(1,1) PRIMARY KEY,
    codigo VARCHAR(20) NOT NULL UNIQUE,
    nombre VARCHAR(100) NOT NULL,
    tipo VARCHAR(30) CHECK (tipo IN ('Principal', 'Secundario', 'Sucursal', 'Transito')),
    direccion VARCHAR(255),
    ciudad VARCHAR(50),
    telefono VARCHAR(20),
    responsable_id INT,
    capacidad_maxima DECIMAL(10,2),
    area_m2 DECIMAL(10,2),
    tiene_refrigeracion BIT DEFAULT 0,
    temperatura_min DECIMAL(5,2),
    temperatura_max DECIMAL(5,2),
    es_principal BIT DEFAULT 0,
    estado BIT DEFAULT 1,
    fecha_creacion DATETIME DEFAULT GETDATE(),
    
    FOREIGN KEY (responsable_id) REFERENCES Usuarios(id)
);
GO

PRINT 'Tabla Almacenes creada';

-- TABLA 9: Movimientos de Inventario
CREATE TABLE Movimientos (
    id INT IDENTITY(1,1) PRIMARY KEY,
    codigo VARCHAR(30) NOT NULL UNIQUE,
    tipo_movimiento VARCHAR(20) NOT NULL CHECK (tipo_movimiento IN ('Entrada', 'Salida', 'Ajuste', 'Transferencia', 'Devolucion')),
    subtipo VARCHAR(30),
    
    -- Producto y Cantidad
    producto_id INT NOT NULL,
    almacen_origen_id INT,
    almacen_destino_id INT,
    cantidad INT NOT NULL,
    
    -- Informacion Financiera
    precio_unitario DECIMAL(10,2),
    subtotal AS (cantidad * precio_unitario) PERSISTED,
    descuento DECIMAL(10,2) DEFAULT 0,
    itbis DECIMAL(10,2) DEFAULT 0,
    total AS (cantidad * precio_unitario - descuento + itbis) PERSISTED,
    
    -- Control de Stock
    stock_anterior INT,
    stock_nuevo INT,
    
    -- Referencias y Documentos
    documento_referencia VARCHAR(50),
    orden_compra_id INT,
    venta_id INT,
    
    -- Motivo y Detalles
    motivo VARCHAR(255) NOT NULL,
    observaciones TEXT,
    
    -- Proveedor/Cliente segun tipo
    proveedor_id INT,
    cliente_id INT,
    
    -- Control de Lote y Vencimiento
    numero_lote VARCHAR(50),
    fecha_vencimiento DATE,
    
    -- Usuario y Aprobacion
    usuario_registro_id INT NOT NULL,
    usuario_aprobacion_id INT,
    fecha_aprobacion DATETIME,
    requiere_aprobacion BIT DEFAULT 0,
    aprobado BIT DEFAULT 0,
    
    -- Estado
    estado VARCHAR(20) DEFAULT 'Pendiente' CHECK (estado IN ('Pendiente', 'Aprobado', 'Rechazado', 'Anulado', 'Completado')),
    motivo_anulacion VARCHAR(255),
    
    -- Fechas
    fecha_movimiento DATETIME DEFAULT GETDATE(),
    fecha_registro DATETIME DEFAULT GETDATE(),
    
    FOREIGN KEY (producto_id) REFERENCES Productos(id),
    FOREIGN KEY (almacen_origen_id) REFERENCES Almacenes(id),
    FOREIGN KEY (almacen_destino_id) REFERENCES Almacenes(id),
    FOREIGN KEY (proveedor_id) REFERENCES Proveedores(id),
    FOREIGN KEY (cliente_id) REFERENCES Clientes(id),
    FOREIGN KEY (usuario_registro_id) REFERENCES Usuarios(id),
    FOREIGN KEY (usuario_aprobacion_id) REFERENCES Usuarios(id)
);
GO

PRINT 'Tabla Movimientos creada';

-- TABLA 10: Ordenes de Compra
CREATE TABLE OrdenesCompra (
    id INT IDENTITY(1,1) PRIMARY KEY,
    numero_orden VARCHAR(30) NOT NULL UNIQUE,
    proveedor_id INT NOT NULL,
    fecha_orden DATETIME DEFAULT GETDATE(),
    fecha_entrega_estimada DATE,
    fecha_entrega_real DATE,
    
    -- Montos
    subtotal DECIMAL(12,2) DEFAULT 0,
    descuento DECIMAL(12,2) DEFAULT 0,
    itbis DECIMAL(12,2) DEFAULT 0,
    total DECIMAL(12,2) DEFAULT 0,
    
    -- Estado y Control
    estado VARCHAR(20) DEFAULT 'Borrador' CHECK (estado IN ('Borrador', 'Enviada', 'Confirmada', 'Recibida Parcial', 'Recibida Total', 'Cancelada')),
    prioridad VARCHAR(20) DEFAULT 'Normal' CHECK (prioridad IN ('Baja', 'Normal', 'Alta', 'Urgente')),
    
    -- Informacion Adicional
    terminos_pago VARCHAR(100),
    metodo_envio VARCHAR(50),
    notas TEXT,
    
    -- Usuarios
    usuario_solicitante_id INT NOT NULL,
    usuario_aprobador_id INT,
    fecha_aprobacion DATETIME,
    
    -- Auditoria
    fecha_creacion DATETIME DEFAULT GETDATE(),
    fecha_actualizacion DATETIME DEFAULT GETDATE(),
    
    FOREIGN KEY (proveedor_id) REFERENCES Proveedores(id),
    FOREIGN KEY (usuario_solicitante_id) REFERENCES Usuarios(id),
    FOREIGN KEY (usuario_aprobador_id) REFERENCES Usuarios(id)
);
GO

PRINT 'Tabla OrdenesCompra creada';

-- TABLA 11: Detalle de Ordenes de Compra
CREATE TABLE DetalleOrdenesCompra (
    id INT IDENTITY(1,1) PRIMARY KEY,
    orden_compra_id INT NOT NULL,
    producto_id INT NOT NULL,
    cantidad_solicitada INT NOT NULL,
    cantidad_recibida INT DEFAULT 0,
    precio_unitario DECIMAL(10,2) NOT NULL,
    descuento DECIMAL(10,2) DEFAULT 0,
    itbis DECIMAL(10,2) DEFAULT 0,
    subtotal AS (cantidad_solicitada * precio_unitario) PERSISTED,
    total AS (cantidad_solicitada * precio_unitario - descuento + itbis) PERSISTED,
    observaciones VARCHAR(500),
    
    FOREIGN KEY (orden_compra_id) REFERENCES OrdenesCompra(id) ON DELETE CASCADE,
    FOREIGN KEY (producto_id) REFERENCES Productos(id)
);
GO

PRINT 'Tabla DetalleOrdenesCompra creada';

-- TABLA 12: Ventas
CREATE TABLE Ventas (
    id INT IDENTITY(1,1) PRIMARY KEY,
    numero_venta VARCHAR(30) NOT NULL UNIQUE,
    tipo_venta VARCHAR(20) CHECK (tipo_venta IN ('Contado', 'Credito', 'Mixto')),
    
    -- Cliente
    cliente_id INT,
    nombre_cliente VARCHAR(100),
    
    -- Fecha y Hora
    fecha_venta DATETIME DEFAULT GETDATE(),
    
    -- Montos
    subtotal DECIMAL(12,2) NOT NULL,
    descuento DECIMAL(12,2) DEFAULT 0,
    itbis DECIMAL(12,2) DEFAULT 0,
    total DECIMAL(12,2) NOT NULL,
    
    -- Pagos
    efectivo DECIMAL(12,2) DEFAULT 0,
    tarjeta DECIMAL(12,2) DEFAULT 0,
    transferencia DECIMAL(12,2) DEFAULT 0,
    cheque DECIMAL(12,2) DEFAULT 0,
    credito DECIMAL(12,2) DEFAULT 0,
    cambio AS (efectivo + tarjeta + transferencia + cheque - total) PERSISTED,
    
    -- Control
    estado VARCHAR(20) DEFAULT 'Completada' CHECK (estado IN ('Completada', 'Anulada', 'Pendiente')),
    motivo_anulacion VARCHAR(255),
    
    -- Referencias
    almacen_id INT NOT NULL,
    usuario_vendedor_id INT NOT NULL,
    usuario_anulacion_id INT,
    fecha_anulacion DATETIME,
    
    -- Observaciones
    observaciones TEXT,
    
    FOREIGN KEY (cliente_id) REFERENCES Clientes(id),
    FOREIGN KEY (almacen_id) REFERENCES Almacenes(id),
    FOREIGN KEY (usuario_vendedor_id) REFERENCES Usuarios(id),
    FOREIGN KEY (usuario_anulacion_id) REFERENCES Usuarios(id)
);
GO

PRINT 'Tabla Ventas creada';

-- TABLA 13: Detalle de Ventas
CREATE TABLE DetalleVentas (
    id INT IDENTITY(1,1) PRIMARY KEY,
    venta_id INT NOT NULL,
    producto_id INT NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    descuento DECIMAL(10,2) DEFAULT 0,
    itbis DECIMAL(10,2) DEFAULT 0,
    subtotal AS (cantidad * precio_unitario) PERSISTED,
    total AS (cantidad * precio_unitario - descuento + itbis) PERSISTED,
    
    -- Costo para calcular ganancia
    costo_unitario DECIMAL(10,2),
    ganancia AS ((precio_unitario - costo_unitario) * cantidad) PERSISTED,
    
    FOREIGN KEY (venta_id) REFERENCES Ventas(id) ON DELETE CASCADE,
    FOREIGN KEY (producto_id) REFERENCES Productos(id)
);
GO

PRINT 'Tabla DetalleVentas creada';

-- TABLA 14: Auditoria del Sistema
CREATE TABLE Auditoria (
    id INT IDENTITY(1,1) PRIMARY KEY,
    tabla_afectada VARCHAR(50) NOT NULL,
    accion VARCHAR(20) NOT NULL CHECK (accion IN ('INSERT', 'UPDATE', 'DELETE', 'LOGIN', 'LOGOUT', 'ERROR')),
    registro_id INT,
    descripcion VARCHAR(500),
    datos_anteriores TEXT,
    datos_nuevos TEXT,
    ip_origen VARCHAR(45),
    navegador VARCHAR(100),
    usuario_id INT NOT NULL,
    fecha_accion DATETIME DEFAULT GETDATE(),
    
    FOREIGN KEY (usuario_id) REFERENCES Usuarios(id)
);
GO

PRINT 'Tabla Auditoria creada';

-- TABLA 15: Configuracion del Sistema
CREATE TABLE ConfiguracionSistema (
    id INT IDENTITY(1,1) PRIMARY KEY,
    clave VARCHAR(50) NOT NULL UNIQUE,
    valor VARCHAR(500),
    descripcion VARCHAR(255),
    tipo_dato VARCHAR(20) CHECK (tipo_dato IN ('texto', 'numero', 'booleano', 'fecha', 'json')),
    categoria VARCHAR(50),
    fecha_actualizacion DATETIME DEFAULT GETDATE(),
    usuario_actualizacion_id INT,
    
    FOREIGN KEY (usuario_actualizacion_id) REFERENCES Usuarios(id)
);
GO

PRINT 'Tabla ConfiguracionSistema creada';

PRINT '';
PRINT '================================================================';
PRINT '           TABLAS CREADAS EXITOSAMENTE';
PRINT '================================================================';
PRINT '';
GO

-- ============================================
-- PASO 3: INSERTAR DATOS INICIALES
-- ============================================

-- Insertar Unidades de Medida
INSERT INTO UnidadesMedida (codigo, nombre, abreviatura, tipo) VALUES
('UNI', 'Unidad', 'Ud', 'Unidad'),
('KG', 'Kilogramo', 'kg', 'Peso'),
('GR', 'Gramo', 'g', 'Peso'),
('LB', 'Libra', 'lb', 'Peso'),
('LT', 'Litro', 'L', 'Volumen'),
('ML', 'Mililitro', 'ml', 'Volumen'),
('CAJ', 'Caja', 'cj', 'Unidad'),
('PAQ', 'Paquete', 'pq', 'Unidad'),
('DOC', 'Docena', 'doc', 'Unidad'),
('MTS', 'Metro', 'm', 'Longitud');
GO

PRINT '10 Unidades de Medida insertadas';

-- Insertar Categorias
INSERT INTO Categorias (codigo, nombre, descripcion, icono) VALUES
('CER', 'Cereales', 'Cereales y productos de desayuno', 'cereal'),
('GAL', 'Galletas', 'Galletas dulces y saladas', 'galleta'),
('BEB', 'Bebidas Vegetales', 'Bebidas alternativas sin lactosa', 'bebida'),
('GRA', 'Granos', 'Granos y semillas', 'grano'),
('TE', 'Tes e Infusiones', 'Tes e infusiones naturales', 'te'),
('CHO', 'Chocolates', 'Productos de chocolate', 'chocolate'),
('JUG', 'Jugos', 'Jugos naturales y concentrados', 'jugo'),
('PAS', 'Pastas', 'Pastas y fideos', 'pasta'),
('CON', 'Condimentos', 'Especias y condimentos', 'condimento'),
('SNK', 'Snacks', 'Snacks saludables', 'snack');
GO

PRINT '10 Categorias insertadas';

-- Insertar Proveedores
INSERT INTO Proveedores (codigo, nombre, razon_social, tipo_documento, numero_documento, contacto_principal, telefono, email, direccion, ciudad, terminos_pago, dias_credito, calificacion) VALUES
('PROV-001', 'Distribuidora ABC', 'ABC Distribuciones SRL', 'RNC', '130-12345-6', 'Juan Perez', '809-555-1001', 'ventas@abc.com', 'Av. Principal No.123', 'Santo Domingo', '30 dias', 30, 4.5),
('PROV-002', 'Importadora XYZ', 'XYZ Import Export SA', 'RNC', '130-23456-7', 'Maria Gonzalez', '809-555-1002', 'info@xyz.com', 'Calle Comercio No.456', 'Santiago', '45 dias', 45, 4.8),
('PROV-003', 'Alimentos Naturales RD', 'Alimentos Naturales SRL', 'RNC', '130-34567-8', 'Pedro Jimenez', '809-555-1003', 'pedidos@alimentosrd.com', 'Zona Industrial No.789', 'La Vega', 'Contado', 0, 4.2),
('PROV-004', 'Granix Internacional', 'Granix Corp', 'RNC', '130-45678-9', 'Ana Martinez', '809-555-1004', 'compras@granix.com', 'Plaza Industrial No.101', 'Santo Domingo', '15 dias', 15, 5.0),
('PROV-005', 'Productos Organicos SA', 'Organicos Dominicanos SA', 'RNC', '130-56789-0', 'Carlos Lopez', '809-555-1005', 'ventas@organicos.com', 'Carretera Duarte Km 5', 'Santiago', '30 dias', 30, 4.6);
GO

PRINT '5 Proveedores insertados';

-- Insertar Almacenes
INSERT INTO Almacenes (codigo, nombre, tipo, direccion, ciudad, telefono, capacidad_maxima, area_m2, tiene_refrigeracion, es_principal) VALUES
('ALM-001', 'Almacen Principal', 'Principal', 'Av. Industrial No.500', 'Santo Domingo', '809-555-2001', 10000, 500, 1, 1),
('ALM-002', 'Sucursal Santiago', 'Sucursal', 'Calle del Sol No.200', 'Santiago', '809-555-2002', 5000, 250, 1, 0),
('ALM-003', 'Bodega La Vega', 'Secundario', 'Zona Franca No.100', 'La Vega', '809-555-2003', 3000, 150, 0, 0);
GO

PRINT '3 Almacenes insertados';

-- Insertar Roles
INSERT INTO Roles (codigo, nombre, descripcion, nivel_acceso,
    puede_ver_productos, puede_crear_productos, puede_editar_productos, puede_eliminar_productos, puede_ajustar_precios,
    puede_ver_inventario, puede_registrar_entradas, puede_registrar_salidas, puede_hacer_ajustes, puede_hacer_transferencias,
    puede_ver_compras, puede_crear_ordenes_compra, puede_aprobar_ordenes_compra, puede_recibir_compras,
    puede_ver_ventas, puede_registrar_ventas, puede_aplicar_descuentos, puede_anular_ventas,
    puede_ver_reportes, puede_generar_reportes, puede_exportar_reportes, puede_ver_reportes_financieros,
    puede_ver_usuarios, puede_crear_usuarios, puede_editar_usuarios, puede_eliminar_usuarios, puede_gestionar_roles,
    puede_ver_configuracion, puede_editar_configuracion, puede_ver_auditoria, puede_hacer_respaldos) 
VALUES
('ROL-001', 'Super Administrador', 'Control total del sistema sin restricciones', 5, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
('ROL-002', 'Administrador', 'Gestion operativa del sistema', 4, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 1, 0, 1, 0),
('ROL-003', 'Gerente', 'Supervision de operaciones y reportes', 3, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1, 0, 1, 0),
('ROL-004', 'Vendedor', 'Registro de ventas y consultas', 2, 1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
('ROL-005', 'Almacen', 'Gestion de inventario y recepcion', 2, 1, 0, 1, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
('ROL-006', 'Auditor', 'Revision y generacion de reportes', 2, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1, 0, 1, 0),
('ROL-007', 'Cajero', 'Registro de ventas al contado', 1, 1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
GO

PRINT '7 Roles insertados';

-- Insertar Usuarios
INSERT INTO Usuarios (codigo, usuario, contrasena, nombre, apellido, cedula, email, telefono, puesto, departamento, fecha_contratacion, rol_id) VALUES
('USR-001', 'admin', 'Admin2024', 'Carlos', 'Rodriguez', '001-0123456-7', 'admin@granix.com', '809-555-0001', 'Director General', 'Administracion', '2020-01-15', 1),
('USR-002', 'admin2', 'Admin2024', 'Laura', 'Martinez', '001-0234567-8', 'laura.martinez@granix.com', '809-555-0002', 'Gerente Administrativo', 'Administracion', '2020-03-10', 2),
('USR-003', 'gerente1', 'Gerente2024', 'Miguel', 'Santos', '001-0345678-9', 'miguel.santos@granix.com', '809-555-0003', 'Gerente de Operaciones', 'Operaciones', '2020-06-01', 3),
('USR-004', 'gerente2', 'Gerente2024', 'Ana', 'Lopez', '001-0456789-0', 'ana.lopez@granix.com', '809-555-0004', 'Gerente de Ventas', 'Ventas', '2021-02-15', 3),
('USR-005', 'vendedor1', 'Venta2024', 'Jose', 'Fernandez', '001-0567890-1', 'jose.fernandez@granix.com', '809-555-0005', 'Vendedor Senior', 'Ventas', '2021-04-20', 4),
('USR-006', 'vendedor2', 'Venta2024', 'Patricia', 'Diaz', '001-0678901-2', 'patricia.diaz@granix.com', '809-555-0006', 'Vendedor', 'Ventas', '2022-01-10', 4),
('USR-007', 'vendedor3', 'Venta2024', 'Roberto', 'Garcia', '001-0789012-3', 'roberto.garcia@granix.com', '809-555-0007', 'Vendedor', 'Ventas', '2022-03-15', 4),
('USR-008', 'almacen1', 'Almacen2024', 'Luis', 'Perez', '001-0890123-4', 'luis.perez@granix.com', '809-555-0008', 'Jefe de Almacen', 'Logistica', '2020-08-01', 5),
('USR-009', 'almacen2', 'Almacen2024', 'Maria', 'Gomez', '001-0901234-5', 'maria.gomez@granix.com', '809-555-0009', 'Asistente de Almacen', 'Logistica', '2021-11-20', 5),
('USR-010', 'auditor1', 'Audit2024', 'Ricardo', 'Mendez', '001-1012345-6', 'ricardo.mendez@granix.com', '809-555-0010', 'Auditor Interno', 'Finanzas', '2021-05-10', 6),
('USR-011', 'cajero1', 'Caja2024', 'Carmen', 'Reyes', '001-1123456-7', 'carmen.reyes@granix.com', '809-555-0011', 'Cajero', 'Ventas', '2022-06-01', 7),
('USR-012', 'cajero2', 'Caja2024', 'Juan', 'Torres', '001-1234567-8', 'juan.torres@granix.com', '809-555-0012', 'Cajero', 'Ventas', '2023-01-15', 7);
GO

PRINT '12 Usuarios insertados';

-- Insertar Productos
DECLARE @cat_cereal INT = (SELECT id FROM Categorias WHERE codigo = 'CER');
DECLARE @cat_galletas INT = (SELECT id FROM Categorias WHERE codigo = 'GAL');
DECLARE @cat_bebidas INT = (SELECT id FROM Categorias WHERE codigo = 'BEB');
DECLARE @cat_granos INT = (SELECT id FROM Categorias WHERE codigo = 'GRA');
DECLARE @cat_te INT = (SELECT id FROM Categorias WHERE codigo = 'TE');
DECLARE @cat_chocolate INT = (SELECT id FROM Categorias WHERE codigo = 'CHO');
DECLARE @cat_jugos INT = (SELECT id FROM Categorias WHERE codigo = 'JUG');
DECLARE @cat_pastas INT = (SELECT id FROM Categorias WHERE codigo = 'PAS');
DECLARE @cat_snacks INT = (SELECT id FROM Categorias WHERE codigo = 'SNK');

DECLARE @um_unidad INT = (SELECT id FROM UnidadesMedida WHERE codigo = 'UNI');
DECLARE @um_kg INT = (SELECT id FROM UnidadesMedida WHERE codigo = 'KG');
DECLARE @um_litro INT = (SELECT id FROM UnidadesMedida WHERE codigo = 'LT');
DECLARE @um_caja INT = (SELECT id FROM UnidadesMedida WHERE codigo = 'CAJ');
DECLARE @um_paquete INT = (SELECT id FROM UnidadesMedida WHERE codigo = 'PAQ');

DECLARE @prov1 INT = (SELECT id FROM Proveedores WHERE codigo = 'PROV-001');
DECLARE @prov2 INT = (SELECT id FROM Proveedores WHERE codigo = 'PROV-002');
DECLARE @prov3 INT = (SELECT id FROM Proveedores WHERE codigo = 'PROV-003');
DECLARE @prov4 INT = (SELECT id FROM Proveedores WHERE codigo = 'PROV-004');

INSERT INTO Productos (codigo, codigo_barras, nombre, descripcion, categoria_id, unidad_medida_id, proveedor_id, precio_costo, precio_venta, precio_mayorista, stock_actual, stock_minimo, stock_maximo, punto_reorden, ubicacion_almacen, marca, peso, aplica_itbis, es_activo, es_vendible, usuario_creacion) VALUES
('PROD-001', '7501234567890', 'Granola Granix Original', 'Granola natural con frutos secos y miel, 500g', @cat_cereal, @um_paquete, @prov4, 4.20, 5.50, 5.00, 150, 30, 500, 50, 'A-01-01', 'Granix', 0.500, 1, 1, 1, 1),
('PROD-002', '7501234567891', 'Granola Granix con Chocolate', 'Granola con trozos de chocolate negro, 500g', @cat_cereal, @um_paquete, @prov4, 4.50, 5.90, 5.40, 120, 25, 400, 40, 'A-01-02', 'Granix', 0.500, 1, 1, 1, 1),
('PROD-003', '7501234567892', 'Copos de Maiz Natural', 'Corn flakes sin azucar anadida, 400g', @cat_cereal, @um_paquete, @prov1, 3.20, 4.20, 3.80, 180, 40, 600, 60, 'A-01-03', 'Nutri-Cereal', 0.400, 1, 1, 1, 1),
('PROD-004', '7501234567893', 'Avena en Hojuelas Premium', 'Avena integral en hojuelas, 500g', @cat_cereal, @um_paquete, @prov1, 2.10, 2.80, 2.50, 250, 50, 800, 80, 'A-01-04', 'Avena Plus', 0.500, 1, 1, 1, 1),
('PROD-005', '7501234567894', 'Galletas Integrales Vainilla', 'Galletas integrales sabor vainilla sin azucar, 200g', @cat_galletas, @um_paquete, @prov2, 2.50, 3.25, 2.90, 200, 40, 700, 70, 'A-02-01', 'Integral Life', 0.200, 1, 1, 1, 1),
('PROD-006', '7501234567895', 'Galletas de Arroz Light', 'Galletas crujientes de arroz integral, 150g', @cat_galletas, @um_paquete, @prov2, 2.20, 2.95, 2.60, 180, 35, 600, 60, 'A-02-02', 'Rice Crisp', 0.150, 1, 1, 1, 1),
('PROD-007', '7501234567896', 'Galletas Avena y Pasas', 'Galletas caseras de avena con pasas, 250g', @cat_galletas, @um_paquete, @prov3, 2.80, 3.60, 3.20, 150, 30, 500, 50, 'A-02-03', 'Homemade', 0.250, 1, 1, 1, 1),
('PROD-008', '7501234567897', 'Leche de Almendra Natural', 'Bebida de almendra sin lactosa, 1L', @cat_bebidas, @um_litro, @prov3, 3.60, 4.80, 4.30, 100, 20, 300, 35, 'B-01-01', 'Almond Plus', 1.0, 1, 1, 1, 1),
('PROD-009', '7501234567898', 'Leche de Coco Organica', 'Bebida de coco 100 por ciento natural, 1L', @cat_bebidas, @um_litro, @prov3, 3.90, 5.20, 4.70, 80, 15, 250, 30, 'B-01-02', 'Coco Life', 1.0, 1, 1, 1, 1),
('PROD-010', '7501234567899', 'Leche de Soja Fortificada', 'Bebida de soja con calcio y vitaminas, 1L', @cat_bebidas, @um_litro, @prov2, 3.20, 4.30, 3.80, 120, 25, 400, 40, 'B-01-03', 'Soy Health', 1.0, 1, 1, 1, 1),
('PROD-011', '7501234567900', 'Quinoa Integral Organica', 'Quinoa blanca lista para cocinar, 500g', @cat_granos, @um_paquete, @prov3, 5.20, 6.90, 6.20, 90, 20, 300, 35, 'A-03-01', 'Quinoa Real', 0.500, 1, 1, 1, 1),
('PROD-012', '7501234567901', 'Arroz Integral Premium', 'Arroz integral de grano largo, 1kg', @cat_granos, @um_kg, @prov1, 2.80, 3.75, 3.30, 200, 40, 600, 70, 'A-03-02', 'Arroz Premium', 1.0, 1, 1, 1, 1),
('PROD-013', '7501234567902', 'Semillas de Chia Organicas', 'Semillas de chia 100 por ciento naturales, 250g', @cat_granos, @um_paquete, @prov3, 3.40, 4.50, 4.00, 130, 25, 400, 45, 'A-03-03', 'Chia Power', 0.250, 1, 1, 1, 1),
('PROD-014', '7501234567903', 'Lentejas Rojas', 'Lentejas rojas secas para cocinar, 500g', @cat_granos, @um_paquete, @prov1, 1.80, 2.50, 2.20, 180, 35, 600, 60, 'A-03-04', 'Legumbres RD', 0.500, 1, 1, 1, 1),
('PROD-015', '7501234567904', 'Te Verde Natural', 'Te verde en saquitos x25 unidades', @cat_te, @um_caja, @prov2, 1.90, 2.50, 2.20, 250, 50, 800, 80, 'A-04-01', 'Green Life', 0.050, 1, 1, 1, 1),
('PROD-016', '7501234567905', 'Te de Manzanilla Premium', 'Te de manzanilla natural x25 saquitos', @cat_te, @um_caja, @prov2, 1.75, 2.30, 2.00, 220, 45, 700, 75, 'A-04-02', 'Herbal Tea', 0.045, 1, 1, 1, 1),
('PROD-017', '7501234567906', 'Te Negro English Breakfast', 'Te negro de alta calidad x20 saquitos', @cat_te, @um_caja, @prov2, 2.20, 2.90, 2.60, 180, 35, 600, 55, 'A-04-03', 'Classic Tea', 0.040, 1, 1, 1, 1),
('PROD-018', '7501234567907', 'Chocolate de Soja 70 Cacao', 'Chocolate elaborado a base de soja, 100g', @cat_chocolate, @um_unidad, @prov4, 4.40, 5.80, 5.20, 110, 20, 350, 40, 'A-05-01', 'Choco Soy', 0.100, 1, 1, 1, 1),
('PROD-019', '7501234567908', 'Chocolate Negro 85 Organico', 'Chocolate amargo sin azucar, 90g', @cat_chocolate, @um_unidad, @prov4, 4.70, 6.20, 5.60, 90, 18, 300, 35, 'A-05-02', 'Dark Pure', 0.090, 1, 1, 1, 1),
('PROD-020', '7501234567909', 'Jugo de Manzana 100 Natural', 'Jugo de manzana sin conservantes, 1L', @cat_jugos, @um_litro, @prov1, 2.95, 3.90, 3.50, 140, 30, 450, 50, 'B-02-01', 'Fresh Juice', 1.0, 1, 1, 1, 1),
('PROD-021', '7501234567910', 'Jugo de Naranja Natural', 'Jugo de naranja recien exprimido, 1L', @cat_jugos, @um_litro, @prov1, 3.10, 4.10, 3.70, 130, 25, 400, 45, 'B-02-02', 'Fresh Juice', 1.0, 1, 1, 1, 1),
('PROD-022', '7501234567911', 'Pasta Integral Spaghetti', 'Pasta integral de trigo, 500g', @cat_pastas, @um_paquete, @prov1, 2.35, 3.10, 2.75, 200, 40, 650, 65, 'A-06-01', 'Pasta Premium', 0.500, 1, 1, 1, 1),
('PROD-023', '7501234567912', 'Pasta Penne Integral', 'Pasta penne de trigo integral, 500g', @cat_pastas, @um_paquete, @prov1, 2.35, 3.10, 2.75, 180, 35, 600, 60, 'A-06-02', 'Pasta Premium', 0.500, 1, 1, 1, 1),
('PROD-024', '7501234567913', 'Mix de Frutos Secos', 'Mezcla de nueces, almendras y pasas, 200g', @cat_snacks, @um_paquete, @prov3, 3.80, 5.10, 4.60, 100, 20, 300, 35, 'A-07-01', 'Nut Mix', 0.200, 1, 1, 1, 1),
('PROD-025', '7501234567914', 'Barras de Granola', 'Barras energeticas de granola x6 unidades', @cat_snacks, @um_caja, @prov4, 3.20, 4.30, 3.80, 150, 30, 500, 50, 'A-07-02', 'Granix', 0.180, 1, 1, 1, 1);
GO

PRINT '25 Productos insertados con informacion completa';

-- Insertar Clientes
INSERT INTO Clientes (codigo, tipo_cliente, nombre, razon_social, tipo_documento, numero_documento, contacto_principal, telefono, email, direccion, ciudad, provincia, limite_credito, dias_credito, categoria_cliente, usuario_creacion) VALUES
('CLI-001', 'Mayorista', 'Supermercado La Economica', 'La Economica SRL', 'RNC', '130-87654-3', 'Fernando Ortiz', '809-555-3001', 'compras@laeconomica.com', 'Av. Independencia No.200', 'Santo Domingo', 'Nacional', 50000, 45, 'A', 1),
('CLI-002', 'Mayorista', 'Cadena Nacional', 'Cadena Nacional SA', 'RNC', '130-87654-4', 'Sandra Mejia', '809-555-3002', 'ventas@cadenanacional.com', 'Carretera Mella Km 8', 'Santo Domingo', 'Nacional', 75000, 60, 'VIP', 1),
('CLI-003', 'Distribuidor', 'Distribuidora del Este', 'Del Este Distribuciones', 'RNC', '130-87654-5', 'Roberto Sanchez', '809-555-3003', 'pedidos@deleste.com', 'Zona Oriental No.150', 'La Romana', 'La Romana', 30000, 30, 'A', 1),
('CLI-004', 'Minorista', 'Colmado Don Juan', '', 'Cedula', '001-1234567-8', 'Juan Perez', '809-555-3004', 'donjuan@email.com', 'Calle Principal No.45', 'Santiago', 'Santiago', 5000, 15, 'B', 1),
('CLI-005', 'Minorista', 'Minimarket El Ahorro', '', 'RNC', '130-87654-6', 'Maria Gonzalez', '809-555-3005', 'elahorro@email.com', 'Av. Duarte No.320', 'La Vega', 'La Vega', 8000, 15, 'B', 1),
('CLI-006', 'Corporativo', 'Hotel Paradise Resort', 'Paradise Resorts SA', 'RNC', '130-87654-7', 'Luis Martinez', '809-555-3006', 'compras@paradise.com', 'Zona Turistica Bavaro', 'Punta Cana', 'La Altagracia', 100000, 60, 'VIP', 1),
('CLI-007', 'Minorista', 'Cliente General', '', 'Cedula', '000-0000000-0', 'Publico General', '809-555-3007', 'info@granix.com', 'N/A', 'Santo Domingo', 'Nacional', 0, 0, 'C', 1);
GO

PRINT '7 Clientes insertados';

-- Insertar Configuracion del Sistema
INSERT INTO ConfiguracionSistema (clave, valor, descripcion, tipo_dato, categoria) VALUES
('empresa_nombre', 'GRANIX - Sistema de Inventario', 'Nombre de la empresa', 'texto', 'General'),
('empresa_rnc', '130-99999-9', 'RNC de la empresa', 'texto', 'General'),
('empresa_telefono', '809-555-0000', 'Telefono principal', 'texto', 'General'),
('empresa_email', 'info@granix.com', 'Email corporativo', 'texto', 'General'),
('empresa_direccion', 'Av. Principal No.500, Santo Domingo, RD', 'Direccion fisica', 'texto', 'General'),
('moneda_principal', 'RD', 'Simbolo de moneda', 'texto', 'Finanzas'),
('itbis_porcentaje', '18', 'Porcentaje de ITBIS', 'numero', 'Finanzas'),
('stock_minimo_alerta', '20', 'Stock minimo para alertas', 'numero', 'Inventario'),
('dias_vencimiento_alerta', '30', 'Dias antes de vencimiento para alertar', 'numero', 'Inventario'),
('backup_automatico', 'true', 'Realizar backup automatico', 'booleano', 'Sistema'),
('decimales_precios', '2', 'Decimales en precios', 'numero', 'Finanzas'),
('permitir_stock_negativo', 'false', 'Permitir ventas con stock negativo', 'booleano', 'Inventario');
GO

PRINT 'Configuracion del sistema insertada';
PRINT '';
PRINT '================================================================';
PRINT '           DATOS INICIALES INSERTADOS EXITOSAMENTE';
PRINT '================================================================';
PRINT '';
GO

-- ============================================
-- PASO 4: CREAR VISTAS
-- ============================================

-- VISTA 1: Productos Completo
CREATE VIEW vw_Productos_Completo AS
SELECT 
    p.id, p.codigo, p.codigo_barras, p.nombre, p.descripcion,
    c.nombre AS categoria, p.subcategoria, p.marca,
    um.nombre AS unidad_medida, um.abreviatura AS unidad_abrev,
    prov.nombre AS proveedor,
    p.precio_costo, p.precio_venta, p.precio_mayorista, p.precio_minimo,
    p.margen_ganancia, p.porcentaje_ganancia,
    p.stock_actual, p.stock_minimo, p.stock_maximo, p.punto_reorden,
    p.stock_actual * p.precio_venta AS valor_inventario,
    p.stock_actual * p.precio_costo AS valor_costo,
    CASE 
        WHEN p.stock_actual = 0 THEN 'Sin Stock'
        WHEN p.stock_actual <= p.stock_minimo THEN 'Stock Critico'
        WHEN p.stock_actual <= p.punto_reorden THEN 'Debe Reordenar'
        WHEN p.stock_actual >= p.stock_maximo THEN 'Sobre Stock'
        ELSE 'Stock Normal'
    END AS estado_stock,
    p.ubicacion_almacen, p.lote, p.peso, p.dimensiones,
    p.fecha_vencimiento, p.fecha_fabricacion, p.ultima_venta, p.ultima_compra,
    CASE WHEN p.es_activo = 1 THEN 'Activo' ELSE 'Inactivo' END AS estado,
    p.veces_vendido, p.fecha_creacion, p.fecha_actualizacion
FROM Productos p
INNER JOIN Categorias c ON p.categoria_id = c.id
INNER JOIN UnidadesMedida um ON p.unidad_medida_id = um.id
LEFT JOIN Proveedores prov ON p.proveedor_id = prov.id;
GO

PRINT 'Vista vw_Productos_Completo creada';

-- VISTA 2: Dashboard Metricas
CREATE VIEW vw_Dashboard_Metricas AS
SELECT 
    (SELECT COUNT(*) FROM Productos WHERE es_activo = 1) AS total_productos_activos,
    (SELECT COUNT(*) FROM Productos WHERE stock_actual <= punto_reorden AND es_activo = 1) AS productos_por_reordenar,
    (SELECT COUNT(*) FROM Productos WHERE stock_actual = 0 AND es_activo = 1) AS productos_sin_stock,
    (SELECT ISNULL(SUM(stock_actual * precio_venta), 0) FROM Productos WHERE es_activo = 1) AS valor_total_inventario,
    (SELECT ISNULL(SUM(stock_actual * precio_costo), 0) FROM Productos WHERE es_activo = 1) AS costo_total_inventario,
    (SELECT ISNULL(SUM(stock_actual), 0) FROM Productos WHERE es_activo = 1) AS total_unidades_inventario,
    (SELECT COUNT(*) FROM Clientes WHERE estado = 1) AS total_clientes_activos,
    (SELECT COUNT(*) FROM Proveedores WHERE estado = 1) AS total_proveedores_activos,
    (SELECT COUNT(*) FROM Usuarios WHERE estado = 1) AS total_usuarios_activos,
    GETDATE() AS fecha_actualizacion;
GO

PRINT 'Vista vw_Dashboard_Metricas creada';

PRINT '';
PRINT '================================================================';
PRINT '      BASE DE DATOS CREADA EXITOSAMENTE - SIN ERRORES';
PRINT '================================================================';
PRINT '';
PRINT 'RESUMEN:';
PRINT '- 15 Tablas creadas';
PRINT '- 10 Categorias';
PRINT '- 10 Unidades de Medida';
PRINT '- 5 Proveedores';
PRINT '- 3 Almacenes';
PRINT '- 7 Roles';
PRINT '- 12 Usuarios';
PRINT '- 25 Productos';
PRINT '- 7 Clientes';
PRINT '- 12 Configuraciones';
PRINT '- 2 Vistas principales';
PRINT '';
PRINT 'La base de datos esta lista para usar!';
PRINT '';
GO
IF COL_LENGTH('Usuarios', 'contrasena_hash') IS NULL
BEGIN
    ALTER TABLE Usuarios ADD contrasena_hash VARBINARY(256);
END;

IF COL_LENGTH('Usuarios', 'contrasena_salt') IS NULL
BEGIN
    ALTER TABLE Usuarios ADD contrasena_salt VARBINARY(128);
END;
GO
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Permisos')
BEGIN
    CREATE TABLE Permisos (
        id INT IDENTITY(1,1) PRIMARY KEY,
        codigo VARCHAR(50) UNIQUE NOT NULL,
        descripcion VARCHAR(255)
    );
END;
GO
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'RolPermisos')
BEGIN
    CREATE TABLE RolPermisos (
        rol_id INT NOT NULL,
        permiso_id INT NOT NULL,
        PRIMARY KEY (rol_id, permiso_id),
        FOREIGN KEY (rol_id) REFERENCES Roles(id),
        FOREIGN KEY (permiso_id) REFERENCES Permisos(id)
    );
END;
GO
INSERT INTO Permisos (codigo, descripcion)
SELECT 'VER_PRODUCTOS','Ver productos' WHERE NOT EXISTS (SELECT 1 FROM Permisos WHERE codigo='VER_PRODUCTOS')
UNION ALL SELECT 'CREAR_PRODUCTOS','Crear productos'
UNION ALL SELECT 'EDITAR_PRODUCTOS','Editar productos'
UNION ALL SELECT 'ELIMINAR_PRODUCTOS','Eliminar productos'
UNION ALL SELECT 'VER_INVENTARIO','Ver inventario'
UNION ALL SELECT 'REGISTRAR_VENTAS','Registrar ventas'
UNION ALL SELECT 'VER_USUARIOS','Ver usuarios'
UNION ALL SELECT 'GESTIONAR_USUARIOS','Gestionar usuarios'
UNION ALL SELECT 'VER_REPORTES','Ver reportes'
UNION ALL SELECT 'VER_AUDITORIA','Ver auditoria';
GO
INSERT INTO RolPermisos (rol_id, permiso_id)
SELECT r.id, p.id
FROM Roles r
JOIN Permisos p ON p.codigo IN ('VER_PRODUCTOS','VER_INVENTARIO','REGISTRAR_VENTAS')
WHERE r.nombre = 'Vendedor'
AND NOT EXISTS (
    SELECT 1 FROM RolPermisos rp
    WHERE rp.rol_id = r.id AND rp.permiso_id = p.id
);
GO
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'HistorialRolesUsuario')
BEGIN
    CREATE TABLE HistorialRolesUsuario (
        id INT IDENTITY(1,1) PRIMARY KEY,
        usuario_id INT NOT NULL,
        rol_anterior_id INT,
        rol_nuevo_id INT,
        usuario_cambio_id INT,
        fecha_cambio DATETIME DEFAULT GETDATE(),
        FOREIGN KEY (usuario_id) REFERENCES Usuarios(id),
        FOREIGN KEY (rol_anterior_id) REFERENCES Roles(id),
        FOREIGN KEY (rol_nuevo_id) REFERENCES Roles(id),
        FOREIGN KEY (usuario_cambio_id) REFERENCES Usuarios(id)
    );
END;
GO
-- ============================================
-- FIX FINAL: Codigo automatico para Usuarios
-- ============================================

IF NOT EXISTS (
    SELECT 1
    FROM sys.default_constraints dc
    JOIN sys.columns c 
        ON dc.parent_object_id = c.object_id 
        AND dc.parent_column_id = c.column_id
    WHERE OBJECT_NAME(dc.parent_object_id) = 'Usuarios'
      AND c.name = 'codigo'
)
BEGIN
    ALTER TABLE Usuarios
    ADD CONSTRAINT DF_Usuarios_Codigo
    DEFAULT ('USR-' + RIGHT(CONVERT(VARCHAR(36), NEWID()), 6))
    FOR codigo;
END;
GO
