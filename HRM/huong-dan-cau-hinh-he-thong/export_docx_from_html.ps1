param(
    [string]$HtmlPath = (Join-Path $PSScriptRoot 'Huong-dan-cau-hinh-he-thong-VIN-HRM.html'),
    [string]$DocxPath = (Join-Path $PSScriptRoot 'Huong-dan-cau-hinh-he-thong-VIN-HRM.docx')
)

$ErrorActionPreference = 'Stop'
$word = $null
$doc = $null

try {
    $htmlFull = (Resolve-Path -LiteralPath $HtmlPath).Path
    $docxFull = [System.IO.Path]::GetFullPath($DocxPath)

    $word = New-Object -ComObject Word.Application
    $word.Visible = $false
    $word.DisplayAlerts = 0

    $doc = $word.Documents.Open($htmlFull, $false, $false)

    foreach ($section in $doc.Sections) {
        $section.PageSetup.PageWidth = 612
        $section.PageSetup.PageHeight = 792
        $section.PageSetup.TopMargin = 48.96
        $section.PageSetup.BottomMargin = 50.4
        $section.PageSetup.LeftMargin = 51.84
        $section.PageSetup.RightMargin = 51.84
    }

    try {
        $doc.Background.Fill.ForeColor.RGB = 16777215
    }
    catch {
        # Some Word versions do not expose the HTML background object.
    }

    foreach ($paragraph in $doc.Paragraphs) {
        $paragraph.Format.SpaceAfter = 4
        $paragraph.Format.LineSpacingRule = 0
    }

    $heading1Index = 0
    foreach ($paragraph in $doc.Paragraphs) {
        $text = ($paragraph.Range.Text -replace '[\r\a]', '').Trim()
        if ([string]::IsNullOrWhiteSpace($text)) {
            continue
        }

        $styleName = ''
        try { $styleName = [string]$paragraph.Style.NameLocal } catch { }

        if ($styleName -eq 'Heading 1') {
            $heading1Index++
            if ($heading1Index -eq 2) {
                $paragraph.Format.PageBreakBefore = -1
            }
        }

        if ($styleName -eq 'Heading 1' -and $text -match '^[4-7]\.\s') {
            $paragraph.Format.PageBreakBefore = -1
        }

        if ($styleName -like 'Heading *') {
            $paragraph.Format.KeepWithNext = -1
        }

    }

    # Keep each configuration explanation together so a key is not separated
    # from its meaning, default value, choices, and usage notes.
    $configKeyPattern = '(Scheduling|Attendance|System|Payroll|Chat|OKR|SocialInsurance)\.'
    for ($i = 1; $i -le $doc.Paragraphs.Count; $i++) {
        $paragraph = $doc.Paragraphs.Item($i)
        $text = ($paragraph.Range.Text -replace '[\r\a]', '').Trim()
        $styleName = ''
        try { $styleName = [string]$paragraph.Style.NameLocal } catch { }

        if ($text -notmatch $configKeyPattern) {
            continue
        }

        $cardParagraphs = New-Object System.Collections.Generic.List[int]
        [void]$cardParagraphs.Add($i)
        for ($j = $i + 1; $j -le $doc.Paragraphs.Count; $j++) {
            $nextParagraph = $doc.Paragraphs.Item($j)
            $nextText = ($nextParagraph.Range.Text -replace '[\r\a]', '').Trim()
            $nextStyleName = ''
            try { $nextStyleName = [string]$nextParagraph.Style.NameLocal } catch { }

            if ([string]::IsNullOrWhiteSpace($nextText) -or
                $nextStyleName -like 'Heading *' -or
                $nextText -match $configKeyPattern) {
                break
            }

            [void]$cardParagraphs.Add($j)
            if ($cardParagraphs.Count -ge 8) {
                break
            }
        }

        for ($k = 0; $k -lt $cardParagraphs.Count; $k++) {
            $keepValue = 0
            if ($k -lt ($cardParagraphs.Count - 1)) {
                $keepValue = -1
            }
            $doc.Paragraphs.Item($cardParagraphs[$k]).Format.KeepWithNext = $keepValue
        }
    }

    foreach ($table in $doc.Tables) {
        $table.TopPadding = 3
        $table.BottomPadding = 3
        $table.LeftPadding = 5
        $table.RightPadding = 5
        $table.Range.ParagraphFormat.SpaceAfter = 0

        # Mark only true data-table header rows. One-cell callouts, the cover
        # metadata table, and two-column screenshot layout tables are excluded.
        if (($table.Columns.Count -eq 3 -and $table.Rows.Count -ge 4) -or
            ($table.Columns.Count -eq 2 -and $table.Rows.Count -ge 5)) {
            $table.Rows.Item(1).HeadingFormat = -1
        }

        if ($table.Range.InlineShapes.Count -eq 2) {
            $table.AllowAutoFit = $false
            $table.PreferredWidthType = 3
            $table.PreferredWidth = 468
            $table.TopPadding = 0
            $table.BottomPadding = 0
            $table.LeftPadding = 0
            $table.RightPadding = 0
            if ($table.Columns.Count -eq 2) {
                $table.Columns.Item(1).PreferredWidthType = 3
                $table.Columns.Item(1).PreferredWidth = 234
                $table.Columns.Item(2).PreferredWidthType = 3
                $table.Columns.Item(2).PreferredWidth = 234
            }
            foreach ($row in $table.Rows) {
                $row.AllowBreakAcrossPages = 0
            }
        }
    }

    foreach ($shape in $doc.InlineShapes) {
        try {
            if ($null -ne $shape.LinkFormat) {
                $shape.LinkFormat.SavePictureWithDocument = $true
                $shape.LinkFormat.BreakLink()
            }
        }
        catch {
            # Embedded images do not expose a link to break.
        }

        if ($shape.Width -gt 234) {
            $shape.LockAspectRatio = -1
            $shape.Width = 234
        }
    }

    $doc.SaveAs2($docxFull, 16)
    $doc.Close(0)
    $doc = $null
    $word.Quit()
    $word = $null

    Get-Item -LiteralPath $docxFull | Select-Object FullName, Length, LastWriteTime
}
finally {
    if ($null -ne $doc) {
        try { $doc.Close(0) } catch { }
    }
    if ($null -ne $word) {
        try { $word.Quit() } catch { }
    }
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()
}
