Get-Date -Format "yyyy-MM-dd HH:mm"

git add . | git commit -m "${Get-Date -Format "yyyy-MM-dd HH:mm"}" | git push

echo 

powershell gallery oy2hsnjm3btmzvnw6wxq7yfpit2c34kehgxi473snrl4s4

Publish-Module -Name <moduleName> -NuGetApiKey <apiKey>