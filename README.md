# ReserVa — Flutter Web

Frontend independiente de **ReserVa**, construido en Flutter Web y conectado a la API real de Django REST Framework del restaurante. Interfaz en español, tema oscuro premium con acentos dorados y diseño responsive para escritorio, iPhone y Android.

- **Ubicación del proyecto:** `C:\Users\Deossa\Desktop\reserva_fluter_open`
- **Backend consumido (solo lectura para su inspección):** `C:\Users\Deossa\Desktop\PRUEBA_RESERVA\ReserVa_django`
- **Nombre del paquete:** `reserva_fluter_open`

El proyecto es totalmente independiente: no está dentro de `PRUEBA_RESERVA`, no modifica el backend, sus migraciones, su base de datos ni su repositorio Git.

---

## 1. Funcionalidades

| Módulo | Descripción |
| --- | --- |
| Inicio | Portada premium, accesos rápidos, explicación del flujo y pie de página. |
| Autenticación | Registro e inicio de sesión reales con token DRF (`Authorization: Token <token>`). |
| Sesión | Persistencia segura del token en el navegador, validación del perfil al abrir y cierre de sesión con revocación en el servidor. |
| Carta | Platos reales desde `/menu/api/platos/`, búsqueda, filtro por categoría, precios, stock, destacados e imágenes del backend con placeholder elegante. |
| Reserva | Flujo de 3 pasos: fecha/hora/personas/zona → mesas disponibles reales → notas y confirmación. Permite reservar sin mesa. |
| Mis reservas | Historial real, filtros por estado, detalle, cancelación con confirmación y actualización inmediata. |
| Cuenta | Perfil real del token, rol, estado de la cuenta, actualización de perfil y cierre de sesión. |
| Estados | Carga, vacío, error de red, error HTTP, 401, validaciones y mensajes amigables en español. |
| Responsive | Barra lateral en escritorio y navegación inferior en móvil; grillas y formularios adaptativos. |

**No se inventaron platos, precios, zonas ni disponibilidad.** Todo dato mostrado proviene de la API o se presenta como un estado vacío explícito.

---

## 2. Endpoints verificados en el backend

La implementación se basó en la inspección de solo lectura de rutas, vistas, serializadores y configuración de Django:

| Método | Ruta | Uso |
| --- | --- | --- |
| `POST` | `/api/auth/login/` | Inicio de sesión. Devuelve `{ token, user }`. |
| `POST` | `/api/auth/register/` | Registro con `nombre`, `email`, `password`. Devuelve `{ token, user }`. |
| `POST` | `/api/auth/logout/` | Revoca el token actual (`204`). |
| `GET` | `/api/auth/me/` | Perfil del token (`{ user }`). |
| `GET` | `/menu/api/platos/` | Carta. Filtros `categoria`, `destacado`, `buscar`. |
| `GET` | `/menu/api/zonas/` | Zonas del restaurante. |
| `GET` | `/menu/api/mesas/disponibles/` | Mesas libres por `fecha`, `hora`, `personas` y `zona` opcional. |
| `GET` | `/reservas/api/reservas/mis-reservas/` | Reservas del usuario autenticado; filtro `estado`. |
| `POST` | `/reservas/api/reservas/` | Crea la reserva (`fecha`, `hora`, `cantidad_personas`, `mesa?`, `notas?`). |
| `POST` | `/reservas/api/reservas/{id}/cancelar/` | Cancela una reserva propia. |

Notas del contrato real:

- El backend usa autenticación por **Token**, no `Bearer`.
- La carta y las reservas exigen sesión (permiso global `IsAuthenticated`), por eso la app muestra una invitación a iniciar sesión en lugar de datos falsos.
- El precio de los platos llega como texto (`"65000.00"`) y se normaliza en el cliente.
- La hora llega como `HH:MM:SS` y se muestra como `HH:MM`.
- La reserva se crea siempre en estado `pendiente`; el usuario y el estado los define el backend.
- La fecha y hora son locales del restaurante (`America/Bogota`, `USE_TZ = False`).

---

## 3. Requisitos

- Flutter 3.41.1 / Dart 3.11.0 (o superior compatible).
- Backend Django de ReserVa en ejecución.
- Navegador moderno (Chrome, Edge o Safari).
- Para el backend: su entorno virtual y dependencias ya instaladas.

En este equipo el SDK no está en el `PATH`; se usó:

```powershell
& "C:\Users\Deossa\Desktop\Nueva carpeta\dev\flutter\bin\flutter.bat"
```

---

## 4. Configuración de la API

La URL base se define en tiempo de compilación mediante `--dart-define` y se centraliza en `lib/core/config/app_config.dart`:

```powershell
# Desarrollo local (valor por defecto si no se define nada)
flutter run -d chrome --web-port=5000 --dart-define=API_BASE_URL=http://127.0.0.1:8000

# Producción
flutter build web --release --dart-define=API_BASE_URL=https://api.midominio.com
```

`API_BASE_URL` no debe terminar en `/`. Las rutas de imágenes relativas (`/media/...`) se resuelven contra esa misma base.

### CORS

El backend permite actualmente solo estos orígenes:

```python
CORS_ALLOWED_ORIGINS = [
    "http://localhost:5000",
    "http://127.0.0.1:5000",
]
```

Por eso la app debe ejecutarse en el **puerto 5000** durante el desarrollo local. Para usar otro origen (por ejemplo, acceso desde un teléfono por LAN o un dominio de producción), el responsable del backend debe añadir ese origen a `CORS_ALLOWED_ORIGINS`. **Este proyecto no modificó el backend.**

---

## 5. Ejecución local

### 5.1 Backend

En una terminal, desde el backend existente (sin modificar archivos):

```powershell
Set-Location "C:\Users\Deossa\Desktop\PRUEBA_RESERVA\ReserVa_django"
.\venv\Scripts\python.exe manage.py runserver 127.0.0.1:8000
```

### 5.2 Flutter Web

En otra terminal, desde este proyecto:

```powershell
Set-Location "C:\Users\Deossa\Desktop\reserva_fluter_open"
& "C:\Users\Deossa\Desktop\Nueva carpeta\dev\flutter\bin\flutter.bat" run -d chrome --web-port=5000 --dart-define=API_BASE_URL=http://127.0.0.1:8000
```

Abre `http://localhost:5000`.

### 5.3 Compilar y servir la versión de producción

```powershell
Set-Location "C:\Users\Deossa\Desktop\reserva_fluter_open"
& "C:\Users\Deossa\Desktop\Nueva carpeta\dev\flutter\bin\flutter.bat" build web --release --dart-define=API_BASE_URL=http://127.0.0.1:8000
```

El resultado queda en `build\web`. Para una prueba local puede servirse con cualquier servidor estático, por ejemplo:

```powershell
Set-Location "C:\Users\Deossa\Desktop\reserva_fluter_open\build\web"
& "C:\Users\Deossa\Desktop\PRUEBA_RESERVA\ReserVa_django\venv\Scripts\python.exe" -m http.server 5000 --bind 127.0.0.1
```

> El servidor estático debe hacer fallback de rutas a `index.html` si se despliega con rutas profundas. La app usa `Navigator` con rutas con nombre; al recargar una URL interna en producción se necesita ese fallback.

---

## 6. Probar en iPhone y Android por LAN

1. Conecta la PC y el teléfono a la **misma red Wi-Fi**.
2. Obtén la IP local de la PC:

   ```powershell
   ipconfig
   ```

   Ejemplo: `192.168.1.20`.

3. Ejecuta Flutter escuchando en todas las interfaces (el teléfono carga la app desde la PC):

   ```powershell
   Set-Location "C:\Users\Deossa\Desktop\reserva_fluter_open"
   & "C:\Users\Deossa\Desktop\Nueva carpeta\dev\flutter\bin\flutter.bat" run -d web-server --web-hostname 0.0.0.0 --web-port=5000 --dart-define=API_BASE_URL=http://192.168.1.20:8000
   ```

4. Arranca el backend escuchando en la red local:

   ```powershell
   Set-Location "C:\Users\Deossa\Desktop\PRUEBA_RESERVA\ReserVa_django"
   .\venv\Scripts\python.exe manage.py runserver 0.0.0.0:8000
   ```

5. En el teléfono, abre `http://192.168.1.20:5000` con Safari (iPhone) o Chrome (Android).

**Requisito importante:** el backend debe permitir el origen del teléfono (`http://192.168.1.20:5000`) en `CORS_ALLOWED_ORIGINS`. Sin ese cambio del lado del backend, el navegador bloqueará las llamadas a la API por CORS. También puede ser necesario permitir los puertos 5000 y 8000 en el Firewall de Windows para redes privadas.

---

## 7. Seguridad de la sesión

- Se guarda únicamente el token DRF y los datos públicos del perfil en `localStorage` (vía `shared_preferences`).
- **Nunca** se almacenan contraseñas.
- Los logs de depuración no incluyen tokens, cabeceras ni cuerpos de petición.
- Al recibir un `401`, la sesión local se limpia y se invita a iniciar sesión de nuevo.
- En producción se recomienda servir la app **solo por HTTPS** y restringir CORS al dominio exacto.

---

## 8. Validación ejecutada

Con el SDK completo en la ruta indicada, desde la raíz del proyecto:

```powershell
flutter pub get
flutter analyze
flutter test
flutter build web --release --dart-define=API_BASE_URL=http://127.0.0.1:8000
```

Resultados en la última ejecución:

- `flutter pub get`: correcto.
- `flutter analyze`: **No issues found**.
- `flutter test`: **28 pruebas superadas** (formateadores, validadores, modelos, parseo de respuestas y una prueba de interfaz del login).
- `flutter build web --release`: compilación correcta en `build\web`.

Las pruebas automatizadas no escriben en la base de datos del backend. No se crearon usuarios ni reservas reales durante el desarrollo.

### Verificación en navegador (build de producción)

Se sirvió `build\web` en `http://localhost:5000` contra el backend local en `http://127.0.0.1:8000` y se comprobó:

- Carga inicial correcta, splash retirado al primer frame y cero excepciones de Flutter en consola.
- Navegación de escritorio y pantallas de acceso/registro con campos accesibles.
- Validación local de formularios vacíos en acceso y registro.
- Intento de acceso con credenciales inexistentes: `POST /api/auth/login/` devuelve **401** y la interfaz muestra «Credenciales inválidas.» sin exponer detalles técnicos.
- Invitaciones a iniciar sesión en Carta, Reservar, Mis reservas y Cuenta (la API exige sesión).
- Sin errores de red distintos al 401 esperado.

No se probó un flujo autenticado completo porque la base de datos local del backend está vacía y no se quiso escribir en ella.

---

## 9. Estructura

```text
lib/
  app.dart                     # MaterialApp, localización y providers
  main.dart                    # Arranque y restauración de sesión
  core/
    config/app_config.dart     # URL base, timeouts y resolución de media
    errors/api_exception.dart  # Errores HTTP normalizados
    theme/                     # Paleta y tema premium
    utils/                     # Formateadores, validadores, responsive
  models/                      # User, Dish, Zone, RestaurantTable, Reservation
  routing/                     # Rutas y transiciones
  screens/                     # Inicio, acceso, carta, reserva, reservas, cuenta
  services/                    # Cliente HTTP, auth, menú, reservas, sesión
  state/auth_controller.dart   # Estado de autenticación
  widgets/                     # Shell responsive, tarjetas, ornamentos, estados
assets/fonts/                  # Cormorant Garamond y Manrope empaquetadas
web/                           # Metadatos, manifest, iconos y splash inicial
test/                          # Pruebas unitarias y de widget
```

---

## 10. Limitaciones y pendientes de producción

- **Edición de perfil:** la API verificada no expone un endpoint para editar datos ni cambiar contraseña; la pantalla de cuenta es de solo lectura (con opción de refrescar el perfil).
- **Carta pública:** la API exige autenticación también para la carta; no se muestran platos sin sesión.
- **Confirmación de reservas:** el frontend crea solicitudes; la confirmación/asistencia la gestiona el restaurante. No hay pagos ni recordatorios.
- **CORS y dominio:** falta definir el dominio de producción y actualizar `CORS_ALLOWED_ORIGINS` en el backend.
- **Imágenes:** dependen de que el backend sirva `/media` correctamente; si falla, se muestra un placeholder.
- **Despliegue:** `build/web` requiere un servidor estático con fallback a `index.html` para rutas internas.

---

## 11. Comandos útiles

```powershell
# Análisis estático
& "C:\Users\Deossa\Desktop\Nueva carpeta\dev\flutter\bin\flutter.bat" analyze

# Pruebas
& "C:\Users\Deossa\Desktop\Nueva carpeta\dev\flutter\bin\flutter.bat" test

# Compilación web de producción
& "C:\Users\Deossa\Desktop\Nueva carpeta\dev\flutter\bin\flutter.bat" build web --release --dart-define=API_BASE_URL=https://api.midominio.com
```
