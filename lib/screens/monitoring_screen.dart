import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/patient.dart';
import '../models/glycemic_reading.dart';
import '../services/database_service.dart';
import '../services/prescription_service.dart';
import 'discharge_screen.dart';

class MonitoringScreen extends StatefulWidget {
  final Patient patient;

  const MonitoringScreen({super.key, required this.patient});

  @override
  State<MonitoringScreen> createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends State<MonitoringScreen> {
  final _databaseService = DatabaseService();
  final _formKey = GlobalKey<FormState>();
  final _glucoseController = TextEditingController();

  List<GlycemicReading> _readings = [];
  bool _isLoading = true;
  bool _isSaving = false;

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String? _selectedPeriod;

  final List<Map<String, String>> _periodOptions = [
    {'label': 'Jejum', 'time': '07:00'},
    {'label': 'Pré-almoço', 'time': '11:30'},
    {'label': 'Pós-almoço', 'time': '14:00'},
    {'label': 'Pré-janta', 'time': '18:00'},
    {'label': 'Pós-janta', 'time': '20:30'},
    {'label': 'Antes de dormir', 'time': '22:00'},
  ];

  @override
  void initState() {
    super.initState();
    _loadReadings();
  }

  @override
  void dispose() {
    _glucoseController.dispose();
    super.dispose();
  }

  Future<void> _loadReadings() async {
    try {
      final readings = await _databaseService.getGlycemicReadings(widget.patient.id!);
      setState(() {
        _readings = readings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar leituras: $e')),
        );
      }
    }
  }

  Future<void> _saveReading(String timeString) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final glucoseValue = double.parse(_glucoseController.text);
      final recommendation = PrescriptionService.getAdjustmentRecommendation(glucoseValue);

      final reading = GlycemicReading(
        patientId: widget.patient.id!,
        readingDate: _selectedDate,
        readingTime: timeString,
        glucoseValue: glucoseValue,
        adjustmentRecommendation: recommendation,
      );

      await _databaseService.createGlycemicReading(reading);

      _glucoseController.clear();
      await _loadReadings();

      if (mounted) {
        _showRecommendationDialog(glucoseValue, recommendation);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar leitura: $e')),
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

  void _showRecommendationDialog(double glucoseValue, String recommendation) {
    Color dialogColor;
    IconData dialogIcon;
    String dialogTitle;

    if (glucoseValue < 70) {
      dialogColor = Colors.red;
      dialogIcon = Icons.warning_amber;
      dialogTitle = 'HIPOGLICEMIA';
    } else if (glucoseValue >= 70 && glucoseValue <= 180) {
      dialogColor = Colors.green;
      dialogIcon = Icons.check_circle;
      dialogTitle = 'Glicemia Adequada';
    } else {
      dialogColor = Colors.orange;
      dialogIcon = Icons.info;
      dialogTitle = 'HIPERGLICEMIA';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: dialogColor.withOpacity(0.7),
        title: Row(
          children: [
            Icon(dialogIcon, color: dialogColor, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                dialogTitle,
                style: TextStyle(color: dialogColor, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Glicemia: ${glucoseValue.toStringAsFixed(0)} mg/dL',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Recomendação:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              recommendation,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
  }

  String _getPeriodFromTime(TimeOfDay time) {
    final hour = time.hour;
    final minute = time.minute;
    final totalMinutes = hour * 60 + minute;

    if (totalMinutes >= 6 * 60 && totalMinutes < 9 * 60) {
      return 'Jejum';
    } else if (totalMinutes >= 11 * 60 && totalMinutes < 13 * 60) {
      return 'Pré-almoço';
    } else if (totalMinutes >= 13 * 60 && totalMinutes < 16 * 60) {
      return 'Pós-almoço';
    } else if (totalMinutes >= 17 * 60 && totalMinutes < 19 * 60) {
      return 'Pré-janta';
    } else if (totalMinutes >= 19 * 60 && totalMinutes < 21 * 60) {
      return 'Pós-janta';
    } else if (totalMinutes >= 21 * 60 || totalMinutes < 6 * 60) {
      return 'Antes de dormir';
    }
    return 'Jejum';
  }

  void _showAddReadingDialog() {
    final now = TimeOfDay.now();
    final initialPeriod = _getPeriodFromTime(now);

    showDialog(
      context: context,
      builder: (context) {
        String? selectedPeriod = initialPeriod;
        TimeOfDay selectedTime = now;

        return StatefulBuilder(builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('Nova Leitura de Glicemia'),
            content: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: const Text('Data'),
                      subtitle: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime.now().subtract(const Duration(days: 30)),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setStateDialog(() => _selectedDate = date);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('Horário'),
                      subtitle: Text(selectedTime.format(context)),
                      trailing: const Icon(Icons.access_time),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: selectedTime,
                        );
                        if (picked != null) {
                          setStateDialog(() {
                            selectedTime = picked;
                            selectedPeriod = _getPeriodFromTime(picked);
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedPeriod,
                      decoration: const InputDecoration(
                        labelText: 'Período do dia',
                        border: OutlineInputBorder(),
                        helperText: 'Selecionado automaticamente, pode ser alterado',
                      ),
                      items: _periodOptions
                          .map((period) => DropdownMenuItem(
                                value: period['label'],
                                child: Text(period['label']!),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setStateDialog(() => selectedPeriod = value);
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _glucoseController,
                      decoration: const InputDecoration(
                        labelText: 'Glicemia (mg/dL)',
                        border: OutlineInputBorder(),
                        suffixText: 'mg/dL',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Campo obrigatório';
                        final glucose = double.tryParse(value);
                        if (glucose == null || glucose <= 0 || glucose > 600) {
                          return 'Valor inválido';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: _isSaving
                    ? null
                    : () {
                        if (!_formKey.currentState!.validate()) {
                          return;
                        }

                        Navigator.pop(context);

                        final timeString =
                            "${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')} - ${selectedPeriod ?? ''}";

                        _saveReading(timeString);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Salvar'),
              ),
            ],
          );
        });
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final avgGlucose = _readings.isNotEmpty
        ? _readings.map((r) => r.glucoseValue).reduce((a, b) => a + b) / _readings.length
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Acompanhamento Diário'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Card(
                  margin: const EdgeInsets.all(16.0),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatCard(
                              'Medições',
                              _readings.length.toString(),
                              Icons.assessment,
                              Colors.blue,
                            ),
                            _buildStatCard(
                              'Média',
                              '${avgGlucose.toStringAsFixed(0)} mg/dL',
                              Icons.trending_up,
                              Colors.orange,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Histórico de Leituras',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _showAddReadingDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Nova Leitura'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _readings.isEmpty
                      ? const Center(
                          child: Text('Nenhuma leitura registrada'),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: _readings.length,
                          itemBuilder: (context, index) {
                            final reading = _readings[index];
                            return _buildReadingCard(reading);
                          },
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DischargeScreen(patient: widget.patient),
                        ),
                      );
                    },
                    icon: const Icon(Icons.exit_to_app),
                    label: const Text('Preparar Alta Hospitalar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildReadingCard(GlycemicReading reading) {
    Color statusColor;
    if (reading.glucoseValue < 70) {
      statusColor = Colors.red;
    } else if (reading.glucoseValue <= 140) {
      statusColor = Colors.green;
    } else if (reading.glucoseValue <= 180) {
      statusColor = Colors.orange;
    } else {
      statusColor = Colors.red;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor,
          child: Text(
            reading.glucoseValue.toStringAsFixed(0),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        title: Text(
          '${DateFormat('dd/MM/yyyy').format(reading.readingDate)} - ${reading.readingTime}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          reading.adjustmentRecommendation ?? 'Sem recomendação',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
      ),
    );
  }
}
