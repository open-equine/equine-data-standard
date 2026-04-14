# Equine Profile Standard
## Redis Schema v1.0

**Location:** equine-profile-standard/v1.0/database/  
**Published by:** Open Equine — TechXZone Pvt Ltd  
**MIT Licensed** | openequine.org | contact@openequine.org  

---

## Overview

Redis is a key-value store used as a **caching and indexing layer** alongside a primary database. It is not a replacement for the relational or document schemas in this standard.

In the context of the Equine Profile Standard, Redis serves two purposes:

1. **Profile caching** — cache frequently accessed horse profiles for sub-millisecond retrieval
2. **Index lookups** — maintain fast reverse lookups by UELN, microchip, and passport number

---

## Key Naming Convention

All keys follow the pattern:

```
equine:{entity}:{identifier}
```

---

## Key Structures

### Horse Profile Cache

```
Key:    equine:horse:{horse_id}
Type:   Hash
TTL:    3600 seconds (1 hour — adjust per application requirements)

Fields:
  horse_name    string
  dob           string    ISO 8601: YYYY-MM-DD
  breed         string
  gender        string    mare | stallion | gelding
  color         string
  ueln          string    15 char alphanumeric
  passport_no   string
  microchip     string    15-digit ISO 11784/11785
  created_at    string    ISO 8601 datetime
  updated_at    string    ISO 8601 datetime
```

Example:
```
HSET equine:horse:uuid-001
  horse_name    "Rajputana Bahadur"
  dob           "2019-03-15"
  breed         "Marwari"
  gender        "stallion"
  color         "Bay"
  ueln          "IN2019MARW00001"
  microchip     "985141002345678"
EXPIRE equine:horse:uuid-001 3600
```

---

### UELN Reverse Lookup

```
Key:    equine:idx:ueln:{ueln_value}
Type:   String
Value:  horse_id
TTL:    86400 seconds (24 hours)
```

Example:
```
SET equine:idx:ueln:IN2019MARW00001 "uuid-001" EX 86400
```

---

### Microchip Reverse Lookup

```
Key:    equine:idx:microchip:{microchip_value}
Type:   String
Value:  horse_id
TTL:    86400 seconds (24 hours)
```

Example:
```
SET equine:idx:microchip:985141002345678 "uuid-001" EX 86400
```

---

### Passport Reverse Lookup

```
Key:    equine:idx:passport:{passport_no}
Type:   String
Value:  horse_id
TTL:    86400 seconds (24 hours)
```

---

### Stable Cache

```
Key:    equine:stable:{stable_id}
Type:   Hash
TTL:    3600 seconds

Fields:
  stable_name     string
  city            string
  state           string
  country         string
  pincode         string
  created_at      string
  updated_at      string
```

---

### Breed Index

```
Key:    equine:idx:breed:{breed_name}
Type:   Set
Value:  Set of horse_ids belonging to this breed
TTL:    1800 seconds (30 minutes)
```

Example:
```
SADD equine:idx:breed:Marwari "uuid-001" "uuid-002" "uuid-003"
EXPIRE equine:idx:breed:Marwari 1800
```

---

## Cache Invalidation

When a horse profile is updated in the primary database, invalidate the corresponding Redis keys:

```
DEL equine:horse:{horse_id}
DEL equine:idx:ueln:{ueln_value}
DEL equine:idx:microchip:{microchip_value}
DEL equine:idx:passport:{passport_no}
SREM equine:idx:breed:{breed_name} {horse_id}
```

---

## Notes

- Redis is a caching layer. The primary source of truth remains the relational or document database.
- TTL values are indicative. Implementing applications should set TTL based on their data update frequency.
- For AI vector search and sub-millisecond indexing, use **Redis Stack** with the `RediSearch` and `RedisJSON` modules, which support vector similarity search natively.

---

*Open Equine — TechXZone Pvt Ltd | openequine.org | contact@openequine.org*  
*Equine Profile Standard v1.0 | MIT Licensed | April 2026*
