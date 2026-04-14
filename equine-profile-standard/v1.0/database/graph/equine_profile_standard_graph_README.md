# Equine Profile Standard — Graph Database

**Version:** 1.0
**Published by:** Open Equine — TechXZone Pvt Ltd
**Website:** openequine.org
**Contact:** contact@openequine.org
**Licence:** MIT

---

## What Is This?

This folder contains the graph database implementations of the Equine Profile Standard v1.0 for Neo4j, Amazon Neptune, and ArangoDB.

A graph database models horse data as nodes and relationships — enabling recursive pedigree traversal, ownership chains, and planetary-scale connectivity as the foundation of the Global Equine Graph.

---

## Files

| File | Database | Purpose |
|------|----------|---------|
| `equine_profile_standard_neo4j_v1.0.cql` | Neo4j | Schema — constraints, indexes, node and relationship definitions |
| `equine_profile_standard_neo4j_nodejs_v1.0.js` | Neo4j | Node.js implementation using `neo4j-driver` |
| `equine_profile_standard_neo4j_python_v1.0.py` | Neo4j | Python implementation using `neo4j` package |
| `equine_profile_standard_neptune_v1.0.cql` | Amazon Neptune | Schema — node and relationship definitions in openCypher |
| `equine_profile_standard_arangodb_v1.0.js` | ArangoDB | Schema, collections, indexes, and AQL implementation |

---

## Prerequisites

### Neo4j
- Neo4j 5.x or above
- Node.js: `npm install neo4j-driver`
- Python: `pip install neo4j`

### Amazon Neptune
- An active Amazon Neptune cluster on AWS
- Neptune endpoint URL from the AWS Console
- AWS VPC access configured — Neptune is not publicly accessible by default

### ArangoDB
- ArangoDB 3.11 or above
- Node.js: `npm install arangojs`

---

## Server Credentials

Before using any implementation file, update the server credentials to match your environment.

### Neo4j

In `equine_profile_standard_neo4j_nodejs_v1.0.js` and `equine_profile_standard_neo4j_python_v1.0.py`, replace the following with your Neo4j instance credentials:

```
bolt://localhost:7687   →   your Neo4j bolt URL
neo4j                   →   your Neo4j username
your-password           →   your Neo4j password
```

### Amazon Neptune

In `equine_profile_standard_neptune_v1.0.cql`, Neptune is queried via the Neptune endpoint URL provided in the AWS Console. Replace the following in your application connection:

```
your-neptune-cluster-endpoint.amazonaws.com:8182   →   your Neptune cluster endpoint
```

Neptune does not use username/password authentication. Access is controlled via AWS IAM roles and VPC security groups.

### ArangoDB

In `equine_profile_standard_arangodb_v1.0.js`, replace the following with your ArangoDB instance credentials:

```
http://localhost:8529   →   your ArangoDB server URL
equine                  →   your database name
root                    →   your ArangoDB username
your-password           →   your ArangoDB password
```

---

## Step 1 — Run the Schema

### Neo4j

Run `equine_profile_standard_neo4j_v1.0.cql` against your Neo4j instance in order:

1. Constraints
2. Indexes
3. Node property definitions
4. Relationship definitions

**Neo4j Browser** — paste and run each block separately.
**Neo4j Desktop** — use the built-in Cypher editor.
**CLI:**
```
cypher-shell -u neo4j -p your-password < equine_profile_standard_neo4j_v1.0.cql
```

### Amazon Neptune

Run `equine_profile_standard_neptune_v1.0.cql` via the Neptune Workbench in the AWS Console or via the Neptune HTTP endpoint.

### ArangoDB

Run `equine_profile_standard_arangodb_v1.0.js` via the ArangoDB web interface or `arangosh` CLI:
```
arangosh --server.endpoint tcp://localhost:8529 < equine_profile_standard_arangodb_v1.0.js
```

---

## Step 2 — Connect Your Application

### Neo4j — Node.js

```javascript
import neo4j from 'neo4j-driver';

const driver = neo4j.driver(
    'bolt://your-neo4j-url:7687',
    neo4j.auth.basic('your-username', 'your-password')
);

const session = driver.session();
```

### Neo4j — Python

```python
from neo4j import GraphDatabase

driver = GraphDatabase.driver(
    "bolt://your-neo4j-url:7687",
    auth=("your-username", "your-password")
)
```

### Amazon Neptune — Node.js

```javascript
import neo4j from 'neo4j-driver';

const driver = neo4j.driver(
    'bolt://your-neptune-endpoint:8182',
    neo4j.auth.basic('', '')   // Neptune uses IAM — leave credentials empty
);
```

### ArangoDB — Node.js

```javascript
import { Database } from 'arangojs';

const db = new Database({
    url:          "http://your-arangodb-url:8529",
    databaseName: "your-database-name",
    auth: { username: "your-username", password: "your-password" }
});
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
| `SIRED_BY` | Horse | Horse | Sire — father |
| `BORN_OF` | Horse | Horse | Dam — mother |
| `OWNED_BY` | Horse | Owner | Current ownership |
| `BRED_BY` | Horse | Breeder | Breeding attribution |
| `KEPT_AT` | Horse | Stable | Current stable location |
| `BRED_AT` | Horse | Stable | Stable where horse was bred |
| `MANAGES` | Owner | Stable | Owner manages stable |

---

## Licence

MIT License — Copyright (c) 2026 TechXZone Pvt Ltd

See [LICENSE.txt](../../../../LICENSE.txt) for full terms.
