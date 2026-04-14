// ============================================================
// Equine Profile Standard
// ArangoDB Multi-Model Schema v1.0
// Collections: horses, stables, owners, breeders
// Edge Collections: sired_by, born_of, owned_by, bred_by,
//                   kept_at, bred_at, manages
// Graph: equine_graph
// Location: equine-profile-standard/v1.0/database/graph/
// Published by Open Equine — TechXZone Pvt Ltd
// MIT Licensed | openequine.org | contact@openequine.org
// ============================================================

// ------------------------------------------------------------
// INSTALLATION
// npm install arangojs
// ------------------------------------------------------------

import { Database } from 'arangojs';


// ------------------------------------------------------------
// CONNECTION
// ------------------------------------------------------------

const db = new Database({
    url:          "http://localhost:8529",
    databaseName: "equine",
    auth: { username: "root", password: "your-password" }
});


// ------------------------------------------------------------
// COLLECTIONS — Document (nodes)
//
// horses
//   _key         String  required  unique identifier
//   horse_name   String  required
//   dob          String  ISO 8601 date: YYYY-MM-DD
//   breed        String
//   gender       String  mare | stallion | gelding
//   color        String
//   ueln         String  15 char alphanumeric — Universal Equine Life Number
//   passport_no  String  travel passport number issued by national authority
//   microchip    String  15-digit ISO 11784/11785 microchip number
//   created_at   String  ISO 8601 datetime
//   updated_at   String  ISO 8601 datetime
//
// stables
//   _key            String  required  unique identifier
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
//
// owners
//   _key           String  required  unique identifier
//   owner_name     String  required
//   owner_contact  String  required  phone number or email address
//   created_at     String  ISO 8601 datetime
//   updated_at     String  ISO 8601 datetime
//
// breeders
//   _key            String  required  unique identifier
//   breeder_name    String  required
//   breeder_contact String  phone number or email address
//   created_at      String  ISO 8601 datetime
//   updated_at      String  ISO 8601 datetime
// ------------------------------------------------------------

await db.createCollection("horses",   { type: 2 });
await db.createCollection("stables",  { type: 2 });
await db.createCollection("owners",   { type: 2 });
await db.createCollection("breeders", { type: 2 });


// ------------------------------------------------------------
// COLLECTIONS — Edge (relationships)
//
// sired_by  (Horse) -> (Horse)   sire (father) relationship
// born_of   (Horse) -> (Horse)   dam (mother) relationship
// owned_by  (Horse) -> (Owner)   current ownership  property: since
// bred_by   (Horse) -> (Breeder) breeding attribution
// kept_at   (Horse) -> (Stable)  current stable location
// bred_at   (Horse) -> (Stable)  stable where horse was bred
// manages   (Owner) -> (Stable)  owner manages stable
// ------------------------------------------------------------

await db.createCollection("sired_by", { type: 3 });
await db.createCollection("born_of",  { type: 3 });
await db.createCollection("owned_by", { type: 3 });
await db.createCollection("bred_by",  { type: 3 });
await db.createCollection("kept_at",  { type: 3 });
await db.createCollection("bred_at",  { type: 3 });
await db.createCollection("manages",  { type: 3 });


// ------------------------------------------------------------
// NAMED GRAPH
// ------------------------------------------------------------

await db.createGraph("equine_graph", {
    edgeDefinitions: [
        { collection: "sired_by", from: ["horses"],  to: ["horses"]   },
        { collection: "born_of",  from: ["horses"],  to: ["horses"]   },
        { collection: "owned_by", from: ["horses"],  to: ["owners"]   },
        { collection: "bred_by",  from: ["horses"],  to: ["breeders"] },
        { collection: "kept_at",  from: ["horses"],  to: ["stables"]  },
        { collection: "bred_at",  from: ["horses"],  to: ["stables"]  },
        { collection: "manages",  from: ["owners"],  to: ["stables"]  }
    ]
});


// ------------------------------------------------------------
// INDEXES
// ------------------------------------------------------------

const horsesCol  = db.collection("horses");
const stablesCol = db.collection("stables");
const ownersCol  = db.collection("owners");

await horsesCol.ensureIndex({ type: "persistent", fields: ["ueln"],        unique: true,  sparse: true  });
await horsesCol.ensureIndex({ type: "persistent", fields: ["microchip"],   unique: true,  sparse: true  });
await horsesCol.ensureIndex({ type: "persistent", fields: ["passport_no"], unique: true,  sparse: true  });
await horsesCol.ensureIndex({ type: "persistent", fields: ["horse_name"],  unique: false, sparse: false });
await horsesCol.ensureIndex({ type: "persistent", fields: ["breed"],       unique: false, sparse: false });
await horsesCol.ensureIndex({ type: "persistent", fields: ["gender"],      unique: false, sparse: false });
await stablesCol.ensureIndex({ type: "persistent", fields: ["country", "city"] });
await ownersCol.ensureIndex({  type: "persistent", fields: ["owner_name"]  });


// ------------------------------------------------------------
// CREATE — Horse document
//
// @param {Object} horse
// @returns {Object} saved document with _id and _key
// ------------------------------------------------------------

async function createHorse(horse) {
    return await horsesCol.save({
        ...horse,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
    });
}


// ------------------------------------------------------------
// CREATE — Stable document
//
// @param {Object} stable
// @returns {Object} saved document with _id and _key
// ------------------------------------------------------------

async function createStable(stable) {
    return await stablesCol.save({
        ...stable,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
    });
}


// ------------------------------------------------------------
// CREATE — Owner document
//
// @param {Object} owner
// @returns {Object} saved document with _id and _key
// ------------------------------------------------------------

async function createOwner(owner) {
    return await ownersCol.save({
        ...owner,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
    });
}


// ------------------------------------------------------------
// CREATE — Pedigree relationships
//
// @param {string} foalId  - horses/_key
// @param {string} sireId  - horses/_key
// @param {string} damId   - horses/_key
// ------------------------------------------------------------

async function createPedigree(foalId, sireId, damId) {
    await db.collection("sired_by").save({ _from: `horses/${foalId}`, _to: `horses/${sireId}` });
    await db.collection("born_of").save({  _from: `horses/${foalId}`, _to: `horses/${damId}`  });
}


// ------------------------------------------------------------
// CREATE — Ownership relationship
//
// @param {string} horseId  - horses/_key
// @param {string} ownerId  - owners/_key
// @param {string} since    - ISO 8601 date
// ------------------------------------------------------------

async function assignOwner(horseId, ownerId, since) {
    await db.collection("owned_by").save({
        _from: `horses/${horseId}`,
        _to:   `owners/${ownerId}`,
        since
    });
}


// ------------------------------------------------------------
// CREATE — Stable relationship
//
// @param {string} horseId   - horses/_key
// @param {string} stableId  - stables/_key
// ------------------------------------------------------------

async function assignStable(horseId, stableId) {
    await db.collection("kept_at").save({
        _from: `horses/${horseId}`,
        _to:   `stables/${stableId}`
    });
}


// ------------------------------------------------------------
// READ — Get horse by UELN using AQL
//
// @param {string} ueln
// @returns {Object|null}
// ------------------------------------------------------------

async function getHorseByUeln(ueln) {
    const cursor = await db.query(
        `FOR h IN horses FILTER h.ueln == @ueln RETURN h`,
        { ueln }
    );
    const result = await cursor.all();
    return result[0] || null;
}


// ------------------------------------------------------------
// READ — Pedigree traversal using AQL
// Retrieve all ancestors up to N generations
//
// @param {string} horseKey   - horses/_key
// @param {number} depth      - default 6
// @returns {Array}
// ------------------------------------------------------------

async function getPedigree(horseKey, depth = 6) {
    const cursor = await db.query(
        `FOR horse IN horses
         FILTER horse._key == @horse_key
         FOR ancestor, edge, path IN 1..@depth
             OUTBOUND horse
             sired_by, born_of
             RETURN {
                 ancestor_name: ancestor.horse_name,
                 breed:         ancestor.breed,
                 generation:    LENGTH(path.edges)
             }`,
        { horse_key: horseKey, depth }
    );
    return await cursor.all();
}


// ------------------------------------------------------------
// READ — Get all horses by breed using AQL
//
// @param {string} breed
// @returns {Array}
// ------------------------------------------------------------

async function getHorsesByBreed(breed) {
    const cursor = await db.query(
        `FOR h IN horses
         FILTER h.breed == @breed
         SORT h.horse_name ASC
         RETURN h`,
        { breed }
    );
    return await cursor.all();
}


// ------------------------------------------------------------
// UPDATE — Horse document
//
// @param {string} horseKey
// @param {Object} fields
// ------------------------------------------------------------

async function updateHorse(horseKey, fields) {
    await horsesCol.update(horseKey, {
        ...fields,
        updated_at: new Date().toISOString()
    });
}


// ------------------------------------------------------------
// DELETE — Horse and all edges
//
// @param {string} horseKey
// ------------------------------------------------------------

async function deleteHorse(horseKey) {
    const edgeCollections = ["sired_by","born_of","owned_by","bred_by","kept_at","bred_at"];
    for (const col of edgeCollections) {
        await db.query(
            `FOR e IN ${col}
             FILTER e._from == @id OR e._to == @id
             REMOVE e IN ${col}`,
            { id: `horses/${horseKey}` }
        );
    }
    await horsesCol.remove(horseKey);
}

export {
    createHorse,
    createStable,
    createOwner,
    createPedigree,
    assignOwner,
    assignStable,
    getHorseByUeln,
    getPedigree,
    getHorsesByBreed,
    updateHorse,
    deleteHorse
};

// ============================================================
// End of Schema
// Equine Profile Standard v1.0
// ============================================================
