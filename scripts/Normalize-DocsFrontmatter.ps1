# Normalizes Markdown files under docs/ to ensure Last Reviewed frontmatter and a footer include

$DocsPath = "./docs"
$FooterFileName = "_footer.md"
$DefaultDate = (Get-Date -Format yyyy-MM-dd)

Write-Host "Docs root: $DocsPath"

$files = Get-ChildItem -Path $DocsPath -Recurse -Include *.md | Where-Object {
    $_.FullName -notmatch "\\docs\\reports\\" -and $_.Name -ne $FooterFileName
}

foreach ($f in $files) {
    Write-Host "Processing: $($f.FullName)"
    $content = Get-Content -Raw -LiteralPath $f.FullName

    # Check for Last Reviewed in the first 12 lines
    $lines = $content -split "`n"
    $firstLines = $lines[0..([Math]::Min(11, $lines.Length - 1))] -join "`n"
    if ($firstLines -notmatch "Last Reviewed") {
        $front = "---`nLast Reviewed: $DefaultDate`nTags: `n---`n`n"
        Write-Host "  Adding frontmatter"
        $content = $front + $content
    } else {
        Write-Host "  Frontmatter present"
    }

    # Compute relative prefix from file folder to docs root
    $fullDocsRoot = (Get-Item $DocsPath).FullName.TrimEnd('\')
    $dir = $f.Directory.FullName.TrimEnd('\')
    $rel = ''
    if ($dir -ne $fullDocsRoot) {
        $relParts = $dir.Substring($fullDocsRoot.Length).TrimStart('\') -split '\\'
        $depth = $relParts.Length
        for ($i=0; $i -lt $depth; $i++) { $rel += "../" }
    }
    if ($rel -eq '') { $rel = './' }

    # produce a literal markdown include line, e.g. Include: `../_footer.md`
    $bt = [char]96
    $literalInclude = $bt + $rel + $FooterFileName + $bt
    $includeLine = "Include: $literalInclude"

    if ($content -notmatch [regex]::Escape($FooterFileName)) {
        Write-Host "  Appending footer include: $rel$FooterFileName"
        if ($content.TrimEnd() -match "---$") {
            $content = $content + "`n" + $includeLine + "`n"
        } else {
            $content = $content + "`n---`n" + $includeLine + "`n"
        }
    } else {
        Write-Host "  Footer already present"
    }

    Set-Content -LiteralPath $f.FullName -Value $content -Encoding UTF8
}

Write-Host "Normalization complete."