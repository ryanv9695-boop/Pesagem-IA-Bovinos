# Módulo de IA para Pesagem de Bovinos (Integração PostgreSQL) - antgravity

## Visão Geral
Este repositório contém a documentação do módulo de inteligência artificial da antgravity focado exclusivamente na estimativa e previsão de peso de bovinos, projetado para consumo e integração direta com o banco de dados PostgreSQL.

## Princípio de Design
O sistema está centrado no **Motor Biológico (Machine Learning)**, que:
1. Prevê o peso futuro do animal (ex: 30, 60, 90 dias) e calcula sua faixa de incerteza estatística usando dados tabulares (XGBoost/LightGBM).
2. Alimenta diretamente as tabelas no PostgreSQL (configurado através dos scripts `import_all_data.sql` e `setup_mcp_readonly.sql`), facilitando o consumo por outras camadas, APIs, ou por um servidor Model Context Protocol (MCP) configurado localmente via `mcp_config.json`.

## Estrutura da Documentação
- `models/MODEL_CARD.md`: Especificações técnicas, limitações e explicabilidade do modelo de IA preditivo.
- `data/DATA_DICTIONARY.md`: Esquema de dados, variáveis temporais e prevenção de vazamento de dados.
- `architecture/SYSTEM_DESIGN.md`: Arquitetura do fluxo de ingestão e integração entre o modelo de IA e o banco PostgreSQL.
- `experiments/EVALUATION_PROTOCOL.md`: Protocolo de validação, baselines e métricas de sucesso do modelo zootécnico.
