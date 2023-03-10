$challenge1StartDate = Get-Date "2023-02-14 11:00:00"
$challenge2StartDate = Get-Date "2023-02-16 11:00:00"
$challenge3StartDate = Get-Date "2023-02-20 12:00:00"
$challenge4StartDate = Get-Date "2023-02-23 18:00:00"
$challenge5StartDate = Get-Date "2023-02-25 11:00:00"

# Fetch the HTML content of the website
try{
$url = "https://ctf.cyberdrain.com/showdownscore"
$html = Invoke-WebRequest $url
} catch {
write-host "Unable to fetch data from website. Have you checked the URL?" -ForegroundColor Red
break
}

# Find the table element in the HTML
$table = $html.ParsedHtml.getElementsByTagName("table") | Select-Object -First 1


# Get the table rows and convert them to an array of custom objects
$csv = $table.Rows | Select-Object -Skip 1 | ForEach-Object {
    $details = $_.Cells[2].InnerText
    $challenge1 = if ($details -match "Challenge 1: (\S+)") { [datetime]::ParseExact($Matches[1], "yyyy-MM-ddTHH:mm:ss", $null) } else { $null }
    $challenge2 = if ($details -match "Challenge 2: (\S+)") { [datetime]::ParseExact($Matches[1], "yyyy-MM-ddTHH:mm:ss", $null) } else { $null }
    $challenge3 = if ($details -match "Challenge 3: (\S+)") { [datetime]::ParseExact($Matches[1], "yyyy-MM-ddTHH:mm:ss", $null) } else { $null }
    $challenge4 = if ($details -match "Challenge 4: (\S+)") { [datetime]::ParseExact($Matches[1], "yyyy-MM-ddTHH:mm:ss", $null) } else { $null }
    $challenge5 = if ($details -match "Challenge 5: (\S+)") { [datetime]::ParseExact($Matches[1], "yyyy-MM-ddTHH:mm:ss", $null) } else { $null }

    $challenge1TimeTaken = if ($challenge1) { (New-TimeSpan $challenge1StartDate $challenge1) } else { New-TimeSpan }
    $challenge2TimeTaken = if ($challenge2) { (New-TimeSpan $challenge2StartDate $challenge2) } else { New-TimeSpan }
    $challenge3TimeTaken = if ($challenge3) { (New-TimeSpan $challenge3StartDate $challenge3) } else { New-TimeSpan }
    $challenge4TimeTaken = if ($challenge4) { (New-TimeSpan $challenge4StartDate $challenge4) } else { New-TimeSpan }
    $challenge5TimeTaken = if ($challenge5) { (New-TimeSpan $challenge5StartDate $challenge5) } else { New-TimeSpan }

    [PSCustomObject]@{
        Team = $_.Cells[0].InnerText
        Score = $_.Cells[1].InnerText
        "Challenge 1" = if ($challenge1) { $challenge1TimeTaken.ToString() } else { "" }
        "Challenge 2" = if ($challenge2) { $challenge2TimeTaken.ToString() } else { "" }
        "Challenge 3" = if ($challenge3) { $challenge3TimeTaken.ToString() } else { "" }
        "Challenge 4" = if ($challenge4) { $challenge4TimeTaken.ToString() } else { "" }
        "Challenge 5" = if ($challenge5) { $challenge5TimeTaken.ToString() } else { "" }
        "Total Time" = ($challenge1TimeTaken + $challenge2TimeTaken + $challenge3TimeTaken + $challenge4TimeTaken + $challenge5TimeTaken).ToString()
    }
}

$csv | Where-Object { $_.score -gt 0 } | Sort-Object -Property @{Expression='Score';Descending=$true},@{Expression='Total Time';Descending=$false} | Format-Table -AutoSize

$firstPlaceTeam = ($csv | Where-Object { $_.score -gt 0 } | Sort-Object -Property @{Expression='Score';Descending=$true},@{Expression='Total Time';Descending=$false} | Select-Object -First 1).Team
Write-Host "The team in first place is $firstPlaceTeam" -ForegroundColor Red
$SecondPlaceTeam = ($csv | Where-Object { $_.score -gt 0 } | Sort-Object -Property @{Expression='Score';Descending=$true},@{Expression='Total Time';Descending=$false} | Select-Object -skip 1 -First 1).Team
Write-Host "The team in second place is $SecondPlaceTeam" -ForegroundColor Green
$ThirdPlaceTeam = ($csv | Where-Object { $_.score -gt 0 } | Sort-Object -Property @{Expression='Score';Descending=$true},@{Expression='Total Time';Descending=$false} | Select-Object -skip 2 -First 1).Team
Write-Host "The team in third place is $ThirdPlaceTeam" -ForegroundColor Yellow
