# 10. Flutter 앱 폴더 구조 및 기본 화면 코드

## 개요

이 문서는 DOA Market의 사용자 모바일 앱(Flutter)의 구현을 설명합니다.

## 기술 스택

```yaml
프레임워크:
  - Flutter: 3.x
  - Dart: 3.2+

아키텍처:
  - Clean Architecture
  - Feature-First Structure

상태 관리:
  - Riverpod: 2.4+ (Provider 패턴)

네트워킹:
  - Dio: 5.4+ (HTTP 클라이언트)
  - Retrofit: 4.0+ (REST API)

로컬 저장소:
  - Shared Preferences: 2.2+ (설정 저장)
  - Flutter Secure Storage: 9.0+ (토큰 저장)

네비게이션:
  - GoRouter: 13.0+ (선언형 라우팅)

코드 생성:
  - Freezed: 2.4+ (불변 클래스)
  - Json Serializable: 6.7+ (JSON 직렬화)
  - Build Runner: 2.4+

UI:
  - Cached Network Image: 3.3+ (이미지 캐싱)
  - Shimmer: 3.0+ (로딩 애니메이션)
  - Flutter SVG: 2.0+ (SVG 렌더링)

유틸리티:
  - Intl: 0.18+ (국제화)
  - Equatable: 2.0+ (값 비교)
  - Dartz: 0.10+ (함수형 프로그래밍)
  - Logger: 2.0+ (로깅)

Firebase:
  - Firebase Core: 2.24+
  - Firebase Messaging: 14.7+ (푸시 알림)
  - Firebase Analytics: 10.8+ (분석)
```

## 프로젝트 구조

```
frontend/user-app/lib/
├── main.dart                   # 앱 엔트리 포인트
├── core/                       # 핵심 기능
│   ├── config/
│   │   └── app_config.dart     # 앱 설정
│   ├── theme/
│   │   └── app_theme.dart      # 테마 정의
│   ├── router/
│   │   └── app_router.dart     # GoRouter 설정
│   ├── network/
│   │   ├── dio_client.dart     # Dio 클라이언트
│   │   └── api_response.dart   # API 응답 모델
│   ├── error/
│   │   └── failures.dart       # 에러 클래스
│   └── utils/
│       └── logger.dart         # 로거
├── features/                   # 기능별 모듈
│   ├── auth/                   # 인증
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── pages/
│   │       ├── widgets/
│   │       └── providers/
│   ├── home/                   # 홈
│   ├── products/               # 상품
│   ├── cart/                   # 장바구니
│   ├── orders/                 # 주문
│   └── profile/                # 프로필
└── shared/                     # 공통 컴포넌트
    ├── widgets/
    └── constants/
```

## Clean Architecture 계층

### 1. Domain Layer (도메인 계층)

비즈니스 로직과 엔티티를 정의합니다.

**Entity (features/auth/domain/entities/user.dart)**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String email,
    required String name,
    String? phone,
    String? profileImage,
    required String role,
    required DateTime createdAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
```

**핵심 기능:**
- Freezed로 불변 클래스 생성
- JSON 직렬화/역직렬화 자동 생성
- 타입 안전성

**Repository Interface (features/auth/domain/repositories/auth_repository.dart)**

```dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, LoginResult>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, LoginResult>> register({
    required String email,
    required String password,
    required String name,
    String? phone,
  });

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, User>> getCurrentUser();
}
```

**핵심 기능:**
- Either 타입으로 성공/실패 처리
- 추상 인터페이스로 의존성 역전

**Use Case (features/auth/domain/usecases/login_usecase.dart)**

```dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Either<Failure, LoginResult>> call({
    required String email,
    required String password,
  }) async {
    return await repository.login(email: email, password: password);
  }
}
```

### 2. Data Layer (데이터 계층)

API 통신과 로컬 저장소를 관리합니다.

**Remote Data Source (features/auth/data/datasources/auth_remote_datasource.dart)**

```dart
import 'package:dio/dio.dart';
import '../../domain/entities/user.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResult> login({required String email, required String password});
  Future<LoginResult> register({...});
  Future<void> logout();
  Future<User> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<LoginResult> login({
    required String email,
    required String password,
  }) async {
    final response = await dio.post(
      '/api/v1/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      final data = response.data['data'];
      return LoginResult(
        user: User.fromJson(data['user']),
        accessToken: data['accessToken'],
        refreshToken: data['refreshToken'],
      );
    } else {
      throw Exception('Login failed');
    }
  }
}
```

**Repository Implementation (features/auth/data/repositories/auth_repository_impl.dart)**

```dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, LoginResult>> login({
    required String email,
    required String password,
  }) async {
    try {
      final result = await remoteDataSource.login(
        email: email,
        password: password,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
```

**핵심 기능:**
- 에러를 Failure로 변환
- Either 타입으로 반환

### 3. Presentation Layer (프레젠테이션 계층)

UI와 상태 관리를 담당합니다.

**Provider (features/auth/presentation/providers/auth_provider.dart)**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../../../core/config/app_config.dart';

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    loginUseCase: ref.read(loginUseCaseProvider),
  );
});

class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUseCase loginUseCase;

  AuthNotifier({required this.loginUseCase}) : super(const AuthState.initial());

  Future<Either<Failure, void>> login({
    required String email,
    required String password,
  }) async {
    state = const AuthState.loading();

    final result = await loginUseCase(email: email, password: password);

    return result.fold(
      (failure) {
        state = AuthState.error(failure.message);
        return Left(failure);
      },
      (loginResult) {
        AppConfig.setTokens(
          loginResult.accessToken,
          loginResult.refreshToken,
        );
        state = AuthState.authenticated(loginResult.user);
        return const Right(null);
      },
    );
  }

  Future<void> logout() async {
    await AppConfig.clearTokens();
    state = const AuthState.unauthenticated();
  }
}

@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated(User user) = _Authenticated;
  const factory AuthState.unauthenticated() = _Unauthenticated;
  const factory AuthState.error(String message) = _Error;
}
```

**Page (features/auth/presentation/pages/login_page.dart)**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final result = await ref.read(authNotifierProvider.notifier).login(
            email: _emailController.text,
            password: _passwordController.text,
          );

      if (mounted) {
        result.fold(
          (failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(failure.message)),
            );
          },
          (_) => context.go('/'),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Logo
                Text(
                  'DOA Market',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),

                const SizedBox(height: 48),

                // Email Field
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: '이메일',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '이메일을 입력해주세요';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: '비밀번호',
                    prefixIcon: Icon(Icons.lock_outlined),
                  ),
                ),

                const SizedBox(height: 24),

                // Login Button
                ElevatedButton(
                  onPressed: authState.isLoading ? null : _handleLogin,
                  child: authState.isLoading
                      ? const CircularProgressIndicator()
                      : const Text('로그인'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

**핵심 기능:**
- Riverpod로 상태 관리
- Form validation
- 로딩 상태 처리
- 에러 핸들링

## 핵심 기능 구현

### 1. Dio 클라이언트 (core/network/dio_client.dart)

```dart
import 'package:dio/dio.dart';
import '../config/app_config.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  // Request Interceptor - JWT 추가
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = AppConfig.accessToken;
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        // 401 에러 시 토큰 갱신
        if (error.response?.statusCode == 401) {
          try {
            final refreshToken = AppConfig.refreshToken;
            final response = await dio.post(
              '/api/v1/auth/refresh',
              data: {'refreshToken': refreshToken},
            );

            final newAccessToken = response.data['data']['accessToken'];
            await AppConfig.setTokens(newAccessToken, refreshToken!);

            // 재시도
            error.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
            return handler.resolve(await dio.fetch(error.requestOptions));
          } catch (e) {
            await AppConfig.clearTokens();
          }
        }
        return handler.next(error);
      },
    ),
  );

  return dio;
});
```

**핵심 기능:**
- 자동 JWT 추가
- 401 에러 시 토큰 자동 갱신
- 인터셉터 체인

### 2. GoRouter 설정 (core/router/app_router.dart)

```dart
import 'package:go_router/go_router.dart';
import '../config/app_config.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggedIn = AppConfig.accessToken != null;
      final isLoginRoute = state.matchedLocation == '/login';

      if (!isLoggedIn && !isLoginRoute) {
        return '/login';
      }

      if (isLoggedIn && isLoginRoute) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/products/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ProductDetailPage(productId: id);
        },
      ),
    ],
  );
});
```

**핵심 기능:**
- 인증 기반 리다이렉트
- 타입 안전 경로 파라미터
- 선언형 라우팅

### 3. 테마 설정 (core/theme/app_theme.dart)

```dart
import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF2563EB);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
      centerTitle: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
  );
}
```

## 주요 화면

### 1. 홈 화면 (features/home/presentation/pages/home_page.dart)

```dart
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeTabPage(),
    const CategoryTabPage(),
    const FavoritesTabPage(),
    const ProfileTabPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.category), label: '카테고리'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: '찜'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '마이'),
        ],
      ),
    );
  }
}
```

**핵심 기능:**
- Bottom Navigation
- 탭별 화면 전환
- 상태 유지

### 2. 상품 상세 (features/products/presentation/pages/product_detail_page.dart)

```dart
class ProductDetailPage extends ConsumerWidget {
  final String productId;

  const ProductDetailPage({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final product = ref.watch(productDetailProvider(productId));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: CachedNetworkImage(
                imageUrl: product.thumbnail ?? '',
                fit: BoxFit.cover,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: Theme.of(context).textTheme.titleLarge),
                  Text('₩${product.price}', style: const TextStyle(fontSize: 24)),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _BottomButtons(),
    );
  }
}
```

### 3. 장바구니 (features/cart/presentation/pages/cart_page.dart)

```dart
class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('장바구니')),
      body: ListView.builder(
        itemCount: cartItems.length,
        itemBuilder: (context, index) {
          return CartItemWidget(item: cartItems[index]);
        },
      ),
      bottomNavigationBar: CheckoutButton(totalAmount: cartItems.totalAmount),
    );
  }
}
```

## 코드 생성

### Freezed 클래스 생성

```bash
# freezed 파일 생성
flutter pub run build_runner build --delete-conflicting-outputs

# watch 모드 (자동 재생성)
flutter pub run build_runner watch
```

### 생성되는 파일

```
user.dart         # 원본 파일
user.freezed.dart # Freezed 생성 파일
user.g.dart       # JSON 직렬화 파일
```

## 환경 설정

```bash
# .env
API_BASE_URL=https://api.doamarket.com
CDN_BASE_URL=https://cdn.doamarket.com
ENABLE_LOGGING=true
```

**사용법:**

```dart
flutter run --dart-define=API_BASE_URL=https://api.doamarket.com
```

## 빌드 및 실행

```bash
# 개발 모드
flutter run

# 프로덕션 빌드 (Android)
flutter build apk --release

# 프로덕션 빌드 (iOS)
flutter build ios --release

# 코드 생성
flutter pub run build_runner build

# 테스트
flutter test
```

## 디렉토리별 역할

```
lib/
├── main.dart                 # 앱 엔트리 포인트
├── core/                     # 공통 핵심 기능
│   ├── config/               # 앱 설정, 환경 변수
│   ├── theme/                # 테마, 스타일
│   ├── router/               # 라우팅 설정
│   ├── network/              # HTTP 클라이언트
│   ├── error/                # 에러 처리
│   └── utils/                # 유틸리티
├── features/                 # 기능별 모듈
│   └── [feature]/
│       ├── data/             # 데이터 계층
│       │   ├── datasources/  # API, 로컬 DB
│       │   ├── models/       # DTO
│       │   └── repositories/ # Repository 구현
│       ├── domain/           # 도메인 계층
│       │   ├── entities/     # 비즈니스 엔티티
│       │   ├── repositories/ # Repository 인터페이스
│       │   └── usecases/     # 유스케이스
│       └── presentation/     # 프레젠테이션 계층
│           ├── pages/        # 화면
│           ├── widgets/      # 위젯
│           └── providers/    # 상태 관리
└── shared/                   # 공통 컴포넌트
    ├── widgets/              # 재사용 위젯
    └── constants/            # 상수
```

## 핵심 설계 원칙

1. **Clean Architecture**
   - 계층 분리 (Domain, Data, Presentation)
   - 의존성 역전 원칙

2. **Feature-First**
   - 기능별로 폴더 구성
   - 모듈화 및 재사용성

3. **불변성**
   - Freezed로 불변 클래스
   - 상태 변경 추적 용이

4. **타입 안전성**
   - Dart 3.x null safety
   - 컴파일 타임 에러 검출

5. **함수형 프로그래밍**
   - Dartz Either 타입
   - 에러 처리 명시적

6. **코드 생성**
   - Freezed, Json Serializable
   - 보일러플레이트 감소

## 다음 단계

다음 문서에서는:
- 이벤트 기반 주문 처리 흐름 구현 예시
- 보안 설계 (IAM, WAF, VPC, Secret Manager)

를 다룹니다.
