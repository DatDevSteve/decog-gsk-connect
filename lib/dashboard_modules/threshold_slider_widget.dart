import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class ThresholdSliderWidget extends StatefulWidget {
  const ThresholdSliderWidget({Key? key}) : super(key: key);

  @override
  State<ThresholdSliderWidget> createState() => _ThresholdSliderWidgetState();
}

class _ThresholdSliderWidgetState extends State<ThresholdSliderWidget> {
  final SupabaseClient _supabase = Supabase.instance.client;

  double _currentThreshold = 700.0;
  bool _isLoading = true;
  bool _isUpdating = false;
  String _statusMessage = '';
  static const bg = Color.fromRGBO(28, 49, 50, 1);
  static const gold = Color.fromRGBO(215, 162, 101, 1);

  @override
  void initState() {
    super.initState();
    _fetchCurrentThreshold();
  }

  /// Fetch the current threshold from Supabase
  Future<void> _fetchCurrentThreshold() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _supabase
          .from('sensor_live')
          .select('sensor_threshold')
          .eq('id', 1)
          .single();

      if (response != null && response['sensor_threshold'] != null) {
        setState(() {
          _currentThreshold = response['sensor_threshold'].toDouble();
          _isLoading = false;
          _statusMessage = 'Current threshold loaded';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Error loading threshold: $e';
      });
      print('Error fetching threshold: $e');
    }
  }

  /// Update threshold in Supabase
  Future<void> _updateThreshold(double newThreshold) async {
    setState(() {
      _isUpdating = true;
      _statusMessage = 'Updating threshold...';
    });

    try {
      await _supabase
          .from('sensor_live')
          .update({'sensor_threshold': newThreshold.toInt()})
          .eq('id', 1);

      setState(() {
        _currentThreshold = newThreshold;
        _isUpdating = false;
        _statusMessage = 'Threshold updated to ${newThreshold.toInt()}';
      });

      // Clear status message after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _statusMessage = '';
          });
        }
      });
    } catch (e) {
      setState(() {
        _isUpdating = false;
        _statusMessage = 'Error updating: $e';
      });
      print('Error updating threshold: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Card(
      color: bg,
      elevation: 0,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.tune, color: gold, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Gas Threshold Control',
                  style: GoogleFonts.dmSans(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Current threshold display
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: _getThresholdColor(_currentThreshold).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _getThresholdColor(_currentThreshold),
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Current Threshold:',
                    style: GoogleFonts.dmSans(color: Colors.white, fontSize: 16),
                  ),
                  Text(
                    '${_currentThreshold.toInt()}',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: _getThresholdColor(_currentThreshold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Slider
            Row(
              children: [
                Text('Low\n(300)', textAlign: TextAlign.center, style: GoogleFonts.dmSans(color: Colors.white, fontSize: 12)),
                Expanded(
                  child: Slider(
                    value: _currentThreshold,
                    min: 300,
                    max: 900,
                    divisions: 60,
                    label: _currentThreshold.toInt().toString(),
                    activeColor: _getThresholdColor(_currentThreshold),
                    onChanged: _isUpdating ? null : (value) {
                      setState(() {
                        _currentThreshold = value;
                      });
                    },
                    onChangeEnd: (value) {
                      _updateThreshold(value);
                    },
                  ),
                ),
                Text('High\n(900)', textAlign: TextAlign.center, style: GoogleFonts.dmSans(color: Colors.white, fontSize: 12)),
              ],
            ),

            // Info text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Drag slider to adjust gas leak detection threshold',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: gold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),

            // Status message
            if (_statusMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _statusMessage.contains('Error')
                      ? Colors.red.withOpacity(0.1)
                      : Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      _statusMessage.contains('Error')
                          ? Icons.error_outline
                          : Icons.check_circle_outline,
                      color: _statusMessage.contains('Error')
                          ? Colors.red
                          : Colors.green,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _statusMessage,
                        style: GoogleFonts.dmSans(
                          color: _statusMessage.contains('Error')
                              ? Colors.red
                              : Colors.green,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Threshold guide
            const SizedBox(height: 16),
            _buildThresholdGuide(),
          ],
        ),
      ),
    );
  }

  Widget _buildThresholdGuide() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: gold, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 18, color: gold ),
              const SizedBox(width: 8),
              Text(
                'Threshold Guide',
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.bold,
                  color: gold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildGuideItem('300-500', 'Very Sensitive', Colors.green),
          _buildGuideItem('500-700', 'Normal (Recommended)', Colors.orange),
          _buildGuideItem('700-900', 'Less Sensitive', Colors.red),
        ],
      ),
    );
  }

  Widget _buildGuideItem(String range, String description, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$range: ',
            style: GoogleFonts.dmSans(color: gold, fontSize: 12, fontWeight: FontWeight.bold),
          ),
          Text(
            description,
            style: GoogleFonts.dmSans(fontSize: 12, color: gold),
          ),
        ],
      ),
    );
  }

  Color _getThresholdColor(double threshold) {
    if (threshold < 500) return Colors.green;
    if (threshold < 700) return Colors.orange;
    return Colors.red;
  }
}
