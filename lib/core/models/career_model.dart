enum CareerTrack { construccion, salud, tecnologia }

extension CareerTrackExtension on CareerTrack {
  String get titleEs {
    switch (this) {
      case CareerTrack.construccion:
        return 'Construcción';
      case CareerTrack.salud:
        return 'Salud';
      case CareerTrack.tecnologia:
        return 'Tecnología';
    }
  }

  String get titleEn {
    switch (this) {
      case CareerTrack.construccion:
        return 'Construction';
      case CareerTrack.salud:
        return 'Healthcare';
      case CareerTrack.tecnologia:
        return 'Technology';
    }
  }

  String get emoji {
    switch (this) {
      case CareerTrack.construccion:
        return '🏗️';
      case CareerTrack.salud:
        return '🏥';
      case CareerTrack.tecnologia:
        return '💻';
    }
  }

  String get descriptionEs {
    switch (this) {
      case CareerTrack.construccion:
        return 'Vocabulario y frases para la obra';
      case CareerTrack.salud:
        return 'Inglés para clínicas y cuidado de pacientes';
      case CareerTrack.tecnologia:
        return 'Comunicación profesional en la oficina';
    }
  }

  List<int> get lessonIds {
    switch (this) {
      case CareerTrack.construccion:
        return [101, 102, 103];
      case CareerTrack.salud:
        return [201, 202, 203];
      case CareerTrack.tecnologia:
        return [301, 302, 303];
    }
  }
}
