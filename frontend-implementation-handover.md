# ProEvalis Frontend - Handover Technique (Tenant)

Version: 2026-02-20  
Portee: module tenant uniquement (hors super-admin master)

## 1) Stack et regles

- React 19 (function components)
- TypeScript strict
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

## 3) RBAC et navigation

- Permissions gerees via store dedie.
- Menu dynamique charge via `GET /api/navigation`.
- Comportement UI conditionne par auth + permissions.

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
- `src/services/user/userService.ts`
- `src/services/project/projectService.ts`
- `src/hooks/projects/useProjects.ts`
- `src/pages/projects/AllProjectPage.tsx`
- `src/pages/projects/filesManagerPage.tsx`
- `src/pages/tasks/AssignedTasksPage.tsx`
- `src/lib/LinkItems.tsx`

## 6) Limites actuelles

- `403` intermittents sur `/api/projects` selon environnement RBAC.
- Upload document profil peut encore retourner `500` selon cas.
- Spec Swagger pas totalement alignee au comportement runtime.
- Endpoint dedie "mes taches" absent/non stabilise.

## 7) Prochaines etapes recommandees

1. Rejouer la checklist QA apres prochain push backend.
2. Mettre a jour ce handover si endpoint ou contrat change.
3. Finaliser modules Scrum/Management apres stabilisation tenant core.

Retour index: [index](./index.html)

