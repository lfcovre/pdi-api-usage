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
