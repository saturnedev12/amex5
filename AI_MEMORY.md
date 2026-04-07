# 🤖 AI_MEMORY — Amex5 · Contexte Complet du Projet

> **Ce fichier est la mémoire persistante du projet.**
> À lire en intégralité en début de chaque session de travail pour retrouver le contexte exact.
> Maintenir à jour après chaque changement architectural important.

---

## 1. Vue d'ensemble

| Champ                    | Valeur                                                                                                                               |
| ------------------------ | ------------------------------------------------------------------------------------------------------------------------------------ |
| **Nom du projet**        | `amex5`                                                                                                                              |
| **Type**                 | Application Desktop Windows (Flutter)                                                                                                |
| **Version**              | `1.0.0+1`                                                                                                                            |
| **SDK Dart**             | `^3.11.0`                                                                                                                            |
| **Dernière mise à jour** | Avril 2026                                                                                                                           |
| **Objectif**             | Suite de contrôle industrielle : authentification, gestion des travaux (WO), transfert BLE, envoi de fichiers JSON vers une API REST |

---

## 2. Dépendances installées

```yaml
dependencies:
  flutter_bloc: ^9.1.1              # Gestion d'état (BLoC pattern)
  dio: ^5.9.2                       # Client HTTP
  file_picker: ^10.3.10             # Sélection de fichiers natifs Windows
  shared_preferences: ^2.5.4        # Persistance locale (baseUrl, session)
  cupertino_icons: ^1.0.8
  get_it: ^9.2.1                    # Service Locator (DI)
  injectable: ^2.7.1+4              # Annotations DI avec code generation
  json_annotation: ^4.11.0          # Annotations JSON serialization
  isar_community: ^3.3.2            # Base de données locale NoSQL
  isar_community_flutter_libs: ^3.3.2  # Native binaries Isar
  flutter_blue_plus_windows: 1.26.1 # BLE (Bluetooth Low Energy) pour Windows
  go_router: ^17.1.0                # Routing déclaratif
  pretty_dio_logger: ^1.4.0         # Log Dio coloré (dev)

dev_dependencies:
  flutter_lints: ^6.0.0
  flutter_test
  build_runner: ^2.13.1             # Code generation
  json_serializable: ^6.13.1        # Génère .g.dart pour JSON
  injectable_generator: ^2.7.2      # Génère injection.config.dart
  isar_community_generator: ^3.3.2  # Génère schémas Isar
```

---

## 3. Architecture — Clean Architecture

```
lib/
├── main.dart                          ← Point d'entrée, init DI + SessionManager + wiring token expiry
├── app/
│   └── app_shell.dart                 ← Shell Desktop : sidebar + contenu (4 pages)
│
├── core/
│   ├── base/
│   │   ├── base_repository.dart       ← mixin SafeCallMixin (try/catch → Result)
│   │   └── base_usecase.dart          ← abstract UseCase<Type,Params>, NoParams
│   ├── config/
│   │   └── app_config.dart            ← Singleton ChangeNotifier, gestion baseUrl runtime
│   ├── constants/
│   │   └── api_constants.dart         ← baseUrl, timeouts, noms des headers
│   ├── database/
│   │   └── isar_config.dart           ← @singleton, init Isar NoSQL
│   ├── di/
│   │   ├── injection.dart             ← configureDependencies() + init SessionManager + Isar
│   │   └── injection.config.dart      ← [GÉNÉRÉ] par injectable_generator
│   ├── error/
│   │   ├── exceptions.dart            ← AppException sealed (NetworkException, Timeout, 4xx, 5xx…)
│   │   └── failures.dart              ← Failure sealed (domain) + Failure.fromException()
│   ├── network/
│   │   ├── dio_client.dart            ← DioClient central (get/post/put/patch/delete)
│   │   ├── dio_config.dart            ← @module DioConfig → fournit Dio avec intercepteurs
│   │   └── interceptors/
│   │       ├── auth_interceptor.dart  ← Inject token brut + X-device, détecte 401 EXPIRED_TOKEN
│   │       ├── error_interceptor.dart ← Map DioException → AppException
│   │       ├── logging_interceptor.dart ← PrettyDioLogger conditionnel
│   │       └── token_provider.dart    ← @singleton TokenProvider (legacy, token lu via SessionManager)
│   ├── router/
│   │   └── app_router.dart            ← GoRouter config (routes /login, /home, etc.)
│   ├── session/
│   │   └── session_manager.dart       ← @singleton — token, loginResponseJson, pendingRedirect
│   ├── theme/
│   │   └── app_theme.dart             ← Palette industrielle sombre (AppColors, AppTextStyles, AppTheme)
│   └── utils/
│       ├── either.dart                ← Either<L,R> natif Dart (sealed class)
│       └── result.dart                ← typedef Result<T> = Either<Failure, T>
│
└── features/
    ├── authentification/              ← ✅ Authentification + gestion session
    │   ├── data/
    │   │   ├── auth_repository.dart           ← @lazySingleton, POST /auth/login
    │   │   └── models/
    │   │       ├── auth_response_model.dart    ← @JsonSerializable (token, user, etc.)
    │   │       └── auth_response_model.g.dart  ← [GÉNÉRÉ]
    │   └── presentation/
    │       ├── login_cubit.dart                ← @injectable, sauvegarde session après login
    │       └── login_page.dart                 ← UI login + redirect vers pendingRedirect
    │
    ├── agent_works/                   ← ✅ Feature travaux des agents (WO + Checklists)
    │   ├── data/
    │   │   ├── datasources/
    │   │   │   └── agent_works_remote_datasource.dart  ← @lazySingleton, POST /wmwo/sync/all + GET /wmwo/checklist
    │   │   ├── models/
    │   │   │   ├── wo_model.dart              ← @JsonSerializable (woCode, act, desc, checkListItems…)
    │   │   │   ├── wo_model.g.dart            ← [GÉNÉRÉ]
    │   │   │   ├── task_model.dart            ← @JsonSerializable (code, desc, type, value, completed…)
    │   │   │   ├── task_model.g.dart          ← [GÉNÉRÉ]
    │   │   │   ├── sync_response_model.dart   ← @JsonSerializable wrapper /wmwo/sync/all
    │   │   │   ├── sync_response_model.g.dart ← [GÉNÉRÉ]
    │   │   │   ├── checklist_response_model.dart  ← @JsonSerializable wrapper /wmwo/checklist
    │   │   │   └── checklist_response_model.g.dart ← [GÉNÉRÉ]
    │   │   └── repositories/
    │   │       └── agent_works_repository_impl.dart  ← @LazySingleton(as: AgentWorksRepository)
    │   ├── domain/
    │   │   └── repositories/
    │   │       └── agent_works_repository.dart  ← abstract interface class
    │   └── presentation/
    │       ├── bloc/
    │       │   └── agent_works_bloc.dart       ← @injectable, Events/States, BLE payload builders
    │       └── pages/
    │           └── agent_works_page.dart       ← Split-view : liste WO ↔ checklist agrégée
    │
    ├── discharge_works/               ← ✅ Feature upload fichiers JSON
    │   ├── domain/
    │   │   ├── entities/discharge_entities.dart
    │   │   ├── repositories/discharge_works_repository.dart
    │   │   └── usecases/upload_discharge_works_usecase.dart
    │   ├── data/
    │   │   ├── datasources/discharge_works_remote_datasource.dart  ← POST /test_upload
    │   │   └── repositories/discharge_works_repository_impl.dart
    │   └── presentation/
    │       ├── bloc/discharge_works_bloc.dart
    │       ├── pages/discharge_works_page.dart
    │       └── widgets/discharge_widgets.dart
    │
    ├── ble_receiver/                  ← ✅ Réception BLE (appareil distant)
    │   └── presentation/
    │       ├── bloc/ble_receiver_bloc.dart     ← Scan, connect, chunked transfer protocol
    │       └── pages/ble_receiver_page.dart
    │
    ├── settings/                      ← ✅ Paramètres
    │   └── presentation/pages/settings_page.dart    ← Formulaire baseUrl
    │
    ├── splash_screen/                 ← Écran de démarrage
    │   └── presentation/pages/splash_screen_page.dart
    │
    └── example/                       ← 🗄️ Exemple de référence (posts JSONPlaceholder)
        ├── domain/ …
        ├── data/ …
        └── presentation/bloc/post_bloc.dart
```

---

## 4. Patterns et conventions

### 4.1 Injection de dépendances (get_it + injectable)

```dart
// Annotations à utiliser :
@singleton       // SessionManager, IsarConfig, TokenProvider
@lazySingleton   // Repositories, DataSources, Interceptors, Dio
@injectable      // BLoCs, Cubits (factory — nouvelle instance à chaque fois)
@module          // DioConfig — fournit des instances tierces (Dio)
@LazySingleton(as: MyAbstractRepo)  // Liaison interface → impl

// Enregistrement initial dans main.dart :
await configureDependencies();  // injection.dart → init()

// Accès aux dépendances :
final bloc = getIt<AgentWorksBloc>();
```

### 4.2 Either / Result

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

### 4.3 Sérialisation JSON (json_serializable)

```dart
// Modèle type :
@JsonSerializable()
class MyModel {
  final String id;
  final String name;
  MyModel({required this.id, required this.name});
  factory MyModel.fromJson(Map<String, dynamic> json) => _$MyModelFromJson(json);
  Map<String, dynamic> toJson() => _$MyModelToJson(this);
}

// Régénérer après modification :
dart run build_runner build --delete-conflicting-outputs
```

### 4.4 Créer une nouvelle feature

1. **Créer l'arborescence** : `domain/repositories`, `data/datasources`, `data/models`, `data/repositories`, `presentation/bloc`, `presentation/pages`
2. **Model** → `@JsonSerializable()` dans `data/models/`
3. **Repository interface** → `abstract interface class` dans `domain/repositories/`
4. **DataSource** → `@lazySingleton`, utilise `Dio` injecté
5. **Repository impl** → `with SafeCallMixin implements MonRepository`, `@LazySingleton(as: MonRepository)`
6. **BLoC** → `@injectable`, `sealed class` Events + States, `extends Bloc<Event, State>`
7. **Ajouter la page au `AppShell`** → `_navItems` + `_pages` dans `app_shell.dart`
8. **Exécuter build_runner** pour générer les `.g.dart`

### 4.5 Intercepteurs Dio

| Ordre | Intercepteur       | Rôle                                                                                      |
| ----- | ------------------ | ----------------------------------------------------------------------------------------- |
| 1     | `PrettyDioLogger`  | Log coloré requête/réponse (via LoggingInterceptor)                                       |
| 2     | `AuthInterceptor`  | Inject token brut `Authorization: <token>` + header `X-device`, détecte 401 EXPIRED_TOKEN |
| 3     | `ErrorInterceptor` | Map `DioException` → `AppException`                                                       |

> ⚠️ **Le token est envoyé SANS préfixe Bearer** — l'API attend le token brut dans le header `Authorization`.

### 4.6 Gestion de session — SessionManager

```dart
// Singleton @singleton, init() charge depuis SharedPreferences
final session = getIt<SessionManager>();

// Après login réussi :
await session.saveLoginData(token: token, loginResponseJson: response.toJson());

// Lecture du token pour les requêtes :
final token = session.token;  // utilisé par AuthInterceptor

// JSON de login complet (pour envoi BLE) :
final loginJson = session.loginResponseJson;

// Redirect après expiration token :
session.pendingRedirect = '/home';  // set par main.dart quand EXPIRED_TOKEN détecté
final redirect = session.pendingRedirect;  // lu par LoginPage après re-login

// Déconnexion :
session.clear();
```

### 4.7 Flux d'expiration du token (401 EXPIRED_TOKEN)

```
1. AuthInterceptor.onError détecte statusCode == 401 + body contient "EXPIRED_TOKEN"
2. → session.clear() (efface token + loginResponse)
3. → AuthInterceptor.onTokenExpired?.call() (callback statique)
4. main.dart wire le callback : pendingRedirect = context.currentRoute, appRouter.go('/login')
5. LoginPage : après AuthAuthenticated, lit session.pendingRedirect et navigue vers cette route
```

### 4.8 Gestion du baseUrl à chaud

```dart
await AppConfig.instance.setBaseUrl('https://new-api.example.com');
final url = AppConfig.instance.baseUrl;
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

| Index | Label           | Icône               | Widget                 |
| ----- | --------------- | ------------------- | ---------------------- |
| 0     | Discharge Works | `Icons.upload_file` | `DischargeWorksPage()` |
| 1     | Travaux Agents  | `Icons.engineering` | `AgentWorksPage()`     |
| 2     | BLE Receiver    | `Icons.bluetooth`   | `BleReceiverPage()`    |
| 3     | Paramètres      | `Icons.settings`    | `SettingsPage()`       |

- **Routing (GoRouter)** : `/login`, `/home`, `/settings`, etc. — configuré dans `core/router/app_router.dart`

Pour **ajouter une page** :

```dart
// Dans app_shell.dart — mettre à jour _navItems + _pages
```

---

## 7. Endpoints API

| Feature               | Méthode | Endpoint                         | Payload / Params                                              |
| --------------------- | ------- | -------------------------------- | ------------------------------------------------------------- |
| **Authentification**  | `POST`  | `/auth/login`                    | `{ username, password }` → `AuthResponseModel` (token, user…) |
| **Sync travaux**      | `POST`  | `/wmwo/sync/all`                 | `{}` (body vide) → `SyncResponseModel` (liste WO)             |
| **Checklist d'un WO** | `GET`   | `/wmwo/checklist/{woCode}/{act}` | Path params → `ChecklistResponseModel` (checkItems)           |
| **DischargeWorks**    | `POST`  | `/test_upload`                   | Contenu JSON du fichier sélectionné                           |

> ⚠️ L'endpoint `/test_upload` est provisoire. Mettre à jour dans :
> `lib/features/discharge_works/data/datasources/discharge_works_remote_datasource.dart`

---

## 8. Feature agent_works — Détails

### 8.1 Modèles de données

- **WoModel** (`wo_model.dart`) : Work Order — champs principaux : `woCode`, `act`, `woDesc`, `objectDesc`, `trade`, `woStatus`, `completed`, `checkListItems` (List<TaskModel>)
- **TaskModel** (`task_model.dart`) : Checklist item — champs principaux : `code` (clé de déduplication), `sequence`, `desc`, `type` (NUMERIC/YES_NO/ITEM/DATETIME/COMMENT/QUALITATIVE), `value`, `finding`, `notes`, `completed`, `uom`, `min`, `max`
- **SyncResponseModel** (`sync_response_model.dart`) : Wrapper de `/wmwo/sync/all` — contient `dataUnitMap.wo` (liste de WoModel)
- **ChecklistResponseModel** (`checklist_response_model.dart`) : Wrapper de `/wmwo/checklist` — contient `checkItems` (List<TaskModel>)

### 8.2 BLoC Events & State

```
Events:
  LoadWorksEvent              → charge tous les WO depuis /wmwo/sync/all
  LoadChecklistEvent(woCode, act) → charge la checklist d'un WO spécifique
  LoadAllChecklistsEvent      → charge les checklists de TOUS les WO
  LoadSelectedChecklistsEvent → charge les checklists des WO sélectionnés uniquement
  ToggleWorkSelectionEvent(woCode) → toggle sélection d'un WO
  SelectAllWorksEvent         → sélectionner tous les WO
  DeselectAllWorksEvent       → désélectionner tous les WO
  SendViaBleEvent(payload)    → envoyer JSON via BLE
  DownloadJsonEvent(payload)  → sauvegarder en fichier JSON via FilePicker
  ResetEvent                  → reset complet de l'état

State (AgentWorksState):
  works: List<WoModel>
  checklistsByWoCode: Map<String, List<TaskModel>>   ← checklists chargées par woCode
  loadingChecklists: Set<String>                      ← woCode en cours de chargement
  selectedWoCodes: Set<String>                        ← WO sélectionnés (checkboxes)
  isLoadingWorks, isSendingBle, error, successMessage

  Computed:
    hasAnyChecklist → au moins une checklist chargée
    hasChecklist(woCode) → checklist chargée pour ce WO
    allCheckItems → agrégation de TOUTES les checklists, dédupliquées par champ "code"
```

### 8.3 Payloads BLE (JSON wrappé par action)

```json
// Login payload
{ "LOGGIN": { ...loginResponseJson... } }

// Works + checklists payload
{ "UPPLOAD_WORK": { "wo": [...], "checkItems": [...] } }

// Tasks only payload
{ "UPLOAD_TASK": { "checkItems": [...déduplication par code...] } }

// Payload complet (ALL)
{
  "LOGGIN": { ...loginResponseJson... },
  "UPPLOAD_WORK": { "wo": [...], "checkItems": [...] }
}
```

> ⚠️ Le bouton de transfert BLE est **désactivé** quand aucune checklist n'est chargée (`!hasAnyChecklist`).

### 8.4 UI — Agent Works Page

- **Split-view** : panneau gauche = liste des WO avec checkboxes, panneau droit = checklist agrégée
- **Indicateurs visuels** : point vert ● sur les WO dont la checklist est chargée
- **AppBar** : compteur checklists chargées/total, boutons RECHARGER, TOUT CHARGER, télécharger JSON, transfert BLE
- **Dialog BLE** : choix de l'action à envoyer (LOGGIN / UPPLOAD_WORK / UPLOAD_TASK / TOUT)

---

## 9. BLE — Protocole de transfert

- Librairie : `flutter_blue_plus_windows`
- Transfert par chunks de **250 octets**
- Protocole personnalisé avec framing (voir `ble_receiver_bloc.dart`)
- Les payloads sont wrappés avec une clé d'action JSON (§8.3)

---

## 10. Points TODO / Next Steps

- [x] **Authentification** : login avec sauvegarde token + session → FAIT
- [x] **Gestion expiration token** : 401 EXPIRED_TOKEN → redirect login → retour page précédente → FAIT
- [x] **Feature agent_works** : chargement WO + checklists + UI + BLE → FAIT
- [ ] **flutter_secure_storage** : stocker les tokens de façon sécurisée (actuellement SharedPreferences)
- [ ] **Endpoint réel** : remplacer `/test_upload` par le vrai endpoint du serveur
- [ ] **Validation du JSON** : ajouter un schéma de validation avant upload
- [ ] **Historique des uploads** : nouvelle feature `upload_history` (stockage local des résultats)
- [ ] **Progress upload** : brancher `onSendProgress` de Dio pour une barre de progression réelle
- [ ] **Tests** : unit tests pour les BLoCs et Repositories
- [ ] **Supprimer la feature `example`** quand elle n'est plus utile
- [ ] **Isar** : exploiter la base locale pour cache offline des WO et checklists

---

## 11. Commandes utiles

```powershell
# Lancer l'app Windows
flutter run -d windows

# Régénérer le code (models .g.dart, injection.config.dart)
dart run build_runner build --delete-conflicting-outputs

# Analyser le code
flutter analyze --no-fatal-infos

# Ajouter une dépendance
flutter pub add <package>

# Build release Windows
flutter build windows --release
```

---

## 12. Notes importantes

- **`withOpacity()` est déprécié** → utiliser `.withValues(alpha: x)` (Dart 3.x)
- **DI via `get_it` + `injectable`** — `configureDependencies()` dans `injection.dart` est le point d'entrée
- **`AppConfig`** gère le baseUrl runtime (ChangeNotifier + SharedPreferences)
- **`SessionManager`** gère le token, le JSON login complet, et le pendingRedirect
- **`Either<L,R>`** est implémenté nativement (pas de `dartz`) — fichier `core/utils/either.dart`
- **Sealed classes** utilisées partout pour les Events/States/Failures/Exceptions → exhaustivité garantie par le compilateur
- **json_serializable** (pas freezed) — tous les modèles utilisent `@JsonSerializable()`
- **Token brut** dans le header `Authorization` (pas de préfixe `Bearer`)
- Le projet cible **Windows Desktop** principalement — macOS utilisé pour le dev

---

## 13. Structure des fichiers à connaître impérativement

| Fichier                                                                    | Rôle                                                            |
| -------------------------------------------------------------------------- | --------------------------------------------------------------- |
| `lib/main.dart`                                                            | Init DI, wire token expiry callback, `runApp(MyApp → AppShell)` |
| `lib/app/app_shell.dart`                                                   | Shell principal, sidebar, 4 pages                               |
| `lib/core/config/app_config.dart`                                          | **Singleton** : baseUrl runtime (ChangeNotifier)                |
| `lib/core/session/session_manager.dart`                                    | **@singleton** : token, loginResponseJson, pendingRedirect      |
| `lib/core/di/injection.dart`                                               | `configureDependencies()` → get_it + injectable                 |
| `lib/core/di/injection.config.dart`                                        | [GÉNÉRÉ] Toutes les enregistrations DI                          |
| `lib/core/network/dio_config.dart`                                         | @module → fournit Dio avec intercepteurs                        |
| `lib/core/network/dio_client.dart`                                         | Wrapper Dio avec helpers HTTP                                   |
| `lib/core/network/interceptors/auth_interceptor.dart`                      | Token injection + EXPIRED_TOKEN detection                       |
| `lib/core/error/exceptions.dart`                                           | `AppException` sealed — couche data                             |
| `lib/core/error/failures.dart`                                             | `Failure` sealed — couche domain                                |
| `lib/core/utils/either.dart`                                               | `Either<L,R>` natif                                             |
| `lib/core/utils/result.dart`                                               | `typedef Result<T>`                                             |
| `lib/core/base/base_repository.dart`                                       | `mixin SafeCallMixin`                                           |
| `lib/core/theme/app_theme.dart`                                            | `AppColors`, `AppTextStyles`, `AppTheme.dark`                   |
| `lib/features/authentification/presentation/login_cubit.dart`              | Login + sauvegarde session                                      |
| `lib/features/agent_works/presentation/bloc/agent_works_bloc.dart`         | BLoC travaux + BLE payloads                                     |
| `lib/features/agent_works/presentation/pages/agent_works_page.dart`        | UI split-view WO / checklists                                   |
| `lib/features/discharge_works/presentation/bloc/discharge_works_bloc.dart` | BLoC upload fichiers                                            |
| `lib/features/ble_receiver/presentation/bloc/ble_receiver_bloc.dart`       | BLoC BLE scan + transfer                                        |
| `lib/features/settings/presentation/pages/settings_page.dart`              | Config baseUrl UI                                               |
