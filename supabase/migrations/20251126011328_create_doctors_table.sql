/*
  # Criação da Tabela de Médicos

  1. Nova Tabela
    - `doctors`
      - `id` (uuid, primary key)
      - `username` (text, unique) - Nome de usuário ou CRM
      - `password_hash` (text) - Hash da senha
      - `full_name` (text) - Nome completo do médico
      - `crm` (text, optional) - CRM do médico
      - `created_at` (timestamptz)
  
  2. Segurança
    - Enable RLS na tabela `doctors`
    - Adicionar políticas para permitir login (select público)
    - Adicionar políticas para permitir criação de usuário (insert público para fins de protótipo)
  
  3. Dados Iniciais
    - Criar um usuário médico padrão para testes:
      - username: "medico"
      - password: "senha123" (hash simplificado para protótipo)
*/

CREATE TABLE IF NOT EXISTS doctors (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  username text UNIQUE NOT NULL,
  password_hash text NOT NULL,
  full_name text NOT NULL,
  crm text,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE doctors ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Permitir consulta pública para login"
  ON doctors
  FOR SELECT
  TO anon, authenticated
  USING (true);

CREATE POLICY "Permitir inserção pública para cadastro"
  ON doctors
  FOR INSERT
  TO anon, authenticated
  WITH CHECK (true);

-- Inserir usuário médico padrão para testes
-- Senha: senha123 (em produção, usar hash bcrypt adequado)
INSERT INTO doctors (username, password_hash, full_name, crm)
VALUES ('medico', 'senha123', 'Dr. João Silva', '12345-SP')
ON CONFLICT (username) DO NOTHING;