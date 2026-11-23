# Registra as tarefas no Agendador do Windows, para o usuario atual, sem precisar de administrador:
#   IntimacoesDJEN\Rotina : todo dia no horario escolhido; roda assim que possivel se o PC estava desligado.
#   IntimacoesDJEN\Bot    : no logon (so quando ha Telegram configurado).
# Usa schtasks.exe com XML em vez dos cmdlets do modulo ScheduledTasks: esses cmdlets falham com
# "PSTypeName MSFT_TaskAction" quando o PowerShell e aberto por outro programa (aqui, pelo Node).
param(
  [Parameter(Mandatory = $true)][string]$App,
  [Parameter(Mandatory = $true)][string]$Rotina,
  [Parameter(Mandatory = $true)][string]$Bot,
  [Parameter(Mandatory = $true)][string]$Horario,
  [Parameter(Mandatory = $true)][string]$Dados,
  [switch]$ComBot,
  # Pasta do Agendador (outro valor so para teste).
  [string]$Pasta = 'IntimacoesDJEN'
)
$ErrorActionPreference = 'Stop'

$node = (Get-Command node -ErrorAction Stop).Source
$usuario = "$env:USERDOMAIN\$env:USERNAME"
New-Item -ItemType Directory -Force -Path "$Dados\logs" | Out-Null

function Escapar([string]$s) { [System.Security.SecurityElement]::Escape($s) }

function Comando([string]$script, [string]$log) {
  # cmd /c set "DJEN_DADOS=..." && "node" --no-warnings "script" >> "log" 2>&1
  "/c set `"DJEN_DADOS=$Dados`" && `"$node`" --no-warnings `"$script`" >> `"$log`" 2>&1"
}

function XmlTarefa([string]$descricao, [string]$gatilho, [string]$argumentos, [string]$limite, [int]$repeticoes, [string]$intervalo) {
@"
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo><Description>$(Escapar $descricao)</Description></RegistrationInfo>
  <Triggers>$gatilho</Triggers>
  <Principals>
    <Principal id="Author">
      <UserId>$(Escapar $usuario)</UserId>
      <LogonType>InteractiveToken</LogonType>
      <RunLevel>LeastPrivilege</RunLevel>
    </Principal>
  </Principals>
  <Settings>
    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
    <DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>false</StopIfGoingOnBatteries>
    <StartWhenAvailable>true</StartWhenAvailable>
    <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
    <ExecutionTimeLimit>$limite</ExecutionTimeLimit>
    <RestartOnFailure><Interval>$intervalo</Interval><Count>$repeticoes</Count></RestartOnFailure>
    <Enabled>true</Enabled>
  </Settings>
  <Actions Context="Author">
    <Exec>
      <Command>cmd.exe</Command>
      <Arguments>$(Escapar $argumentos)</Arguments>
      <WorkingDirectory>$(Escapar $App)</WorkingDirectory>
    </Exec>
  </Actions>
</Task>
"@
}

function Registrar([string]$nome, [string]$xml) {
  $arq = Join-Path $env:TEMP "intimacoes-djen-$nome.xml"
  [System.IO.File]::WriteAllText($arq, $xml, [System.Text.Encoding]::Unicode)
  & schtasks.exe /Create /TN "$Pasta\$nome" /XML $arq /F | Out-Null
  $codigo = $LASTEXITCODE
  Remove-Item $arq -ErrorAction SilentlyContinue
  if ($codigo -ne 0) { throw "schtasks nao registrou a tarefa $nome (codigo $codigo)." }
}

# Rotina diaria
$inicio = (Get-Date -Format 'yyyy-MM-dd') + "T$($Horario):00"
$diario = "<CalendarTrigger><StartBoundary>$inicio</StartBoundary><Enabled>true</Enabled><ScheduleByDay><DaysInterval>1</DaysInterval></ScheduleByDay></CalendarTrigger>"
Registrar 'Rotina' (XmlTarefa 'Consulta o DJEN e faz a triagem das intimacoes.' $diario (Comando $Rotina "$Dados\logs\rotina-saida.log") 'PT2H' 3 'PT10M')

if ($ComBot) {
  $logon = "<LogonTrigger><Enabled>true</Enabled><UserId>$(Escapar $usuario)</UserId></LogonTrigger>"
  Registrar 'Bot' (XmlTarefa 'Bot do Telegram para aprovar prazos.' $logon (Comando $Bot "$Dados\logs\bot-saida.log") 'PT0S' 999 'PT1M')
  & schtasks.exe /Run /TN "$Pasta\Bot" | Out-Null
  Write-Output "Tarefas registradas: rotina diaria as $Horario e bot do Telegram no logon."
} else {
  # Remove um bot antigo, se houver. Sem bot, o schtasks reclama no stderr; no PowerShell 5.1 com
  # ErrorActionPreference=Stop isso viraria erro fatal, entao o aviso e ignorado so aqui.
  $antes = $ErrorActionPreference
  $ErrorActionPreference = 'Continue'
  & schtasks.exe /Delete /TN "$Pasta\Bot" /F 2>&1 | Out-Null
  $ErrorActionPreference = $antes
  Write-Output "Tarefa registrada: rotina diaria as $Horario."
}
