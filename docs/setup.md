# Preparação do ambiente

Este documento reúne a configuração compartilhada pelos exemplos. Os READMEs de cada cenário contêm apenas os passos específicos daquele exemplo.

## 1. Configuração local

Copie:

```text
config/environment.example.bat
```

para:

```text
config/environment.bat
```

Ajuste os valores para o ambiente local. O arquivo real é ignorado pelo Git.

Configuração típica do laboratório:

```bat
set "PENTAHO_SERVER_URL=http://localhost:8080/pentaho"
set "PENTAHO_SERVER_USER=admin"
set "PENTAHO_SERVER_PASSWORD=password"

set "CARTE_URL=http://localhost:9090"
set "CARTE_USER=cluster"
set "CARTE_PASSWORD=cluster"

set "PDI_REPOSITORY_TRANS=/public/pdi-api-usage/trf_api_test"
set "PDI_REPOSITORY_JOB=/public/pdi-api-usage/job_api_test"
```

## 2. Pentaho Server

Os exemplos usam o Carte incorporado ao Pentaho Server com o prefixo:

```text
http://localhost:8080/pentaho/kettle/
```

Para os exemplos de filesystem, o processo do Pentaho Server precisa conseguir acessar os arquivos `.ktr/.kjb` no caminho físico informado.

Para o exemplo de repository, publique os artefatos no Pentaho Repository em paths lógicos equivalentes a:

```text
/public/pdi-api-usage/trf_api_test
/public/pdi-api-usage/job_api_test
```

## 3. Carte Standalone básico

O Pentaho Server usa a porta 8080 neste laboratório. Para evitar conflito, Carte Standalone usa 9090.

Configuração de exemplo:

```text
config/carte/carte-basic.example.xml
```

Inicie com:

```powershell
C:\Pentaho\design-tools\data-integration\Carte.bat `
  C:\caminho\pdi-api-usage\config\carte\carte-basic.example.xml
```

Valide a porta:

```powershell
Test-NetConnection localhost -Port 9090
```

Resultado esperado:

```text
TcpTestSucceeded : True
```

Use essa configuração no Ex03 e na variação de repository explícito.

## 4. Carte Standalone com Pentaho Repository

Para Ex04, copie:

```text
config/carte/carte-repository.example.xml
```

para:

```text
config/carte/carte-repository.xml
```

Preencha o bloco:

```xml
<repository>
  <name>REPOSITORY_NAME</name>
  <username>REPOSITORY_USER</username>
  <password>REPOSITORY_PASSWORD</password>
</repository>
```

O nome precisa corresponder a uma definição disponível no `repositories.xml` visível ao usuário do sistema operacional que inicia Carte.

No ambiente validado, Carte leu:

```text
C:\Users\sofintech\.kettle\repositories.xml
```

Depois inicie:

```powershell
C:\Pentaho\design-tools\data-integration\Carte.bat `
  C:\caminho\pdi-api-usage\config\carte\carte-repository.xml
```

## 5. Repository explícito na requisição

A variação `examples/variants/carte-explicit-repository/` usa `executeTrans`/`executeJob` com:

```text
rep
user
pass
```

Mesmo nesse modo, `rep` é um nome lógico e o processo Carte precisa conhecer a definição correspondente no `repositories.xml`.

## 6. Configuração do Postman

A Collection Postman não usa `config/environment.bat`. Importe `postman/environments/local.example.postman_environment.json` e ajuste URLs, caminhos físicos e credenciais no Environment local. Consulte [postman.md](postman.md).

## 7. Segurança

Não versione:

```text
config/environment.bat
config/carte/carte-repository.xml
```

Esses arquivos podem conter credenciais. Os scripts agora exigem a configuração local e não executam automaticamente usando valores do arquivo `.example`.

Em ambientes compartilhados, use HTTPS, contas específicas e políticas de acesso adequadas. Evite expor endpoints Carte diretamente à Internet.

Para Postman, também não versione nem publique exports de Environment que contenham credenciais reais.
