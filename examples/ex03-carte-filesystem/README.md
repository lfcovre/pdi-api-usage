# Ex03 — Carte Standalone com artefato no filesystem

## Objetivo

Executar a Transformation e o Job diretamente do filesystem usando Carte Standalone.

## Cenário

| Item | Valor |
|---|---|
| Engine | Carte Standalone |
| Origem | Filesystem |
| Transformation | `executeTrans` |
| Job | `executeJob` |
| Resolução | caminho físico enviado em `trans`/`job` |

Endpoints usados no ambiente validado:

```text
http://localhost:9090/kettle/executeTrans/
http://localhost:9090/kettle/executeJob/
```

## Pré-requisitos

- `config/environment.bat` configurado;
- Carte iniciado na porta 9090 com `config/carte/carte-basic.example.xml`;
- os artefatos da pasta `pdi/` acessíveis ao processo Carte.

Início do Carte:

```powershell
C:\Pentaho\design-tools\data-integration\Carte.bat `
  C:\caminho\pdi-api-usage\config\carte\carte-basic.example.xml
```

## curl

```powershell
cd examples\ex03-carte-filesystem\curl
.\transformation.bat
.\job.bat
```

## Resultado esperado

- HTTP 200 nas duas chamadas;
- `executeJob` retorna `Job started` e ID;
- a Transformation e o Job registram `[PDI API TEST]` no terminal do Carte.

No ambiente testado, remover a barra final dos endpoints produziu HTTP 301; por isso os scripts mantêm `/` no final.

Consulte [../../docs/setup.md](../../docs/setup.md) e [../../docs/testing.md](../../docs/testing.md).

## Postman

A pasta `postman/` está reservada para a versão equivalente deste cenário em Postman.
