-- Local DEV only: grant broad ReBAC permissions to admin@test.com
-- Usage:
--   cat docs/local-admin-rebac-full-dev.sql | docker exec -i proevalis_postgres psql -U postgres -d <tenant_db_name>
-- Notes:
--   - Idempotent (safe to re-run)
--   - Do not use as-is in production

BEGIN;

-- 1) Ensure user exists
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'admin@test.com') THEN
    RAISE EXCEPTION 'User admin@test.com not found in this tenant database';
  END IF;
END $$;

-- 2) Ensure ADMIN role exists
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM roles WHERE name = 'ADMIN') THEN
    INSERT INTO roles (name, description, is_system_role, scope)
    VALUES ('ADMIN', 'System Administrator - Full Access (DEV)', TRUE, 'TENANT');
  END IF;
END $$;

-- 3) Ensure admin@test.com is linked to ADMIN relation on TENANT
WITH admin_user AS (
  SELECT id
  FROM users
  WHERE email = 'admin@test.com'
  LIMIT 1
),
tenant_root AS (
  SELECT COALESCE(
    (SELECT object_id FROM relationships WHERE object_type = 'TENANT' LIMIT 1),
    '00000000-0000-0000-0000-000000000000'::uuid
  ) AS object_id
)
INSERT INTO relationships (subject_id, subject_type, relation, object_id, object_type, created_at)
SELECT u.id, 'USER', 'ADMIN', t.object_id, 'TENANT', NOW()
FROM admin_user u
CROSS JOIN tenant_root t
WHERE NOT EXISTS (
  SELECT 1
  FROM relationships r
  WHERE r.subject_id = u.id
    AND r.subject_type = 'USER'
    AND r.relation = 'ADMIN'
    AND r.object_type = 'TENANT'
);

-- 4) Grant full supported matrix to ADMIN role (TENANT/USER/PROJECT/TASK/ROLE/GROUP)
WITH admin_role AS (
  SELECT id
  FROM roles
  WHERE name = 'ADMIN'
  LIMIT 1
)
INSERT INTO role_matrix (role_id, resource_type, action)
SELECT ar.id, p.resource_type, p.action
FROM admin_role ar
CROSS JOIN (
  VALUES
    -- TENANT
    ('TENANT', 'READ'),
    ('TENANT', 'UPDATE'),
    ('TENANT', 'MANAGE_ACCESS'),
    ('TENANT', 'DOWNLOAD'),

    -- USER
    ('USER', 'READ'),
    ('USER', 'UPDATE'),
    ('USER', 'MANAGE_ACCESS'),

    -- PROJECT
    ('PROJECT', 'READ'),
    ('PROJECT', 'CREATE'),
    ('PROJECT', 'UPDATE'),
    ('PROJECT', 'DELETE'),
    ('PROJECT', 'MANAGE_ACCESS'),
    ('PROJECT', 'DOWNLOAD'),

    -- TASK
    ('TASK', 'READ'),
    ('TASK', 'UPDATE'),
    ('TASK', 'DELETE'),
    ('TASK', 'APPROVE'),
    ('TASK', 'EXECUTE'),

    -- ROLE
    ('ROLE', 'READ'),
    ('ROLE', 'CREATE'),
    ('ROLE', 'UPDATE'),
    ('ROLE', 'DELETE'),

    -- GROUP
    ('GROUP', 'READ'),
    ('GROUP', 'CREATE'),
    ('GROUP', 'UPDATE'),
    ('GROUP', 'DELETE'),
    ('GROUP', 'MANAGE_ACCESS')
) AS p(resource_type, action)
WHERE NOT EXISTS (
  SELECT 1
  FROM role_matrix rm
  WHERE rm.role_id = ar.id
    AND rm.resource_type = p.resource_type
    AND rm.action = p.action
);

COMMIT;

-- Verification 1: relation link
-- SELECT subject_id, subject_type, relation, object_id, object_type
-- FROM relationships
-- WHERE subject_id = (SELECT id FROM users WHERE email='admin@test.com')
--   AND relation = 'ADMIN';

-- Verification 2: ADMIN matrix
-- SELECT resource_type, action
-- FROM role_matrix rm
-- JOIN roles r ON r.id = rm.role_id
-- WHERE r.name = 'ADMIN'
-- ORDER BY resource_type, action;
