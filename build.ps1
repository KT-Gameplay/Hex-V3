param(
    [string]$GameRoot = 'F:\Funkin2\Funkin-secret',
    [string]$Engine
)

$ErrorActionPreference = 'Stop'

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $Engine) { $Engine = Join-Path (Split-Path -Parent $here) 'modchart-engine' }

$sdk = Join-Path $GameRoot 'sdk\windows\release'
$temp = [System.IO.Path]::GetTempPath()
$staged = Join-Path $temp 'hex-menus-sdk'
$source = Join-Path $temp 'hex-menus-src'
$utf8 = New-Object System.Text.UTF8Encoding($false)

$info = @(Get-Content (Join-Path $sdk 'export_classes.info'))
$info += 0..1023 | ForEach-Object { "class JsonParser_$_"; "class JsonWriter_$_" }
$info += Get-Content (Join-Path $Engine 'engine_classes.info')

$hxml = @(Get-Content (Join-Path $sdk 'cppia.hxml')) + "-cp $(Join-Path $Engine 'cppia-src')"

New-Item -ItemType Directory -Force $staged | Out-Null
[System.IO.File]::WriteAllText((Join-Path $staged 'export_classes.info'), (($info | Select-Object -Unique) -join "`n") + "`n", $utf8)
[System.IO.File]::WriteAllText((Join-Path $staged 'cppia.hxml'), ($hxml -join "`n") + "`n", $utf8)

if (Test-Path $source) { Remove-Item -Recurse -Force $source }
Copy-Item -Recurse (Join-Path $here 'cppia-src') $source
Copy-Item -Recurse -Force (Join-Path $here 'cppia-charts\*') $source

& (Join-Path $GameRoot 'scripts\cppia\build_cppia.ps1') --sdk $staged $GameRoot $source (Join-Path $here 'ui\scripts\menus\HexMenus.cppia')
