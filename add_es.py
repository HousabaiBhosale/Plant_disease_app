path = r"c:\Users\HP\PlantDiseaseApp\plant_disease_app\lib\services\language_service.dart"
with open(path,'r',encoding='utf-8') as f:
    c = f.read()

es_block = """    'es': {
      'home': 'Inicio',
      'history': 'Historial',
      'profile': 'Perfil',
      'recent_scans': 'Escaneos Recientes',
      'see_all': 'Ver todo',
      'scan_leaf': 'Escanear Hoja',
      'disease_info': 'Info de Enfermedad',
      'crop_tips': 'Consejos de Cultivo',
      'edit_profile': 'Editar Perfil',
      'language': 'Idioma',
      'notifications': 'Notificaciones',
      'location': 'Ubicacion',
      'offline_mode': 'Modo Sin Internet',
      'log_out': 'Cerrar Sesion',
      'diagnosis': 'Diagnostico',
      'symptoms': 'Sintomas',
      'treatment': 'Tratamiento',
      'prevention': 'Prevencion',
      'take_photo': 'Tomar Foto y Diagnosticar',
      'gallery': 'Galeria',
      'scans_done': 'Escaneos',
      'crops_helped': 'Cultivos Ayudados',
      'crops_grown': 'Cultivos Sembrados',
      'my_crops': 'Mis Cultivos',
      'status': 'Estado',
      'healthy': 'Saludable',
      'diseased': 'Enfermo',
      'unknown': 'Desconocido',
      'rate_app': 'Calificar PlantGuard',
      'rate_app_sub': 'Ayuda a los agricultores',
      'privacy_data': 'Privacidad y Datos',
      'privacy_data_sub': 'Las fotos no salen del telefono',
      'about_app': 'Acerca de PlantGuard',
      'about_app_sub': 'v1.0.0 - DeepCognix AI Labs',
      'offline_mode_sub': 'IA en dispositivo - sin internet',
      'notif_sub': 'Alertas de enfermedades y clima',
      'location_label': 'Ubicacion',
      'offline_title': 'Modo Sin Internet',
      'offline_desc': 'PlantGuard funciona sin internet. Tus datos nunca salen del telefono.',
      'rate_title': 'Que tal PlantGuard?',
      'rate_desc': 'Por favor califiquenos en Play Store!',
      'privacy_title': 'Privacidad y Datos',
      'privacy_desc': 'Todos los escaneos se procesan en el dispositivo sin subir fotos.',
      'about_title': 'Acerca de PlantGuard',
      'about_desc': 'PlantGuard v1.0.0 detecta enfermedades en 14 cultivos con 38+ clases.',
      'close': 'Cerrar',
      'go_rate': 'Calificar',
    }"""

check = "'es':"
if check not in c:
    c = c.replace("  };\n\n  String t(", es_block + "\n  };\n\n  String t(")
    with open(path,'w',encoding='utf-8') as f:
        f.write(c)
    print("ES added OK")
else:
    print("ES already present")
