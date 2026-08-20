@echo off
rem ============================================================================
rem PDI API Usage - environment example
rem
rem Copy this file to config\environment.bat and adjust the values for the
rem local environment. The local file is ignored by Git because it may contain
rem credentials.
rem ============================================================================

rem Pentaho Server
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

rem Logical paths in the Pentaho Repository.
rem Used by Ex02 and Ex04. Do not include .ktr or .kjb.
set "PDI_REPOSITORY_TRANS=/public/pdi-api-usage/trf_api_test"
set "PDI_REPOSITORY_JOB=/public/pdi-api-usage/job_api_test"

rem Used only by the advanced Carte variation that sends the repository
rem selection and credentials in the request.
set "PDI_REPOSITORY_NAME=REPOSITORY_NAME"
set "PDI_REPOSITORY_USER=REPOSITORY_USER"
set "PDI_REPOSITORY_PASSWORD=REPOSITORY_PASSWORD"
