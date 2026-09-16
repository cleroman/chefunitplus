import 'package:flutter/material.dart';

import '../director/module_editor_screen.dart';

/// Wrapper : reutilise le meme editeur pour le formateur.
class TrainerModuleEditorScreen extends StatelessWidget {
  final String formationId;

  const TrainerModuleEditorScreen({
    super.key,
    this.formationId = '',
  });

  @override
  Widget build(BuildContext context) {
    return ModuleEditorScreen(formationId: formationId);
  }
}