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

$possible_installs = "tortoisesvn", "AnkhSvn", "vim", "beyondcompare", "git", "dropbox", "SkyDrive", "emacs", "IntelliJ",
              "Terminals", "ConEmu", "Ruby", "RubyMine", "virtualbox", "Firefox", "GoogleChrome.Dev", "PyCharm-community", "vlc", "GnuWin",
              "fiddler4", "skype", "FoxitReader", "ilmerge", "dotPeek", "kaxaml", "SqlManagementStudio"

$installs = "nuget.commandline", "notepadplusplus", "svn", "git-commandline", "Python", "sysinternals", "7zip", "7zip.commandline", "putty", 
            "curl", "wget", "linqpad4", "msbuild.communitytasks", "specflow"

# default is cinst
$package_command = @{"pry" = "gem install"; "win32console" = "gem install"; "colorize" = "gem install"}
$which_packages = @{"vim" = @("vim", "ctags"); "git-commandline" = @("poshgit"); "git" = @("gitextensions", "git-credential-winstore", "githubforwindows", "Devbox-GitSettings"); 
                    "IntelliJ" = @("intellij-idea-community"); "Terminals" = @("Terminals.app"); "ConEmu" = @("EthanBrown.ConEmuConfig");
                    "Ruby" = @("ruby1.9"; "ruby.devkit"; "pry"; "win32console"; "colorize"); "Python" = @("python.x86"); 
                    "SqlManagementStudio" = @("SqlManagementStudio -source webpi")}

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

foreach($app in $possible_installs)
{
    if (Install-NeededFor $app)
    {
        $installs += $app
    }
}

foreach($app in $installs)
{
    Install-Thing $app
}

#wget https://bitbucket.org/pypa/setuptools/raw/bootstrap/ez_setup.py --no-check-certificate
#python ./ez_setup.py
#easy_install pip
#pip install pyodbc