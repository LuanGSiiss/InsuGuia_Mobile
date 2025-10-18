/*
  # Criação das tabelas para o InsuGuia Mobile

  ## 1. Tabelas
  
  ### `patients` (Pacientes)
  - `id` (uuid, chave primária)
  - `name` (text) - Nome do paciente
  - `sex` (text) - Sexo (M/F)
  - `age` (integer) - Idade
  - `weight` (numeric) - Peso em kg
  - `height` (numeric) - Altura em cm
  - `creatinine` (numeric) - Creatinina
  - `admission_location` (text) - Local de internação
  - `patient_type` (text) - Tipo de paciente (não crítico)
  - `is_discharged` (boolean) - Se recebeu alta
  - `created_at` (timestamptz) - Data de criação
  - `updated_at` (timestamptz) - Data de atualização

  ### `prescriptions` (Prescrições)
  - `id` (uuid, chave primária)
  - `patient_id` (uuid, FK para patients)
  - `diet_type` (text) - Tipo de dieta
  - `glycemic_monitoring` (text) - Monitorização glicêmica
  - `basal_insulin` (text) - Insulina basal
  - `rapid_insulin` (text) - Insulina de ação rápida
  - `hypoglycemia_instructions` (text) - Orientações para hipoglicemia
  - `created_at` (timestamptz)

  ### `glycemic_readings` (Leituras de Glicemia)
  - `id` (uuid, chave primária)
  - `patient_id` (uuid, FK para patients)
  - `reading_date` (date) - Data da leitura
  - `reading_time` (text) - Horário (jejum, pré-almoço, etc)
  - `glucose_value` (numeric) - Valor da glicemia
  - `adjustment_recommendation` (text) - Recomendação de ajuste
  - `created_at` (timestamptz)

  ### `discharge_instructions` (Orientações de Alta)
  - `id` (uuid, chave primária)
  - `patient_id` (uuid, FK para patients)
  - `instructions` (text) - Orientações gerais
  - `treatment_summary` (text) - Resumo do tratamento
  - `discharge_date` (timestamptz) - Data da alta
  - `created_at` (timestamptz)

  ## 2. Segurança
  - Habilita RLS em todas as tabelas
  - Políticas permitem acesso público para fins de protótipo
*/

-- Tabela de Pacientes
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

-- Tabela de Prescrições
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

-- Tabela de Leituras de Glicemia
CREATE TABLE IF NOT EXISTS glycemic_readings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  patient_id uuid REFERENCES patients(id) ON DELETE CASCADE,
  reading_date date NOT NULL,
  reading_time text NOT NULL,
  glucose_value numeric NOT NULL,
  adjustment_recommendation text,
  created_at timestamptz DEFAULT now()
);

-- Tabela de Orientações de Alta
CREATE TABLE IF NOT EXISTS discharge_instructions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  patient_id uuid REFERENCES patients(id) ON DELETE CASCADE,
  instructions text NOT NULL,
  treatment_summary text NOT NULL,
  discharge_date timestamptz DEFAULT now(),
  created_at timestamptz DEFAULT now()
);

-- Habilitar RLS
ALTER TABLE patients ENABLE ROW LEVEL SECURITY;
ALTER TABLE prescriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE glycemic_readings ENABLE ROW LEVEL SECURITY;
ALTER TABLE discharge_instructions ENABLE ROW LEVEL SECURITY;

-- Políticas (acesso público para protótipo)
CREATE POLICY "Permitir acesso público aos pacientes"
  ON patients FOR ALL
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Permitir acesso público às prescrições"
  ON prescriptions FOR ALL
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Permitir acesso público às leituras"
  ON glycemic_readings FOR ALL
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Permitir acesso público às orientações de alta"
  ON discharge_instructions FOR ALL
  USING (true)
  WITH CHECK (true);

-- Índices para melhor performance
CREATE INDEX IF NOT EXISTS idx_prescriptions_patient_id ON prescriptions(patient_id);
CREATE INDEX IF NOT EXISTS idx_glycemic_readings_patient_id ON glycemic_readings(patient_id);
CREATE INDEX IF NOT EXISTS idx_discharge_instructions_patient_id ON discharge_instructions(patient_id);
