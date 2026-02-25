---
layout: default
title: ProEvalis Tenant Docs
---

# ProEvalis - Documentation Tenant

Cette page centralise la documentation de suivi entre le frontend et le backend tenant.

## Acces rapide

- [Besoins backend pour le frontend](./backend-needs-for-frontend.html)
- [Rapport de bugs backend](./backend-bug-report-2026-02-19.html)
- [Checklist QA post-correctifs backend](./qa-checklist-tenant-post-backend-fix.html)
- [Handover implementation frontend](./frontend-implementation-handover.html)


## Statut actuel (2026-02-20)

- Profil utilisateur: majoritairement fonctionnel (update, avatar, documents) avec incidents intermittents selon les runs.
- ReBAC admin local: corrige localement via SQL, a officialiser via migration backend.
- Projets: des retours `403` reapparaissent selon l'environnement/runs.
- Upload documents: gestion des erreurs de taille/type a stabiliser cote backend.
- Swagger/OpenAPI: plusieurs ecarts avec l'implementation reelle.

## Ordre de lecture recommande

1. Lire `backend-needs-for-frontend` pour la vue decisionnelle.
2. Lire `backend-bug-report` pour le detail technique et les preuves.
3. Executer `qa-checklist-tenant-post-backend-fix` apres un nouveau push backend.
4. Utiliser `frontend-implementation-handover` pour onboard un nouveau developpeur frontend.

## Sources annexes

- Logs: `docs/logs/`
- Hotfix local ReBAC: `docs/local-admin-rebac-hotfix.sql`
- Contrat API exporte: `docs/api-docs.json`
