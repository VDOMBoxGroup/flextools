#!/bin/sh

#Set next params value:
sdk3_6_folder=/home/oska/sdk/3.6.0
sdk4_1_folder=/home/oska/sdk/4.1.0
sdk_air_for_linux_folder=/home/oska/sdk/AdobeAIRSDK_linux
pp_root_folder=/home/oska/svn/PowerPack
pp_lib_root_folder=/home/oska/svn/PowerPack_lib
output_package_folder=/home/oska/package_builder/output
sert_path=/home/oska/package_builder/mySert.p12

# This params value generates automatically:
swf_compiler=$sdk3_6_folder/bin/amxmlc
output_installer_swf_file=$pp_root_folder/bin-debug/Installer.swf
output_builder_swf_file=$pp_root_folder/bin-debug/Builder.swf
libs=$pp_lib_root_folder/libs
pp_lib=$pp_lib_root_folder/bin/PowerPack_lib.swc
air_global_4_1=$sdk4_1_folder/frameworks/libs/air/airglobal.swc
main_installer_mxml=$pp_root_folder/src/Installer.mxml
main_builder_mxml=$pp_root_folder/src/Builder.mxml

buildInstallerSwf()
{
# build Installer.swf
echo ---------------------- 
echo B U I L D I N G :  Installer.swf
echo ---------------------- 

$swf_compiler -output=$output_installer_swf_file -library-path+=$libs,$pp_lib -- $main_installer_mxml || { showError "Error building Installer.swf";}
}

buildBuilderSwf()
{
# build Builder.swf
echo ---------------------- 
echo B U I L D I N G :  Builder.swf
echo ---------------------- 

$swf_compiler -output=$output_builder_swf_file -library-path+=$libs,$pp_lib,$air_global_4_1 -- $main_builder_mxml || { showError "Error building Builder.swf";}
}

packageBuilderInstaller()
{
# packaging BuilderInstaller.deb
echo ---------------------- 
echo P A C K A G I N G :  $1
echo ---------------------- 

# This params value generates automatically
package_cmpiler=$sdk_air_for_linux_folder/bin/adt
builder_config_xml=$pp_root_folder/bin-debug/Builder-app.xml
builder_swf_folder=$pp_root_folder/bin-debug

$package_cmpiler -package -storetype pkcs12 -keystore $sert_path -storepass q -target native $output_package_folder$1 $builder_config_xml -C $builder_swf_folder Builder.swf -C $builder_swf_folder assets -C $builder_swf_folder Installer.swf || { showError "Error packaging BuilderInstaller.deb";}
}


showError()
{
echo ---------------------- 
echo E R R O R :  $1;
echo ---------------------- 

exit 1;
}

#--------------------------------
buildInstallerSwf
buildBuilderSwf
packageBuilderInstaller /BuilderInstaller.deb
packageBuilderInstaller /BuilderInstaller.rpm
#--------------------------------

