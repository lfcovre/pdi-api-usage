# PDI API Usage

Projeto de estudo prático para executar Transformations (`.ktr`) e Jobs (`.kjb`) do Pentaho Data Integration por HTTP, comparando duas engines de execução e duas origens de artefato:

- engine PDI incorporada ao Pentaho Server;
- Carte Standalone;
- arquivos no filesystem;
- objetos armazenados no Pentaho Repository.

Os mesmos cenários podem ser executados por scripts `curl` ou pela Collection do Postman. O objetivo principal é mostrar onde o artefato está, qual engine o executa e qual família de endpoint é adequada para cada cenário.

## Matriz dos exemplos principais

| Exemplo | Engine | Origem do artefato | Como o artefato é localizado | Transformation | Job |
|---|---|---|---|---|---|
| [Ex01](examples/ex01-pentaho-server-filesystem/README.md) | Pentaho Server | Filesystem | caminho físico enviado em `trans`/`job` | `executeTrans` | `executeJob` |
| [Ex02](examples/ex02-pentaho-server-repository/README.md) | Pentaho Server | Pentaho Repository | repository interno do Server; caminho lógico enviado em `trans`/`job` | `runTrans` | `runJob` |
| [Ex03](examples/ex03-carte-filesystem/README.md) | Carte Standalone | Filesystem | caminho físico enviado em `trans`/`job` | `executeTrans` | `executeJob` |
| [Ex04](examples/ex04-carte-repository/README.md) | Carte Standalone | Pentaho Repository | repository configurado no Carte; caminho lógico enviado em `trans`/`job` | `runTrans` | `runJob` |

```text
                              ORIGEM DO ARTEFATO
                         Filesystem        Pentaho Repository
                         ----------        ------------------
Pentaho Server              Ex01                  Ex02
Carte Standalone            Ex03                  Ex04
```

Todos os quatro exemplos principais foram validados com Transformation e Job.

## Endpoints e engines

`executeTrans`, `executeJob`, `runTrans` e `runJob` pertencem à API Carte e podem ser expostos tanto por Carte Standalone quanto pelo Carte incorporado ao Pentaho Server.

```text
Pentaho Server:   http://host:8080/pentaho/kettle/...
Carte Standalone: http://host:9090/kettle/...
```

O endpoint não é escolhido pelo nome da engine. A escolha depende principalmente de como o artefato será localizado:

- `executeTrans` / `executeJob`: sem `rep`, `trans`/`job` é tratado como arquivo no filesystem; com `rep`, a família também pode abrir um repository informado na própria requisição;
- `runTrans` / `runJob`: executam objetos de repository quando esse repository já está disponível para a engine.

Consulte [docs/api-endpoints.md](docs/api-endpoints.md) para a comparação completa.

## Clientes HTTP

### curl

Cada cenário possui seus próprios scripts em:

```text
examples/<cenario>/curl/
```

Consulte [docs/curl.md](docs/curl.md).

### Postman

O projeto usa uma única Collection, organizada nas mesmas quatro pastas da matriz:

```text
postman/pdi-api-usage.postman_collection.json
```

O Environment de exemplo fica em:

```text
postman/environments/local.example.postman_environment.json
```

Consulte [postman/README.md](postman/README.md) e [docs/postman.md](docs/postman.md).

## Estrutura do projeto

```text
pdi-api-usage/
├── README.md
├── .gitignore
├── config/
│   ├── environment.example.bat
│   └── carte/
│       ├── carte-basic.example.xml
│       └── carte-repository.example.xml
├── docs/
│   ├── api-endpoints.md
│   ├── curl.md
│   ├── postman.md
│   ├── setup.md
│   ├── testing.md
│   └── roadmap.md
├── examples/
│   ├── ex01-pentaho-server-filesystem/
│   │   ├── README.md
│   │   └── curl/
│   ├── ex02-pentaho-server-repository/
│   │   ├── README.md
│   │   └── curl/
│   ├── ex03-carte-filesystem/
│   │   ├── README.md
│   │   └── curl/
│   ├── ex04-carte-repository/
│   │   ├── README.md
│   │   └── curl/
│   └── variants/
│       └── carte-explicit-repository/
├── postman/
│   ├── README.md
│   ├── pdi-api-usage.postman_collection.json
│   └── environments/
│       └── local.example.postman_environment.json
└── pdi/
    ├── transformations/
    └── jobs/
```

## Configuração inicial

1. Para os scripts curl, copie `config/environment.example.bat` para `config/environment.bat` e ajuste os valores.
2. Para Postman, importe a Collection e o Environment de exemplo e ajuste os valores locais.
3. Para Carte Standalone, consulte [docs/setup.md](docs/setup.md).
4. Para validar execuções e logs, consulte [docs/testing.md](docs/testing.md).

Arquivos locais com credenciais não devem ser versionados.

## Artefatos PDI de teste

Os exemplos usam:

```text
pdi/transformations/trf_api_test.ktr
pdi/jobs/job_api_test.kjb
```

Ambos recebem `P_MESSAGE`. A execução registra `[PDI API TEST]`, permitindo confirmar que a chamada HTTP iniciou o artefato correto e transmitiu o parâmetro.

## Variação avançada

Além da matriz principal, o projeto mantém uma variação validada em:

```text
examples/variants/carte-explicit-repository/
```

Ela demonstra `executeTrans`/`executeJob` no Carte Standalone com `rep`, `user` e `pass` enviados na própria requisição. A origem continua sendo o mesmo Pentaho Repository, por isso não é tratada como um quinto cenário principal.

## Documentação

- [docs/api-endpoints.md](docs/api-endpoints.md): diferenças entre `execute*` e `run*`, parâmetros, respostas e cenários de uso;
- [docs/setup.md](docs/setup.md): preparação do ambiente, Carte e Pentaho Repository;
- [docs/curl.md](docs/curl.md): opções do `curl` usadas nos scripts;
- [docs/postman.md](docs/postman.md): Collection, Environment, variáveis, autenticação e testes Postman;
- [docs/testing.md](docs/testing.md): logs, resultados observados e critérios de validação;
- [docs/roadmap.md](docs/roadmap.md): monitoramento, Scheduler API e outras evoluções.
