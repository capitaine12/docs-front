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

# Besoins Backend Pour Alignement Frontend (Tenant)

Date: 2026-02-19  
Périmètre: module tenant local (`frontend:3000`, `backend:8082`)

## Résolu (local uniquement)
1. Permissions `ADMIN` insuffisantes (403 sur projets/admin users)  
- Corrigé localement via `docs/local-admin-rebac-hotfix.sql`.  
- Vérifié en DB: `ADMIN` a maintenant `PROJECT:READ`, `USER:READ`, etc.
- À faire côté backend: intégrer ce correctif dans migration seed officielle (`V1__init_tenant.sql` ou migration dédiée), pour éviter le patch manuel.

## Validé sur run vert (console `18:17:46`)
1. `PUT /api/user/profile` => `200`
2. `POST /api/user/profile/avatar` => `200`
3. `POST/GET/DELETE /api/user/profile/documents...` => `200/204`
4. Pas de `403` visible sur les flux profil/admin testés

## Régression observée (console `2026-2-20_0-45-8`)
1. `GET /api/projects` -> `403` répété en fin de run.
2. `POST /api/user/profile/documents/DRIVING_LICENSE` -> `500` (intermittent).

## Reste à corriger côté backend
1. Upload documents: dépassement taille -> `500` actuel  
- Log confirmé: `MaxUploadSizeExceededException`.
- Attendu: `413 Payload Too Large` (ou `400`) avec message clair.
- Besoin: handler dédié + message API stable.
 - Complément: investiguer les `500` intermittents upload document hors dépassement taille.

2. Contrat Swagger incohérent pour `PUT /api/user/profile`  
- Swagger montre `profileDetails: "string"`.
- Implémentation réelle attend un objet polymorphique avec `type` (`PHYSICAL`/`MORAL`) + structure dédiée.
- Besoin: corriger la doc OpenAPI pour refléter le contrat réel.

3. Limites de formats documents (métier)  
- `MimeTypeValidator` accepte: `jpeg/png/webp/pdf/doc/docx`.
- `xlsx` non supporté actuellement.
- Besoin: ajouter `xls/xlsx` si requis produit.

4. Alignement Swagger vs implémentation — Documents Projet  
- Endpoints backend existent et sont implémentés:
  - `GET /api/projects/{projectId}/documents`
  - `POST /api/projects/{projectId}/documents`
  - `DELETE /api/projects/{projectId}/documents`
  - `POST /api/projects/{projectId}/documents/url`
- Écarts constatés:
  - Swagger annonce `DELETE .../documents` en `200`, le backend renvoie `204`.
  - Swagger donne l'exemple `SPECIFICATIONS`, alors que l'enum backend attend `SPECIFICATION` (singulier), puis `CONTRACT`, `INVOICE`, `REPORT`, `OTHER`.
- Besoin: corriger Swagger pour refléter le contrat réel.

## À clarifier backend
1. Navigation HATEOAS ReBAC  
- Anciennement: erreur provider CGLIB observée.
- Dernier run: non reproduit.
- Action: revalidation backend sur run complet (login -> navigation -> admin -> profile).

2. Endpoint tâches utilisateur  
- Toujours pas d’endpoint clair "mes tâches affectées" pour onglet profil tâches.
- Besoin recommandé: `GET /api/tasks/my` (paginé/filtrable).

3. Notifications / 2FA  
- Endpoints non disponibles côté tenant pour implémentation complète.

## Références
- Rapport détaillé: `docs/backend-bug-report-2026-02-19.md`
- Checklist QA: `docs/qa-checklist-tenant-post-backend-fix.md`
- Hotfix local RBAC: `docs/local-admin-rebac-hotfix.sql`
