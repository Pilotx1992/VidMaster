# One-off icon migration script.
# Replaces `Icons.X` usages with `Symbols.X` from material_symbols_icons
# and ensures every touched file imports the package.

$ErrorActionPreference = "Stop"

# Special mappings (rename or drop suffix) where the Symbols name differs.
$specialMap = @{
    'Icons.bedtime_outlined'        = 'Symbols.bedtime'
    'Icons.cast_connected_outlined' = 'Symbols.cast_connected'
    'Icons.edit_outlined'           = 'Symbols.edit'
    'Icons.folder_outlined'         = 'Symbols.folder'
    'Icons.folder_open_outlined'    = 'Symbols.folder_open'
    'Icons.info_outline'            = 'Symbols.info'
    'Icons.library_music_outlined'  = 'Symbols.library_music'
    'Icons.movie_creation_outlined' = 'Symbols.movie_creation'
    'Icons.movie_outlined'          = 'Symbols.movie'
    'Icons.music_note_outlined'     = 'Symbols.music_note'
    'Icons.playlist_add_outlined'   = 'Symbols.playlist_add'
    'Icons.share_outlined'          = 'Symbols.share'
    'Icons.timer_outlined'          = 'Symbols.timer'
    'Icons.video_library_outlined'  = 'Symbols.video_library'
    'Icons.play_circle_filled'      = 'Symbols.play_circle'
    'Icons.play_circle_fill_rounded' = 'Symbols.play_circle_rounded'
}

$libDir = Join-Path $PSScriptRoot "..\lib"
$libDir = Resolve-Path $libDir
$importLine = "import 'package:material_symbols_icons/symbols.dart';"

$touchedFiles = 0
$totalReplacements = 0

Get-ChildItem -Path $libDir -Recurse -Filter "*.dart" | ForEach-Object {
    $file = $_.FullName
    $original = Get-Content -Raw -Path $file
    if (-not ($original -match 'Icons\.')) { return }

    $content = $original
    $fileReplacements = 0

    foreach ($key in $specialMap.Keys) {
        $escaped = [regex]::Escape($key) + '\b'
        $before = $content
        $content = [regex]::Replace($content, $escaped, $specialMap[$key])
        $count = ($before | Select-String -Pattern $escaped -AllMatches).Matches.Count
        $fileReplacements += $count
    }

    $genericMatches = [regex]::Matches($content, 'Icons\.[A-Za-z_]\w*\b')
    $fileReplacements += $genericMatches.Count
    $content = [regex]::Replace($content, 'Icons\.([A-Za-z_]\w*)\b', 'Symbols.$1')

    if ($fileReplacements -gt 0 -and ($content -notmatch [regex]::Escape($importLine))) {
        $matInfo = [regex]::Match($content, "import\s+'package:flutter/material\.dart';\s*\r?\n")
        if ($matInfo.Success) {
            $insertAt = $matInfo.Index + $matInfo.Length
            $content = $content.Substring(0, $insertAt) + $importLine + "`r`n" + $content.Substring($insertAt)
        } else {
            $content = $importLine + "`r`n" + $content
        }
    }

    if ($content -ne $original) {
        Set-Content -Path $file -Value $content -NoNewline
        $touchedFiles++
        $totalReplacements += $fileReplacements
        Write-Host "  + $($_.Name): $fileReplacements replacement(s)"
    }
}

Write-Host ""
Write-Host "Done. Touched $touchedFiles files, $totalReplacements total replacements."
