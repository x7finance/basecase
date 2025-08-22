-- InstantDB Schema Migration for Basecase App
-- App ID: 3f44e818-bbda-49ac-bce4-9e0af53827f8

-- Create idents first (these are attribute identifiers)
INSERT INTO idents (id, app_id, etype, label) VALUES
-- users entity
(gen_random_uuid(), '3f44e818-bbda-49ac-bce4-9e0af53827f8', 'users', 'id'),
(gen_random_uuid(), '3f44e818-bbda-49ac-bce4-9e0af53827f8', 'users', 'email'),
(gen_random_uuid(), '3f44e818-bbda-49ac-bce4-9e0af53827f8', 'users', 'name'),
(gen_random_uuid(), '3f44e818-bbda-49ac-bce4-9e0af53827f8', 'users', 'emailVerified'),
(gen_random_uuid(), '3f44e818-bbda-49ac-bce4-9e0af53827f8', 'users', 'image'),
(gen_random_uuid(), '3f44e818-bbda-49ac-bce4-9e0af53827f8', 'users', 'createdAt'),
(gen_random_uuid(), '3f44e818-bbda-49ac-bce4-9e0af53827f8', 'users', 'updatedAt'),

-- sessions entity
(gen_random_uuid(), '3f44e818-bbda-49ac-bce4-9e0af53827f8', 'sessions', 'id'),
(gen_random_uuid(), '3f44e818-bbda-49ac-bce4-9e0af53827f8', 'sessions', 'token'),
(gen_random_uuid(), '3f44e818-bbda-49ac-bce4-9e0af53827f8', 'sessions', 'expiresAt'),
(gen_random_uuid(), '3f44e818-bbda-49ac-bce4-9e0af53827f8', 'sessions', 'ipAddress'),
(gen_random_uuid(), '3f44e818-bbda-49ac-bce4-9e0af53827f8', 'sessions', 'userAgent'),
(gen_random_uuid(), '3f44e818-bbda-49ac-bce4-9e0af53827f8', 'sessions', 'userId'),
(gen_random_uuid(), '3f44e818-bbda-49ac-bce4-9e0af53827f8', 'sessions', 'createdAt'),
(gen_random_uuid(), '3f44e818-bbda-49ac-bce4-9e0af53827f8', 'sessions', 'updatedAt'),

-- accounts entity
(gen_random_uuid(), '3f44e818-bbda-49ac-bce4-9e0af53827f8', 'accounts', 'id'),
(gen_random_uuid(), '3f44e818-bbda-49ac-bce4-9e0af53827f8', 'accounts', 'accountId'),
(gen_random_uuid(), '3f44e818-bbda-49ac-bce4-9e0af53827f8', 'accounts', 'providerId'),
(gen_random_uuid(), '3f44e818-bbda-49ac-bce4-9e0af53827f8', 'accounts', 'userId'),
(gen_random_uuid(), '3f44e818-bbda-49ac-bce4-9e0af53827f8', 'accounts', 'accessToken'),
(gen_random_uuid(), '3f44e818-bbda-49ac-bce4-9e0af53827f8', 'accounts', 'refreshToken'),
(gen_random_uuid(), '3f44e818-bbda-49ac-bce4-9e0af53827f8', 'accounts', 'idToken'),
(gen_random_uuid(), '3f44e818-bbda-49ac-bce4-9e0af53827f8', 'accounts', 'accessTokenExpiresAt'),
(gen_random_uuid(), '3f44e818-bbda-49ac-bce4-9e0af53827f8', 'accounts', 'refreshTokenExpiresAt'),
(gen_random_uuid(), '3f44e818-bbda-49ac-bce4-9e0af53827f8', 'accounts', 'scope'),
(gen_random_uuid(), '3f44e818-bbda-49ac-bce4-9e0af53827f8', 'accounts', 'password'),
(gen_random_uuid(), '3f44e818-bbda-49ac-bce4-9e0af53827f8', 'accounts', 'createdAt'),
(gen_random_uuid(), '3f44e818-bbda-49ac-bce4-9e0af53827f8', 'accounts', 'updatedAt'),

-- verifications entity
(gen_random_uuid(), '3f44e818-bbda-49ac-bce4-9e0af53827f8', 'verifications', 'id'),
(gen_random_uuid(), '3f44e818-bbda-49ac-bce4-9e0af53827f8', 'verifications', 'identifier'),
(gen_random_uuid(), '3f44e818-bbda-49ac-bce4-9e0af53827f8', 'verifications', 'value'),
(gen_random_uuid(), '3f44e818-bbda-49ac-bce4-9e0af53827f8', 'verifications', 'expiresAt'),
(gen_random_uuid(), '3f44e818-bbda-49ac-bce4-9e0af53827f8', 'verifications', 'createdAt'),
(gen_random_uuid(), '3f44e818-bbda-49ac-bce4-9e0af53827f8', 'verifications', 'updatedAt')

;

-- Now create attrs entries for each ident
INSERT INTO attrs (id, app_id, value_type, cardinality, is_unique, is_indexed, forward_ident, etype, checked_data_type)
SELECT 
    gen_random_uuid() as id,
    i.app_id,
    'blob' as value_type,
    'one' as cardinality,
    CASE 
        WHEN i.label = 'id' THEN true
        WHEN i.label = 'email' AND i.etype = 'users' THEN true
        WHEN i.label = 'token' AND i.etype = 'sessions' THEN true
        ELSE false
    END as is_unique,
    CASE 
        WHEN i.label IN ('id', 'email', 'userId', 'identifier', 'expiresAt') THEN true
        ELSE false
    END as is_indexed,
    i.id as forward_ident,
    i.etype,
    CASE 
        WHEN i.label LIKE '%At' THEN 'date'
        WHEN i.label = 'emailVerified' THEN 'boolean'
        ELSE 'string'
    END::checked_data_type as checked_data_type
FROM idents i
WHERE i.app_id = '3f44e818-bbda-49ac-bce4-9e0af53827f8'
AND NOT EXISTS (
    SELECT 1 FROM attrs a 
    WHERE a.forward_ident = i.id
);