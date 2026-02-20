# Besoins Backend Pour Alignement Frontend (Tenant)

Date de reference: 2026-02-20  
Perimetre: environnement local (`frontend:3000`, `backend:8082`)

## Objectif

Lister uniquement ce que le backend doit encore livrer/corriger pour que le frontend tenant soit stable.

## 1) Priorite critique

### 1.1 RBAC admin non stable sur projets

- Symptom: `GET /api/projects` retourne parfois `403` pour un profil admin.
- Constate dans: `docs/logs/console-export-2026-2-20_0-45-8.log`.
- Impact frontend: pages projets/fichiers bloquees aleatoirement.
- Attendu backend:
  - seed/migration officielle des permissions `ADMIN`;
  - verification durable sur nouvel environnement (sans hotfix manuel).

### 1.2 Gestion upload documents en erreur serveur

- Symptom: `POST /api/user/profile/documents/{type}` retourne encore des `500` sur certains cas.
- Cause confirmee sur gros fichiers: `MaxUploadSizeExceededException`.
- Impact frontend: UX non maitrisable (erreur technique au lieu d'erreur metier).
- Attendu backend:
  - handler global -> `413` (ou `400`) avec message exploitable;
  - investigation des `500` intermittents hors depassement taille.

## 2) Priorite haute

### 2.1 Swagger/OpenAPI non aligne avec le contrat reel

- `PUT /api/user/profile`
  - Swagger documente `profileDetails` comme `string`.
  - API attend un objet type (`PHYSICAL`/`MORAL`) avec champs associes.
- Documents projet
  - Swagger indique `DELETE /api/projects/{projectId}/documents` -> `200`.
  - Backend renvoie `204`.
  - Swagger montre `SPECIFICATIONS`, backend attend `SPECIFICATION`.
- Attendu backend:
  - corriger la spec pour eviter les erreurs d'integration frontend.

### 2.2 Formats de fichiers metier

- Constate: `MimeTypeValidator` n'accepte pas `xls/xlsx`.
- Impact: certains uploads metier rejetes.
- Action attendue: confirmer le besoin produit et ajouter Excel si requis.

## 3) Priorite moyenne

### 3.1 Endpoint dedie "mes taches"

- Besoin frontend profil: liste fiable des taches assignees a l'utilisateur connecte.
- Recommandation backend: endpoint type `GET /api/tasks/my` (pagine + filtre).

### 3.2 Endpoints metier notifications / 2FA

- Statut: non exposes de facon exploitable pour le module tenant.
- Impact: frontend utilise encore des contournements (preferences integrees au profil).

## 4) Deja resolu localement (a officialiser backend)

- Hotfix SQL local applique: `docs/local-admin-rebac-hotfix.sql`.
- Ne doit pas rester une etape manuelle en QA/prod.

## 5) References

- Rapport detaille: `docs/backend-bug-report-2026-02-19.md`
- Checklist QA: `docs/qa-checklist-tenant-post-backend-fix.md`
- Contrat API exporte: `docs/api-docs.json`
- Retour index: [index](./index.html)

