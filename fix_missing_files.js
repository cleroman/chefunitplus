// =============================================================
// ChefUnitPlus - Cree automatiquement les fichiers manquants
// du router avec des placeholders fonctionnels
// =============================================================

const fs = require('fs');
const path = require('path');

const routerPath = 'lib/core/routes/app_router.dart';

console.log('');
console.log('===========================================================');
console.log('  ChefUnitPlus - Fix fichiers manquants');
console.log('===========================================================');
console.log('');

if (!fs.existsSync(routerPath)) {
    console.log('ERREUR : ' + routerPath + ' introuvable');
    process.exit(1);
}

const content = fs.readFileSync(routerPath, 'utf8');
const lines = content.split('\n');

// -------------------------------------------------------------
// 1. Extraire tous les imports
// -------------------------------------------------------------
const imports = [];
const importRegex = /^import\s+'([^']+\.dart)';/;

for (const line of lines) {
    const m = line.match(importRegex);
    if (m) {
        const importPath = m[1];
        // Ignorer les imports package: et relatifs non-fichiers
        if (importPath.startsWith('package:') || importPath.startsWith('dart:')) continue;
        // Resoudre le chemin relatif depuis lib/core/routes/
        const baseDir = 'lib/core/routes';
        const fullPath = path.normalize(path.join(baseDir, importPath));
        imports.push({
            raw: line.trim(),
            importPath: importPath,
            fullPath: fullPath,
        });
    }
}

console.log('Imports relatifs trouves : ' + imports.length);
console.log('');

// -------------------------------------------------------------
// 2. Verifier quels fichiers existent
// -------------------------------------------------------------
const missing = [];
for (const imp of imports) {
    if (!fs.existsSync(imp.fullPath)) {
        missing.push(imp);
    }
}

console.log('Fichiers MANQUANTS : ' + missing.length);
console.log('');
for (const m of missing) {
    console.log('  [X] ' + m.fullPath);
}
console.log('');

// -------------------------------------------------------------
// 3. Si tout existe, on a fini
// -------------------------------------------------------------
if (missing.length === 0) {
    console.log('===========================================================');
    console.log('  TOUS LES FICHIERS EXISTENT !');
    console.log('===========================================================');
    console.log('');
    process.exit(0);
}

// -------------------------------------------------------------
// 4. Creer les fichiers manquants (placeholders)
// -------------------------------------------------------------
console.log('Creation des fichiers manquants...');
console.log('');

// Extraire le nom de classe depuis le chemin
function classNameFromPath(filePath) {
    const base = path.basename(filePath, '.dart');
    // Convertir snake_case en PascalCase
    return base.split('_').map(w => 
        w.charAt(0).toUpperCase() + w.slice(1)
    ).join('');
}

for (const imp of missing) {
    const fullPath = imp.fullPath;
    const dir = path.dirname(fullPath);
    const className = classNameFromPath(fullPath);
    
    // Creer le dossier si necessaire
    if (!fs.existsSync(dir)) {
        fs.mkdirSync(dir, { recursive: true });
    }
    
    // Contenu du placeholder
    const placeholder = `// =============================================================
// ChefUnitPlus - ${className}
// Ecran temporaire - a remplacer par l'implementation finale
// =============================================================

import 'package:flutter/material.dart';

class ${className} extends StatelessWidget {
  const ${className}({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('${className}'),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.construction, size: 64, color: Colors.orange),
              SizedBox(height: 16),
              Text(
                'Ecran en construction',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Cet ecran sera complete prochainement.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
`;
    
    fs.writeFileSync(fullPath, placeholder, 'utf8');
    console.log('  [+] ' + fullPath + ' (' + className + ')');
}

console.log('');
console.log('===========================================================');
console.log('  FICHIERS CREES : ' + missing.length);
console.log('===========================================================');
console.log('');
console.log('Prochaines etapes :');
console.log('  1. flutter analyze');
console.log('  2. flutter run -d chrome');
console.log('');
console.log('Note : ces fichiers sont des PLACEHOLDERS.');
console.log('Ils fonctionnent mais affichent "Ecran en construction".');
console.log('Vous pourrez les completer au fur et a mesure.');
console.log('');