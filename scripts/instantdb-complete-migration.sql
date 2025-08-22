-- Complete InstantDB Schema Migration for Auth Entities
-- App ID: 3f44e818-bbda-49ac-bce4-9e0af53827f8

-- Add missing user attributes
INSERT INTO attrs (id, app_id, etype, label, value_type, cardinality, is_unique, is_indexed, forward_ident, checked_data_type) 
SELECT * FROM (VALUES
-- Missing users attributes
('b1000000-0000-0000-0000-000000000004'::uuid, '3f44e818-bbda-49ac-bce4-9e0af53827f8'::uuid, 'users', 'emailVerified', 'blob', 'one', false, false, 'b2000000-0000-0000-0000-000000000004'::uuid, 'boolean'::checked_data_type),
('b1000000-0000-0000-0000-000000000005'::uuid, '3f44e818-bbda-49ac-bce4-9e0af53827f8'::uuid, 'users', 'image', 'blob', 'one', false, false, 'b2000000-0000-0000-0000-000000000005'::uuid, 'string'::checked_data_type),
('b1000000-0000-0000-0000-000000000006'::uuid, '3f44e818-bbda-49ac-bce4-9e0af53827f8'::uuid, 'users', 'createdAt', 'blob', 'one', false, true, 'b2000000-0000-0000-0000-000000000006'::uuid, 'date'::checked_data_type),
('b1000000-0000-0000-0000-000000000007'::uuid, '3f44e818-bbda-49ac-bce4-9e0af53827f8'::uuid, 'users', 'updatedAt', 'blob', 'one', false, false, 'b2000000-0000-0000-0000-000000000007'::uuid, 'date'::checked_data_type),

-- Missing sessions attributes  
('b1000000-0000-0000-0000-000000000014'::uuid, '3f44e818-bbda-49ac-bce4-9e0af53827f8'::uuid, 'sessions', 'ipAddress', 'blob', 'one', false, false, 'b2000000-0000-0000-0000-000000000014'::uuid, 'string'::checked_data_type),
('b1000000-0000-0000-0000-000000000015'::uuid, '3f44e818-bbda-49ac-bce4-9e0af53827f8'::uuid, 'sessions', 'userAgent', 'blob', 'one', false, false, 'b2000000-0000-0000-0000-000000000015'::uuid, 'string'::checked_data_type),
('b1000000-0000-0000-0000-000000000017'::uuid, '3f44e818-bbda-49ac-bce4-9e0af53827f8'::uuid, 'sessions', 'createdAt', 'blob', 'one', false, false, 'b2000000-0000-0000-0000-000000000017'::uuid, 'date'::checked_data_type),
('b1000000-0000-0000-0000-000000000018'::uuid, '3f44e818-bbda-49ac-bce4-9e0af53827f8'::uuid, 'sessions', 'updatedAt', 'blob', 'one', false, false, 'b2000000-0000-0000-0000-000000000018'::uuid, 'date'::checked_data_type),

-- Missing accounts attributes
('b1000000-0000-0000-0000-000000000022'::uuid, '3f44e818-bbda-49ac-bce4-9e0af53827f8'::uuid, 'accounts', 'accountId', 'blob', 'one', false, false, 'b2000000-0000-0000-0000-000000000022'::uuid, 'string'::checked_data_type),
('b1000000-0000-0000-0000-000000000023'::uuid, '3f44e818-bbda-49ac-bce4-9e0af53827f8'::uuid, 'accounts', 'providerId', 'blob', 'one', false, false, 'b2000000-0000-0000-0000-000000000023'::uuid, 'string'::checked_data_type),
('b1000000-0000-0000-0000-000000000025'::uuid, '3f44e818-bbda-49ac-bce4-9e0af53827f8'::uuid, 'accounts', 'accessToken', 'blob', 'one', false, false, 'b2000000-0000-0000-0000-000000000025'::uuid, 'string'::checked_data_type),
('b1000000-0000-0000-0000-000000000026'::uuid, '3f44e818-bbda-49ac-bce4-9e0af53827f8'::uuid, 'accounts', 'refreshToken', 'blob', 'one', false, false, 'b2000000-0000-0000-0000-000000000026'::uuid, 'string'::checked_data_type),
('b1000000-0000-0000-0000-000000000027'::uuid, '3f44e818-bbda-49ac-bce4-9e0af53827f8'::uuid, 'accounts', 'idToken', 'blob', 'one', false, false, 'b2000000-0000-0000-0000-000000000027'::uuid, 'string'::checked_data_type),
('b1000000-0000-0000-0000-000000000028'::uuid, '3f44e818-bbda-49ac-bce4-9e0af53827f8'::uuid, 'accounts', 'accessTokenExpiresAt', 'blob', 'one', false, false, 'b2000000-0000-0000-0000-000000000028'::uuid, 'date'::checked_data_type),
('b1000000-0000-0000-0000-000000000029'::uuid, '3f44e818-bbda-49ac-bce4-9e0af53827f8'::uuid, 'accounts', 'refreshTokenExpiresAt', 'blob', 'one', false, false, 'b2000000-0000-0000-0000-000000000029'::uuid, 'date'::checked_data_type),
('b1000000-0000-0000-0000-000000000030'::uuid, '3f44e818-bbda-49ac-bce4-9e0af53827f8'::uuid, 'accounts', 'scope', 'blob', 'one', false, false, 'b2000000-0000-0000-0000-000000000030'::uuid, 'string'::checked_data_type),
('b1000000-0000-0000-0000-000000000031'::uuid, '3f44e818-bbda-49ac-bce4-9e0af53827f8'::uuid, 'accounts', 'password', 'blob', 'one', false, false, 'b2000000-0000-0000-0000-000000000031'::uuid, 'string'::checked_data_type),
('b1000000-0000-0000-0000-000000000032'::uuid, '3f44e818-bbda-49ac-bce4-9e0af53827f8'::uuid, 'accounts', 'createdAt', 'blob', 'one', false, false, 'b2000000-0000-0000-0000-000000000032'::uuid, 'date'::checked_data_type),
('b1000000-0000-0000-0000-000000000033'::uuid, '3f44e818-bbda-49ac-bce4-9e0af53827f8'::uuid, 'accounts', 'updatedAt', 'blob', 'one', false, false, 'b2000000-0000-0000-0000-000000000033'::uuid, 'date'::checked_data_type),

-- All verifications attributes
('b1000000-0000-0000-0000-000000000041'::uuid, '3f44e818-bbda-49ac-bce4-9e0af53827f8'::uuid, 'verifications', 'id', 'blob', 'one', true, true, 'b2000000-0000-0000-0000-000000000041'::uuid, 'string'::checked_data_type),
('b1000000-0000-0000-0000-000000000042'::uuid, '3f44e818-bbda-49ac-bce4-9e0af53827f8'::uuid, 'verifications', 'identifier', 'blob', 'one', false, true, 'b2000000-0000-0000-0000-000000000042'::uuid, 'string'::checked_data_type),
('b1000000-0000-0000-0000-000000000043'::uuid, '3f44e818-bbda-49ac-bce4-9e0af53827f8'::uuid, 'verifications', 'value', 'blob', 'one', false, false, 'b2000000-0000-0000-0000-000000000043'::uuid, 'string'::checked_data_type),
('b1000000-0000-0000-0000-000000000044'::uuid, '3f44e818-bbda-49ac-bce4-9e0af53827f8'::uuid, 'verifications', 'expiresAt', 'blob', 'one', false, true, 'b2000000-0000-0000-0000-000000000044'::uuid, 'date'::checked_data_type),
('b1000000-0000-0000-0000-000000000045'::uuid, '3f44e818-bbda-49ac-bce4-9e0af53827f8'::uuid, 'verifications', 'createdAt', 'blob', 'one', false, false, 'b2000000-0000-0000-0000-000000000045'::uuid, 'date'::checked_data_type),
('b1000000-0000-0000-0000-000000000046'::uuid, '3f44e818-bbda-49ac-bce4-9e0af53827f8'::uuid, 'verifications', 'updatedAt', 'blob', 'one', false, false, 'b2000000-0000-0000-0000-000000000046'::uuid, 'date'::checked_data_type)
) AS v(id, app_id, etype, label, value_type, cardinality, is_unique, is_indexed, forward_ident, checked_data_type)
WHERE NOT EXISTS (
    SELECT 1 FROM attrs 
    WHERE attrs.app_id = v.app_id 
    AND attrs.etype = v.etype 
    AND attrs.label = v.label
);

-- Create idents for all attrs
INSERT INTO idents (id, app_id, attr_id, etype, label)
SELECT v.ident_id, v.app_id, v.attr_id, v.etype, v.label
FROM (
    SELECT 
        a.forward_ident as ident_id,
        a.app_id,
        a.id as attr_id,
        a.etype,
        a.label
    FROM attrs a
    WHERE a.app_id = '3f44e818-bbda-49ac-bce4-9e0af53827f8'
    AND NOT EXISTS (
        SELECT 1 FROM idents i 
        WHERE i.attr_id = a.id
    )
) v;