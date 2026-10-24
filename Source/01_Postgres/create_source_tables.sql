/* =====================================================================
   CareSync Health Network — Internal Hospital System Tables
   Target: Neon Postgres (source system, schema: public)
   Creates hospitals, doctors, patients + seed sample data.
   ===================================================================== */

DROP TABLE IF EXISTS patients;
DROP TABLE IF EXISTS doctors;
DROP TABLE IF EXISTS hospitals;

/* ---------------------------------------------------------------------
   1. hospitals — hospital/facility master data (FULL load)
   --------------------------------------------------------------------- */
CREATE TABLE hospitals (
    hospital_id     SERIAL PRIMARY KEY,
    hospital_name   VARCHAR(150) NOT NULL,
    city            VARCHAR(100),
    state           VARCHAR(50),
    hospital_type   VARCHAR(50),   -- General, Specialty, Teaching
    bed_count       INT,
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP NOT NULL DEFAULT NOW()
);

/* ---------------------------------------------------------------------
   2. doctors — doctor/physician roster (FULL load)
   --------------------------------------------------------------------- */
CREATE TABLE doctors (
    doctor_id       SERIAL PRIMARY KEY,
    first_name      VARCHAR(100) NOT NULL,
    last_name       VARCHAR(100) NOT NULL,
    specialty       VARCHAR(100),
    hospital_id     INT REFERENCES hospitals (hospital_id),
    phone_number    VARCHAR(20),
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP NOT NULL DEFAULT NOW()
);

/* ---------------------------------------------------------------------
   3. patients — patient registration & demographics (MERGE load)
      watermark_column = updated_at, merge_keys = patient_id
   --------------------------------------------------------------------- */
CREATE TABLE patients (
    patient_id              SERIAL PRIMARY KEY,
    first_name              VARCHAR(100) NOT NULL,
    last_name               VARCHAR(100) NOT NULL,
    date_of_birth            DATE,
    gender                   VARCHAR(10),
    city                     VARCHAR(100),
    state                    VARCHAR(50),
    registered_hospital_id   INT REFERENCES hospitals (hospital_id),
    insurance_provider_id    INT,   -- logical FK to insurance_providers.csv (ADLS); no DB-level
                                    -- constraint since that table lives outside this database
    created_at               TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at               TIMESTAMP NOT NULL DEFAULT NOW()
);

/* =====================================================================
   Seed data — set-based generation (no giant literal INSERT lists)
   Target volumes: ~50 hospitals, ~10 doctors/hospital (~500), ~100
   patients/hospital (~5000).
   ===================================================================== */

-- 1. hospitals: 50 rows, cycling through 25 city/state pairs (2 each)
--    and 7 name-suffix / 5 hospital-type patterns so names don't collide.
WITH generated AS (
    SELECT
        gs,
        (ARRAY['Austin','Dallas','Houston','San Antonio','Fort Worth','Phoenix','Denver',
               'Seattle','Portland','Chicago','Atlanta','Miami','Orlando','Charlotte',
               'Nashville','Columbus','Indianapolis','Sacramento','San Diego','Boston',
               'Philadelphia','Baltimore','Minneapolis','Kansas City','Las Vegas']
        )[1 + (gs % 25)] AS city,
        (ARRAY['TX','TX','TX','TX','TX','AZ','CO','WA','OR','IL','GA','FL','FL','NC','TN',
               'OH','IN','CA','CA','MA','PA','MD','MN','MO','NV']
        )[1 + (gs % 25)] AS state,
        (ARRAY['General','Specialty','Teaching','Community','Regional'])[1 + (gs % 5)] AS hospital_type,
        (ARRAY['General Hospital','Medical Center','Regional Hospital','Community Hospital',
               'Health Center','Care Center','Memorial Hospital']
        )[1 + (gs % 7)] AS name_suffix
    FROM generate_series(0, 49) AS gs
)
INSERT INTO hospitals (hospital_name, city, state, hospital_type, bed_count)
SELECT city || ' ' || name_suffix, city, state, hospital_type, 80 + floor(random() * 420)::int
FROM generated;

-- 2. doctors: ~10 per hospital (~500 rows)
INSERT INTO doctors (first_name, last_name, specialty, hospital_id, phone_number)
SELECT
    (ARRAY['James','Mary','Robert','Patricia','John','Jennifer','Michael','Linda','David',
           'Elizabeth','William','Barbara','Richard','Susan','Joseph','Jessica','Thomas',
           'Sarah','Charles','Karen']
    )[1 + ((h.hospital_id * 10 + n) % 20)],
    (ARRAY['Smith','Johnson','Williams','Brown','Jones','Garcia','Miller','Davis','Rodriguez',
           'Martinez','Hernandez','Lopez','Gonzalez','Wilson','Anderson','Thomas','Taylor',
           'Moore','Jackson','Martin']
    )[1 + ((h.hospital_id * 13 + n * 3) % 20)],
    (ARRAY['Cardiology','Pediatrics','Orthopedics','Neurology','Oncology','General Medicine',
           'Endocrinology','Dermatology','Psychiatry','Radiology','Emergency Medicine',
           'Gastroenterology']
    )[1 + ((h.hospital_id + n) % 12)],
    h.hospital_id,
    '555-' || lpad(((h.hospital_id - 1) * 10 + n)::text, 4, '0')
FROM hospitals h
CROSS JOIN generate_series(1, 10) AS n;

-- 3. patients: ~100 per hospital (~5000 rows), city/state inherited from
--    the registering hospital; insurance_provider_id spread across the 25
--    providers in insurance_providers.csv; watermark_column (updated_at)
--    defaults to NOW()
INSERT INTO patients (first_name, last_name, date_of_birth, gender, city, state, registered_hospital_id, insurance_provider_id)
SELECT
    (ARRAY['James','Mary','Robert','Patricia','John','Jennifer','Michael','Linda','David',
           'Elizabeth','William','Barbara','Richard','Susan','Joseph','Jessica','Thomas',
           'Sarah','Charles','Karen']
    )[1 + ((h.hospital_id * 100 + n) % 20)],
    (ARRAY['Smith','Johnson','Williams','Brown','Jones','Garcia','Miller','Davis','Rodriguez',
           'Martinez','Hernandez','Lopez','Gonzalez','Wilson','Anderson','Thomas','Taylor',
           'Moore','Jackson','Martin']
    )[1 + ((h.hospital_id * 37 + n * 7) % 20)],
    DATE '1945-01-01' + floor(random() * 29200)::int,
    CASE WHEN (h.hospital_id + n) % 2 = 0 THEN 'M' ELSE 'F' END,
    h.city,
    h.state,
    h.hospital_id,
    1 + ((h.hospital_id * 3 + n) % 25)
FROM hospitals h
CROSS JOIN generate_series(1, 100) AS n;
