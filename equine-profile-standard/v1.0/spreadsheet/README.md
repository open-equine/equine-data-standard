# Equine Profile Standard v1.0 — Spreadsheet Template

**Version:** 1.0  
**Published by:** Open Equine — TechXZone Pvt Ltd  
**Website:** openequine.org  
**Contact:** contact@openequine.org  
**Licence:** MIT  

---

## What Is This?

A standards-compliant Google Sheets template for recording horse profile data conforming to the Equine Profile Standard v1.0.

Designed for stable owners, breeders and breed societies who manage horse records in spreadsheets. All fields, validation rules and structure conform directly to the Equine Profile Standard v1.0 — no deviation, no additions.

---

## Files

| File | Description |
|------|-------------|
| `Equine_Profile_Standard_v1.0.xlsx` | The spreadsheet template. Upload to Google Drive and open with Google Sheets. Also opens in Microsoft Excel. |
| `OEDS_GoogleAppsScript.gs` | Google Apps Script for automation. Paste into Extensions > Apps Script inside Google Sheets to activate timestamps, ID generation, duplicate detection and field validation. |

---

## Sheet Structure

| Tab | Contents |
|-----|----------|
| Instructions | Step by step guide — read before filling any data |
| Horses | Core horse identity — 12 fields conforming to the Horse Identity domain |
| Pedigree | Three generations of lineage — parents, grandparents, great-grandparents |
| Owner & Breeder | Ownership history and breeder details |
| Media | Photo URLs linked to each horse |
| Meta & Consent | Data capture metadata and consent records |
| Reference | Hidden — source data for dropdown validations |

All tabs are linked via **Stable Horse ID** — a unique identifier assigned by the stable to each horse.

---

## Fields

All fields in this template map directly to the Equine Profile Standard v1.0 JSON schema.

See the full field definitions in:
- [`../schema/equine.profile.standard.v1.0.json`](../schema/equine.profile.standard.v1.0.json)
- [`../docs/equine.profile.data.dictionary.v1.0.md`](../docs/equine.profile.data.dictionary.v1.0.md)

---

## Getting Started

### Step 1 — Open in Google Sheets
1. Upload `Equine_Profile_Standard_v1.0.xlsx` to Google Drive
2. Right click → Open with → Google Sheets

### Step 2 — Install the Apps Script
1. Go to `Extensions` → `Apps Script`
2. Delete any existing code
3. Paste the entire contents of `OEDS_GoogleAppsScript.gs`
4. Click Save
5. Click Run → select `onOpen` → Authorise when prompted
6. Reload the Google Sheet
7. An **OEDS Tools** menu will appear in the menu bar

### Step 3 — Start entering data
Begin with the **Horses** tab. Enter each horse as one row. All other tabs link back via the Stable Horse ID.

---

## Automation — OEDS Tools Menu

Once the Apps Script is installed the following tools are available under the **OEDS Tools** menu:

| Tool | Description |
|------|-------------|
| Generate Next Stable Horse ID | Auto-generates the next STB-001, STB-002 etc. |
| Check Duplicate IDs | Scans all IDs and highlights duplicates in red |
| Validate Required Fields | Checks all required fields and highlights missing ones |
| Validate UELN & Microchip Length | Enforces exactly 15 characters for UELN and Microchip |
| Clear All Highlights | Resets all validation highlights |

**Timestamps** — Created At and Updated At are stamped automatically on edit. No action required.

---

## Data Validations

The following fields have enforced dropdown validation:

| Field | Valid Values |
|-------|-------------|
| Gender | mare, stallion, gelding, filly, colt |
| Breed | 17 breeds — see Reference tab |
| Color | 15 colors — see Reference tab |

UELN and Microchip length are enforced by the Apps Script validator.

---

## Extracting as JSON

Data entered in this template can be exported to the Equine Profile Standard v1.0 JSON format using the Horse Profile Creator at:

**horseprofile.vercel.app**

---

## Licence

MIT License — Copyright (c) 2026 TechXZone Pvt Ltd

Permission is hereby granted, free of charge, to any person obtaining a copy of this file to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the file.

See [LICENSE.txt](../../../../LICENSE.txt) for full terms.

---

*Open Equine Data Standards — openequine.org — contact@openequine.org*  
*Equine Profile Standard v1.0 — MIT Licensed — April 2026*

