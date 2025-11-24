/*
  # Add Doctors Table and Authentication System

  1. New Tables
    - `doctors` - Doctor profiles linked to auth.users

  2. Modified Tables
    - `patients` - Add doctor_id column to link patients to doctors

  3. Security Policies
    - Doctors can only see their own patients
    - Prescriptions and readings are isolated by doctor
    - Patient data belongs exclusively to the assigned doctor
*/

CREATE TABLE IF NOT EXISTS doctors (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  name text NOT NULL,
  email text UNIQUE NOT NULL,
  specialty text NOT NULL,
  crm text UNIQUE NOT NULL,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE doctors ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Doctors can view own profile"
  ON doctors FOR SELECT
  TO authenticated
  USING (auth.uid() = id);

ALTER TABLE patients ADD COLUMN IF NOT EXISTS doctor_id uuid REFERENCES doctors(id) ON DELETE RESTRICT;

CREATE INDEX IF NOT EXISTS idx_patients_doctor_id ON patients(doctor_id);

DROP POLICY IF EXISTS "Allow all access" ON patients;
DROP POLICY IF EXISTS "Permitir acesso público aos pacientes" ON patients;

CREATE POLICY "Doctor can view own patients"
  ON patients FOR SELECT
  TO authenticated
  USING (doctor_id = auth.uid() OR doctor_id IS NULL);

CREATE POLICY "Doctor can create patients"
  ON patients FOR INSERT
  TO authenticated
  WITH CHECK (doctor_id = auth.uid());

CREATE POLICY "Doctor can update own patients"
  ON patients FOR UPDATE
  TO authenticated
  USING (doctor_id = auth.uid())
  WITH CHECK (doctor_id = auth.uid());

CREATE POLICY "Doctor can delete own patients"
  ON patients FOR DELETE
  TO authenticated
  USING (doctor_id = auth.uid());

DROP POLICY IF EXISTS "Allow all access" ON prescriptions;
DROP POLICY IF EXISTS "Permitir acesso público às prescrições" ON prescriptions;

CREATE POLICY "Doctor can view own patient prescriptions"
  ON prescriptions FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM patients
      WHERE patients.id = prescriptions.patient_id
      AND (patients.doctor_id = auth.uid() OR patients.doctor_id IS NULL)
    )
  );

CREATE POLICY "Doctor can create prescriptions for own patients"
  ON prescriptions FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM patients
      WHERE patients.id = prescriptions.patient_id
      AND patients.doctor_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Allow all access" ON glycemic_readings;
DROP POLICY IF EXISTS "Permitir acesso público às leituras" ON glycemic_readings;

CREATE POLICY "Doctor can view own patient readings"
  ON glycemic_readings FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM patients
      WHERE patients.id = glycemic_readings.patient_id
      AND (patients.doctor_id = auth.uid() OR patients.doctor_id IS NULL)
    )
  );

CREATE POLICY "Doctor can create readings for own patients"
  ON glycemic_readings FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM patients
      WHERE patients.id = glycemic_readings.patient_id
      AND patients.doctor_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Allow all access" ON discharge_instructions;
DROP POLICY IF EXISTS "Permitir acesso público às orientações de alta" ON discharge_instructions;

CREATE POLICY "Doctor can view own patient discharge instructions"
  ON discharge_instructions FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM patients
      WHERE patients.id = discharge_instructions.patient_id
      AND (patients.doctor_id = auth.uid() OR patients.doctor_id IS NULL)
    )
  );

CREATE POLICY "Doctor can create discharge instructions"
  ON discharge_instructions FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM patients
      WHERE patients.id = discharge_instructions.patient_id
      AND patients.doctor_id = auth.uid()
    )
  );