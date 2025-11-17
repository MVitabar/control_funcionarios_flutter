# Sistema de Actualizaciones Automáticas - Control Funcionarios

Este proyecto implementa un sistema completo de actualizaciones automáticas que verifica nuevas versiones cuando haces commit al repositorio y notifica a los usuarios.

## 🚀 Características

- **Verificación automática de versiones** al iniciar la app
- **Notificaciones de actualización** con diálogo personalizado
- **CI/CD con GitHub Actions** para builds automáticos
- **Releases automáticos** en GitHub con APK descargable
- **Actualizaciones forzadas** para cambios críticos
- **Recordatorios inteligentes** si el usuario pospone la actualización

## 📋 Configuración

### 1. Dependencias Instaladas

Las siguientes dependencias ya están configuradas en `pubspec.yaml`:

```yaml
# App Updates
package_info_plus: ^8.0.3
version: ^3.0.2
url_launcher: ^6.3.1
http: ^1.2.2
```

### 2. GitHub Actions

El workflow `.github/workflows/build_and_deploy.yml` está configurado para:

✅ **Automáticamente** cuando haces push a `main`:
- Ejecutar tests
- Analizar código
- Compilar APK y App Bundle
- Crear release en GitHub con el APK adjunto

✅ **Automáticamente** cuando creas un release:
- Publicar en Google Play Store (requiere configuración adicional)

### 3. Configuración de Secrets (Opcional)

Para publicación automática en Google Play Store:

1. Ve a `Settings > Secrets and variables > Actions` en tu repo GitHub
2. Agrega estos secrets:
   - `GOOGLE_PLAY_SERVICE_ACCOUNT`: JSON de tu cuenta de servicio Google Play
   - `GOOGLE_PLAY_PACKAGE_NAME`: Nombre del paquete de tu app

## 🛠️ Uso

### Verificación Manual

Puedes verificar actualizaciones manualmente desde cualquier pantalla con el mixin:

```dart
// En cualquier State con UpdateCheckerMixin
await checkForUpdatesManually();
```

### Configuración de Versiones

1. **Actualiza `pubspec.yaml`:**
   ```yaml
   version: 1.0.0+1  # versión+múmero de build
   ```

2. **Crea un tag y release en GitHub:**
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```

3. **El workflow automáticamente:**
   - Compilará la nueva versión
   - Creará un release con el APK
   - Los usuarios recibirán la notificación

## 📱 Flujo de Usuario

1. **Usuario abre la app** → Verifica automáticamente si hay actualizaciones
2. **Si hay actualización disponible** → Muestra diálogo con:
   - Versión actual y nueva
   - Notas de la versión
   - Opciones: "Actualizar ahora" o "Más tarde"
3. **Si es actualización forzada** → No permite continuar hasta actualizar
4. **Si elige "Más tarde"** → Recordará en 30 minutos

## 🔧 Personalización

### Cambiar URL del Repositorio

Edita `lib/services/update_service.dart`:

```dart
static const String _versionApiUrl = 'https://api.github.com/repos/TU_USERNAME/TU_REPO/releases/latest';
```

### Actualizaciones Forzadas

Las actualizaciones son forzadas automáticamente cuando cambia la versión major (ej: 1.0.0 → 2.0.0).

### Personalizar Diálogo

Modifica `lib/widgets/update_dialog.dart` para cambiar:
- Colores y textos
- Comportamiento del diálogo
- Acciones adicionales

## 🚀 Despliegue

### Para Activar el Sistema:

1. **Asegúrate de tener las dependencias:**
   ```bash
   flutter pub get
   ```

2. **El sistema ya está implementado en:**
   - `DashboardScreen` (verificación automática al iniciar)
   - `UpdateService` (lógica de verificación)
   - `UpdateDialog` (interfaz de usuario)
   - `UpdateCheckerMixin` (fácil implementación)

3. **Haz tu primer commit:**
   ```bash
   git add .
   git commit -m "feat: implement system update checker"
   git push origin main
   ```

4. **GitHub Actions creará automáticamente:**
   - El APK compilado
   - Un release en GitHub
   - La notificación para usuarios

## 📝 Notas Importantes

- **Solo funciona en Android** para descarga directa (iOS requiere App Store)
- **El APK se descarga desde GitHub releases**
- **Los usuarios deben permitir instalaciones de fuentes desconocidas**
- **Para producción**, considera publicar en Google Play Store

## 🔄 Mantenimiento

- **Actualiza el número de versión** en `pubspec.yaml` para cada release
- **Escribe buenas notas de versión** en los releases de GitHub
- **Monitorea los logs** del workflow para detectar problemas

¡Listo! Tu sistema de actualizaciones automáticas está configurado y funcionando. 🎉
