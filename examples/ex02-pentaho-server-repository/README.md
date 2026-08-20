# Ex02 — Pentaho Server com artefato no Pentaho Repository

## Objetivo

Executar a Transformation e o Job armazenados no Pentaho Repository usando a engine PDI incorporada ao Pentaho Server.

## Cenário

| Item | Valor |
|---|---|
| Engine | Pentaho Server |
| Origem | Pentaho Repository |
| Transformation | `runTrans` |
| Job | `runJob` |
| Resolução | repository interno do Server e path lógico do objeto |

Endpoints:

```text
http://localhost:8080/pentaho/kettle/runTrans
http://localhost:8080/pentaho/kettle/runJob
```

Neste cenário o repository não é selecionado por `rep` na URL. O exemplo usa o repository já fornecido pelo ambiente do Pentaho Server.

## Pré-requisitos

- Pentaho Server iniciado;
- `config/environment.bat` configurado;
- Transformation e Job publicados no Pentaho Repository, por exemplo:

```text
/public/pdi-api-usage/trf_api_test
/public/pdi-api-usage/job_api_test
```

## curl

```powershell
cd examples\ex02-pentaho-server-repository\curl
.\transformation.bat
.\job.bat
```

## Parâmetros principais

Transformation:

```text
trans=/public/pdi-api-usage/trf_api_test
level=Basic
P_MESSAGE=...
```

Job:

```text
job=/public/pdi-api-usage/job_api_test
level=Basic
P_MESSAGE=...
```

Não são enviados `rep`, `user` ou `pass` do repository. A autenticação HTTP é feita no Pentaho Server.

## Resultado esperado

`runTrans` e `runJob` retornam XML com mensagem de início e ID Carte. A execução deve ser confirmada em `<PENTAHO_SERVER_HOME>\logs\pdi.log`.

Consulte [../../docs/api-endpoints.md](../../docs/api-endpoints.md) e [../../docs/testing.md](../../docs/testing.md).

## Postman

Na Collection `PDI API Usage`, use a pasta:

```text
02 - Pentaho Server - Pentaho Repository
```

Requests:

```text
Transformation - runTrans
Job - runJob
```

A Collection e o Environment ficam centralizados em [../../postman/README.md](../../postman/README.md).
