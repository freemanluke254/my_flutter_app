import 'package:flutter/material.dart';

class CrewNameField extends StatefulWidget {
  const CrewNameField({
    required this.controller,
    required this.label,
    required this.names,
    required this.onNewName,
    super.key,
  });
  final TextEditingController controller;
  final String label;
  final List<String> names;
  final ValueChanged<String> onNewName;

  @override
  State<CrewNameField> createState() => _CrewNameFieldState();
}

class _CrewNameFieldState extends State<CrewNameField> {
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RawAutocomplete<String>(
    textEditingController: widget.controller,
    focusNode: _focusNode,
    displayStringForOption: (option) => option,
    optionsBuilder: (value) {
      final query = value.text.trim().toLowerCase();
      if (query.isEmpty) return widget.names;
      return widget.names.where((name) => name.toLowerCase().contains(query));
    },
    onSelected: (value) => widget.controller.text = value,
    fieldViewBuilder: (context, controller, focusNode, onSubmitted) =>
        TextField(
          controller: controller,
          focusNode: focusNode,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: widget.label,
            suffixIcon: const Icon(Icons.arrow_drop_down_rounded),
          ),
          onSubmitted: (value) {
            _addIfNew(value);
            onSubmitted();
          },
          onEditingComplete: () => _addIfNew(controller.text),
        ),
    optionsViewBuilder: (context, onSelected, options) => Align(
      alignment: Alignment.topLeft,
      child: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(12),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 240, maxWidth: 320),
          child: ListView(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            children: options
                .map(
                  (name) => ListTile(
                    title: Text(name),
                    leading: const Icon(Icons.person_outline_rounded),
                    onTap: () => onSelected(name),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    ),
  );

  void _addIfNew(String value) {
    final name = value.trim();
    if (name.isEmpty ||
        widget.names.any((item) => item.toLowerCase() == name.toLowerCase())) {
      return;
    }
    widget.onNewName(name);
  }
}
