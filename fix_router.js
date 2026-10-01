// =============================================================
// ChefUnitPlus - Ajout de TOUTES les routes manquantes
// =============================================================

const fs = require('fs');
const path = require('path');

const routerPath = 'lib/core/routes/app_router.dart';

console.log('');
console.log('===========================================================');
console.log('  ChefUnitPlus - Fix complet des routes');
console.log('===========================================================');
console.log('');

if (!fs.existsSync(routerPath)) {
    console.log('ERREUR : ' + routerPath + ' introuvable');
    console.log('Lancez ce script depuis chefunitplus_v1');
    process.exit(1);
}

// Lire le fichier actuel
let content = fs.readFileSync(routerPath, 'utf8');

console.log('Fichier : ' + routerPath);
console.log('Taille  : ' + content.length + ' caracteres');
console.log('');

// Vérifier quels imports manquent
const importsToAdd = [
    "import '../../views/profile/profile_screen.dart';",
    "import '../../views/profile/edit_profile_screen.dart';",
    "import '../../views/admin/users_management_screen.dart';",
    "import '../../views/admin/promote_director_screen.dart';",
    "import '../../views/admin/global_stats_screen.dart';",
    "import '../../views/admin/payments_log_screen.dart';",
    "import '../../views/admin/system_settings_screen.dart';",
    "import '../../views/director/formation_editor_screen.dart';",
    "import '../../views/director/module_assign_screen.dart';",
    "import '../../views/director/enrollments_validation_screen.dart';",
    "import '../../views/director/trainers_management_screen.dart';",
    "import '../../views/director/formation_stats_screen.dart';",
    "import '../../views/trainer/my_modules_screen.dart';",
    "import '../../views/trainer/module_editor_screen.dart';",
    "import '../../views/trainer/lesson_editor_screen.dart';",
    "import '../../views/trainer/students_list_screen.dart';",
    "import '../../views/learner/formation_catalog_screen.dart';",
    "import '../../views/learner/my_enrollments_screen.dart';",
    "import '../../views/learner/certificate_screen.dart';",
    "import '../../views/payment/payment_screen.dart';",
];

// Trouver la dernière ligne d'import
const lines = content.split('\n');
let lastImportIndex = -1;

for (let i = 0; i < lines.length; i++) {
    if (lines[i].trim().startsWith("import '") && lines[i].includes('.dart')) {
        lastImportIndex = i;
    }
}

if (lastImportIndex < 0) {
    console.log('ERREUR : aucun import trouve');
    process.exit(1);
}

// Ajouter les imports manquants
let importsAdded = 0;
for (const imp of importsToAdd) {
    if (!content.includes(imp)) {
        lastImportIndex++;
        lines.splice(lastImportIndex, 0, imp);
        importsAdded++;
    }
}

content = lines.join('\n');
console.log('Imports ajoutes : ' + importsAdded);
console.log('');

// =============================================================
// Remplacer tout le switch dans onGenerateRoute
// =============================================================

const newSwitch = `    switch (name) {
      // --- Démarrage ---
      case AppRoutes.splash:
        return _route(const SplashScreen(), settings);
      case AppRoutes.onboarding:
        return _route(const OnboardingScreen(), settings);

      // --- Auth ---
      case AppRoutes.login:
        return _route(const LoginScreen(), settings);
      case AppRoutes.register:
        return _route(const RegisterScreen(), settings);
      case AppRoutes.forgotPassword:
        return _route(const ForgotPasswordScreen(), settings);

      // --- Home par rôle ---
      case AppRoutes.adminHome:
      case AppRoutes.directorHome:
      case AppRoutes.trainerHome:
      case AppRoutes.learnerHome:
        return _route(const RoleRouter(), settings);

      // --- Profil (commun à tous les rôles) ---
      case AppRoutes.profile:
        return _route(const ProfileScreen(), settings);
      case AppRoutes.editProfile:
        return _route(const EditProfileScreen(), settings);

      // --- Admin ---
      case AppRoutes.adminUsers:
        return _route(const UsersManagementScreen(), settings);
      case AppRoutes.adminPromote:
        return _route(const PromoteDirectorScreen(), settings);
      case AppRoutes.adminStats:
        return _route(const GlobalStatsScreen(), settings);
      case AppRoutes.adminPayments:
        return _route(const PaymentsLogScreen(), settings);
      case AppRoutes.adminSettings:
        return _route(const SystemSettingsScreen(), settings);
      case AppRoutes.adminScoutGroups:
        return _route(const ScoutGroupsScreen(), settings);
      case AppRoutes.adminComplaints:
        return _route(const ComplaintsScreen(), settings);
      case AppRoutes.adminPasswordRequests:
        return _route(const PasswordRequestsScreen(), settings);

      // --- Directeur ---
      case AppRoutes.directorFormationEditor:
        return _route(const FormationEditorScreen(), settings);
      case AppRoutes.directorModuleAssign:
        return _route(const ModuleAssignScreen(), settings);
      case AppRoutes.directorEnrollments:
        return _route(const EnrollmentsValidationScreen(), settings);
      case AppRoutes.directorTrainers:
        return _route(const TrainersManagementScreen(), settings);
      case AppRoutes.directorStats:
        return _route(const FormationStatsScreen(), settings);

      // --- Formateur ---
      case AppRoutes.trainerModules:
        return _route(const MyModulesScreen(), settings);
      case AppRoutes.trainerModuleEditor:
        return _route(const ModuleEditorScreen(), settings);
      case AppRoutes.trainerLessonEditor:
        return _route(const LessonEditorScreen(), settings);
      case AppRoutes.trainerStudents:
        return _route(const StudentsListScreen(), settings);

      // --- Apprenant ---
      case AppRoutes.learnerCatalog:
        return _route(const FormationCatalogScreen(), settings);
      case AppRoutes.learnerMyEnrollments:
        return _route(const MyEnrollmentsScreen(), settings);
      case AppRoutes.learnerCertificates:
        return _route(const CertificateScreen(), settings);

      // --- Paiement ---
      case AppRoutes.payment:
        return _route(const PaymentScreen(), settings);

      default:
        return _unknownRoute(settings);
    }`;

// Trouver et remplacer le switch
const switchStart = content.indexOf('    switch (name) {');
if (switchStart < 0) {
    console.log('ERREUR : switch non trouve dans onGenerateRoute');
    process.exit(1);
}

// Trouver la fin du switch (le prochain "  }" après le switch)
// On cherche la fermeture du switch
let braceCount = 0;
let switchEnd = -1;
let started = false;

for (let i = switchStart; i < content.length; i++) {
    const c = content[i];
    if (c === '{') {
        braceCount++;
        started = true;
    } else if (c === '}') {
        braceCount--;
        if (started && braceCount === 0) {
            switchEnd = i;
            break;
        }
    }
}

if (switchEnd < 0) {
    console.log('ERREUR : fin du switch non trouvee');
    process.exit(1);
}

// Remplacer
content = content.substring(0, switchStart) + newSwitch + content.substring(switchEnd + 1);

// =============================================================
// Sauvegarder
// =============================================================
fs.writeFileSync(routerPath, content, 'utf8');

console.log('Router mis a jour !');
console.log('');

// Vérifier
console.log('Verification...');
const verifyContent = fs.readFileSync(routerPath, 'utf8');
const routesToCheck = [
    { name: 'profile', pattern: 'case AppRoutes.profile:' },
    { name: 'editProfile', pattern: 'case AppRoutes.editProfile:' },
    { name: 'adminUsers', pattern: 'case AppRoutes.adminUsers:' },
    { name: 'directorFormationEditor', pattern: 'case AppRoutes.directorFormationEditor:' },
    { name: 'trainerModules', pattern: 'case AppRoutes.trainerModules:' },
    { name: 'learnerCatalog', pattern: 'case AppRoutes.learnerCatalog:' },
    { name: 'payment', pattern: 'case AppRoutes.payment:' },
];

let allOk = true;
for (const r of routesToCheck) {
    if (verifyContent.includes(r.pattern)) {
        console.log('  [OK] ' + r.name);
    } else {
        console.log('  [X] ' + r.name + ' MANQUANT');
        allOk = false;
    }
}

console.log('');
if (allOk) {
    console.log('===========================================================');
    console.log('  TOUTES LES ROUTES SONT AJOUTEES !');
    console.log('===========================================================');
    console.log('');
    console.log('Prochaines etapes :');
    console.log('  1. flutter analyze');
    console.log('  2. flutter run -d chrome');
    console.log('  3. Testez : clic sur icone profil -> page profil');
    console.log('');
} else {
    console.log('Certaines routes manquent encore.');
}