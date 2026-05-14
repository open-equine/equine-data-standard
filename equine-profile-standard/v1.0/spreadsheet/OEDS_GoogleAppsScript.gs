// ============================================================
// Equine Profile Standard v1.0 — Google Apps Script
// Open Equine Data Standards (OEDS)
// openequine.org | MIT Licensed | © 2026 TechXZone Pvt Ltd
//
// COLUMNS — Horses Tab:
// A=Stable Horse ID, B=Open Equine ID, C=Horse Name, D=DOB,
// E=Breed, F=Gender, G=Color, H=UELN, I=Passport No,
// J=Microchip, K=Created At, L=Updated At
//
// HOW TO INSTALL:
// 1. Upload xlsx to Google Drive → Open with Google Sheets
// 2. Extensions > Apps Script
// 3. Delete existing code, paste this entire script
// 4. Click Save → Run onOpen once to authorise
// 5. Reload the sheet — OEDS Tools menu appears
// ============================================================

function onOpen() {
  SpreadsheetApp.getUi()
    .createMenu('OEDS Tools')
    .addItem('Generate Next Stable Horse ID', 'generateNextHorseID')
    .addSeparator()
    .addItem('Check Duplicate IDs', 'checkDuplicateIDs')
    .addItem('Validate Required Fields', 'validateRequiredFields')
    .addItem('Validate UELN & Microchip Length', 'validateFieldLengths')
    .addSeparator()
    .addItem('Clear All Highlights', 'clearHighlights')
    .addToUi();
}

// ── AUTO-STAMP TIMESTAMPS ON EDIT ───────────────────────────
function onEdit(e) {
  var sheet = e.source.getActiveSheet();
  var row   = e.range.getRow();
  var col   = e.range.getColumn();

  // HORSES TAB — K=11 Created At, L=12 Updated At
  if (sheet.getName() === 'Horses' && row >= 11) {
    var stableID = sheet.getRange(row, 1).getValue();
    if (stableID !== '') {
      var now = new Date().toISOString().replace('T', ' ').substring(0, 19);
      if (sheet.getRange(row, 11).getValue() === '') {
        sheet.getRange(row, 11).setValue(now);
      }
      if (col !== 11 && col !== 12) {
        sheet.getRange(row, 12).setValue(now);
      }
    }
  }

  // META & CONSENT TAB — D=4 Created At, E=5 Updated At
  if (sheet.getName() === 'Meta & Consent' && row >= 10) {
    var stableID = sheet.getRange(row, 1).getValue();
    if (stableID !== '') {
      var now = new Date().toISOString().replace('T', ' ').substring(0, 19);
      if (sheet.getRange(row, 4).getValue() === '') {
        sheet.getRange(row, 4).setValue(now);
      }
      if (col !== 4 && col !== 5) {
        sheet.getRange(row, 5).setValue(now);
      }
    }
  }
}

// ── GENERATE NEXT STABLE HORSE ID ───────────────────────────
function generateNextHorseID() {
  var sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName('Horses');
  if (!sheet) { SpreadsheetApp.getUi().alert('Horses sheet not found.'); return; }

  var lastRow = sheet.getLastRow();
  var nextNum = 1;

  for (var r = 11; r <= lastRow; r++) {
    var val   = sheet.getRange(r, 1).getValue().toString().trim();
    var parts = val.split('-');
    if (parts.length === 2) {
      var num = parseInt(parts[1], 10);
      if (!isNaN(num) && num >= nextNum) nextNum = num + 1;
    }
  }

  var nextID    = 'STB-' + String(nextNum).padStart(3, '0');
  var targetRow = lastRow + 1;
  for (var r = 11; r <= lastRow + 1; r++) {
    if (sheet.getRange(r, 1).getValue() === '') { targetRow = r; break; }
  }

  sheet.getRange(targetRow, 1).setValue(nextID);
  sheet.setActiveRange(sheet.getRange(targetRow, 3));
  SpreadsheetApp.getUi().alert('New Stable Horse ID: ' + nextID + ' (Row ' + targetRow + ')');
}

// ── CHECK DUPLICATE IDs ──────────────────────────────────────
function checkDuplicateIDs() {
  var sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName('Horses');
  if (!sheet) { SpreadsheetApp.getUi().alert('Horses sheet not found.'); return; }

  var lastRow    = sheet.getLastRow();
  var idMap      = {};
  var duplicates = [];

  sheet.getRange(11, 1, Math.max(lastRow - 10, 1), 1).setBackground(null);

  for (var r = 11; r <= lastRow; r++) {
    var id = sheet.getRange(r, 1).getValue().toString().trim();
    if (id !== '') {
      if (idMap[id] !== undefined) {
        sheet.getRange(idMap[id], 1).setBackground('#FFCCCC');
        sheet.getRange(r, 1).setBackground('#FFCCCC');
        duplicates.push('Row ' + r + ': ' + id + ' (duplicate of row ' + idMap[id] + ')');
      } else {
        idMap[id] = r;
        sheet.getRange(r, 1).setBackground('#EAF5EA');
      }
    }
  }

  if (duplicates.length === 0) {
    SpreadsheetApp.getUi().alert('No duplicate Stable Horse IDs found.');
  } else {
    SpreadsheetApp.getUi().alert(
      'Found ' + duplicates.length + ' duplicate(s):\n\n' +
      duplicates.join('\n') +
      '\n\nDuplicate rows highlighted in red.'
    );
  }
}

// ── VALIDATE REQUIRED FIELDS ─────────────────────────────────
function validateRequiredFields() {
  var sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName('Horses');
  if (!sheet) { SpreadsheetApp.getUi().alert('Horses sheet not found.'); return; }

  var requiredCols = [1, 3, 4, 5, 6, 7];
  var colNames     = ['Stable Horse ID', 'Horse Name', 'Date of Birth', 'Breed', 'Gender', 'Color'];
  var lastRow      = sheet.getLastRow();
  var errors       = [];

  if (lastRow >= 11) sheet.getRange(11, 1, lastRow - 10, 12).setBackground(null);

  for (var r = 11; r <= lastRow; r++) {
    if (sheet.getRange(r, 1).getValue().toString().trim() !== '') {
      for (var i = 0; i < requiredCols.length; i++) {
        if (sheet.getRange(r, requiredCols[i]).getValue().toString().trim() === '') {
          sheet.getRange(r, requiredCols[i]).setBackground('#FFCCCC');
          errors.push('Row ' + r + ' — ' + colNames[i] + ' is empty');
        }
      }
    }
  }

  if (errors.length === 0) {
    SpreadsheetApp.getUi().alert('All required fields complete.');
  } else {
    SpreadsheetApp.getUi().alert(
      errors.length + ' missing field(s):\n\n' +
      errors.slice(0, 20).join('\n') +
      (errors.length > 20 ? '\n...and ' + (errors.length - 20) + ' more.' : '')
    );
  }
}

// ── VALIDATE UELN & MICROCHIP ────────────────────────────────
function validateFieldLengths() {
  var sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName('Horses');
  if (!sheet) { SpreadsheetApp.getUi().alert('Horses sheet not found.'); return; }

  var lastRow = sheet.getLastRow();
  var errors  = [];

  for (var r = 11; r <= lastRow; r++) {
    if (sheet.getRange(r, 1).getValue().toString().trim() === '') continue;

    var ueln = sheet.getRange(r, 8).getValue().toString().trim();
    if (ueln !== '' && ueln.length !== 15) {
      sheet.getRange(r, 8).setBackground('#FFCCCC');
      errors.push('Row ' + r + ' — UELN is ' + ueln.length + ' chars (must be 15)');
    }

    var chip = sheet.getRange(r, 10).getValue().toString().trim();
    if (chip !== '' && (chip.length !== 15 || isNaN(chip))) {
      sheet.getRange(r, 10).setBackground('#FFCCCC');
      errors.push('Row ' + r + ' — Microchip must be exactly 15 digits');
    }
  }

  if (errors.length === 0) {
    SpreadsheetApp.getUi().alert('All UELN and Microchip values are valid.');
  } else {
    SpreadsheetApp.getUi().alert(errors.length + ' error(s):\n\n' + errors.join('\n'));
  }
}

// ── CLEAR ALL HIGHLIGHTS ─────────────────────────────────────
function clearHighlights() {
  var sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName('Horses');
  if (sheet) {
    var lastRow = Math.max(sheet.getLastRow(), 11);
    sheet.getRange(11, 1, lastRow - 10, 12).setBackground(null);
  }
  SpreadsheetApp.getUi().alert('All highlights cleared.');
}

// ============================================================
// END — Equine Profile Standard v1.0
// Open Equine Data Standards | openequine.org
// MIT Licensed | © 2026 TechXZone Pvt Ltd
// ============================================================
