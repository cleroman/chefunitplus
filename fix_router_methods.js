// =============================================================
// ChefUnitPlus - Ajoute les methodes manquantes dans AppRouter
// =============================================================

const fs = require('fs');

const routerPath = 'lib/core/routes/app_router.dart';

console.log('');
console.log('===========================================================');
console.log('  ChefUnitPlus - Fix methodes AppRouter');
console.log('===========================================================');
console.log('');

if (!fs.existsSync(routerPath)) {
    console.log('ERREUR : ' + routerPath + ' introuvable');
    process.exit(1);
}

let content = fs.readFileSync(routerPath, 'utf8');

console.log('Fichier : ' + routerPath);
console.log('');

// -------------------------------------------------------------
// 1. Verifier quels helpers existent
// -------------------------------------------------------------
const hasUnknownRoute = content.includes('_unknownRoute(') && content.includes('static Route<dynamic> _unknownRoute');
const hasRoute = content.includes('static MaterialPageRoute _route');
const hasHomeRouteName = content.includes('static String homeRouteName');
const hasHomeFor = content.includes('static Widget homeFor');

console.log('Methodes existantes :');
console.log('  _route           : ' + (hasRoute ? 'OUI' : 'NON'));
console.log('  _unknownRoute    : ' + (hasUnknownRoute ? 'OUI' : 'NON'));
console.log('  homeRouteName    : ' + (hasHomeRouteName ? 'OUI' : 'NON'));
console.log('  homeFor          : ' + (hasHomeFor ? 'OUI' : 'NON'));
console.log('');

// -------------------------------------------------------------
// 2. Preparer les methodes a ajouter
// -------------------------------------------------------------
let methodsToAdd = '';

if (!hasRoute) {
    methodsToAdd += `
  // ===========================================================
  // HELPER : cree une MaterialPageRoute
  // ===========================================================
  static MaterialPageRoute _route(Widget screen, RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => screen,
      settings: settings,
    );
  }
`;
}

if (!hasUnknownRoute) {
    methodsToAdd += `
  // ===========================================================
  // HELPER : page d'erreur "route inconnue"
  // ===========================================================
  static Route<dynamic> _unknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: const Text('Page introuvable'),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 80,
                  color: Colors.red,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Route inconnue',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  settings.name ?? 'inconnue',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      settings: settings,
    );
  }
`;
}

if (!hasHomeFor) {
    methodsToAdd += `
  // ===========================================================
  // HELPER : widget home selon le role
  // ===========================================================
  static Widget homeFor(User user) {
    return const RoleRouter();
  }
`;
}

if (!hasHomeRouteName) {
    methodsToAdd += `
  // ===========================================================
  // HELPER : route home selon le role
  // ===========================================================
  static String homeRouteName(User user) {
    switch (user.role) {
      case UserRole.admin:
        return AppRoutes.adminHome;
      case UserRole.directeur:
        return AppRoutes.directorHome;
      case UserRole.formateur:
        return AppRoutes.trainerHome;
      case UserRole.apprenant:
        return AppRoutes.learnerHome;
    }
  }
`;
}

if (methodsToAdd === '') {
    console.log('===========================================================');
    console.log('  TOUTES LES METHODES EXISTENT DEJA !');
    console.log('===========================================================');
    console.log('');
    process.exit(0);
}

// -------------------------------------------------------------
// 3. Trouver la position pour inserer (avant la derniere })
// -------------------------------------------------------------
const lastBrace = content.lastIndexOf('}');

if (lastBrace < 0) {
    console.log('ERREUR : accolade finale non trouvee');
    process.exit(1);
}

// Inserer avant la derniere accolade
content = content.substring(0, lastBrace) + methodsToAdd + '\n}\n' + content.substring(lastBrace + 1);

// -------------------------------------------------------------
// 4. S'assurer que les imports necessaires sont presents
// -------------------------------------------------------------
const requiredImports = [
    { check: 'RoleRouter', import: "import '../../views/common/role_router.dart';" },
    { check: 'UserRole', import: "import '../constants/role_constants.dart';" },
];

const lines = content.split('\n');
let lastImportIndex = -1;
for (let i = 0; i < lines.length; i++) {
    if (lines[i].trim().startsWith("import '")) {
        lastImportIndex = i;
    }
}

for (const req of requiredImports) {
    if (content.includes(req.check) && !content.includes(req.import)) {
        lastImportIndex++;
        lines.splice(lastImportIndex, 0, req.import);
        console.log('  [+] Import ajoute : ' + req.import);
    }
}

content = lines.join('\n');

// -------------------------------------------------------------
// 5. Ecrire
// -------------------------------------------------------------
fs.writeFileSync(routerPath, content, 'utf8');

console.log('Methodes ajoutees avec succes !');
console.log('');

// Verification
const verify = fs.readFileSync(routerPath, 'utf8');
console.log('Verification :');
console.log('  _route        : ' + (verify.includes('static MaterialPageRoute _route') ? 'OK' : 'MANQUANT'));
console.log('  _unknownRoute : ' + (verify.includes('static Route<dynamic> _unknownRoute') ? 'OK' : 'MANQUANT'));
console.log('  homeFor       : ' + (verify.includes('static Widget homeFor') ? 'OK' : 'MANQUANT'));
console.log('  homeRouteName : ' + (verify.includes('static String homeRouteName') ? 'OK' : 'MANQUANT'));
console.log('');
console.log('===========================================================');
console.log('  TERMINE !');
console.log('===========================================================');
console.log('');
console.log('Prochaines etapes :');
console.log('  flutter analyze');
console.log('  flutter run -d chrome');
console.log('');