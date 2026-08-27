# analyze-dev.ps1
Move-Item analysis_options.yaml analysis_options.yaml.bak -Force
Copy-Item analysis_options_migrate.yaml analysis_options.yaml -Force
fvm flutter analyze
Move-Item -Force analysis_options.yaml.bak analysis_options.yaml