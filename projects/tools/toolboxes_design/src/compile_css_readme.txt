To use the command line compilation of WysiwygStyle.css (compile_css.bat), please follow these steps:

1. Install Java JRE
   On windows, make sure of installing 32 bits version and NOT 64 bits version !!!

2. Install Flash Builder (Flex) to have the command line compilator (C:\flexSDK\bin\mxmlc.exe)

3. Setup Flex command line compilator by editing C:\flexSDK\bin\jvm.config and setting java.home to the jre path:
   java.home=C:/Program Files (x86)/Java/jre6
   
   Make sure to use only slashes: "/" but NO backslashes: "\" !!!

4. Run compile_css.bat
   As a result, silex_server/plugins/wysiwyg/design/WysiwygStyle.swf file should be updated
   