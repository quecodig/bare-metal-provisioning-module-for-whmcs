# Documentación Completa: Hivelocity VPS Snapshots API V2

Esta documentación detalla los endpoints de la API V2 de Hivelocity para la gestión de Snapshots (Instantáneas de Volumen) y Snapshot Schedules (Programaciones de Instantáneas) en servidores VPS.

---

## 1. Gestión de Snapshots (Instantáneas)

### [POST] Crear un VPS Volume Snapshot
Crea una instantánea manual de un volumen de VPS.
- **Endpoint**: `/vps/snapshot`
- **Headers**:
  - `X-API-KEY`: Tu clave de API.
  - `X-Fields` (opcional): Máscara de campos.
- **Request Body (JSON)** (Requerido):
  | Campo | Tipo | Descripción |
  | :--- | :--- | :--- |
  | `facilityCode` | string | **Requerido**. Código del centro de datos (ej: `TPA1`). |
  | `volumeId` | string | **Requerido**. ID único del volumen del VPS. |
  | `name` | string | **Requerido**. Nombre descriptivo para el snapshot. |
  | `clientId` | integer | (Opcional) ID de la cuenta del cliente. |

### [GET] Obtener todos los Snapshots disponibles
Lista todos los snapshots asociados a la cuenta o dispositivo.
- **Endpoint**: `/vps/snapshot`
- **Query Parameters**:
  | Parámetro | Tipo | Descripción |
  | :--- | :--- | :--- |
  | `deviceId` | integer | ID del dispositivo VPS para filtrar. |
  | `facilityCode`| string | Código de la instalación. |
  | `clientId` | integer | ID de la cuenta del cliente. |

### [GET] Obtener Snapshot por ID
Retorna los detalles de un snapshot específico.
- **Endpoint**: `/vps/snapshot/{snapshotId}`
- **Query Parameters**:
  | Parámetro | Tipo | Descripción |
  | :--- | :--- | :--- |
  | `facilityCode`| string | **Requerido**. Código de la instalación. |

### [POST] Restaurar un VPS Volume Snapshot
Inicia el proceso de restauración de un VPS a partir de un snapshot.
- **Endpoint**: `/vps/snapshot/{snapshotId}`
- **Request Body (JSON)** (Requerido):
  | Campo | Tipo | Descripción |
  | :--- | :--- | :--- |
  | `facilityCode` | string | **Requerido**. Código de la instalación. |
  | `clientId` | integer | ID de la cuenta del cliente. |

### [DELETE] Eliminar un VPS Volume Snapshot
Elimina permanentemente un snapshot.
- **Endpoint**: `/vps/snapshot/{snapshotId}`
- **Query Parameters**:
  | Parámetro | Tipo | Descripción |
  | :--- | :--- | :--- |
  | `facilityCode`| string | **Requerido**. Código de la instalación. |

---

## 2. Programaciones (Snapshot Schedules)

### [POST] Crear una Programación (Schedule)
Configura la creación automática de snapshots.
- **Endpoint**: `/vps/snapshotSchedule`
- **Request Body (JSON)** (Requerido):
  | Campo | Tipo | Descripción |
  | :--- | :--- | :--- |
  | `volumeId` | string | **Requerido**. ID del volumen. |
  | `facilityCode` | string | **Requerido**. Código de la instalación. |
  | `intervalType` | string | **Requerido**. Opciones: `DAILY`, `WEEKLY`, `MONTHLY`. |
  | `hour` | integer | **Requerido**. Hora (0-23). |
  | `minute` | integer | **Requerido**. Minuto (0-59). |
  | `timezone` | string | **Requerido**. Formato IANA (ej: `America/New_York`). |
  | `maxSnapshots` | integer | **Requerido**. Cantidad máxima de snapshots a retener. |
  | `weekday` | integer | Requerido para `WEEKLY` (1-7, 1=Lunes). |
  | `day` | integer | Requerido para `MONTHLY` (1-28). |

### [GET] Obtener todas las Programaciones
Lista las programaciones para una instalación o VPS.
- **Endpoint**: `/vps/snapshotSchedule`
- **Query Parameters**:
  | Parámetro | Tipo | Descripción |
  | :--- | :--- | :--- |
  | `deviceId` | integer | ID del dispositivo para filtrar. |
  | `facilityCode`| string | Código de la instalación. |

### [GET] Obtener Programación por ID
Detalles de una programación específica.
- **Endpoint**: `/vps/snapshotSchedule/{snapshotScheduleId}`
- **Query Parameters**:
  | Parámetro | Tipo | Descripción |
  | :--- | :--- | :--- |
  | `facilityCode`| string | **Requerido**. Código de la instalación. |

### [DELETE] Eliminar una Programación
- **Endpoint**: `/vps/snapshotSchedule/{snapshotScheduleId}`
- **Query Parameters**:
  | Parámetro | Tipo | Descripción |
  | :--- | :--- | :--- |
  | `facilityCode`| string | **Requerido**. Código de la instalación. |

---

## 3. Notas Técnicas de Implementación
- Todas las respuestas de éxito para operaciones de escritura (POST/DELETE) suelen retornar un `taskId` para seguimiento asíncrono.
- La autenticación se realiza mediante el header `X-API-KEY`.
- El `volumeId` es crítico y debe obtenerse mediante el detalle del VPS (`/vps/{vpsId}`).
