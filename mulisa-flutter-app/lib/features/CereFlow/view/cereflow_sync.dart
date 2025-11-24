import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class CereFlowSyncPage extends StatelessWidget {
  static const routeName = '/careflow-sync';
  const CereFlowSyncPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('CereFlow Sync'),
      //   centerTitle: true,
      //   actions: [
      //     IconButton(
      //       tooltip: 'Export',
      //       onPressed: () {},
      //       icon: const Icon(Icons.ios_share_outlined),
      //     )
      //   ],
      // ),
      body: const _DashboardGrid(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            showDragHandle: true,
            builder: (c) => const _QuickRecordSheet(), // keep if you already added it
          );
        },
        icon: const Icon(Icons.monitor_heart_outlined),
        label: const Text('Record Vitals'),
      ),
    );
  }
}

class _DashboardGrid extends StatelessWidget {
  const _DashboardGrid();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final isWide = c.maxWidth >= 900;
      final isTablet = c.maxWidth >= 600;
      final cross = isWide ? 3 : (isTablet ? 2 : 1);
      return CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
            sliver: SliverGrid.count(
              crossAxisCount: cross,
              childAspectRatio: 1.1,
              children: const [
                _MetricCard(title: 'Hemoglobin (g/dL)', child: _HemoglobinLine()),
                _MetricCard(title: 'Pain Crises / Month', child: _PainCrisesBar()),
                _MetricCard(title: 'SpO₂ Waveform (%)', child: _SpO2Wave()),
                _MetricCard(title: 'Pain Score (0–10)', child: _PainScoreLine()),
                _MetricCard(title: 'Medication Adherence', child: _AdherenceRing()),
                _MetricCard(title: 'Crisis Timeline (14d)', child: _CrisisTimeline()),
              ],
            ),
          )
        ],
      );
    });
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _MetricCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: child,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 1) Hemoglobin trend (with chart swap animation)
class _HemoglobinLine extends StatelessWidget {
  const _HemoglobinLine();
  @override
  Widget build(BuildContext context) {
    final points = [8.0, 9.2, 8.6, 7.4, 8.1, 8.3, 7.9, 8.4, 8.0, 7.8, 8.1];
    return LineChart(
      LineChartData(
        minY: 6,
        maxY: 11,
        gridData: FlGridData(show: true, drawVerticalLine: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, interval: 2, getTitlesWidget: (v, _) => Text('W${v.toInt()}'))),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: [for (int i = 0; i < points.length; i++) FlSpot(i.toDouble(), points[i])],
            isCurved: true,
            barWidth: 3,
            dotData: const FlDotData(show: false),
          ),
        ],
      ),
      // swapAnimationDuration: Duration(milliseconds: 600),
      // swapAnimationCurve: Curves.easeInOutCubic,
    );
  }
}

/// 2) Pain crises per month (animated)
class _PainCrisesBar extends StatelessWidget {
  const _PainCrisesBar();
  @override
  Widget build(BuildContext context) {
    final monthly = [2, 1, 3, 1, 2, 4, 3, 2, 1, 2, 3, 2];
    return BarChart(
      BarChartData(
        borderData: FlBorderData(show: false),
        gridData: FlGridData(show: true, drawVerticalLine: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) {
              const labels = ['J','F','M','A','M','J','J','A','S','O','N','D'];
              if (v < 0 || v > 11) return const SizedBox.shrink();
              return Text(labels[v.toInt()]);
            }),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        barGroups: [
          for (int i = 0; i < monthly.length; i++)
            BarChartGroupData(x: i, barRods: [
              BarChartRodData(toY: monthly[i].toDouble(), width: 16, borderRadius: BorderRadius.circular(4))
            ])
        ],
      ),
      swapAnimationDuration: const Duration(milliseconds: 600),
      swapAnimationCurve: Curves.easeInOutCubic,
    );
  }
}

/// 3) SpO₂ waveform (LIVE scrolling)
class _SpO2Wave extends StatefulWidget {
  const _SpO2Wave();
  @override
  State<_SpO2Wave> createState() => _SpO2WaveState();
}

class _SpO2WaveState extends State<_SpO2Wave> {
  static const _len = 80; // visible samples
  static const _dt = Duration(milliseconds: 120);
  late List<FlSpot> _spots;
  Timer? _timer;
  int _tick = 0;

  @override
  void initState() {
    super.initState();
    _spots = List.generate(_len, (i) => FlSpot(i.toDouble(), _value(i)));
    _timer = Timer.periodic(_dt, (_) {
      _tick++;
      // shift left and append a new point
      _spots = [
        for (int i = 1; i < _spots.length; i++) FlSpot(i - 1.0, _spots[i].y),
      ]..add(FlSpot((_len - 1).toDouble(), _value(_tick)));
      if (mounted) setState(() {});
    });
  }

  double _value(int i) {
    // Simple synthetic pleth-like waveform around ~97–99 with periodic spikes
    final saw = (i % 16 == 0) ? 2.2 : 0.0;  // brief pulse
    final square = (i % 8 < 4) ? 0.5 : -0.5; // low-freq oscillation
    return 97.2 + saw + square; // 96.7–99.9 approx
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        minY: 94,
        maxY: 100,
        gridData: FlGridData(show: true),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: _spots,
            isCurved: true,
            barWidth: 2.2,
            dotData: const FlDotData(show: false),
          ),
        ],
      ),
      // swapAnimationDuration: const Duration(milliseconds: 300),
      // swapAnimationCurve: Curves.linear,
    );
  }
}

/// 4) Pain score trend (animated)
class _PainScoreLine extends StatelessWidget {
  const _PainScoreLine();
  @override
  Widget build(BuildContext context) {
    final scores = [4, 7, 5, 9, 6, 4, 7, 5, 4, 3];
    return LineChart(
      LineChartData(
        minY: 0,
        maxY: 10,
        gridData: FlGridData(show: true, drawVerticalLine: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 26)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) => Text('D${v.toInt() + 1}'))),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: [for (int i = 0; i < scores.length; i++) FlSpot(i.toDouble(), scores[i].toDouble())],
            isCurved: true,
            barWidth: 3,
            dotData: const FlDotData(show: true),
          )
        ],
      ),
      // swapAnimationDuration: const Duration(milliseconds: 600),
      // swapAnimationCurve: Curves.easeInOutCubic,
    );
  }
}

/// 5) Medication adherence (ring, animated)
class _AdherenceRing extends StatelessWidget {
  const _AdherenceRing();
  @override
  Widget build(BuildContext context) {
    const taken = 24.0;
    const missed = 6.0; // 80% adherence
    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: [
          PieChartSectionData(value: taken, title: 'Taken', radius: 46),
          PieChartSectionData(value: missed, title: 'Missed', radius: 46),
        ],
      ),
      swapAnimationDuration: const Duration(milliseconds: 600),
      swapAnimationCurve: Curves.easeInOutCubic,
    );
  }
}

/// 6) Crisis timeline grid (static UI container)
class _CrisisTimeline extends StatelessWidget {
  const _CrisisTimeline();
  @override
  Widget build(BuildContext context) {
    final days = List.generate(14, (i) => i);
    final crisisDays = {1, 5, 6, 11};
    return Row(
      children: [
        for (final d in days)
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Theme.of(context).dividerColor),
                      color: crisisDays.contains(d)
                          ? Theme.of(context).colorScheme.errorContainer
                          : Theme.of(context).colorScheme.surface,
                    ),
                    child: Center(
                      child: Icon(
                        crisisDays.contains(d) ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                        size: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text('D${d + 1}', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          )
      ],
    );
  }
}

// NOTE: If you haven't already pasted _QuickRecordSheet from earlier,
// keep your previous implementation here so the FAB works.

// --- Bottom sheet: quick vitals entry ---------------------------------------
class _QuickRecordSheet extends StatefulWidget {
  const _QuickRecordSheet();

  @override
  State<_QuickRecordSheet> createState() => _QuickRecordSheetState();
}

class _QuickRecordSheetState extends State<_QuickRecordSheet> {
  final _formKey = GlobalKey<FormState>();
  final _spo2Ctrl = TextEditingController();
  final _hbCtrl = TextEditingController();
  final _tempCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  double _pain = 3;
  bool _tookMeds = false;
  DateTime _when = DateTime.now();

  @override
  void dispose() {
    _spo2Ctrl.dispose();
    _hbCtrl.dispose();
    _tempCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  String? _num(String? v, {double? min, double? max}) {
    if (v == null || v.trim().isEmpty) return null; // optional fields
    final x = double.tryParse(v);
    if (x == null) return 'Enter a number';
    if (min != null && x < min) return 'Min $min';
    if (max != null && x > max) return 'Max $max';
    return null;
  }

  Future<void> _pickWhen() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _when,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (d == null) return;
    final t = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_when));
    setState(() {
      _when = DateTime(
        d.year, d.month, d.day, t?.hour ?? _when.hour, t?.minute ?? _when.minute,
      );
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop({
      'when': _when.toIso8601String(),
      'spo2': _spo2Ctrl.text.isEmpty ? null : double.parse(_spo2Ctrl.text),
      'hb': _hbCtrl.text.isEmpty ? null : double.parse(_hbCtrl.text),
      'temp_c': _tempCtrl.text.isEmpty ? null : double.parse(_tempCtrl.text),
      'pain': _pain.round(),
      'tookMeds': _tookMeds,
      'notes': _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(
        left: 16, right: 16, bottom: insets + 16, top: 12,
      ),
      child: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Grab handle spacing is provided by showDragHandle: true
                Row(
                  children: [
                    Text('Quick Record', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                    const Spacer(),
                    IconButton(
                      tooltip: 'Pick date & time',
                      onPressed: _pickWhen,
                      icon: const Icon(Icons.schedule_outlined),
                    ),
                    Text(
                      TimeOfDay.fromDateTime(_when).format(context),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _spo2Ctrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'SpO₂ (%)',
                          hintText: 'e.g., 98',
                          prefixIcon: Icon(Icons.bloodtype_outlined),
                        ),
                        validator: (v) => _num(v, min: 50, max: 100),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _hbCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Hemoglobin (g/dL)',
                          hintText: 'e.g., 8.5',
                          prefixIcon: Icon(Icons.biotech_outlined),
                        ),
                        validator: (v) => _num(v, min: 3, max: 20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _tempCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Temperature (°C)',
                          hintText: 'e.g., 37.0',
                          prefixIcon: Icon(Icons.device_thermostat),
                        ),
                        validator: (v) => _num(v, min: 30, max: 45),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Pain (0–10)',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.fromLTRB(12, 8, 12, 8),
                        ),
                        child: Row(
                          children: [
                            const Text('0'),
                            Expanded(
                              child: Slider(
                                value: _pain,
                                min: 0,
                                max: 10,
                                divisions: 10,
                                label: _pain.round().toString(),
                                onChanged: (v) => setState(() => _pain = v),
                              ),
                            ),
                            const Text('10'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                SwitchListTile(
                  title: const Text('Medication taken (today)'),
                  value: _tookMeds,
                  onChanged: (v) => setState(() => _tookMeds = v),
                  secondary: const Icon(Icons.medication_outlined),
                  contentPadding: EdgeInsets.zero,
                ),

                TextFormField(
                  controller: _notesCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                    hintText: 'Triggers, symptoms, activity, etc.',
                    prefixIcon: Icon(Icons.note_alt_outlined),
                  ),
                ),
                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.close),
                        label: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _submit,
                        icon: const Icon(Icons.save_outlined),
                        label: const Text('Save'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


/// Optional: Simple provider to refresh with new mock data in the future can be added here.
