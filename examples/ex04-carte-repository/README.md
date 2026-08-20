# Ex04 — Carte Standalone com artefato no Pentaho Repository

## Objetivo

Executar a Transformation e o Job armazenados no Pentaho Repository usando Carte Standalone com o repository configurado previamente no XML de inicialização.

## Cenário

| Item | Valor |
|---|---|
| Engine | Carte Standalone |
| Origem | Pentaho Repository |
| Transformation | `runTrans` |
| Job | `runJob` |
| Resolução | repository configurado no Carte e path lógico do objeto |

Endpoints:

```text
http://localhost:9090/kettle/runTrans/
http://localhost:9090/kettle/runJob/
```

## Pré-requisitos

1. Configure `config/environment.bat`.
2. Publique os artefatos no Pentaho Repository.
3. Copie `config/carte/carte-repository.example.xml` para `config/carte/carte-repository.xml`.
4. Preencha nome, usuário e senha do repository.
5. Garanta que o processo Carte tenha acesso à definição correspondente em `repositories.xml`.
6. Inicie Carte com o XML local.

Consulte [../../docs/setup.md](../../docs/setup.md) para o passo a passo.

## curl

```powershell
cd examples\ex04-carte-repository\curl
.\transformation.bat
.\job.bat
```

A requisição não envia `rep`, `user` ou `pass` do repository. Ela envia apenas o path lógico, nível de log e parâmetros da execução.

## Resultado esperado

`runTrans` e `runJob` retornam mensagem de início e ID. No terminal do Carte devem aparecer a conexão ao repository e o marcador `[PDI API TEST]`.

Consulte [../../docs/api-endpoints.md](../../docs/api-endpoints.md) e [../../docs/testing.md](../../docs/testing.md).

## Postman

A pasta `postman/` está reservada para a versão equivalente deste cenário em Postman.
