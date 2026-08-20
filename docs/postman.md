# Uso do Postman

Este documento descreve a Collection e o Environment usados para reproduzir, no Postman, as mesmas chamadas HTTP demonstradas pelos scripts `curl`.

## 1. Organização

O projeto usa uma única Collection:

```text
postman/pdi-api-usage.postman_collection.json
```

Ela é organizada em pastas que correspondem aos quatro cenários principais:

| Pasta da Collection | Cenário | Endpoints |
|---|---|---|
| `01 - Pentaho Server - Filesystem` | Ex01 | `executeTrans` / `executeJob` |
| `02 - Pentaho Server - Pentaho Repository` | Ex02 | `runTrans` / `runJob` |
| `03 - Carte Standalone - Filesystem` | Ex03 | `executeTrans` / `executeJob` |
| `04 - Carte Standalone - Pentaho Repository` | Ex04 | `runTrans` / `runJob` |

A pasta `Variants > Carte - Explicit Repository` demonstra `executeTrans`/`executeJob` com `rep`, `user` e `pass` do repository enviados na requisição.

Uma única Collection evita duplicação e permite comparar os cenários pela mesma interface.

## 2. Environment

Importe:

```text
postman/environments/local.example.postman_environment.json
```

O Environment contém apenas valores dependentes da máquina ou do ambiente:

```text
pentaho_server_url
pentaho_server_user
pentaho_server_password
carte_url
carte_user
carte_password
trans_file_path
job_file_path
repository_name
repository_user
repository_password
```

O arquivo versionado usa `CHANGE_ME` para senhas. Depois da importação, ajuste os valores localmente. No Postman, variáveis sensíveis podem ser marcadas como seguras para reduzir sua exposição na interface.

Não exporte de volta para o repositório um Environment contendo credenciais reais.

## 3. Variáveis da Collection

Valores que pertencem ao próprio laboratório ficam na Collection:

```text
log_level = Basic
p_message = Mensagem enviada pela API REST do PDI
repository_trans_path = /public/pdi-api-usage/trf_api_test
repository_job_path = /public/pdi-api-usage/job_api_test
```

Essa separação deixa no Environment somente aquilo que normalmente muda entre máquinas ou instalações.

## 4. Autenticação

As pastas dos cenários Pentaho Server usam HTTP Basic com:

```text
{{pentaho_server_user}}
{{pentaho_server_password}}
```

As pastas Carte usam:

```text
{{carte_user}}
{{carte_password}}
```

Na variação `Carte - Explicit Repository`, a autenticação HTTP continua sendo a do Carte. As credenciais do Pentaho Repository aparecem separadamente como parâmetros:

```text
rep={{repository_name}}
user={{repository_user}}
pass={{repository_password}}
```

Isso demonstra a diferença entre autenticar no endpoint HTTP e autenticar no repository PDI.

## 5. Testes incluídos

A Collection possui um teste comum para todas as requisições:

```javascript
pm.test("HTTP status is 200", function () {
    pm.response.to.have.status(200);
});
```

Nos endpoints que retornam XML de início de execução, há testes adicionais para:

- `<result>OK</result>`;
- `Transformation started` ou `Job started`;
- presença de um `<id>...</id>` de execução.

`executeTrans` não exige conteúdo no corpo porque, no ambiente validado, uma execução bem-sucedida pôde retornar HTTP 200 com corpo vazio.

Os testes Postman validam a resposta HTTP, mas não substituem a verificação do log da engine. Consulte [testing.md](testing.md).

## 6. Redirects no Carte

No ambiente validado, os endpoints Carte sem barra final retornaram HTTP 301. Por isso a Collection usa:

```text
/kettle/executeTrans/
/kettle/executeJob/
/kettle/runTrans/
/kettle/runJob/
```

O Postman pode seguir redirects automaticamente. Ao investigar um comportamento 3xx, desative temporariamente `Automatically follow redirects` nas configurações da requisição ou inspecione o Postman Console para não confundir a resposta final com a resposta intermediária.

## 7. Relação com os exemplos curl

Postman e curl representam os mesmos cenários. A diferença é apenas o cliente HTTP:

```text
examples/<cenario>/curl/   -> execução por script
postman/                   -> execução interativa pela Collection
```

Os READMEs dos cenários indicam qual pasta da Collection deve ser usada.

## 8. Referências do Postman

- Exportação de Collections e Environments: https://learning.postman.com/docs/getting-started/importing-and-exporting/exporting-data
- Environment variables: https://learning.postman.com/docs/use/send-requests/variables/environment-variables
- Herança de autenticação em Collection e folders: https://learning.postman.com/latest-v-12/docs/use/send-requests/authorization/specifying-authorization-details
- Configuração de redirects: https://learning.postman.com/v11/docs/getting-started/installation/settings
