function Get-AadToolkitConfig
{
    (Get-Content -Path config.json) | ConvertFrom-Json
}