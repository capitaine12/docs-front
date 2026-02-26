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

Date: 2026-02-26  
Périmètre: module tenant local (`frontend:3000`, `backend:8082`)

## Nouveau blocage observé (2026-02-26)
1. Navigation HATEOAS partielle à cause d'une erreur provider ReBAC  
- Log backend: `Failed to fetch links from provider RebacModuleLinkProvider: Could not generate CGLIB subclass ... RebacMetadataResponse`.
- Impact frontend: avec les nouveaux guards permissions, si `/api/navigation` ne renvoie pas tous les liens attendus, l'utilisateur peut rester limité à la page profil.
- Action backend: corriger le provider `RebacModuleLinkProvider` (CGLIB/final DTO) pour restaurer une navigation complète et stable.

## Résolu (local uniquement)
1. Permissions `ADMIN` insuffisantes (403 sur projets/admin users)  
- Corrigé localement via `docs/local-admin-rebac-hotfix.sql` (voir en bas).  
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
- Erreur provider CGLIB reproduite sur `docs/logs/log-bakend.log` (2026-02-26).
- Action: fix backend + revalidation run complet (login -> navigation -> admin -> profile).

2. Endpoint tâches utilisateur  
- Toujours pas d’endpoint clair "mes tâches affectées" pour onglet profil tâches.
- Besoin recommandé: `GET /api/tasks/my` (paginé/filtrable).

3. Notifications / 2FA  
- Endpoints non disponibles côté tenant pour implémentation complète.

## Références
- Rapport détaillé: `docs/backend-bug-report-2026-02-19.md`
- Checklist QA: `docs/qa-checklist-tenant-post-backend-fix.md`
- Hotfix local ReBAC (matrice roles/permissions): `docs/local-admin-rebac-hotfix.sql`
- Hotfix local ReBAC complet (mode dev): `docs/local-admin-rebac-full-dev.sql`

## local-admin-rebac-hotfix.sql

```SQL
-- Local hotfix (QA only) for tenant ADMIN permissions.
-- Purpose: unblock frontend tests when ADMIN receives only TENANT:MANAGE_ACCESS.
-- Scope: local/dev only. Do not apply in production as-is.

BEGIN;

WITH admin_role AS (
  SELECT id
  FROM roles
  WHERE name = 'ADMIN'
)
INSERT INTO role_matrix (role_id, resource_type, action)
SELECT ar.id, p.resource_type, p.action
FROM admin_role ar
CROSS JOIN (
  VALUES
    -- Tenant
    ('TENANT', 'READ'),
    ('TENANT', 'UPDATE'),
    ('TENANT', 'MANAGE_ACCESS'),
    ('TENANT', 'DOWNLOAD'),

    -- User admin screens
    ('USER', 'READ'),
    ('USER', 'UPDATE'),
    ('USER', 'MANAGE_ACCESS'),

    -- Project dashboard and files
    ('PROJECT', 'READ'),
    ('PROJECT', 'CREATE'),
    ('PROJECT', 'UPDATE'),
    ('PROJECT', 'DELETE'),
    ('PROJECT', 'MANAGE_ACCESS'),
    ('PROJECT', 'DOWNLOAD'),

    -- Role management screens
    ('ROLE', 'READ'),
    ('ROLE', 'CREATE'),
    ('ROLE', 'UPDATE'),
    ('ROLE', 'DELETE')
) AS p(resource_type, action)
WHERE NOT EXISTS (
  SELECT 1
  FROM role_matrix rm
  WHERE rm.role_id = ar.id
    AND rm.resource_type = p.resource_type
    AND rm.action = p.action
);

COMMIT;

-- Verification query:
-- SELECT resource_type, action
-- FROM role_matrix rm
-- JOIN roles r ON r.id = rm.role_id
-- WHERE r.name = 'ADMIN'
-- ORDER BY resource_type, action;


```


[⬅ Retour à la liste](./index.html)
