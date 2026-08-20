# Roadmap

Os quatro cenários principais estão validados e possuem exemplos em curl e Postman. As próximas evoluções ficam registradas aqui para evitar criar estruturas de implementação antes do trabalho começar.

## Monitoramento

Estudar endpoints de acompanhamento e controle:

- status de Transformation;
- status de Job;
- uso do ID Carte retornado pelas execuções;
- stop/remove quando aplicável;
- diferenças entre respostas síncronas e execuções registradas no Carte.

## Scheduler API do Pentaho Server

Tratar separadamente da execução direta de `.ktr/.kjb`:

- listar agendamentos;
- criar e gerenciar schedules;
- `triggerNow`;
- diferença entre executar um artefato e disparar um agendamento.

## APIs legadas/depreciadas

Manter apenas como estudo de compatibilidade:

- `addTrans`;
- `addJob`;
- envio de `transformation_configuration` / `job_configuration`.

## Outras evoluções

- exemplos em PowerShell puro;
- execução automatizada da Collection com Postman CLI ou Newman;
- CI/CD para publicação e execução;
- Java API do PDI como projeto separado;
- HTTPS e contas não administrativas.
