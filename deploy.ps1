# Sync mutabaah.html ke index.html
Copy-Item mutabaah.html index.html -Force
Write-Host "OK index.html synced"

# Push ke GitHub -> Cloudflare Pages auto-deploy
$msg = "update $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
git add -A
git commit -m $msg
git push origin main

Write-Host ""
Write-Host "OK Push selesai! Cloudflare Pages auto-deploy dalam ~1 menit"
Write-Host "   https://fidin-mutabaah-app.pages.dev"
