# Déchargement Travaux

Cette feature reçoit par bluetooth un JSON produit par l'appareil distant, le parse, affiche les données pour contrôle, puis envoie les éléments vers l'API.

## Entrée attendue

Payload principal :

```json
{
  "WORKS": [],
  "CHECK_ITEMS_WORKS": []
}
```

`WORKS` contient des `WoModel`. Chaque travail peut contenir sa checklist sous `checkListItems` ou sous `checkItems`; `WoModel.fromJson` normalise `checkItems` vers `checkListItems` pour désérialiser les éléments avec `TaskModel`.

`CHECK_ITEMS_WORKS` contient des `CheckItemsWork` :

```dart
CheckItemsWork(
  checkItemCode: String?,
  woDesc: String?,
  woCode: String?,
  woMobileUuid: String?,
)
```

`woCode` peut être nul.

## Fichiers clés

- `presentation/pages/discharge_works_page.dart` : page "Déchargement travaux", connexion bluetooth, métriques, listes, affichage des checklists et boutons d'envoi.
- `presentation/bloc/discharge_works_cubit.dart` : écoute `BleService.receivedJsonStream`, parse le JSON, maintient les statuts d'envoi et déclenche les uploads.
- `domain/entities/discharge_entities.dart` : modèles d'état UI (`DischargePayload`, lignes de travaux/check items, statuts).
- `../agent_works/data/models/check_items_work.dart` : modèle API `CheckItemsWork`.
- `../agent_works/data/models/wo_model.dart` : parse aussi le champ entrant `checkItems`.
- `../agent_works/domain/repositories/agent_works_repository.dart` : expose `sendWorkStatus` et `createCheckItemWo`.
- `../agent_works/data/datasources/agent_works_remote_datasource.dart` : appels HTTP `/wmwo/act` et `/wmwo/check-item/wo`.
- `../../core/ble/ble_service.dart` : état bluetooth, scan, connexion, flux JSON reçu.

## Workflow

1. À l'ouverture de la page, le service vérifie l'état bluetooth et peut lancer le scan si l'adaptateur est actif.
2. L'utilisateur sélectionne un appareil dans la liste des appareils détectés.
3. Une fois connecté, la page écoute les notifications JSON bluetooth via `receivedJsonStream`.
4. Le Cubit parse `WORKS` et `CHECK_ITEMS_WORKS`, calcule la taille du JSON, le nombre de travaux, le nombre de check items work et le total des éléments de checklist.
5. La page affiche les travaux reçus. Pour chaque travail, les éléments de checklist sont visibles dans un panneau repliable.
6. L'utilisateur peut envoyer un élément seul ou tout envoyer. Les statuts sont `pending`, `sending`, `sent`, `error`.

## Points d'attention

- Ne pas utiliser l'abréviation courte dans les textes utilisateur de cette page; écrire "bluetooth".
- Ne pas supprimer l'ancien `DischargeWorksBloc` sans vérifier les injections existantes, même si la page actuelle utilise `DischargeWorksCubit`.
- Pour les tests manuels, utiliser un payload avec `WORKS[].checkItems` afin de vérifier que la checklist est bien visible et parsée en `TaskModel`.
