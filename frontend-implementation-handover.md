# ProEvalis Frontend - Handover Technique

Date: 2026-02-12
Portée: module tenant uniquement (pas super-admin master)

## 1) Stack et conventions
- React 19 + TypeScript strict.
- TanStack Router (file-based).
- TanStack Query.
- Zustand (auth et états transverses tenant/permissions).
- API tenant via `VITE_TENANT_API_BASE_URL`.

## 2) Auth, session et tenant
- Access token en mémoire + injection `Authorization` via `setAccessToken`.
- Refresh token HttpOnly avec `POST /api/auth/refresh-token` (intercepteur Axios sur 401).
- Guard global des routes protégées: `src/routes/_protected.tsx`.
- Résolution identité tenant via `GET /api/public/identity`.
- Header multi-tenant injecté: `X-Tenant-ID`.

## 3) RBAC / navigation
- Schéma ReBAC chargé côté frontend (base prête).
- Permissions stockées dans store dédié.
- Bootstrap navigation via endpoint dynamique `GET /api/navigation`.

## 4) Profil utilisateur (aligné Swagger)
### Route
- `/profile` (route protégée)

### Endpoints utilisés
- `GET /api/user/profile`
- `PUT /api/user/profile`
- `PUT /api/user/profile/password`
- `POST /api/user/profile/documents/{type}`
- `GET /api/user/profile/documents`
- `GET /api/user/profile/documents/{documentId}/download`
- `DELETE /api/user/profile/documents/{documentId}`
- `POST /api/user/profile/avatar`
- `DELETE /api/user/profile/avatar`

### UI modulaire implémentée
- `ProfilePersonalInfoSection`
  - infos personnelles
  - téléphone avec indicatif/pays (select drapeau + code)
  - détection pays depuis saisie internationale (`+...`)
  - pays en select drapeau + nom
- `ProfileDocumentsSection`
  - upload/liste/suppression/téléchargement documents profil
- `ProfileSecuritySection`
  - changement mot de passe
  - choix 2FA unique (radio)
- `ProfileNotificationsSection`
  - préférences sauvegardées dans `profileDetails` (fallback en attendant endpoints dédiés)

## 5) Projets, tâches, fichiers utilisateur
### Projets
- Page `dasboard/allProject` branchée sur `GET /api/projects`.

### Fichiers projet
- Page `files/filesManager` branchée sur:
  - `GET /api/projects/{projectId}/documents`
  - `POST /api/projects/{projectId}/documents`
  - `DELETE /api/projects/{projectId}/documents`
  - `POST /api/projects/{projectId}/documents/url`

### Tâches
- Route `/tasks` ajoutée.
- Affichage actuel dépend des données exposées par projets.
- Endpoint "mes tâches" dédié non disponible dans Swagger partagé.

## 6) Endpoints Swagger confirmés mais non encore branchés partout
- Administration utilisateurs:
  - `GET/POST /api/admin/users`
  - `PUT/DELETE /api/admin/users/{userId}`
  - rôles/permissions par user
  - export excel
- Groupes:
  - CRUD groupes + membres + assignations
- Catégories:
  - `GET/POST /api/categories`, `DELETE /api/categories/{id}`
- ReBAC metadata:
  - `GET /api/rebac/metadata/schema`
  - `GET /api/rebac/metadata/schema/{scope}`
- Paiement:
  - `POST /api/payments/initiate`

## 7) Fichiers frontend principaux touchés
- `src/pages/user/ProfilePage.tsx`
- `src/components/profile/ProfilePersonalInfoSection.tsx`
- `src/components/profile/ProfileDocumentsSection.tsx`
- `src/components/profile/ProfileSecuritySection.tsx`
- `src/components/profile/ProfileNotificationsSection.tsx`
- `src/components/profile/ProfileSidebar.tsx`
- `src/components/profile/countries.ts`
- `src/services/user/userService.ts`
- `src/services/project/projectService.ts`
- `src/hooks/projects/useProjects.ts`
- `src/pages/projects/AllProjectPage.tsx`
- `src/pages/projects/filesManagerPage.tsx`
- `src/pages/tasks/AssignedTasksPage.tsx`
- `src/routes/_protected/tasks.tsx`
- `src/routes/_protected/files/filesManager.tsx`
- `src/lib/LinkItems.tsx`

## 8) Points ouverts / risques
- Avatar: `401` encore observé sur upload/suppression à traiter backend.
- Notifications et 2FA: endpoints métier dédiés non exposés dans Swagger partagé.
- Tâches utilisateur: endpoint dédié requis pour un affichage fiable.
- Modules Scrum/Management: migration des mocks reportée (à faire plus tard, comme convenu).
