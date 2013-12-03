$packageName = 'alanstevens.vsextensions'

function Get-Batchfile ($file) {
  $cmd = "`"$file`" & set"
    cmd /c $cmd | Foreach-Object {
      $p, $v = $_.split('=')
        Set-Item -path env:$p -value $v
    }
}

function VsVars32()
{
    $BatchFile = join-path $env:VS100COMNTOOLS "vsvars32.bat"
    Get-Batchfile `"$BatchFile`"
}

function curlex($url, $filename) {
  $path = [io.path]::gettemppath() + "\" + $filename

    if( test-path $path ) { rm -force $path }

  (new-object net.webclient).DownloadFile($url, $path)

    return new-object io.fileinfo $path
}

function installsilently($url, $name) {
  echo "Installing $name"

  $extension = (curlex $url $name).FullName

  $result = Start-Process -FilePath "VSIXInstaller.exe" -ArgumentList "/q $extension" -Wait -PassThru;
}

try {

  vsvars32

    installsilently http://visualstudiogallery.msdn.microsoft.com/b31916b0-c026-4c27-9d6b-ba831093f6b2/file/62080/1/Gister.vsix Gister.vsix
    installsilently http://visualstudiogallery.msdn.microsoft.com/c8bccfe2-650c-4b42-bc5c-845e21f96328/file/75539/6/EditorConfigPlugin-0.2.5.vsix EditorConfig.vsix
    installsilently http://visualstudiogallery.msdn.microsoft.com/27077b70-9dad-4c64-adcf-c7cf6bc9970c/file/37502/19/NuGet.Tools.vsix NuGet.vsix
    installsilently http://visualstudiogallery.msdn.microsoft.com/e5f41ad9-4edc-4912-bca3-91147db95b99/file/7088/6/PowerCommands.vsix PowerCommands.vsix
    installsilently http://visualstudiogallery.msdn.microsoft.com/fa85b17d-3df2-49b1-bee6-71527ffef441/file/49766/1/PerfWatsonExtension-Signed.vsix PerfWatson.vsix
    installsilently http://visualstudiogallery.msdn.microsoft.com/63a7e40d-4d71-4fbb-a23b-d262124b8f4c/file/29105/42/GitSccProvider.vsix
    installsilently http://visualstudiogallery.msdn.microsoft.com/7dbae8b3-5812-490e-913e-7bfe17f47f1d/file/29587/13/donmar.devColor.vsix DevColor.vsix
    installsilently http://visualstudiogallery.msdn.microsoft.com/20cd93a2-c435-4d00-a797-499f16402378/file/13848/1/ThemeManagerPackage.vsix ThemeManager.vsix
    installsilently http://visualstudiogallery.msdn.microsoft.com/6ed4c78f-a23e-49ad-b5fd-369af0c2107f/file/50769/31/WebEssentials.vsix WebEssentials.vsix
    installsilently http://visualstudiogallery.msdn.microsoft.com/23d11b45-c2ed-4398-9cb5-48ea67878470/file/77232/3/Twitter%20Bootstrap%20MVC.vsix TwitterBootstrapMvc.vsix
    installsilently http://visualstudiogallery.msdn.microsoft.com/f2ec6478-7fa2-4782-9fc0-e6d9ef8bb3a9/file/79408/4/MvcTwitterBootstrap.vsix MvcTwitterBootstrap.vsix
    installsilently http://visualstudiogallery.msdn.microsoft.com/268d0b05-6ba5-4793-9a10-7d9d2a478881/file/70320/5/MVC4TwitterBootstrapStarterLayoutPage.vsix
    installsilently http://visualstudiogallery.msdn.microsoft.com/2b96d16a-c986-4501-8f97-8008f9db141a/file/53962/24/Mindscape.WebWorkbench.Integration.10.vsix WebWorkbench.vsix
    installsilently http://visualstudiogallery.msdn.microsoft.com/a15c3ce9-f58f-42b7-8668-53f6cdc2cd83/file/52418/2/Web%20Standards%20Update.msi WebStandardsUpdate.msi
    installsilently http://visualstudiogallery.msdn.microsoft.com/d491911d-97f3-4cf6-87b0-6a2882120acf/file/25426/72/DPStudio.VSCommands.vsix
    installsilently http://visualstudiogallery.msdn.microsoft.com/bb424812-f742-41ef-974a-cdac607df921/file/35141/29/Clarius.DBS.vsix
    installsilently http://visualstudiogallery.msdn.microsoft.com/69023d00-a4f9-4a34-a6cd-7e854ba318b5/file/55948/12/SlowCheetah.vsix
    installsilently http://visualstudiogallery.msdn.microsoft.com/9915524d-7fb0-43c3-bb3c-a8a14fbd40ee/file/79327/6/TechTalk.SpecFlow.Vs2010Integration.vsix
    installsilently http://visualstudiogallery.msdn.microsoft.com/60297607-5fd4-4da4-97e1-3715e90c1a23/file/7152/27/tangibleT4EditorPlusModellingToolsVS2010.msi
   

    Write-ChocolateySuccess $packageName
} catch {
  Write-ChocolateyFailure $packageName "$($_.Exception.Message)"
    throw
}
