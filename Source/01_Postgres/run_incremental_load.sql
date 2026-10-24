/* =====================================================================
    CareSync Health Network - Incremental source load
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
        'Riverside Specialty Hospital',
        'Nashville',
        'TN',
        'Specialty',
        220,
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
    ('Sophia', 'Mitchell', 'Cardiology', '555-9001'),
    ('Liam', 'Turner', 'Neurology', '555-9002')
) AS doctor(first_name, last_name, specialty, phone_number);

/* ---------------------------------------------------------------------
   2. Update existing hospitals and doctors
   --------------------------------------------------------------------- */
UPDATE hospitals
SET
    bed_count = bed_count + 25,
    hospital_type = 'Regional',
    updated_at = CURRENT_TIMESTAMP
WHERE hospital_id = 1;

UPDATE doctors
SET
    specialty = 'Emergency Medicine',
    phone_number = '555-0101',
    updated_at = CURRENT_TIMESTAMP
WHERE doctor_id = 1;

/* ---------------------------------------------------------------------
   3. Insert new patients
   --------------------------------------------------------------------- */
INSERT INTO patients (
    first_name,
    last_name,
    date_of_birth,
    gender,
    city,
    state,
    registered_hospital_id,
    created_at,
    updated_at
)
VALUES
    (
        'Ava',
        'Bennett',
        DATE '1988-04-17',
        'F',
        'Austin',
        'TX',
        1,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ),
    (
        'Noah',
        'Carter',
        DATE '1976-11-03',
        'M',
        'Dallas',
        'TX',
        2,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ),
    (
        'Mia',
        'Reed',
        DATE '1995-08-29',
        'F',
        'Denver',
        'CO',
        7,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    );

/* ---------------------------------------------------------------------
    4. Update existing patients
   --------------------------------------------------------------------- */
UPDATE patients
SET
    city = 'Houston',
    state = 'TX',
    registered_hospital_id = 3,
    updated_at = CURRENT_TIMESTAMP
WHERE patient_id = 1;

UPDATE patients
SET
    first_name = 'Elena',
    city = 'Seattle',
    state = 'WA',
    registered_hospital_id = 8,
    updated_at = CURRENT_TIMESTAMP
WHERE patient_id = 2500;

COMMIT;
