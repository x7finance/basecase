-- InstantDB Schema Migration for Basecase App
-- App ID: 3f44e818-bbda-49ac-bce4-9e0af53827f8

-- Create attrs if they don't exist
INSERT INTO attrs (id, app_id, etype, label, value_type, cardinality, is_unique, is_indexed, forward_ident, checked_data_type)
SELECT * FROM (VALUES
-- users entity attributes
('b1000000-0000-0000-0000-000000000001'::uuid, '3f44e818-bbda-49ac-bce4-9e0af53827f8'::uuid, 'users', 'id', 'blob', 'one', true, true, 'b2000000-0000-0000-0000-000000000001'::uuid, 'string'::checked_data_type),
('b1000000-0000-0000-0000-000000000002'::uuid, '3f44e818-bbda-49ac-bce4-9e0af53827f8'::uuid, 'users', 'email', 'blob', 'one', true, true, 'b2000000-0000-0000-0000-000000000002'::uuid, 'string'::checked_data_type),
('b1000000-0000-0000-0000-000000000003'::uuid, '3f44e818-bbda-49ac-bce4-9e0af53827f8'::uuid, 'users', 'name', 'blob', 'one', false, false, 'b2000000-0000-0000-0000-000000000003'::uuid, 'string'::checked_data_type),
('b1000000-0000-0000-0000-000000000004'::uuid, '3f44e818-bbda-49ac-bce4-9e0af53827f8'::uuid, 'users', 'emailVerified', 'blob', 'one', false, false, 'b2000000-0000-0000-0000-000000000004'::uuid, 'boolean'::checked_data_type),
('b1000000-0000-0000-0000-000000000005'::uuid, '3f44e818-bbda-49ac-bce4-9e0af53827f8'::uuid, 'users', 'image', 'blob', 'one', false, false, 'b2000000-0000-0000-0000-000000000005'::uuid, 'string'::checked_data_type),
('b1000000-0000-0000-0000-000000000006'::uuid, '3f44e818-bbda-49ac-bce4-9e0af53827f8'::uuid, 'users', 'createdAt', 'blob', 'one', false, true, 'b2000000-0000-0000-0000-000000000006'::uuid, 'date'::checked_data_type),
('b1000000-0000-0000-0000-000000000007'::uuid, '3f44e818-bbda-49ac-bce4-9e0af53827f8'::uuid, 'users', 'updatedAt', 'blob', 'one', false, false, 'b2000000-0000-0000-0000-000000000007'::uuid, 'date'::checked_data_type),

-- sessions entity attributes
('b1000000-0000-0000-0000-000000000011'::uuid, '3f44e818-bbda-49ac-bce4-9e0af53827f8'::uuid, 'sessions', 'id', 'blob', 'one', true, true, 'b2000000-0000-0000-0000-000000000011'::uuid, 'string'::checked_data_type),
('b1000000-0000-0000-0000-000000000012'::uuid, '3f44e818-bbda-49ac-bce4-9e0af53827f8'::uuid, 'sessions', 'token', 'blob', 'one', true, true, 'b2000000-0000-0000-0000-000000000012'::uuid, 'string'::checked_data_type),
('b1000000-0000-0000-0000-000000000013'::uuid, '3f44e818-bbda-49ac-bce4-9e0af53827f8'::uuid, 'sessions', 'expiresAt', 'blob', 'one', false, true, 'b2000000-0000-0000-0000-000000000013'::uuid, 'date'::checked_data_type),
('b1000000-0000-0000-0000-000000000014'::uuid, '3f44e818-bbda-49ac-bce4-9e0af53827f8'::uuid, 'sessions', 'ipAddress', 'blob', 'one', false, false, 'b2000000-0000-0000-0000-000000000014'::uuid, 'string'::checked_data_type),
('b1000000-0000-0000-0000-000000000015'::uuid, '3f44e818-bbda-49ac-bce4-9e0af53827f8'::uuid, 'sessions', 'userAgent', 'blob', 'one', false, false, 'b2000000-0000-0000-0000-000000000015'::uuid, 'string'::checked_data_type),
('b1000000-0000-0000-0000-000000000016'::uuid, '3f44e818-bbda-49ac-bce4-9e0af53827f8'::uuid, 'sessions', 'userId', 'blob', 'one', false, true, 'b2000000-0000-0000-0000-000000000016'::uuid, 'string'::checked_data_type),
('b1000000-0000-0000-0000-000000000017'::uuid, '3f44e818-bbda-49ac-bce4-9e0af53827f8'::uuid, 'sessions', 'createdAt', 'blob', 'one', false, false, 'b2000000-0000-0000-0000-000000000017'::uuid, 'date'::checked_data_type),
('b1000000-0000-0000-0000-000000000018'::uuid, '3f44e818-bbda-49ac-bce4-9e0af53827f8'::uuid, 'sessions', 'updatedAt', 'blob', 'one', false, false, 'b2000000-0000-0000-0000-000000000018'::uuid, 'date'::checked_data_type),

-- accounts entity attributes
('b1000000-0000-0000-0000-000000000021'::uuid, '3f44e818-bbda-49ac-bce4-9e0af53827f8'::uuid, 'accounts', 'id', 'blob', 'one', true, true, 'b2000000-0000-0000-0000-000000000021'::uuid, 'string'::checked_data_type),
('b1000000-0000-0000-0000-000000000022'::uuid, '3f44e818-bbda-49ac-bce4-9e0af53827f8'::uuid, 'accounts', 'accountId', 'blob', 'one', false, false, 'b2000000-0000-0000-0000-000000000022'::uuid, 'string'::checked_data_type),
('b1000000-0000-0000-0000-000000000023'::uuid, '3f44e818-bbda-49ac-bce4-9e0af53827f8'::uuid, 'accounts', 'providerId', 'blob', 'one', false, false, 'b2000000-0000-0000-0000-000000000023'::uuid, 'string'::checked_data_type),
('b1000000-0000-0000-0000-000000000024'::uuid, '3f44e818-bbda-49ac-bce4-9e0af53827f8'::uuid, 'accounts', 'userId', 'blob', 'one', false, true, 'b2000000-0000-0000-0000-000000000024'::uuid, 'string'::checked_data_type),
('b1000000-0000-0000-0000-000000000025'::uuid, '3f44e818-bbda-49ac-bce4-9e0af53827f8'::uuid, 'accounts', 'accessToken', 'blob', 'one', false, false, 'b2000000-0000-0000-0000-000000000025'::uuid, 'string'::checked_data_type),
('b1000000-0000-0000-0000-000000000026'::uuid, '3f44e818-bbda-49ac-bce4-9e0af53827f8'::uuid, 'accounts', 'refreshToken', 'blob', 'one', false, false, 'b2000000-0000-0000-0000-000000000026'::uuid, 'string'::checked_data_type),
('b1000000-0000-0000-0000-000000000027'::uuid, '3f44e818-bbda-49ac-bce4-9e0af53827f8'::uuid, 'accounts', 'idToken', 'blob', 'one', false, false, 'b2000000-0000-0000-0000-000000000027'::uuid, 'string'::checked_data_type),
('b1000000-0000-0000-0000-000000000028'::uuid, '3f44e818-bbda-49ac-bce4-9e0af53827f8'::uuid, 'accounts', 'accessTokenExpiresAt', 'blob', 'one', false, false, 'b2000000-0000-0000-0000-000000000028'::uuid, 'date'::checked_data_type),
('b1000000-0000-0000-0000-000000000029'::uuid, '3f44e818-bbda-49ac-bce4-9e0af53827f8'::uuid, 'accounts', 'refreshTokenExpiresAt', 'blob', 'one', false, false, 'b2000000-0000-0000-0000-000000000029'::uuid, 'date'::checked_data_type),
('b1000000-0000-0000-0000-000000000030'::uuid, '3f44e818-bbda-49ac-bce4-9e0af53827f8'::uuid, 'accounts', 'scope', 'blob', 'one', false, false, 'b2000000-0000-0000-0000-000000000030'::uuid, 'string'::checked_data_type),
('b1000000-0000-0000-0000-000000000031'::uuid, '3f44e818-bbda-49ac-bce4-9e0af53827f8'::uuid, 'accounts', 'password', 'blob', 'one', false, false, 'b2000000-0000-0000-0000-000000000031'::uuid, 'string'::checked_data_type),
('b1000000-0000-0000-0000-000000000032'::uuid, '3f44e818-bbda-49ac-bce4-9e0af53827f8'::uuid, 'accounts', 'createdAt', 'blob', 'one', false, false, 'b2000000-0000-0000-0000-000000000032'::uuid, 'date'::checked_data_type),
('b1000000-0000-0000-0000-000000000033'::uuid, '3f44e818-bbda-49ac-bce4-9e0af53827f8'::uuid, 'accounts', 'updatedAt', 'blob', 'one', false, false, 'b2000000-0000-0000-0000-000000000033'::uuid, 'date'::checked_data_type),

-- verifications entity attributes
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

-- Create idents if they don't exist
INSERT INTO idents (id, app_id, attr_id, etype, label)
SELECT v.id, v.app_id, v.attr_id, v.etype, v.label
FROM (VALUES
-- users idents
('b2000000-0000-0000-0000-000000000001'::uuid, '3f44e818-bbda-49ac-bce4-9e0af53827f8'::uuid, 'b1000000-0000-0000-0000-000000000001'::uuid, 'users', 'id'),
('b2000000-0000-0000-0000-000000000002'::uuid, '3f44e818-bbda-49ac-bce4-9e0af53827f8'::uuid, 'b1000000-0000-0000-0000-000000000002'::uuid, 'users', 'email'),
('b2000000-0000-0000-0000-000000000003'::uuid, '3f44e818-bbda-49ac-bce4-9e0af53827f8'::uuid, 'b1000000-0000-0000-0000-000000000003'::uuid, 'users', 'name'),
('b2000000-0000-0000-0000-000000000004'::uuid, '3f44e818-bbda-49ac-bce4-9e0af53827f8'::uuid, 'b1000000-0000-0000-0000-000000000004'::uuid, 'users', 'emailVerified'),
('b2000000-0000-0000-0000-000000000005'::uuid, '3f44e818-bbda-49ac-bce4-9e0af53827f8'::uuid, 'b1000000-0000-0000-0000-000000000005'::uuid, 'users', 'image'),
('b2000000-0000-0000-0000-000000000006'::uuid, '3f44e818-bbda-49ac-bce4-9e0af53827f8'::uuid, 'b1000000-0000-0000-0000-000000000006'::uuid, 'users', 'createdAt'),
('b2000000-0000-0000-0000-000000000007'::uuid, '3f44e818-bbda-49ac-bce4-9e0af53827f8'::uuid, 'b1000000-0000-0000-0000-000000000007'::uuid, 'users', 'updatedAt'),

-- sessions idents
('b2000000-0000-0000-0000-000000000011'::uuid, '3f44e818-bbda-49ac-bce4-9e0af53827f8'::uuid, 'b1000000-0000-0000-0000-000000000011'::uuid, 'sessions', 'id'),
('b2000000-0000-0000-0000-000000000012'::uuid, '3f44e818-bbda-49ac-bce4-9e0af53827f8'::uuid, 'b1000000-0000-0000-0000-000000000012'::uuid, 'sessions', 'token'),
('b2000000-0000-0000-0000-000000000013'::uuid, '3f44e818-bbda-49ac-bce4-9e0af53827f8'::uuid, 'b1000000-0000-0000-0000-000000000013'::uuid, 'sessions', 'expiresAt'),
('b2000000-0000-0000-0000-000000000014'::uuid, '3f44e818-bbda-49ac-bce4-9e0af53827f8'::uuid, 'b1000000-0000-0000-0000-000000000014'::uuid, 'sessions', 'ipAddress'),
('b2000000-0000-0000-0000-000000000015'::uuid, '3f44e818-bbda-49ac-bce4-9e0af53827f8'::uuid, 'b1000000-0000-0000-0000-000000000015'::uuid, 'sessions', 'userAgent'),
('b2000000-0000-0000-0000-000000000016'::uuid, '3f44e818-bbda-49ac-bce4-9e0af53827f8'::uuid, 'b1000000-0000-0000-0000-000000000016'::uuid, 'sessions', 'userId'),
('b2000000-0000-0000-0000-000000000017'::uuid, '3f44e818-bbda-49ac-bce4-9e0af53827f8'::uuid, 'b1000000-0000-0000-0000-000000000017'::uuid, 'sessions', 'createdAt'),
('b2000000-0000-0000-0000-000000000018'::uuid, '3f44e818-bbda-49ac-bce4-9e0af53827f8'::uuid, 'b1000000-0000-0000-0000-000000000018'::uuid, 'sessions', 'updatedAt'),

-- accounts idents
('b2000000-0000-0000-0000-000000000021'::uuid, '3f44e818-bbda-49ac-bce4-9e0af53827f8'::uuid, 'b1000000-0000-0000-0000-000000000021'::uuid, 'accounts', 'id'),
('b2000000-0000-0000-0000-000000000022'::uuid, '3f44e818-bbda-49ac-bce4-9e0af53827f8'::uuid, 'b1000000-0000-0000-0000-000000000022'::uuid, 'accounts', 'accountId'),
('b2000000-0000-0000-0000-000000000023'::uuid, '3f44e818-bbda-49ac-bce4-9e0af53827f8'::uuid, 'b1000000-0000-0000-0000-000000000023'::uuid, 'accounts', 'providerId'),
('b2000000-0000-0000-0000-000000000024'::uuid, '3f44e818-bbda-49ac-bce4-9e0af53827f8'::uuid, 'b1000000-0000-0000-0000-000000000024'::uuid, 'accounts', 'userId'),
('b2000000-0000-0000-0000-000000000025'::uuid, '3f44e818-bbda-49ac-bce4-9e0af53827f8'::uuid, 'b1000000-0000-0000-0000-000000000025'::uuid, 'accounts', 'accessToken'),
('b2000000-0000-0000-0000-000000000026'::uuid, '3f44e818-bbda-49ac-bce4-9e0af53827f8'::uuid, 'b1000000-0000-0000-0000-000000000026'::uuid, 'accounts', 'refreshToken'),
('b2000000-0000-0000-0000-000000000027'::uuid, '3f44e818-bbda-49ac-bce4-9e0af53827f8'::uuid, 'b1000000-0000-0000-0000-000000000027'::uuid, 'accounts', 'idToken'),
('b2000000-0000-0000-0000-000000000028'::uuid, '3f44e818-bbda-49ac-bce4-9e0af53827f8'::uuid, 'b1000000-0000-0000-0000-000000000028'::uuid, 'accounts', 'accessTokenExpiresAt'),
('b2000000-0000-0000-0000-000000000029'::uuid, '3f44e818-bbda-49ac-bce4-9e0af53827f8'::uuid, 'b1000000-0000-0000-0000-000000000029'::uuid, 'accounts', 'refreshTokenExpiresAt'),
('b2000000-0000-0000-0000-000000000030'::uuid, '3f44e818-bbda-49ac-bce4-9e0af53827f8'::uuid, 'b1000000-0000-0000-0000-000000000030'::uuid, 'accounts', 'scope'),
('b2000000-0000-0000-0000-000000000031'::uuid, '3f44e818-bbda-49ac-bce4-9e0af53827f8'::uuid, 'b1000000-0000-0000-0000-000000000031'::uuid, 'accounts', 'password'),
('b2000000-0000-0000-0000-000000000032'::uuid, '3f44e818-bbda-49ac-bce4-9e0af53827f8'::uuid, 'b1000000-0000-0000-0000-000000000032'::uuid, 'accounts', 'createdAt'),
('b2000000-0000-0000-0000-000000000033'::uuid, '3f44e818-bbda-49ac-bce4-9e0af53827f8'::uuid, 'b1000000-0000-0000-0000-000000000033'::uuid, 'accounts', 'updatedAt'),

-- verifications idents
('b2000000-0000-0000-0000-000000000041'::uuid, '3f44e818-bbda-49ac-bce4-9e0af53827f8'::uuid, 'b1000000-0000-0000-0000-000000000041'::uuid, 'verifications', 'id'),
('b2000000-0000-0000-0000-000000000042'::uuid, '3f44e818-bbda-49ac-bce4-9e0af53827f8'::uuid, 'b1000000-0000-0000-0000-000000000042'::uuid, 'verifications', 'identifier'),
('b2000000-0000-0000-0000-000000000043'::uuid, '3f44e818-bbda-49ac-bce4-9e0af53827f8'::uuid, 'b1000000-0000-0000-0000-000000000043'::uuid, 'verifications', 'value'),
('b2000000-0000-0000-0000-000000000044'::uuid, '3f44e818-bbda-49ac-bce4-9e0af53827f8'::uuid, 'b1000000-0000-0000-0000-000000000044'::uuid, 'verifications', 'expiresAt'),
('b2000000-0000-0000-0000-000000000045'::uuid, '3f44e818-bbda-49ac-bce4-9e0af53827f8'::uuid, 'b1000000-0000-0000-0000-000000000045'::uuid, 'verifications', 'createdAt'),
('b2000000-0000-0000-0000-000000000046'::uuid, '3f44e818-bbda-49ac-bce4-9e0af53827f8'::uuid, 'b1000000-0000-0000-0000-000000000046'::uuid, 'verifications', 'updatedAt')
) AS v(id, app_id, attr_id, etype, label)
WHERE EXISTS (
    SELECT 1 FROM attrs 
    WHERE attrs.id = v.attr_id
) AND NOT EXISTS (
    SELECT 1 FROM idents 
    WHERE idents.id = v.id
);