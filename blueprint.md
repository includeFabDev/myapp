# Blueprint: App de Gestión de Eventos (Choripanes)

## 1. Resumen de la Aplicación

Esta es una aplicación Flutter diseñada para gestionar la logística y las finanzas de eventos o actividades de recaudación de fondos, como la venta de choripanes. Permite a los organizadores hacer un seguimiento de los participantes, sus metas de venta, los productos entregados y los pagos recibidos, todo ello sincronizado en tiempo real a través de Firebase.

---

## 2. Arquitectura y Funcionalidades Implementadas

La aplicación utiliza Firebase (Cloud Firestore) como backend, lo que permite la persistencia y sincronización de datos en tiempo real.

### 2.1. Estructura del Proyecto

-   **`lib/models/`**: Contiene los modelos de datos (`actividad.dart`, `participante.dart`, `gasto.dart`).
-   **`lib/screens/`**: Alberga las pantallas de la UI, incluyendo `bienvenida_screen.dart`, `activity_details_screen.dart`, `inversiones_screen.dart` y `reportes_screen.dart`.
-   **`lib/services/`**: Centraliza la comunicación con Cloud Firestore en `firebase_service.dart`.

### 2.2. Flujo de Datos y Características Principales

1.  **Gestión de Actividades**: Los usuarios pueden crear, ver y eliminar actividades.
2.  **Gestión de Participantes**: Dentro de cada actividad, se pueden añadir, editar y eliminar participantes.
3.  **Registro de Ventas y Pagos**: Se puede registrar la cantidad de productos vendidos y los pagos recibidos (en efectivo y por QR).
4.  **Gestión de Inversiones**: Permite registrar y visualizar todos los gastos asociados a una actividad.
5.  **Reportes en Tiempo Real**: La app cuenta con una pantalla de reportes que consolida toda la información y presenta:
    -   Un **Resumen Financiero** con ingresos, inversión y ganancia neta.
    -   Un **Gráfico de Distribución de Ingresos** (Efectivo vs. QR).
    -   Un **Ranking de Ventas** para identificar a los mejores vendedores.
    -   Una **Lista de Deudores** para facilitar el seguimiento de los pagos pendientes.

---

## 3. Plan de Desarrollo y Funcionalidades Futuras

### ✅ **Paso 1: Reportes Avanzados (¡Completado!)**

**Objetivo**: Ofrecer una visión financiera completa y visual de la actividad.

-   **Implementación**:
    1.  Se reestructuró `reportes_screen.dart` para que cargue los datos de participantes y gastos en tiempo real.
    2.  Se añadió una tarjeta de **Resumen Financiero** que muestra Ingresos Totales, Inversión Total y Ganancia Neta.
    3.  **¡Nuevo!** Se incorporó un **Gráfico de Pie (PieChart)** en una nueva tarjeta que visualiza la distribución de ingresos (Efectivo vs. QR), con una leyenda clara que muestra los montos de cada uno.
    4.  Se mejoró el modelo `Participante` con un getter `pagos` para simplificar el código.
    5.  Se corrigieron errores y se aseguró la funcionalidad de eliminación de participantes.

### ⏳ **Paso 2: Implementar Módulo de "Control de Caja" (En Progreso)**

**Objetivo**: Crear un sistema de contabilidad general para registrar todos los ingresos y egresos del grupo, llevando un saldo total y un historial de movimientos.

-   **Plan**:
    1.  **Modelo de Datos (`movimiento_caja.dart`)**:
        -   Crear el modelo `MovimientoCaja` con los campos: `id`, `tipo` ('ingreso' | 'egreso'), `monto`, `descripcion`, `fecha`, `relacion_actividad` (opcional), y `saldo_resultante`.
    2.  **Servicios de Firebase (`firebase_service.dart`)**:
        -   Implementar el método `addMovimientoCaja` que, de forma transaccional, obtenga el último saldo, calcule el nuevo `saldo_resultante` y guarde el movimiento.
        -   Crear `getMovimientosCajaStream` para obtener un `Stream` de todos los movimientos ordenados por fecha.
        -   Crear `getSaldoCajaStream` para obtener un `Stream` con el saldo total actual.
    3.  **UI - Pantalla de Caja (`caja_screen.dart`)**:
        -   Diseñar una nueva pantalla que muestre:
            -   El saldo total en un lugar visible.
            -   Una lista con el historial de movimientos.
            -   Botones flotantes para registrar nuevos ingresos y egresos.
        -   Crear un formulario (en un diálogo o nueva pantalla) para añadir/editar movimientos.
    4.  **Integración y Navegación**:
        -   Añadir un `BottomNavigationBar` en la pantalla principal.
        -   Integrar la "Lista de Actividades" (`bienvenida_screen.dart`) y el "Control de Caja" (`caja_screen.dart`) como las dos pestañas principales de la aplicación.

### Paso 3: Implementar un Sistema de Autenticación Real

**Objetivo**: Aumentar la seguridad de la app y prepararla para un uso real con múltiples usuarios.

-   **Plan**:
    1.  Reemplazar el login ficticio actual con **Firebase Authentication**.
    2.  Implementar un flujo de registro e inicio de sesión con correo y contraseña.
    3.  Asociar cada actividad creada al `UID` del usuario que la creó.
    4.  Definir **Reglas de Seguridad en Firestore** para que un usuario solo pueda ver y modificar sus propias actividades.

### Paso 4: Mejorar la Experiencia de Usuario (UX)

**Objetivo**: Agilizar los flujos de trabajo más comunes, como el registro de ventas.

-   **Plan**:
    1.  En el diálogo de edición de ventas, añadir **botones de acción rápida** (ej: `+1`, `+5`, `-1`) para modificar la cantidad vendida sin necesidad de teclear.
    2.  Revisar y pulir el diseño de las tarjetas y los diálogos para una apariencia más moderna y limpia.
