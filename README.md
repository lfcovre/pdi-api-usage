# PDI API Usage

Projeto de estudo e referencia pratica para executar **Pentaho Data Integration (PDI)** Jobs (`.kjb`) e Transformations (`.ktr`) por HTTP usando as APIs expostas pelo **Pentaho Server** e pelo **Carte Standalone**.

O projeto esta sendo construido de forma incremental. Os cenarios de **filesystem** (Ex01 e Ex04) e o **repository explicito no Carte Standalone** (Ex05) ja foram validados. O Ex02 foi implementado e investigado no ambiente de testes, mas o Carte incorporado ao Pentaho Server nao localizou a definicao de repository informada em `rep`.

## Objetivos

- demonstrar chamadas reais usando `curl`;
- comparar Pentaho Server e Carte Standalone;
- testar Transformations e Jobs separadamente;
- validar passagem de parametros pela API;
- diferenciar filesystem, repository explicito e repository pre-configurado;
- registrar comportamento esperado, limitacoes e APIs legadas sem mistura-las com o fluxo recomendado.

## Cenários planejados

| Exemplo | Executor | Origem / modo | Endpoint | Status |
|---|---|---|---|---|
| **Ex01** | Pentaho Server | Filesystem | `executeTrans` / `executeJob` | **Validado** |
| **Ex02** | Pentaho Server | Repository explicito | `executeTrans` / `executeJob` | Investigado / nao validado no ambiente atual |
| **Ex03** | Pentaho Server | Repository pre-configurado | `runTrans` / `runJob` | Planejado / validar |
| **Ex04** | Carte Standalone | Filesystem | `executeTrans` / `executeJob` | **Validado** |
| **Ex05** | Carte Standalone | Repository explicito | `executeTrans` / `executeJob` | **Validado** |
| **Ex06** | Carte Standalone | Repository pre-configurado | `runTrans` / `runJob` | Planejado |

> Os exemplos de monitoramento, Scheduler API e APIs depreciadas foram registrados em [`docs/ROADMAP.md`](docs/ROADMAP.md) e serao tratados depois dos seis cenarios principais.

## Estrutura atual

```text
pdi-api-usage/
├── .gitignore
├── README.md
├── config/
│   ├── environment.example.bat
│   └── carte/
│       ├── carte-filesystem.example.xml
│       └── carte-repository.example.xml
├── docs/
│   ├── CARTE.md
│   ├── CURL.md
│   ├── REPOSITORY.md
│   ├── ROADMAP.md
│   └── TESTING.md
├── pdi/
│   ├── transformations/
│   │   └── trf_api_test.ktr
│   └── jobs/
│       └── job_api_test.kjb
└── scripts/
    └── curl/
        ├── c01_pentaho_server/
        │   ├── ex01_filesystem/
        │   │   ├── execute_transformation.bat
        │   │   └── execute_job.bat
        │   └── ex02_repository_execute/
        │       ├── execute_transformation.bat
        │       └── execute_job.bat
        └── c02_carte_standalone/
            ├── ex04_filesystem/
            │   ├── execute_transformation.bat
            │   └── execute_job.bat
            └── ex05_repository_execute/
                ├── execute_transformation.bat
                └── execute_job.bat
```

## Artefatos PDI de teste

Os dois artefatos usam o mesmo parametro nomeado:

```text
P_MESSAGE
```

A chamada HTTP envia um valor para esse parametro e o artefato grava a mensagem no log do PDI.

### Transformation

`pdi/transformations/trf_api_test.ktr`

Fluxo:

```text
Generate Test Row
        |
        v
Write API Message To Log
```

A Transformation gera apenas uma linha e registra no log:

```text
[PDI API TEST] Transformation executada. P_MESSAGE=<valor recebido>
```

### Job

`pdi/jobs/job_api_test.kjb`

Fluxo:

```text
START
  |
  v
Write API Message To Log
```

O Job registra:

```text
[PDI API TEST] Job executado. P_MESSAGE=<valor recebido>
```

## Configuracao do ambiente

Copie:

```bat
config\environment.example.bat
```

para:

```bat
config\environment.bat
```

Depois ajuste URL e credenciais conforme seu ambiente.

Exemplo:

```bat
set "PENTAHO_SERVER_URL=http://localhost:8080/pentaho"
set "PENTAHO_SERVER_USER=admin"
set "PENTAHO_SERVER_PASSWORD=password"

set "CARTE_URL=http://localhost:9090"
set "CARTE_USER=cluster"
set "CARTE_PASSWORD=cluster"

set "PDI_LOG_LEVEL=Basic"
set "PDI_TEST_MESSAGE=Mensagem enviada pela API REST do PDI"
```

`config/environment.bat` esta no `.gitignore` porque pode conter credenciais reais. O arquivo `environment.example.bat` possui somente valores de exemplo.

Se `environment.bat` nao existir, os scripts desta primeira etapa usam `environment.example.bat` e exibem um aviso.

## Ex01 - Pentaho Server + filesystem

Arquivos:

```text
scripts/curl/c01_pentaho_server/ex01_filesystem/
├── execute_transformation.bat
└── execute_job.bat
```

Os endpoints usados sao:

```text
/pentaho/kettle/executeTrans
/pentaho/kettle/executeJob
```

### Importante: de quem e o filesystem?

O caminho passado em `trans` ou `job` e aberto pelo **processo do Pentaho Server**.

Portanto, mesmo que o `curl` seja executado em outra maquina, o arquivo precisa estar acessivel no filesystem visto pelo servidor.

Nesta estrutura os scripts calculam automaticamente caminhos como:

```text
<projeto>\pdi\transformations\trf_api_test.ktr
<projeto>\pdi\jobs\job_api_test.kjb
```

Isso funciona diretamente quando o cliente e o Pentaho Server estao na mesma maquina e compartilham esse caminho. Em um teste remoto, ajuste a estrategia para informar um caminho valido na maquina do servidor.

## Ex04 - Carte Standalone + filesystem

Arquivos:

```text
scripts/curl/c02_carte_standalone/ex04_filesystem/
├── execute_transformation.bat
└── execute_job.bat
```

Os endpoints usados sao:

```text
/kettle/executeTrans/
/kettle/executeJob/
```

Neste projeto, o Carte usa a porta **9090** para nao conflitar com o Pentaho Server local, que normalmente esta em `8080`.

Ha duas formas documentadas de iniciar o Carte para este exemplo:

**Inicializacao rapida, sem arquivo XML:**

```bat
Carte.bat localhost 9090
```

**Inicializacao usando o XML fornecido pelo projeto:**

```bat
Carte.bat "C:\caminho\pdi-api-usage\config\carte\carte-filesystem.example.xml"
```

O arquivo `carte-filesystem.example.xml` pode permanecer dentro do repositorio. Nao e necessario copia-lo para a pasta do PDI: basta fornecer ao `Carte.bat` o caminho completo do XML.

Antes de executar o Ex04, confirme que o Carte iniciou em `http://localhost:9090/` e mantenha o terminal do Carte aberto para acompanhar suas mensagens.

Assim como no Pentaho Server, o caminho do `.ktr` ou `.kjb` precisa ser acessivel ao **processo do Carte**.

O passo a passo completo de configuracao, inicializacao, localizacao do XML e validacao esta em [`docs/CARTE.md`](docs/CARTE.md).


## Ex02 e Ex05 - repository explicito

Estes exemplos continuam usando `executeTrans` e `executeJob`, mas acrescentam:

```text
rep
user
pass
```

Quando `rep` e informado, `trans` e `job` passam a representar caminhos logicos dentro do repository, e nao caminhos de arquivos locais.

Exemplo:

```text
/public/pdi-api-usage/trf_api_test
/public/pdi-api-usage/job_api_test
```

O executor ainda precisa conhecer a definicao do repository em seu ambiente PDI. O procedimento completo, incluindo `repositories.xml`, publicacao dos artefatos, duas camadas de autenticacao e troubleshooting, esta em [`docs/REPOSITORY.md`](docs/REPOSITORY.md).

### Resultado atual dos testes de repository explicito

No ambiente de validacao deste projeto:

- **Ex05 / Carte Standalone:** validado. O Carte leu explicitamente `C:\Users\sofintech\.kettle\repositories.xml`, conectou ao repository `localhost` e executou Transformation e Job;
- **Ex02 / Pentaho Server:** investigado, mas nao validado. A chamada retornou `Unable to find repository: localhost` antes de autenticar no repository ou procurar o objeto.

Esse resultado demonstra que o mesmo `repositories.xml`, nome de repository, credenciais e caminhos logicos funcionam no Carte Standalone. Portanto, o erro observado no Ex02 esta relacionado ao contexto do Carte incorporado ao Pentaho Server e nao aos dados basicos de configuracao usados pelo Ex05.

## Como os parametros sao enviados

Os scripts usam `--data-urlencode` em vez de montar manualmente a query string. Exemplo conceitual:

```bat
curl.exe ^
  --user "usuario:senha" ^
  --get ^
  --data-urlencode "trans=C:\caminho\trf_api_test.ktr" ^
  --data-urlencode "level=Basic" ^
  --data-urlencode "P_MESSAGE=Teste via API" ^
  "http://localhost:9090/kettle/executeTrans/"
```

Isso evita depender de aspas escapadas para caminhos com espacos e faz o URL encoding dos parametros.

Os proprios scripts possuem comentarios explicando cada opcao usada no comando (`--silent`, `--show-error`, `--fail-with-body`, `--user`, `--get`, `--data-urlencode` e `--write-out`). Uma explicacao mais detalhada, incluindo a diferenca entre opcoes do `curl` e parametros enviados ao PDI, esta em [`docs/CURL.md`](docs/CURL.md).

`P_MESSAGE` foi declarado nos dois artefatos PDI. Assim, o valor recebido pode ser verificado diretamente no log da execucao.

## Executando e validando os testes

1. Abra `trf_api_test.ktr` e `job_api_test.kjb` no Spoon para confirmar que os plugins usados estao disponiveis na sua versao do PDI.
2. Crie `config/environment.bat` a partir do arquivo de exemplo e ajuste as configuracoes.
3. Inicie o Pentaho Server ou o Carte.
4. Execute o `.bat` correspondente ao teste desejado, preferencialmente a partir de um PowerShell ou Prompt de Comando.
5. Verifique a resposta da API e o `HTTP_STATUS` mostrado pelo script.
6. Verifique também o log do executor e confirme que `P_MESSAGE` foi recebido pelo artefato PDI.

### Saida do `.bat` x log do PDI

A saída do `.bat` representa a perspectiva do **cliente HTTP**: chamada realizada, resposta da API, erros do `curl` e status HTTP. Ela não é o log completo da Transformation ou Job.

No Pentaho Server, o log das execuções PDI pode ser acompanhado em:

```text
<PENTAHO_SERVER_HOME>\logs\pdi.log
```

No PowerShell, por exemplo:

```powershell
$PdiLog = "C:\caminho\pentaho-server\logs\pdi.log"
Get-Content $PdiLog -Tail 100 -Wait
```

Para mostrar somente as mensagens produzidas pelos artefatos deste projeto:

```powershell
Get-Content $PdiLog -Tail 100 -Wait |
    Select-String "PDI API TEST"
```

Um filtro mais amplo pode acompanhar também referências aos dois arquivos de teste:

```powershell
Get-Content $PdiLog -Tail 100 -Wait |
    Select-String -Pattern "PDI API TEST|trf_api_test|job_api_test"
```

O guia detalhado, incluindo pesquisa histórica, contexto e critérios de validação, está em [`docs/TESTING.md`](docs/TESTING.md).

## Resultado do Ex01

O Ex01 foi validado para Transformation e Job. Nos testes realizados:

- `executeTrans` retornou `HTTP_STATUS=200` e o `pdi.log` confirmou a mensagem `[PDI API TEST]` com o valor enviado em `P_MESSAGE`;
- `executeJob` retornou `HTTP_STATUS=200`, `Job started` e um identificador de execução em `<id>`;
- o `pdi.log` confirmou o recebimento de `P_MESSAGE` pelo Job e o término do job entry com resultado `true`.

Os detalhes e exemplos de saída estão registrados em [`docs/TESTING.md`](docs/TESTING.md).

## Resultado do Ex04

O Ex04 foi validado para Transformation e Job em Carte Standalone na porta `9090`. Nos testes realizados:

- `executeTrans/` retornou `HTTP_STATUS=200` e o terminal do Carte confirmou `[PDI API TEST]` com o valor recebido em `P_MESSAGE`;
- `executeJob/` retornou `HTTP_STATUS=200`, `Job started` e um identificador em `<id>`;
- o terminal do Carte confirmou o recebimento de `P_MESSAGE` pelo Job e o término com `result=[true]`.

Durante a validação foi observado que chamar os endpoints Carte sem a barra final (`/kettle/executeTrans` e `/kettle/executeJob`) pode retornar `HTTP 301`, redirecionando para a URL com `/`. Por isso os scripts do Ex04 usam explicitamente `/kettle/executeTrans/` e `/kettle/executeJob/`.

Os detalhes do `301` e o procedimento de diagnóstico estão em [`docs/TESTING.md`](docs/TESTING.md).

## Observacoes sobre a resposta HTTP

Transformation e Job nao devem ser tratados como se necessariamente devolvessem o mesmo tipo de resposta.

Nos endpoints `executeTrans` / `executeJob`, a implementacao do PDI possui diferencas no ciclo de execucao. Por isso, nesta fase, o criterio de validacao comum e:

- chamada HTTP sem erro;
- `HTTP_STATUS` de sucesso;
- execucao registrada no log;
- `P_MESSAGE` recebido corretamente pelo artefato.

O tratamento de IDs de execucao, consulta de status e controle remoto sera documentado posteriormente no bloco de monitoramento.

## Repository pre-configurado

O arquivo:

```text
config/carte/carte-repository.example.xml
```

foi incluido apenas como referencia para o futuro **Ex06**. Ele ainda nao faz parte do Ex04.

Nesse modelo, o Carte e iniciado com uma configuracao que informa qual repository deve ser aberto. O cliente pode entao usar `runTrans` / `runJob` sem enviar `rep`, usuario e senha do repository a cada chamada.

A implementacao completa desse caso sera feita depois dos exemplos de repository explicito.

## Proximas etapas

Com Ex01, Ex04 e Ex05 validados, a proxima etapa e **reavaliar os cenarios do Pentaho Server antes de implementar Ex03** e, em paralelo, preparar o **Ex06 - Carte Standalone + repository pre-configurado** com `runTrans` / `runJob`.

O Ex02 permanece no projeto como cenario implementado e investigado, com o resultado `Unable to find repository: localhost` registrado para o Carte incorporado ao Pentaho Server. Nao serao feitas alteracoes adicionais no Server apenas para forcar uma simetria com o Carte Standalone sem antes revisar o modelo tecnico do exemplo.

Consulte [`docs/ROADMAP.md`](docs/ROADMAP.md) para os blocos futuros de monitoramento, Scheduler API e APIs legadas.
