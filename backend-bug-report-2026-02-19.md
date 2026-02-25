# Rapport Bugs Backend (Local) - Tenant

Periode couverte: 2026-02-19 -> 2026-02-20  
Contexte: frontend local (`3000`) contre backend tenant local (`8082`)

## Resume executif

- Des scenarios profil sont fonctionnels sur plusieurs runs (`200/204`).
- Deux points restent instables et bloquants:
  - `403` intermittents sur `/api/projects` pour admin;
  - `500` sur upload document profil dans certains cas.

## Incidents suivis

## 1) ReBAC admin -> `403` sur projets

- Endpoint: `GET /api/projects`
- Etat: partiellement corrige localement, non stabilise globalement.
- Preuves:
  - run vert: `docs/logs/console-export-2026-2-19_18-17-46.log`
  - regression: `docs/logs/console-export-2026-2-20_0-45-8.log`
- Action backend requise:
  - migration officielle des permissions `ADMIN`;
  - verification sur base vierge.

## 2) Upload documents profil -> `500`

- Endpoint: `POST /api/user/profile/documents/{type}`
- Etat: non resolu.
- Cause confirmee pour gros fichier: `MaxUploadSizeExceededException`.
- Action backend requise:
  - transformer en reponse metier (`413`/`400`) + message clair;
  - corriger les cas intermittents hors taille.

## 3) `PUT /api/user/profile` -> instabilites passees

- Endpoint: `PUT /api/user/profile`
- Etat actuel: stable sur derniers runs (`200`).
- Risque: payload mal documente dans Swagger, pouvant recreer des erreurs d'integration.

## 4) `POST /api/user/profile/avatar` -> incidents passes

- Endpoint: `POST /api/user/profile/avatar`
- Etat actuel: operationnel sur derniers runs (`200`).
- Risque: a surveiller apres prochains changements backend stockage/auth.

## 5) Contrat Swagger incoherent

- `profileDetails` type incorrect dans la spec.
- Documents projet: exemples/reponses non alignes (`SPECIFICATION` vs `SPECIFICATIONS`, `204` vs `200`).
- Effet: erreurs de payload et integration fragile.

## Priorisation backend proposee

1. Stabiliser ReBAC admin sans hotfix manuel.
2. Corriger pipeline upload documents pour supprimer les `500` techniques.
3. Mettre la documentation OpenAPI en phase avec le runtime.

## References

- Besoins backend: `docs/backend-needs-for-frontend.md`
- Checklist QA: `docs/qa-checklist-tenant-post-backend-fix.md`
- Retour index: [index](./index.html)
