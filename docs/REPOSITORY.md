# Execucao a partir de repository explicito

Este documento descreve os pre-requisitos e o funcionamento dos exemplos **Ex02** e **Ex05**.

- **Ex02**: Pentaho Server + repository explicito
- **Ex05**: Carte Standalone + repository explicito

Ambos usam os endpoints `executeTrans` e `executeJob` e informam explicitamente na requisicao o repository que deve ser aberto e as credenciais usadas para conectar a ele.

## 1. O que significa "repository explicito"

A chamada envia parametros semelhantes a:

```text
rep=<nome do repository>
user=<usuario do repository>
pass=<senha do repository>
trans=/pasta/trf_api_test
```

ou:

```text
rep=<nome do repository>
user=<usuario do repository>
pass=<senha do repository>
job=/pasta/job_api_test
```

Ha uma diferenca importante entre esses parametros e a autenticacao HTTP:

```text
Cliente curl
   |
   | HTTP Basic: PENTAHO_SERVER_USER/PASSWORD ou CARTE_USER/PASSWORD
   v
Pentaho Server / Carte
   |
   | rep + user + pass
   v
PDI Repository
```

Portanto existem **duas camadas de autenticacao**:

1. `curl --user ...` autentica a requisicao HTTP no Pentaho Server ou Carte;
2. `user` e `pass` na query sao usados pelo PDI para abrir o repository selecionado por `rep`.

Os valores podem coincidir em um ambiente de testes, mas representam responsabilidades diferentes.

## 2. O que o parametro `rep` realmente identifica

Embora algumas descricoes da API usem o termo "repository id", a implementacao atual procura o valor recebido em `rep` pelo **nome do repository** carregado pelo PDI.

Assim, se o repository aparece no PDI client como:

```text
PentahoRepository
```

configure:

```bat
set "PDI_REPOSITORY_NAME=PentahoRepository"
```

Use exatamente o nome configurado no ambiente.

## 3. O repository ainda precisa estar conhecido pelo executor

Informar `rep`, `user` e `pass` nao transmite ao servidor todos os metadados necessarios para descobrir o repository.

O Pentaho Server ou Carte precisa conseguir carregar uma definicao correspondente a `PDI_REPOSITORY_NAME` a partir de seu ambiente PDI, normalmente por meio de `repositories.xml`.

Em outras palavras:

```text
rep=PentahoRepository
```

nao informa automaticamente tipo, URL e demais propriedades de conexao. Ele apenas seleciona uma definicao de repository que o executor ja conhece.

### Carte Standalone

Para executar objetos de repository no Carte, certifique-se de que o usuario do sistema operacional que inicia `Carte.bat` tenha acesso ao `repositories.xml` apropriado.

A forma mais segura para este teste e usar o arquivo `repositories.xml` ja gerado/configurado pelo Spoon e disponibiliza-lo no ambiente do usuario que inicia o Carte. Nao e recomendado criar esse XML manualmente apenas para o exemplo.

Se Spoon e Carte sao executados pelo mesmo usuario Windows na mesma maquina, eles podem ja enxergar o mesmo diretorio de configuracao PDI. Mesmo assim, confirme o repository antes do teste.

### Pentaho Server

O Pentaho Server tambem possui um ambiente PDI proprio. O fato de Spoon, executado no seu usuario Windows, conhecer um repository nao garante que o processo do Pentaho Server esteja lendo o mesmo `repositories.xml`.

Se o Ex02 retornar "Unable to find repository", valide qual PDI home/configuracao e usada pelo processo do Pentaho Server e se nela existe a definicao com o mesmo nome de `PDI_REPOSITORY_NAME`.

## 4. Publicar os dois artefatos no repository

Antes de executar Ex02/Ex05, salve ou importe no repository:

```text
trf_api_test
job_api_test
```

Uma estrutura sugerida para os testes e:

```text
/public/pdi-api-usage/
├── trf_api_test
└── job_api_test
```

Os arquivos locais de origem continuam no projeto:

```text
pdi/transformations/trf_api_test.ktr
pdi/jobs/job_api_test.kjb
```

Abra-os no Spoon conectado ao repository e use **Save As** para salva-los na pasta escolhida, ou use os mecanismos de importacao disponiveis no PDI.

> O caminho enviado em `trans` ou `job` e um **caminho logico do repository**, nao um caminho do Windows.

## 5. Extensoes `.ktr` e `.kjb`

Nos exemplos de filesystem usamos caminhos como:

```text
C:\...\trf_api_test.ktr
C:\...\job_api_test.kjb
```

No repository a API procura o objeto pelo nome dentro da arvore do repository. Para este projeto, configure os caminhos sem as extensoes:

```bat
set "PDI_REPOSITORY_TRANS=/public/pdi-api-usage/trf_api_test"
set "PDI_REPOSITORY_JOB=/public/pdi-api-usage/job_api_test"
```

A implementacao separa o caminho no ultimo `/`, localiza o diretorio e depois procura o ID da Transformation/Job pelo nome informado.

## 6. Configurar `environment.bat`

Copie `config/environment.example.bat` para `config/environment.bat`, se ainda nao fez isso, e ajuste:

```bat
set "PDI_REPOSITORY_NAME=PentahoRepository"
set "PDI_REPOSITORY_USER=admin"
set "PDI_REPOSITORY_PASSWORD=password"
set "PDI_REPOSITORY_TRANS=/public/pdi-api-usage/trf_api_test"
set "PDI_REPOSITORY_JOB=/public/pdi-api-usage/job_api_test"
```

Use os valores reais do seu ambiente.

## 7. Ex02 - Pentaho Server

Transformation:

```powershell
cd C:\caminho\pdi-api-usage\scripts\curl\c01_pentaho_server\ex02_repository_execute
.\execute_transformation.bat
```

Job:

```powershell
.\execute_job.bat
```

Os scripts chamam:

```text
http://localhost:8080/pentaho/kettle/executeTrans
http://localhost:8080/pentaho/kettle/executeJob
```

A validacao permanece no:

```text
<PENTAHO_SERVER_HOME>\logs\pdi.log
```

Procure por:

```text
[PDI API TEST]
```

## 8. Ex05 - Carte Standalone

O Carte continua usando:

```text
http://localhost:9090
```

Para este exemplo, alem de iniciar o Carte, confirme que seu processo consegue localizar a definicao de repository indicada por `PDI_REPOSITORY_NAME`.

Transformation:

```powershell
cd C:\caminho\pdi-api-usage\scripts\curl\c02_carte_standalone\ex05_repository_execute
.\execute_transformation.bat
```

Job:

```powershell
.\execute_job.bat
```

Os endpoints usam barra final, conforme validado no Ex04:

```text
http://localhost:9090/kettle/executeTrans/
http://localhost:9090/kettle/executeJob/
```

Acompanhe o terminal em que `Carte.bat` esta sendo executado e procure por `[PDI API TEST]`.

## 9. O que muda em relacao ao filesystem

| Aspecto | Filesystem (Ex01/Ex04) | Repository explicito (Ex02/Ex05) |
|---|---|---|
| `rep` | nao enviado | enviado |
| `user`/`pass` de repository | nao enviados | enviados |
| `trans`/`job` | caminho de arquivo | caminho logico do objeto |
| `.ktr`/`.kjb` no parametro | sim | normalmente nao |
| `repositories.xml` | nao necessario para localizar o arquivo | necessario para descobrir o repository |
| origem do artefato | filesystem do executor | repository PDI |

## 10. Erros comuns

### Repository nao encontrado

Sintomas possiveis:

```text
Unable to find repository
```

ou resposta HTTP de erro.

Verifique:

- `PDI_REPOSITORY_NAME`;
- se o nome corresponde exatamente ao repository conhecido pelo executor;
- qual `repositories.xml` o processo esta lendo;
- se Spoon e o servidor/Carte estao rodando sob usuarios diferentes.

### HTTP 401

Pode indicar falha de autenticacao. Lembre que ha duas autenticacoes diferentes:

- HTTP Basic (`--user` do curl);
- usuario/senha do repository (`user`/`pass` da API).

Analise o corpo devolvido pela API e o log do executor para identificar em qual camada ocorreu a falha.

### HTTP 404 ou objeto nao encontrado

Verifique:

- pasta do repository;
- nome do objeto;
- uso de `/` como separador;
- se `PDI_REPOSITORY_TRANS`/`PDI_REPOSITORY_JOB` estao sem extensao;
- se o artefato foi realmente salvo/importado no repository usado pelo teste.

## 11. Observacao de seguranca

O contrato desses endpoints recebe `user` e `pass` do repository como parametros da requisicao. Como sao parametros de query, eles podem aparecer em logs HTTP, proxies ou ferramentas intermediarias.

Use credenciais de laboratorio para estes exemplos. Em ambientes reais, use HTTPS e avalie cuidadosamente a exposicao de credenciais antes de adotar esse modelo de integracao.
