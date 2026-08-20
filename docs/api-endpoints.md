# Endpoints de execução do PDI

Este documento explica `executeTrans`, `executeJob`, `runTrans` e `runJob` e como escolher entre eles.

## 1. Um ponto importante: endpoint e engine são dimensões diferentes

Os quatro endpoints fazem parte da API Carte. Eles podem ser disponibilizados por:

- Carte Standalone;
- Carte incorporado ao Pentaho Server.

Por isso, `executeTrans` não significa "Pentaho Server" e `runTrans` não significa "Carte". O endpoint deve ser escolhido pela forma como o artefato será localizado e pelo repository disponível no executor.

Prefixos usados neste projeto:

```text
Pentaho Server
http://localhost:8080/pentaho/kettle/...

Carte Standalone
http://localhost:9090/kettle/...
```

No ambiente Carte validado, os scripts usam barra final (`/kettle/executeTrans/`, por exemplo) porque a versão sem barra retornou HTTP 301.

## 2. Visão comparativa

| Endpoint | Tipo de artefato | Como localiza o artefato | Repository na requisição | Comportamento observado |
|---|---|---|---|---|
| `executeTrans` | Transformation | sem `rep`: arquivo; com `rep`: objeto de repository | opcional | aguarda a Transformation terminar; sucesso pode ter corpo vazio |
| `executeJob` | Job | sem `rep`: arquivo; com `rep`: objeto de repository | opcional | inicia o Job e retorna um ID |
| `runTrans` | Transformation em repository | caminho lógico em repository já disponível ao executor | não | inicia a Transformation e retorna um ID |
| `runJob` | Job em repository | caminho lógico em repository já disponível ao executor | não | inicia o Job e retorna um ID |

## 3. `executeTrans`

Endpoint lógico:

```text
/kettle/executeTrans
```

A documentação oficial descreve o uso com repository explícito, usando `rep`, `user`, `pass`, `trans` e `level`. O código atual do PDI também permite omitir `rep`: quando nenhum repository é aberto, `trans` é tratado como filename.

### Filesystem

```text
trans=C:\projeto\pdi\transformations\trf_api_test.ktr
level=Basic
P_MESSAGE=...
```

Neste modo:

- não envie `rep`;
- o arquivo precisa estar acessível ao processo que executa o PDI;
- o caminho não é resolvido pelo computador do cliente HTTP, a menos que cliente e executor sejam a mesma máquina.

### Repository explícito

```text
rep=localhost
user=admin
pass=...
trans=/public/pdi-api-usage/trf_api_test
level=Basic
```

Nesse modo, `rep` é o nome de um repository conhecido pelo processo PDI, e `trans` é um path lógico no repository.

O projeto demonstra esse modo como variação do Carte Standalone.

### Comportamento de execução

A implementação atual prepara a Transformation, inicia as threads e aguarda o término. Por isso `executeTrans` é o endpoint mais síncrono entre os quatro estudados. Em uma execução bem-sucedida, o corpo HTTP pode ficar vazio; o status HTTP e o log do executor são usados para validação.

## 4. `executeJob`

Endpoint lógico:

```text
/kettle/executeJob
```

A resolução do artefato segue a mesma ideia de `executeTrans`:

- sem `rep`: `job` é um arquivo `.kjb`;
- com `rep`: `job` é um path lógico no repository indicado.

No sucesso, o Job é iniciado e a API retorna um objeto XML contendo `Job started` e um ID Carte.

## 5. `runTrans`

Endpoint lógico:

```text
/kettle/runTrans
```

`runTrans` é destinado a uma Transformation armazenada em enterprise repository quando o repository já está disponível ao executor.

A requisição envia principalmente:

```text
trans=/public/pdi-api-usage/trf_api_test
level=Basic
P_MESSAGE=...
```

Não são enviados `rep`, `user` ou `pass` de repository nessa chamada.

Neste projeto:

- Ex02: o Carte incorporado ao Pentaho Server usa o Pentaho Repository interno do Server;
- Ex04: o Carte Standalone recebe o repository pelo XML de inicialização.

No sucesso, retorna `Transformation started` e um ID Carte.

## 6. `runJob`

Endpoint lógico:

```text
/kettle/runJob
```

Segue o mesmo modelo de `runTrans`, mas para Jobs. A documentação do PDI define `job` como o path completo do Job no repository e exige que o repository esteja configurado/disponível no Carte.

No sucesso, retorna `Job started` e um ID Carte.

## 7. Quando usar cada família

### Use `executeTrans` / `executeJob` quando

- o artefato está no filesystem e o executor consegue acessar seu caminho físico;
- ou você quer selecionar explicitamente um repository na requisição usando `rep/user/pass` e esse repository está definido para o processo PDI.

### Use `runTrans` / `runJob` quando

- o artefato está no Pentaho Repository;
- o repository já é fornecido pelo ambiente de execução;
- você quer enviar apenas o path lógico do objeto e os parâmetros da execução.

Para o cenário normal "Pentaho Server executando conteúdo do próprio Pentaho Repository", o projeto usa `runTrans`/`runJob`.

## 8. Autenticação HTTP e autenticação de repository

São camadas diferentes.

### Pentaho Server

```text
curl --user admin:password
        |
        +-- autenticação HTTP no Pentaho Server
```

No Ex02 não há `user/pass` de repository na query.

### Carte com repository configurado

```text
curl --user cluster:cluster
        |
        +-- autenticação HTTP no Carte

carte-repository.xml
        |
        +-- usuário e senha do Pentaho Repository
```

### Carte com repository explícito

```text
curl --user cluster:cluster
        |
        +-- autenticação HTTP no Carte

rep=localhost&user=admin&pass=...
        |
        +-- seleção e autenticação do repository
```

## 9. Significado de `trans` e `job`

| Situação | Exemplo de valor |
|---|---|
| `executeTrans` sem `rep` | `C:\...\trf_api_test.ktr` |
| `executeJob` sem `rep` | `C:\...\job_api_test.kjb` |
| `executeTrans`/`executeJob` com `rep` | `/public/pdi-api-usage/trf_api_test` ou `/public/pdi-api-usage/job_api_test` |
| `runTrans`/`runJob` | path lógico no repository, sem `.ktr`/`.kjb` nos exemplos deste projeto |

## 10. Parâmetros adicionais

Os artefatos deste projeto declaram `P_MESSAGE`. As chamadas dos quatro cenários enviam esse parâmetro e os testes confirmaram seu recebimento pela Transformation e pelo Job.

## 11. Referências técnicas

- Pentaho REST API, Carte transformations: https://docs.pentaho.com/rest-api/carte-apis-transformations
- Pentaho REST API, Carte jobs: https://docs.pentaho.com/rest-api/carte-apis-jobs
- `ExecuteTransServlet`: https://github.com/pentaho/pentaho-kettle/blob/master/engine/src/main/java/org/pentaho/di/www/ExecuteTransServlet.java
- `ExecuteJobServlet`: https://github.com/pentaho/pentaho-kettle/blob/master/engine/src/main/java/org/pentaho/di/www/ExecuteJobServlet.java
- PDI 11 `RunTransServlet` Javadoc: https://javadoc.pentaho.com/kettle110/kettle-engine-11.0.0.0-237-javadoc/org/pentaho/di/www/RunTransServlet.html
- `RunJobServlet`: https://github.com/pentaho/pentaho-kettle/blob/master/engine/src/main/java/org/pentaho/di/www/RunJobServlet.java
