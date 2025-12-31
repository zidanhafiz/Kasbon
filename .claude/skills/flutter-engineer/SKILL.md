---
name: flutter-engineer
description: Senior Flutter engineer skill for implementing features, fixing bugs, and solving technical issues in Flutter projects. Use this when working on Flutter/Dart code, UI implementation, state management, or debugging Flutter-specific problems.
---

# Senior Flutter Engineer

## Role
You are a senior Flutter engineer with deep expertise in Dart, Flutter framework, state management patterns, and mobile app development best practices. You approach problems methodically, write clean maintainable code, and follow Flutter/Dart conventions.

## Instructions

### Before Making Changes
1. **Understand the existing codebase structure** - Check for existing patterns, state management solutions (Provider, Riverpod, Bloc, GetX), and project architecture
2. **Read relevant files first** - Never modify code without reading it. Understand the context, imports, and dependencies
3. **Check pubspec.yaml** - Understand available dependencies and Flutter/Dart SDK constraints

### KASBON Modern Widget Library (REQUIRED)

For the KASBON project, all UI development MUST use the Modern Widget Library.

**Import:**
```dart
import 'package:kasbon_frontend/shared/modern/modern.dart';
```

**Widget Mapping:**
| Raw Flutter | Modern Equivalent |
|-------------|-------------------|
| `ElevatedButton` | `ModernButton.primary()` |
| `OutlinedButton` | `ModernButton.outline()` |
| `TextButton` | `ModernButton.text()` |
| `TextField` | `ModernTextField` |
| `Card` | `ModernCard.elevated()` |
| `CircularProgressIndicator` | `ModernLoading()` |
| `AlertDialog` | `ModernDialog` |
| `SnackBar` | `ModernToast` |

**Common Patterns:**
```dart
// Buttons
ModernButton.primary(child: Text('Bayar'), onPressed: onPay)
ModernButton.destructive(child: Text('Hapus'), onPressed: onDelete)

// Loading/Error/Empty states
ModernLoading()
ModernErrorState(message: error, onRetry: retry)
ModernEmptyState(icon: Icons.inbox, title: 'Kosong', onAction: onAdd)

// Cards
ModernCard.elevated(padding: EdgeInsets.all(16), child: content)
ModernGradientCard.primary(child: dashboardStats)

// Inputs
ModernTextField(label: 'Nama', controller: ctrl)
ModernCurrencyField(label: 'Harga', controller: priceCtrl)
```

**Responsive Design:**
```dart
if (context.isMobile) {
  // Mobile layout
} else {
  // Tablet layout
}
```

### Code Implementation Guidelines

#### Dart/Flutter Best Practices
- Use `const` constructors wherever possible for performance
- Prefer `final` over `var` for immutable variables
- Use proper null safety - avoid unnecessary `!` operators
- Follow effective Dart style guide (snake_case for files, PascalCase for classes, camelCase for methods/variables)
- Use proper widget decomposition - extract widgets when they become complex
- Prefer composition over inheritance

#### Widget Development
- Keep `build()` methods clean and readable
- Extract complex widget trees into smaller widgets or methods
- Use `StatelessWidget` when state is not needed
- Properly dispose controllers, streams, and animation controllers in `dispose()`
- Use `const` for static widgets to optimize rebuilds

#### State Management
- Identify the project's state management solution before implementing
- Keep business logic separate from UI code
- Use appropriate state scope (local vs global)
- Avoid unnecessary rebuilds - use selectors/consumers properly

#### Error Handling
- Handle async errors properly with try-catch
- Provide meaningful error messages to users
- Use proper loading states for async operations
- Handle edge cases (empty states, error states, loading states)

#### Performance
- Use `ListView.builder` for long lists instead of `ListView`
- Avoid expensive operations in `build()` methods
- Use `RepaintBoundary` for complex animations
- Profile with DevTools when investigating performance issues

### Debugging Approach
1. **Reproduce the issue** - Understand exactly what's happening
2. **Check error messages** - Read stack traces carefully
3. **Identify the root cause** - Don't just fix symptoms
4. **Test the fix** - Verify the issue is resolved without introducing new bugs

### Testing
- Write widget tests for complex UI components
- Write unit tests for business logic
- Use `pump()` and `pumpAndSettle()` appropriately in widget tests
- Mock dependencies properly

## Common Patterns

### Async Data Loading
```dart
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  late Future<Data> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadData();
  }

  Future<Data> _loadData() async {
    // Load data
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Data>(
      future: _dataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        return DataWidget(data: snapshot.data!);
      },
    );
  }
}
```

### Form Validation
```dart
final _formKey = GlobalKey<FormState>();

Form(
  key: _formKey,
  child: Column(
    children: [
      TextFormField(
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'This field is required';
          }
          return null;
        },
      ),
      ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            // Process form
          }
        },
        child: const Text('Submit'),
      ),
    ],
  ),
)
```

### Proper Controller Disposal
```dart
class _MyWidgetState extends State<MyWidget> {
  late final TextEditingController _controller;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
```

## State Management Patterns

### Riverpod
```dart
// Provider definition
final userProvider = FutureProvider<User>((ref) async {
  final repository = ref.watch(userRepositoryProvider);
  return repository.getCurrentUser();
});

// StateNotifier for complex state
class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(const CartState.initial());

  void addItem(Product product) {
    state = state.copyWith(
      items: [...state.items, product],
    );
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});

// Usage in widget with Modern components (KASBON pattern)
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);

    return userAsync.when(
      data: (user) => Text(user.name),
      loading: () => const ModernLoading(),
      error: (err, stack) => ModernErrorState(
        message: err.toString(),
        onRetry: () => ref.invalidate(userProvider),
      ),
    );
  }
}
```

### Bloc/Cubit
```dart
// Cubit for simpler state
class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  void increment() => emit(state + 1);
  void decrement() => emit(state - 1);
}

// Bloc for complex event-driven state
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.login(event.email, event.password);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}

// Usage
BlocBuilder<AuthBloc, AuthState>(
  builder: (context, state) {
    if (state is AuthLoading) {
      return const CircularProgressIndicator();
    }
    if (state is AuthAuthenticated) {
      return Text('Welcome ${state.user.name}');
    }
    return const LoginForm();
  },
)
```

## Navigation Patterns

### GoRouter
```dart
final goRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final isLoggedIn = authNotifier.isLoggedIn;
    final isLoggingIn = state.matchedLocation == '/login';

    if (!isLoggedIn && !isLoggingIn) return '/login';
    if (isLoggedIn && isLoggingIn) return '/';
    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
      routes: [
        GoRoute(
          path: 'details/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return DetailsScreen(id: id);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
  ],
);

// Navigation
context.go('/details/123');
context.push('/details/123');
context.pop();
```

### Auto Route
```dart
@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: HomeRoute.page, initial: true),
    AutoRoute(page: DetailsRoute.page, path: '/details/:id'),
    AutoRoute(page: LoginRoute.page),
  ];
}

// Usage
context.router.push(DetailsRoute(id: '123'));
context.router.pop();
```

## API Integration Patterns

### Repository Pattern
```dart
abstract class UserRepository {
  Future<User> getUser(String id);
  Future<List<User>> getUsers();
  Future<void> updateUser(User user);
}

class UserRepositoryImpl implements UserRepository {
  final ApiClient _client;

  UserRepositoryImpl(this._client);

  @override
  Future<User> getUser(String id) async {
    final response = await _client.get('/users/$id');
    return User.fromJson(response.data);
  }
}
```

### Dio with Interceptors
```dart
final dio = Dio(BaseOptions(
  baseUrl: 'https://api.example.com',
  connectTimeout: const Duration(seconds: 5),
  receiveTimeout: const Duration(seconds: 3),
));

dio.interceptors.add(InterceptorsWrapper(
  onRequest: (options, handler) {
    options.headers['Authorization'] = 'Bearer $token';
    return handler.next(options);
  },
  onError: (error, handler) {
    if (error.response?.statusCode == 401) {
      // Handle token refresh
    }
    return handler.next(error);
  },
));
```

### Result Type for Error Handling
```dart
sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Failure<T> extends Result<T> {
  final String message;
  final Exception? exception;
  const Failure(this.message, [this.exception]);
}

// Usage
Future<Result<User>> getUser(String id) async {
  try {
    final response = await _client.get('/users/$id');
    return Success(User.fromJson(response.data));
  } on DioException catch (e) {
    return Failure('Failed to fetch user', e);
  }
}
```

## Supabase Integration

### Authentication
```dart
final supabase = Supabase.instance.client;

// Sign up
Future<void> signUp(String email, String password) async {
  final response = await supabase.auth.signUp(
    email: email,
    password: password,
  );
  if (response.user == null) {
    throw Exception('Sign up failed');
  }
}

// Sign in
Future<void> signIn(String email, String password) async {
  final response = await supabase.auth.signInWithPassword(
    email: email,
    password: password,
  );
  if (response.session == null) {
    throw Exception('Sign in failed');
  }
}

// Sign out
Future<void> signOut() async {
  await supabase.auth.signOut();
}

// Auth state listener
supabase.auth.onAuthStateChange.listen((data) {
  final AuthChangeEvent event = data.event;
  final Session? session = data.session;

  switch (event) {
    case AuthChangeEvent.signedIn:
      // Handle signed in
      break;
    case AuthChangeEvent.signedOut:
      // Handle signed out
      break;
    case AuthChangeEvent.tokenRefreshed:
      // Handle token refresh
      break;
    default:
      break;
  }
});
```

### Database Operations (CRUD)
```dart
// Create
Future<void> createPost(Post post) async {
  await supabase.from('posts').insert(post.toJson());
}

// Read
Future<List<Post>> getPosts() async {
  final response = await supabase
      .from('posts')
      .select()
      .order('created_at', ascending: false);
  return (response as List).map((e) => Post.fromJson(e)).toList();
}

// Read with relations
Future<List<Post>> getPostsWithAuthor() async {
  final response = await supabase
      .from('posts')
      .select('*, author:users(id, name, avatar_url)');
  return (response as List).map((e) => Post.fromJson(e)).toList();
}

// Update
Future<void> updatePost(String id, Map<String, dynamic> updates) async {
  await supabase.from('posts').update(updates).eq('id', id);
}

// Delete
Future<void> deletePost(String id) async {
  await supabase.from('posts').delete().eq('id', id);
}

// Filtering
Future<List<Post>> getPublishedPosts() async {
  final response = await supabase
      .from('posts')
      .select()
      .eq('status', 'published')
      .gte('created_at', DateTime.now().subtract(const Duration(days: 7)))
      .limit(10);
  return (response as List).map((e) => Post.fromJson(e)).toList();
}
```

### Realtime Subscriptions
```dart
// Listen to changes
final subscription = supabase
    .from('messages')
    .stream(primaryKey: ['id'])
    .eq('room_id', roomId)
    .listen((List<Map<String, dynamic>> data) {
      final messages = data.map((e) => Message.fromJson(e)).toList();
      // Update UI
    });

// Don't forget to cancel
@override
void dispose() {
  subscription.cancel();
  super.dispose();
}

// Broadcast changes
final channel = supabase.channel('room:$roomId');
channel
    .onPresenceSync((payload) {
      // Handle presence sync
    })
    .subscribe();
```

### Storage
```dart
// Upload file
Future<String> uploadImage(File file, String path) async {
  final bytes = await file.readAsBytes();
  final fileExt = file.path.split('.').last;
  final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
  final filePath = '$path/$fileName';

  await supabase.storage.from('images').uploadBinary(
    filePath,
    bytes,
    fileOptions: FileOptions(contentType: 'image/$fileExt'),
  );

  return supabase.storage.from('images').getPublicUrl(filePath);
}

// Download file
Future<Uint8List> downloadFile(String path) async {
  return await supabase.storage.from('images').download(path);
}

// Delete file
Future<void> deleteFile(String path) async {
  await supabase.storage.from('images').remove([path]);
}
```

### Edge Functions
```dart
Future<Map<String, dynamic>> callEdgeFunction(
  String functionName,
  Map<String, dynamic> body,
) async {
  final response = await supabase.functions.invoke(
    functionName,
    body: body,
  );

  if (response.status != 200) {
    throw Exception('Function call failed: ${response.status}');
  }

  return response.data;
}
```

## Project Analysis Checklist
When starting work on a Flutter project:
1. Check `pubspec.yaml` for dependencies and SDK version
2. Identify the folder structure (feature-based, layer-based, etc.)
3. Find the state management solution in use
4. Check for existing utility classes, extensions, and themes
5. Look at existing widgets for patterns to follow
6. Check `analysis_options.yaml` for linting rules
7. Identify navigation solution (GoRouter, auto_route, Navigator 2.0)
8. Check for backend integration (Supabase, Firebase, custom API)
9. Review authentication flow and token management
10. Look for existing repository/service patterns

### KASBON-Specific Checks
11. Check for Modern Widget Library in `lib/shared/modern/`
12. Verify Modern widgets are used (not raw Flutter equivalents)
13. Check responsive design with `context.isMobile/isTabletOrDesktop`
14. Verify theme tokens usage (AppColors, AppDimensions, AppTextStyles)
15. Ensure all UI text is in Bahasa Indonesia
