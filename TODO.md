@@ -1,13 +1,12 @@
-- [x] Create lib/widgets/app_drawer.dart with Drawer widget including header and menu options
-- [x] Create lib/screens/participantes_activos_screen.dart for listing unique participants with sales
-- [x] Update lib/router.dart to add route for /participantes_activos
-- [x] Add drawer to lib/screens/home_screen.dart
-- [x] Add drawer to lib/screens/activity_details_screen.dart
-- [x] Add drawer and AppBar to lib/screens/caja_screen.dart
-- [x] Add drawer to lib/screens/inversiones_screen.dart
-- [x] Add drawer to lib/screens/reportes_screen.dart
-- [x] Change navigation in selector screens from named routes to MaterialPageRoute
-- [x] Add missing imports for screen classes in selector screens
-- [x] Add new routes to router.dart for reportes_generales
-- [x] Add new menu item "Reportes Generales" to app_drawer.dart
-- [x] Test app build and run successfully
+# TODO: Fix Login Issues
+
+## Steps to Complete
+- [ ] Add detailed logging to _login method in login_screen.dart
+- [ ] Trim email and password in signIn call in login_screen.dart
+- [ ] Update error message in catch to include actual error
+- [ ] Change setPersistence in auth_service.dart to use SESSION instead of NONE
+- [ ] Test login functionality and check console logs for errors
+
+## Progress Tracking
+- [x] Analyze code and gather information
+- [x] Create plan and TODO.md