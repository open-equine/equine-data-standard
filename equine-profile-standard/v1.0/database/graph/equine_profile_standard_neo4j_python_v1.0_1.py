# ============================================================
# Equine Profile Standard
# Neo4j Graph Database - Python Implementation v1.0
# Location: equine-profile-standard/v1.0/database/graph/
# Published by Open Equine - TechXZone Pvt Ltd
# MIT Licensed | openequine.org | contact@openequine.org
# ============================================================

# ------------------------------------------------------------
# INSTALLATION
# pip install neo4j
# ------------------------------------------------------------

from neo4j import GraphDatabase
from typing import Optional


# ------------------------------------------------------------
# CONNECTION
# ------------------------------------------------------------

URI      = "bolt://localhost:7687"
USERNAME = "neo4j"
PASSWORD = "your-password"

driver = GraphDatabase.driver(URI, auth=(USERNAME, PASSWORD))


# ------------------------------------------------------------
# CREATE - Horse node
#
# @param horse dict with keys:
#   horse_id     str  required  unique identifier
#   horse_name   str  required
#   dob          str  ISO 8601: YYYY-MM-DD
#   breed        str
#   gender       str  mare | stallion | gelding
#   color        str
#   ueln         str  15 char alphanumeric
#   passport_no  str
#   microchip    str  15-digit ISO 11784/11785
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


# ------------------------------------------------------------
# CREATE - Stable node
#
# @param stable dict with keys:
#   stable_id       str  required  unique identifier
#   stable_name     str  required
#   stable_location str
#   address_line1   str
#   address_line2   str
#   city            str
#   state           str
#   country         str
#   pincode         str
# ------------------------------------------------------------

def create_stable(tx, stable: dict):
    tx.run(
        """
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
            s.created_at      = datetime(),
            s.updated_at      = datetime()
        """,
        **stable
    )


# ------------------------------------------------------------
# CREATE - Owner node
#
# @param owner dict with keys:
#   owner_id       str  required  unique identifier
#   owner_name     str  required
#   owner_contact  str  required
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
# CREATE - Breeder node
#
# @param breeder dict with keys:
#   breeder_id      str  required  unique identifier
#   breeder_name    str  required
#   breeder_contact str
# ------------------------------------------------------------

def create_breeder(tx, breeder: dict):
    tx.run(
        """
        MERGE (b:Breeder { breeder_id: $breeder_id })
        SET
            b.breeder_name    = $breeder_name,
            b.breeder_contact = $breeder_contact,
            b.created_at      = datetime(),
            b.updated_at      = datetime()
        """,
        **breeder
    )


# ------------------------------------------------------------
# CREATE - Pedigree relationships
#
# @param foal_id str
# @param sire_id str
# @param dam_id  str
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
#
# @param horse_id str
# @param owner_id str
# @param since    str  ISO 8601 date ownership began
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
#
# @param horse_id  str
# @param stable_id str
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
#
# @param  horse_id str
# @return dict | None
# ------------------------------------------------------------

def get_horse_by_id(tx, horse_id: str) -> Optional[dict]:
    result = tx.run(
        "MATCH (h:Horse { horse_id: $horse_id }) RETURN h",
        horse_id=horse_id
    )
    record = result.single()
    return dict(record["h"]) if record else None


# ------------------------------------------------------------
# READ - Get horse by UELN
#
# @param  ueln str
# @return dict | None
# ------------------------------------------------------------

def get_horse_by_ueln(tx, ueln: str) -> Optional[dict]:
    result = tx.run(
        "MATCH (h:Horse { ueln: $ueln }) RETURN h",
        ueln=ueln
    )
    record = result.single()
    return dict(record["h"]) if record else None


# ------------------------------------------------------------
# READ - Pedigree traversal
# Retrieve all ancestors up to N generations
#
# @param  horse_id    str
# @param  generations int  default 6
# @return list[dict]
# ------------------------------------------------------------

def get_pedigree(tx, horse_id: str, generations: int = 6) -> list:
    result = tx.run(
        """
        MATCH path = (h:Horse { horse_id: $horse_id })
                     -[:SIRED_BY|BORN_OF*1..$generations]->(ancestor:Horse)
        RETURN
            ancestor.horse_name AS ancestor_name,
            ancestor.breed      AS breed,
            length(path)        AS generation
        ORDER BY generation ASC
        """,
        horse_id=horse_id,
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


# ------------------------------------------------------------
# READ - Get all horses at a stable
#
# @param  stable_id str
# @return list[dict]
# ------------------------------------------------------------

def get_horses_by_stable(tx, stable_id: str) -> list:
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
#
# @param  breed str
# @return list[dict]
# ------------------------------------------------------------

def get_horses_by_breed(tx, breed: str) -> list:
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
#
# @param horse_id str
# @param fields   dict  key-value pairs to update
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
# DELETE - Horse and all relationships
#
# @param horse_id str
# ------------------------------------------------------------

def delete_horse(tx, horse_id: str):
    tx.run(
        "MATCH (h:Horse { horse_id: $horse_id }) DETACH DELETE h",
        horse_id=horse_id
    )


# ------------------------------------------------------------
# CLOSE CONNECTION
# ------------------------------------------------------------

def close():
    driver.close()

# ============================================================
# End of Implementation
# Equine Profile Standard v1.0
# ============================================================
