// ============================================================
// Equine Profile Standard
// MongoDB Schema v1.0
// Collections: stables, horses, pedigree, owners
// Location: equine-profile-standard/v1.0/database/
// Published by Open Equine — TechXZone Pvt Ltd
// MIT Licensed | openequine.org | contact@openequine.org
// ============================================================

// ------------------------------------------------------------
// Drop collections (safe re-run)
// ------------------------------------------------------------
db.owners.drop();
db.pedigree.drop();
db.horses.drop();
db.stables.drop();

// ============================================================
// COLLECTION 1: stables
// Standalone stable registry. Referenced by owners and horses.
// ============================================================
db.createCollection("stables", {
    validator: {
        $jsonSchema: {
            bsonType: "object",
            required: ["stable_name", "created_at", "updated_at"],
            additionalProperties: false,
            properties: {
                _id: {
                    bsonType: "objectId"
                },
                stable_name: {
                    bsonType: "string",
                    minLength: 1,
                    description: "Name of the stable. Required."
                },
                stable_location: {
                    bsonType: "string",
                    description: "Full free text address as typed by user."
                },
                address_line1: {
                    bsonType: "string"
                },
                address_line2: {
                    bsonType: "string"
                },
                city: {
                    bsonType: "string"
                },
                state: {
                    bsonType: "string"
                },
                country: {
                    bsonType: "string"
                },
                pincode: {
                    bsonType: "string",
                    description: "String to handle leading zeros and international formats."
                },
                created_at: {
                    bsonType: "date",
                    description: "Record creation timestamp. Required."
                },
                updated_at: {
                    bsonType: "date",
                    description: "Record last updated timestamp. Required."
                }
            }
        }
    }
});

db.stables.createIndex({ stable_name: 1 });


// ============================================================
// COLLECTION 2: horses
// Core horse identity collection.
// ============================================================
db.createCollection("horses", {
    validator: {
        $jsonSchema: {
            bsonType: "object",
            required: ["horse_name", "created_at", "updated_at"],
            additionalProperties: false,
            properties: {
                _id: {
                    bsonType: "objectId"
                },
                horse_name: {
                    bsonType: "string",
                    minLength: 1,
                    description: "The horse's registered or commonly known name. Required."
                },
                dob: {
                    bsonType: "string",
                    pattern: "^[0-9]{4}-[0-9]{2}-[0-9]{2}$",
                    description: "Date of birth. ISO 8601 format: YYYY-MM-DD."
                },
                breed: {
                    bsonType: "string",
                    description: "Breed name of the horse."
                },
                gender: {
                    bsonType: "string",
                    enum: ["mare", "stallion", "gelding"],
                    description: "Biological sex or reproductive status of the horse."
                },
                color: {
                    bsonType: "string",
                    description: "Base coat color of the horse."
                },
                ueln: {
                    bsonType: "string",
                    pattern: "^[A-Z0-9]{15}$",
                    description: "Universal Equine Life Number — 15 character alphanumeric ISO standard."
                },
                passport_no: {
                    bsonType: "string",
                    description: "Travel passport number issued by a national authority for international movement of horses."
                },
                microchip: {
                    bsonType: "string",
                    pattern: "^[0-9]{15}$",
                    description: "15-digit ISO 11784/11785 microchip identification number."
                },
                created_at: {
                    bsonType: "date",
                    description: "Record creation timestamp. Required."
                },
                updated_at: {
                    bsonType: "date",
                    description: "Record last updated timestamp. Required."
                }
            }
        }
    }
});

db.horses.createIndex({ horse_name: 1 });
db.horses.createIndex({ breed: 1 });
db.horses.createIndex({ gender: 1 });
db.horses.createIndex({ ueln: 1 },       { unique: true, sparse: true });
db.horses.createIndex({ microchip: 1 },  { unique: true, sparse: true });
db.horses.createIndex({ passport_no: 1 },{ unique: true, sparse: true });


// ============================================================
// COLLECTION 3: pedigree
// Lineage data for a horse.
// Each ancestor has a name field (free text) and an optional
// horse_id reference if the ancestor exists in the horses collection.
// ============================================================
db.createCollection("pedigree", {
    validator: {
        $jsonSchema: {
            bsonType: "object",
            required: ["horse_id", "created_at", "updated_at"],
            additionalProperties: false,
            properties: {
                _id: {
                    bsonType: "objectId"
                },
                horse_id: {
                    bsonType: "objectId",
                    description: "Reference to horses._id. The horse whose pedigree this record describes. Required."
                },

                // Sire (Father)
                sire_name: {
                    bsonType: "string"
                },
                sire_horse_id: {
                    bsonType: "objectId",
                    description: "Reference to horses._id if sire is registered in the database."
                },

                // Dam (Mother)
                dam_name: {
                    bsonType: "string"
                },
                dam_horse_id: {
                    bsonType: "objectId",
                    description: "Reference to horses._id if dam is registered in the database."
                },

                // Paternal Grandparents (Sire line)
                sire_of_sire_name: {
                    bsonType: "string"
                },
                sire_of_sire_horse_id: {
                    bsonType: "objectId",
                    description: "Reference to horses._id if paternal grandsire is registered."
                },

                dam_of_sire_name: {
                    bsonType: "string"
                },
                dam_of_sire_horse_id: {
                    bsonType: "objectId",
                    description: "Reference to horses._id if paternal granddam is registered."
                },

                // Maternal Grandparents (Dam line)
                sire_of_dam_name: {
                    bsonType: "string"
                },
                sire_of_dam_horse_id: {
                    bsonType: "objectId",
                    description: "Reference to horses._id if maternal grandsire is registered."
                },

                dam_of_dam_name: {
                    bsonType: "string"
                },
                dam_of_dam_horse_id: {
                    bsonType: "objectId",
                    description: "Reference to horses._id if maternal granddam is registered."
                },

                // Extended lineage notes
                description: {
                    bsonType: "string",
                    description: "Free text for extended lineage, great-grandparents, bloodline notes."
                },

                created_at: {
                    bsonType: "date",
                    description: "Record creation timestamp. Required."
                },
                updated_at: {
                    bsonType: "date",
                    description: "Record last updated timestamp. Required."
                }
            }
        }
    }
});

db.pedigree.createIndex({ horse_id: 1 }, { unique: true }); // One pedigree record per horse


// ============================================================
// COLLECTION 4: owners
// Owner and breeder information linked to the horse.
// Each record references two stables:
//   owner_stable_id   — the stable where the owner keeps the horse
//   breeder_stable_id — the stable where the horse was bred
// ============================================================
db.createCollection("owners", {
    validator: {
        $jsonSchema: {
            bsonType: "object",
            required: ["horse_id", "owner_name", "owner_contact", "created_at", "updated_at"],
            additionalProperties: false,
            properties: {
                _id: {
                    bsonType: "objectId"
                },
                horse_id: {
                    bsonType: "objectId",
                    description: "Reference to horses._id. Required."
                },
                owner_name: {
                    bsonType: "string",
                    minLength: 1,
                    description: "Full name of the current registered owner. Required."
                },
                owner_contact: {
                    bsonType: "string",
                    minLength: 1,
                    description: "Owner's phone number or email address. Required."
                },
                owner_stable_id: {
                    bsonType: "objectId",
                    description: "Reference to stables._id — stable where the owner keeps the horse."
                },
                breeder_name: {
                    bsonType: "string",
                    description: "Full name of the individual or organisation that bred the horse."
                },
                breeder_contact: {
                    bsonType: "string",
                    description: "Breeder's phone number or email address."
                },
                breeder_stable_id: {
                    bsonType: "objectId",
                    description: "Reference to stables._id — stable where the horse was bred."
                },
                created_at: {
                    bsonType: "date",
                    description: "Record creation timestamp. Required."
                },
                updated_at: {
                    bsonType: "date",
                    description: "Record last updated timestamp. Required."
                }
            }
        }
    }
});

db.owners.createIndex({ horse_id: 1 });

// ============================================================
// End of Schema
// Equine Profile Standard v1.0
// ============================================================
