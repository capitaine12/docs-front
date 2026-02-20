# Documentation ProEvalis (dossier `docs/`)

Ce dossier est publie via GitHub Pages et sert de reference de travail frontend/backend pour le module tenant.

## Fichiers principaux

- `index.md`: page d'entree publique
- `backend-needs-for-frontend.md`: backlog backend priorise pour debloquer le frontend
- `backend-bug-report-2026-02-19.md`: rapport detaille des bugs observes
- `qa-checklist-tenant-post-backend-fix.md`: recette QA pas-a-pas apres correctifs backend
- `frontend-implementation-handover.md`: etat de l'implementation frontend et points d'extension
- `backend-bug-report-whatsapp-2026-02-19.md`: version courte partage rapide

## Regles de mise a jour

1. Mettre a jour `index.md` si un document est ajoute/renomme.
2. Mettre a jour `backend-needs-for-frontend.md` a chaque changement de priorites backend.
3. Ajouter la preuve de chaque incident via un log dans `docs/logs/`.
4. Marquer explicitement ce qui est:
   - corrige localement,
   - corrige officiellement backend,
   - encore bloque.
5. Garder des dates explicites (`YYYY-MM-DD`) pour eviter les ambiguities.

## Publication GitHub Pages

- Source recommande: branche principale, dossier `/docs`.
- Theme Jekyll configure dans `_config.yml`.
- Les liens internes doivent cibler les pages `.html` pour compatibilite Pages.

