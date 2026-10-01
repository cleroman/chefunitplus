const fs = require('fs');
const path = require('path');

function fixText(text) {
  let current = text;
  for (let i = 0; i < 6; i++) {
    const hasProblem = current.indexOf('\u00C3') >= 0 || current.indexOf('\u0413') >= 0 || current.indexOf('\uFFFD') >= 0;
    if (!hasProblem) break;
    try {
      const buf = Buffer.from(current, 'latin1');
      const fixed = buf.toString('utf8');
      if (fixed === current) break;
      current = fixed;
    } catch (e) {
      break;
    }
  }
  return current;
}

function walk(dir, list) {
  const items = fs.readdirSync(dir);
  for (const item of items) {
    const full = path.join(dir, item);
    const stat = fs.statSync(full);
    if (stat.isDirectory()) {
      walk(full, list);
    } else if (item.endsWith('.dart')) {
      list.push(full);
    }
  }
}

const allFiles = [];
walk('lib', allFiles);

console.log('Fichiers Dart trouves : ' + allFiles.length);
console.log('');

let fixed = 0;
for (const f of allFiles) {
  const buf = fs.readFileSync(f);
  const original = buf.toString('utf8');
  const corrected = fixText(original);
  if (corrected !== original) {
    fs.writeFileSync(f, corrected, 'utf8');
    console.log('[FIX] ' + f);
    fixed++;
  }
}

console.log('');
console.log('Fichiers corriges : ' + fixed);
console.log('');
console.log('Verification en cours...');
console.log('');

let stillBad = 0;
for (const f of allFiles) {
  const buf = fs.readFileSync(f);
  const text = buf.toString('utf8');
  if (text.indexOf('\u00C3') >= 0 || text.indexOf('\u0413') >= 0 || text.indexOf('\uFFFD') >= 0) {
    console.log('[!] ' + f);
    stillBad++;
  }
}

console.log('');
if (stillBad === 0) {
  console.log('===========================================');
  console.log('  TOUS LES ACCENTS SONT CORRECTS !');
  console.log('===========================================');
} else {
  console.log(stillBad + ' fichier(s) encore corrompu(s)');
}