# Read client_secrets.env and run flutter with --dart-define
$envFile = "client_secrets.env"
$argsList = @("run")

if (Test-Path $envFile) {
    Get-Content $envFile | Where-Object { $_ -match "^\s*[^#]" } | ForEach-Object {
        $parts = $_.Split('=', 2)
        if ($parts.Length -eq 2) {
            $key = $parts[0].Trim()
            $value = $parts[1].Trim()
            if ($key -and $value) {
                $argsList += "--dart-define=$key=$value"
            }
        }
    }
}

# Pass any additional arguments passed to the script (e.g. -d windows)
if ($args.Length -gt 0) {
    $argsList += $args
}

& flutter @argsList
