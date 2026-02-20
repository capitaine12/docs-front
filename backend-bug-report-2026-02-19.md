<p>
  <a href="./index.html" style="
    display:inline-block;
    padding:8px 16px;
    background:#2d89ef;
    color:white;
    text-decoration:none;
    border-radius:6px;
  ">
    ⬅ Retour à la liste
  </a>
</p>

# Rapport Bugs Backend (Local) — Tenant

Date: 2026-02-19  
Mise à jour: après runs console `18:17:46` (vert) et `00:45:8` du 20/02 (régression partielle)

## 1) Permissions ADMIN (403 projets/admin)
- Statut: **résolu localement**.
- Action faite: patch `docs/local-admin-rebac-hotfix.sql`.
- Preuve: 17 permissions présentes dans `role_matrix` pour `ADMIN`.
- Dette backend: intégrer migration officielle (pas de patch manuel en QA/prod).
- Régression observée:
  - Sur le run `docs/logs/console-export-2026-2-20_0-45-8.log`, `GET /api/projects` retombe en `403` (plusieurs occurrences).
  - Donc le correctif RBAC n'est pas encore stabilisé durablement côté backend/environnement.

## 2) `PUT /api/user/profile` -> 500 intermittent
- Statut: **stabilisé sur le dernier run**.
- Dernier run (`docs/logs/console-export-2026-2-19_18-17-46.log`): `PUT /api/user/profile` en `200`.
- Risque résiduel: incidents intermittents observés sur runs précédents.
- Cause probable:
  - mismatch de payload `profileDetails`,
  - doc Swagger inexacte (`profileDetails` string alors que backend attend objet typé).
- Attendu backend:
  - retour `400` avec message métier clair en cas de payload invalide,
  - pas de `500` générique.

## 3) `POST /api/user/profile/avatar` -> 500 intermittent
- Statut: **stabilisé sur le dernier run**.
- Dernier run (`docs/logs/console-export-2026-2-19_18-17-46.log`): uploads avatar en `200`.
- Risque résiduel: incidents intermittents observés sur runs précédents.
- Attendu backend:
  - `200` succès,
  - `400`/`413` en cas de format/taille invalide, avec message explicite.

## 4) `POST /api/user/profile/documents/{type}` -> 500 sur gros fichier
- Statut: **cause confirmée**.
- Log backend: `MaxUploadSizeExceededException`.
- Attendu backend:
  - handler dédié `MaxUploadSizeExceededException`,
  - code `413` (ou `400`) + message lisible pour UI.
- Observation complémentaire:
  - Run `00:45:8`: `POST /api/user/profile/documents/DRIVING_LICENSE` a aussi retourné un `500` hors scénario explicite de gros fichier (à investiguer backend).

## 5) Formats MIME
- Statut: **limitation connue**.
- Validator actuel: `jpeg/png/webp/pdf/doc/docx`.
- `xlsx` non supporté.
- Action backend requise si demandé métier: ajouter MIME Excel (`xls/xlsx`).

## 6) Navigation HATEOAS ReBAC
- Ancien problème: provider CGLIB.
- Statut actuel: **non reproduit sur dernier run**, à revalider sur scénario complet.

## 7) Contrat Swagger à corriger
- `PUT /api/user/profile` documente `profileDetails` comme `string`.
- Implémentation réelle attend un objet polymorphique (`type: PHYSICAL|MORAL` + champs dédiés).
- Action backend: corriger OpenAPI pour éviter les erreurs d’intégration.

## Priorité recommandée backend
1. Publier migration seed RBAC ADMIN complète (supprimer dépendance au hotfix local).  
2. Gérer proprement la taille upload (`413/400` au lieu de `500`).  
3. Mettre Swagger en phase avec le contrat réel (`profileDetails` polymorphique).

[⬅ Retour à la liste](./index.html)