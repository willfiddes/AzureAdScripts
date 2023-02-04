#
# Module manifest for module 'Azure AD Support Manifest'
#
# Generated by: William Fiddes
#
# Generated on: 2/24/2022
#

@{

# Script module or binary module file associated with this manifest
RootModule = '.\AadToolkitCmdlets.psm1'

# Version number of this module.
ModuleVersion = '0.5.0'

# ID used to uniquely identify this module
GUID = 'ca2a2c86-1fc3-4a80-84ac-1af54192c12d'

# Author of this module
Author = 'William Fiddes'

# Company or vendor of this module
CompanyName = 'William Fiddes'

# Copyright statement for this module
Copyright = '(c) 2022 William Fiddes'

# Description of the functionality provided by this module
Description = 'PowerShell module for Azure AD support.'

# Minimum version of the Windows PowerShell engine required by this module
# PowerShellVersion = ''

# Name of the Windows PowerShell host required by this module
# PowerShellHostName = ''

# Minimum version of the Windows PowerShell host required by this module
# PowerShellHostVersion = ''

# Minimum version of the .NET Framework required by this module
# DotNetFrameworkVersion = ''

# Minimum version of the common language runtime (CLR) required by this module
# CLRVersion = ''

# Processor architecture (None, X86, Amd64) required by this module
# ProcessorArchitecture = ''

# Modules that must be imported into the global environment prior to importing this module
# RequiredModules = @()

# Assemblies that must be loaded prior to importing this module
# RequiredAssemblies = @()

# Script files (.ps1) that are run in the caller's environment prior to importing this module
ScriptsToProcess = @("_startup.ps1")

# Type files (.ps1xml) to be loaded when importing this module
# TypesToProcess = @()

# Format files (.ps1xml) to be loaded when importing this module
# FormatsToProcess = @()

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
NestedModules = @()

# Functions to export from this module
FunctionsToExport = '*-Aad*'

# Cmdlets to export from this module
CmdletsToExport = '*-Aad*'

# Variables to export from this module
VariablesToExport = ''

# Aliases to export from this module
AliasesToExport = '*-Aad*'

# List of all modules packaged with this module
# ModuleList = @()

# List of all files packaged with this module
FileList = @()

# Private data to pass to the module specified in RootModule/ModuleToProcess
# PrivateData = ''

# HelpInfo URI of this module
HelpInfoURI = 'https://github.com/ms-willfid/aad-support-psh-module'

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''

}