# Uso do curl nos exemplos

Os exemplos atuais usam `curl.exe` em arquivos `.bat`. O Postman será adicionado posteriormente em pastas separadas dentro de cada cenário.

## 1. Opções usadas

| Opção | Função |
|---|---|
| `--silent` | oculta a barra de progresso |
| `--show-error` | mantém a exibição de erros com `--silent` |
| `--fail-with-body` | retorna erro do curl em HTTP 4xx/5xx e preserva o corpo da resposta |
| `--user` | envia autenticação HTTP Basic ao Pentaho Server ou Carte |
| `--get` | usa os dados informados como query string de uma requisição GET |
| `--data-urlencode` | adiciona parâmetros com URL encoding automático |
| `--output` | grava temporariamente o corpo da resposta |
| `--write-out` | obtém o status HTTP para validação pelo script |

## 2. Por que `--get` e `--data-urlencode`

Em vez de concatenar manualmente:

```text
?trans=C:\pasta com espaco\arquivo.ktr&level=Basic
```

os scripts usam:

```bat
--get ^
--data-urlencode "trans=%TRANS_PATH%" ^
--data-urlencode "level=%PDI_LOG_LEVEL%"
```

Isso reduz problemas com espaços e caracteres reservados de URL.

## 3. `--user` e `user` não significam a mesma coisa

```bat
--user "%CARTE_USER%:%CARTE_PASSWORD%"
```

é autenticação HTTP no Carte.

Na variação de repository explícito:

```bat
--data-urlencode "user=%PDI_REPOSITORY_USER%"
--data-urlencode "pass=%PDI_REPOSITORY_PASSWORD%"
```

são credenciais do Pentaho Repository e fazem parte dos parâmetros da API PDI.

## 4. `%%{http_code}` em `.bat`

No curl a expressão é:

```text
%{http_code}
```

Dentro de `.bat`, `%` é escapado como `%%`:

```bat
--write-out "%%{http_code}"
```

## 5. Tratamento de status

Os scripts classificam:

```text
2xx -> sucesso HTTP
3xx -> redirecionamento inesperado
4xx -> erro de requisição ou autenticação
5xx -> erro do servidor ou da execução
```

`--fail-with-body` não trata `3xx` como falha. Por isso o script também verifica explicitamente o primeiro dígito do status.

## 6. Corpo da resposta e log PDI

A resposta HTTP não substitui o log da engine. Em especial, `executeTrans` pode terminar com HTTP 200 e corpo vazio. Consulte [testing.md](testing.md) para os critérios de validação.
