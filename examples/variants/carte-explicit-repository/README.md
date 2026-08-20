# Variação — Carte com repository informado na requisição

Esta variação não faz parte da matriz principal. Ela demonstra outra capacidade de `executeTrans`/`executeJob`: abrir explicitamente um repository informado pela própria requisição.

## Cenário

| Item | Valor |
|---|---|
| Engine | Carte Standalone |
| Origem | Pentaho Repository |
| Transformation | `executeTrans` |
| Job | `executeJob` |
| Repository | `rep/user/pass` enviados na query string |

Parâmetros adicionais:

```text
rep=<nome do repository>
user=<usuario do repository>
pass=<senha do repository>
```

O `rep` deve corresponder a uma definição disponível no `repositories.xml` do processo Carte.

## curl

Inicie Carte com `config/carte/carte-basic.example.xml`, configure as variáveis `PDI_REPOSITORY_*` em `config/environment.bat` e execute:

```powershell
cd examples\variants\carte-explicit-repository\curl
.\transformation.bat
.\job.bat
```

A autenticação HTTP do Carte (`--user cluster:cluster`) continua separada das credenciais do repository enviadas como parâmetros da API.

Consulte [../../../docs/api-endpoints.md](../../../docs/api-endpoints.md) e [../../../docs/setup.md](../../../docs/setup.md).

## Postman

Na Collection `PDI API Usage`, use:

```text
Variants
└── Carte - Explicit Repository
    ├── Transformation - executeTrans + rep
    └── Job - executeJob + rep
```

A Collection e o Environment ficam centralizados em [../../../postman/README.md](../../../postman/README.md).
