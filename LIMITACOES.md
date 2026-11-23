# Limitações conhecidas

Situações em que o Intimações DJEN não calcula o prazo, ou pode calcular de forma incompleta (cláusula 3 dos Termos de Uso). Nesses casos, a contagem é feita pelo advogado.

## Versão 0.2.3 (23/11/2026)

**Prazos que o programa não calcula ou calcula de forma incompleta**

- Prazos em horas, meses ou anos, e prazos de direito material. A contagem em dias úteis vale só para prazos processuais (CPC, art. 219, parágrafo único). A triagem por regras converte prazo em horas para dias, arredondando para cima.
- Intimações pessoais ou por vista, feitas fora do Diário (Lei 11.419/2006, art. 4º, § 2º).
- Prazos que começam de outro marco que não a publicação no Diário: juntada de aviso de recebimento ou de mandado, consulta à intimação no portal do tribunal ou no Domicílio Judicial Eletrônico, entre outros previstos no CPC, art. 231.
- Processos criminais, infracionais e outros procedimentos com regra de contagem própria. O programa conta em dias corridos, não desconta o recesso de 20/12 a 20/01 e mostra aviso para conferir.
- Intimações que não chegam ao DJEN, ou que chegam com dado errado ou fora do prazo por falha na origem.

**Calendários**

- O programa só conhece os dias sem expediente fixados por cada tribunal quando o calendário daquele tribunal e ano está cadastrado. Veja a [lista de calendários](CALENDARIOS.md). Sem calendário, Quarta-feira de Cinzas e outros dias fixados por ato do tribunal contam como dias úteis, e o cartão avisa.
- Suspensões avulsas (indisponibilidade do sistema, portaria de última hora) só entram depois que o calendário é atualizado ou que o advogado as cadastra como feriado local.

**Prazo em dobro**

- O programa não verifica sozinho se a parte é Fazenda Pública, Ministério Público, Defensoria Pública, ou se há litisconsortes com procuradores diferentes. O dobro só é aplicado quando a triagem pelo Claude sugere, e o cartão avisa. A conferência é do advogado.

**Funcionamento**

- A consulta diária depende do computador ligado. Se estiver desligado no horário marcado, ela roda quando o computador for ligado.
- Enquanto o aplicativo do Google criado na instalação estiver em modo de teste, a autorização do Google Agenda expira em até 7 dias e precisa ser renovada.

## Histórico

| Data | Versão | Mudança |
|---|---|---|
| 23/11/2026 | 0.2.3 | Primeira publicação desta lista. |
