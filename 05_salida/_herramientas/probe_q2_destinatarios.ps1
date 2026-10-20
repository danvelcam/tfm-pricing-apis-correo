# ============================================================================
# Sondeo empirico Q2 - limites de destinatarios de Postmark
#
# Usa el token de pruebas documentado POSTMARK_API_TEST: la API VALIDA la
# peticion pero NO envia nada y NO consume cuota. 3 peticiones, 2 s entre
# cada una. Resultado por pantalla y en probe_q2_resultado.json.
#
# Uso (PowerShell):
#   powershell -ExecutionPolicy Bypass -File .\probe_q2_destinatarios.ps1
# ============================================================================
$ErrorActionPreference = "Stop"
$H = @{ "Accept" = "application/json"; "X-Postmark-Server-Token" = "POSTMARK_API_TEST" }

function Addrs($n, $p) { (1..$n | ForEach-Object { "$p$_@example.com" }) -join "," }

function Probe($name, $body) {
    $json = $body | ConvertTo-Json -Depth 4
    try {
        $r = Invoke-RestMethod -Uri "https://api.postmarkapp.com/email" -Method Post `
             -Headers $H -ContentType "application/json" -Body $json
        $out = [pscustomobject]@{ test = $name; http = 200; ErrorCode = $r.ErrorCode; Message = $r.Message }
    } catch {
        $code = -1; $ec = $null; $msg = $_.Exception.Message
        try { $code = [int]$_.Exception.Response.StatusCode.value__ } catch {}
        if ($_.ErrorDetails -and $_.ErrorDetails.Message) {
            try { $b = $_.ErrorDetails.Message | ConvertFrom-Json; $ec = $b.ErrorCode; $msg = $b.Message } catch {}
        }
        $out = [pscustomobject]@{ test = $name; http = $code; ErrorCode = $ec; Message = $msg }
    }
    Start-Sleep -Seconds 2
    return $out
}

$base = @{ From = "sender@example.com"; Subject = "TFM capacity probe (test token)";
           TextBody = "probe"; MessageStream = "outbound" }

$res = @()
$res += Probe "A_51_en_To (esperado: error por campo)" ($base + @{ To = Addrs 51 "a" })
$res += Probe "B_50_en_To (esperado: aceptada)"        ($base + @{ To = Addrs 50 "b" })
$res += Probe "C_50_To+50_Cc+50_Bcc (150 total)"       ($base + @{ To = Addrs 50 "c"; Cc = Addrs 50 "d"; Bcc = Addrs 50 "e" })

""
$res | Format-Table -AutoSize
$res | ConvertTo-Json -Depth 4 | Out-File -Encoding utf8 (Join-Path $PSScriptRoot "probe_q2_resultado.json")
""
Write-Host ("Guardado: " + (Join-Path $PSScriptRoot "probe_q2_resultado.json") + " - pegame la tabla en el chat.")
