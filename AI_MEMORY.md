# 🤖 AI_MEMORY — Amex5 · Contexte Complet du Projet

> **Ce fichier est la mémoire persistante du projet.**
> À lire en intégralité en début de chaque session de travail pour retrouver le contexte exact.
> Maintenir à jour après chaque changement architectural important.

---

## 1. Vue d'ensemble

| Champ | Valeur |
|---|---|
| **Nom du projet** | `amex5` |
| **Type** | Application Desktop Windows (Flutter) |
| **Version** | `1.0.0+1` |
| **SDK Dart** | `^3.11.1` |
| **Dernière mise à jour** | Mars 2026 |
| **Objectif** | Suite de contrôle industrielle pour envoyer des fichiers JSON vers une API REST |

---

## 2. Dépendances installées

```yaml
dependencies:
  flutter_bloc: ^9.1.1       # Gestion d'état (BLoC pattern)
  dio: ^5.9.2                # Client HTTP
  file_picker: ^10.3.10      # Sélection de fichiers natifs Windows
  shared_preferences: ^2.5.4 # Persistance locale (baseUrl)
  cupertino_icons: ^1.0.8

dev_dependencies:
  flutter_lints: ^6.0.0
  flutter_test
```

---

## 3. Architecture — Clean Architecture

```
lib/
├── main.dart                          ← Point d'entrée, init AppConfig
├── app/
│   └── app_shell.dart                 ← Shell Desktop : sidebar + contenu
│
├── core/
│   ├── base/
│   │   ├── base_repository.dart       ← mixin SafeCallMixin (try/catch → Result)
│   │   └── base_usecase.dart          ← abstract UseCase<Type,Params>, NoParams
│   ├── config/
│   │   └── app_config.dart            ← Singleton ChangeNotifier, gestion baseUrl runtime
│   ├── constants/
│   │   └── api_constants.dart         ← baseUrl, timeouts, noms des headers
│   ├── di/
│   │   └── injection.dart             ← Ancien singleton DI (remplacé par AppConfig)
│   ├── error/
│   │   ├── exceptions.dart            ← AppException sealed (NetworkException, Timeout, 4xx, 5xx…)
│   │   └── failures.dart              ← Failure sealed (domain) + Failure.fromException()
│   ├── network/
│   │   ├── dio_client.dart            ← DioClient central (get/post/put/patch/delete)
│   │   └── interceptors/
│   │       ├── auth_interceptor.dart  ← Inject Bearer token + retry 401
│   │       ├── error_interceptor.dart ← Map DioException → AppException
│   │       └── logging_interceptor.dart ← Logs structurés (developer.log)
│   ├── theme/
│   │   └── app_theme.dart             ← Palette industrielle sombre (AppColors, AppTextStyles, AppTheme)
│   └── utils/
│       ├── either.dart                ← Either<L,R> natif Dart (sealed class)
│       └── result.dart                ← typedef Result<T> = Either<Failure, T>
│
└── features/
    ├── discharge_works/               ← ✅ Feature principale
    │   ├── domain/
    │   │   ├── entities/discharge_entities.dart     ← DischargeFile, DischargeUploadResult
    │   │   ├── repositories/discharge_works_repository.dart  ← interface abstraite
    │   │   └── usecases/upload_discharge_works_usecase.dart
    │   ├── data/
    │   │   ├── datasources/discharge_works_remote_datasource.dart  ← POST /test_upload
    │   │   └── repositories/discharge_works_repository_impl.dart
    │   └── presentation/
    │       ├── bloc/discharge_works_bloc.dart        ← Events, States, BLoC
    │       ├── pages/discharge_works_page.dart       ← UI principale split-view
    │       └── widgets/discharge_widgets.dart        ← StatusBadge, IndustrialCard, PrimaryActionButton
    │
    ├── settings/                      ← ✅ Paramètres
    │   └── presentation/pages/settings_page.dart    ← Formulaire baseUrl
    │
    └── example/                       ← 🗄️ Exemple de référence (posts JSONPlaceholder)
        ├── domain/ …
        ├── data/ …
        └── presentation/bloc/post_bloc.dart
```

---

## 4. Patterns et conventions

### 4.1 Either / Result

```dart
// Pas de dartz — implémentation native
typedef Result<T> = Either<Failure, T>;
Result<T> success<T>(T value) => Right(value);
Result<T> failure<T>(Failure f)  => Left(f);

// Usage dans un repository
Future<Result<MyEntity>> fetchData() =>
    safeCall(() => _remote.fetchData());

// Usage dans un BLoC
final result = await useCase(params);
result.fold(
  (failure) => emit(ErrorState(failure)),
  (data)    => emit(SuccessState(data)),
);
```

### 4.2 Créer une nouvelle feature

1. **Créer l'arborescence** : `domain/entities`, `domain/repositories`, `domain/usecases`, `data/datasources`, `data/repositories`, `presentation/bloc`, `presentation/pages`, `presentation/widgets`
2. **Entité** → classe pure Dart dans `domain/entities/`
3. **Repository interface** → `abstract interface class` dans `domain/repositories/`
4. **UseCase** → `extends UseCase<ReturnType, ParamsType>` dans `domain/usecases/`
5. **DataSource** → utilise `DioClient` injecté via `AppConfig.instance.dioClient`
6. **Repository impl** → `with SafeCallMixin implements MonRepository`
7. **BLoC** → `sealed class` Events + States, `extends Bloc<Event, State>`
8. **Ajouter la page au `AppShell`** → `_navItems` + `_pages` dans `app_shell.dart`

### 4.3 Intercepteurs Dio

| Ordre | Intercepteur | Rôle |
|---|---|---|
| 1 | `LoggingInterceptor` | Log requête/réponse/erreur dans la console |
| 2 | `AuthInterceptor` | Inject `Authorization: Bearer <token>` + retry 401 |
| 3 | `ErrorInterceptor` | Map `DioException` → `AppException` |

### 4.4 Gestion du baseUrl à chaud

```dart
// Modifier le baseUrl en runtime (persiste dans SharedPreferences)
await AppConfig.instance.setBaseUrl('https://new-api.example.com');

// Lire le baseUrl courant
final url = AppConfig.instance.baseUrl;

// Récupérer le DioClient (toujours à jour)
final client = AppConfig.instance.dioClient;
```

### 4.5 BLoC DischargeWorks

```
Events:
  PickFileEvent    → ouvre FilePicker (JSON only), lit + parse le fichier
  UploadFileEvent  → POST /test_upload avec le contenu JSON du fichier
  ResetEvent       → retour à DischargeWorksInitial

States:
  DischargeWorksInitial
  DischargeWorksPickingFile
  DischargeWorksFileSelected(file: DischargeFile)
  DischargeWorksUploading(file: DischargeFile)
  DischargeWorksSuccess(file, result: DischargeUploadResult)
  DischargeWorksError(failure, file?)
```

---

## 5. Thème industriel — AppColors

```dart
// Fond
AppColors.background     = #0F1117  // fond principal
AppColors.surface        = #1A1D27  // sidebar, AppBar
AppColors.surfaceVariant = #23273A  // card headers
AppColors.card           = #1E2235  // cards

// Primaires
AppColors.primary        = #2D7DD2  // bleu acier
AppColors.accent         = #E8A020  // ambre industriel

// États
AppColors.success        = #2ECC71
AppColors.error          = #E74C3C
AppColors.warning        = #F39C12
AppColors.info           = #3498DB

// Texte
AppColors.textPrimary    = #E8ECF4
AppColors.textSecondary  = #8B93B0
AppColors.textDisabled   = #4A5070
```

---

## 6. Navigation — AppShell

- **Sidebar** fixe de 220px — `app/app_shell.dart`
- **Indicateur baseUrl** en bas de la sidebar → réactif via `ListenableBuilder(AppConfig.instance)`
- **Pages** actives :

| Index | Label | Widget |
|---|---|---|
| 0 | Discharge Works | `DischargeWorksPage()` |
| 1 | Paramètres | `SettingsPage()` |

Pour **ajouter une page** :
```dart
// Dans app_shell.dart
static const List<_NavItem> _navItems = [
  // … items existants …
  _NavItem(icon: Icons.new_icon, activeIcon: Icons.new_icon, label: 'Nouveau'),
];
static const List<Widget> _pages = [
  // … pages existantes …
  NouveauPage(),
];
```

---

## 7. Endpoint API actuel

| Feature | Méthode | Endpoint | Payload |
|---|---|---|---|
| DischargeWorks | `POST` | `/test_upload` | Contenu JSON du fichier sélectionné |

> ⚠️ L'endpoint `/test_upload` est provisoire. Mettre à jour dans :
> `lib/features/discharge_works/data/datasources/discharge_works_remote_datasource.dart`
> ```dart
> static const String _endpoint = '/test_upload'; // ← changer ici
> ```

---

## 8. Points TODO / Next Steps

- [ ] **Authentification** : brancher `getAccessToken` / `getRefreshToken` / `onRefresh` dans `main.dart` (commentaires présents)
- [ ] **flutter_secure_storage** : stocker les tokens de façon sécurisée (à ajouter en dépendance)
- [ ] **Endpoint réel** : remplacer `/test_upload` par le vrai endpoint du serveur
- [ ] **Validation du JSON** : ajouter un schéma de validation avant upload (ex: `json_schema`)
- [ ] **Historique des uploads** : nouvelle feature `upload_history` (stockage local des résultats)
- [ ] **Gestion multi-fichiers** : permettre la sélection de plusieurs JSON
- [ ] **Progress upload** : brancher `onSendProgress` de Dio pour une barre de progression réelle
- [ ] **Tests** : unit tests pour les UseCases et BLoCs
- [ ] **Supprimer la feature `example`** quand elle n'est plus utile (elle sert de référence actuellement)

---

## 9. Commandes utiles

```powershell
# Lancer l'app Windows
flutter run -d windows

# Analyser le code
flutter analyze --no-fatal-infos

# Ajouter une dépendance
flutter pub add <package>

# Build release Windows
flutter build windows --release
```

---

## 10. Notes importantes

- **`withOpacity()` est déprécié** → utiliser `.withValues(alpha: x)` (Dart 3.x)
- **`AppConfig`** remplace `Injection` comme point d'entrée des dépendances réseau
- **`Injection`** (`core/di/injection.dart`) existe encore mais n'est plus utilisé — peut être supprimé
- **`Either<L,R>`** est implémenté nativement (pas de `dartz`) — fichier `core/utils/either.dart`
- **Sealed classes** utilisées partout pour les Events/States/Failures/Exceptions → exhaustivité garantie par le compilateur
- Le projet cible **Windows Desktop uniquement** pour l'instant — pas de mobile/web

---

## 11. Structure des fichiers à connaître impérativement

| Fichier | Rôle |
|---|---|
| `lib/main.dart` | Init `AppConfig` + `runApp(MyApp → AppShell)` |
| `lib/app/app_shell.dart` | Shell principal, sidebar, routing |
| `lib/core/config/app_config.dart` | **Singleton central** : baseUrl, DioClient |
| `lib/core/network/dio_client.dart` | Wrapper Dio avec helpers HTTP |
| `lib/core/error/exceptions.dart` | `AppException` sealed — couche data |
| `lib/core/error/failures.dart` | `Failure` sealed — couche domain |
| `lib/core/utils/either.dart` | `Either<L,R>` natif |
| `lib/core/utils/result.dart` | `typedef Result<T>` |
| `lib/core/base/base_repository.dart` | `mixin SafeCallMixin` |
| `lib/core/base/base_usecase.dart` | `abstract UseCase<Type, Params>` |
| `lib/core/theme/app_theme.dart` | `AppColors`, `AppTextStyles`, `AppTheme.dark` |
| `lib/features/discharge_works/presentation/bloc/discharge_works_bloc.dart` | BLoC principal |
| `lib/features/discharge_works/data/datasources/discharge_works_remote_datasource.dart` | Endpoint POST |
| `lib/features/settings/presentation/pages/settings_page.dart` | Config baseUrl UI |
