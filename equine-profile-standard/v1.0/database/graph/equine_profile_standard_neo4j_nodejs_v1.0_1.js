// ============================================================
// Equine Profile Standard
// Neo4j Graph Database — Node.js Implementation v1.0
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
//
// @param {Object} horse
// @param {string} horse.horse_id     - unique identifier
// @param {string} horse.horse_name   - required
// @param {string} horse.dob          - ISO 8601: YYYY-MM-DD
// @param {string} horse.breed
// @param {string} horse.gender       - mare | stallion | gelding
// @param {string} horse.color
// @param {string} horse.ueln         - 15 char alphanumeric
// @param {string} horse.passport_no
// @param {string} horse.microchip    - 15-digit ISO 11784/11785
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


// ------------------------------------------------------------
// CREATE — Stable node
//
// @param {Object} stable
// @param {string} stable.stable_id       - unique identifier
// @param {string} stable.stable_name     - required
// @param {string} stable.stable_location
// @param {string} stable.address_line1
// @param {string} stable.address_line2
// @param {string} stable.city
// @param {string} stable.state
// @param {string} stable.country
// @param {string} stable.pincode
// ------------------------------------------------------------

async function createStable(stable) {
    const result = await session.run(
        `MERGE (s:Stable { stable_id: $stable_id })
         SET
             s.stable_name     = $stable_name,
             s.stable_location = $stable_location,
             s.address_line1   = $address_line1,
             s.address_line2   = $address_line2,
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
//
// @param {Object} owner
// @param {string} owner.owner_id       - unique identifier
// @param {string} owner.owner_name     - required
// @param {string} owner.owner_contact  - required
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
// CREATE — Breeder node
//
// @param {Object} breeder
// @param {string} breeder.breeder_id      - unique identifier
// @param {string} breeder.breeder_name    - required
// @param {string} breeder.breeder_contact
// ------------------------------------------------------------

async function createBreeder(breeder) {
    const result = await session.run(
        `MERGE (b:Breeder { breeder_id: $breeder_id })
         SET
             b.breeder_name    = $breeder_name,
             b.breeder_contact = $breeder_contact,
             b.created_at      = datetime(),
             b.updated_at      = datetime()
         RETURN b`,
        breeder
    );
    return result.records[0].get('b').properties;
}


// ------------------------------------------------------------
// CREATE — Pedigree relationships
//
// @param {string} foalId
// @param {string} sireId
// @param {string} damId
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
//
// @param {string} horseId
// @param {string} ownerId
// @param {string} since   - ISO 8601 date ownership began
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
// CREATE — Stable relationship
//
// @param {string} horseId
// @param {string} stableId
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
//
// @param {string} horseId
// @returns {Object|null}
// ------------------------------------------------------------

async function getHorseById(horseId) {
    const result = await session.run(
        `MATCH (h:Horse { horse_id: $horseId }) RETURN h`,
        { horseId }
    );
    if (result.records.length === 0) return null;
    return result.records[0].get('h').properties;
}


// ------------------------------------------------------------
// READ — Get horse by UELN
//
// @param {string} ueln
// @returns {Object|null}
// ------------------------------------------------------------

async function getHorseByUeln(ueln) {
    const result = await session.run(
        `MATCH (h:Horse { ueln: $ueln }) RETURN h`,
        { ueln }
    );
    if (result.records.length === 0) return null;
    return result.records[0].get('h').properties;
}


// ------------------------------------------------------------
// READ — Pedigree traversal
// Retrieve all ancestors up to N generations
//
// @param {string} horseId
// @param {number} generations  - default 6
// @returns {Array}
// ------------------------------------------------------------

async function getPedigree(horseId, generations = 6) {
    const result = await session.run(
        `MATCH path = (h:Horse { horse_id: $horseId })
                      -[:SIRED_BY|BORN_OF*1..$generations]->(ancestor:Horse)
         RETURN
             ancestor.horse_name AS ancestor_name,
             ancestor.breed      AS breed,
             length(path)        AS generation
         ORDER BY generation ASC`,
        { horseId, generations: neo4j.int(generations) }
    );
    return result.records.map(r => ({
        ancestor_name: r.get('ancestor_name'),
        breed:         r.get('breed'),
        generation:    r.get('generation').toNumber()
    }));
}


// ------------------------------------------------------------
// READ — Get all horses at a stable
//
// @param {string} stableId
// @returns {Array}
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
//
// @param {string} breed
// @returns {Array}
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
//
// @param {string} horseId
// @param {Object} fields   - key-value pairs to update
// @returns {Object}
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
// DELETE — Horse and all relationships
//
// @param {string} horseId
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

export {
    createHorse,
    createStable,
    createOwner,
    createBreeder,
    createPedigree,
    assignOwner,
    assignStable,
    getHorseById,
    getHorseByUeln,
    getPedigree,
    getHorsesByStable,
    getHorsesByBreed,
    updateHorse,
    deleteHorse,
    close
};

// ============================================================
// End of Implementation
// Equine Profile Standard v1.0
// ============================================================
