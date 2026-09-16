// =============================================================
// ChefUnitPlus - Ajoute 'const' automatiquement
// =============================================================

const fs = require('fs');
const { execSync } = require('child_process');

console.log('');
console.log('===========================================================');
console.log('  ChefUnitPlus - Fix prefer_const_constructors');
console.log('===========================================================');
console.log('');

// Utiliser dart fix --apply qui corrige AUTOMATIQUEMENT
console.log('Application de dart fix --apply...');
console.log('');

try {
    const output = execSync('dart fix --apply', { encoding: 'utf8' });
    console.log(output);
} catch (e) {
    console.log('Sortie de dart fix :');
    if (e.stdout) console.log(e.stdout);
    if (e.stderr) console.log(e.stderr);
}

console.log('');
console.log('Analyse finale...');
console.log('');

try {
    const analyze = execSync('flutter analyze', { encoding: 'utf8' });
    console.log(analyze);
} catch (e) {
    // flutter analyze retourne 1 si erreurs
    if (e.stdout) console.log(e.stdout);
    if (e.stderr) console.log(e.stderr);
}

console.log('');
console.log('===========================================================');
console.log('  TERMINE !');
console.log('===========================================================');
console.log('');