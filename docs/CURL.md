# curl nos exemplos do projeto

Este documento explica as opções do `curl` e os parâmetros da API usados nos scripts `.bat` do projeto.

Os scripts também possuem comentários próximos à chamada para que seja possível entender o comando sem depender exclusivamente deste documento.

## 1. Estrutura geral da chamada

Um exemplo simplificado é:

```bat
curl.exe ^
  --silent ^
  --show-error ^
  --fail-with-body ^
  --user "usuario:senha" ^
  --get ^
  --data-urlencode "trans=C:\caminho\trf_api_test.ktr" ^
  --data-urlencode "level=Basic" ^
  --data-urlencode "P_MESSAGE=Teste via API" ^
  --write-out "\nHTTP_STATUS=%%{http_code}\n" ^
  "http://localhost:9090/kettle/executeTrans/"
```

O caractere `^` é o continuador de linha do `cmd.exe`. Ele permite dividir um único comando em várias linhas para facilitar a leitura.

## 2. Opções do curl

### `--silent`

Oculta a barra de progresso e outras informações de progresso do `curl`.

Isso deixa a saída dos exemplos focada no corpo devolvido pela API e no status HTTP.

### `--show-error`

Quando `--silent` é usado, essa opção garante que mensagens de erro do `curl` continuem sendo exibidas.

As duas opções são usadas em conjunto:

```text
--silent --show-error
```

para obter uma saída limpa sem esconder erros importantes.

### `--fail-with-body`

Faz o `curl` considerar respostas HTTP `400` ou superiores como falha e retornar um código de saída diferente de zero.

Ao mesmo tempo, mantém o corpo da resposta HTTP disponível. Isso é útil porque o Pentaho pode devolver no corpo informações relevantes para diagnosticar o erro.

O script captura o código de saída do `curl` usando:

```bat
set "CURL_EXIT=%ERRORLEVEL%"
```


### Respostas `3xx`

`--fail-with-body` considera falha respostas `4xx` e `5xx`, mas não transforma `3xx` em erro do `curl`. Por isso os scripts também verificam explicitamente o `HTTP_STATUS` e somente aceitam códigos `2xx` como sucesso.

No Ex04 foi observado um `301` quando o endpoint Carte foi chamado sem a barra final. Os scripts usam a URL canônica com `/` e não usam `--location`, para que um redirecionamento inesperado não seja mascarado.

### `--user "usuario:senha"`

Informa as credenciais usadas na autenticação HTTP do endpoint.

Nos exemplos atuais:

```bat
--user "%PENTAHO_SERVER_USER%:%PENTAHO_SERVER_PASSWORD%"
```

ou:

```bat
--user "%CARTE_USER%:%CARTE_PASSWORD%"
```

Essas são credenciais do **Pentaho Server ou Carte**. Elas não devem ser confundidas com credenciais de um **repositório PDI**, que serão tratadas nos exemplos de repository.

### `--get`

Instrui o `curl` a realizar uma requisição HTTP `GET` e usar os valores fornecidos por `--data-urlencode` como parâmetros da query string.

Conceitualmente:

```bat
--get ^
--data-urlencode "level=Basic"
```

resulta em uma chamada equivalente a:

```text
...?level=Basic
```

com o valor corretamente codificado para URL.

### `--data-urlencode "nome=valor"`

Adiciona um parâmetro à requisição fazendo o URL encoding do valor automaticamente.

Essa opção é especialmente importante para caminhos Windows, mensagens com espaços e outros caracteres que não devem ser concatenados manualmente na URL.

Por exemplo:

```bat
--data-urlencode "trans=C:\Meu Projeto\trf_api_test.ktr"
```

é mais seguro e legível do que montar manualmente uma URL com espaços e aspas escapadas.

### `--output`

Os scripts gravam temporariamente o corpo da resposta em um arquivo:

```bat
--output "%RESPONSE_FILE%"
```

Isso permite separar o **corpo da resposta** do **código HTTP**, exibir ambos de forma controlada e validar o status antes de declarar sucesso. O arquivo temporário é removido ao final do script.

### `--write-out`

Permite obter informações do `curl` depois que a resposta HTTP foi recebida. Os scripts atuais usam:

```bat
--write-out "%%{http_code}"
```

e redirecionam esse valor para um arquivo temporário de status. Em seguida exibem explicitamente:

```text
HTTP_STATUS=200
```

No `curl`, a variável é `%{http_code}`. Como o comando está dentro de um arquivo `.bat`, `%` possui significado especial para o `cmd.exe`; por isso escrevemos `%%{http_code}` para que um `%` literal chegue ao `curl`.

A validação do script considera somente respostas `2xx` como sucesso. Assim, um `301`, embora não seja tratado como erro por `--fail-with-body`, não gera mais a mensagem `[OK]`.

## 3. Parâmetros enviados ao PDI

### `trans`

Usado por `executeTrans` para informar a Transformation que deve ser executada.

Nos exemplos de filesystem, o valor é o caminho do arquivo `.ktr` visto pelo processo que executa o PDI.

### `job`

Usado por `executeJob` para informar o Job que deve ser executado.

Nos exemplos de filesystem, o valor é o caminho do arquivo `.kjb` visto pelo processo que executa o PDI.

### `level`

Define o nível de log solicitado para a execução.

Nos exemplos, o valor padrão é configurado em:

```bat
set "PDI_LOG_LEVEL=Basic"
```

no arquivo de ambiente.

### `P_MESSAGE`

Não é um parâmetro reservado do endpoint. É um parâmetro criado especificamente nos artefatos deste projeto:

```text
trf_api_test.ktr
job_api_test.kjb
```

Ele permite comprovar que valores enviados na requisição HTTP chegaram efetivamente à Transformation ou ao Job.

## 4. URL do endpoint

A URL aparece por último no comando porque ela representa o destino ao qual todas as opções anteriores serão aplicadas.

No Pentaho Server:

```text
http://localhost:8080/pentaho/kettle/executeTrans
http://localhost:8080/pentaho/kettle/executeJob
```

No Carte Standalone:

```text
http://localhost:9090/kettle/executeTrans/
http://localhost:9090/kettle/executeJob/
```

## 5. Por que os scripts não usam `-X GET`?

Os exemplos usam `--get`, portanto não é necessário adicionar:

```text
-X GET
```

Além de definir o método GET, `--get` integra diretamente os valores fornecidos por `--data-urlencode` à query string. Isso deixa o objetivo da chamada mais explícito e reduz montagem manual de URLs.

## 6. Saída HTTP x log PDI

As opções do `curl` permitem observar a perspectiva do cliente HTTP, mas não substituem o log interno do PDI.

Para entender como validar a execução no `pdi.log`, acompanhar o arquivo em tempo real com PowerShell e aplicar filtros, consulte [`TESTING.md`](TESTING.md).


## 7. Parametros de repository nos Ex02 e Ex05

Os exemplos de repository explicito acrescentam quatro parametros importantes:

```text
rep
user
pass
trans  (ou job)
```

`rep` seleciona pelo nome um repository conhecido pelo ambiente PDI do executor. `user` e `pass` sao usados para conectar a esse repository. Eles nao substituem `--user` do `curl`, que continua sendo a autenticacao HTTP no Pentaho Server ou Carte.

Exemplo conceitual:

```text
--user "cluster:cluster"              -> autenticacao HTTP do Carte
--data-urlencode "rep=PentahoRepo"    -> repository PDI
--data-urlencode "user=admin"         -> usuario do repository
--data-urlencode "pass=password"      -> senha do repository
--data-urlencode "trans=/public/..."  -> objeto dentro do repository
```

Como `pass` e enviado na query segundo o contrato da API, consulte as observacoes de seguranca em [`REPOSITORY.md`](REPOSITORY.md).
