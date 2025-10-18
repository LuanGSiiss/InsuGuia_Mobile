import '../models/patient.dart';
import '../models/prescription.dart';

class PrescriptionService {
  static Prescription generatePrescription(Patient patient) {
    final double basalDose = _calculateBasalDose(patient);
    final double rapidDose = _calculateRapidDose(patient);

    return Prescription(
      patientId: patient.id!,
      dietType: _getDietType(patient),
      glycemicMonitoring: _getGlycemicMonitoring(),
      basalInsulin: _getBasalInsulinInstructions(basalDose),
      rapidInsulin: _getRapidInsulinInstructions(rapidDose),
      hypoglycemiaInstructions: _getHypoglycemiaInstructions(),
    );
  }

  static double _calculateBasalDose(Patient patient) {
    final baseDose = patient.weight * 0.2;
    if (patient.creatinine > 1.5) {
      return baseDose * 0.8;
    }
    return baseDose;
  }

  static double _calculateRapidDose(Patient patient) {
    final baseDose = patient.weight * 0.1;
    if (patient.age > 65) {
      return baseDose * 0.9;
    }
    return baseDose;
  }

  static String _getDietType(Patient patient) {
    if (patient.bmi > 30) {
      return 'Dieta hipocalórica (1500-1800 kcal/dia) - Fracionada em 6 refeições';
    } else if (patient.bmi < 18.5) {
      return 'Dieta hipercalórica (2200-2500 kcal/dia) - Fracionada em 6 refeições';
    } else {
      return 'Dieta normocalórica (1800-2000 kcal/dia) - Fracionada em 6 refeições';
    }
  }

  static String _getGlycemicMonitoring() {
    return '''Monitorização glicêmica 4x ao dia:
- Jejum (antes do café da manhã)
- Pré-almoço
- Pré-jantar
- Antes de dormir

Meta glicêmica:
- Jejum e pré-refeições: 100-140 mg/dL
- Pós-refeições (2h): < 180 mg/dL''';
  }

  static String _getBasalInsulinInstructions(double dose) {
    return '''Insulina Basal (NPH ou Glargina):
- Dose: ${dose.toStringAsFixed(0)} UI/dia
- Aplicação: 22h (antes de dormir)
- Via: Subcutânea (região abdominal ou coxa)

Ajustes:
- Se glicemia de jejum > 180 mg/dL: aumentar 2 UI
- Se glicemia de jejum < 70 mg/dL: reduzir 2 UI''';
  }

  static String _getRapidInsulinInstructions(double dose) {
    return '''Insulina Rápida (Regular):
- Dose por refeição: ${(dose / 3).toStringAsFixed(0)} UI
- Aplicação: 30 minutos antes das principais refeições (café, almoço, jantar)
- Via: Subcutânea (região abdominal)

Escala de correção (se glicemia pré-refeição):
- 150-200 mg/dL: adicionar 2 UI
- 201-250 mg/dL: adicionar 4 UI
- 251-300 mg/dL: adicionar 6 UI
- > 300 mg/dL: adicionar 8 UI e reavaliar''';
  }

  static String _getHypoglycemiaInstructions() {
    return '''Protocolo de Hipoglicemia:

Se glicemia < 70 mg/dL:
1. Administrar 15g de carboidrato de ação rápida:
   - 150ml de suco de laranja ou
   - 3 sachês de açúcar (15g) ou
   - 3 balas de glicose

2. Aguardar 15 minutos e medir novamente

3. Se ainda < 70 mg/dL, repetir o passo 1

4. Após normalização, oferecer lanche com carboidrato complexo

Se glicemia < 50 mg/dL ou paciente inconsciente:
- Acionar equipe médica imediatamente
- Não administrar nada por via oral
- Preparar para glicose IV 50%''';
  }

  static String getAdjustmentRecommendation(double glucoseValue) {
    if (glucoseValue < 70) {
      return 'HIPOGLICEMIA - Seguir protocolo de hipoglicemia. Considerar redução de insulina.';
    } else if (glucoseValue >= 70 && glucoseValue < 100) {
      return 'Glicemia adequada, porém próxima ao limite inferior. Monitorar atentamente.';
    } else if (glucoseValue >= 100 && glucoseValue <= 140) {
      return 'Glicemia dentro da meta. Manter esquema atual.';
    } else if (glucoseValue > 140 && glucoseValue <= 180) {
      return 'Glicemia levemente elevada. Verificar adesão à dieta e aplicação de insulina.';
    } else if (glucoseValue > 180 && glucoseValue <= 250) {
      return 'Hiperglicemia moderada. Aplicar escala de correção e considerar aumento da dose basal em 10%.';
    } else {
      return 'HIPERGLICEMIA IMPORTANTE - Aplicar escala de correção. Reavaliar esquema de insulina. Investigar causas (infecção, estresse, má adesão).';
    }
  }

  static String generateDischargeInstructions(Patient patient) {
    return '''ORIENTAÇÕES DE ALTA HOSPITALAR - DIABETES

Paciente: ${patient.name}

1. MEDICAÇÃO
Continue usando a insulina conforme prescrito durante a internação até a consulta com endocrinologista. Não suspenda sem orientação médica.

2. MONITORIZAÇÃO
- Medir glicemia capilar conforme orientado pela equipe
- Anotar valores em um caderno com data e hora
- Levar anotações nas consultas

3. ALIMENTAÇÃO
- Manter dieta fracionada (6 refeições ao dia)
- Evitar: açúcar, mel, doces, refrigerantes, sucos industrializados
- Preferir: verduras, legumes, frutas com casca, carnes magras
- Controlar quantidade de carboidratos (pães, massas, arroz)

4. SINAIS DE ALERTA - PROCURAR EMERGÊNCIA SE:
- Glicemia menor que 60 mg/dL com sintomas
- Glicemia maior que 300 mg/dL persistente
- Náuseas, vômitos, dor abdominal intensa
- Confusão mental, sonolência excessiva
- Febre, sinais de infecção

5. CONSULTAS DE SEGUIMENTO
- Endocrinologista: agendar em até 15 dias
- Levar: receitas, exames e anotações de glicemia

6. CUIDADOS COM APLICAÇÃO DE INSULINA
- Conservar na geladeira (não no congelador)
- Caneta em uso pode ficar fora da geladeira por até 28 dias
- Fazer rodízio dos locais de aplicação
- Descartar agulhas em recipiente rígido

Dúvidas: Entre em contato com a unidade de saúde''';
  }

  static String generateTreatmentSummary(Patient patient, Prescription prescription, List<dynamic> readings) {
    final avgGlucose = readings.isNotEmpty
        ? readings.map((r) => r.glucoseValue as double).reduce((a, b) => a + b) / readings.length
        : 0.0;

    return '''RESUMO DO TRATAMENTO HOSPITALAR

Paciente: ${patient.name}
Idade: ${patient.age} anos | Sexo: ${patient.sex}
IMC: ${patient.bmi.toStringAsFixed(1)} kg/m²

INTERNAÇÃO:
Local: ${patient.admissionLocation}
Tipo: ${patient.patientType}

ESQUEMA INSULÍNICO UTILIZADO:
${prescription.basalInsulin}

${prescription.rapidInsulin}

MONITORIZAÇÃO GLICÊMICA:
- Total de medições: ${readings.length}
- Média glicêmica: ${avgGlucose.toStringAsFixed(0)} mg/dL
- Meta alcançada: ${avgGlucose >= 100 && avgGlucose <= 140 ? 'SIM' : 'PARCIALMENTE'}

EVOLUÇÃO:
${readings.length > 0 ? 'Paciente apresentou controle glicêmico durante a internação com esquema de insulina conforme descrito.' : 'Dados de monitorização não disponíveis.'}

Paciente apto para alta hospitalar com acompanhamento ambulatorial em endocrinologia.''';
  }
}
