const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');

function loadScript(name) {
  // Use the host Date so timezone changes in calendar tests remain observable.
  const context = vm.createContext({Date});
  const file = path.join(__dirname, '../../home/jwlee/quickshell', name);
  vm.runInContext(fs.readFileSync(file, 'utf8'), context, {filename: file});
  return context;
}

module.exports = {assert, loadScript};
