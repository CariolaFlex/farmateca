# MIGRACIÓN A CUENTAS EMPRESARIALES - FARMATECA

## CONTEXTO

Durante la fase de desarrollo inicial (v0.9.0 - v1.0.0), Farmateca utiliza cuentas de desarrollo **temporales** y **personales** para configurar los servicios de terceros necesarios.

**IMPORTANTE:** Estas cuentas DEBEN ser migradas a cuentas **empresariales** antes del lanzamiento oficial en producción.

---

## CUENTAS ACTUALES (TEMPORALES - DESARROLLO)

### 1. Email principal de desarrollo
- **Email:** `farmateca.soporte@gmail.com`
- **Uso:** Cuenta temporal para desarrollo y pruebas
- **Servicios asociados:**
  - Firebase Console
  - Google Play Console
  - Apple Developer Program
  - RevenueCat
  - GitHub (repositorio privado)

### 2. Git (configuración local)
- **Nombre:** `Farmateca Developer`
- **Email:** `farmateca.soporte@gmail.com`
- **Uso:** Commits durante desarrollo

---

## SERVICIOS QUE REQUIEREN MIGRACIÓN

### Firebase (Google Cloud Platform)
- **Estado actual:** Proyecto `farmateca-app` con cuenta personal
- **A migrar a:** Cuenta Google Workspace de la empresa
- **Pasos:**
  1. Crear organización en Google Cloud Platform
  2. Transferir proyecto Firebase
  3. Actualizar archivos de configuración:
     - `android/app/google-services.json`
     - `ios/Runner/GoogleService-Info.plist`
  4. Actualizar permisos de acceso

### Google Play Console
- **Estado actual:** Cuenta personal de desarrollador
- **A migrar a:** Cuenta de organización de Google Play
- **Pasos:**
  1. Crear cuenta de Google Play para organizaciones ($25 USD único)
  2. Transferir aplicación desde cuenta personal
  3. Configurar estructura de equipo y permisos

### Apple Developer Program
- **Estado actual:** Cuenta individual ($99 USD/año)
- **A migrar a:** Apple Developer Program for Organizations ($99 USD/año)
- **Pasos:**
  1. Registrar organización en Apple Developer
  2. Migrar certificados y provisioning profiles
  3. Actualizar Bundle ID y entitlements
  4. Re-firmar aplicación con nuevos certificados

### RevenueCat (Suscripciones)
- **Estado actual:** Cuenta gratuita con email personal
- **A migrar a:** Cuenta empresarial
- **Pasos:**
  1. Crear nueva cuenta con email corporativo
  2. Migrar configuración de productos
  3. Actualizar API Keys en `lib/config/app_config.dart`
  4. Probar flujo de compras en sandbox

### Repositorio Git/GitHub
- **Estado actual:** Repositorio privado asociado a cuenta personal
- **A migrar a:** Organización empresarial en GitHub
- **Pasos:**
  1. Crear organización en GitHub
  2. Transferir repositorio a la organización
  3. Configurar equipos y permisos
  4. Actualizar configuración de CI/CD si aplica

---

## ARCHIVOS QUE NECESITAN ACTUALIZACIÓN

### Archivos de configuración Firebase
```
android/app/google-services.json
ios/Runner/GoogleService-Info.plist
```
**Acción:** Descargar nuevos archivos desde Firebase Console con cuenta empresarial

### Archivo de configuración principal
```
lib/config/app_config.dart
```
**Campos a actualizar:**
- `supportEmail` → Email corporativo
- `firebaseProjectId` → ID del nuevo proyecto
- `revenueCatApiKey` → Nueva API key
- `websiteUrl` → Sitio web oficial
- `privacyPolicyUrl` → URL de política de privacidad
- `termsUrl` → URL de términos y condiciones

### Git config (global)
```bash
git config --global user.name "Nombre Empresa o Equipo"
git config --global user.email "dev@empresareal.com"
```

### Archivos de certificados iOS
```
ios/Runner.xcodeproj/project.pbxproj
ios/Runner/Info.plist
```
**Acción:** Actualizar Team ID y Bundle ID con certificados empresariales

---

## ORDEN RECOMENDADO DE MIGRACIÓN

### FASE 1: Infraestructura básica
1. Crear cuentas empresariales (Google Workspace, Apple Developer)
2. Transferir proyecto Firebase
3. Actualizar archivos de configuración de Firebase

### FASE 2: Tiendas de aplicaciones
1. Crear cuentas en Google Play Console y App Store Connect
2. Configurar estructura de equipo
3. Preparar assets para publicación (íconos, screenshots, etc.)

### FASE 3: Monetización
1. Configurar RevenueCat con cuenta empresarial
2. Actualizar productos y precios
3. Probar flujo completo de suscripciones

### FASE 4: Legal y contenido
1. Crear política de privacidad
2. Crear términos y condiciones
3. Configurar sitio web o landing page

### FASE 5: Código y despliegue
1. Actualizar `app_config.dart`
2. Re-firmar aplicación con certificados empresariales
3. Crear build de producción
4. Subir a stores para revisión

---

## CHECKLIST FINAL ANTES DE PRODUCCIÓN

- [ ] Firebase migrado a cuenta empresarial
- [ ] Google Play Console configurado
- [ ] Apple Developer Program configurado
- [ ] RevenueCat con API keys de producción
- [ ] Política de privacidad publicada
- [ ] Términos y condiciones publicados
- [ ] Sitio web oficial activo
- [ ] Email de soporte corporativo activo
- [ ] app_config.dart actualizado con valores de producción
- [ ] Certificados de firma actualizados
- [ ] Build de producción generado y probado
- [ ] Analytics y crash reporting configurados
- [ ] Repositorio transferido a organización

---

## NOTAS IMPORTANTES

### Sobre cuentas gratuitas vs. pagadas
- **Firebase:** Tier gratuito suficiente para inicio (Spark Plan)
- **RevenueCat:** Tier gratuito hasta $2,500 USD/mes en ingresos
- **GitHub:** Repositorios privados gratuitos en organizaciones
- **Google Play:** Pago único de $25 USD
- **Apple Developer:** Pago anual de $99 USD

### Backup de configuración actual
Antes de migrar, hacer backup de:
```
android/app/google-services.json
ios/Runner/GoogleService-Info.plist
lib/config/app_config.dart
```

### Testing después de migración
Probar completamente:
- Autenticación con Firebase
- Base de datos local (SQLite)
- Búsqueda y navegación
- Modo offline
- Flujo de suscripciones (sandbox)
- Push notifications (si aplica)

---

## CONTACTO DE DESARROLLO

Durante el desarrollo (hasta v1.0.0):
- Email: farmateca.soporte@gmail.com
- Configuración temporal para pruebas

**Este documento debe actualizarse cuando se completen las migraciones.**

---

**Última actualización:** 2024-12-18
**Versión del proyecto:** 0.9.0-beta
**Estado:** DESARROLLO - Cuentas temporales activas
