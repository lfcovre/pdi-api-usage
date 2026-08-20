# Postman

Esta pasta centraliza os artefatos Postman do projeto.

## Arquivos

```text
postman/
├── README.md
├── pdi-api-usage.postman_collection.json
└── environments/
    └── local.example.postman_environment.json
```

A Collection contém os quatro cenários principais e a variação Carte com repository explícito. A organização interna espelha a matriz do projeto:

```text
PDI API Usage
├── 01 - Pentaho Server - Filesystem
├── 02 - Pentaho Server - Pentaho Repository
├── 03 - Carte Standalone - Filesystem
├── 04 - Carte Standalone - Pentaho Repository
└── Variants
    └── Carte - Explicit Repository
```

Cada uma das quatro pastas principais contém duas requisições: uma para Transformation e outra para Job.

## Importação

No Postman:

1. importe `pdi-api-usage.postman_collection.json`;
2. importe `environments/local.example.postman_environment.json`;
3. duplique ou renomeie o Environment de exemplo para uso local;
4. ajuste URLs, caminhos físicos e credenciais;
5. selecione o Environment antes de enviar as requisições.

Não publique um Environment com credenciais reais no GitHub. Consulte [../docs/postman.md](../docs/postman.md) para configuração, variáveis, testes e observações sobre redirects.
