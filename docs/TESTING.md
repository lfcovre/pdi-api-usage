# Testes, logs e resultados validados

## 1. Pontos de observação

### Cliente HTTP

Pode ser:

- terminal que executa o `.bat` com curl;
- resposta e aba de testes do Postman.

O cliente mostra endpoint, parâmetros relevantes, corpo da resposta e status HTTP. A Collection Postman também executa testes básicos sobre o status e, quando aplicável, sobre o XML retornado.

### Engine PDI

- Pentaho Server: `<PENTAHO_SERVER_HOME>\logs\pdi.log`;
- Carte Standalone: terminal em que `Carte.bat` está rodando.

Os artefatos usam o marcador:

```text
[PDI API TEST]
```

## 2. Acompanhar o `pdi.log`

```powershell
$PdiLog = "C:\Pentaho\server\pentaho-server\logs\pdi.log"
Get-Content $PdiLog -Tail 100 -Wait
```

Somente o marcador do projeto:

```powershell
Get-Content $PdiLog -Tail 100 -Wait |
    Select-String "PDI API TEST"
```

Filtro mais amplo:

```powershell
Get-Content $PdiLog -Tail 100 -Wait |
    Select-String -Pattern "PDI API TEST|trf_api_test|job_api_test|repository"
```

Pesquisa histórica:

```powershell
Select-String -Path $PdiLog -Pattern "PDI API TEST" -Context 2,2
```

## 3. Critério de validação

Um cenário é considerado validado quando:

1. o cliente HTTP não apresenta erro de transporte;
2. a API retorna HTTP 2xx;
3. a engine registra a execução;
4. `[PDI API TEST]` aparece no log;
5. `P_MESSAGE` contém o valor enviado;
6. o artefato não termina com erro funcional.

Um teste verde no Postman confirma a resposta HTTP esperada, mas não substitui os itens 3 a 6.

## 4. Status atual

| Exemplo | Transformation | Job | Status |
|---|---|---|---|
| Ex01 — Pentaho Server / filesystem | validada | validado | Validado |
| Ex02 — Pentaho Server / Pentaho Repository | validada | validado | Validado |
| Ex03 — Carte / filesystem | validada | validado | Validado |
| Ex04 — Carte / Pentaho Repository | validada | validado | Validado |

A variação Carte + repository explícito também foi validada para Transformation e Job.

## 5. Comportamentos observados

### Ex01 — Pentaho Server / filesystem

`executeTrans` retornou HTTP 200 com corpo vazio e a Transformation foi confirmada no `pdi.log`.

`executeJob` retornou XML contendo:

```text
Job started
<id>...</id>
```

### Ex02 — Pentaho Server / Pentaho Repository

`runTrans` retornou `Transformation started`, um ID e HTTP 200.

`runJob` retornou `Job started`, um ID e HTTP 200.

Em algumas linhas do `pdi.log`, o contexto do path lógico apareceu duplicado, por exemplo:

```text
/public/pdi-api-usage//public/pdi-api-usage/trf_api_test.ktr
```

A execução do objeto correto foi confirmada; o comportamento foi tratado apenas como peculiaridade do contexto de logging observado.

### Ex03 — Carte / filesystem

No ambiente validado, os endpoints sem barra final retornaram HTTP 301. Os scripts e a Collection usam:

```text
/kettle/executeTrans/
/kettle/executeJob/
```

Com a barra final, Transformation e Job retornaram HTTP 200 e foram confirmados no terminal do Carte.

### Ex04 — Carte / Pentaho Repository

O terminal do Carte mostrou a leitura de `repositories.xml` e a conexão com o Pentaho Repository. `runTrans` e `runJob` retornaram HTTP 200, IDs de execução e os artefatos receberam `P_MESSAGE`.

Em uma execução foi observado erro de rotação/exclusão de `pdi.log` por arquivo em uso. A execução continuou normalmente e o evento não foi considerado falha do endpoint.

## 6. Salvar a saída do cliente curl

Exemplo:

```powershell
.	ransformation.bat *> transformation-client.log
```

Esse arquivo contém a saída do cliente HTTP, não o log interno completo do PDI.

Para Postman, consulte [postman.md](postman.md) para os testes incluídos e a observação sobre redirects.
