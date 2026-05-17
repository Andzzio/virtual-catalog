$f = "d:\proyectos\virtual-catalog\lib\presentation\widgets\checkout\checkout_form_view.dart"
$lines = [System.IO.File]::ReadAllLines($f)
$keep = [System.Collections.Generic.List[string]]::new()
for ($i = 0; $i -lt $lines.Length; $i++) {
    if ($i -ge 941 -and $i -le 1039) { continue }
    $keep.Add($lines[$i])
}
[System.IO.File]::WriteAllLines($f, $keep)
Write-Host "Removed lines 942-1040 (0-indexed 941-1039). New total: $($keep.Count)"
