import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';

class EqualizerScreen extends StatefulWidget {
  const EqualizerScreen({super.key});

  @override
  State<EqualizerScreen> createState() => _EqualizerScreenState();
}

class _EqualizerScreenState extends State<EqualizerScreen> {
  bool _isEqEnabled = true;
  String _selectedPreset = 'Vocaloid';
  
  final List<String> _presets = ['Flat', 'Pop', 'Rock', 'Jazz', 'Vocaloid'];
  
  // Mock equalizer values
  double _v60 = 0.3;
  double _v150 = 0.5;
  double _v400 = 0.7;
  double _v1k = 0.9;
  double _v2_4k = 0.7;
  double _v6k = 0.5;
  double _v16k = 0.4;

  double _bass = 2.0;
  double _treble = 1.0;
  double _balance = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: Stack(
        children: [
          // Background decorations
          Positioned(
            left: 262, top: 104,
            child: Container(
              width: 202, height: 202,
              decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.teal.withOpacity(0.04)),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                const SizedBox(height: 16),
                _buildToggleSwitch(),
                const SizedBox(height: 32),
                _buildVerticalSliders(),
                const SizedBox(height: 24),
                _buildPresetsRow(),
                const SizedBox(height: 32),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: [
                      _buildHorizontalSlider('Bass', _bass, -10, 10, 'dB', (val) => setState(() => _bass = val)),
                      const SizedBox(height: 24),
                      _buildHorizontalSlider('Treble', _treble, -10, 10, 'dB', (val) => setState(() => _treble = val)),
                      const SizedBox(height: 24),
                      _buildHorizontalSlider('Balance', _balance, -10, 10, 'dB', (val) => setState(() => _balance = val)),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.deepCyan.withOpacity(0.2))),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.sky, size: 20),
            onPressed: () => context.pop(),
          ),
          const Expanded(
            child: Text(
              'Equalizer',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildToggleSwitch() {
    return Center(
      child: GestureDetector(
        onTap: () => setState(() => _isEqEnabled = !_isEqEnabled),
        child: Container(
          width: 80,
          height: 34,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: _isEqEnabled ? AppColors.teal : AppColors.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _isEqEnabled ? AppColors.teal : AppColors.deepCyan.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: _isEqEnabled ? MainAxisAlignment.spaceBetween : MainAxisAlignment.start,
            children: [
              if (_isEqEnabled)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Text('ON', style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.navy)),
                ),
              Container(
                width: 26, height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isEqEnabled ? AppColors.navy : AppColors.sky,
                ),
              ),
              if (!_isEqEnabled)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Text('OFF', style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.sky)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerticalSliders() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _VerticalSliderItem(label: '60', value: _v60, onChanged: (v) => setState(() => _v60 = v)),
          _VerticalSliderItem(label: '150', value: _v150, onChanged: (v) => setState(() => _v150 = v)),
          _VerticalSliderItem(label: '400', value: _v400, onChanged: (v) => setState(() => _v400 = v)),
          _VerticalSliderItem(label: '1K', value: _v1k, onChanged: (v) => setState(() => _v1k = v)),
          _VerticalSliderItem(label: '2.4K', value: _v2_4k, onChanged: (v) => setState(() => _v2_4k = v)),
          _VerticalSliderItem(label: '6K', value: _v6k, onChanged: (v) => setState(() => _v6k = v)),
          _VerticalSliderItem(label: '16K', value: _v16k, onChanged: (v) => setState(() => _v16k = v)),
        ],
      ),
    );
  }

  Widget _buildPresetsRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: _presets.map((preset) {
          final isSelected = _selectedPreset == preset;
          return GestureDetector(
            onTap: () => setState(() => _selectedPreset = preset),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.teal : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isSelected ? AppColors.teal : AppColors.sky.withOpacity(0.3)),
              ),
              child: Text(
                preset,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? AppColors.navy : AppColors.sky.withOpacity(0.8),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHorizontalSlider(String label, double value, double min, double max, String unit, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppColors.sky.withOpacity(0.8)),
        ),
        Row(
          children: [
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 4,
                  activeTrackColor: AppColors.teal,
                  inactiveTrackColor: AppColors.deepCyan.withOpacity(0.2),
                  thumbColor: AppColors.teal,
                  overlayColor: AppColors.teal.withOpacity(0.1),
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                ),
                child: Slider(
                  value: value,
                  min: min,
                  max: max,
                  onChanged: onChanged,
                ),
              ),
            ),
            SizedBox(
              width: 36,
              child: Text(
                '${value > 0 ? '+' : ''}${value.toInt()}$unit',
                textAlign: TextAlign.right,
                style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: AppColors.teal),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _VerticalSliderItem extends StatelessWidget {
  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  const _VerticalSliderItem({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: RotatedBox(
            quarterTurns: 3,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4,
                activeTrackColor: AppColors.teal,
                inactiveTrackColor: AppColors.deepCyan.withOpacity(0.2),
                thumbColor: AppColors.teal,
                overlayColor: AppColors.teal.withOpacity(0.1),
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
              ),
              child: Slider(
                value: value,
                onChanged: onChanged,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: TextStyle(fontFamily: 'Inter', fontSize: 10, color: AppColors.sky.withOpacity(0.5)),
        ),
      ],
    );
  }
}
