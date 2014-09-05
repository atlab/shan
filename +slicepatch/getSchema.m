function obj = getSchema
persistent schemaObject

if isempty(schemaObject)
    common.getSchema;
    psy.getSchema;
    schemaObject = dj.Schema(dj.conn, 'slicepatch', 'shan_slice_patch');
end

obj = schemaObject;
end