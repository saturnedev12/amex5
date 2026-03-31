# BLE Receiver — Documentation technique complète

> Application : **AMEX5 — Industrial Control Suite** (Flutter Windows Desktop)
> Feature : `lib/features/ble_receiver/`
> Rôle du PC Windows : **Central BLE (Client GATT)**
> Rôle du smartphone Android : **Peripheral BLE (Serveur GATT)**

---

## Sommaire

1. [Vue d'ensemble du système BLE](#1-vue-densemble-du-système-ble)
2. [Architecture du package — Clean Architecture](#2-architecture-du-package--clean-architecture)
3. [Les UUIDs — clé de l'identification GATT](#3-les-uuids--clé-de-lidentification-gatt)
4. [Le package `flutter_blue_plus_windows`](#4-le-package-flutter_blue_plus_windows)
5. [Analyse ligne par ligne de `ble_data_source.dart`](#5-analyse-ligne-par-ligne-de-ble_data_sourcedart)
6. [Le protocole de Chunking JSON](#6-le-protocole-de-chunking-json)
7. [Les entités du domaine](#7-les-entités-du-domaine)
8. [Le Repository pattern](#8-le-repository-pattern)
9. [Le BLoC — Gestion d'état](#9-le-bloc--gestion-détat)
10. [La couche UI — Présentation](#10-la-couche-ui--présentation)
11. [Flux de données complet (diagramme)](#11-flux-de-données-complet-diagramme)
12. [Problème UUID Windows — Résolution](#12-problème-uuid-windows--résolution)
13. [Connexion avec l'Android Server (`AndroidBleServerManager`)](#13-connexion-avec-landroid-server-androidbleservermanager)

---

## 1. Vue d'ensemble du système BLE

### Qu'est-ce que le BLE (Bluetooth Low Energy) ?

Le BLE est un protocole de communication sans fil conçu pour les échanges de petits volumes de données avec une consommation énergétique minimale. Il est structuré autour du modèle **GATT (Generic Attribute Profile)** :

```
Android (Peripheral / Serveur GATT)
        │
        │  BLE Radio (2.4 GHz)
        ▼
Windows PC (Central / Client GATT)
```

- Le **Peripheral** (Android) publie des **Services** qui contiennent des **Caractéristiques**. Il advertise sa présence sur les ondes radio.
- Le **Central** (Windows) scanne les péripheriques à portée, s'y connecte, découvre ses services, puis lit/écrit/s'abonne aux notifications.

### Modèle GATT — Hiérarchie des objets

```
Peripheral (Android "Serveur_Flutter")
└── Service  (UUID: 0000ffe0-...)        ← regroupement logique
    └── Characteristic (UUID: 0000ffe1-...) ← le canal d'échange réel
        ├── Propriété : READ   → Windows peut lire
        ├── Propriété : WRITE  → Windows peut écrire
        └── Propriété : NOTIFY → Android peut pousser des données vers Windows
```

### Ce que fait cette feature

1. Le PC Windows **scanne** le BLE pour trouver le serveur Android
2. Il **se connecte** et découvre le Service + la Caractéristique cibles
3. Il **s'abonne aux notifications** (NOTIFY) pour recevoir les JSON envoyés par Android
4. Il peut également **envoyer des JSON** vers Android via WRITE
5. Tout JSON reçu ou envoyé est affiché dans un journal temps réel dans l'UI

---

## 2. Architecture du package — Clean Architecture

La feature respecte la **Clean Architecture** du projet AMEX5, organisée en 3 couches strictement séparées :

```
lib/features/ble_receiver/
├── domain/                         ← Cœur métier — aucune dépendance externe
│   ├── entities/
│   │   └── ble_device_entity.dart  ← BleDeviceEntity, BleJsonRecord, BleDirection
│   └── repositories/
│       └── ble_repository.dart     ← Interface abstraite (contrat)
│
├── data/                           ← Implémentations concrètes — accès aux données
│   ├── datasources/
│   │   └── ble_data_source.dart    ← WindowsBleClientDataSource (API BLE réelle)
│   └── repositories/
│       └── ble_repository_impl.dart ← Délègue à la datasource
│
└── presentation/                   ← UI + Gestion d'état
    ├── bloc/
    │   └── ble_bloc.dart           ← Events, States, BleBloc
    ├── widgets/
    │   └── ble_widgets.dart        ← BleStatusBadge, RssiBar, BleDeviceTile, BleJsonEntry
    └── pages/
        └── ble_receiver_page.dart  ← Page principale de la feature
```

**Règle de dépendance** : les flèches pointent toujours vers l'intérieur.
- `domain` ne connaît rien de `data` ni de `presentation`
- `data` connaît `domain` (implémente ses interfaces)
- `presentation` connaît `domain` et `data` (instancie le BLoC avec la datasource concrète)

---

## 3. Les UUIDs — clé de l'identification GATT

```dart
const String _kServiceUuid = '0000ffe0-0000-1000-8000-00805f9b34fb';
const String _kCharUuid    = '0000ffe1-0000-1000-8000-00805f9b34fb';
```

### Format UUID 128-bit Bluetooth SIG

Le Bluetooth SIG (Standards Body) définit une **base UUID** :
```
xxxxxxxx-0000-1000-8000-00805f9b34fb
```

Pour les UUIDs de service 16-bit assignés, on utilise la forme `0000XXXX-0000-1000-8000-00805f9b34fb`.

- `0000ffe0` → service "HM-10 / BLE Serial" (UUID propriétaire 0xFFE0)
- `0000ffe1` → caractéristique associée (0xFFE1)

Ces UUIDs sont courants dans les modules BLE génériques (HM-10, etc.) et dans les applications qui veulent un canal "série BLE" bidirectionnel.

**Important** : les deux côtés (Android et Windows) **doivent utiliser exactement les mêmes UUIDs**. C'est le mécanisme d'identification — sans correspondance UUID, la connexion échoue.

---

## 4. Le package `flutter_blue_plus_windows`

### Problème de base

`flutter_blue_plus` ne supporte **pas** Windows nativement — il est conçu pour Android et iOS, qui exposent des APIs BLE système directes.

Windows expose son API BLE via **WinRT** (Windows Runtime), qui est une couche COM/C++ non accessible directement depuis Dart/Flutter sans bindings natifs.

### La chaîne de packages

```
flutter_blue_plus_windows (pub.dev)
        │
        │  Réexporte l'API de flutter_blue_plus
        │  Remplace l'implémentation native par win_ble
        ▼
win_ble (bindings Dart ↔ WinRT natif)
        │
        ▼
Windows BLE Stack (WinRT / Bluetooth GATT Client API)
```

- **`flutter_blue_plus_windows: ^1.26.1`** est un thin wrapper qui :
  1. Exporte tous les types de `flutter_blue_plus` (`BluetoothDevice`, `BluetoothService`, `BluetoothCharacteristic`, `Guid`, `ScanResult`, etc.)
  2. Substitue l'implémentation plateforme par `win_ble` pour Windows
  3. Résultat : **l'API Dart est identique à `flutter_blue_plus`** — seul l'import change

### Dans le code

```dart
// Un seul import suffit — API 100% identique à flutter_blue_plus
import 'package:flutter_blue_plus_windows/flutter_blue_plus_windows.dart';
```

Au lieu de :
```dart
import 'package:flutter_blue_plus/flutter_blue_plus.dart'; // ne marche pas sur Windows
```

---

## 5. Analyse ligne par ligne de `ble_data_source.dart`

Ce fichier est le **cœur technique** de la feature. C'est ici que toute l'interaction BLE réelle se passe.

### 5.1 Les constantes globales

```dart
const String _kServiceUuid = '0000ffe0-0000-1000-8000-00805f9b34fb';
const String _kCharUuid    = '0000ffe1-0000-1000-8000-00805f9b34fb';
const int    _kChunkSize   = 250;  // octets par paquet BLE
const int    _kChunkDelayMs = 30;  // ms de pause entre chunks
```

Le préfixe `_k` est la convention Dart pour les constantes privées (`k` = konstante).

### 5.2 La fonction `_uuidMatches()` — Tolérance de format

```dart
bool _uuidMatches(Guid uuid, String expected) {
  final raw = uuid.toString().toLowerCase()
    .replaceAll('{', '').replaceAll('}', '');
  final exp = expected.toLowerCase();

  if (raw == exp) return true;  // Cas normal

  final sigMatch = RegExp(
    r'^0000([0-9a-f]{4})-0000-1000-8000-00805f9b34fb$',
  ).firstMatch(exp);

  if (sigMatch != null) {
    final short4 = sigMatch.group(1)!;
    if (raw == short4) return true;
    if (raw == '0000$short4') return true;
    if (raw.startsWith('0000$short4')) return true;
  }
  return false;
}
```

**Pourquoi cette fonction existe-t-elle ?**

Le stack BLE de Windows (via win_ble) ne retourne pas toujours les UUIDs dans le format 128-bit complet. Selon la version du driver, l'OS, ou le périphérique connecté, on peut recevoir :

| Format reçu par Windows | Exemple |
|---|---|
| Forme complète (idéal) | `0000ffe0-0000-1000-8000-00805f9b34fb` |
| Forme courte 4-hex | `ffe0` |
| Forme 8-char | `0000ffe0` |
| Majuscules avec accolades | `{0000FFE0-0000-1000-8000-00805F9B34FB}` |

La RegEx `^0000([0-9a-f]{4})-0000-1000-8000-00805f9b34fb$` extrait le segment `ffe0` de l'UUID complet pour les comparaisons en forme courte.

**Sans cette fonction**, la connexion échouait avec le message :
> `Exception: Caractéristique BLE (0000ffe1-...) introuvable sur le serveur Android.`

### 5.3 L'interface abstraite `BleDataSource`

```dart
abstract class BleDataSource {
  Stream<List<BleDeviceEntity>> get scanResultsStream;
  Stream<Map<String, dynamic>> get receivedJsonStream;
  Stream<bool> get connectionStateStream;

  Future<void> startScan();
  Future<void> stopScan();
  Future<void> connectToDevice(BleDeviceEntity device);
  Future<void> sendJson(Map<String, dynamic> data);
  Future<void> disconnect();
  void dispose();
}
```

C'est un **contrat** (interface) qui définit ce que toute implémentation datasource doit fournir. Si demain on veut ajouter une version macOS ou Linux, on crée une nouvelle classe qui `implements BleDataSource` sans toucher au reste du code.

Les **3 Streams** sont la colonne vertébrale de la communication asynchrone :
- `scanResultsStream` → émet une liste de devices à chaque update du scan
- `receivedJsonStream` → émet un Map<String, dynamic> quand un JSON complet est reçu
- `connectionStateStream` → émet `true`/`false` selon l'état de la connexion

### 5.4 La classe `WindowsBleClientDataSource`

```dart
class WindowsBleClientDataSource implements BleDataSource {
  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _characteristic;
  
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<List<int>>? _characteristicSubscription;
  StreamSubscription<BluetoothConnectionState>? _connectionStateSubscription;
  
  final Map<String, BluetoothDevice> _foundDevicesMap = {};
  final List<int> _receiveBuffer = [];
  
  final _scanController       = StreamController<List<BleDeviceEntity>>.broadcast();
  final _jsonController       = StreamController<Map<String, dynamic>>.broadcast();
  final _connectionController = StreamController<bool>.broadcast();
```

**État interne — les variables membres :**

| Variable | Type | Rôle |
|---|---|---|
| `_connectedDevice` | `BluetoothDevice?` | L'objet BLE du périphérique connecté |
| `_characteristic` | `BluetoothCharacteristic?` | La caractéristique active (lecture/écriture/notify) |
| `_scanSubscription` | `StreamSubscription?` | Abonnement au stream de scan de flutter_blue_plus |
| `_characteristicSubscription` | `StreamSubscription?` | Abonnement aux notifications BLE entrantes |
| `_connectionStateSubscription` | `StreamSubscription?` | Abonnement aux changements d'état de connexion |
| `_foundDevicesMap` | `Map<String, BluetoothDevice>` | Cache des devices BLE bruts trouvés (clé = remoteId MAC) |
| `_receiveBuffer` | `List<int>` | Buffer applicatif d'assemblage des chunks JSON |

**Les StreamControllers en mode broadcast :**

```dart
final _scanController       = StreamController<List<BleDeviceEntity>>.broadcast();
final _jsonController       = StreamController<Map<String, dynamic>>.broadcast();
final _connectionController = StreamController<bool>.broadcast();
```

`.broadcast()` permet à **plusieurs listeners** de s'abonner au même stream simultanément (le BLoC + potentiellement l'UI directement). Un StreamController normal ne supporte qu'un seul listener.

### 5.5 La méthode `startScan()`

```dart
@override
Future<void> startScan() async {
  _foundDevicesMap.clear();
  await _scanSubscription?.cancel();

  await FlutterBluePlus.startScan(
    withServices: [Guid(_kServiceUuid)],
    timeout: const Duration(seconds: 15),
  );

  _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
    for (final r in results) {
      _foundDevicesMap[r.device.remoteId.toString()] = r.device;
    }
    final entities = results.map((r) => BleDeviceEntity(
      id: r.device.remoteId.toString(),
      name: r.device.platformName.isNotEmpty ? r.device.platformName : 'Appareil BLE',
      rssi: r.rssi,
    )).toList();
    if (!_scanController.isClosed) _scanController.add(entities);
  });
}
```

**Points techniques :**

1. **`withServices: [Guid(_kServiceUuid)]`** — filtre le scan pour ne retourner que les périphériques qui advertise le service `0xFFE0`. Cela évite de lister tous les périphériques BLE à portée (casques, montres, etc.).

2. **`_foundDevicesMap`** — le `_scanController` émet des `BleDeviceEntity` (objets du domaine, sans dépendance BLE), mais pour se connecter il faut l'objet `BluetoothDevice` brut de flutter_blue_plus. Ce Map fait le pont entre les deux via le `remoteId` (adresse MAC).

3. **`r.device.platformName`** — le nom annoncé par le périphérique dans ses données d'advertising. L'Android annonce `"Serveur_Flutter"` via `BlePeripheral.startAdvertising(localName: "Serveur_Flutter")`.

4. **`timeout: Duration(seconds: 15)`** — le scan s'arrête automatiquement après 15s pour économiser la batterie et les ressources.

### 5.6 La méthode `connectToDevice()`

```dart
@override
Future<void> connectToDevice(BleDeviceEntity deviceEntity) async {
  // 1. Récupérer le BluetoothDevice brut depuis le cache
  final btDevice = _foundDevicesMap[deviceEntity.id];
  if (btDevice == null) throw Exception("Appareil introuvable...");

  // 2. Stopper le scan avant de se connecter
  await stopScan();
  _connectedDevice = btDevice;
  await _connectedDevice!.connect(autoConnect: false);

  // 3. Écouter les changements d'état de connexion
  _connectionStateSubscription = _connectedDevice!.connectionState.listen((state) {
    final connected = state == BluetoothConnectionState.connected;
    if (!_connectionController.isClosed) _connectionController.add(connected);
    if (!connected) {
      _characteristic = null;
      _receiveBuffer.clear();
    }
  });

  // 4. Découvrir les services GATT
  final services = await _connectedDevice!.discoverServices();
  
  // 5. Debug — afficher tous les UUIDs retournés par Windows
  debugPrint('BLE — ${services.length} service(s) découvert(s) :');
  for (final svc in services) {
    debugPrint('  ├─ Service : ${svc.uuid}');
    for (final chr in svc.characteristics) {
      debugPrint('  │   └─ Char : ${chr.uuid}  props=${chr.properties}');
    }
  }
  
  // 6. Trouver le service et la caractéristique cibles
  for (final svc in services) {
    if (_uuidMatches(svc.uuid, _kServiceUuid)) {
      for (final chr in svc.characteristics) {
        if (_uuidMatches(chr.uuid, _kCharUuid)) {
          _characteristic = chr;
          await _subscribeToNotifications();
          break;
        }
      }
      break;
    }
  }

  // 7. Vérifier que la caractéristique a bien été trouvée
  if (_characteristic == null) {
    throw Exception('Caractéristique BLE introuvable sur le serveur Android.');
  }
}
```

**Séquence GATT — Étape par étape :**

```
1. connect()           → Établit la connexion L2CAP/BLE radio
2. discoverServices()  → Lit la table GATT du serveur (ATT requests)
3. _uuidMatches()      → Identifie le bon service et la bonne caractéristique
4. setNotifyValue(true)→ Active la souscription CCCD (Client Characteristic Config Descriptor)
```

**Pourquoi `autoConnect: false` ?**

`autoConnect: true` demande à Windows de se connecter automatiquement en arrière-plan quand le périphérique est détecté. `false` force une connexion directe et immédiate — comportement prévisible pour une app interactive.

### 5.7 La méthode `_subscribeToNotifications()`

```dart
Future<void> _subscribeToNotifications() async {
  await _characteristicSubscription?.cancel();
  await _characteristic!.setNotifyValue(true);

  _characteristicSubscription = _characteristic!.lastValueStream.listen((bytes) {
    if (bytes.isNotEmpty) _processChunk(bytes);
  });
}
```

**`setNotifyValue(true)`** écrit `0x0001` dans le **CCCD** (Client Characteristic Configuration Descriptor) de la caractéristique. C'est le mécanisme GATT standard qui "allume" les notifications côté serveur (Android). Sans cette étape, Android ne saurait pas qu'il doit envoyer des notifications à Windows.

**`lastValueStream`** vs `onValueReceived` :

| Stream | Comportement |
|---|---|
| `lastValueStream` | Émet la **dernière valeur connue** dès l'abonnement + chaque nouvelle valeur |
| `onValueReceived` | Émet **uniquement** les nouvelles valeurs reçues (pas la dernière valeur en cache) |

On utilise `lastValueStream` car il garantit de ne manquer aucun chunk.

### 5.8 La méthode `_processChunk()` — Le cœur du déchunking

```dart
void _processChunk(List<int> chunk) {
  _receiveBuffer.addAll(chunk);  // Ajouter le chunk au buffer
  try {
    final jsonStr = utf8.decode(_receiveBuffer);   // Tenter UTF-8
    final decoded = jsonDecode(jsonStr);           // Tenter JSON parse

    final Map<String, dynamic> json;
    if (decoded is Map<String, dynamic>) {
      json = decoded;
    } else if (decoded is List) {
      json = {'data': decoded};   // Normalisation des arrays JSON
    } else {
      throw FormatException('Type JSON inattendu');
    }

    if (!_jsonController.isClosed) _jsonController.add(json);
    _receiveBuffer.clear();  // Succès → vider le buffer

  } on FormatException {
    // JSON incomplet → NE PAS vider le buffer, attendre le prochain chunk
  } catch (e) {
    debugPrint('BLE — Erreur parsing JSON : $e');
    _receiveBuffer.clear();  // Erreur fatale → purger le buffer corrompu
  }
}
```

Cette méthode est au cœur du protocole de communication. Voir [Section 6](#6-le-protocole-de-chunking-json) pour une explication complète.

### 5.9 La méthode `sendJson()` — Envoi chunké vers Android

```dart
@override
Future<void> sendJson(Map<String, dynamic> data) async {
  if (_characteristic == null) throw Exception("Pas de connexion BLE active.");

  final bytes = utf8.encode(jsonEncode(data));
  
  for (int i = 0; i < bytes.length; i += _kChunkSize) {
    final end = (i + _kChunkSize < bytes.length) ? i + _kChunkSize : bytes.length;
    await _characteristic!.write(
      bytes.sublist(i, end),
      withoutResponse: false,  // Write With Response (ACK garanti)
    );
    await Future.delayed(const Duration(milliseconds: _kChunkDelayMs));
  }
}
```

**`withoutResponse: false`** = **Write With Response** (opcode BLE `0x12`). Le serveur Android envoie un ACK GATT pour chaque paquet. Plus lent mais **fiable** — on ne perd pas de chunks.

**`withoutResponse: true`** = Write Without Response (opcode `0x52`). Plus rapide mais sans garantie de réception. Déconseillé pour du JSON structuré.

### 5.10 La méthode `dispose()`

```dart
@override
void dispose() {
  _scanSubscription?.cancel();
  _characteristicSubscription?.cancel();
  _connectionStateSubscription?.cancel();
  _connectedDevice?.disconnect();

  if (!_scanController.isClosed) _scanController.close();
  if (!_jsonController.isClosed) _jsonController.close();
  if (!_connectionController.isClosed) _connectionController.close();
}
```

`dispose()` est critique pour éviter les **memory leaks** :
- Les `StreamSubscription` doivent être `.cancel()`s pour cesser d'écouter
- Les `StreamController` doivent être `.close()`s pour libérer les ressources Dart et signaler la fin du stream aux listeners
- Le `_connectedDevice` doit être `.disconnect()`é pour libérer la connexion BLE radio

Le guard `if (!_scanController.isClosed)` évite l'erreur `Bad state: Cannot close a closed stream` si `dispose()` est appelé deux fois.

---

## 6. Le protocole de Chunking JSON

### Pourquoi chunker ?

Le BLE impose une **MTU (Maximum Transmission Unit)** maximale par paquet. La valeur négociée par défaut est souvent 23 octets (ATT_MTU par défaut), ou jusqu'à 512 octets après négociation. En pratique, avec la plupart des stacks Windows/Android, une valeur sûre est **~250 octets** par notification/écriture.

Un JSON typique peut faire plusieurs centaines voire milliers d'octets → il faut le découper.

### Mécanisme côté Android (envoi)

```
JSON complet (ex: 800 octets)
│
├── Chunk 1 : octets [0  → 249]  → BlePeripheral.updateCharacteristic()
│   (pause 30ms)
├── Chunk 2 : octets [250 → 499] → BlePeripheral.updateCharacteristic()
│   (pause 30ms)
├── Chunk 3 : octets [500 → 749] → BlePeripheral.updateCharacteristic()
│   (pause 30ms)
└── Chunk 4 : octets [750 → 799] → BlePeripheral.updateCharacteristic()
```

La pause de **30ms entre chaque chunk** est indispensable. Le stack GATT Android ne peut pas traiter des notify() consécutifs sans délai — les paquets seraient droppés silencieusement.

### Mécanisme côté Windows (réception — `_processChunk`)

```
Chunk 1 reçu → _receiveBuffer = [octets 0→249]
  → utf8.decode() → OK (chaîne valide)
  → jsonDecode()  → FormatException (JSON incomplet "{"id":1,"na")
  → On attend le prochain chunk

Chunk 2 reçu → _receiveBuffer = [octets 0→499]
  → utf8.decode() → OK
  → jsonDecode()  → FormatException (JSON incomplet)
  → On attend

...

Chunk 4 reçu → _receiveBuffer = [octets 0→799]
  → utf8.decode() → OK
  → jsonDecode()  → SUCCÈS → {"id":1,"name":"test",...}
  → _jsonController.add(json)
  → _receiveBuffer.clear()  ← prêt pour le prochain message
```

**Astuce du protocole** : on utilise `FormatException` comme **signal de flux incomplet**. Un JSON partiellement reçu ne peut pas être parsé → exception → on garde le buffer → on attend le prochain chunk. C'est élégant car le JSON est auto-délimitant (accolades `{}` fermantes).

### Cas limite — Buffer UTF-8 cassé au milieu d'un caractère multibyte

Un caractère UTF-8 peut prendre 1 à 4 octets. Si le découpage BLE tombe au milieu d'un caractère multi-octets, `utf8.decode()` lèvera aussi une `FormatException` — ce qui est géré correctement par le même bloc `on FormatException`.

---

## 7. Les entités du domaine

### `BleDeviceEntity`

```dart
class BleDeviceEntity {
  final String id;    // Adresse MAC du périphérique ("AA:BB:CC:DD:EE:FF")
  final String name;  // Nom annoncé ("Serveur_Flutter")
  final int rssi;     // Puissance du signal reçu en dBm (ex: -65)
}
```

**RSSI (Received Signal Strength Indicator)** : exprimé en dBm.
- `-50 dBm` → signal excellent (très proche)
- `-70 dBm` → signal correct (quelques mètres)
- `-85 dBm` → signal faible (limite de portée)
- `-100 dBm` → quasi-inexistant

### `BleJsonRecord`

```dart
class BleJsonRecord {
  final Map<String, dynamic> data;      // Le JSON lui-même
  final DateTime timestamp;             // Horodatage de réception/envoi
  final BleDirection direction;         // received ou sent
  
  String get prettyJson { ... }         // JSON indenté pour affichage
}
```

`prettyJson` utilise `JsonEncoder.withIndent('  ')` pour formater le JSON avec 2 espaces d'indentation, rendant le JSON lisible dans l'UI.

### `BleDirection`

```dart
enum BleDirection { received, sent }
```

Distingue dans le journal si le JSON a été reçu de l'Android (`←`) ou envoyé vers l'Android (`→`).

---

## 8. Le Repository pattern

### `BleRepository` (interface)

Définie dans le domaine — aucune dépendance BLE. C'est le **contrat** que le BLoC utilise.

```dart
abstract class BleRepository {
  Stream<List<BleDeviceEntity>> get scanResultsStream;
  Stream<Map<String, dynamic>> get receivedJsonStream;
  Stream<bool> get connectionStateStream;
  
  Future<void> startScan();
  Future<void> stopScan();
  Future<void> connectToDevice(BleDeviceEntity device);
  Future<void> sendJson(Map<String, dynamic> data);
  Future<void> disconnect();
  void dispose();
}
```

### `BleRepositoryImpl` (implémentation)

```dart
class BleRepositoryImpl implements BleRepository {
  final BleDataSource _dataSource;
  BleRepositoryImpl(this._dataSource);
  
  @override
  Future<void> startScan() => _dataSource.startScan();
  // ...tous les autres méthodes délèguent identiquement
}
```

Dans cette feature, le repository est une **délégation pure** — il ne fait que passer les appels à la datasource. Son utilité devient évidente si l'on veut :
- Combiner plusieurs datasources (BLE + HTTP)
- Ajouter de la logique de retry, de cache, ou de transformation
- Tester le BLoC en mockant le repository sans toucher la datasource

---

## 9. Le BLoC — Gestion d'état

### Architecture Events / States

```
Events (entrants)                    States (sortants)
─────────────────                    ──────────────────
BleScanStartEvent    ──────────────► BleInitial
BleStopScanEvent     ──────────────► BleScanning(devices)
BleConnectDeviceEvent ─────────────► BleConnecting(device)
BleDisconnectEvent   ──────────────► BleConnected(device, history)
BleSendJsonEvent     ──────────────► BleSending(device, history)
BleResetEvent        ──────────────► BleDisconnected(reason?)
                                     BleError(message)
                                     
Events internes (pilotés par les streams)
─────────────────────────────────────────
_DevicesUpdatedEvent    → met à jour BleScanning.devices
_JsonReceivedEvent      → ajoute un BleJsonRecord dans BleConnected.history
_ConnectionChangedEvent → passe à BleDisconnected si déconnexion inattendue
_ErrorOccurredEvent     → passe à BleError
```

### Pattern "Stream → BLoC via events internes"

C'est la technique clé pour intégrer les Streams de la datasource dans le BLoC :

```dart
// Dans _onScanStart
_scanSub = _repository.scanResultsStream.listen(
  (devices) => add(_DevicesUpdatedEvent(devices)),  // Stream → event interne
  onError: (e) => add(_ErrorOccurredEvent('$e')),
);
```

Les events **externes** (`BleScanStartEvent`, etc.) sont déclenché par l'UI. Les events **internes** (`_DevicesUpdatedEvent`, etc.) sont déclenchés par les streams BLE. Cette séparation garde le BLoC testable et les handlers clairs.

### Gestion de l'historique JSON

```dart
void _onJsonReceived(_JsonReceivedEvent event, Emitter<BleState> emit) {
  if (state is BleConnected) {
    final record = BleJsonRecord(data: event.json, timestamp: DateTime.now(), direction: BleDirection.received);
    emit((state as BleConnected).copyWith(
      history: [record, ...current.history],  // Nouveau record en tête de liste
    ));
  }
}
```

L'historique est **immutable** — chaque nouveau record crée une nouvelle liste via le spread operator. Le plus récent est toujours en tête (`[newRecord, ...oldList]`).

### Cycle de vie des StreamSubscriptions

```dart
@override
Future<void> close() async {
  await _scanSub?.cancel();
  await _jsonSub?.cancel();
  await _connSub?.cancel();
  _repository.dispose();
  return super.close();
}
```

`close()` est appelé automatiquement quand le `BlocProvider` est détruit (navigation hors de la page). C'est la garantie qu'aucun stream ne reste ouvert en arrière-plan.

---

## 10. La couche UI — Présentation

### `BleReceiverPage`

Point d'entrée de la feature. Instancie le BlocProvider :

```dart
class BleReceiverPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BleBloc(),  // BleBloc instancie lui-même BleRepositoryImpl + WindowsBleClientDataSource
      child: const _BleReceiverView(),
    );
  }
}
```

### Layout principal

```
┌─────────────────────────────────────────────────────────┐
│  AppBar : "BLE RECEIVER" + badge d'état                 │
├───────────────────┬─────────────────────────────────────┤
│  _BleScanPanel    │  _JsonLogPanel                      │
│  (340px fixe)     │  (expanded)                         │
│                   │                                     │
│  [SCANNER]        │  Journal des échanges JSON          │
│  [DÉCONNECTER]    │  ┌─ BleJsonEntry (← REÇU 14:32:01)│
│                   │  │   { "id": 1, "name": "test" }   │
│  Liste devices :  │  └─ BleJsonEntry (→ ENVOYÉ ...)    │
│  ┌─ BleDeviceTile│                                     │
│  │ Serveur_Flutter│  Zone d'envoi JSON manuel           │
│  └─ [CONN.]       │  [TextField] [ENVOYER]              │
└───────────────────┴─────────────────────────────────────┘
```

### Les widgets réutilisables (`ble_widgets.dart`)

**`BleStatusBadge`** — Badge d'état dans l'AppBar :
```
● INACTIF    (gris)
● SCAN...    (orange)
● CONNEXION  (orange)
● CONNECTÉ   (vert)
● ENVOI      (bleu)
● DÉCONNECTÉ (gris foncé)
● ERREUR     (rouge)
```

**`RssiBar`** — Indicateur visuel de 4 barres (comme l'icône réseau mobile) :
- 4 barres vertes → signal excellent (≥ -60 dBm)
- 3 barres orange → signal correct (≥ -70 dBm)
- 2 barres rouge → signal faible (≥ -80 dBm)
- 1 barre rouge → signal très faible (< -80 dBm)

**`BleJsonEntry`** — Card expansible pour chaque échange JSON :
- Collapsed : aperçu 1 ligne `{ "clé1": val1, "clé2": val2, ... }`
- Expanded : JSON indenté complet, **`SelectableText`** (sélectionnable/copiable)

**`BleSectionDivider`** — Séparateur de section visuel avec label.

### Gestion des erreurs dans l'UI

Quand le BLoC émet `BleError`, le `_JsonLogPanel` affiche `_buildErrorState()` :

```dart
Widget _buildErrorState(String message) {
  return Container(
    // ...styling rouge...
    child: SelectableText(
      message,
      style: TextStyle(fontFamily: 'monospace', color: AppColors.error),
    ),
  );
}
```

Le `SelectableText` permet de **sélectionner et copier** le message d'erreur — utile pour debugger des messages d'exception longs.

---

## 11. Flux de données complet (diagramme)

```
Utilisateur appuie "SCANNER"
        │
        ▼
BleBloc.add(BleScanStartEvent)
        │
        ▼
_onScanStart()
  ├─ emit(BleScanning())           → UI affiche spinner + liste vide
  ├─ _scanSub = scanResultsStream.listen(...)
  └─ _repository.startScan()
                │
                ▼
        FlutterBluePlus.startScan(withServices: [...])
                │
                │  (Android advertise "Serveur_Flutter")
                │
                ▼
        ScanResult reçu
                │
                ▼
        _foundDevicesMap["AA:BB:..."] = BluetoothDevice
        _scanController.add([BleDeviceEntity(...)])
                │
                ▼
        _scanSub → BleBloc.add(_DevicesUpdatedEvent([...]))
                │
                ▼
        _onDevicesUpdated()
          └─ emit(BleScanning(devices: [BleDeviceEntity(...)]))
                │
                ▼
        UI affiche BleDeviceTile("Serveur_Flutter")

──────── L'utilisateur clique "CONN." ────────

BleBloc.add(BleConnectDeviceEvent(device))
        │
        ▼
_onConnectDevice()
  ├─ emit(BleConnecting(device))
  ├─ _jsonSub = receivedJsonStream.listen(...)
  ├─ _connSub = connectionStateStream.listen(...)
  └─ _repository.connectToDevice(device)
                │
                ▼
        btDevice.connect()
        btDevice.discoverServices()
        _uuidMatches() → trouve service + char
        _subscribeToNotifications()
          └─ characteristic.setNotifyValue(true)
          └─ lastValueStream.listen() → _processChunk()
                │
                ▼
        (retour réussi)
                │
                ▼
  emit(BleConnected(device: device))
        │
        ▼
  UI affiche le journal JSON

──────── Android envoie un JSON ────────

Android BlePeripheral.updateCharacteristic(chunk1)
        │
        ▼
_processChunk([...250 bytes...])
  └─ _receiveBuffer.addAll(chunk)
  └─ jsonDecode() → FormatException → attend

Android BlePeripheral.updateCharacteristic(chunk2)
        │
        ▼
_processChunk([...250 bytes...])
  └─ _receiveBuffer.addAll(chunk)
  └─ jsonDecode() → SUCCÈS
  └─ _jsonController.add({"id": 1, ...})
  └─ _receiveBuffer.clear()
        │
        ▼
_jsonSub → BleBloc.add(_JsonReceivedEvent(json))
        │
        ▼
_onJsonReceived()
  └─ emit(BleConnected(history: [BleJsonRecord(...), ...]))
        │
        ▼
UI affiche nouvelle BleJsonEntry "← REÇU 14:32:01"
```

---

## 12. Problème UUID Windows — Résolution

### Symptôme

```
Exception: Caractéristique BLE (0000ffe1-0000-1000-8000-00805f9b34fb) introuvable sur le serveur Android.
```

L'erreur se produisait même quand l'Android était bien connecté et avait le bon service.

### Cause racine

Le stack BLE Windows (WinRT GATT) retourne les UUIDs dans des formats non standardisés selon les drivers. Exemple de ce que `discoverServices()` peut retourner :

```
// Ce qu'on attendait :
"0000ffe0-0000-1000-8000-00805f9b34fb"

// Ce que Windows retournait parfois :
"ffe0"         ← format court 16-bit
"0000FFE0"     ← forme 8-char sans tirets
"{0000FFE0-...}" ← avec accolades
```

### Solution implémentée

La fonction `_uuidMatches()` normalise les deux termes de comparaison et accepte toutes les formes connues via RegEx. Voir [Section 5.2](#52-la-fonction-_uuidmatches--tolérance-de-format).

### Logs de diagnostic ajoutés

```dart
debugPrint('BLE — ${services.length} service(s) découvert(s) :');
for (final svc in services) {
  debugPrint('  ├─ Service : ${svc.uuid}');
  for (final chr in svc.characteristics) {
    debugPrint('  │   └─ Char : ${chr.uuid}  props=${chr.properties}');
  }
}
```

Ces logs s'affichent dans la console Flutter à chaque connexion. Si la connexion échoue encore, ils montrent exactement quel format UUID Windows retourne.

---

## 13. Connexion avec l'Android Server (`AndroidBleServerManager`)

### Configuration requise côté Android

L'application Android doit utiliser le package `ble_peripheral` et configurer le serveur exactement comme suit :

```dart
// UUIDs obligatoirement identiques à ceux de Windows
static const String serverServiceUuid = "0000ffe0-0000-1000-8000-00805f9b34fb";
static const String serverCharUuid    = "0000ffe1-0000-1000-8000-00805f9b34fb";

// Propriétés de la caractéristique
BleCharacteristic(
  uuid: serverCharUuid,
  properties: [
    CharacteristicProperties.read.index,   // Windows peut lire
    CharacteristicProperties.write.index,  // Windows peut écrire (sendJson)
    CharacteristicProperties.notify.index, // Android peut notifier Windows (sendJsonToWindows)
  ],
)

// Nom d'advertising (visible lors du scan Windows)
await BlePeripheral.startAdvertising(
  services: [serverServiceUuid],
  localName: "Serveur_Flutter",  // Apparaîtra dans la liste de scan
);
```

### Tableau de correspondance des opérations

| Opération | Côté Android | Côté Windows |
|---|---|---|
| Android → Windows (JSON) | `BlePeripheral.updateCharacteristic()` (NOTIFY) | `lastValueStream.listen()` → `_processChunk()` |
| Windows → Android (JSON) | `setWriteRequestCallback()` → `_processReceivedChunk()` | `characteristic.write()` (WRITE) |
| Connexion | Advertise passif | `FlutterBluePlus.startScan()` + `device.connect()` |
| Déconnexion | `BlePeripheral.connectionStateChangeCallback` | `connectionState.listen()` |

### Compatibilité du protocole de chunking

Les deux côtés utilisent la même logique de chunking :
- Taille de chunk : **250 octets** (côté Windows : `_kChunkSize = 250`, côté Android : `chunkSize = 250`)
- Délai entre chunks : **30ms** (côté Windows : `_kChunkDelayMs = 30`, côté Android : `Duration(milliseconds: 30)`)
- Réassemblage : **tentative de parse JSON à chaque chunk** — FormatException = incomplet, succès = message complet

Cette symétrie est essentielle — modifier la taille de chunk d'un côté sans modifier l'autre peut causer des pertes de données ou des timeouts.

---

*Documentation générée pour AMEX5 — BLE Receiver Feature v1.0*
