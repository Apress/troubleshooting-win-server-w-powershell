Source Code for Troubleshooting Windows Server with PowerShell

There are chapter PS1 files associated for each chapter.
There are also two script files associated with installed applications,
  CompareInstalledApps.ps1
  Listing Programs thru registry query.ps1
  Those two files were big enough and unique enough to keep seperate.

For the chpaters that we specifically put functions in, we created a module for those chapters.
You can import the module for testing by typing in PowerShell,
Import-Module <PathToParentFolder>\TWSWP_Chapter1
  Note: to import, you just need to call out the folder name that holds the PSD1 and PSM1 files.
  Note: The <PathToParentFolder> should be your path you saved the module folders in.

Please read through the code posted here before running it explicitly. It's great that you trust our code,
but all files from the Internet should be considered untrusted - be safe with your systems is all we are saying.