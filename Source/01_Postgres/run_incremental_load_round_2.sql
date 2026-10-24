/* =====================================================================
   CareSync Health Network - Incremental source load, round 2
   Target: Neon Postgres (source system, schema: public)

   Inserts and updates hospitals, doctors, and patients.
   The updated_at column is explicitly refreshed for every update.
   ===================================================================== */

BEGIN;

/* ---------------------------------------------------------------------
   1. Insert a new hospital and its doctors
   --------------------------------------------------------------------- */
WITH new_hospital AS (
    INSERT INTO hospitals (
        hospital_name,
        city,
        state,
        hospital_type,
        bed_count,
        created_at,
        updated_at
    )
    VALUES (
        'Lakeside Community Hospital',
        'Orlando',
        'FL',
        'Community',
        180,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    )
    RETURNING hospital_id
)
INSERT INTO doctors (
    first_name,
    last_name,
    specialty,
    hospital_id,
    phone_number,
    created_at,
    updated_at
)
SELECT
    doctor.first_name,
    doctor.last_name,
    doctor.specialty,
    new_hospital.hospital_id,
    doctor.phone_number,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM new_hospital
CROSS JOIN (VALUES
    ('Grace', 'Morgan', 'Pediatrics', '555-9101'),
    ('Ethan', 'Collins', 'Orthopedics', '555-9102')
) AS doctor(first_name, last_name, specialty, phone_number);

/* ---------------------------------------------------------------------
   2. Update existing hospitals and doctors
   --------------------------------------------------------------------- */
UPDATE hospitals
SET
    bed_count = bed_count + 30,
    hospital_type = 'Teaching',
    updated_at = CURRENT_TIMESTAMP
WHERE hospital_id = 2;

UPDATE doctors
SET
    specialty = 'Gastroenterology',
    phone_number = '555-0202',
    updated_at = CURRENT_TIMESTAMP
WHERE doctor_id = 2;

/* ---------------------------------------------------------------------
   3. Insert new patients for the newly added hospital
   --------------------------------------------------------------------- */
INSERT INTO patients (
    first_name,
    last_name,
    date_of_birth,
    gender,
    city,
    state,
    registered_hospital_id,
    insurance_provider_id,
    created_at,
    updated_at
)
SELECT
    patient.first_name,
    patient.last_name,
    patient.date_of_birth,
    patient.gender,
    'Orlando',
    'FL',
    hospital.hospital_id,
    patient.insurance_provider_id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM hospitals AS hospital
CROSS JOIN (VALUES
    ('Isabella', 'Hayes', DATE '1990-02-14', 'F', 3),
    ('Lucas', 'Foster', DATE '1982-07-21', 'M', 14),
    ('Chloe', 'Parker', DATE '2001-12-05', 'F', 21)
) AS patient(first_name, last_name, date_of_birth, gender, insurance_provider_id)
WHERE hospital.hospital_name = 'Lakeside Community Hospital'
  AND hospital.city = 'Orlando'
  AND hospital.state = 'FL';

/* ---------------------------------------------------------------------
   4. Update existing patients
   --------------------------------------------------------------------- */
UPDATE patients
SET
    city = 'Phoenix',
    state = 'AZ',
    registered_hospital_id = 6,
    insurance_provider_id = 8,
    updated_at = CURRENT_TIMESTAMP
WHERE patient_id = 2;

UPDATE patients
SET
    last_name = 'Henderson',
    city = 'Chicago',
    state = 'IL',
    registered_hospital_id = 10,
    updated_at = CURRENT_TIMESTAMP
WHERE patient_id = 3500;

COMMIT;
