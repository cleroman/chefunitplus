// =============================================================
// ChefUnitPlus - Fix global des accents (Node.js)
// Corrige TOUS les fichiers .dart avec accents casses
// =============================================================

const fs = require('fs');
const path = require('path');

// -------------------------------------------------------------
// Table de correction : toutes les variantes de mojibake connues
// -------------------------------------------------------------
const REPLACEMENTS = [
    // === MOJIBAKE STANDARD (UTF-8 lu en Windows-1252) ===
    ['\u00C3\u00A9', 'é'],
    ['\u00C3\u00A8', 'è'],
    ['\u00C3\u00AA', 'ê'],
    ['\u00C3\u00AB', 'ë'],
    ['\u00C3\u00A0', 'à'],
    ['\u00C3\u00A2', 'â'],
    ['\u00C3\u00AE', 'î'],
    ['\u00C3\u00AF', 'ï'],
    ['\u00C3\u00B4', 'ô'],
    ['\u00C3\u00B6', 'ö'],
    ['\u00C3\u00B9', 'ù'],
    ['\u00C3\u00BB', 'û'],
    ['\u00C3\u00BC', 'ü'],
    ['\u00C3\u00A7', 'ç'],
    ['\u00C3\u0089', 'É'],
    ['\u00C3\u0088', 'È'],
    ['\u00C3\u008A', 'Ê'],
    ['\u00C3\u0080', 'À'],
    ['\u00C3\u0087', 'Ç'],

    // === MOJIBAKE CYRILLIQUE (double/triple encodage) ===
    ['\u0413\u0453\u0412\u0404', 'é'],
    ['\u0413\u0453\u0412\u0401', 'é'],
    ['\u0413\u0453\u0412\u00A9', 'é'],
    ['\u0413\u0453\u0412\u0451', 'è'],
    ['\u0413\u0453\u0412\u0454', 'è'],
    ['\u0413\u0453\u0412\u0405', 'è'],
    ['\u0413\u0453\u0412\u0020', 'à'],
    ['\u0413\u0453\u0412\u0407', 'ç'],

    // === MOJIBAKE AVEC CARACTERE DE REMPLACEMENT ===
    ['\uFFFD\uFFFD', ''],           // \uFFFD\uFFFD → rien (souvent des emojis casses)
    ['\uFFFD', ''],                  // \uFFFD seul → rien

    // === TYPOGRAPHIE ===
    ['\u00E2\u0080\u0099', "'"],      // apostrophe droite
    ['\u00E2\u0080\u0098', "'"],      // apostrophe gauche
    ['\u00E2\u0080\u009C', '"'],      // guillemet gauche
    ['\u00E2\u0080\u009D', '"'],      // guillemet droit
    ['\u00E2\u0080\u00A6', '...'],    // points de suspension
    ['\u00E2\u0080\u0093', '-'],      // tiret en
    ['\u00E2\u0080\u0094', '-'],      // tiret em
    ['\u00E2\u0082\u00AC', 'EUR'],    // euro

    // === ESPACES INSECABLES ===
    ['\u00C2\u00A0', ' '],            // espace insecable
    ['\u00C2', ''],                   // A circonflexe orphelin

    // === EMOJIS COURANTS CASSES ===
    ['\uFFFDx\uFFFD', ''],            // Emoji cassé
    ['\uFFFDx\uFFFDx\uFFFDx', ''],
];

// -------------------------------------------------------------
// Fonction : corriger le texte (applique N passes)
// -------------------------------------------------------------
function fixText(text) {
    let current = text;
    const maxPasses = 8;
    
    for (let i = 0; i < maxPasses; i++) {
        const before = current;
        
        // 1. Appliquer les remplacements directs
        for (const [from, to] of REPLACEMENTS) {
            if (current.includes(from)) {
                current = current.split(from).join(to);
            }
        }
        
        // 2. Essayer le re-decodage latin1 -> utf8
        if (current.includes('\u00C3') || current.includes('\u0413') || current.includes('\uFFFD')) {
            try {
                const fixed = Buffer.from(current, 'latin1').toString('utf8');
                if (fixed !== current && !fixed.includes('\uFFFD\uFFFD\uFFFD')) {
                    current = fixed;
                }
            } catch (e) {
                // ignore
            }
        }
        
        // Si rien n'a change, on arrete
        if (current === before) break;
    }
    
    return current;
}

// -------------------------------------------------------------
// Fonction : detecter si le texte contient encore du mojibake
// -------------------------------------------------------------
function hasMojibake(text) {
    // Patterns de mojibake
    if (text.includes('\u00C3')) return true;      // Ã
    if (text.includes('\u0413\u0453')) return true; // Гѓ
    if (text.includes('\uFFFD\uFFFD')) return true; // 2+ caracteres de remplacement
    
    // \uFFFD seul est tolere (peut etre legitime dans certains cas)
    const fffdCount = (text.match(/\uFFFD/g) || []).length;
    if (fffdCount >= 2) return true;
    
    return false;
}

// -------------------------------------------------------------
// Parcourir recursivement tous les fichiers .dart
// -------------------------------------------------------------
function walk(dir, list) {
    try {
        const items = fs.readdirSync(dir);
        for (const item of items) {
            const full = path.join(dir, item);
            try {
                const stat = fs.statSync(full);
                if (stat.isDirectory()) {
                    walk(full, list);
                } else if (item.endsWith('.dart')) {
                    list.push(full);
                }
            } catch (e) {
                // skip
            }
        }
    } catch (e) {
        console.log('  Erreur sur ' + dir + ' : ' + e.message);
    }
}

// =============================================================
// EXECUTION
// =============================================================
console.log('');
console.log('===========================================================');
console.log('  ChefUnitPlus - Fix global des accents');
console.log('===========================================================');
console.log('');

// Verifier qu'on est au bon endroit
if (!fs.existsSync('lib')) {
    console.log('ERREUR : dossier "lib" introuvable.');
    console.log('Lancez ce script depuis : chefunitplus_v1');
    process.exit(1);
}

// Trouver tous les fichiers Dart
const allFiles = [];
walk('lib', allFiles);

console.log('Fichiers Dart trouves : ' + allFiles.length);
console.log('');

// -------------------------------------------------------------
// Correction
// -------------------------------------------------------------
let fixed = 0;
let skipped = 0;

for (const file of allFiles) {
    const buf = fs.readFileSync(file);
    const original = buf.toString('utf8');
    
    if (!hasMojibake(original)) {
        skipped++;
        continue;
    }
    
    const corrected = fixText(original);
    
    if (corrected !== original) {
        // Ecrire en UTF-8
        fs.writeFileSync(file, corrected, 'utf8');
        fixed++;
        const short = file.replace(/\\/g, '/').replace('lib/', '');
        console.log('  [FIX] ' + short);
    }
}

console.log('');
console.log('Fichiers corriges : ' + fixed);
console.log('Fichiers deja OK   : ' + skipped);
console.log('');

// -------------------------------------------------------------
// Verification finale
// -------------------------------------------------------------
console.log('Verification...');
console.log('');

let stillBad = 0;
const badFiles = [];

for (const file of allFiles) {
    const buf = fs.readFileSync(file);
    const text = buf.toString('utf8');
    
    if (hasMojibake(text)) {
        stillBad++;
        const short = file.replace(/\\/g, '/').replace('lib/', '');
        badFiles.push(short);
    }
}

if (stillBad === 0) {
    console.log('===========================================================');
    console.log('  TOUS LES ACCENTS SONT CORRECTS !');
    console.log('===========================================================');
    console.log('');
    console.log('Prochaines etapes :');
    console.log('  flutter analyze');
    console.log('  flutter run -d chrome');
    console.log('');
} else {
    console.log('Fichiers encore problematiques : ' + stillBad);
    console.log('');
    for (const f of badFiles) {
        console.log('  [!] ' + f);
    }
    console.log('');
}