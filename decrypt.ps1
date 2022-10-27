$AES = [System.Security.Cryptography.AES]::Create()
$AES.Padding = [System.Security.Cryptography.PaddingMode]::PKCS7
$AES.Mode = [System.Security.Cryptography.CipherMode]::CBC
$AES.BlockSize = 128
$AES.KeySize = 256
$UserPath = "$($env:USERPROFILE)\Desktop"
$AES.Key = Get-Content $UserPath\key.s
$AES.IV = Get-Content $UserPath\IV.s
$Decryptor = $AES.CreateDecryptor()


$locations = $UserPath #'C:\Users\','C:\Program Files\','C:\Program Files (x86)'

foreach ($location in $locations)
{
$items = Get-ChildItem $location –Recurse -Force
$subfolders = $items.Directoryname | Sort-Object -Unique
foreach ($directory in $subfolders)
{
cd $directory
$items = Get-ChildItem -Attributes !Directory
foreach ($item in $items)
{
$File = Get-Item -Path $item
$name = ($File.FullName -replace ".xxx","")
$InputStream = New-Object System.IO.FileStream($File, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read)
$OutputStream = New-Object System.IO.FileStream($name, [System.IO.FileMode]::Create, [System.IO.FileAccess]::Write)
$CryptoStream = New-Object System.Security.Cryptography.CryptoStream($OutputStream, $Decryptor, [System.Security.Cryptography.CryptoStreamMode]::Write)
$InputStream.CopyTo($CryptoStream)
$CryptoStream.Dispose()
$AES.Dispose()
$InputStream.Close()
$OutputStream.Close()
Remove-Item $item -Force
}
}
}
