// ============================================================
// Equine Profile Standard
// Neo4j Graph Database — Node.js Implementation Snippets v1.0
// Location: equine-profile-standard/v1.0/database/graph/
// Published by Open Equine — TechXZone Pvt Ltd
// MIT Licensed | openequine.org | contact@openequine.org
// ============================================================

// ------------------------------------------------------------
// INSTALLATION
// npm install neo4j-driver
// ------------------------------------------------------------

import neo4j from 'neo4j-driver';

// ------------------------------------------------------------
// CONNECTION
// ------------------------------------------------------------

const driver = neo4j.driver(
    'bolt://localhost:7687',
    neo4j.auth.basic('neo4j', 'your-password')
);

const session = driver.session({ database: 'neo4j' });


// ------------------------------------------------------------
// CREATE — Horse node
// ------------------------------------------------------------

async function createHorse(horse) {
    const result = await session.run(
        `MERGE (h:Horse { horse_id: $horse_id })
         SET
             h.horse_name  = $horse_name,
             h.dob         = $dob,
             h.breed       = $breed,
             h.gender      = $gender,
             h.color       = $color,
             h.ueln        = $ueln,
             h.passport_no = $passport_no,
             h.microchip   = $microchip,
             h.created_at  = datetime(),
             h.updated_at  = datetime()
         RETURN h`,
        horse
    );
    return result.records[0].get('h').properties;
}

// Usage
await createHorse({
    horse_id:    'uuid-001',
    horse_name:  'Rajputana Bahadur',
    dob:         '2019-03-15',
    breed:       'Marwari',
    gender:      'stallion',
    color:       'Bay',
    ueln:        'IN2019MARW00001',
    passport_no: 'AIMHS-2019-00432',
    microchip:   '985141002345678'
});


// ------------------------------------------------------------
// CREATE — Stable node
// ------------------------------------------------------------

async function createStable(stable) {
    const result = await session.run(
        `MERGE (s:Stable { stable_id: $stable_id })
         SET
             s.stable_name     = $stable_name,
             s.city            = $city,
             s.state           = $state,
             s.country         = $country,
             s.pincode         = $pincode,
             s.created_at      = datetime(),
             s.updated_at      = datetime()
         RETURN s`,
        stable
    );
    return result.records[0].get('s').properties;
}


// ------------------------------------------------------------
// CREATE — Owner node
// ------------------------------------------------------------

async function createOwner(owner) {
    const result = await session.run(
        `MERGE (o:Owner { owner_id: $owner_id })
         SET
             o.owner_name    = $owner_name,
             o.owner_contact = $owner_contact,
             o.created_at    = datetime(),
             o.updated_at    = datetime()
         RETURN o`,
        owner
    );
    return result.records[0].get('o').properties;
}


// ------------------------------------------------------------
// CREATE — Pedigree relationships
// ------------------------------------------------------------

async function createPedigree(foalId, sireId, damId) {
    await session.run(
        `MATCH (foal:Horse { horse_id: $foalId })
         MATCH (sire:Horse { horse_id: $sireId })
         MATCH (dam:Horse  { horse_id: $damId  })
         MERGE (foal)-[:SIRED_BY]->(sire)
         MERGE (foal)-[:BORN_OF]->(dam)`,
        { foalId, sireId, damId }
    );
}


// ------------------------------------------------------------
// CREATE — Ownership relationship
// ------------------------------------------------------------

async function assignOwner(horseId, ownerId, since) {
    await session.run(
        `MATCH (h:Horse { horse_id: $horseId })
         MATCH (o:Owner { owner_id: $ownerId })
         MERGE (h)-[:OWNED_BY { since: $since }]->(o)`,
        { horseId, ownerId, since }
    );
}


// ------------------------------------------------------------
// CREATE — Stable relationships
// ------------------------------------------------------------

async function assignStable(horseId, stableId) {
    await session.run(
        `MATCH (h:Horse  { horse_id:  $horseId  })
         MATCH (s:Stable { stable_id: $stableId })
         MERGE (h)-[:KEPT_AT]->(s)`,
        { horseId, stableId }
    );
}


// ------------------------------------------------------------
// READ — Get horse by ID
// ------------------------------------------------------------

async function getHorseById(horseId) {
    const result = await session.run(
        `MATCH (h:Horse { horse_id: $horseId })
         RETURN h`,
        { horseId }
    );
    if (result.records.length === 0) return null;
    return result.records[0].get('h').properties;
}


// ------------------------------------------------------------
// READ — Get horse by UELN
// ------------------------------------------------------------

async function getHorseByUeln(ueln) {
    const result = await session.run(
        `MATCH (h:Horse { ueln: $ueln })
         RETURN h`,
        { ueln }
    );
    if (result.records.length === 0) return null;
    return result.records[0].get('h').properties;
}


// ------------------------------------------------------------
// READ — Get full pedigree (up to 6 generations)
// Global Equine Graph traversal
// ------------------------------------------------------------

async function getPedigree(horseName, generations = 6) {
    const result = await session.run(
        `MATCH path = (h:Horse { horse_name: $horseName })
                      -[:SIRED_BY|BORN_OF*1..$generations]->(ancestor:Horse)
         RETURN
             ancestor.horse_name AS ancestor_name,
             ancestor.breed      AS breed,
             length(path)        AS generation
         ORDER BY generation ASC`,
        { horseName, generations: neo4j.int(generations) }
    );
    return result.records.map(r => ({
        ancestor_name: r.get('ancestor_name'),
        breed:         r.get('breed'),
        generation:    r.get('generation').toNumber()
    }));
}


// ------------------------------------------------------------
// READ — Get all horses at a stable
// ------------------------------------------------------------

async function getHorsesByStable(stableId) {
    const result = await session.run(
        `MATCH (h:Horse)-[:KEPT_AT]->(s:Stable { stable_id: $stableId })
         RETURN h`,
        { stableId }
    );
    return result.records.map(r => r.get('h').properties);
}


// ------------------------------------------------------------
// READ — Get all horses by breed
// ------------------------------------------------------------

async function getHorsesByBreed(breed) {
    const result = await session.run(
        `MATCH (h:Horse { breed: $breed })
         RETURN h
         ORDER BY h.horse_name ASC`,
        { breed }
    );
    return result.records.map(r => r.get('h').properties);
}


// ------------------------------------------------------------
// UPDATE — Horse profile
// ------------------------------------------------------------

async function updateHorse(horseId, fields) {
    const setClauses = Object.keys(fields)
        .map(key => `h.${key} = $${key}`)
        .join(', ');

    const result = await session.run(
        `MATCH (h:Horse { horse_id: $horseId })
         SET ${setClauses}, h.updated_at = datetime()
         RETURN h`,
        { horseId, ...fields }
    );
    return result.records[0].get('h').properties;
}


// ------------------------------------------------------------
// DELETE — Horse and all related relationships
// ------------------------------------------------------------

async function deleteHorse(horseId) {
    await session.run(
        `MATCH (h:Horse { horse_id: $horseId })
         DETACH DELETE h`,
        { horseId }
    );
}


// ------------------------------------------------------------
// CLOSE CONNECTION
// ------------------------------------------------------------

async function close() {
    await session.close();
    await driver.close();
}

// ============================================================
// End of Snippets
// Equine Profile Standard v1.0
// ============================================================
