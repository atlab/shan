function obj = getSchema
persistent schemaObject

if isempty(schemaObject)
    common.getSchema;
    psy.getSchema;
    schemaObject = dj.Schema(dj.conn, 'patch', 'shan_patch');
end

obj = schemaObject;
end