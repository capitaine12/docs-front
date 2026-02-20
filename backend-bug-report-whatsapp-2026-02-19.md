# Rapport Court (Format Message) - Backend Tenant

Date: 2026-02-20  
Reference run: `20/02 00:45`

## Message de synthese

Bonjour, update QA local tenant:

1. Profil/avatar restent majoritairement OK (`200/204`).
2. Regression: `GET /api/projects` retombe en `403` (plusieurs occurrences).
3. Upload documents: `POST /api/user/profile/documents/DRIVING_LICENSE` retourne encore `500` (intermittent).
4. Cas gros fichier: attendu `413/400`, pas `500`.
5. Swagger `PUT /api/user/profile` reste incoherent (`profileDetails` string vs objet type attendu).
6. Migration RBAC ADMIN doit devenir officielle (pas de hotfix SQL manuel).
7. Swagger Documents Projet a aligner:
   - `DELETE /api/projects/{projectId}/documents` doc en `200`, runtime en `204`.
   - exemple `SPECIFICATIONS` non conforme a l'enum runtime (`SPECIFICATION`, `CONTRACT`, `INVOICE`, `REPORT`, `OTHER`).

Merci de pousser ces correctifs backend pour cloturer.

Retour index: [index](./index.html)

