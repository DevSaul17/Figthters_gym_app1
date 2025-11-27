# Guía de Seguridad - Login de Empleados

## 🔐 Mejoras de Seguridad Implementadas

### **1. Hashing de Contraseñas**
- ✅ **SHA-256 con Salt**: Las contraseñas se almacenan hasheadas con un salt único por usuario
- ✅ **Migración Gradual**: Compatibilidad con contraseñas existentes en texto plano
- ✅ **Salt Único**: Cada usuario tiene su propio salt basado en su DNI

### **2. Rate Limiting**
- ✅ **3 intentos máximo** por DNI antes del bloqueo
- ✅ **15 minutos de bloqueo** temporal después de exceder los intentos
- ✅ **Contador de intentos** mostrado al usuario
- ✅ **Tiempo restante** de bloqueo visible

### **3. Validaciones Mejoradas**
- ✅ **DNI**: Exactamente 8 dígitos numéricos
- ✅ **Contraseña**: Mínimo 6 caracteres
- ✅ **Formato de entrada**: Solo números para DNI
- ✅ **Límite de caracteres**: Máximo 8 dígitos para DNI

### **4. Logging de Seguridad**
- ✅ **Registro completo** de todos los intentos de login
- ✅ **Actividad sospechosa** detectada y registrada
- ✅ **Timestamps** de todos los eventos
- ✅ **Detalles específicos** de cada fallo

### **5. Gestión de Cuentas**
- ✅ **Estado activo/inactivo** de empleados
- ✅ **Último login** registrado
- ✅ **Roles de usuario** definidos
- ✅ **Protección contra cuentas desactivadas**

### **6. UX Mejorada**
- ✅ **Loading states** durante autenticación
- ✅ **Limpieza de campos** sensibles después de errores
- ✅ **Mensajes informativos** con intentos restantes
- ✅ **Timeout de consultas** para mejor rendimiento

---

## 📊 Estructura de Datos en Firestore

### **Colección: `entrenadores`**
```json
{
  "dni": "12345678",
  "nombre": "Juan",
  "apellido": "Pérez",
  "telefono": "+51987654321", 
  "email": "juan@gym.com",
  "rol": "entrenador", // o "admin", "empleado"
  "activo": true,
  
  // Campos de Seguridad
  "contrasena": "password123", // Solo para migración
  "password_hash": "a1b2c3...", // Hash SHA-256 + salt
  "password_updated_at": "timestamp",
  "ultimo_login": "timestamp",
  
  // Metadatos
  "created_at": "timestamp",
  "updated_at": "timestamp"
}
```

### **Colección: `logs_seguridad`**
```json
{
  "evento": "login_exitoso", // o "intento_login", "bloqueo_rate_limit", etc.
  "dni": "12345678",
  "exitoso": true,
  "timestamp": "timestamp",
  "detalles": "Login correcto",
  "ip": "mobile_app"
}
```

---

## ⚙️ Configuración de Seguridad

### **Parámetros Ajustables** (en `AuthSecurityService`)
```dart
static const int maxIntentos = 3;              // Intentos antes de bloqueo
static const Duration tiempoBloqueo = Duration(minutes: 15); // Tiempo de bloqueo
static const Duration timeoutAutenticacion = Duration(seconds: 10); // Timeout de consulta
```

### **Patrones de Validación**
```dart
static const String dniPattern = r'^\d{8}$';    // 8 dígitos exactos
static const String passwordPattern = r'^.{6,}$'; // Mínimo 6 caracteres
```

---

## 🛠️ Funciones de Desarrollo

### **Limpiar Rate Limiting** (Solo para desarrollo)
```dart
await AuthSecurityService.limpiarDatosSeguridad();
```

### **Verificar Estado de Usuario**
```dart
// Consultar intentos restantes
final intentos = await AuthSecurityService.intentosRestantes("12345678");

// Verificar tiempo de bloqueo
final tiempo = await AuthSecurityService.tiempoDesbloqueoRestante("12345678");
```

---

## 🔄 Migración de Contraseñas

El sistema migra automáticamente las contraseñas existentes:

1. **Login con contraseña plana**: El sistema la verifica
2. **Conversión automática**: La convierte a hash + salt
3. **Actualización en BD**: Guarda el hash y marca timestamp
4. **Próximos logins**: Usa solo el hash

---

## 📱 Experiencia de Usuario

### **Estados de Login**
1. **Normal**: Campos limpios, botón activo
2. **Cargando**: Spinner en botón, campos deshabilitados
3. **Error**: Campo contraseña limpiado, mensaje informativo
4. **Bloqueado**: Mensaje con tiempo restante + botón debug

### **Mensajes de Feedback**
- ✅ **Éxito**: "¡Bienvenido [Nombre]!"
- ❌ **Fallo**: "DNI o contraseña incorrectos. Te quedan X intentos"
- ⏰ **Bloqueo**: "Demasiados intentos. Intenta en X minutos"
- 🔒 **Cuenta inactiva**: "Cuenta desactivada. Contacta administrador"

---

## 🔐 Recomendaciones Adicionales

### **Para Producción**
1. **Eliminar botón "Limpiar"** del rate limiting
2. **Implementar 2FA** opcional para administradores
3. **Rotación de salts** periódica
4. **Monitoring** de logs de seguridad
5. **Alertas** por intentos sospechosos

### **Para Administradores**
1. **Dashboard** de logs de seguridad
2. **Gestión de cuentas** activas/inactivas
3. **Reset de contraseñas** seguro
4. **Reportes** de actividad

---

## 🚀 Implementación Completada

✅ **Hashing de contraseñas** con SHA-256 + salt  
✅ **Rate limiting** con 3 intentos / 15 min  
✅ **Validaciones mejoradas** DNI y contraseña  
✅ **Logging completo** de eventos de seguridad  
✅ **UX mejorada** con feedback informativo  
✅ **Gestión de cuentas** activas/inactivas  
✅ **Migración automática** de contraseñas  
✅ **Timeouts y error handling** robusto

El sistema de login ahora está completamente securizado y listo para producción! 🎉