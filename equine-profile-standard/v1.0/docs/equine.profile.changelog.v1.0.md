# Equine Profile Standard — Changelog

**Published by:** Open Equine — TechXZone Pvt Ltd
**Website:** openequine.org
**Contact:** contact@openequine.org
**Licence:** MIT

---

## Version 1.0 — April 2026

**Status:** Published
**Released:** 12 April 2026
**Repository:** github.com/open-equine/equine-data-standard

---

### What Is New in v1.0

First public release of the Equine Profile Standard. All fields, domains, database schemas, and documentation are new.

**Domains:**

| Domain | Fields |
|--------|--------|
| Horse Identity | horseName, dob, breed, gender, color, ueln, passportNo, microchip |
| Pedigree | sire, dam, sireOfSire, damOfSire, sireOfDam, damOfDam, description |
| Owner & Breeder | ownerName, ownerContact, stableLocation, breederName, breederContact |
| Media | photos[].url, photos[].caption, photos[].isPrimary |
| Meta | schemaVersion, createdAt, updatedAt, capturedBy, sourceApp, geo |
| Consent | acknowledged, acknowledgedAt, acknowledgedBy, disclaimer, ipAddress |

**Database schemas published:**

- MySQL
- PostgreSQL
- SQLite
- MongoDB
- Firebase Firestore
- Amazon DynamoDB
- Redis
- Neo4j
- Amazon Neptune
- ArangoDB

**Documentation published:**

- equine.profile.data.dictionary.v1.0.md
- equine.profile.implementation.guide.v1.0.md
- equine.profile.changelog.v1.0.md

---

### Known Limitations in v1.0

- `breed` and `color` are free-text fields. Controlled vocabulary URI lists are planned for v1.1.
- No vector embedding field. AI-optimised `meta.embedding` is planned for v1.1.
- No Decentralized ID (`did`) field. Cross-platform entity linking is planned for v1.1.
- Media domain covers foundational photo association only. Detailed media specification is addressed separately.

---

### Contributors — v1.0

The Equine Profile Standard v1.0 was developed by Open Equine — TechXZone Pvt Ltd. The following individual contributed domain expertise that directly shaped the design of specific fields in this standard.

---

**Mr. Ranjit Kher**
*The Barn House, Pune, Maharashtra*
*Founder, Rare Genetics — India's first equine and canine semen collection and cryopreservation bank and skin tissue bio bank*

**Contribution — `meta.geo` and `meta.capturedBy` fields**

During the review of the Horse Profile Creator tool, Mr. Ranjit Kher identified and recommended the implementation of Geostamping and Timestamp capture on every horse profile record.

This recommendation was formally incorporated into the Equine Profile Standard v1.0 as the `meta.geo` and `meta.capturedBy` fields. These fields transform a static horse record into a geographically traceable, attribution-anchored data point — forming the architectural foundation of the Global Equine Graph.

*Open Equine and TechXZone Pvt Ltd acknowledge this contribution with gratitude.*

---

### How to Contribute

The Equine Profile Standard welcomes contributions from the global equine and developer community.

- Open an issue at github.com/open-equine/equine-data-standard to propose a new field or domain
- Submit a pull request with your proposed change and the use case it addresses
- All accepted contributions will be acknowledged in the changelog of the version they appear in

---

*Open Equine — TechXZone Pvt Ltd | openequine.org | MIT Licensed | April 2026*
