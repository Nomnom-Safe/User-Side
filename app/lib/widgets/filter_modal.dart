import 'package:flutter/material.dart';
import 'multi_select_checkbox_list.dart';

class FilterModal extends StatelessWidget {
  final String buttonLabel;
  final String title;
  final List<String> options;
  final List<String> selectedOptions;
  final ValueChanged<List<String>> onChanged;
  final bool enabled;
  final String? disabledTooltip;

  const FilterModal({
    required this.buttonLabel,
    required this.title,
    required this.options,
    required this.selectedOptions,
    required this.onChanged,
    super.key,
    this.enabled = true,
    this.disabledTooltip,
  });

  void _showMultiSelectDialog(BuildContext context) async {
    final tempSelections = Set<String>.from(selectedOptions);

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              contentPadding: const EdgeInsets.only(
                top: 8,
                left: 24,
                right: 24,
                bottom: 16,
              ),
              titlePadding: const EdgeInsets.only(left: 24, right: 8, top: 16),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title),
                  IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: 'Close',
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: MultiSelectCheckboxList(
                  options: options,
                  selected: tempSelections,
                  onChanged: (option, checked) {
                    setState(() {
                      if (checked) {
                        tempSelections.add(option);
                      } else {
                        tempSelections.remove(option);
                      }
                    });
                  },
                ),
              ),
              actionsAlignment: MainAxisAlignment.spaceBetween,
              actions: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: tempSelections.isNotEmpty
                        ? MainAxisAlignment.spaceBetween
                        : MainAxisAlignment.end,
                    children: [
                      if (tempSelections.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              tempSelections.clear();
                            });
                          },
                          child: const Text('Clear Selection'),
                        ), // placeholder to maintain spacing
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          onChanged(tempSelections.toList());
                        },
                        child: const Text('Apply'),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton.icon(
      icon: const Icon(Icons.filter_alt),
      label: Text(buttonLabel),
      onPressed: enabled ? () => _showMultiSelectDialog(context) : null,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );

    if (!enabled && (disabledTooltip != null && disabledTooltip!.isNotEmpty)) {
      return Tooltip(
        message: disabledTooltip!,
        child: MouseRegion(cursor: SystemMouseCursors.basic, child: button),
      );
    }

    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: button,
    );
  }
}
