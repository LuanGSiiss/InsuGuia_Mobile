import 'package:flutter/material.dart';
import '../models/patient.dart';
import 'prescription_screen.dart';

class ClassificationScreen extends StatelessWidget {
  final Patient patient;

  const ClassificationScreen({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Classificação Clínica'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'IMC: ${patient.bmi.toStringAsFixed(1)}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        const Text(
                          'Tipo de Paciente',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    const Text(
                      'PACIENTE NÃO CRÍTICO',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Regras de Cálculo Aplicáveis',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    _buildRuleItem(
                      'Dose Basal de Insulina',
                      'Calculada com base no peso corporal (0,2 UI/kg/dia)',
                      Icons.calculate,
                    ),
                    _buildRuleItem(
                      'Dose de Insulina Rápida',
                      'Calculada com base no peso corporal (0,1 UI/kg/dia)',
                      Icons.calculate,
                    ),
                    _buildRuleItem(
                      'Ajuste por Função Renal',
                      patient.creatinine > 1.5
                          ? 'Redução de 20% na dose basal devido creatinina elevada'
                          : 'Função renal preservada - sem ajuste necessário',
                      Icons.health_and_safety,
                    ),
                    _buildRuleItem(
                      'Ajuste por Idade',
                      patient.age > 65
                          ? 'Redução de 10% na dose de insulina rápida (idade > 65 anos)'
                          : 'Idade adequada - sem ajuste necessário',
                      Icons.elderly,
                    ),
                    _buildRuleItem(
                      'Tipo de Dieta',
                      _getDietDescription(patient.bmi),
                      Icons.restaurant,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Orientações Gerais',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    const Text(
                      '• Monitorização glicêmica 4x ao dia\n'
                      '• Dieta fracionada em 6 refeições\n'
                      '• Protocolo de hipoglicemia disponível\n'
                      '• Escala de correção conforme glicemia\n'
                      '• Acompanhamento diário da equipe',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PrescriptionScreen(patient: patient),
                  ),
                );
              },
              icon: const Icon(Icons.medical_services),
              label: const Text('Gerar Prescrição Sugerida'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRuleItem(String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getDietDescription(double bmi) {
    if (bmi > 30) {
      return 'Dieta hipocalórica (sobrepeso/obesidade)';
    } else if (bmi < 18.5) {
      return 'Dieta hipercalórica (baixo peso)';
    } else {
      return 'Dieta normocalórica (peso adequado)';
    }
  }
}
