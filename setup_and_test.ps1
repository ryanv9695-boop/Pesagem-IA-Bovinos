param (
    [string]$Database = "agrofense-ia-pesagem",
    [string]$AdminUser = "postgres",
    [string]$ReadOnlyPassword = "123456",
    [int]$Port = 5432
)

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " Configuração MCP PostgreSQL 18 - Usuário Read-Only       " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# 1. Localizar psql
$psqlPath = "C:\Program Files\PostgreSQL\18\bin\psql.exe"
if (-not (Test-Path $psqlPath)) {
    $cmd = Get-Command psql -ErrorAction SilentlyContinue
    if ($cmd) {
        $psqlPath = $cmd.Source
    } else {
        Write-Error "psql.exe não foi encontrado em 'C:\Program Files\PostgreSQL\18\bin\psql.exe' nem no PATH do sistema."
        exit 1
    }
}

Write-Host "[1/4] Usando psql em: $psqlPath" -ForegroundColor Green

# 2. Atualizar o script SQL com a senha desejada temporariamente ou executar com substituição
$sqlFile = "$PSScriptRoot\setup_mcp_readonly.sql"
if (-not (Test-Path $sqlFile)) {
    Write-Error "Arquivo $sqlFile não encontrado!"
    exit 1
}

Write-Host "[2/4] Executando script SQL no banco '$Database' com o usuário admin '$AdminUser'..." -ForegroundColor Green
Write-Host "Nota: Se o PostgreSQL solicitar a senha do '$AdminUser', digite-a no prompt abaixo." -ForegroundColor Yellow

& $psqlPath -U $AdminUser -h localhost -p $Port -d $Database -f $sqlFile

if ($LASTEXITCODE -ne 0) {
    Write-Warning "Ocorreu um erro ou aviso ao rodar o script SQL. Verifique as credenciais do superusuário."
} else {
    Write-Host "Script SQL executado com sucesso!" -ForegroundColor Green
}

# 3. Atualizar o arquivo mcp_config.json
$jsonConfig = @"
{
  "mcpServers": {
    "postgres": {
      "command": "npx.cmd",
      "args": [
        "-y",
        "@modelcontextprotocol/server-postgres",
        "postgresql://mcp_readonly:$ReadOnlyPassword@localhost:$Port/$Database"
      ]
    }
  }
}
"@

$mcpConfigFile = "$PSScriptRoot\mcp_config.json"
Set-Content -Path $mcpConfigFile -Value $jsonConfig -Encoding utf8
Write-Host "[3/4] Configuração salva em: $mcpConfigFile" -ForegroundColor Green

# 4. Testar a conexão com o usuário mcp_readonly
Write-Host "[4/4] Testando conexão com usuário mcp_readonly..." -ForegroundColor Green
$env:PGPASSWORD = $ReadOnlyPassword

Write-Host ">> Testando SELECT (deve funcionar):" -ForegroundColor Gray
& $psqlPath -U mcp_readonly -h localhost -p $Port -d $Database -c "SELECT current_user, current_database(), 'Conexão OK' AS status;"

Write-Host ">> Testando tentativa de gravação (DEVE ser bloqueada):" -ForegroundColor Gray
& $psqlPath -U mcp_readonly -h localhost -p $Port -d $Database -c "CREATE TABLE teste_mcp_block (id int);" 2>&1

Remove-Item Env:\PGPASSWORD

Write-Host "`nConcluído! Se o teste de CREATE TABLE foi bloqueado, o usuário está 100% seguro." -ForegroundColor Cyan
Write-Host "Para testar com o MCP Inspector, execute:" -ForegroundColor Yellow
Write-Host "npx @modelcontextprotocol/inspector npx.cmd -y @modelcontextprotocol/server-postgres `"postgresql://mcp_readonly:$ReadOnlyPassword@localhost:$Port/$Database`"" -ForegroundColor Yellow
