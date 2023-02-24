#This was written by https://github.com/rvdwegen/, and original script can be found here: https://github.com/rvdwegen/Powershell/blob/main/Cyberdrain-CTF-Search.ps1

# Single affiliation
$affiliation = "officegrip"; (Invoke-RestMethod -Method 'GET' -Uri "https://ctf.cyberdrain.com/api/v1/users?affiliation=$($affiliation)").data | ForEach-Object { (Invoke-RestMethod -Method 'GET' -Uri "https://ctf.cyberdrain.com/api/v1/users/$($_.id)").data } | Sort-Object -Property score -Descending | ForEach-Object { Write-Host "$($_.name): $($_.place) place with a score of $($_.score)" }

# Multiple affiliations
@("officegrip", "Prime Networks") | ForEach-Object { (Invoke-RestMethod -Method 'GET' -Uri "https://ctf.cyberdrain.com/api/v1/users?affiliation=$($_)").data } | ForEach-Object { (Invoke-RestMethod -Method 'GET' -Uri "https://ctf.cyberdrain.com/api/v1/users/$($_.id)").data } | Sort-Object -Property score -Descending | ForEach-Object { Write-Host "$($_.name) from $($_.affiliation): $($_.place) place with a score of $($_.score)" }

# Multiple affiliations with Out-GridView
@("officegrip", "Prime Networks") | ForEach-Object { (Invoke-RestMethod -Method 'GET' -Uri "https://ctf.cyberdrain.com/api/v1/users?affiliation=$($_)").data } | ForEach-Object { (Invoke-RestMethod -Method 'GET' -Uri "https://ctf.cyberdrain.com/api/v1/users/$($_.id)").data } | Select-Object -Property id, name, affiliation, country, place, score | Sort-Object -Property score -Descending | Out-GridView -Title "Scoreboard"

# Get all affiliated users
$baseUri = "https://ctf.cyberdrain.com/api/v1/users"
$pages = (Invoke-RestMethod -Method 'GET' -Uri $baseUri).meta.pagination.pages
1..$pages | ForEach-Object { (Invoke-RestMethod -Method 'GET' -Uri ($baseUri + "?page=" + $_)).data } | Where-Object { $_.affiliation } | Select-Object affiliation -Unique | ForEach-Object { (Invoke-RestMethod -Method 'GET' -Uri "$($baseUri)?affiliation=$($_.affiliation)").data } | ForEach-Object { (Invoke-RestMethod -Method 'GET' -Uri "$($baseUri)/$($_.id)").data } | Sort-Object -Property score -Descending | ForEach-Object { Write-Host "$($_.name) from $($_.affiliation): $($_.place) place with a score of $($_.score)" }
