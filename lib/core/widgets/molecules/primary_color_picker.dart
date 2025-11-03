import 'package:flutter/material.dart';

import 'package:travelmate/core/localization/app_localizations.dart';

Future<Color?> showPrimaryColorPickerDialog({
  required BuildContext context,
  required Color initialColor,
}) {
  final localizations = AppLocalizations.of(context);
  return showDialog<Color>(
    context: context,
    builder: (context) {
      return _PrimaryColorPickerDialog(
        initialColor: initialColor,
        applyLabel: localizations.translate('apply'),
        cancelLabel: localizations.translate('cancel'),
      );
    },
  );
}

class _PrimaryColorPickerDialog extends StatefulWidget {
  const _PrimaryColorPickerDialog({
    required this.initialColor,
    required this.applyLabel,
    required this.cancelLabel,
  });

  final Color initialColor;
  final String applyLabel;
  final String cancelLabel;

  @override
  State<_PrimaryColorPickerDialog> createState() =>
      _PrimaryColorPickerDialogState();
}

class _PrimaryColorPickerDialogState
    extends State<_PrimaryColorPickerDialog> {
  late HSLColor _currentColor;

  @override
  void initState() {
    super.initState();
    _currentColor = HSLColor.fromColor(widget.initialColor);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.applyLabel),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ColorPreview(color: _currentColor.toColor()),
          const SizedBox(height: 16),
          _SliderRow(
            label: 'H',
            value: _currentColor.hue / 360,
            onChanged: (value) => _updateColor(_currentColor.withHue(value * 360)),
          ),
          const SizedBox(height: 12),
          _SliderRow(
            label: 'S',
            value: _currentColor.saturation,
            onChanged: (value) =>
                _updateColor(_currentColor.withSaturation(value)),
          ),
          const SizedBox(height: 12),
          _SliderRow(
            label: 'L',
            value: _currentColor.lightness,
            onChanged: (value) => _updateColor(_currentColor.withLightness(value)),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(widget.cancelLabel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_currentColor.toColor()),
          child: Text(widget.applyLabel),
        ),
      ],
    );
  }

  void _updateColor(HSLColor newColor) {
    setState(() {
      _currentColor = newColor;
    });
  }
}

class _ColorPreview extends StatelessWidget {
  const _ColorPreview({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: color,
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 24,
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        Expanded(
          child: Slider(
            value: value,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
