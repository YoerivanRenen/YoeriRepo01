$urllijst = Get-Content -Path E:\Powershell\URLSextern.txt
$urls = New-Object System.Collections.Generic.List[System.Object]
Foreach ($url in $urllijst) {
    Write-Host "Bezig met testen van beschikbaarheid $url"
    if(nslookup $url | Where-Object {$_.return -notcontains "Non-existent domain"}) {
        Write-Host "DNS record voor $url gevonden, bezig met testen connectie"
        if (Test-NetConnection -ComputerName $url -Port 443 | Where-Object { $_.TcpTestSucceeded -eq "True" }) {
            Write-Host "HTTPS OK!"
            $urls.Add($url)
        }
        Elseif (Test-NetConnection -ComputerName $url -Port 80 | Where-Object { $_.TcpTestSucceeded -eq "True"} ) {
                Write-Host "HTTP OK!"
                $urls.Add($url)
        }
    }
    Else { Write-Host "$url is niet benaderbaar"}
 }
ForEach ($url in $urls) {
 [hashtable]$ht1 = Invoke-WebRequest -Uri "$url" | Select-Object Headers -ExpandProperty Headers
 $ht2 = $ht1.Clone()
 foreach($k in $ht1.GetEnumerator()){ 
    if([string]$k.Name -notcontains "Strict-Transport-Security"-and [string]$k.Name -notcontains "X-Frame-Options" `
    -and [string]$k.Name -notcontains "X-XSS-Protection" -and [string]$k.Name -notcontains "X-Content-Type-Options" `
    -and [string]$k.Name -notcontains "Referrer-Policy"  ){
    #notice, deleting from clone, then return clone at the end
    $ht2.Remove($k.Key) 
    }   
 }
 Write-Output "Website: $url" | Out-File E:\Powershell\Headerscanneroutput.log -Append
 $ht2 | Out-File E:\Powershell\Headerscanneroutput.log -Append
 Write-Output " " | Out-File E:\Powershell\Headerscanneroutput.log -Append
 } 