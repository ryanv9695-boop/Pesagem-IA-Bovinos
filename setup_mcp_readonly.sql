-- ==============================================================================
-- Script de Configuração de Usuário MCP Read-Only para PostgreSQL 18
-- Objetivo: Criar o usuário mcp_readonly com permissões estritas de leitura (SELECT)
-- e defesa em profundidade com transações somente leitura forçadas no banco.
-- ==============================================================================

-- 1. Criação do usuário (Altere a senha conforme desejado)
DO
$do$
BEGIN
   IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'mcp_readonly') THEN
      CREATE USER mcp_readonly WITH PASSWORD '123456';
   ELSE
      ALTER USER mcp_readonly WITH PASSWORD '123456';
   END IF;
END
$do$;

-- 2. Conexão e restrições no banco de dados atual
-- NOTA: Execute conectado ao banco de dados desejado (ex: postgres, bovinos, etc.)
GRANT CONNECT ON DATABASE current_database() TO mcp_readonly;
REVOKE TEMPORARY ON DATABASE current_database() FROM mcp_readonly;

-- 3. Restrições no schema público
GRANT USAGE ON SCHEMA public TO mcp_readonly;
REVOKE CREATE ON SCHEMA public FROM mcp_readonly;

-- 4. Permissões de SELECT em tabelas e sequências existentes
GRANT SELECT ON ALL TABLES IN SCHEMA public TO mcp_readonly;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO mcp_readonly;

-- 5. Permissões automáticas para tabelas futuras criadas pelo usuário atual
ALTER DEFAULT PRIVILEGES IN SCHEMA public 
GRANT SELECT ON TABLES TO mcp_readonly;

ALTER DEFAULT PRIVILEGES IN SCHEMA public 
GRANT SELECT ON SEQUENCES TO mcp_readonly;

-- 6. Defesa em Profundidade: Força transações da sessão deste usuário como Read-Only
-- Mesmo que uma tabela futura receba privilégios indevidos ou funções sejam chamadas,
-- o motor do PostgreSQL bloqueará qualquer mutação (INSERT, UPDATE, DELETE, DDL).
ALTER USER mcp_readonly SET default_transaction_read_only = on;

-- Confirmação
SELECT 'Usuário mcp_readonly configurado com sucesso com permissões estritas de SELECT.' AS status;
