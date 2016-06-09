function s = rename_field_to_force_array(s, fieldname)
forceArrayDirectve = '___Array___';
s.([fieldname forceArrayDirectve]) = s.(fieldname);
s = rmfield(s, fieldname);