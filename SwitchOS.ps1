$lc=0
$vt=0
$vf=0

if (Test-Path boot8)
{
  $vt = 8
  $vf = 7
}
else
{
  $vt = 7
  $vf = 8
}

$paths = @("support", "sources", "boot", "efi", "bootmgr", "bootmgr.efi", "setup.exe", "autorun.inf")

foreach ($path in $paths) 
{
  Move-Item $path $path$vf
  Move-Item $path$vt $path
}

