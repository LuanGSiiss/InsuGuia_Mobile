import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../models/prescription.dart';
import '../services/database_service.dart';
import '../services/prescription_service.dart';
import 'monitoring_screen.dart';

class PrescriptionScreen extends StatefulWidget {
  final Patient patient;

  const PrescriptionScreen({super.key, required this.patient});

  @override
  State<PrescriptionScreen> createState() => _PrescriptionScreenState();
}

class _PrescriptionScreenState extends State<PrescriptionScreen> {
  final _databaseService = DatabaseService();
  Prescription? _prescription;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadOrGeneratePrescription();
  }

  Future<void> _loadOrGeneratePrescription() async {
    try {
      final existingPrescription = await _databaseService.getPrescription(widget.patient.id!);

      if (existingPrescription != null) {
        setState(() {
          _prescription = existingPrescription;
          _isLoading = false;
        });
      } else {
        final newPrescription = PrescriptionService.generatePrescription(widget.patient);
        setState(() {
          _prescription = newPrescription;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar prescrição: $e')),
        );
      }
    }
  }

  Future<void> _savePrescription() async {
    if (_prescription == null) return;

    setState(() {
      _isSaving = true;
    });

    try {
      if (_prescription!.id == null) {
        await _databaseService.createPrescription(_prescription!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Prescrição salva com sucesso!')),
          );
        }
      }

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MonitoringScreen(patient: widget.patient),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar prescrição: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prescrição Sugerida'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _prescription == null
              ? const Center(child: Text('Erro ao gerar prescrição'))
              : SingleChildScrollView(
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
                                widget.patient.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Peso: ${widget.patient.weight} kg | IMC: ${widget.patient.bmi.toStringAsFixed(1)}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildPrescriptionSection(
                        'Tipo de Dieta',
                        _prescription!.dietType,
                        Icons.restaurant_menu,
                        Colors.green,
                      ),
                      _buildPrescriptionSection(
                        'Monitorização Glicêmica',
                        _prescription!.glycemicMonitoring,
                        Icons.monitor_heart,
                        Colors.orange,
                      ),
                      _buildPrescriptionSection(
                        'Insulina Basal',
                        _prescription!.basalInsulin,
                        Icons.medication,
                        Colors.blue,
                      ),
                      _buildPrescriptionSection(
                        'Insulina de Ação Rápida',
                        _prescription!.rapidInsulin,
                        Icons.medication_liquid,
                        Colors.red,
                      ),
                      _buildPrescriptionSection(
                        'Protocolo de Hipoglicemia',
                        _prescription!.hypoglycemiaInstructions,
                        Icons.warning_amber,
                        Colors.red[900]!,
                      ),
                      const SizedBox(height: 24),
                      Card(
                        color: Colors.amber[50],
                        child: const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Icon(Icons.info, color: Colors.amber),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Esta prescrição é simulada e serve apenas para fins educacionais. Não possui validade clínica.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _isSaving ? null : _savePrescription,
                        icon: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.save),
                        label: Text(_isSaving ? 'Salvando...' : 'Salvar e Iniciar Acompanhamento'),
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

  Widget _buildPrescriptionSection(String title, String content, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: Icon(icon, color: color),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                content,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
