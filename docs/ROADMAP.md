# Roadmap

Os quatro cenários principais estão validados. As próximas evoluções ficam registradas aqui para evitar criar pastas de implementação antes do trabalho começar.

## Postman

As pastas `postman/` já existem dentro de cada exemplo e da variação avançada. Próximos passos:

- criar requests equivalentes aos scripts curl;
- avaliar uma collection única com environments para Pentaho Server e Carte;
- documentar variáveis, autenticação e parâmetros;
- manter a mesma matriz de cenários usada pelos exemplos curl.

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
- CI/CD para publicação e execução;
- Java API do PDI como projeto separado;
- HTTPS e contas não administrativas.
