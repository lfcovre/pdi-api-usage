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

## 3. Executando os scripts pelo PowerShell

É preferível executar os arquivos `.bat` a partir de um terminal durante os testes, pois assim a saída permanece disponível para análise.

Exemplo para o Ex01:

```powershell
cd C:\caminho\pdi-api-usage\scripts\curl\c01_pentaho_server\ex01_filesystem

.\execute_transformation.bat
.\execute_job.bat
```

Executar o arquivo por duplo clique pode fazer a janela fechar imediatamente após o término.

Os scripts não usam `pause` propositalmente, pois isso permite que continuem adequados para execução automatizada.

## 4. Critério de validação dos exemplos

Para considerar um teste válido, não é suficiente observar somente uma das evidências.

Use o seguinte conjunto:

1. o `curl` deve terminar sem erro de transporte;
2. a API deve retornar um código HTTP de sucesso;
3. o PDI deve registrar a execução no log do executor;
4. a mensagem `[PDI API TEST]` deve aparecer;
5. o valor de `P_MESSAGE` deve ser o valor enviado pelo script;
6. não deve haver erro de execução da Transformation ou Job.

## 5. Ex01 - resultado validado

O **Ex01 - Pentaho Server + filesystem** foi validado em 17/08/2026 para os dois artefatos.

### 5.1 Transformation

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

### 5.2 Job

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

### 5.3 Observação sobre níveis de log

Durante a validação, algumas mensagens de início/fim do Job foram registradas pelo PDI como `WARN`, embora o Job tenha terminado com sucesso.

Portanto, uma linha isolada com nível `WARN` não deve ser interpretada automaticamente como falha. A validação deve considerar o conjunto da execução: resultado do job entry, ausência de erros, mensagem de teste, resposta HTTP e término da execução.

## 6. Salvando a saída do cliente em arquivo

Caso seja necessário registrar também a saída do `.bat`, o próprio shell pode redirecioná-la:

```powershell
.\execute_transformation.bat *> transformation-client.log
```

ou, usando redirecionamento compatível com `cmd.exe`:

```cmd
execute_transformation.bat > transformation-client.log 2>&1
```

Esse arquivo registra a perspectiva do **cliente HTTP**. Ele continua sendo diferente do `pdi.log`, que registra a perspectiva do **PDI no servidor**.
