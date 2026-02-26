import 'package:flutter/material.dart';

class MilestoneData {
  const MilestoneData({
    required this.xpRequired,
    required this.icon,
    required this.titleEs,
    required this.achievementEs,
  });

  final int xpRequired;
  final IconData icon;
  final String titleEs;
  final String achievementEs;
}

const kMilestones = <MilestoneData>[
  MilestoneData(
    xpRequired: 0,
    icon: Icons.flag,
    titleEs: 'Primer Paso',
    achievementEs: 'Comenzaste tu viaje',
  ),
  MilestoneData(
    xpRequired: 50,
    icon: Icons.chat_bubble,
    titleEs: 'Primeras Palabras',
    achievementEs: 'Aprendiste tus primeras 50 palabras',
  ),
  MilestoneData(
    xpRequired: 120,
    icon: Icons.explore,
    titleEs: 'Explorador',
    achievementEs: 'Completaste tu primera lección',
  ),
  MilestoneData(
    xpRequired: 210,
    icon: Icons.hiking,
    titleEs: 'Caminante',
    achievementEs: 'Dominaste 3 lecciones',
  ),
  MilestoneData(
    xpRequired: 330,
    icon: Icons.school,
    titleEs: 'Estudiante',
    achievementEs: 'Completaste tu primera práctica de voz',
  ),
  MilestoneData(
    xpRequired: 500,
    icon: Icons.menu_book,
    titleEs: 'Lector',
    achievementEs: 'Escribiste tu primera página',
  ),
  MilestoneData(
    xpRequired: 700,
    icon: Icons.record_voice_over,
    titleEs: 'Orador',
    achievementEs: 'Completaste un simulador de vida real',
  ),
  MilestoneData(
    xpRequired: 950,
    icon: Icons.auto_stories,
    titleEs: 'Escritor',
    achievementEs: 'Escribiste 5 páginas en tu libro',
  ),
  MilestoneData(
    xpRequired: 1250,
    icon: Icons.edit_note,
    titleEs: 'Autor',
    achievementEs: 'Completaste todas las lecciones',
  ),
  MilestoneData(
    xpRequired: 1600,
    icon: Icons.workspace_premium,
    titleEs: 'Maestro',
    achievementEs: '¡Publicaste tu libro!',
  ),
];
