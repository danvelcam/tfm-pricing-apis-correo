# ============================================================================
# Sondeo empirico v2 - limites de destinatarios y bulk de Postmark
#
# Token de pruebas POSTMARK_API_TEST: valida pero NO envia ni gasta cuota.
# v2: extrae el cuerpo del error (ErrorCode + Message reales) leyendo el
# stream de la respuesta, acota el tope conjunto con biseccion (50 vs 51
# repartidos entre campos) y sondea /email/bulk (Q6/Q8).
#
# Uso:  powershell -ExecutionPolicy Bypass -File .\probe_q2_v2.ps1
# ============================================================================
$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$H = @{ "Accept" = "application/json"; "X-Postmark-Server-Token" = "POSTMARK_API_TEST" }

function Addrs($n, $p) { (1..$n | ForEach-Object { "$p$_@example.com" }) -join "," }

function Call($name, $uri, $json) {
    try {
        $r = Invoke-RestMethod -Uri $uri -Method Post -Headers $H -ContentType "application/json" -Body $json
        $out = [pscustomobject]@{ test = $name; http = 200; ErrorCode = $r.ErrorCode; Message = $r.Message }
    } catch {
        $code = -1; $ec = $null; $msg = $_.Exception.Message
        try { $code = [int]$_.Exception.Response.StatusCode.value__ } catch {}
        $raw = $null
        if ($_.ErrorDetails -and $_.ErrorDetails.Message) { $raw = $_.ErrorDetails.Message }
        if (-not $raw) {
            try {
                $stream = $_.Exception.Response.GetResponseStream()
                $sr = New-Object System.IO.StreamReader($stream)
                $raw = $sr.ReadToEnd(); $sr.Close()
            } catch {}
        }
        if ($raw) { try { $b = $raw | ConvertFrom-Json; $ec = $b.ErrorCode; $msg = $b.Message } catch { $msg = $raw } }
        $out = [pscustomobject]@{ test = $name; http = $code; ErrorCode = $ec; Message = $msg }
    }
    Start-Sleep -Seconds 2
    return $out
}

function ProbeEmail($name, $body) {
    Call $name "https://api.postmarkapp.com/email" ($body | ConvertTo-Json -Depth 4)
}

$base = @{ From = "sender@example.com"; Subject = "TFM capacity probe (test token)";
           TextBody = "probe"; MessageStream = "outbound" }

$res = @()
# --- Tope por campo y tope conjunto (biseccion) ---
$res += ProbeEmail "A_51_To"              ($base + @{ To = Addrs 51 "a" })
$res += ProbeEmail "B_50_To"              ($base + @{ To = Addrs 50 "b" })
$res += ProbeEmail "C_25To_25Cc  (50 tot)" ($base + @{ To = Addrs 25 "c"; Cc = Addrs 25 "d" })
$res += ProbeEmail "D_26To_25Cc  (51 tot)" ($base + @{ To = Addrs 26 "e"; Cc = Addrs 25 "f" })
$res += ProbeEmail "E_50To_1Cc   (51 tot)" ($base + @{ To = Addrs 50 "g"; Cc = Addrs 1 "h" })
$res += ProbeEmail "F_50_50_50  (150 tot)" ($base + @{ To = Addrs 50 "i"; Cc = Addrs 50 "j"; Bcc = Addrs 50 "k" })

# --- Bulk (Q6/Q8): 600 mensajes > al tope de 500 del batch ---
$msgs = @(); 1..600 | ForEach-Object { $msgs += @{ To = "bulk$_@example.com" } }
$bulk = @{ From = "sender@example.com"; Subject = "TFM bulk probe"; TextBody = "probe"; Messages = $msgs }
$res += Call "G_bulk_600_msgs" "https://api.postmarkapp.com/email/bulk" ($bulk | ConvertTo-Json -Depth 6)

""
$res | Format-Table -Wrap -AutoSize
$res | ConvertTo-Json -Depth 4 | Out-File -Encoding utf8 (Join-Path $PSScriptRoot "probe_q2_v2_resultado.json")
""
Write-Host ("Guardado: " + (Join-Path $PSScriptRoot "probe_q2_v2_resultado.json") + " - pegame la tabla completa en el chat.")
