# Blueprint: App de Gestión de Eventos (Choripanes)

## 1. Resumen de la Aplicación

Esta es una aplicación Flutter diseñada para gestionar la logística y las finanzas de eventos o actividades de recaudación de fondos, como la venta de choripanes. Permite a los organizadores hacer un seguimiento de los participantes, sus metas de venta, los productos entregados y los pagos recibidos, todo ello sincronizado en tiempo real a través de Firebase.

---

## 2. Arquitectura Actual (Versión con Firebase)

La aplicación ha sido migrada a Firebase, utilizando Cloud Firestore como base de datos principal para la persistencia y sincronización de datos en tiempo real.

### 2.1. Estructura del Proyecto

-   **`lib/main.dart`**: Punto de entrada de la aplicación. Inicializa Firebase y define la navegación inicial.
-   **`lib/models/`**: Contiene las clases del modelo de datos (`actividad.dart`, `participante.dart`, `venta.dart`), que representan la estructura de la información en Firestore.
-   **`lib/screens/`**: Alberga todas las pantallas de la interfaz de usuario, como:
    -   `bienvenida_screen.dart`: Pantalla de bienvenida y para la creación de actividades.
    -   `home_screen.dart`: Muestra la lista de participantes y un resumen general.
    -   `login_screen.dart`: Pantalla de inicio de sesión (actualmente con una implementación ficticia).
    -   `reportes_screen.dart`: Muestra el ranking de ventas y deudas.
-   **`lib/services/`**: Incluye la lógica de negocio y la comunicación con servicios externos.
    -   `firebase_service.dart`: Centraliza todas las operaciones de lectura y escritura con Cloud Firestore.

### 2.2. Flujo de Datos

1.  **Inicio**: `main.dart` inicializa Firebase y muestra una `LoginScreen` básica.
2.  **Login Ficticio**: El usuario ingresa credenciales predefinidas ("admin"/"1234") para acceder a `BienvenidaScreen`.
3.  **Gestión de Actividades**: En `BienvenidaScreen`, el usuario puede crear nuevas actividades y ver una lista de las existentes. Los datos se leen y escriben en la colección `actividades` de Firestore.
4.  **Sincronización en Tiempo Real**: La aplicación utiliza `Stream`s de Firebase para que la lista de actividades se actualice automáticamente.

### 2.3. Dependencias Clave

-   `firebase_core`: Para la inicialización de Firebase.
-   `cloud_firestore`: Para la interacción con la base de datos de Firestore.
-   `intl`: Para el formateo de fechas.

---

## 3. Plan de Implementación de Funcionalidades

Para continuar el desarrollo de la aplicación de forma ordenada, se seguirán los siguientes pasos:

### Paso 1: Gestión Completa de Participantes (CRUD)

**Objetivo**: Implementar la funcionalidad completa para añadir, editar y eliminar participantes directamente desde la aplicación, reflejando los cambios en tiempo real en la `HomeScreen`.

1.  **Crear y Editar Participantes**:
    -   Añadir un botón flotante (`FloatingActionButton`) en la `HomeScreen` para abrir un formulario de creación/edición de participantes.
    -   El formulario permitirá ingresar/modificar el nombre del participante.
    -   Guardar los datos en la colección `participantes` de Firestore a través del `FirebaseService`.
2.  **Eliminar Participantes**:
    -   Añadir una opción para eliminar un participante (por ejemplo, mediante un gesto de deslizamiento en la lista).
    -   Implementar la lógica en `FirebaseService` para borrar el documento correspondiente en Firestore.
3.  **Actualizar la Interfaz en Tiempo Real**:
    -   Asegurar que la `HomeScreen` utilice un `Stream` para escuchar los cambios en la colección `participantes` y se actualice automáticamente.

### Paso 2: Detalle y Gestión de Ventas por Participante

**Objetivo**: Crear una pantalla de detalle para cada participante, donde se puedan registrar las ventas y los pagos, y visualizar el progreso individual.

1.  **Navegación a Pantalla de Detalle**:
    -   Hacer que cada elemento de la lista en `HomeScreen` sea navegable hacia una nueva pantalla (`ActivityDetailsScreen`).
    -   Pasar el ID del participante a la pantalla de detalle.
2.  **Diseño de la Pantalla de Detalle**:
    -   Mostrar el nombre del participante y su meta de ventas.
    -   Incluir un formulario para añadir nuevas ventas (`llevo`) y registrar pagos (`pago_efectivo`, `pago_qr`).
    -   Añadir una barra de progreso que muestre el avance del participante respecto a su meta.
3.  **Lógica de Negocio en `FirebaseService`**:
    -   Crear métodos para añadir/actualizar las ventas en la subcolección correspondiente.
    -   Implementar los cálculos de deuda y total recaudado.

### Paso 3: Pantalla de Reportes y Rankings

**Objetivo**: Dar vida a la `ReportesScreen`, mostrando datos agregados y clasificaciones útiles para la organización.

1.  **Ranking de Ventas**:
    -   Crear una consulta a Firestore que ordene a los participantes por la cantidad de productos vendidos (`llevo`) de mayor a menor.
2.  **Ranking de Deudas**:
    -   Mostrar una lista de los participantes que aún tienen pagos pendientes, ordenada por el monto de la deuda.
3.  **Totales Generales**:
    -   Calcular y mostrar en la parte superior de la pantalla:
        -   El total de productos vendidos por todos los participantes.
        -   El total de dinero recaudado.
        -   El total de deuda pendiente.

### Paso 4: Implementar Autenticación y Reglas de Seguridad

**Objetivo**: Para convertir la app en una solución multiusuario y segura.

1.  **Implementar Firebase Auth**:
    -   Reemplazar la lógica de login ficticia con el SDK de `firebase_auth`.
    -   Permitir el registro e inicio de sesión con Email/Contraseña y/o un proveedor como Google.
2.  **Asociar Datos con Usuarios**:
    -   Al crear una actividad, guardar el UID del usuario que la creó (`ownerId`).
3.  **Implementar Reglas de Seguridad de Firestore**:
    -   Escribir reglas en la Consola de Firebase para que:
        -   Un usuario solo pueda ver las actividades que él ha creado.
        -   Solo el creador de una actividad pueda modificarla o eliminarla.
        -   Solo el creador pueda añadir o editar participantes en su actividad.
