param(
  [string]$EnvFile = ".env.production.local",
  [switch]$ResetPasswords,
  [switch]$SkipVerify
)

$ErrorActionPreference = "Stop"

$ProjectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $ProjectRoot

function Import-DotEnvFile {
  param([string]$Path)

  if (-not (Test-Path -LiteralPath $Path)) {
    return
  }

  Get-Content -LiteralPath $Path | ForEach-Object {
    $line = $_.Trim()
    if ($line.Length -eq 0 -or $line.StartsWith("#")) {
      return
    }

    $parts = $line.Split("=", 2)
    if ($parts.Count -ne 2) {
      return
    }

    $name = $parts[0].Trim()
    $value = $parts[1].Trim()
    $value = $value.Trim('"').Trim("'")

    if ($name) {
      [Environment]::SetEnvironmentVariable($name, $value, "Process")
    }
  }
}

Import-DotEnvFile -Path (Join-Path $ProjectRoot $EnvFile)

$env:RAILS_ENV = if ($env:RAILS_ENV) { $env:RAILS_ENV } else { "production" }

$required = @("DATABASE_URL", "RAILS_MASTER_KEY", "SECRET_KEY_BASE")
$missing = $required | Where-Object { -not [Environment]::GetEnvironmentVariable($_, "Process") }

if ($missing.Count -gt 0) {
  Write-Error "Missing required env vars: $($missing -join ', '). Put them in $EnvFile or set them in this PowerShell session."
}

if ($ResetPasswords) {
  $env:DEMO_SEED_RESET_PASSWORDS = "1"
} else {
  Remove-Item Env:\DEMO_SEED_RESET_PASSWORDS -ErrorAction SilentlyContinue
}

Write-Host "Refreshing Unizone demo seed against $($env:RAILS_ENV) database..." -ForegroundColor Cyan
bundle exec rails demo:refresh

if (-not $SkipVerify) {
  Write-Host ""
  Write-Host "Top published events:" -ForegroundColor Cyan
  bundle exec rails runner "puts Event.published.to_a.sort_by { |event| [-event.attendees_count, event.date] }.first(3).map { |event| [event.title, event.city, event.attendees_count].join(' | ') }"
}

Write-Host ""
Write-Host "Demo seed refresh complete." -ForegroundColor Green
