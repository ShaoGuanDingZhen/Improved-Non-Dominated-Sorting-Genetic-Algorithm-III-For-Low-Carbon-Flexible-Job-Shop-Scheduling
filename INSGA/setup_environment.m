function setup_environment()
%SETUP_ENVIRONMENT Configure paths and validate the experiment environment.
%   Run this once per MATLAB session before running scripts in experiments/.

    codeRoot = fileparts(mfilename('fullpath'));
    projectRoot = fileparts(codeRoot);
    dataRoot = fullfile(projectRoot,'T2FJSP');
    experimentsRoot = fullfile(codeRoot,'experiments');

    addpath(codeRoot);
    addpath(experimentsRoot);

    assert(isfolder(dataRoot), ...
        'Instance directory not found: %s',dataRoot);
    assert(isfile(fullfile(dataRoot,'Type2FJSP_20_6.txt')), ...
        'Expected test instance Type2FJSP_20_6.txt was not found.');
    assert(exist('pdist','file') == 2, ...
        ['pdist was not found. Install/enable Statistics and Machine Learning ',...
         'Toolbox before running the experiments.']);

    fprintf('MATLAB version: %s\n',version);
    fprintf('Code directory: %s\n',codeRoot);
    fprintf('Instance directory: %s\n',dataRoot);
    fprintf('Environment check passed.\n');
end
