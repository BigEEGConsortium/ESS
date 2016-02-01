obj = levelDerivedStudy([fileparts(which('level1Study')) filesep 'unit_test' filesep 'dummy_level_derived_full']);
opt.ForceRootName = false;
json = savejson('', struct(obj));
%%
workingDirectory = fileparts(which('ess_as_json_report_script.m'));

fid= fopen([workingDirectory filesep 'manifest.js'], 'w');
fprintf(fid, '%s', ['study = ' json]);
fclose(fid);


workingDirectory = fileparts(which('ess_as_json_report_script.m'));
masterTemplate = readtxtfile([workingDirectory filesep 'master_template.html']);
html_template = readtxtfile([workingDirectory filesep 'html_template.html']);

finalHtml = strrep(masterTemplate, 'html_template', html_template);
finalHtml = strrep(finalHtml, 'data_from_ESS', json);

fid= fopen([workingDirectory filesep 'index.html'], 'w');
fprintf(fid, '%s', finalHtml);
fclose(fid);