// ============================================================
// Equine Profile Standard
// Amazon Neptune Graph Database Schema v1.0
// Query Language: openCypher
// Nodes: Horse, Stable, Owner, Breeder
// Relationships: SIRED_BY, BORN_OF, OWNED_BY, BRED_BY,
//                KEPT_AT, BRED_AT, MANAGES
// Location: equine-profile-standard/v1.0/database/graph/
// Published by Open Equine — TechXZone Pvt Ltd
// MIT Licensed | openequine.org | contact@openequine.org
// ============================================================

// ------------------------------------------------------------
// IMPORTANT
// Amazon Neptune does not support CREATE CONSTRAINT or
// CREATE INDEX via openCypher.
// Uniqueness and indexing are managed via the
// Neptune console or AWS CLI.
// ------------------------------------------------------------


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

MERGE (h:Horse { horse_id: $horse_id })
SET
    h.horse_name  = $horse_name,
    h.dob         = $dob,
    h.breed       = $breed,
    h.gender      = $gender,
    h.color       = $color,
    h.ueln        = $ueln,
    h.passport_no = $passport_no,
    h.microchip   = $microchip,
    h.created_at  = $created_at,
    h.updated_at  = $updated_at;


// ------------------------------------------------------------
// NODE: Stable
//
// Properties:
//   stable_id       String  required  unique identifier
//   stable_name     String  required
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

MERGE (s:Stable { stable_id: $stable_id })
SET
    s.stable_name     = $stable_name,
    s.stable_location = $stable_location,
    s.address_line1   = $address_line1,
    s.address_line2   = $address_line2,
    s.city            = $city,
    s.state           = $state,
    s.country         = $country,
    s.pincode         = $pincode,
    s.created_at      = $created_at,
    s.updated_at      = $updated_at;


// ------------------------------------------------------------
// NODE: Owner
//
// Properties:
//   owner_id       String  required  unique identifier
//   owner_name     String  required
//   owner_contact  String  required  phone number or email address
//   created_at     String  ISO 8601 datetime
//   updated_at     String  ISO 8601 datetime
// ------------------------------------------------------------

MERGE (o:Owner { owner_id: $owner_id })
SET
    o.owner_name    = $owner_name,
    o.owner_contact = $owner_contact,
    o.created_at    = $created_at,
    o.updated_at    = $updated_at;


// ------------------------------------------------------------
// NODE: Breeder
//
// Properties:
//   breeder_id      String  required  unique identifier
//   breeder_name    String  required
//   breeder_contact String  phone number or email address
//   created_at      String  ISO 8601 datetime
//   updated_at      String  ISO 8601 datetime
// ------------------------------------------------------------

MERGE (b:Breeder { breeder_id: $breeder_id })
SET
    b.breeder_name    = $breeder_name,
    b.breeder_contact = $breeder_contact,
    b.created_at      = $created_at,
    b.updated_at      = $updated_at;


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
//   Current ownership. Property: since — ISO 8601 date.
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

MATCH (foal:Horse { horse_id: $foal_id })
MATCH (sire:Horse { horse_id: $sire_id })
MATCH (dam:Horse  { horse_id: $dam_id  })
MERGE (foal)-[:SIRED_BY]->(sire)
MERGE (foal)-[:BORN_OF]->(dam);

MATCH (h:Horse { horse_id: $horse_id })
MATCH (o:Owner { owner_id: $owner_id })
MERGE (h)-[:OWNED_BY { since: $since }]->(o);

MATCH (h:Horse  { horse_id:  $horse_id  })
MATCH (s:Stable { stable_id: $stable_id })
MERGE (h)-[:KEPT_AT]->(s);

MATCH (h:Horse   { horse_id:   $horse_id   })
MATCH (b:Breeder { breeder_id: $breeder_id })
MERGE (h)-[:BRED_BY]->(b);

MATCH (o:Owner  { owner_id:  $owner_id  })
MATCH (s:Stable { stable_id: $stable_id })
MERGE (o)-[:MANAGES]->(s);


// ------------------------------------------------------------
// PEDIGREE TRAVERSAL QUERY
// Retrieve all ancestors up to N generations
// Replace $horse_id and $generations with runtime values
// ------------------------------------------------------------

MATCH path = (h:Horse { horse_id: $horse_id })
             -[:SIRED_BY|BORN_OF*1..$generations]->(ancestor:Horse)
RETURN
    ancestor.horse_name AS ancestor_name,
    ancestor.breed      AS breed,
    length(path)        AS generation
ORDER BY generation ASC;


// ============================================================
// End of Schema
// Equine Profile Standard v1.0
// ============================================================
