/// 가격 포맷팅 유틸리티
class FormatUtils {
  /// 가격을 원화 형식으로 포맷팅 (천 단위 콤마, 소수점 제거)
  static String formatPrice(dynamic price) {
    if (price == null) return '0원';

    // String이면 숫자로 변환
    double priceValue;
    if (price is String) {
      priceValue = double.tryParse(price) ?? 0;
    } else if (price is num) {
      priceValue = price.toDouble();
    } else {
      return '0원';
    }

    // 정수로 변환 (소수점 제거)
    int priceInt = priceValue.round();

    // 천 단위 콤마 추가
    String priceStr = priceInt.toString();
    String formatted = priceStr.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );

    return '$formatted원';
  }

  /// 가격을 숫자만 포맷팅 (원 제외)
  static String formatPriceNumber(dynamic price) {
    if (price == null) return '0';

    double priceValue;
    if (price is String) {
      priceValue = double.tryParse(price) ?? 0;
    } else if (price is num) {
      priceValue = price.toDouble();
    } else {
      return '0';
    }

    int priceInt = priceValue.round();
    String priceStr = priceInt.toString();

    return priceStr.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}
