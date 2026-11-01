import 'package:flutter_test/flutter_test.dart';
import 'package:library_app/core/practice_stage.dart';

void main() {
  test('ПР6 сохраняет формы и обязательную авторизацию', () {
    expect(practiceStage, 6);
    expect(supportsForms, isTrue);
    expect(supportsAuthentication, isTrue);
  });
}
