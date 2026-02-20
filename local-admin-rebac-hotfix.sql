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
