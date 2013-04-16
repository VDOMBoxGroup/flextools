echo off

rem Set next params value:
set sdk3_6_folder="C:/Program Files (x86)/Adobe/Adobe Flash Builder 4.6/sdks/3.6.0"
set sdk4_1_folder="C:/Program Files (x86)/Adobe/Adobe Flash Builder 4.6/sdks/4.1.0"
set pp_root_folder=D:/workspaces/PowerPack/PowerPack
set pp_lib_root_folder=D:/workspaces/PowerPack/PowerPack_lib
set output_exe=D:/upload/BuilderInstaller.exe

rem This params value generates automatically
set swf_compiler=%sdk3_6_folder%/bin/amxmlc.bat
set output_installer_swf_file=%pp_root_folder%/bin-debug/Installer.swf
set output_builder_swf_file=%pp_root_folder%/bin-debug/Builder.swf
set libs=%pp_lib_root_folder%/libs
set pp_lib=%pp_lib_root_folder%/bin/PowerPack_lib.swc
set air_global_4_1=%sdk4_1_folder%/frameworks/libs/air/airglobal.swc
set main_installer_mxml=%pp_root_folder%/src/Installer.mxml
set main_builder_mxml=%pp_root_folder%/src/Builder.mxml

rem build Installer.swf
echo ---------------------- 
echo B U I L D I N G :  Installer.swf
echo ---------------------- 

call %swf_compiler% -output=%output_installer_swf_file% -library-path+=%libs%,%pp_lib% -- %main_installer_mxml%
IF ERRORLEVEL 1 GOTO errBuildingInstaller

rem build Builder.swf
echo ---------------------- 
echo B U I L D I N G :  Builder.swf
echo ---------------------- 

call %swf_compiler% -output=%output_builder_swf_file% -library-path+=%libs%,%pp_lib%,%air_global_4_1% -- %main_builder_mxml%
IF ERRORLEVEL 1 GOTO errBuildingBuilder

rem package BuilderInstaller.exe
echo ---------------------- 
echo P A C K A G I N G :  BuilderInstaller.exe
echo ---------------------- 

rem This params value generates automatically
set package_cmpiler=%sdk4_1_folder%/bin/adt.bat
set sert_path=%pp_root_folder%/src/assets/sert.p12
set builder_config_xml=%pp_root_folder%/bin-debug/Builder-app.xml
set builder_swf_folder=%pp_root_folder%/bin-debug

call %package_cmpiler% -package -storetype pkcs12 -keystore %sert_path% -storepass q -target native -storetype pkcs12 -keystore %sert_path% -storepass q %output_exe% %builder_config_xml% -C %builder_swf_folder% Builder.swf -C %builder_swf_folder% assets -C %builder_swf_folder% Installer.swf
IF ERRORLEVEL 1 GOTO errPackaging

goto end

:errBuildingInstaller
set errorMsg="Erorr when building Installer.swf"
goto showError

:errBuildingBuilder
set errorMsg="Erorr when building Builder.swf"
goto showError

:errPackaging
set errorMsg="Erorr when packaging BuilderInstaller.exe"
goto showError

:showError
echo ---------------------- 
echo E R R O R :  %errorMsg%
echo ---------------------- 
goto end

:end