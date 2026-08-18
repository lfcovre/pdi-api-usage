@echo off
setlocal EnableExtensions

rem Ex05 - Carte Standalone + repository explicito + Transformation
rem O parametro rep seleciona um repository conhecido pelo processo do Carte.
rem user/pass abaixo sao credenciais DO REPOSITORY, diferentes da autenticacao HTTP.
rem Pre-requisitos e detalhes: docs\REPOSITORY.md

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

if not defined CARTE_URL (
  echo [ERRO] CARTE_URL nao definida.
  exit /b 5
)
if not defined PDI_REPOSITORY_NAME (
  echo [ERRO] PDI_REPOSITORY_NAME nao definida.
  exit /b 5
)
if not defined PDI_REPOSITORY_USER (
  echo [ERRO] PDI_REPOSITORY_USER nao definida.
  exit /b 5
)
if not defined PDI_REPOSITORY_PASSWORD (
  echo [ERRO] PDI_REPOSITORY_PASSWORD nao definida.
  exit /b 5
)
if not defined PDI_REPOSITORY_TRANS (
  echo [ERRO] PDI_REPOSITORY_TRANS nao definida.
  exit /b 5
)

if not defined PDI_LOG_LEVEL set "PDI_LOG_LEVEL=Basic"
if not defined PDI_TEST_MESSAGE set "PDI_TEST_MESSAGE=Mensagem enviada pela API REST do PDI"

set "ENDPOINT=%CARTE_URL%/kettle/executeTrans/"
set "RESPONSE_FILE=%TEMP%\pdi-api-response-%RANDOM%-%RANDOM%.tmp"
set "STATUS_FILE=%TEMP%\pdi-api-status-%RANDOM%-%RANDOM%.tmp"

echo ============================================================
echo Ex05 - Carte Standalone / Repository explicito / Transformation
echo Endpoint   : %ENDPOINT%
echo Repository : %PDI_REPOSITORY_NAME%
echo Objeto     : %PDI_REPOSITORY_TRANS%
echo Parametro  : P_MESSAGE=%PDI_TEST_MESSAGE%
echo ============================================================
echo.

rem ---------------------------------------------------------------------------
rem Autenticacao e parametros:
rem   --user HTTP_USER:HTTP_PASSWORD : autentica no Carte.
rem   rep                            : nome do repository conhecido pelo PDI.
rem   user / pass                    : credenciais para conectar ao repository.
rem   trans                          : caminho logico da Transformation no repository.
rem   level                          : nivel de log da execucao.
rem   P_MESSAGE                      : parametro declarado no artefato de teste.
rem
rem IMPORTANTE: rep/user/pass sao parametros da API PDI e vao na query string.
rem O repository ainda precisa estar definido no repositories.xml do executor.
rem Detalhes: docs\REPOSITORY.md e docs\CURL.md
rem ---------------------------------------------------------------------------

curl.exe ^
  --silent ^
  --show-error ^
  --fail-with-body ^
  --user "%CARTE_USER%:%CARTE_PASSWORD%" ^
  --get ^
  --data-urlencode "rep=%PDI_REPOSITORY_NAME%" ^
  --data-urlencode "user=%PDI_REPOSITORY_USER%" ^
  --data-urlencode "pass=%PDI_REPOSITORY_PASSWORD%" ^
  --data-urlencode "trans=%PDI_REPOSITORY_TRANS%" ^
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
  echo        Consulte docs\REPOSITORY.md para 401, 404 e erros de repository.
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
echo   4. Confirme que o objeto carregado veio do repository esperado.
echo.
echo Consulte docs\REPOSITORY.md e docs\TESTING.md.
exit /b 0
