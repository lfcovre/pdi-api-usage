# Ex01 — Pentaho Server com artefato no filesystem

## Objetivo

Executar a Transformation e o Job do projeto usando a engine PDI incorporada ao Pentaho Server, carregando os artefatos diretamente do filesystem.

## Cenário

| Item | Valor |
|---|---|
| Engine | Pentaho Server |
| Origem | Filesystem |
| Transformation | `executeTrans` |
| Job | `executeJob` |
| Resolução | caminho físico enviado em `trans`/`job` |

Endpoints:

```text
http://localhost:8080/pentaho/kettle/executeTrans
http://localhost:8080/pentaho/kettle/executeJob
```

Sem `rep`, a implementação de `executeTrans`/`executeJob` interpreta `trans`/`job` como filename.

## Pré-requisitos

- Pentaho Server iniciado;
- `config/environment.bat` configurado;
- os arquivos da pasta `pdi/` acessíveis ao processo do Pentaho Server.

## curl

```powershell
cd examples\ex01-pentaho-server-filesystem\curl
.\transformation.bat
.\job.bat
```

Os scripts calculam automaticamente os paths físicos:

```text
pdi/transformations/trf_api_test.ktr
pdi/jobs/job_api_test.kjb
```

## Parâmetros principais

Transformation:

```text
trans=<caminho físico do .ktr>
level=Basic
P_MESSAGE=...
```

Job:

```text
job=<caminho físico do .kjb>
level=Basic
P_MESSAGE=...
```

Não são enviados `rep`, `user` ou `pass` de repository.

## Resultado esperado

- `executeTrans`: HTTP 200; o corpo pode ficar vazio; validar no `pdi.log`;
- `executeJob`: HTTP 200 e XML com `Job started` e ID.

Consulte [../../docs/testing.md](../../docs/testing.md).

## Postman

Na Collection `PDI API Usage`, use a pasta:

```text
01 - Pentaho Server - Filesystem
```

Requests:

```text
Transformation - executeTrans
Job - executeJob
```

A Collection e o Environment ficam centralizados em [../../postman/README.md](../../postman/README.md).
