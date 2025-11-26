# InsuGuia Mobile - Instruções de Instalação e Execução

## Descrição do Projeto

O InsuGuia Mobile é um aplicativo Flutter desenvolvido como protótipo educacional para auxiliar médicos na prescrição de insulina para pacientes não críticos internados em ambiente hospitalar.

É importanten destacar que este é um protótipo sem validade clínica, desenvolvido apenas para fins educacionais e demonstração de conceitos de desenvolvimento mobile.

## Funcionalidades Implementadas

1. **Login**
   - Validação de usuário e senha

2. **Cadastro de Paciente**
   - Formulário completo com validação de campos
   - Dados: nome, sexo, idade, peso, altura, creatinina, local de internação
   - Armazenamento no Supabase

3. **Visualização de Detalhes e Classificação Clínica**
   - Exibição de dados do paciente
   - Por hora, apenas como "Paciente Não Crítico"
   - Cálculo de IMC
   - Regras de cálculo aplicáveis

4. **Sugestão de Prescrição**
   - Geração automática baseada em regras simuladas baseadas no SBD
   - Tipo de dieta (baseado no IMC)
   - Monitorização glicêmica
   - Insulina basal e de ação rápida (doses calculadas por peso)
   - Protocolo de hipoglicemia
   - Ajustes por idade e função renal

5. **Acompanhamento Diário**
   - Registro de leituras de glicemia
   - Recomendações automáticas de ajuste
   - Histórico completo de medições
   - Estatísticas (média glicêmica, total de medições)

6. **Alta Hospitalar**
   - Geração de orientações de alta
   - Resumo do tratamento
   - Marcação do paciente como inativo

## Tecnologias Utilizadas

- **Framework**: Flutter (Dart)
- **Banco de Dados**: Supabase (PostgreSQL)
- **Bibliotecas**:
  - `supabase_flutter`: Cliente Supabase
  - `intl`: Formatação de datas
  - `flutter_form_builder` e `form_builder_validators`: Formulários e validação

## Instalação

### Pré-requisitos

- Flutter SDK (versão 3.9.2 ou superior)
- Android Studio ou VS Code com extensões Flutter
- Conta Supabase (já configurada)

### Passos

1. Clone ou baixe o projeto

2. Instale as dependências:
```bash
flutter pub get
```

3. Execute o aplicativo:
```bash
# Android
flutter run

# iOS (requer macOS)
flutter run

# Web
flutter run -d chrome
```

## Estrutura do Projeto

```
lib/
├── main.dart                          
├── models/                            
│   ├── patient.dart
│   ├── prescription.dart
│   ├── glycemic_reading.dart
│   └── discharge_instruction.dart
├── services/                          
│   ├── database_service.dart
│   ├── auth_service.dart     
│   └── prescription_service.dart     
└── screens/                          
    ├── login_screen.dart             
    ├── home_screen.dart              
    ├── patient_form_screen.dart      
    ├── patient_detail_screen.dart    
    ├── classification_screen.dart    
    ├── prescription_screen.dart      
    ├── monitoring_screen.dart        
    └── discharge_screen.dart        
```


## Regras de Cálculo Simuladas

### Insulina Basal
- Base: 0,2 UI/kg/dia
- Ajuste: Redução de 20% se creatinina > 1,5 mg/dL
- Insulina NPH com divisão em dose matinal (2/3) e dose noturna (1/3).

### Insulina Rápida
- Base: 0,1 UI/kg/dia dividido em 3 refeições
- Ajuste: Redução de 10% se idade > 65 anos

### Tipo de Dieta
- IMC > 30: Dieta hipocalórica (1500-1800 kcal/dia)
- IMC < 18.5: Dieta hipercalórica (2200-2500 kcal/dia)
- IMC normal: Dieta normocalórica (1800-2000 kcal/dia)

### Recomendações de Ajuste (Glicemia)
- < 70 mg/dL: Hipoglicemia - protocolo específico
- 70-100 mg/dL: Adequada mas monitorar
- 100-140 mg/dL: Dentro da meta
- 140-180 mg/dL: Levemente elevada
- 180-250 mg/dL: Hiperglicemia moderada
- > 250 mg/dL: Hiperglicemia importante

## Observações

1. Este aplicativo é apenas um protótipo educacional e não possui validade clínica.

## Equipe

- Luan Gerber Siiss - Gerente e Desenvolvedor
- Lucas Gilmar da Silva - Desenvolvedor
- Guilherme Afonso Casa - Desenvolvedor

Curso: Sistemas de Informação
