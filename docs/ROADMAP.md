# Roadmap

Este arquivo registra os cenarios planejados para que eles nao se percam durante a evolucao incremental do projeto.

## Escopo principal: 6 cenarios de execucao

| Exemplo | Executor | Origem / modo | API principal | Status |
|---|---|---|---|---|
| Ex01 | Pentaho Server | Filesystem acessivel pelo servidor | `executeTrans` / `executeJob` | **Validado** |
| Ex02 | Pentaho Server | Repositorio informado explicitamente | `executeTrans` / `executeJob` com `rep`, `user` e `pass` | Proxima etapa |
| Ex03 | Pentaho Server | Repositorio pre-configurado | `runTrans` / `runJob` | Planejado; validar no ambiente Pentaho Server |
| Ex04 | Carte Standalone | Filesystem acessivel pelo Carte | `executeTrans` / `executeJob` | Implementado; pendente de validacao via API |
| Ex05 | Carte Standalone | Repositorio informado explicitamente | `executeTrans` / `executeJob` com `rep`, `user` e `pass` | Proxima etapa |
| Ex06 | Carte Standalone | Repositorio pre-configurado no Carte | `runTrans` / `runJob` | Planejado |

## Blocos futuros

### c03_monitoring

Exemplos para consultar e controlar execucoes, incluindo status, parada e remocao de execucoes registradas no Carte/Pentaho.

Possiveis endpoints a documentar e testar:

- `transStatus`
- `jobStatus`
- `stopTrans`
- `stopJob`
- `removeTrans`
- `removeJob`

A lista final deve ser validada contra a versao do Pentaho/PDI usada nos testes.

### c04_pentaho_scheduler

Exemplos especificos do Pentaho Server para criar/consultar agendamentos e disparar uma execucao pelo scheduler, incluindo o caso de `triggerNow`.

Esse bloco sera mantido separado dos exemplos Carte porque o scheduler pertence ao Pentaho Server e representa outro modelo de execucao.

### legacy

Registrar, apenas para estudo e compatibilidade, APIs depreciadas relacionadas ao envio de configuracoes XML, como `addTrans` e `addJob`. Esses exemplos nao devem ser apresentados como abordagem recomendada para novas integracoes.
