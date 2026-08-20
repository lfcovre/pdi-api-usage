# PDI API Usage

Projeto de estudo prático para executar Transformations (`.ktr`) e Jobs (`.kjb`) do Pentaho Data Integration por HTTP, comparando duas engines de execução e duas origens de artefato:

- engine PDI incorporada ao Pentaho Server;
- Carte Standalone;
- arquivos no filesystem;
- objetos armazenados no Pentaho Repository.

O objetivo principal é mostrar onde o artefato está, qual engine o executa e qual família de endpoint é adequada para cada cenário. As diferenças entre `executeTrans`/`executeJob` e `runTrans`/`runJob` são tratadas separadamente em [docs/api-endpoints.md](docs/api-endpoints.md).

## Matriz dos exemplos principais

| Exemplo | Engine | Origem do artefato | Resolução do artefato | Transformation | Job |
|---|---|---|---|---|---|
| [Ex01](examples/ex01-pentaho-server-filesystem/README.md) | Pentaho Server | Filesystem | caminho físico enviado em `trans`/`job` | `executeTrans` | `executeJob` |
| [Ex02](examples/ex02-pentaho-server-repository/README.md) | Pentaho Server | Pentaho Repository | repository interno do Server; caminho lógico enviado em `trans`/`job` | `runTrans` | `runJob` |
| [Ex03](examples/ex03-carte-filesystem/README.md) | Carte Standalone | Filesystem | caminho físico enviado em `trans`/`job` | `executeTrans` | `executeJob` |
| [Ex04](examples/ex04-carte-repository/README.md) | Carte Standalone | Pentaho Repository | repository configurado no Carte; caminho lógico enviado em `trans`/`job` | `runTrans` | `runJob` |

Visualmente:

```text
                              ORIGEM DO ARTEFATO
                         Filesystem        Pentaho Repository
                         ----------        ------------------
Pentaho Server              Ex01                  Ex02
Carte Standalone            Ex03                  Ex04
```

Todos os quatro exemplos principais foram validados com Transformation e Job.

## Os quatro endpoints podem ser usados em qual engine?

`executeTrans`, `executeJob`, `runTrans` e `runJob` pertencem à API Carte. Eles podem ser expostos tanto por um Carte Standalone quanto pelo Carte incorporado ao Pentaho Server. O prefixo da URL muda:

```text
Pentaho Server:  http://host:8080/pentaho/kettle/...
Carte Standalone: http://host:9090/kettle/...
```

O endpoint não é escolhido pelo nome da engine, e sim pela forma como o artefato deve ser resolvido:

- `executeTrans` / `executeJob`: carregam diretamente o recurso indicado pela requisição. Sem `rep`, o código do PDI interpreta `trans`/`job` como arquivo no filesystem. Com `rep`, a mesma família também consegue abrir um repository explicitamente informado na requisição.
- `runTrans` / `runJob`: executam um objeto de repository quando esse repository já está disponível para a engine. No Pentaho Server, o exemplo usa o repository interno do Server. No Carte Standalone, o repository é configurado no XML de inicialização.

Consulte [docs/api-endpoints.md](docs/api-endpoints.md) para a explicação completa, inclusive comportamento de resposta, parâmetros e a variação `execute* + rep/user/pass`.

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
│   ├── setup.md
│   ├── testing.md
│   └── roadmap.md
├── examples/
│   ├── ex01-pentaho-server-filesystem/
│   │   ├── README.md
│   │   ├── curl/
│   │   └── postman/
│   ├── ex02-pentaho-server-repository/
│   │   ├── README.md
│   │   ├── curl/
│   │   └── postman/
│   ├── ex03-carte-filesystem/
│   │   ├── README.md
│   │   ├── curl/
│   │   └── postman/
│   ├── ex04-carte-repository/
│   │   ├── README.md
│   │   ├── curl/
│   │   └── postman/
│   └── variants/
│       └── carte-explicit-repository/
├── pdi/
│   ├── transformations/
│   └── jobs/
└── ...
```

Cada exemplo é organizado pelo cenário. Dentro dele, `curl/` contém os scripts atuais e `postman/` fica reservado para as requisições e collections que serão adicionadas posteriormente.

## Configuração inicial

1. Copie `config/environment.example.bat` para `config/environment.bat`.
2. Ajuste URLs, usuários, senhas e paths lógicos do repository.
3. Para Carte Standalone, consulte [docs/setup.md](docs/setup.md).
4. Para validar execuções e logs, consulte [docs/testing.md](docs/testing.md).

Os arquivos locais que podem conter credenciais não são versionados:

```text
config/environment.bat
config/carte/carte-repository.xml
```

## Artefatos PDI de teste

Os exemplos usam os mesmos artefatos:

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

Ela demonstra `executeTrans`/`executeJob` no Carte Standalone com `rep`, `user` e `pass` enviados na própria requisição. A origem continua sendo o mesmo Pentaho Repository; por isso essa variação não é tratada como um quinto cenário principal.

## Documentação

- [docs/api-endpoints.md](docs/api-endpoints.md): diferenças entre `execute*` e `run*`, parâmetros, respostas e cenários de uso;
- [docs/setup.md](docs/setup.md): preparação do ambiente, Carte e Pentaho Repository;
- [docs/curl.md](docs/curl.md): opções do `curl` usadas nos scripts;
- [docs/testing.md](docs/testing.md): logs, resultados observados e critérios de validação;
- [docs/roadmap.md](docs/roadmap.md): Postman, monitoramento, Scheduler API e outros próximos blocos.
