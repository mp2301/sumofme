Param(
    [string]$Path = "docs/enterprise/architecture/adr"
)

$errors = @()
$adrFiles = Get-ChildItem -Path $Path -Filter "20*-*.md" -File | Sort-Object Name
$requiredFrontMatter = @('Title:', 'Status:')

foreach($file in $adrFiles){
    $content = Get-Content $file.FullName -Raw
    foreach($req in $requiredFrontMatter){
        if($content -notmatch [regex]::Escape($req)){
            $errors += "Missing '$req' in $($file.Name)"
        }
    }
    if($file.BaseName -notmatch '^[0-9]{4}-[0-9]{2}-[0-9]{2}-'){ $errors += "Filename pattern invalid: $($file.Name)" }
}

if($errors){
    Write-Host 'ADR validation FAILED:' -ForegroundColor Red
    $errors | ForEach-Object { Write-Host " - $_" -ForegroundColor Yellow }
    exit 1
}else{
    Write-Host "ADR validation passed ($($adrFiles.Count) files)." -ForegroundColor Green
}
