// ============================================================
// Equine Profile Standard
// Neo4j Graph Database Schema v1.0
// Nodes: Horse, Stable, Owner, Breeder
// Relationships: SIRED_BY, BORN_OF, OWNED_BY, BRED_BY,
//                KEPT_AT, BRED_AT, MANAGES
// Location: equine-profile-standard/v1.0/database/
// Published by Open Equine - TechXZone Pvt Ltd
// MIT Licensed | openequine.org | contact@openequine.org
// ============================================================


// ------------------------------------------------------------
// STEP 1 - CONSTRAINTS
// Run each statement individually in Neo4j Browser
// ------------------------------------------------------------

CREATE CONSTRAINT constraint_horse_id IF NOT EXISTS
FOR (h:Horse) REQUIRE h.horse_id IS UNIQUE;

CREATE CONSTRAINT constraint_horse_ueln IF NOT EXISTS
FOR (h:Horse) REQUIRE h.ueln IS UNIQUE;

CREATE CONSTRAINT constraint_horse_microchip IF NOT EXISTS
FOR (h:Horse) REQUIRE h.microchip IS UNIQUE;

CREATE CONSTRAINT constraint_horse_passport IF NOT EXISTS
FOR (h:Horse) REQUIRE h.passport_no IS UNIQUE;

CREATE CONSTRAINT constraint_stable_id IF NOT EXISTS
FOR (s:Stable) REQUIRE s.stable_id IS UNIQUE;

CREATE CONSTRAINT constraint_owner_id IF NOT EXISTS
FOR (o:Owner) REQUIRE o.owner_id IS UNIQUE;

CREATE CONSTRAINT constraint_breeder_id IF NOT EXISTS
FOR (b:Breeder) REQUIRE b.breeder_id IS UNIQUE;


// ------------------------------------------------------------
// STEP 2 - INDEXES
// ------------------------------------------------------------

CREATE INDEX index_horse_name     IF NOT EXISTS FOR (h:Horse)   ON (h.horse_name);
CREATE INDEX index_horse_breed    IF NOT EXISTS FOR (h:Horse)   ON (h.breed);
CREATE INDEX index_horse_gender   IF NOT EXISTS FOR (h:Horse)   ON (h.gender);
CREATE INDEX index_stable_name    IF NOT EXISTS FOR (s:Stable)  ON (s.stable_name);
CREATE INDEX index_stable_city    IF NOT EXISTS FOR (s:Stable)  ON (s.city);
CREATE INDEX index_stable_country IF NOT EXISTS FOR (s:Stable)  ON (s.country);
CREATE INDEX index_owner_name     IF NOT EXISTS FOR (o:Owner)   ON (o.owner_name);
CREATE INDEX index_breeder_name   IF NOT EXISTS FOR (b:Breeder) ON (b.breeder_name);


// ------------------------------------------------------------
// STEP 3 - NODE: Horse
//
// Properties:
//   horse_id     - internal unique identifier (required)
//   horse_name   - registered or commonly known name (required)
//   dob          - date of birth, ISO 8601: YYYY-MM-DD
//   breed        - breed name
//   gender       - mare | stallion | gelding
//   color        - base coat color
//   ueln         - Universal Equine Life Number, 15 char alphanumeric
//   passport_no  - travel passport number issued by national authority
//   microchip    - 15-digit ISO 11784/11785 microchip number
//   created_at   - record creation datetime
//   updated_at   - record last updated datetime
// ------------------------------------------------------------

MERGE (h:Horse { horse_id: "example-uuid-001" })
SET
    h.horse_name  = "Rajputana Bahadur",
    h.dob         = "2019-03-15",
    h.breed       = "Marwari",
    h.gender      = "stallion",
    h.color       = "Bay",
    h.ueln        = "IN2019MARW00001",
    h.passport_no = "AIMHS-2019-00432",
    h.microchip   = "985141002345678",
    h.created_at  = datetime(),
    h.updated_at  = datetime();


// ------------------------------------------------------------
// STEP 4 - NODE: Stable
//
// Properties:
//   stable_id       - internal unique identifier (required)
//   stable_name     - name of the stable (required)
//   stable_location - full free text address
//   address_line1
//   address_line2
//   city
//   state
//   country
//   pincode         - string to handle leading zeros
//   created_at
//   updated_at
// ------------------------------------------------------------

MERGE (s:Stable { stable_id: "stable-uuid-001" })
SET
    s.stable_name     = "Rathore Stud Farm",
    s.city            = "Jodhpur",
    s.state           = "Rajasthan",
    s.country         = "India",
    s.pincode         = "342001",
    s.created_at      = datetime(),
    s.updated_at      = datetime();


// ------------------------------------------------------------
// STEP 5 - NODE: Owner
//
// Properties:
//   owner_id       - internal unique identifier (required)
//   owner_name     - full name of current registered owner (required)
//   owner_contact  - phone number or email address (required)
//   created_at
//   updated_at
// ------------------------------------------------------------

MERGE (o:Owner { owner_id: "owner-uuid-001" })
SET
    o.owner_name    = "Vikram Singh Rathore",
    o.owner_contact = "+91-9876543210",
    o.created_at    = datetime(),
    o.updated_at    = datetime();


// ------------------------------------------------------------
// STEP 6 - NODE: Breeder
//
// Properties:
//   breeder_id      - internal unique identifier (required)
//   breeder_name    - full name of breeder or organisation (required)
//   breeder_contact - phone number or email address
//   created_at
//   updated_at
// ------------------------------------------------------------

MERGE (b:Breeder { breeder_id: "breeder-uuid-001" })
SET
    b.breeder_name    = "Jodhpur Heritage Stables",
    b.breeder_contact = "heritage@samplestables.in",
    b.created_at      = datetime(),
    b.updated_at      = datetime();


// ------------------------------------------------------------
// STEP 7 - RELATIONSHIPS
//
// (Horse)-[:SIRED_BY]->(Horse)
//   Connects a horse to its sire (father).
//
// (Horse)-[:BORN_OF]->(Horse)
//   Connects a horse to its dam (mother).
//
// (Horse)-[:OWNED_BY]->(Owner)
//   Current ownership. Property: since (date ownership began).
//
// (Horse)-[:BRED_BY]->(Breeder)
//   Breeding attribution.
//
// (Horse)-[:KEPT_AT]->(Stable)
//   Current stable location.
//
// (Horse)-[:BRED_AT]->(Stable)
//   Stable where the horse was bred.
//
// (Owner)-[:MANAGES]->(Stable)
//   Owner manages or operates a stable.
// ------------------------------------------------------------

// Pedigree relationships
MATCH (foal:Horse  { horse_id: "example-uuid-001" })
MATCH (sire:Horse  { horse_id: "sire-uuid-here"   })
MATCH (dam:Horse   { horse_id: "dam-uuid-here"    })
MERGE (foal)-[:SIRED_BY]->(sire)
MERGE (foal)-[:BORN_OF]->(dam);

// Ownership relationship
MATCH (h:Horse { horse_id: "example-uuid-001" })
MATCH (o:Owner { owner_id: "owner-uuid-001"   })
MERGE (h)-[:OWNED_BY { since: "2023-01-01" }]->(o);

// Stable relationships
MATCH (h:Horse  { horse_id:  "example-uuid-001" })
MATCH (s:Stable { stable_id: "stable-uuid-001"  })
MERGE (h)-[:KEPT_AT]->(s);

// Breeder relationship
MATCH (h:Horse   { horse_id:   "example-uuid-001"  })
MATCH (b:Breeder { breeder_id: "breeder-uuid-001"  })
MERGE (h)-[:BRED_BY]->(b);

// Owner manages stable
MATCH (o:Owner  { owner_id:  "owner-uuid-001"  })
MATCH (s:Stable { stable_id: "stable-uuid-001" })
MERGE (o)-[:MANAGES]->(s);


// ------------------------------------------------------------
// STEP 8 - GLOBAL EQUINE GRAPH
// Recursive pedigree traversal query
// Retrieve all ancestors up to 6 generations
// ------------------------------------------------------------

MATCH path = (h:Horse { horse_name: "Rajputana Bahadur" })
             -[:SIRED_BY|BORN_OF*1..6]->(ancestor:Horse)
RETURN
    ancestor.horse_name  AS ancestor_name,
    ancestor.breed       AS breed,
    length(path)         AS generation
ORDER BY generation ASC;


// ============================================================
// End of Schema
// Equine Profile Standard v1.0
// ============================================================
