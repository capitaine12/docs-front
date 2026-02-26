# Rapport Bugs Backend (Local) - Tenant

Periode couverte: 2026-02-19 -> 2026-02-26  
Contexte: frontend local (`3000`) contre backend tenant local (`8082`)

## Resume executif

- Des scenarios profil sont fonctionnels sur plusieurs runs (`200/204`).
- Trois points restent instables et bloquants:
  - erreur provider ReBAC sur génération des liens de navigation;
  - `403` intermittents sur `/api/projects` pour admin;
  - `500` sur upload document profil dans certains cas.

## Incidents suivis

## 1) Navigation ReBAC -> erreur provider CGLIB

- Endpoint impacté: `GET /api/navigation` (liens incomplets/instables).
- Preuve: `docs/logs/log-bakend.log`
- Erreur: `Failed to fetch links from provider RebacModuleLinkProvider: Could not generate CGLIB subclass ... RebacMetadataResponse`.
- Impact frontend: avec guards permissions stricts, certaines routes restent inaccessibles.
- Action backend requise:
  - corriger le provider ReBAC concerné;
  - garantir un payload navigation complet et stable.

## 2) ReBAC admin -> `403` sur projets

- Endpoint: `GET /api/projects`
- Etat: partiellement corrige localement, non stabilise globalement.
- Preuves:
  - run vert: `docs/logs/console-export-2026-2-19_18-17-46.log`
  - regression: `docs/logs/console-export-2026-2-20_0-45-8.log`
- Action backend requise:
  - migration officielle des permissions `ADMIN`;
  - verification sur base vierge.

## 3) Upload documents profil -> `500`

- Endpoint: `POST /api/user/profile/documents/{type}`
- Etat: non resolu.
- Cause confirmée pour de gros fichiers.
- Action backend requise:
  - transformer en reponse metier (`413`/`400`) + message clair;
  - corriger les cas intermittents hors taille.

## 4) `PUT /api/user/profile` -> instabilites passees

- Endpoint: `PUT /api/user/profile`
- Etat actuel: stable sur derniers runs (`200`).
- Risque: payload mal documente dans Swagger, pouvant recreer des erreurs d'integration.

## 5) `POST /api/user/profile/avatar` -> incidents passes

- Endpoint: `POST /api/user/profile/avatar`
- Etat actuel: operationnel sur derniers runs (`200`).
- Risque: a surveiller apres prochains changements backend stockage/auth.

## 6) Contrat Swagger incoherent

- `profileDetails` type incorrect dans la spec.
- Documents projet: exemples/reponses non alignes (`SPECIFICATION` vs `SPECIFICATIONS`, `204` vs `200`).
- Effet: erreurs de payload et integration fragile.

## Priorisation backend proposee

1. Corriger l'erreur CGLIB du provider ReBAC de navigation.
2. Stabiliser ReBAC admin sans hotfix manuel.
3. Corriger pipeline upload documents pour supprimer les `500` techniques.
4. Mettre la documentation OpenAPI en phase avec le runtime.

## References

- Besoins backend: `docs/backend-needs-for-frontend.md`
- Checklist QA: `docs/qa-checklist-tenant-post-backend-fix.md`


- Retour index: [index](./index.html)
