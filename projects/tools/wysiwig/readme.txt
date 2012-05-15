HOW TO GENERATE THE ASDOC FOR THE WYSIWYG IN FLEX (Flash builder)

. In flex, open the External Tool Configuration Panel : Run > External Tools > External Tools Configuration
. Add a new launch configuration, name it (ex: AsDoc_Wysiwyg)
. In the "Location" input, enter the location of AsDoc.exe. It will most likely be in your flex sdk folder in bin\asdoc.exe
. In the "Working directory"input enter the root of your folders. This exemple assumes that your root is the silex trunk, so we use
the environnement variable "${workspace_loc}"
. paste the following code in the "Arguments" input : 

-source-path
projects\tools\wysiwig\src
projects\tools\wysiwig\propertyPlugin\src
projects\tools\wysiwig\ToolBoxAPI\src
projects\tools\wysiwig\propertyEditorPlugin\src
projects\tools\ViewMenu\src
framework\as3\


-doc-sources
projects\tools\wysiwig\src\.
projects\tools\wysiwig\propertyPlugin\src\.
projects\tools\ViewMenu\src\.
projects\tools\wysiwig\propertyEditorPlugin\src\.
projects\tools\wysiwig\ToolBoxAPI\src\.
projects\tools\ViewMenu\src\.
framework\as3\.


-warnings=false
-output C:\wamp\www\silex_trunk\projects\tools\wysiwig\asdoc\

.Replace the -output argument with your own output folder
. Click "Apply" then "Run". If there is no error in your comment, the doc will be generated, elseerrors will appear in the flex console.