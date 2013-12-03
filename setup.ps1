function _cmd($command) {
  $result = cmd.exe /c "$command 2>&1" #stderr hack  
  return $result
}

function Install-NeededFor {
param([string] $packageName = '', [bool] $defaultAnswer = $true)
    if ($packageName -eq '') {return $false}
    
    $yes = '6'
    $no = '7'
    $msgBoxTimout='-1'
    $defaultAnswerDisplay = 'Yes'
    $buttonType = 0x4;
    if (!$defaultAnswer) {$defaultAnswerDisplay = 'No'; $buttonType= 0x104;}
    
    $answer = $msgBoxTimeout
    try {
        $timeout = 10
        $question = "Do you need to install $($packageName)? Defaults to `'$defaultAnswerDisplay`' after $timeout seconds"
        $msgBox = New-Object -ComObject WScript.Shell
        $answer = $msgBox.Popup($question, $timeout, "Install $packageName", $buttonType)
    }
    catch {
    }
    
    if ($answer -eq $yes -or ($answer -eq $msgBoxTimeout -and $defaultAnswer -eq $true)) {
        write-host "Installing $packageName"
        return $true
    }
    
    write-host "Not installing $packageName"
    return $false
}

function is64Bit
{
    if ([System.IntPtr]::Size -eq 8)
    {
        return $true
    }
    else
    {
        return $false
    }
}

foreach($app in $installs.GetEnumerator())
{
    if ($which_installs -notcontains $app.Name)
    {
        if (Install-NeededFor $app.Name)
        {
            $which_installs += $app.Name
        }
    }
}

$progFiles86 = $env:ProgramFiles
if (is64Bit)
{
    $progFiles86 = ${env:ProgramFiles(x86)}
}

$install_choc = Install-NeededFor 'chocolatey'

#install choclate;
if ($install_choc) {
    iex ((new-object net.webclient).DownloadString('http://chocolatey.org/install.ps1'))
}

$installs = @{"nuget.commandline" = $true; "vim" = $false; "git" = $false}

# default is cinst
$package_command = @{"otherThing" = "boom"}
$which_packages = @{"vim" = @("vim", "ctags"); "git" = @("poshgit", "gitextensions", "git-credential-winstore", "githubforwindows")}

function Install-Thing {
    param([string] $thing = '')
    if ($thing -eq '') {return $false}
    
    if ($which_packages.ContainsKey($thing))
    {
        $packages = $which_packages.Get_Item($thing)
    }
    else
    {
        $packages = @($thing)
    }
    
    foreach($package in $packages)
    {
        if ($package_command.ContainsKey($package))
        {
            $command = $package_command.Get_Item($package)
        }
        else
        {
            $command = "cinst"
        }
        
        & $command $package
    }
    
}

foreach($entry in $installs.GetEnumerator())
{
    if (-Not ($entry.Value))
    {
        $entry.Value = Install-NeededFor $entry.Name
    }
}

foreach($entry in $installs.GetEnumerator())
{
    $app = $entry.Name
    if ($entry.Value)
    {
        Install-Thing $app
    }
}

# install nuget, ruby.devkit, and ruby if they are missing

$hg = $false
if (Install-NeededFor 'mecurial') {
    $hg = $true
    cinstm Posh-GIT-HG
}
else {
    cinstm Posh-GIT
}

if (Install-NeededFor 'dropbox') {
    cinstm dropbox
}

if (Install-NeededFor 'skydrive') {
    cinstm SkyDrive
}

if (Install-NeededFor 'emacs') {
    cinstm Emacs
}

if (Install-NeededFor 'InteliJ') {
    cinst IntelliJIDEA
}

if (-Not (Test-Path(Join-Path $progFiles86 "Terminals")))
{
    "Installing Terminals"
    _cmd "C:\Windows\System32\msiexec.exe /qb /i ""SetupTerminals_v2.0.msi"""
    Copy-Item Terminals.config $progFiles86\Terminals
    Copy-Item Credentials.xml $progFiles86\Terminals
}

cinstm ruby.devkit

#perform ruby updates and get gems
_cmd "C:\ruby193\bin\gem update --system"
cgem rake
cgem bundler
cgem win32console
cgem colorize
cgem mustache

cinstm virtualbox
cinstm Firefox
cinstm GoogleChrome.Dev

cinstm python
#cinstm easy.install             # issue here
#cinstm pip                      # issue here
cinstm vlc
cinstm sysinternals
cinstm gitextensions
cinstm kdiff3
cinstm GnuWin
cinstm tortoisesvn
cinstm svn
cinstm notepadplusplus
cinstm 7zip
cinstm 7zip.commandline
cinstm fiddler
cinstm putty
cinstm windirstat
cinstm curl
cinstm skype
cinstm wget
cinstm FoxitReader
cinst SourceCodePro
cinst EthanBrown.ConEmuConfig

#Get-Content conEmu.reg | Foreach-Object{$_ -replace "PROGFILES", "$progFiles86"} | Set-Content 'conEmu2.reg'
#reg Import conEmu2.reg
#"c:\program files\conemu.exe /UpdateJumpList"
#Remove-Item conEmu2.reg

cinstm linqpad4
cinstm ilmerge
cinstm dotPeek
cinstm kaxaml
cinstm msbuild.communitytasks
#cinstm Silverlight
#cinstm Silverlight5SDK
cinstm specflow


#cinst MVC3 -source webpi
#cinst MVC3Loc -source webpi
#cinst MVC4 -source webpi
Write-Host "Finished checking for/installing Visual Studio Items."

cinst SQLManagementStudio -source webpi

if (Install-NeededFor 'IIS' $false) {
  cinst ASPNET -source webpi
  cinst ASPNET_REGIIS -source webpi
  cinst DefaultDocument -source webpi
  cinst DynamicContentCompression -source webpi
  cinst HTTPRedirection -source webpi
  cinst IIS7_ExtensionLessURLs -source webpi
  cinst IISExpress -source webpi
  cinst IISExpress_7_5 -source webpi
  cinst IISManagementConsole -source webpi
  cinst ISAPIExtensions -source webpi
  cinst ISAPIFilters -source webpi
  cinst NETExtensibility -source webpi
  cinst RequestFiltering -source webpi
  cinst StaticContent -source webpi
  cinst StaticContentCompression -source webpi
  cinst UrlRewrite2 -source webpi
  cinst WindowsAuthentication -source webpi
}