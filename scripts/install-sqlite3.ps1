$zip_name = 'sqlite-amalgamation-3420000.zip'
$url = 'https://www.sqlite.org/2023/sqlite-dll-win64-x64-3420000.zip'
$destination = "$HOME/Documents/sqlite-dll-win64-x64-3400200"

# Download the file using Invoke-WebRequest
Invoke-WebRequest -Uri $url -Outfile $zip_name

mkdir -p $destination
# Extract the downloaded archive (assuming it's a ZIP file)
Expand-Archive $zip_name -DestinationPath $destination
Remove-Item $zip_name

return 0
