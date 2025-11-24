/*
  # Create Initial Schema for InsuGuia

  1. New Tables
    - `patients` - Patient records
    - `prescriptions` - Insulin prescriptions
    - `glycemic_readings` - Blood glucose readings
    - `discharge_instructions` - Hospital discharge instructions

  2. Security
    - RLS enabled on all tables
    - Initial public policies (will be replaced with auth policies)
*/

CREATE TABLE IF NOT EXISTS patients (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  sex text NOT NULL,
  age integer NOT NULL,
  weight numeric NOT NULL,
  height numeric NOT NULL,
  creatinine numeric NOT NULL,
  admission_location text NOT NULL,
  patient_type text DEFAULT 'não crítico',
  is_discharged boolean DEFAULT false,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS prescriptions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  patient_id uuid REFERENCES patients(id) ON DELETE CASCADE,
  diet_type text NOT NULL,
  glycemic_monitoring text NOT NULL,
  basal_insulin text NOT NULL,
  rapid_insulin text NOT NULL,
  hypoglycemia_instructions text NOT NULL,
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS glycemic_readings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  patient_id uuid REFERENCES patients(id) ON DELETE CASCADE,
  reading_date date NOT NULL,
  reading_time text NOT NULL,
  glucose_value numeric NOT NULL,
  adjustment_recommendation text,
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS discharge_instructions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  patient_id uuid REFERENCES patients(id) ON DELETE CASCADE,
  instructions text NOT NULL,
  treatment_summary text NOT NULL,
  discharge_date timestamptz DEFAULT now(),
  created_at timestamptz DEFAULT now()
);

ALTER TABLE patients ENABLE ROW LEVEL SECURITY;
ALTER TABLE prescriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE glycemic_readings ENABLE ROW LEVEL SECURITY;
ALTER TABLE discharge_instructions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow all access" ON patients FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all access" ON prescriptions FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all access" ON glycemic_readings FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all access" ON discharge_instructions FOR ALL USING (true) WITH CHECK (true);

CREATE INDEX IF NOT EXISTS idx_prescriptions_patient_id ON prescriptions(patient_id);
CREATE INDEX IF NOT EXISTS idx_glycemic_readings_patient_id ON glycemic_readings(patient_id);
CREATE INDEX IF NOT EXISTS idx_discharge_instructions_patient_id ON discharge_instructions(patient_id);