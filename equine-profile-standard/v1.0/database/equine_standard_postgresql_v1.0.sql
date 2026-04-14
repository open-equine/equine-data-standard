-- ============================================================
-- Equine Profile Standard
-- PostgreSQL Database Schema v1.0
-- Tables: stables, horses, pedigree, owners
-- Location: equine-profile-standard/v1.0/database/
-- Published by Open Equine — TechXZone Pvt Ltd
-- MIT Licensed | openequine.org | contact@openequine.org
-- ============================================================

-- ------------------------------------------------------------
-- Drop tables in reverse dependency order (safe re-run)
-- ------------------------------------------------------------
DROP TABLE IF EXISTS owners;
DROP TABLE IF EXISTS pedigree;
DROP TABLE IF EXISTS horses;
DROP TABLE IF EXISTS stables;

-- ------------------------------------------------------------
-- Drop custom types if they exist (safe re-run)
-- ------------------------------------------------------------
DROP TYPE IF EXISTS gender_enum;

-- ------------------------------------------------------------
-- Custom ENUM type for gender
-- ------------------------------------------------------------
CREATE TYPE gender_enum AS ENUM (
    'mare',
    'stallion',
    'gelding'
);


-- ============================================================
-- TABLE 1: stables
-- Standalone stable registry. Referenced by owners and horses.
-- ============================================================
CREATE TABLE stables (
    stable_id           SERIAL                      NOT NULL,
    stable_name         VARCHAR(255)                NOT NULL,

    -- Free text full address (as typed)
    stable_location     TEXT                        NULL,

    -- Split location fields for search and filtering
    address_line1       VARCHAR(255)                NULL,
    address_line2       VARCHAR(255)                NULL,
    city                VARCHAR(100)                NULL,
    state               VARCHAR(100)                NULL,
    country             VARCHAR(100)                NULL,
    pincode             VARCHAR(20)                 NULL,       -- VARCHAR to handle leading zeros and international formats

    -- Record tracking
    created_at          TIMESTAMP WITH TIME ZONE    NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMP WITH TIME ZONE    NOT NULL DEFAULT NOW(),

    CONSTRAINT pk_stables PRIMARY KEY (stable_id)
);

COMMENT ON TABLE  stables                   IS 'Standalone stable registry. Referenced by owners and horses.';
COMMENT ON COLUMN stables.stable_location   IS 'Full free text address as typed by user.';
COMMENT ON COLUMN stables.pincode           IS 'VARCHAR to handle leading zeros and international postal formats.';

-- Trigger to auto-update updated_at on row change
CREATE OR REPLACE FUNCTION fn_set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_stables_updated_at
    BEFORE UPDATE ON stables
    FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();


-- ============================================================
-- TABLE 2: horses
-- Core horse identity table.
-- ============================================================
CREATE TABLE horses (
    horse_id            SERIAL                      NOT NULL,

    -- Identity fields
    horse_name          VARCHAR(255)                NOT NULL,
    dob                 DATE                        NULL,
    breed               VARCHAR(100)                NULL,
    gender              gender_enum                 NULL,
    color               VARCHAR(100)                NULL,

    -- Registration and identification
    ueln                VARCHAR(15)                 NULL,
    passport_no         VARCHAR(100)                NULL,
    microchip           CHAR(15)                    NULL,

    -- Record tracking
    created_at          TIMESTAMP WITH TIME ZONE    NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMP WITH TIME ZONE    NOT NULL DEFAULT NOW(),

    CONSTRAINT pk_horses            PRIMARY KEY (horse_id),
    CONSTRAINT uq_horses_ueln       UNIQUE (ueln),
    CONSTRAINT uq_horses_microchip  UNIQUE (microchip),
    CONSTRAINT uq_horses_passport   UNIQUE (passport_no)
);

COMMENT ON TABLE  horses                IS 'Core horse identity table. One record per horse.';
COMMENT ON COLUMN horses.ueln           IS 'Universal Equine Life Number — 15 character alphanumeric ISO standard.';
COMMENT ON COLUMN horses.passport_no    IS 'Travel passport number issued by a national authority for international movement of horses.';
COMMENT ON COLUMN horses.microchip      IS '15-digit ISO 11784/11785 microchip identification number.';

-- Indexes
CREATE INDEX idx_horses_horse_name  ON horses (horse_name);
CREATE INDEX idx_horses_breed       ON horses (breed);
CREATE INDEX idx_horses_gender      ON horses (gender);

-- Trigger
CREATE TRIGGER trg_horses_updated_at
    BEFORE UPDATE ON horses
    FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();


-- ============================================================
-- TABLE 3: pedigree
-- Lineage data for a horse.
-- Each ancestor has both a name field (free text, always available)
-- and a horse_id field (nullable FK — links if ancestor exists in horses table).
-- ============================================================
CREATE TABLE pedigree (
    pedigree_id             SERIAL                      NOT NULL,
    horse_id                INTEGER                     NOT NULL,

    -- Sire (Father)
    sire_name               VARCHAR(255)                NULL,
    sire_horse_id           INTEGER                     NULL,

    -- Dam (Mother)
    dam_name                VARCHAR(255)                NULL,
    dam_horse_id            INTEGER                     NULL,

    -- Paternal Grandparents (Sire line)
    sire_of_sire_name       VARCHAR(255)                NULL,
    sire_of_sire_horse_id   INTEGER                     NULL,

    dam_of_sire_name        VARCHAR(255)                NULL,
    dam_of_sire_horse_id    INTEGER                     NULL,

    -- Maternal Grandparents (Dam line)
    sire_of_dam_name        VARCHAR(255)                NULL,
    sire_of_dam_horse_id    INTEGER                     NULL,

    dam_of_dam_name         VARCHAR(255)                NULL,
    dam_of_dam_horse_id     INTEGER                     NULL,

    -- Extended lineage notes
    description             TEXT                        NULL,

    -- Record tracking
    created_at              TIMESTAMP WITH TIME ZONE    NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMP WITH TIME ZONE    NOT NULL DEFAULT NOW(),

    CONSTRAINT pk_pedigree          PRIMARY KEY (pedigree_id),
    CONSTRAINT uq_pedigree_horse    UNIQUE (horse_id),          -- One pedigree record per horse

    -- Foreign key — the horse this pedigree belongs to
    CONSTRAINT fk_pedigree_horse
        FOREIGN KEY (horse_id)
        REFERENCES horses (horse_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    -- Foreign keys — ancestors linked to horses table (nullable)
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

COMMENT ON TABLE  pedigree                      IS 'Lineage data for a horse. Each ancestor has a name field and an optional FK to horses table.';
COMMENT ON COLUMN pedigree.horse_id             IS 'The horse whose pedigree this record describes.';
COMMENT ON COLUMN pedigree.sire_horse_id        IS 'FK to horses.horse_id if sire is registered in the database.';
COMMENT ON COLUMN pedigree.dam_horse_id         IS 'FK to horses.horse_id if dam is registered in the database.';
COMMENT ON COLUMN pedigree.sire_of_sire_horse_id IS 'FK to horses.horse_id if paternal grandsire is registered.';
COMMENT ON COLUMN pedigree.dam_of_sire_horse_id  IS 'FK to horses.horse_id if paternal granddam is registered.';
COMMENT ON COLUMN pedigree.sire_of_dam_horse_id  IS 'FK to horses.horse_id if maternal grandsire is registered.';
COMMENT ON COLUMN pedigree.dam_of_dam_horse_id   IS 'FK to horses.horse_id if maternal granddam is registered.';
COMMENT ON COLUMN pedigree.description          IS 'Free text for extended lineage, great-grandparents, bloodline notes.';

-- Trigger
CREATE TRIGGER trg_pedigree_updated_at
    BEFORE UPDATE ON pedigree
    FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();


-- ============================================================
-- TABLE 4: owners
-- Owner and breeder information linked to the horse.
-- Each owner record references two stables:
--   owner_stable_id   — the stable where the owner keeps the horse
--   breeder_stable_id — the stable where the horse was bred
-- ============================================================
CREATE TABLE owners (
    owner_id                SERIAL                      NOT NULL,
    horse_id                INTEGER                     NOT NULL,

    -- Owner details
    owner_name              VARCHAR(255)                NOT NULL,
    owner_contact           VARCHAR(255)                NOT NULL,
    owner_stable_id         INTEGER                     NULL,

    -- Breeder details
    breeder_name            VARCHAR(255)                NULL,
    breeder_contact         VARCHAR(255)                NULL,
    breeder_stable_id       INTEGER                     NULL,

    -- Record tracking
    created_at              TIMESTAMP WITH TIME ZONE    NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMP WITH TIME ZONE    NOT NULL DEFAULT NOW(),

    CONSTRAINT pk_owners PRIMARY KEY (owner_id),

    -- Foreign key — the horse this owner record belongs to
    CONSTRAINT fk_owners_horse
        FOREIGN KEY (horse_id)
        REFERENCES horses (horse_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    -- Foreign key — owner stable
    CONSTRAINT fk_owners_owner_stable
        FOREIGN KEY (owner_stable_id)
        REFERENCES stables (stable_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,

    -- Foreign key — breeder stable
    CONSTRAINT fk_owners_breeder_stable
        FOREIGN KEY (breeder_stable_id)
        REFERENCES stables (stable_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

COMMENT ON TABLE  owners                    IS 'Owner and breeder information linked to the horse.';
COMMENT ON COLUMN owners.horse_id           IS 'The horse this ownership record belongs to.';
COMMENT ON COLUMN owners.owner_contact      IS 'Phone number or email address of the owner.';
COMMENT ON COLUMN owners.owner_stable_id    IS 'FK to stables — stable where the owner currently keeps the horse.';
COMMENT ON COLUMN owners.breeder_contact    IS 'Phone number or email address of the breeder.';
COMMENT ON COLUMN owners.breeder_stable_id  IS 'FK to stables — stable where the horse was bred.';

-- Index for horse lookups
CREATE INDEX idx_owners_horse_id ON owners (horse_id);

-- Trigger
CREATE TRIGGER trg_owners_updated_at
    BEFORE UPDATE ON owners
    FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();


-- ============================================================
-- End of Schema
-- Equine Profile Standard v1.0
-- ============================================================
