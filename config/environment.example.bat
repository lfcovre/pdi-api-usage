@echo off
rem ============================================================================
rem Example environment for PDI REST API tests.
rem Copy this file to environment.bat and adjust it for your installation.
rem environment.bat is ignored by Git because it may contain real credentials.
rem ============================================================================

rem Pentaho Server (BA Server / Pentaho Server)
set "PENTAHO_SERVER_URL=http://localhost:8080/pentaho"
set "PENTAHO_SERVER_USER=admin"
set "PENTAHO_SERVER_PASSWORD=password"

rem Carte Standalone
set "CARTE_URL=http://localhost:9090"
set "CARTE_USER=cluster"
set "CARTE_PASSWORD=cluster"

rem Common execution options
set "PDI_LOG_LEVEL=Basic"
set "PDI_TEST_MESSAGE=Mensagem enviada pela API REST do PDI"

rem Explicit repository examples (Ex02 and Ex05)
rem The repository name must match a repository definition visible to the executor.
rem The object paths are logical repository paths; do not use local filesystem paths.
set "PDI_REPOSITORY_NAME=REPOSITORY_NAME"
set "PDI_REPOSITORY_USER=admin"
set "PDI_REPOSITORY_PASSWORD=password"
set "PDI_REPOSITORY_TRANS=/public/pdi-api-usage/trf_api_test"
set "PDI_REPOSITORY_JOB=/public/pdi-api-usage/job_api_test"
