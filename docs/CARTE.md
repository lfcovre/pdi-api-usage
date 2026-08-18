# Carte Standalone nos exemplos do projeto

Este documento descreve somente o necessario para executar os exemplos deste repositorio com **Carte Standalone**. O objetivo nao e substituir a documentacao completa do Carte ou explicar configuracoes de cluster.

## 1. Porta utilizada neste projeto

O Pentaho Server do ambiente de testes pode estar executando em:

```text
http://localhost:8080/pentaho
```

Por isso, os exemplos Carte deste projeto usam:

```text
http://localhost:9090
```

Isso permite manter Pentaho Server e Carte Standalone em execucao ao mesmo tempo na mesma maquina.

A URL esta centralizada em:

```text
config/environment.bat
```

com o valor de exemplo:

```bat
set "CARTE_URL=http://localhost:9090"
```

## 2. Onde esta o Carte

O executavel do Carte faz parte da instalacao do Pentaho Data Integration (PDI). Em uma instalacao Windows, ele normalmente e iniciado a partir do diretorio `data-integration`, onde existe o arquivo:

```text
Carte.bat
```

Exemplo conceitual:

```text
C:\pentaho\design-tools\data-integration\Carte.bat
```

O caminho exato depende de onde o PDI foi instalado.

## 3. Formas de iniciar o Carte para o Ex04

Para o **Ex04 - Carte Standalone + filesystem**, existem duas formas simples.

### 3.1 Inicializacao rapida sem XML

Abra PowerShell ou Prompt de Comando na pasta `data-integration` e execute:

```bat
Carte.bat localhost 9090
```

Nesse modo, host e porta sao informados diretamente na linha de comando.

Essa e a forma mais curta para validar o Ex04.

### 3.2 Inicializacao usando o XML do projeto

O repositorio fornece:

```text
config/carte/carte-filesystem.example.xml
```

Conteudo principal:

```xml
<slave_config>
  <slaveserver>
    <name>carte-local</name>
    <hostname>localhost</hostname>
    <port>9090</port>
    <username>cluster</username>
    <password>cluster</password>
    <master>N</master>
  </slaveserver>
</slave_config>
```

O arquivo **nao precisa ser copiado para a pasta `data-integration`**. O Carte aceita o caminho do arquivo de configuracao como argumento. Se o XML estiver em outro diretorio, informe o caminho completo.

Por exemplo, estando na pasta `data-integration`:

```bat
Carte.bat "C:\Users\usuario\Documents\projetos\pdi-api-usage\config\carte\carte-filesystem.example.xml"
```

Outra opcao e copiar o XML para `data-integration` e executar apenas:

```bat
Carte.bat carte-filesystem.example.xml
```

Para este projeto, manter o arquivo em `config/carte/` e passar o caminho completo e preferivel, pois a configuracao de exemplo permanece versionada junto com os scripts.

## 4. O que significa cada campo do XML

### `name`

```xml
<name>carte-local</name>
```

Nome logico da instancia Carte.

### `hostname`

```xml
<hostname>localhost</hostname>
```

Endereco em que a instancia e identificada para os exemplos locais.

### `port`

```xml
<port>9090</port>
```

Porta HTTP usada pelo Carte neste projeto.

### `username` e `password`

```xml
<username>cluster</username>
<password>cluster</password>
```

Credenciais de autenticacao HTTP usadas pelos scripts `curl` do Ex04.

Elas correspondem a:

```bat
set "CARTE_USER=cluster"
set "CARTE_PASSWORD=cluster"
```

em `config/environment.bat`.

Essas credenciais nao sao credenciais de repository PDI. A diferenca sera importante nos exemplos Ex05 e Ex06.

No **Ex05**, o Carte usa esta mesma configuracao basica e recebe `rep`, `user` e `pass` na chamada HTTP. O bloco `<repository>` do arquivo `carte-repository.example.xml` **nao e usado no Ex05**; ele fica reservado para o Ex06, no qual `runTrans`/`runJob` usarao um repository pre-configurado no Carte.

### `master`

```xml
<master>N</master>
```

Indica que essa instancia nao esta sendo configurada como master de um cluster. Os exemplos atuais usam Carte apenas como executor standalone.

## 5. Validando se o Carte iniciou

Ao executar `Carte.bat`, mantenha o terminal aberto. Ele mostra as mensagens do processo Carte e sera o primeiro local para diagnosticar erros de inicializacao ou execucao.

Com a configuracao deste projeto, tente acessar no navegador:

```text
http://localhost:9090/
```

Use as credenciais configuradas para o Carte quando solicitado.

Tambem e possivel confirmar que a porta esta em escuta pelo PowerShell:

```powershell
Test-NetConnection localhost -Port 9090
```

O resultado esperado inclui:

```text
TcpTestSucceeded : True
```

Para verificar qual processo esta usando a porta:

```powershell
Get-NetTCPConnection -LocalPort 9090 -State Listen |
    Select-Object LocalAddress, LocalPort, OwningProcess
```

E, se necessario, identificar o processo pelo PID:

```powershell
Get-Process -Id <PID>
```

## 6. Preparando o ambiente do projeto

Copie:

```text
config/environment.example.bat
```

para:

```text
config/environment.bat
```

Confirme pelo menos:

```bat
set "CARTE_URL=http://localhost:9090"
set "CARTE_USER=cluster"
set "CARTE_PASSWORD=cluster"
```

`environment.bat` nao e versionado porque pode conter credenciais reais.

## 7. Executando o Ex04

Com o Carte em execucao, abra outro PowerShell:

```powershell
cd C:\caminho\pdi-api-usage\scripts\curl\c02_carte_standalone\ex04_filesystem
```

Execute a Transformation:

```powershell
.\execute_transformation.bat
```

Depois execute o Job:

```powershell
.\execute_job.bat
```

Os scripts chamam:

```text
http://localhost:9090/kettle/executeTrans/
http://localhost:9090/kettle/executeJob/
```


## 8. Redirecionamento HTTP 301 e barra final

Durante a validação do Ex04, uma chamada para:

```text
http://localhost:9090/kettle/executeTrans
```

retornou `HTTP_STATUS=301` com o header:

```text
Location: /kettle/executeTrans/?trans=...
```

Isso mostrou que, nesse ambiente Carte/PDI 11, a URL canônica do servlet inclui a barra final. Por isso os scripts usam:

```text
http://localhost:9090/kettle/executeTrans/
http://localhost:9090/kettle/executeJob/
```

Os scripts não usam `--location` para esconder esse comportamento. Um redirecionamento inesperado deve ser tratado como condição a investigar, e não como sucesso da execução.

## 9. Onde observar o log no Ex04

No Ex01, executado pelo Pentaho Server, usamos o arquivo `pdi.log` do servidor.

No Ex04, o executor e o **Carte Standalone**. Para este teste inicial, acompanhe principalmente o **terminal em que `Carte.bat` esta executando**, pois nele aparecem as mensagens da execucao.

Procure pelo prefixo criado pelos artefatos deste projeto:

```text
[PDI API TEST]
```

A Transformation deve registrar algo semelhante a:

```text
[PDI API TEST] Transformation executada. P_MESSAGE=Mensagem enviada pela API REST do PDI
```

E o Job:

```text
[PDI API TEST] Job executado. P_MESSAGE=Mensagem enviada pela API REST do PDI
```

A persistencia de logs do Carte pode ser configurada separadamente, mas nao e requisito para validar o Ex04.

## 10. Sobre `carte-repository.example.xml`

O arquivo:

```text
config/carte/carte-repository.example.xml
```

**nao e usado pelo Ex04**.

Ele foi reservado para o futuro **Ex06 - repository pre-configurado** e acrescenta uma secao `<repository>` com nome e credenciais do repository.

Para esse caso, alem do XML de configuracao do Carte, o processo Carte precisara conseguir localizar o `repositories.xml` correspondente. Essa configuracao sera detalhada quando implementarmos o Ex06.

## 11. Referencias oficiais

A documentacao oficial do Pentaho sobre configuracao de Carte mostra a inicializacao passando um arquivo XML ao script `carte.sh`/`Carte.bat` e informa que, quando o XML esta fora do diretorio do Carte, seu caminho deve ser informado no comando.

Para execucoes baseadas em repository, a documentacao tambem informa que o Carte precisa ter acesso ao `repositories.xml`; esse ponto sera aplicado posteriormente no Ex06.


## 12. Repository explicito no Ex05

O Ex05 continua usando o mesmo Carte em `localhost:9090`, mas exige que o processo do Carte consiga localizar uma definicao de repository correspondente a `PDI_REPOSITORY_NAME`.

Isso e diferente do Ex06: no Ex05 as credenciais do repository sao enviadas em cada chamada `executeTrans`/`executeJob`; no Ex06 elas ficarao pre-configuradas no XML do Carte e serao usadas por `runTrans`/`runJob`.

Consulte [`REPOSITORY.md`](REPOSITORY.md) antes de testar o Ex05.


## 13. Uso da configuracao basica no Ex05

O `carte-filesystem.example.xml` nasceu no Ex04, mas sua configuracao de servidor tambem e suficiente para o Ex05. O nome do arquivo descreve a primeira finalidade para a qual foi criado; funcionalmente, ele configura apenas a instancia Carte (`localhost:9090`, autenticacao HTTP e `master=N`).

No Ex05, a definicao do repository continua em `C:\Users\sofintech\.kettle\repositories.xml`, enquanto `rep`, `user` e `pass` sao enviados pelos scripts.

O `carte-repository.example.xml` deve ser usado somente quando chegarmos ao Ex06, para manter separados os conceitos de **repository explicito** e **repository pre-configurado**.
