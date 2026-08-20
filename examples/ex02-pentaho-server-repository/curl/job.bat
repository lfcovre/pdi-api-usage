@echo off
setlocal EnableExtensions

rem Ex02 - Pentaho Server + Pentaho Repository + Job
rem runJob usa o repository ja disponivel no ambiente do Pentaho Server.

for %%I in ("%~dp0..\..\..") do set "PROJECT_ROOT=%%~fI"
set "ENV_FILE=%PROJECT_ROOT%\config\environment.bat"

if not exist "%ENV_FILE%" (
  echo [ERRO] config\environment.bat nao encontrado.
  echo        Copie config\environment.example.bat para environment.bat e ajuste o ambiente.
  exit /b 2
)

call "%ENV_FILE%"

where curl.exe >nul 2>&1
if errorlevel 1 (
  echo [ERRO] curl.exe nao encontrado no PATH.
  exit /b 3
)


if not defined PENTAHO_SERVER_URL (
  echo [ERRO] PENTAHO_SERVER_URL nao definida.
  exit /b 5
)
if not defined PENTAHO_SERVER_USER (
  echo [ERRO] PENTAHO_SERVER_USER nao definida.
  exit /b 5
)
if not defined PENTAHO_SERVER_PASSWORD (
  echo [ERRO] PENTAHO_SERVER_PASSWORD nao definida.
  exit /b 5
)
if not defined PDI_REPOSITORY_JOB (
  echo [ERRO] PDI_REPOSITORY_JOB nao definida.
  exit /b 5
)

if not defined PDI_LOG_LEVEL set "PDI_LOG_LEVEL=Basic"
if not defined PDI_TEST_MESSAGE set "PDI_TEST_MESSAGE=Mensagem enviada pela API REST do PDI"

set "ENDPOINT=%PENTAHO_SERVER_URL%/kettle/runJob"
set "RESPONSE_FILE=%TEMP%\pdi-api-response-%RANDOM%-%RANDOM%.tmp"
set "STATUS_FILE=%TEMP%\pdi-api-status-%RANDOM%-%RANDOM%.tmp"

echo ============================================================
echo Ex02 - Pentaho Server / Pentaho Repository / Job
echo Endpoint   : %ENDPOINT%
echo Objeto     : %PDI_REPOSITORY_JOB%
echo Parametro  : P_MESSAGE=%PDI_TEST_MESSAGE%
echo ============================================================
echo.

rem Opcoes do curl e parametros PDI: docs\curl.md e docs\api-endpoints.md
curl.exe ^
  --silent ^
  --show-error ^
  --fail-with-body ^
  --user "%PENTAHO_SERVER_USER%:%PENTAHO_SERVER_PASSWORD%" ^
  --get ^
  --data-urlencode "job=%PDI_REPOSITORY_JOB%" ^
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
echo Validacao: consulte docs\testing.md
exit /b 0
