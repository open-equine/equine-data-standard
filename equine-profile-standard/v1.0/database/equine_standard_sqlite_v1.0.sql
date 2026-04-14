-- ============================================================
-- Equine Profile Standard
-- SQLite Database Schema v1.0
-- Tables: stables, horses, pedigree, owners
-- Location: equine-profile-standard/v1.0/database/
-- Published by Open Equine — TechXZone Pvt Ltd
-- MIT Licensed | openequine.org | contact@openequine.org
-- ============================================================

-- ------------------------------------------------------------
-- Enable foreign key enforcement (disabled by default in SQLite)
-- ------------------------------------------------------------
PRAGMA foreign_keys = ON;

-- ------------------------------------------------------------
-- Drop tables in reverse dependency order (safe re-run)
-- ------------------------------------------------------------
DROP TABLE IF EXISTS owners;
DROP TABLE IF EXISTS pedigree;
DROP TABLE IF EXISTS horses;
DROP TABLE IF EXISTS stables;

-- ============================================================
-- TABLE 1: stables
-- Standalone stable registry. Referenced by owners and horses.
-- ============================================================
CREATE TABLE stables (
    stable_id           INTEGER         NOT NULL,

    stable_name         TEXT            NOT NULL,

    -- Free text full address (as typed)
    stable_location     TEXT            NULL,

    -- Split location fields for search and filtering
    address_line1       TEXT            NULL,
    address_line2       TEXT            NULL,
    city                TEXT            NULL,
    state               TEXT            NULL,
    country             TEXT            NULL,
    pincode             TEXT            NULL,       -- TEXT to handle leading zeros and international formats

    -- Record tracking
    created_at          TEXT            NOT NULL DEFAULT (datetime('now')),
    updated_at          TEXT            NOT NULL DEFAULT (datetime('now')),

    PRIMARY KEY (stable_id AUTOINCREMENT)
);

-- ============================================================
-- TABLE 2: horses
-- Core horse identity table.
-- ============================================================
CREATE TABLE horses (
    horse_id            INTEGER         NOT NULL,

    -- Identity fields
    horse_name          TEXT            NOT NULL,
    dob                 TEXT            NULL,       -- ISO 8601 date: YYYY-MM-DD
    breed               TEXT            NULL,
    gender              TEXT            NULL        CHECK (gender IN ('mare', 'stallion', 'gelding')),
    color               TEXT            NULL,

    -- Registration and identification
    ueln                TEXT            NULL,       -- Universal Equine Life Number — 15 char alphanumeric
    passport_no         TEXT            NULL,       -- Travel passport number issued by a national authority
    microchip           TEXT            NULL,       -- 15-digit ISO 11784/11785 microchip number

    -- Record tracking
    created_at          TEXT            NOT NULL DEFAULT (datetime('now')),
    updated_at          TEXT            NOT NULL DEFAULT (datetime('now')),

    PRIMARY KEY (horse_id AUTOINCREMENT),

    CONSTRAINT uq_horses_ueln       UNIQUE (ueln),
    CONSTRAINT uq_horses_microchip  UNIQUE (microchip),
    CONSTRAINT uq_horses_passport   UNIQUE (passport_no)
);

-- Indexes for common lookups
CREATE INDEX idx_horses_horse_name  ON horses (horse_name);
CREATE INDEX idx_horses_breed       ON horses (breed);
CREATE INDEX idx_horses_gender      ON horses (gender);

-- Trigger to auto-update updated_at
CREATE TRIGGER trg_horses_updated_at
    AFTER UPDATE ON horses
    FOR EACH ROW
BEGIN
    UPDATE horses SET updated_at = datetime('now') WHERE horse_id = OLD.horse_id;
END;

-- ============================================================
-- TABLE 3: pedigree
-- Lineage data for a horse.
-- Each ancestor has both a name field (free text, always available)
-- and a horse_id field (nullable FK — links if ancestor exists in horses table).
-- ============================================================
CREATE TABLE pedigree (
    pedigree_id             INTEGER     NOT NULL,
    horse_id                INTEGER     NOT NULL,   -- The horse whose pedigree this record describes

    -- Sire (Father)
    sire_name               TEXT        NULL,
    sire_horse_id           INTEGER     NULL,       -- FK to horses.horse_id if sire exists in database

    -- Dam (Mother)
    dam_name                TEXT        NULL,
    dam_horse_id            INTEGER     NULL,       -- FK to horses.horse_id if dam exists in database

    -- Paternal Grandparents (Sire line)
    sire_of_sire_name       TEXT        NULL,
    sire_of_sire_horse_id   INTEGER     NULL,       -- FK to horses.horse_id if sire of sire exists in database

    dam_of_sire_name        TEXT        NULL,
    dam_of_sire_horse_id    INTEGER     NULL,       -- FK to horses.horse_id if dam of sire exists in database

    -- Maternal Grandparents (Dam line)
    sire_of_dam_name        TEXT        NULL,
    sire_of_dam_horse_id    INTEGER     NULL,       -- FK to horses.horse_id if sire of dam exists in database

    dam_of_dam_name         TEXT        NULL,
    dam_of_dam_horse_id     INTEGER     NULL,       -- FK to horses.horse_id if dam of dam exists in database

    -- Extended lineage notes
    description             TEXT        NULL,       -- Free text for extended lineage, great-grandparents, bloodline notes

    -- Record tracking
    created_at              TEXT        NOT NULL DEFAULT (datetime('now')),
    updated_at              TEXT        NOT NULL DEFAULT (datetime('now')),

    PRIMARY KEY (pedigree_id AUTOINCREMENT),

    CONSTRAINT uq_pedigree_horse    UNIQUE (horse_id),      -- One pedigree record per horse

    CONSTRAINT fk_pedigree_horse
        FOREIGN KEY (horse_id)
        REFERENCES horses (horse_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_pedigree_sire
        FOREIGN KEY (sire_horse_id)
        REFERENCES horses (horse_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,

    CONSTRAINT fk_pedigree_dam
        FOREIGN KEY (dam_horse_id)
        REFERENCES horses (horse_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,

    CONSTRAINT fk_pedigree_sire_of_sire
        FOREIGN KEY (sire_of_sire_horse_id)
        REFERENCES horses (horse_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,

    CONSTRAINT fk_pedigree_dam_of_sire
        FOREIGN KEY (dam_of_sire_horse_id)
        REFERENCES horses (horse_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,

    CONSTRAINT fk_pedigree_sire_of_dam
        FOREIGN KEY (sire_of_dam_horse_id)
        REFERENCES horses (horse_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,

    CONSTRAINT fk_pedigree_dam_of_dam
        FOREIGN KEY (dam_of_dam_horse_id)
        REFERENCES horses (horse_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

-- Trigger to auto-update updated_at
CREATE TRIGGER trg_pedigree_updated_at
    AFTER UPDATE ON pedigree
    FOR EACH ROW
BEGIN
    UPDATE pedigree SET updated_at = datetime('now') WHERE pedigree_id = OLD.pedigree_id;
END;

-- ============================================================
-- TABLE 4: owners
-- Owner and breeder information linked to the horse.
-- Each owner record references two stables:
--   owner_stable_id   — the stable where the owner keeps the horse
--   breeder_stable_id — the stable where the horse was bred
-- ============================================================
CREATE TABLE owners (
    owner_id                INTEGER     NOT NULL,
    horse_id                INTEGER     NOT NULL,   -- The horse this ownership record belongs to

    -- Owner details
    owner_name              TEXT        NOT NULL,
    owner_contact           TEXT        NOT NULL,   -- Phone number or email address
    owner_stable_id         INTEGER     NULL,       -- FK to stables.stable_id

    -- Breeder details
    breeder_name            TEXT        NULL,
    breeder_contact         TEXT        NULL,       -- Phone number or email address
    breeder_stable_id       INTEGER     NULL,       -- FK to stables.stable_id

    -- Record tracking
    created_at              TEXT        NOT NULL DEFAULT (datetime('now')),
    updated_at              TEXT        NOT NULL DEFAULT (datetime('now')),

    PRIMARY KEY (owner_id AUTOINCREMENT),

    CONSTRAINT fk_owners_horse
        FOREIGN KEY (horse_id)
        REFERENCES horses (horse_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_owners_owner_stable
        FOREIGN KEY (owner_stable_id)
        REFERENCES stables (stable_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,

    CONSTRAINT fk_owners_breeder_stable
        FOREIGN KEY (breeder_stable_id)
        REFERENCES stables (stable_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

-- Index for horse lookups
CREATE INDEX idx_owners_horse_id ON owners (horse_id);

-- Trigger to auto-update updated_at
CREATE TRIGGER trg_owners_updated_at
    AFTER UPDATE ON owners
    FOR EACH ROW
BEGIN
    UPDATE owners SET updated_at = datetime('now') WHERE owner_id = OLD.owner_id;
END;

-- ============================================================
-- End of Schema
-- Equine Profile Standard v1.0
-- ============================================================
