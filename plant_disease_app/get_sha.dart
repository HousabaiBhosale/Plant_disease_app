import 'dart:io';

void main() {
  final userProfile = Platform.environment['USERPROFILE'];
  final result = Process.runSync(
    'C:\\Program Files\\Android\\Android Studio\\jbr\\bin\\keytool.exe',
    [
      '-list',
      '-v',
      '-keystore',
      '$userProfile\\.android\\debug.keystore',
      '-alias',
      'androiddebugkey',
      '-storepass',
      'android',
      '-keypass',
      'android'
    ]
  );
  
  final lines = result.stdout.toString().split('\n');
  final out = File('keys.txt');
  for (var line in lines) {
    if (line.contains('SHA1:') || line.contains('SHA256:')) {
      out.writeAsStringSync(line.trim() + '\n', mode: FileMode.append);
    }
  }
}
