-- ============================================================
-- Equine Profile Standard
-- MySQL Database Schema v1.0
-- Tables: stables, horses, pedigree, owners
-- Location: equine-profile-standard/v1.0/database/
-- Published by Open Equine — TechXZone Pvt Ltd
-- MIT Licensed | openequine.org | contact@openequine.org
-- ============================================================

-- ------------------------------------------------------------
-- Drop tables in reverse dependency order (safe re-run)
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `owners`;
DROP TABLE IF EXISTS `pedigree`;
DROP TABLE IF EXISTS `horses`;
DROP TABLE IF EXISTS `stables`;

-- ============================================================
-- TABLE 1: stables
-- Standalone stable registry. Referenced by owners and horses.
-- ============================================================
CREATE TABLE `stables` (
    `stable_id`         INT UNSIGNED        NOT NULL AUTO_INCREMENT,
    `stable_name`       VARCHAR(255)        NOT NULL,

    -- Free text full address (as typed)
    `stable_location`   TEXT                NULL,

    -- Split location fields for search and filtering
    `address_line1`     VARCHAR(255)        NULL,
    `address_line2`     VARCHAR(255)        NULL,
    `city`              VARCHAR(100)        NULL,
    `state`             VARCHAR(100)        NULL,
    `country`           VARCHAR(100)        NULL,
    `pincode`           VARCHAR(20)         NULL,       -- VARCHAR to handle leading zeros and international formats

    -- Record tracking
    `created_at`        DATETIME            NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`        DATETIME            NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (`stable_id`)

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- TABLE 2: horses
-- Core horse identity table.
-- ============================================================
CREATE TABLE `horses` (
    `horse_id`          INT UNSIGNED        NOT NULL AUTO_INCREMENT,

    -- Identity fields
    `horse_name`        VARCHAR(255)        NOT NULL,
    `dob`               DATE                NULL,
    `breed`             VARCHAR(100)        NULL,
    `gender`            ENUM(
                            'mare',
                            'stallion',
                            'gelding'
                        )                   NULL,
    `color`             VARCHAR(100)        NULL,

    -- Registration and identification
    `ueln`              VARCHAR(15)         NULL COMMENT 'Universal Equine Life Number — 15 char alphanumeric ISO standard',
    `passport_no`       VARCHAR(100)        NULL COMMENT 'Travel passport number issued by a national authority for international movement of horses',
    `microchip`         CHAR(15)            NULL COMMENT '15-digit ISO 11784/11785 microchip number',

    -- Record tracking
    `created_at`        DATETIME            NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`        DATETIME            NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (`horse_id`),

    -- Indexes for common lookups
    UNIQUE INDEX `idx_ueln`         (`ueln`),
    UNIQUE INDEX `idx_microchip`    (`microchip`),
    UNIQUE INDEX `idx_passport_no`  (`passport_no`),
    INDEX        `idx_horse_name`   (`horse_name`),
    INDEX        `idx_breed`        (`breed`),
    INDEX        `idx_gender`       (`gender`)

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- TABLE 3: pedigree
-- Lineage data for a horse.
-- Each ancestor has both a name field (free text, always available)
-- and a horse_id field (nullable FK — links if ancestor exists in horses table).
-- ============================================================
CREATE TABLE `pedigree` (
    `pedigree_id`           INT UNSIGNED    NOT NULL AUTO_INCREMENT,
    `horse_id`              INT UNSIGNED    NOT NULL COMMENT 'The horse whose pedigree this record describes',

    -- Sire (Father)
    `sire_name`             VARCHAR(255)    NULL,
    `sire_horse_id`         INT UNSIGNED    NULL COMMENT 'FK to horses.horse_id if sire exists in database',

    -- Dam (Mother)
    `dam_name`              VARCHAR(255)    NULL,
    `dam_horse_id`          INT UNSIGNED    NULL COMMENT 'FK to horses.horse_id if dam exists in database',

    -- Paternal Grandparents (Sire line)
    `sire_of_sire_name`     VARCHAR(255)    NULL,
    `sire_of_sire_horse_id` INT UNSIGNED    NULL COMMENT 'FK to horses.horse_id if sire of sire exists in database',

    `dam_of_sire_name`      VARCHAR(255)    NULL,
    `dam_of_sire_horse_id`  INT UNSIGNED    NULL COMMENT 'FK to horses.horse_id if dam of sire exists in database',

    -- Maternal Grandparents (Dam line)
    `sire_of_dam_name`      VARCHAR(255)    NULL,
    `sire_of_dam_horse_id`  INT UNSIGNED    NULL COMMENT 'FK to horses.horse_id if sire of dam exists in database',

    `dam_of_dam_name`       VARCHAR(255)    NULL,
    `dam_of_dam_horse_id`   INT UNSIGNED    NULL COMMENT 'FK to horses.horse_id if dam of dam exists in database',

    -- Extended lineage notes
    `description`           TEXT            NULL COMMENT 'Free text for extended lineage, great-grandparents, bloodline notes',

    -- Record tracking
    `created_at`            DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`            DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (`pedigree_id`),

    -- One pedigree record per horse
    UNIQUE INDEX `idx_horse_id` (`horse_id`),

    -- Foreign key — the horse this pedigree belongs to
    CONSTRAINT `fk_pedigree_horse`
        FOREIGN KEY (`horse_id`)
        REFERENCES `horses` (`horse_id`)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    -- Foreign keys — ancestors linked to horses table (nullable)
    CONSTRAINT `fk_pedigree_sire`
        FOREIGN KEY (`sire_horse_id`)
        REFERENCES `horses` (`horse_id`)
        ON DELETE SET NULL
        ON UPDATE CASCADE,

    CONSTRAINT `fk_pedigree_dam`
        FOREIGN KEY (`dam_horse_id`)
        REFERENCES `horses` (`horse_id`)
        ON DELETE SET NULL
        ON UPDATE CASCADE,

    CONSTRAINT `fk_pedigree_sire_of_sire`
        FOREIGN KEY (`sire_of_sire_horse_id`)
        REFERENCES `horses` (`horse_id`)
        ON DELETE SET NULL
        ON UPDATE CASCADE,

    CONSTRAINT `fk_pedigree_dam_of_sire`
        FOREIGN KEY (`dam_of_sire_horse_id`)
        REFERENCES `horses` (`horse_id`)
        ON DELETE SET NULL
        ON UPDATE CASCADE,

    CONSTRAINT `fk_pedigree_sire_of_dam`
        FOREIGN KEY (`sire_of_dam_horse_id`)
        REFERENCES `horses` (`horse_id`)
        ON DELETE SET NULL
        ON UPDATE CASCADE,

    CONSTRAINT `fk_pedigree_dam_of_dam`
        FOREIGN KEY (`dam_of_dam_horse_id`)
        REFERENCES `horses` (`horse_id`)
        ON DELETE SET NULL
        ON UPDATE CASCADE

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- TABLE 4: owners
-- Owner and breeder information linked to the horse.
-- Each owner record references two stables:
--   owner_stable_id  — the stable where the owner keeps the horse
--   breeder_stable_id — the stable where the horse was bred
-- ============================================================
CREATE TABLE `owners` (
    `owner_id`              INT UNSIGNED    NOT NULL AUTO_INCREMENT,
    `horse_id`              INT UNSIGNED    NOT NULL COMMENT 'The horse this ownership record belongs to',

    -- Owner details
    `owner_name`            VARCHAR(255)    NOT NULL,
    `owner_contact`         VARCHAR(255)    NOT NULL COMMENT 'Phone number or email address',
    `owner_stable_id`       INT UNSIGNED    NULL COMMENT 'FK to stables.stable_id — where owner keeps the horse',

    -- Breeder details
    `breeder_name`          VARCHAR(255)    NULL,
    `breeder_contact`       VARCHAR(255)    NULL COMMENT 'Phone number or email address',
    `breeder_stable_id`     INT UNSIGNED    NULL COMMENT 'FK to stables.stable_id — where the horse was bred',

    -- Record tracking
    `created_at`            DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`            DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (`owner_id`),

    -- Index for horse lookups
    INDEX `idx_horse_id`    (`horse_id`),

    -- Foreign key — the horse this owner record belongs to
    CONSTRAINT `fk_owners_horse`
        FOREIGN KEY (`horse_id`)
        REFERENCES `horses` (`horse_id`)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    -- Foreign key — owner stable
    CONSTRAINT `fk_owners_owner_stable`
        FOREIGN KEY (`owner_stable_id`)
        REFERENCES `stables` (`stable_id`)
        ON DELETE SET NULL
        ON UPDATE CASCADE,

    -- Foreign key — breeder stable
    CONSTRAINT `fk_owners_breeder_stable`
        FOREIGN KEY (`breeder_stable_id`)
        REFERENCES `stables` (`stable_id`)
        ON DELETE SET NULL
        ON UPDATE CASCADE

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- End of Schema
-- Equine Profile Standard v1.0
-- ============================================================
