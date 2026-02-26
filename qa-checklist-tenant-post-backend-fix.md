# QA Checklist Tenant (Apres Correctifs Backend)

Version: 2026-02-26  
Usage: valider rapidement qu'un nouveau push backend n'a pas casse le frontend tenant.

## Pre-requis

- Backend tenant demarre sur `http://localhost:8082`
- Frontend demarre sur `http://localhost:3000`
- Variable frontend: `VITE_TENANT_API_BASE_URL=http://localhost:8082/api`
- Compte admin tenant valide

## Scenario A - Auth et bootstrap

1. Se connecter.
2. Verifier en reseau:
   - `POST /api/auth/login` -> `200`
   - `GET /api/public/identity` -> `200`
   - `GET /api/navigation` -> `200`
3. Verifier que la reponse `GET /api/navigation` contient les liens attendus (pas seulement un lien partiel).
   - minimum attendu pour admin: liens vers users/projets/roles/groupes selon ReBAC.
4. Recharger la page.
5. Verifier refresh session si besoin:
   - `POST /api/auth/refresh-token` -> `200` (quand access token expire)

## Scenario B - Profil utilisateur

1. Ouvrir `/profile`.
2. Modifier des champs personnels.
3. Verifier:
   - `PUT /api/user/profile` -> `200`
   - aucune erreur console frontend

## Scenario C - Avatar

1. Uploader une image valide (< 5MB, jpg/png/webp).
2. Verifier `POST /api/user/profile/avatar` -> `200`.
3. Supprimer l'avatar.
4. Verifier `DELETE /api/user/profile/avatar` -> `204`.

## Scenario D - Documents profil

1. Uploader des documents standards:
   - `PASSPORT`
   - `ID_CARD_FRONT`
   - `RESIDENCE_PROOF`
2. Verifier:
   - `POST /api/user/profile/documents/{type}` -> `200`
   - `GET /api/user/profile/documents` -> `200`
3. Tester suppression document:
   - `DELETE /api/user/profile/documents/{documentId}` -> `204`
4. Tester depassement taille:
   - attendu: `413` ou `400` metier (et non `500`)

## Scenario E - Projets et admin

1. Aller sur `/dasboard/admin` et `/dasboard/allProject`.
2. Verifier absence de `403` sur:
   - `GET /api/admin/users`
   - `GET /api/projects`
3. Si une route reste bloquee avec frontend authentifie, verifier backend log:
   - erreur `HateoasDiscoveryService` / `RebacModuleLinkProvider` / CGLIB.

## Critere de validation globale

- Aucun `500` sur endpoints profil standards.
- Aucun `403` sur endpoints admin/projets pour role `ADMIN`.
- Les erreurs metier (taille, type fichier) retournent des statuts explicites (`400`/`413`).

## Sortie et preuves

- Archiver un log navigateur dans `docs/logs/`.
- En cas d'echec, ouvrir ou mettre a jour:
  - `docs/backend-bug-report-2026-02-19.md`
  - `docs/backend-needs-for-frontend.md`

Retour index: [index](./index.html)
