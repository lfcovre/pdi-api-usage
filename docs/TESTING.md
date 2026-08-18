# Testes, logs e critérios de validação

Este documento descreve como validar os exemplos do projeto e explica a diferença entre a saída produzida pelo cliente HTTP (`curl`/`.bat`) e o log interno de execução do Pentaho Data Integration (PDI).

## 1. Dois pontos de observação diferentes

Ao executar um dos scripts `.bat`, existem dois pontos de observação independentes.

### 1.1 Saída do cliente HTTP

É a saída mostrada no PowerShell ou Prompt de Comando que executou o `.bat`.

Ela pode conter:

- endpoint chamado;
- arquivo ou objeto solicitado;
- parâmetros enviados;
- corpo devolvido pela API;
- código HTTP;
- erros do `curl`.

Exemplo:

```text
HTTP_STATUS=200

[OK] Requisicao concluida.
```

Essa saída **não deve ser confundida com o log completo da Transformation ou do Job**.

### 1.2 Log do PDI no Pentaho Server

No Pentaho Server, as execuções PDI podem ser verificadas no arquivo:

```text
<PENTAHO_SERVER_HOME>\logs\pdi.log
```

É nesse arquivo que podem aparecer informações como:

- início da Transformation ou Job;
- execução de steps e job entries;
- quantidade de linhas processadas;
- erros de execução;
- mensagens escritas pelos próprios artefatos PDI;
- valor recebido no parâmetro `P_MESSAGE` usado neste projeto.

Os artefatos de teste escrevem uma mensagem com o prefixo:

```text
[PDI API TEST]
```

Esse prefixo foi escolhido para facilitar a localização das execuções no log.

## 2. Acompanhando `pdi.log` em tempo real com PowerShell

Defina primeiro o caminho real do arquivo em seu ambiente:

```powershell
$PdiLog = "C:\caminho\pentaho-server\logs\pdi.log"
```

### 2.1 Exibir as últimas linhas e continuar acompanhando

```powershell
Get-Content $PdiLog -Tail 100 -Wait
```

O PowerShell mostra as últimas 100 linhas e continua exibindo novas linhas conforme forem gravadas.

Use `Ctrl+C` para encerrar o acompanhamento.

### 2.2 Mostrar somente as mensagens dos artefatos deste projeto

```powershell
Get-Content $PdiLog -Tail 100 -Wait |
    Select-String "PDI API TEST"
```

Com esse filtro, a validação deve mostrar mensagens semelhantes a:

```text
[PDI API TEST] Transformation executada. P_MESSAGE=Mensagem enviada pela API REST do PDI
```

ou:

```text
[PDI API TEST] Job executado. P_MESSAGE=Mensagem enviada pela API REST do PDI
```

### 2.3 Acompanhar referências aos dois artefatos de teste

```powershell
Get-Content $PdiLog -Tail 100 -Wait |
    Select-String -Pattern "PDI API TEST|trf_api_test|job_api_test"
```

Esse filtro é útil quando se deseja acompanhar também início, término e mensagens dos steps/job entries relacionados aos artefatos.

### 2.4 Pesquisar mensagens já existentes no arquivo

Para pesquisar o log sem acompanhamento em tempo real:

```powershell
Select-String -Path $PdiLog -Pattern "PDI API TEST"
```

Para incluir duas linhas anteriores e posteriores a cada ocorrência:

```powershell
Select-String -Path $PdiLog -Pattern "PDI API TEST" -Context 2,2
```

## 3. Log e validacao no Carte Standalone

No Ex04, o executor nao e o Pentaho Server, mas o **Carte Standalone**. Para os testes iniciais, mantenha aberto o terminal em que `Carte.bat` foi iniciado e acompanhe as mensagens produzidas pelo Carte.

O projeto usa a porta:

```text
9090
```

Antes de executar os `.bat`, voce pode validar a porta no PowerShell:

```powershell
Test-NetConnection localhost -Port 9090
```

O resultado esperado inclui:

```text
TcpTestSucceeded : True
```

Durante a execucao do Ex04, procure no terminal do Carte pelo prefixo:

```text
[PDI API TEST]
```

A configuracao e o procedimento completo de inicializacao estao em [`CARTE.md`](CARTE.md).

## 4. Executando os scripts pelo PowerShell

É preferível executar os arquivos `.bat` a partir de um terminal durante os testes, pois assim a saída permanece disponível para análise.

Exemplo para o Ex01:

```powershell
cd C:\caminho\pdi-api-usage\scripts\curl\c01_pentaho_server\ex01_filesystem

.\execute_transformation.bat
.\execute_job.bat
```

Executar o arquivo por duplo clique pode fazer a janela fechar imediatamente após o término.

Os scripts não usam `pause` propositalmente, pois isso permite que continuem adequados para execução automatizada.

## 5. Critério de validação dos exemplos

Para considerar um teste válido, não é suficiente observar somente uma das evidências.

Use o seguinte conjunto:

1. o `curl` deve terminar sem erro de transporte;
2. a API deve retornar um código HTTP de sucesso;
3. o PDI deve registrar a execução no log do executor;
4. a mensagem `[PDI API TEST]` deve aparecer;
5. o valor de `P_MESSAGE` deve ser o valor enviado pelo script;
6. não deve haver erro de execução da Transformation ou Job.

## 6. Ex01 - resultado validado

O **Ex01 - Pentaho Server + filesystem** foi validado em 17/08/2026 para os dois artefatos.

### 6.1 Transformation

A chamada de:

```text
/pentaho/kettle/executeTrans
```

retornou:

```text
HTTP_STATUS=200
```

sem corpo relevante de sucesso.

O `pdi.log` confirmou a execução e registrou:

```text
[PDI API TEST] Transformation executada. P_MESSAGE=Mensagem enviada pela API REST do PDI
```

Também foram observadas mensagens de conclusão dos steps `Generate Test Row` e `Write API Message To Log` sem erros.

### 6.2 Job

A chamada de:

```text
/pentaho/kettle/executeJob
```

retornou `HTTP_STATUS=200` e um corpo XML semelhante a:

```xml
<webresult>
  <result>OK</result>
  <message>Job started</message>
  <id>...</id>
</webresult>
```

O identificador em `<id>` é gerado para a execução e pode variar a cada chamada.

O `pdi.log` confirmou:

```text
[PDI API TEST] Job executado. P_MESSAGE=Mensagem enviada pela API REST do PDI
```

Também foi observado o término do job entry com resultado `true` e a finalização do Job.

### 6.3 Observação sobre níveis de log

Durante a validação, algumas mensagens de início/fim do Job foram registradas pelo PDI como `WARN`, embora o Job tenha terminado com sucesso.

Portanto, uma linha isolada com nível `WARN` não deve ser interpretada automaticamente como falha. A validação deve considerar o conjunto da execução: resultado do job entry, ausência de erros, mensagem de teste, resposta HTTP e término da execução.


## 7. Ex04 - resultado validado

O **Ex04 - Carte Standalone + filesystem** foi validado em 18/08/2026 para Transformation e Job, com Carte iniciado em `http://localhost:9090`.

### 7.1 Transformation

A chamada de:

```text
/kettle/executeTrans/
```

retornou:

```text
HTTP_STATUS=200
```

O terminal do Carte confirmou:

```text
[PDI API TEST] Transformation executada. P_MESSAGE=Mensagem enviada pela API REST do PDI
```

### 7.2 Job

A chamada de:

```text
/kettle/executeJob/
```

retornou `HTTP_STATUS=200` e um corpo XML semelhante a:

```xml
<webresult>
  <result>OK</result>
  <message>Job started</message>
  <id>...</id>
</webresult>
```

O terminal do Carte confirmou:

```text
[PDI API TEST] Job executado. P_MESSAGE=Mensagem enviada pela API REST do PDI
```

e o término do Job com `result=[true]`.

## 8. Troubleshooting: HTTP 301 no Carte

Durante os testes, chamar o endpoint sem a barra final:

```text
http://localhost:9090/kettle/executeTrans
```

retornou `HTTP_STATUS=301`. A inspeção dos headers mostrou:

```text
Location: /kettle/executeTrans/?trans=...
```

Para inspecionar um redirecionamento sem segui-lo automaticamente, pode-se usar:

```powershell
curl.exe `
  --silent `
  --show-error `
  --dump-header - `
  --output NUL `
  --user cluster:cluster `
  --get `
  --data-urlencode "trans=C:\caminho\trf_api_test.ktr" `
  "http://localhost:9090/kettle/executeTrans"
```

O Ex04 usa diretamente as URLs canônicas com barra final:

```text
/kettle/executeTrans/
/kettle/executeJob/
```

Os scripts não usam `--location` de propósito. Seguir automaticamente um `301` poderia esconder um endpoint incorreto. Para estes exemplos, somente respostas `2xx` são tratadas como sucesso HTTP.

## 9. Salvando a saída do cliente em arquivo

Caso seja necessário registrar também a saída do `.bat`, o próprio shell pode redirecioná-la:

```powershell
.\execute_transformation.bat *> transformation-client.log
```

ou, usando redirecionamento compatível com `cmd.exe`:

```cmd
execute_transformation.bat > transformation-client.log 2>&1
```

Esse arquivo registra a perspectiva do **cliente HTTP**. Ele continua sendo diferente do `pdi.log`, que registra a perspectiva do **PDI no servidor**.


## 10. Validacao dos Ex02 e Ex05

O **Ex05 foi validado**. O **Ex02 foi investigado, mas nao validado** no ambiente Pentaho Server atual.

Para novos ambientes ou repeticao dos testes, confirme:

1. `PDI_REPOSITORY_NAME` corresponde ao nome conhecido pelo executor;
2. o executor consegue localizar seu `repositories.xml`;
3. `PDI_REPOSITORY_USER` e `PDI_REPOSITORY_PASSWORD` autenticam no repository;
4. `trf_api_test` e `job_api_test` existem na pasta configurada;
5. os caminhos `PDI_REPOSITORY_TRANS` e `PDI_REPOSITORY_JOB` nao sao caminhos locais do Windows.

O criterio de sucesso para um cenario de repository explicito continua sendo:

- resposta HTTP `2xx`;
- mensagem `[PDI API TEST]` no log do executor;
- valor correto de `P_MESSAGE`;
- ausencia de erros de execucao.

Consulte [`REPOSITORY.md`](REPOSITORY.md) para o passo a passo.


### 10.1 Ex05 - resultado validado

A Transformation e o Job retornaram `HTTP_STATUS=200`. O terminal do Carte mostrou:

```text
RepositoriesMeta - Reading repositories XML file: C:\Users\sofintech\.kettle\repositories.xml
```

seguido da criacao/sincronizacao dos servicos `PurRepositoryConnector` e das mensagens:

```text
[PDI API TEST] Transformation executada. P_MESSAGE=Mensagem enviada pela API REST do PDI
[PDI API TEST] Job executado. P_MESSAGE=Mensagem enviada pela API REST do PDI
```

O Job terminou com `result=[true]`.

### 10.2 Ex02 - resultado da investigacao

A chamada ao Pentaho Server retornou HTTP 500 e `Unable to find repository: localhost`. Como o Ex05 validou posteriormente exatamente o mesmo repository `localhost`, `repositories.xml`, credenciais e caminhos, o Ex02 permanece registrado como **investigado / nao validado no ambiente atual**.

### 10.3 Descobrindo o PID atual do Pentaho Server no Windows

O PID do Java pode mudar apos reinicializacao. Se houver apenas um `java.exe` em execucao:

```powershell
(Get-Process java).Id
```

Se houver mais de um processo Java (por exemplo Pentaho Server, Spoon ou Carte), liste primeiro os processos:

```powershell
Get-CimInstance Win32_Process -Filter "name='java.exe'" |
    Select-Object ProcessId, ExecutablePath, CommandLine
```

Outra opcao e usar o `jcmd` da instalacao Java e listar as JVMs conhecidas:

```powershell
& "C:\Program Files\Java\jdk-21\bin\jcmd.exe" -l
```

Depois use o PID real, sem os caracteres `<` e `>`:

```powershell
& "C:\Program Files\Java\jdk-21\bin\jcmd.exe" `
    9824 VM.system_properties |
    Select-String "user.home|user.dir|KETTLE_HOME"
```

`9824` e apenas um exemplo de PID observado durante os testes; ele pode mudar.
