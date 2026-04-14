// ============================================================
// Equine Profile Standard
// Neo4j Graph Database Schema v1.0
// Nodes: Horse, Stable, Owner, Breeder
// Relationships: SIRED_BY, BORN_OF, OWNED_BY, BRED_BY,
//                KEPT_AT, BRED_AT, MANAGES
// Location: equine-profile-standard/v1.0/database/graph/
// Published by Open Equine — TechXZone Pvt Ltd
// MIT Licensed | openequine.org | contact@openequine.org
// ============================================================


// ------------------------------------------------------------
// CONSTRAINTS
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
// INDEXES
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
// NODE: Horse
//
// Properties:
//   horse_id     String  required  unique identifier
//   horse_name   String  required  registered or commonly known name
//   dob          String  ISO 8601 date: YYYY-MM-DD
//   breed        String  breed name
//   gender       String  mare | stallion | gelding
//   color        String  base coat color
//   ueln         String  15 char alphanumeric — Universal Equine Life Number
//   passport_no  String  travel passport number issued by national authority
//   microchip    String  15-digit ISO 11784/11785 microchip number
//   created_at   String  ISO 8601 datetime
//   updated_at   String  ISO 8601 datetime
// ------------------------------------------------------------


// ------------------------------------------------------------
// NODE: Stable
//
// Properties:
//   stable_id       String  required  unique identifier
//   stable_name     String  required  name of the stable
//   stable_location String  full free text address
//   address_line1   String
//   address_line2   String
//   city            String
//   state           String
//   country         String
//   pincode         String  string to handle leading zeros
//   created_at      String  ISO 8601 datetime
//   updated_at      String  ISO 8601 datetime
// ------------------------------------------------------------


// ------------------------------------------------------------
// NODE: Owner
//
// Properties:
//   owner_id       String  required  unique identifier
//   owner_name     String  required  full name of current registered owner
//   owner_contact  String  required  phone number or email address
//   created_at     String  ISO 8601 datetime
//   updated_at     String  ISO 8601 datetime
// ------------------------------------------------------------


// ------------------------------------------------------------
// NODE: Breeder
//
// Properties:
//   breeder_id      String  required  unique identifier
//   breeder_name    String  required  full name of breeder or organisation
//   breeder_contact String  phone number or email address
//   created_at      String  ISO 8601 datetime
//   updated_at      String  ISO 8601 datetime
// ------------------------------------------------------------


// ------------------------------------------------------------
// RELATIONSHIPS
//
// (Horse)-[:SIRED_BY]->(Horse)
//   Connects a horse to its sire (father).
//
// (Horse)-[:BORN_OF]->(Horse)
//   Connects a horse to its dam (mother).
//
// (Horse)-[:OWNED_BY { since: String }]->(Owner)
//   Current ownership. Property: since — ISO 8601 date ownership began.
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


// ------------------------------------------------------------
// PEDIGREE TRAVERSAL QUERY
// Retrieve all ancestors up to N generations
// Replace $horseName and $generations with runtime values
// ------------------------------------------------------------

// MATCH path = (h:Horse { horse_name: $horseName })
//              -[:SIRED_BY|BORN_OF*1..$generations]->(ancestor:Horse)
// RETURN
//     ancestor.horse_name AS ancestor_name,
//     ancestor.breed      AS breed,
//     length(path)        AS generation
// ORDER BY generation ASC;


// ============================================================
// End of Schema
// Equine Profile Standard v1.0
// ============================================================
