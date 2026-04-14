# Equine Profile Standard — Neo4j Graph Database

**Version:** 1.0  
**Published by:** Open Equine — TechXZone Pvt Ltd  
**Website:** openequine.org  
**Contact:** contact@openequine.org  
**Licence:** MIT  

---

## What Is This?

This folder contains the Neo4j graph database implementation of the Equine Profile Standard v1.0.

A graph database models horse data as nodes and relationships — enabling recursive pedigree traversal, ownership chains, and planetary-scale connectivity as the foundation of the Global Equine Graph.

---

## Files

| File | Purpose |
|------|---------|
| `equine_profile_standard_neo4j_v1.0.cql` | Schema — constraints, indexes, node definitions, relationship definitions |
| `equine_profile_standard_neo4j_nodejs_v1.0.js` | Ready-to-use Node.js implementation using `neo4j-driver` |
| `equine_profile_standard_neo4j_python_v1.0.py` | Ready-to-use Python implementation using `neo4j` package |

---

## Prerequisites

- Neo4j 5.x or above
- For Node.js: `npm install neo4j-driver`
- For Python: `pip install neo4j`

---

## Step 1 — Run the Schema

Open `equine_profile_standard_neo4j_v1.0.cql` and run each section in order against your Neo4j instance:

1. Constraints
2. Indexes
3. Example node creation
4. Example relationship creation

**Neo4j Browser** — paste and run each block separately.  
**Neo4j Desktop** — use the built-in Cypher editor.  
**CLI** — `cypher-shell -u neo4j -p your-password < equine_profile_standard_neo4j_v1.0.cql`

---

## Step 2 — Connect Your Application

### Node.js

```javascript
import neo4j from 'neo4j-driver';

const driver = neo4j.driver(
    'bolt://localhost:7687',
    neo4j.auth.basic('neo4j', 'your-password')
);

const session = driver.session();
```

### Python

```python
from neo4j import GraphDatabase

driver = GraphDatabase.driver(
    "bolt://localhost:7687",
    auth=("neo4j", "your-password")
)
```

---

## Step 3 — Create a Horse Profile

### Node.js

```javascript
await session.run(
    `MERGE (h:Horse { horse_id: $horse_id })
     SET
         h.horse_name = $horse_name,
         h.breed      = $breed,
         h.gender     = $gender,
         h.dob        = $dob,
         h.created_at = datetime(),
         h.updated_at = datetime()`,
    {
        horse_id:   "uuid-001",
        horse_name: "Rajputana Bahadur",
        breed:      "Marwari",
        gender:     "stallion",
        dob:        "2019-03-15"
    }
);
```

### Python

```python
with driver.session() as session:
    session.execute_write(lambda tx: tx.run(
        """
        MERGE (h:Horse { horse_id: $horse_id })
        SET
            h.horse_name = $horse_name,
            h.breed      = $breed,
            h.gender     = $gender,
            h.dob        = $dob,
            h.created_at = datetime(),
            h.updated_at = datetime()
        """,
        horse_id="uuid-001",
        horse_name="Rajputana Bahadur",
        breed="Marwari",
        gender="stallion",
        dob="2019-03-15"
    ))
```

---

## Step 4 — Link Pedigree

### Node.js

```javascript
await session.run(
    `MATCH (foal:Horse { horse_id: $foalId })
     MATCH (sire:Horse { horse_id: $sireId })
     MATCH (dam:Horse  { horse_id: $damId  })
     MERGE (foal)-[:SIRED_BY]->(sire)
     MERGE (foal)-[:BORN_OF]->(dam)`,
    { foalId: "uuid-001", sireId: "uuid-002", damId: "uuid-003" }
);
```

### Python

```python
with driver.session() as session:
    session.execute_write(lambda tx: tx.run(
        """
        MATCH (foal:Horse { horse_id: $foal_id })
        MATCH (sire:Horse { horse_id: $sire_id })
        MATCH (dam:Horse  { horse_id: $dam_id  })
        MERGE (foal)-[:SIRED_BY]->(sire)
        MERGE (foal)-[:BORN_OF]->(dam)
        """,
        foal_id="uuid-001",
        sire_id="uuid-002",
        dam_id="uuid-003"
    ))
```

---

## Step 5 — Traverse the Global Equine Graph

Retrieve all ancestors of a horse up to 6 generations:

### Node.js

```javascript
const result = await session.run(
    `MATCH path = (h:Horse { horse_name: $horseName })
                  -[:SIRED_BY|BORN_OF*1..6]->(ancestor:Horse)
     RETURN
         ancestor.horse_name AS ancestor_name,
         ancestor.breed      AS breed,
         length(path)        AS generation
     ORDER BY generation ASC`,
    { horseName: "Rajputana Bahadur" }
);

result.records.forEach(record => {
    console.log(`Generation ${record.get('generation')}: ${record.get('ancestor_name')}`);
});
```

### Python

```python
with driver.session() as session:
    result = session.execute_read(lambda tx: tx.run(
        """
        MATCH path = (h:Horse { horse_name: $horse_name })
                     -[:SIRED_BY|BORN_OF*1..6]->(ancestor:Horse)
        RETURN
            ancestor.horse_name AS ancestor_name,
            ancestor.breed      AS breed,
            length(path)        AS generation
        ORDER BY generation ASC
        """,
        horse_name="Rajputana Bahadur"
    ).data())

    for record in result:
        print(f"Generation {record['generation']}: {record['ancestor_name']}")
```

---

## Nodes

| Node | Required Properties | Description |
|------|-------------------|-------------|
| `Horse` | `horse_id`, `horse_name` | Core equine identity |
| `Stable` | `stable_id`, `stable_name` | Stable registry |
| `Owner` | `owner_id`, `owner_name`, `owner_contact` | Ownership record |
| `Breeder` | `breeder_id`, `breeder_name` | Breeding attribution |

---

## Relationships

| Relationship | From | To | Description |
|-------------|------|----|-------------|
| `SIRED_BY` | Horse | Horse | Sire (father) |
| `BORN_OF` | Horse | Horse | Dam (mother) |
| `OWNED_BY` | Horse | Owner | Current ownership |
| `BRED_BY` | Horse | Breeder | Breeding attribution |
| `KEPT_AT` | Horse | Stable | Current stable location |
| `BRED_AT` | Horse | Stable | Stable where horse was bred |
| `MANAGES` | Owner | Stable | Owner manages stable |

---

## Licence

MIT License — Copyright (c) 2026 TechXZone Pvt Ltd

See [LICENSE.txt](../../../../LICENSE.txt) for full terms.
