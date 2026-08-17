@echo off
setlocal EnableExtensions

rem Ex01 - Pentaho Server + filesystem + Job
rem O caminho do arquivo e interpretado pelo processo do Pentaho Server, nao pelo curl.

for %%I in ("%~dp0..\..\..\..") do set "PROJECT_ROOT=%%~fI"
set "ENV_FILE=%PROJECT_ROOT%\config\environment.bat"

if not exist "%ENV_FILE%" (
  set "ENV_FILE=%PROJECT_ROOT%\config\environment.example.bat"
  echo [AVISO] config\environment.bat nao encontrado. Usando environment.example.bat.
  echo         Copie o arquivo de exemplo para environment.bat e ajuste o ambiente.
  echo.
)

if not exist "%ENV_FILE%" (
  echo [ERRO] Arquivo de configuracao nao encontrado.
  exit /b 2
)

call "%ENV_FILE%"

where curl.exe >nul 2>&1
if errorlevel 1 (
  echo [ERRO] curl.exe nao encontrado no PATH.
  exit /b 3
)

set "JOB_PATH=%PROJECT_ROOT%\pdi\jobs\job_api_test.kjb"

if not exist "%JOB_PATH%" (
  echo [ERRO] Job nao encontrado: "%JOB_PATH%"
  exit /b 4
)

if not defined PENTAHO_SERVER_URL (
  echo [ERRO] PENTAHO_SERVER_URL nao definida.
  exit /b 5
)

if not defined PDI_LOG_LEVEL set "PDI_LOG_LEVEL=Basic"
if not defined PDI_TEST_MESSAGE set "PDI_TEST_MESSAGE=Mensagem enviada pela API REST do PDI"

echo ============================================================
echo Ex01 - Pentaho Server / Filesystem / Job
echo Endpoint : %PENTAHO_SERVER_URL%/kettle/executeJob
echo Arquivo  : %JOB_PATH%
echo Parametro: P_MESSAGE=%PDI_TEST_MESSAGE%
echo ============================================================
echo.

rem ---------------------------------------------------------------------------
rem Resumo das opcoes do curl:
rem   --silent/--show-error : oculta progresso, mas continua mostrando erros.
rem   --fail-with-body      : falha em HTTP 4xx/5xx e preserva o corpo da resposta.
rem   --user                : autenticacao HTTP no Pentaho Server/Carte.
rem   --get                 : realiza GET usando os parametros abaixo na query string.
rem   --data-urlencode      : envia parametros com URL encoding automatico.
rem   --write-out           : imprime o HTTP_STATUS ao final da resposta.
rem Parametros PDI: job = caminho do .kjb; level = nivel de log; P_MESSAGE = parametro do teste.
rem Detalhes: docs\CURL.md
rem ---------------------------------------------------------------------------

curl.exe ^
  --silent ^
  --show-error ^
  --fail-with-body ^
  --user "%PENTAHO_SERVER_USER%:%PENTAHO_SERVER_PASSWORD%" ^
  --get ^
  --data-urlencode "job=%JOB_PATH%" ^
  --data-urlencode "level=%PDI_LOG_LEVEL%" ^
  --data-urlencode "P_MESSAGE=%PDI_TEST_MESSAGE%" ^
  --write-out "\nHTTP_STATUS=%%{http_code}\n" ^
  "%PENTAHO_SERVER_URL%/kettle/executeJob"

set "CURL_EXIT=%ERRORLEVEL%"
echo.

if not "%CURL_EXIT%"=="0" (
  echo [ERRO] A chamada curl terminou com codigo %CURL_EXIT%.
  exit /b %CURL_EXIT%
)

echo [OK] Requisicao concluida.
echo.
echo Validacao da execucao:
echo   1. Confira o HTTP_STATUS e a resposta acima.
echo   2. Confira ^<PENTAHO_SERVER_HOME^>\logs\pdi.log.
echo   3. Procure pela mensagem [PDI API TEST] e pelo valor de P_MESSAGE.
echo.
echo Consulte docs\TESTING.md para comandos PowerShell e filtros de log.
exit /b 0
