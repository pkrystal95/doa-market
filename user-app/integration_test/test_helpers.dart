import 'package:flutter_test/flutter_test.dart';

/// 통합 테스트를 위한 헬퍼 함수 모음

/// 여러 텍스트 중 하나라도 찾으면 해당 Finder 반환
Finder findAnyText(List<String> texts) {
  for (final text in texts) {
    final finder = find.text(text);
    if (finder.evaluate().isNotEmpty) {
      return finder;
    }
  }
  return find.text(texts.first); // 기본값 반환
}

/// 여러 텍스트를 포함하는 것 중 하나라도 찾으면 해당 Finder 반환
Finder findAnyTextContaining(List<String> texts) {
  for (final text in texts) {
    final finder = find.textContaining(text);
    if (finder.evaluate().isNotEmpty) {
      return finder;
    }
  }
  return find.textContaining(texts.first); // 기본값 반환
}

/// 여러 아이콘 중 하나라도 찾으면 해당 Finder 반환
Finder findAnyIcon(List<dynamic> icons) {
  for (final icon in icons) {
    final finder = find.byIcon(icon);
    if (finder.evaluate().isNotEmpty) {
      return finder;
    }
  }
  return find.byIcon(icons.first); // 기본값 반환
}

/// 여러 위젯 타입 중 하나라도 찾으면 해당 Finder 반환
Finder findAnyType(List<Type> types) {
  for (final type in types) {
    final finder = find.byType(type);
    if (finder.evaluate().isNotEmpty) {
      return finder;
    }
  }
  return find.byType(types.first); // 기본값 반환
}

/// 텍스트 중 하나라도 존재하는지 확인
bool hasAnyText(List<String> texts) {
  for (final text in texts) {
    if (find.text(text).evaluate().isNotEmpty) {
      return true;
    }
  }
  return false;
}

/// 아이콘 중 하나라도 존재하는지 확인
bool hasAnyIcon(List<dynamic> icons) {
  for (final icon in icons) {
    if (find.byIcon(icon).evaluate().isNotEmpty) {
      return true;
    }
  }
  return false;
}
