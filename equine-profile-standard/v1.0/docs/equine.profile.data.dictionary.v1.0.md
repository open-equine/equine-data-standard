# Equine Profile Standard — Data Dictionary

**Version:** 1.0  
**Published by:** Open Equine — TechXZone Pvt Ltd  
**Website:** openequine.org  
**Contact:** contact@openequine.org  
**Licence:** MIT  

---

## About This Document

This document defines every field in the Equine Profile Standard v1.0 in human-readable form. It is intended for developers integrating the standard, breed societies adopting it, and institutions building equine data systems.

For the machine-readable schema, see `equine-profile-standard/v1.0/schema/equine.profile.standard.v1.0.json`.  
For a working example, see `equine-profile-standard/v1.0/examples/equine.profile.example.v1.0.json`.

---

## Field Conventions

- All field names follow **camelCase** convention.
- Dates use **ISO 8601** format: `YYYY-MM-DD`
- Datetimes use **ISO 8601** format with UTC offset: `YYYY-MM-DDTHH:MM:SSZ`
- Fields marked **Required** must be present for a profile to be considered valid under this standard.
- Fields marked **Optional** are strongly recommended where applicable but will not cause validation failure if absent.
- String fields should not contain leading or trailing whitespace.

---

## Domain 1 — Horse Identity

Core fields that identify a horse as a unique individual.

---

### `horseName`
**Type:** string  
**Required:** Yes  
**Description:** The horse's registered name or commonly used name. This may be a studbook name, show name, or stable name depending on the context.  
**Recommended Validation:** Minimum 1 character. Should not contain purely numeric strings. Implementations may restrict special characters per their naming convention.  
**Examples:** `Rajputana Bahadur`, `Desert Storm`, `Black Caviar`

---

### `dob`
**Type:** string (ISO 8601 date)  
**Required:** Yes  
**Format:** `YYYY-MM-DD`  
**Description:** The horse's date of birth. Where the exact date is unknown, the first of January of the birth year is an accepted convention in the equine industry (e.g. `2019-01-01`).  
**Recommended Validation:** Must be a valid calendar date. Must not be a future date. Must not be more than 60 years in the past.  
**Examples:** `2019-03-15`, `2021-01-01`

---

### `breed`
**Type:** string  
**Required:** Yes  
**Description:** The breed of the horse. This standard does not enforce a controlled vocabulary for breed names in v1.0 to accommodate global diversity of breeds and regional naming conventions.  
**Recommended Validation:** Minimum 1 character.  
**Examples:** `Marwari`, `Thoroughbred`, `Arabian`, `Warmblood`, `Kathiawari`, `Anglo-Arab`  
**Note for Indian implementations:** Recognised Indian breeds include Marwari, Kathiawari, Spiti, Zanskari, Manipuri, and Bhutia. AIMHS and SBAI maintain official breed registers.

---

### `gender`
**Type:** enum  
**Required:** Yes  
**Allowed Values:**
- `mare` — female horse, typically over 4 years of age
- `stallion` — intact male horse
- `gelding` — castrated male horse

**Description:** The biological sex or reproductive status of the horse.  
**Note:** Colt (young male) and filly (young female) are age-qualified terms not used as gender enums in this standard. Implementing applications may display age-contextual labels in the UI while storing the base gender enum.

---

### `color`
**Type:** string  
**Required:** Yes  
**Description:** The base coat color of the horse using standard equine color terminology.  
**Recommended Validation:** Minimum 1 character.  
**Common values:** `Bay`, `Chestnut`, `Grey`, `Black`, `Roan`, `Dun`, `Palomino`, `Piebald`, `Skewbald`  
**Note:** Color descriptions in the equine industry vary by region and breed society. This standard accepts free text to accommodate all conventions.

---

### `ueln`
**Type:** string  
**Required:** No  
**Format:** 15-character alphanumeric, uppercase (`^[A-Z0-9]{15}$`)  
**Description:** Universal Equine Life Number — an internationally standardised unique identifier assigned to a horse at birth or first registration. The UELN system is managed by the World Breeding Federation for Sport Horses (WBFSH).  
**Structure:** First 3 characters — country/database code. Next 9 characters — database identifier. Last 3 characters — individual horse number.  
**Note:** UELN is mandatory in many European Union member states. It is not yet universally mandated in India but is increasingly required for international competition entry.  
**Examples:** `276098102345678` (Germany), `826001002345678` (UK)

---

### `passportNo`
**Type:** string  
**Required:** No  
**Description:** The horse's travel passport number issued by a national authority. A travel passport is an official government issued document for the international movement of horses. Format varies by issuing country and authority.

---

### `microchip`
**Type:** string  
**Required:** No  
**Format:** Exactly 15 digits (`^[0-9]{15}$`)  
**Description:** The 15-digit microchip identification number implanted in the horse, compliant with ISO 11784 (code structure) and ISO 11785 (technical concept). Microchips are typically implanted in the nuchal ligament on the left side of the neck.  
**Recommended Validation:** Must be exactly 15 numeric digits. First 3 digits typically represent the country code under ISO 3166.  
**Examples:** `985141002345678`, `276098102345679`

---

## Domain 2 — Pedigree

Lineage and bloodline information. All fields in this domain are optional to allow profiles to be created for horses of unknown or unregistered ancestry.

---

### `pedigree.sire`
**Type:** string  
**Required:** No  
**Description:** The registered name of the horse's sire (father).

---

### `pedigree.dam`
**Type:** string  
**Required:** No  
**Description:** The registered name of the horse's dam (mother).

---

### `pedigree.sireOfSire`
**Type:** string  
**Required:** No  
**Description:** Paternal grandsire — the father of the sire. Known in traditional pedigree notation as the top line of the second generation.

---

### `pedigree.damOfSire`
**Type:** string  
**Required:** No  
**Description:** Paternal granddam — the mother of the sire.

---

### `pedigree.sireOfDam`
**Type:** string  
**Required:** No  
**Description:** Maternal grandsire — the father of the dam.

---

### `pedigree.damOfDam`
**Type:** string  
**Required:** No  
**Description:** Maternal granddam — the mother of the dam.

---

### `pedigree.description`
**Type:** string  
**Required:** No  
**Description:** Free text field for extended lineage information. May include great-grandparents, notable ancestors, bloodline achievements, breed society notes, or any additional pedigree context that does not fit the structured fields above.

---

## Domain 3 — Owner & Breeder

Current ownership and stable information. The `owner` object as a whole is optional at the schema level, but if present, `ownerName`, `ownerContact`, and `stableLocation` are required within it.

---

### `owner.ownerName`
**Type:** string  
**Required:** Yes (within owner object)  
**Description:** Full legal name of the current registered owner of the horse.  
**Recommended Validation:** Minimum 1 character. Should not be purely numeric.

---

### `owner.ownerContact`
**Type:** string  
**Required:** Yes (within owner object)  
**Description:** The owner's primary contact information — a phone number or email address. This field accepts free text to accommodate international phone formats and various email structures.  
**Recommended Validation:** Implementing applications should validate for either a valid phone format or a valid email format per their regional requirements.  
**Examples:** `+91-9876543210`, `owner@example.com`

---

### `owner.stableLocation`
**Type:** string  
**Required:** Yes (within owner object)  
**Description:** The name and/or physical location of the stable where the horse is currently kept. May be a stable name, an address, or both.  
**Examples:** `Rathore Stud Farm, Jodhpur, Rajasthan`, `Wellington Riding School, Hampshire, UK`

---

### `owner.breederName`
**Type:** string  
**Required:** No  
**Description:** Full name of the individual or organisation that bred the horse. May differ from the current owner.

---

### `owner.breederContact`
**Type:** string  
**Required:** No  
**Description:** The breeder's contact information — phone number or email address. Optional as breeder contact may not always be available or relevant.

---

## Domain 4 — Media

Visual media associated with the horse profile.

---

### `media.photos`
**Type:** array of objects  
**Required:** No  
**Description:** An ordered collection of photo objects associated with this horse profile. There is no maximum limit defined at the schema level — implementing applications may enforce their own storage or display limits.

---

### `media.photos[].url`
**Type:** string (URI)  
**Required:** Yes (within each photo object)  
**Description:** A publicly accessible URI pointing to the image. Should be a stable, long-lived URL. Temporary object URLs (such as those created by `URL.createObjectURL()`) should be resolved to permanent URIs before persisting to a database.  
**Format:** Must be a valid URI (`https://` recommended).

---

### `media.photos[].caption`
**Type:** string  
**Required:** No  
**Description:** A short descriptive label for the photo. Useful for identifying the type or context of the image.  
**Examples:** `Left lateral view`, `Right lateral view`, `Head study`, `Competition 2024`, `At stable, March 2025`

---

### `media.photos[].isPrimary`
**Type:** boolean  
**Required:** No  
**Description:** When `true`, designates this photo as the primary profile image to be used as the horse's cover photo or thumbnail. Only one photo in the array should carry `isPrimary: true`. Implementing applications should enforce this constraint at the application level.

---

## Domain 5 — Meta

Metadata about the data record itself. `schemaVersion` and `createdAt` are required. All other meta fields are optional.

---

### `meta.schemaVersion`
**Type:** string  
**Required:** Yes  
**Description:** The version of the Equine Profile Standard that this profile conforms to. Must be set by the originating application at record creation. This field is critical for forward compatibility — as the standard evolves, consuming systems use this field to apply the correct parsing and validation logic.  
**Current value:** `"1.0"`

---

### `meta.createdAt`
**Type:** string (ISO 8601 datetime)  
**Required:** Yes  
**Format:** `YYYY-MM-DDTHH:MM:SSZ`  
**Description:** The datetime at which this data record was first constructed by the originating application. This is not the horse's date of birth, nor the date of any physical document. It is the timestamp of the digital profile's creation. Must be set once at record creation and never modified — use `updatedAt` for subsequent changes.  
**Examples:** `2026-04-07T10:30:00Z`

---

### `meta.updatedAt`
**Type:** string (ISO 8601 datetime)  
**Required:** No  
**Format:** `YYYY-MM-DDTHH:MM:SSZ`  
**Description:** The datetime of the most recent modification to this data record. Should be updated by the originating application each time any field in the profile is changed.

---

### `meta.capturedBy`
**Type:** string  
**Required:** No  
**Description:** The name or system identifier of the person or automated system that submitted or generated this data record.

---

### `meta.sourceApp`
**Type:** string  
**Required:** No  
**Description:** The name or URL of the application that generated this profile. Helps consuming systems trace the origin of a data record.  
**Examples:** `StableManager Pro v3.2`, `FEI Registration Portal`

---

### `meta.geo.lat`
**Type:** number  
**Required:** Yes (within geo object)  
**Range:** -90 to 90  
**Description:** Latitude coordinate of the device at the time of data capture. Requires explicit user permission. Omit the entire `geo` object if location is unavailable or not consented.

---

### `meta.geo.lng`
**Type:** number  
**Required:** Yes (within geo object)  
**Range:** -180 to 180  
**Description:** Longitude coordinate of the device at the time of data capture.

---

### `meta.geo.accuracyMeters`
**Type:** number  
**Required:** No  
**Description:** The accuracy radius of the GPS reading in metres. A lower number indicates a more precise location reading.

---

## Domain 6 — Consent

Data sharing acknowledgement record. This entire domain is optional at the schema level. Implementing platforms are responsible for meeting their own legal and regulatory obligations around data sharing consent.

**Best Practice:** Any platform that stores, publishes, or shares horse profile data on behalf of an owner is strongly recommended to capture and persist a consent record.

---

### `consent.acknowledged`
**Type:** boolean  
**Required:** No  
**Description:** When `true`, confirms that the submitting party has read the data accuracy disclaimer and consented to the data being stored or shared. Should only be set to `true` in response to an explicit affirmative action by the user (e.g. checking a checkbox) — never set programmatically without user interaction.

---

### `consent.acknowledgedAt`
**Type:** string (ISO 8601 datetime)  
**Required:** No  
**Description:** The exact datetime at which the user gave their acknowledgement. Should be captured at the moment of the user's affirmative action, not at form submission time if these differ.

---

### `consent.acknowledgedBy`
**Type:** string  
**Required:** No  
**Description:** The full name of the person who gave the acknowledgement. Typically the owner. Should match `owner.ownerName` in most cases.

---

### `consent.disclaimer`
**Type:** string  
**Required:** No  
**Description:** The exact text of the disclaimer that was presented to the user at the time of acknowledgement. Storing the verbatim disclaimer text creates an immutable audit record of what the user agreed to, which is important if the disclaimer text changes over time.

---

### `consent.ipAddress`
**Type:** string  
**Required:** No  
**Description:** The IP address of the submitting device at the time consent was given. Provides an additional layer of audit trail. Implementing applications must comply with applicable data protection regulations before collecting and storing IP addresses.

---

## Recommended Application-Level Validations

The following validations are not enforced by the JSON schema but are recommended for implementing applications:

- **`ownerContact`** — Validate as either a valid phone number (E.164 format recommended for international compatibility) or a valid email address. Applications targeting India may additionally validate against Indian mobile number format.
- **`horseName`** — Should not contain purely numeric strings. Consider restricting to letters, spaces, hyphens, and apostrophes.
- **`stableLocation`** — Minimum meaningful length of 3 characters recommended.
- **`pedigree` names** — Should not contain numeric strings. Consider minimum 2 characters.
- **`media.photos[].isPrimary`** — Enforce uniqueness: no more than one photo per profile should have `isPrimary: true`.
- **`meta.createdAt`** — Must not be a future datetime.
- **`meta.updatedAt`** — Must not be earlier than `meta.createdAt`.
- **`consent.acknowledged`** — Must only be set to `true` via explicit user action. Never default to `true`.

---

## International Standards Reference

- **UELN** — Universal Equine Life Number. An internationally recognised unique identifier for horses. Use the `ueln` field.
- **ISO 11784/11785** — The global microchip standard. All microchip values in this schema must conform to this standard. Use the `microchip` field.
- **Travel Passport** — An official government issued document for the international movement/travel of horses. Use the `passportNo` field.

---

*Open Equine — TechXZone Pvt Ltd | openequine.org | contact@openequine.org*  
*Equine Profile Standard v1.0 | MIT Licensed | April 2026*
