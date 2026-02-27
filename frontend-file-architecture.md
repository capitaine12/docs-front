# Frontend File Architecture (Tenant)

Date: 2026-02-26

## Objectif

Préparer une architecture modulaire sans casser le fonctionnement actuel, en attendant les correctifs backend.

## Direction cible

- `src/features/*`: logique métier par domaine (auth, access-control, profile, projects, etc.)
- `src/components/*`: UI réutilisable
- `src/pages/*`: composition page
- `src/routes/*`: routing + guards
- `src/services/*`: clients API par domaine
- `src/store/*`: états globaux (auth/tenant/permissions)

## Refactor déjà appliqué (phase non risquée)

Nouveau domaine:
- `src/features/access-control/navigation-permissions.ts`
- `src/features/access-control/permissions.ts`
- `src/features/access-control/route-guards.ts`
- `src/features/access-control/navigation-service.ts`
- `src/features/access-control/useNavigationPermissions.ts`

Socle applicatif introduit:
- `src/app/providers/AppProviders.tsx`
- `src/app/providers/QueryProvider.tsx`
- `src/app/providers/AuthProvider.tsx`
- `src/app/providers/TenantProvider.tsx`
- `src/app/providers/RBACProvider.tsx`
- `src/app/guards/AuthGuard.tsx`
- `src/app/guards/TenantGuard.tsx`
- `src/app/guards/PermissionGuard.tsx`
- `src/app/layouts/PublicLayout.tsx`
- `src/app/layouts/AuthLayout.tsx`
- `src/app/layouts/AdminLayout.tsx`
- `src/app/layouts/ClientLayout.tsx`
- `src/app/layouts/ProjectLayout.tsx`

Domaines introduits (phase 1):
- `src/domains/auth/{api,hooks,store,types,index.ts}`
- `src/domains/tenant/{api,hooks,store,types,index.ts}`
- `src/domains/users/{api,hooks,types,index.ts}`
- `src/domains/roles/{api,hooks,types,index.ts}`
- `src/domains/projects/{api,hooks,types,index.ts}`
- `src/domains/dashboard/{admin,management}`
- `src/domains/scrum/{api,hooks,types,components,pages,index.ts}`
- `src/domains/finance/{api,hooks,types,components,index.ts}` (scaffold)
- `src/domains/evaluation/{api,hooks,types,components,index.ts}` (scaffold)
- Certains fichiers ont commencé en façades/re-exports pour migrer sans rupture, puis ont été supprimés après migration complète des imports.

Migration physique déjà faite:
- `authService`, `useAuthStore`, `useLogin`, `useLogout`, `useForgotPassword`, `useResetPassword` vivent maintenant dans `src/domains/auth/*`.
- `tenantService`, `useTenantIdentity`, `useTenantStore` vivent maintenant dans `src/domains/tenant/*`.
- `userService` et `useMyProfile` (et hooks associés: update profile/password, documents, avatar) vivent maintenant dans `src/domains/users/*`.
- `projectService`, `useProjects` et `projectDocumentTypes` vivent maintenant dans `src/domains/projects/*`.
- Les types Projects sont structurés dans:
- `src/domains/projects/types/project.types.ts`
- `src/domains/projects/types/document.types.ts`
- Les types Users sont structurés dans:
- `src/domains/users/types/profile.types.ts`
- `src/domains/users/types/document.types.ts`
- Les types Roles sont structurés dans:
- `src/domains/roles/types/rebac.types.ts`
- Les types Tenant sont structurés dans:
- `src/domains/tenant/types/tenant.types.ts`
- `rebacService` et `useRebacSchema` vivent maintenant dans `src/domains/roles/*`.
- `useDashboard` et `useGantt` (management) vivent maintenant dans `src/domains/dashboard/management/hooks/*`.
- Pages dashboard déplacées dans `src/domains/dashboard/*/pages/*` (`DashboardAdminPage`, `RolePermissionPage`, `DashboardManagementPage`).
- `ScrumBoardPage` déplacée dans `src/domains/scrum/pages/ScrumBoardPage.tsx` et route TanStack mise à jour.
- `useScrumBoard` + `scrumService` introduits pour séparer UI/état/données et préparer le branchement API backend.
- Les types Scrum sont désormais exposés via `src/domains/scrum/types/scrumTypes.ts` pour éviter les imports directs dispersés vers `src/types/types.tsx`.
- `src/lib/dashboard.selectors.ts` consomme maintenant les types via `domains/scrum/types`.
- `src/context/ProjectContext.tsx` (non utilisé) a été retiré pour éviter un état global redondant.
- Les définitions Scrum/dashboard ont été déplacées dans `src/domains/scrum/types/scrumTypes.ts`.
- Les types sont maintenant scindés en:
- `src/domains/scrum/types/board.types.ts` (board, cards, members, statuses)
- `src/domains/scrum/types/dashboard.types.ts` (task stats, budget, gantt)
- `src/domains/scrum/types/scrumTypes.ts` reste le point d'entrée de compatibilité.
- `src/types/types.ts` est conservé comme point de compatibilité (re-export des types Scrum).
- Les anciens chemins legacy (auth, tenant, users, projects, roles, dashboard manager hooks, pages admin/management) ont été retirés après migration des imports.

Routing TanStack conserve:
- `src/routes/*` reste file-based (aucune rupture d'architecture TanStack).
- `src/router.tsx` utilise maintenant `AppProviders` sans modifier la route tree.

Compatibilité conservée:
- `src/lib/navigation-permissions.ts` -> re-export vers `features/access-control`
- `src/lib/permissions.ts` -> re-export vers `features/access-control`
- `src/lib/route-guards.ts` -> re-export vers `features/access-control`

## Pourquoi ce choix

- Aucun changement de comportement runtime.
- Migration incrémentale réalisée fichier par fichier.
- Réduction de la dette technique en supprimant les doublons legacy.
- Le chargement des permissions de navigation est centralisé dans `features/access-control`.

## Prochaine phase proposée

1. Continuer la migration par domaine pour les modules restants (scrum, finance, evaluation).
2. Remplacer progressivement les mocks dashboard par des appels API réels quand les endpoints backend sont disponibles.
3. Stabiliser les tests de non-régression sur routing/guards/permissions.

Retour index: [index](./index.html)
