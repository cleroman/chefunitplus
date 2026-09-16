// =============================================================
// ChefUnitPlus - Fix icones + import inutilise
// =============================================================

const fs = require('fs');
const path = require('path');

const BASE = process.cwd();

console.log('');
console.log('===========================================================');
console.log('  ChefUnitPlus - Fix icones');
console.log('===========================================================');
console.log('');

// =============================================================
// FIX 1 - Retirer l'import inutilise dans app_router.dart
// =============================================================
const routerPath = path.join(BASE, 'lib/core/routes/app_router.dart');
if (fs.existsSync(routerPath)) {
    let content = fs.readFileSync(routerPath, 'utf8');
    const original = content;

    // Retirer la ligne d'import user_details_screen
    content = content.replace(
        /import '\.\.\/\.\.\/views\/admin\/user_details_screen\.dart';\r?\n/g,
        ''
    );

    if (content !== original) {
        fs.writeFileSync(routerPath, content, 'utf8');
        console.log('  [FIX] app_router.dart : import user_details retire');
    } else {
        console.log('  [OK]  app_router.dart : deja propre');
    }
} else {
    console.log('  [X]   app_router.dart introuvable');
}

// =============================================================
// FIX 2 - Remplacer les icones inexistantes dans register_screen.dart
// =============================================================
const registerPath = path.join(BASE, 'lib/views/auth/register_screen.dart');
if (fs.existsSync(registerPath)) {
    let content = fs.readFileSync(registerPath, 'utf8');
    const original = content;
    let fixes = 0;

    // Icons.tree_outlined -> Icons.park_outlined
    if (content.includes('Icons.tree_outlined')) {
        content = content.split('Icons.tree_outlined').join('Icons.park_outlined');
        fixes++;
        console.log('  [FIX] Icons.tree_outlined -> Icons.park_outlined');
    }

    // Icons.camping -> Icons.outdoor_grill
    if (content.includes('Icons.camping')) {
        content = content.split('Icons.camping').join('Icons.outdoor_grill');
        fixes++;
        console.log('  [FIX] Icons.camping -> Icons.outdoor_grill');
    }

    // Corriger la concatenation de strings avec interpolation
    // 'Inscription (' + (_currentStep + 1).toString() + '/7)' -> 'Inscription (${_currentStep + 1}/7)'
    content = content.replace(
        /'Inscription \(' \+ \(_currentStep \+ 1\)\.toString\(\) \+ '\/7\)'/g,
        "'Inscription (\\${_currentStep + 1}/7)'"
    );

    // 'Ajouter un contact (' + _data.emergencyContacts.length.toString() + '/2 min)'
    content = content.replace(
        /'Ajouter un contact \(' \+\s*_data\.emergencyContacts\.length\.toString\(\) \+\s*'\/2 min\)'/g,
        "'Ajouter un contact (\\${_data.emergencyContacts.length}/2 min)'"
    );

    if (content !== original) {
        fs.writeFileSync(registerPath, content, 'utf8');
        console.log('  [FIX] register_screen.dart : ' + fixes + ' icone(s) + interpolations corrigees');
    } else {
        console.log('  [OK]  register_screen.dart : deja propre');
    }
} else {
    console.log('  [X]   register_screen.dart introuvable');
}

console.log('');
console.log('===========================================================');
console.log('  FIX TERMINE !');
console.log('===========================================================');
console.log('');
console.log('Etape suivante : flutter analyze');
console.log('');