part of '../b787_preflight_checklist.dart';

class _ProcedureStage {
  const _ProcedureStage({
    required this.title,
    required this.reference,
    required this.items,
  });
  final String title, reference;
  final List<_ProcedureItem> items;
}

class _ProcedureItem {
  const _ProcedureItem(this.id, this.label, this.owner, {this.source = 'FCOM'});
  final String id, label, owner, source;
}
