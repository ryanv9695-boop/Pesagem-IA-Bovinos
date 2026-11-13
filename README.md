Módulo de IA para Pesagem de Bovinos (Integração PostgreSQL) - antgravity 🐂📈

Bem-vindo ao repositório do Módulo de Inteligência Artificial para Pesagem de Bovinos. Este projeto utiliza aprendizado de máquina (Machine Learning) e análise de dados multivariados (clima, suplementação, índices multiespectrais) para prever o ganho de peso de bovinos Nelore, integrando os resultados diretamente em um banco de dados PostgreSQL.

📁 Estrutura do Repositório

A estrutura do projeto foi desenhada para separar claramente a ingestão de dados, o processamento, a modelagem preditiva e a integração com o banco de dados.

1. Raiz do Projeto (Configuração e Banco de Dados)

setup_and_test.ps1: Script PowerShell principal para inicializar o ambiente, testar dependências e configurar a infraestrutura local.

setup_mcp_readonly.sql / import_all_data.sql: Scripts SQL responsáveis por preparar as tabelas no PostgreSQL, importar os dados tabulares brutos e configurar as permissões seguras (modo leitura) para que ferramentas de IA consumam as informações.

mcp_config.json / .agents/ / .vscode/: Arquivos de configuração do Model Context Protocol (MCP), que definem como os agentes de IA interagem com o banco de dados e o ambiente de desenvolvimento.

2. Diretório data/ (Pipeline de Dados)

O coração do sistema de informações de pesagem e variáveis ambientais.

raw/ (Dados Brutos): Contém o dataset base com histórico de pesagem, suplementação e condições climáticas.

src/: Scripts e notebooks auxiliares de coleta (ex: collect_weather_data.ipynb e get_image_data.ipynb) que extraem e consolidam variáveis no .cache.sqlite antes de compor o dataset tabular.

processed/ (Dados Prontos para ML):

treino.csv, validacao.csv, teste.csv: Divisões do dataset respeitando a unidade animal-tempo para evitar vazamento de dados (Target Leakage) durante o treinamento da IA.

3. Diretório notebooks/ (Modelagem Preditiva)

Bovino.ipynb: O motor principal de IA. Consome os dados processados, treina algoritmos preditivos baseados em árvores (ex: XGBoost/LightGBM), extrai os fatores de explicabilidade (SHAP) e gera as projeções de peso futuro com seus respectivos quantis de incerteza (P10 a P90).

Untitled.ipynb: Notebook auxiliar para análises exploratórias.
