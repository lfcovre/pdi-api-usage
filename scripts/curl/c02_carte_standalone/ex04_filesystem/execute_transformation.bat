@echo off
setlocal EnableExtensions

rem Ex04 - Carte Standalone + filesystem + Transformation
rem O caminho do arquivo e interpretado pelo processo do Carte, nao pelo curl.

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

set "TRANS_PATH=%PROJECT_ROOT%\pdi\transformations\trf_api_test.ktr"

if not exist "%TRANS_PATH%" (
  echo [ERRO] Transformation nao encontrada: "%TRANS_PATH%"
  exit /b 4
)

if not defined CARTE_URL (
  echo [ERRO] CARTE_URL nao definida.
  exit /b 5
)

if not defined PDI_LOG_LEVEL set "PDI_LOG_LEVEL=Basic"
if not defined PDI_TEST_MESSAGE set "PDI_TEST_MESSAGE=Mensagem enviada pela API REST do PDI"

echo ============================================================
echo Ex04 - Carte Standalone / Filesystem / Transformation
echo Endpoint : %CARTE_URL%/kettle/executeTrans
echo Arquivo  : %TRANS_PATH%
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
rem Parametros PDI: trans = caminho do .ktr; level = nivel de log; P_MESSAGE = parametro do teste.
rem Detalhes: docs\CURL.md
rem ---------------------------------------------------------------------------

curl.exe ^
  --silent ^
  --show-error ^
  --fail-with-body ^
  --user "%CARTE_USER%:%CARTE_PASSWORD%" ^
  --get ^
  --data-urlencode "trans=%TRANS_PATH%" ^
  --data-urlencode "level=%PDI_LOG_LEVEL%" ^
  --data-urlencode "P_MESSAGE=%PDI_TEST_MESSAGE%" ^
  --write-out "\nHTTP_STATUS=%%{http_code}\n" ^
  "%CARTE_URL%/kettle/executeTrans"

set "CURL_EXIT=%ERRORLEVEL%"
echo.

if not "%CURL_EXIT%"=="0" (
  echo [ERRO] A chamada curl terminou com codigo %CURL_EXIT%.
  exit /b %CURL_EXIT%
)

echo [OK] Requisicao concluida. Confira tambem o console/log do Carte.
exit /b 0
