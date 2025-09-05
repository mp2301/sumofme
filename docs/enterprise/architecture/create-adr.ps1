Param(
    [Parameter(Mandatory=$true)][string]$Title
)

# create-adr.ps1 - create a new ADR file with YYYY-MM-DD-title.md
$slug = $Title.ToLower() -replace '[^a-z0-9\- ]','' -replace ' ','-'
$date = Get-Date -Format yyyy-MM-dd
$fileName = "$date-$slug.md"
$dir = Join-Path -Path $PSScriptRoot -ChildPath 'adr'
if(!(Test-Path $dir)){ New-Item -ItemType Directory -Path $dir | Out-Null }
$path = Join-Path -Path $dir -ChildPath $fileName

if(Test-Path $path){
    Write-Host "File already exists: $path" -ForegroundColor Yellow
    exit 1
}

$template = Get-Content -Path (Join-Path $PSScriptRoot 'adr-template.md') -Raw
$template = $template -replace '<short title>',$Title
Set-Content -Path $path -Value $template -Encoding UTF8
Write-Host "Created ADR: $path" -ForegroundColor Green
