# ProEvalis Frontend - Handover Technique (Tenant)

Version: 2026-02-26  
Portee: module tenant

Mise a jour: 2026-02-28
- Architecture migree vers `src/domains/*` (anciens wrappers `src/services/*`, `src/hooks/*` supprimes).
- Pipeline CI frontend en Yarn active (`.github/workflows/frontend-ci.yml`).
- Suite tests locale actuelle: 9 fichiers / 23 tests verts.

## 1) Stack et regles

- React 19 (function components)
- TypeScript 
- TanStack Router (file-based)
- TanStack Query
- Zustand (auth + etats globaux tenant/permissions)
- Tailwind CSS

## 2) Auth, session, tenant

- Access token garde en memoire et injecte dans `Authorization`.
- Refresh token HttpOnly via `POST /api/auth/refresh-token`.
- Header multi-tenant requis: `X-Tenant-ID`.
- Resolution tenant via `GET /api/public/identity`.
- Guard global routes protegees sur `src/routes/_protected.tsx`.

## 3) ReBAC et navigation

- Permissions gerees via store dedie.
- Menu dynamique charge via `GET /api/navigation`.
- Comportement UI conditionne par auth + permissions.
- Guards routes factorises via `src/lib/route-guards.ts` (`requireAuthAndPermission`).

## 4) Modules frontend deja branches

## Profil utilisateur

- Route: `/profile`
- Endpoints utilises:
  - `GET /api/user/profile`
  - `PUT /api/user/profile`
  - `PUT /api/user/profile/password`
  - `POST /api/user/profile/avatar`
  - `DELETE /api/user/profile/avatar`
  - `POST /api/user/profile/documents/{type}`
  - `GET /api/user/profile/documents`
  - `GET /api/user/profile/documents/{documentId}/download`
  - `DELETE /api/user/profile/documents/{documentId}`

## Projets / fichiers / taches

- Liste projets: `/dasboard/allProject` -> `GET /api/projects`
- Fichiers projet: `/files/filesManager`
  - `GET /api/projects/{projectId}/documents`
  - `POST /api/projects/{projectId}/documents`
  - `DELETE /api/projects/{projectId}/documents`
  - `POST /api/projects/{projectId}/documents/url`
- Taches: `/tasks` (depend de la disponibilite backend)

## 5) Fichiers frontend principaux

- `src/pages/user/ProfilePage.tsx`
- `src/components/profile/ProfilePersonalInfoSection.tsx`
- `src/components/profile/ProfileDocumentsSection.tsx`
- `src/components/profile/ProfileSecuritySection.tsx`
- `src/components/profile/ProfileNotificationsSection.tsx`
- `src/domains/users/api/userService.ts`
- `src/domains/projects/api/projectService.ts`
- `src/domains/projects/hooks/useProjects.ts`
- `src/domains/auth/*`
- `src/domains/tenant/*`
- `src/domains/roles/*`
- `src/domains/scrum/*`
- `src/pages/projects/AllProjectPage.tsx`
- `src/pages/projects/filesManagerPage.tsx`
- `src/pages/tasks/AssignedTasksPage.tsx`
- `src/lib/LinkItems.tsx`
- `src/features/access-control/permissions.ts`
- `src/features/access-control/route-guards.ts`

## 6) Limites actuelles

- `403` intermittents sur `/api/projects` selon environnement ReBAC.
- erreur backend CGLIB `RebacModuleLinkProvider` observee dans `docs/logs/log-bakend.log`, pouvant renvoyer une navigation partielle.
- compte `admin@test.com` pas encore pleinement autorise en projets/files/scrum selon run backend actuel.
- Upload document profil peut encore retourner `500` selon cas.
- Spec Swagger pas totalement alignee au comportement runtime.
- Endpoint dedie "mes taches" absent/non stabilise.

## 7) Prochaines etapes recommandees

1. Rejouer la checklist QA apres prochain push backend.
2. Appliquer `docs/local-admin-rebac-full-dev.sql` en local pour debloquer les tests admin si necessaire.
3. Mettre a jour ce handover si endpoint ou contrat change.
4. Finaliser modules Scrum/Management apres stabilisation tenant core.

Retour index: [index](./index.html)
