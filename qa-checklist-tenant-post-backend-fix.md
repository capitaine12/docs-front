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

# QA Checklist Tenant (après correctifs backend)

Date: 2026-02-19  
Contexte: validation frontend tenant avec backend local `http://localhost:8082`

## État rapide (dernier run: `docs/logs/console-export-2026-2-19_18-17-46.log`)
- `PUT /api/user/profile`: PASS (`200`)
- `POST /api/user/profile/avatar`: PASS (`200`)
- Documents profil upload/list/delete: PASS (`200/204`)
- 403 projets/admin: non observé sur ce run (après hotfix RBAC local)
- Point restant majeur: gestion dépassement taille upload (doit répondre `413/400`, pas `500`)

## État rapide (run suivant: `docs/logs/console-export-2026-2-20_0-45-8.log`)
- `PUT /api/user/profile`: PASS (`200`)
- `POST/DELETE /api/user/profile/avatar`: PASS (`200/204`)
- Documents: PARTIEL (un `POST .../DRIVING_LICENSE` en `500`)
- Projets: FAIL (`GET /api/projects` en `403` répété)

## Pré-requis
- Backend tenant lancé sur `8082`.
- Frontend lancé sur `3000`.
- Identifiants tenant valides.
- Variables frontend:
  - `VITE_TENANT_API_BASE_URL=http://localhost:8082/api`

## 1) Auth + bootstrap
1. Login.
2. Vérifier:
- `POST /api/auth/login` => 200
- `GET /api/public/identity` => 200
- `GET /api/navigation` => 200
3. Refresh page.
4. Vérifier `POST /api/auth/refresh-token` => 200 si access expiré.

## 2) Profil (payload réel)
1. Aller sur `/profile`.
2. Modifier prénom/nom/email/adresse.
3. Vérifier `PUT /api/user/profile` => 200 stable (pas de 500 intermittent).
4. Vérifier en backend que `profileDetails` est accepté avec structure typée (`type` + champs).

## 3) Avatar
1. Upload image `< 5MB`.
2. Vérifier `POST /api/user/profile/avatar` => 200 stable.
3. Supprimer avatar.
4. Vérifier `DELETE /api/user/profile/avatar` => 204.

## 4) Documents profil
1. Uploader fichiers types:
- `PASSPORT`
- `ID_CARD_FRONT`
- `RESIDENCE_PROOF`
2. Vérifier:
- `POST /api/user/profile/documents/{type}` => 200
- `GET /api/user/profile/documents` => 200
3. Télécharger/supprimer un document:
- download => 200
- delete => 204
4. Tester gros fichier (> limite):
- attendu backend: `413` ou `400` avec message clair (pas `500`).

## 5) Admin + projets
1. Aller sur `/dasboard/admin`.
2. Vérifier chargement liste users (pas de 403 backend).
3. Aller sur pages qui appellent `/api/projects`.
4. Vérifier absence de 403 pour utilisateur admin tenant.

## 6) Navigation HATEOAS
1. Vérifier `GET /api/navigation` => 200.
2. Vérifier absence d’erreur provider ReBAC dans logs backend.

## Critères de sortie
- Aucun `500` sur:
  - `PUT /api/user/profile`
  - `POST /api/user/profile/avatar`
  - upload documents (hors validation taille qui doit être 400/413)
- Aucun `403` sur `/api/projects` et `/api/admin/users` pour admin tenant.
- Contrat Swagger aligné avec payload réel `profileDetails`.

[⬅ Retour à la liste](./index.html)