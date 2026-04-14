# ============================================================
# Equine Profile Standard
# Neo4j Graph Database - Python Implementation Snippets v1.0
# Location: equine-profile-standard/v1.0/database/graph/
# Published by Open Equine - TechXZone Pvt Ltd
# MIT Licensed | openequine.org | contact@openequine.org
# ============================================================

# ------------------------------------------------------------
# INSTALLATION
# pip install neo4j
# ------------------------------------------------------------

from neo4j import GraphDatabase
from datetime import datetime


# ------------------------------------------------------------
# CONNECTION
# ------------------------------------------------------------

URI      = "bolt://localhost:7687"
USERNAME = "neo4j"
PASSWORD = "your-password"

driver = GraphDatabase.driver(URI, auth=(USERNAME, PASSWORD))


# ------------------------------------------------------------
# CREATE - Horse node
# ------------------------------------------------------------

def create_horse(tx, horse: dict):
    tx.run(
        """
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
            h.created_at  = datetime(),
            h.updated_at  = datetime()
        """,
        **horse
    )

# Usage
with driver.session() as session:
    session.execute_write(create_horse, {
        "horse_id":    "uuid-001",
        "horse_name":  "Rajputana Bahadur",
        "dob":         "2019-03-15",
        "breed":       "Marwari",
        "gender":      "stallion",
        "color":       "Bay",
        "ueln":        "IN2019MARW00001",
        "passport_no": "AIMHS-2019-00432",
        "microchip":   "985141002345678"
    })


# ------------------------------------------------------------
# CREATE - Stable node
# ------------------------------------------------------------

def create_stable(tx, stable: dict):
    tx.run(
        """
        MERGE (s:Stable { stable_id: $stable_id })
        SET
            s.stable_name = $stable_name,
            s.city        = $city,
            s.state       = $state,
            s.country     = $country,
            s.pincode     = $pincode,
            s.created_at  = datetime(),
            s.updated_at  = datetime()
        """,
        **stable
    )


# ------------------------------------------------------------
# CREATE - Owner node
# ------------------------------------------------------------

def create_owner(tx, owner: dict):
    tx.run(
        """
        MERGE (o:Owner { owner_id: $owner_id })
        SET
            o.owner_name    = $owner_name,
            o.owner_contact = $owner_contact,
            o.created_at    = datetime(),
            o.updated_at    = datetime()
        """,
        **owner
    )


# ------------------------------------------------------------
# CREATE - Pedigree relationships
# ------------------------------------------------------------

def create_pedigree(tx, foal_id: str, sire_id: str, dam_id: str):
    tx.run(
        """
        MATCH (foal:Horse { horse_id: $foal_id })
        MATCH (sire:Horse { horse_id: $sire_id })
        MATCH (dam:Horse  { horse_id: $dam_id  })
        MERGE (foal)-[:SIRED_BY]->(sire)
        MERGE (foal)-[:BORN_OF]->(dam)
        """,
        foal_id=foal_id,
        sire_id=sire_id,
        dam_id=dam_id
    )


# ------------------------------------------------------------
# CREATE - Ownership relationship
# ------------------------------------------------------------

def assign_owner(tx, horse_id: str, owner_id: str, since: str):
    tx.run(
        """
        MATCH (h:Horse { horse_id: $horse_id })
        MATCH (o:Owner { owner_id: $owner_id })
        MERGE (h)-[:OWNED_BY { since: $since }]->(o)
        """,
        horse_id=horse_id,
        owner_id=owner_id,
        since=since
    )


# ------------------------------------------------------------
# CREATE - Stable relationship
# ------------------------------------------------------------

def assign_stable(tx, horse_id: str, stable_id: str):
    tx.run(
        """
        MATCH (h:Horse  { horse_id:  $horse_id  })
        MATCH (s:Stable { stable_id: $stable_id })
        MERGE (h)-[:KEPT_AT]->(s)
        """,
        horse_id=horse_id,
        stable_id=stable_id
    )


# ------------------------------------------------------------
# READ - Get horse by ID
# ------------------------------------------------------------

def get_horse_by_id(tx, horse_id: str):
    result = tx.run(
        "MATCH (h:Horse { horse_id: $horse_id }) RETURN h",
        horse_id=horse_id
    )
    record = result.single()
    return dict(record["h"]) if record else None

with driver.session() as session:
    horse = session.execute_read(get_horse_by_id, "uuid-001")
    print(horse)


# ------------------------------------------------------------
# READ - Get horse by UELN
# ------------------------------------------------------------

def get_horse_by_ueln(tx, ueln: str):
    result = tx.run(
        "MATCH (h:Horse { ueln: $ueln }) RETURN h",
        ueln=ueln
    )
    record = result.single()
    return dict(record["h"]) if record else None


# ------------------------------------------------------------
# READ - Get full pedigree (up to 6 generations)
# Global Equine Graph traversal
# ------------------------------------------------------------

def get_pedigree(tx, horse_name: str, generations: int = 6):
    result = tx.run(
        """
        MATCH path = (h:Horse { horse_name: $horse_name })
                     -[:SIRED_BY|BORN_OF*1..$generations]->(ancestor:Horse)
        RETURN
            ancestor.horse_name AS ancestor_name,
            ancestor.breed      AS breed,
            length(path)        AS generation
        ORDER BY generation ASC
        """,
        horse_name=horse_name,
        generations=generations
    )
    return [
        {
            "ancestor_name": record["ancestor_name"],
            "breed":         record["breed"],
            "generation":    record["generation"]
        }
        for record in result
    ]

with driver.session() as session:
    pedigree = session.execute_read(get_pedigree, "Rajputana Bahadur")
    for ancestor in pedigree:
        print(f"Generation {ancestor['generation']}: {ancestor['ancestor_name']} ({ancestor['breed']})")


# ------------------------------------------------------------
# READ - Get all horses at a stable
# ------------------------------------------------------------

def get_horses_by_stable(tx, stable_id: str):
    result = tx.run(
        """
        MATCH (h:Horse)-[:KEPT_AT]->(s:Stable { stable_id: $stable_id })
        RETURN h
        """,
        stable_id=stable_id
    )
    return [dict(record["h"]) for record in result]


# ------------------------------------------------------------
# READ - Get all horses by breed
# ------------------------------------------------------------

def get_horses_by_breed(tx, breed: str):
    result = tx.run(
        """
        MATCH (h:Horse { breed: $breed })
        RETURN h
        ORDER BY h.horse_name ASC
        """,
        breed=breed
    )
    return [dict(record["h"]) for record in result]


# ------------------------------------------------------------
# UPDATE - Horse profile
# ------------------------------------------------------------

def update_horse(tx, horse_id: str, fields: dict):
    set_clauses = ", ".join([f"h.{k} = ${k}" for k in fields.keys()])
    tx.run(
        f"""
        MATCH (h:Horse {{ horse_id: $horse_id }})
        SET {set_clauses}, h.updated_at = datetime()
        """,
        horse_id=horse_id,
        **fields
    )


# ------------------------------------------------------------
# DELETE - Horse and all related relationships
# ------------------------------------------------------------

def delete_horse(tx, horse_id: str):
    tx.run(
        "MATCH (h:Horse { horse_id: $horse_id }) DETACH DELETE h",
        horse_id=horse_id
    )


# ------------------------------------------------------------
# CLOSE CONNECTION
# ------------------------------------------------------------

driver.close()

# ============================================================
# End of Snippets
# Equine Profile Standard v1.0
# ============================================================
