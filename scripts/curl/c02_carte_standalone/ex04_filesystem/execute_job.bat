@echo off
setlocal EnableExtensions

rem Ex04 - Carte Standalone + filesystem + Job
rem O caminho do arquivo e interpretado pelo processo do Carte, nao pelo curl.
rem O ambiente de exemplo usa Carte em http://localhost:9090.
rem Inicializacao e configuracao: docs\CARTE.md

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

if not defined CARTE_URL (
  echo [ERRO] CARTE_URL nao definida.
  exit /b 5
)

if not defined PDI_LOG_LEVEL set "PDI_LOG_LEVEL=Basic"
if not defined PDI_TEST_MESSAGE set "PDI_TEST_MESSAGE=Mensagem enviada pela API REST do PDI"

set "ENDPOINT=%CARTE_URL%/kettle/executeJob/"
set "RESPONSE_FILE=%TEMP%\pdi-api-response-%RANDOM%-%RANDOM%.tmp"
set "STATUS_FILE=%TEMP%\pdi-api-status-%RANDOM%-%RANDOM%.tmp"

echo ============================================================
echo Ex04 - Carte Standalone / Filesystem / Job
echo Endpoint : %ENDPOINT%
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
rem   --output              : grava temporariamente o corpo da resposta para exibicao.
rem   --write-out           : grava o HTTP_STATUS para validacao pelo script.
rem Parametros PDI: job = caminho do .kjb; level = nivel de log; P_MESSAGE = parametro do teste.
rem Detalhes: docs\CURL.md
rem ---------------------------------------------------------------------------

curl.exe ^
  --silent ^
  --show-error ^
  --fail-with-body ^
  --user "%CARTE_USER%:%CARTE_PASSWORD%" ^
  --get ^
  --data-urlencode "job=%JOB_PATH%" ^
  --data-urlencode "level=%PDI_LOG_LEVEL%" ^
  --data-urlencode "P_MESSAGE=%PDI_TEST_MESSAGE%" ^
  --output "%RESPONSE_FILE%" ^
  --write-out "%%{http_code}" ^
  "%ENDPOINT%" > "%STATUS_FILE%"

set "CURL_EXIT=%ERRORLEVEL%"
set "HTTP_STATUS="
if exist "%STATUS_FILE%" set /p HTTP_STATUS=<"%STATUS_FILE%"

if exist "%RESPONSE_FILE%" (
  for %%A in ("%RESPONSE_FILE%") do if %%~zA GTR 0 (
    type "%RESPONSE_FILE%"
    echo.
  )
)

echo HTTP_STATUS=%HTTP_STATUS%
echo.

if not "%CURL_EXIT%"=="0" (
  echo [ERRO] A chamada curl terminou com codigo %CURL_EXIT%.
  del /q "%RESPONSE_FILE%" "%STATUS_FILE%" >nul 2>&1
  exit /b %CURL_EXIT%
)

if not defined HTTP_STATUS (
  echo [ERRO] Nao foi possivel obter o status HTTP.
  del /q "%RESPONSE_FILE%" "%STATUS_FILE%" >nul 2>&1
  exit /b 6
)

if "%HTTP_STATUS:~0,1%"=="3" (
  echo [ERRO] Redirecionamento HTTP inesperado ^(%HTTP_STATUS%^).
  echo        Verifique o endpoint. Os exemplos nao seguem redirects automaticamente.
  del /q "%RESPONSE_FILE%" "%STATUS_FILE%" >nul 2>&1
  exit /b 7
)

if not "%HTTP_STATUS:~0,1%"=="2" (
  echo [ERRO] Status HTTP inesperado: %HTTP_STATUS%.
  del /q "%RESPONSE_FILE%" "%STATUS_FILE%" >nul 2>&1
  exit /b 8
)

del /q "%RESPONSE_FILE%" "%STATUS_FILE%" >nul 2>&1

echo [OK] Requisicao HTTP concluida com sucesso.
echo.
echo Validacao da execucao:
echo   1. Confira o HTTP_STATUS e a resposta acima.
echo   2. Confira o terminal em que Carte.bat esta executando.
echo   3. Procure por [PDI API TEST] e pelo valor de P_MESSAGE.
echo.
echo Carte deste projeto: %CARTE_URL%
echo Consulte docs\CARTE.md e docs\TESTING.md.
exit /b 0
