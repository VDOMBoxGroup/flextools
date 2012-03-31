#!/bin/sh

# Set parrams:
deb_source_file=/home/oska/package_builder/output/BuilderInstaller.deb
deb_depackage_folder=/home/oska/package_builder/output/depackaged

binary_file_path=$deb_depackage_folder"/opt/VDOM/Power Pack Builder v.1.2.5.8110/bin/Power Pack Builder v.1.2.5.8110"

deb_target_file=/home/oska/package_builder/output/BuilderInstaller1.deb
# -----------------------

if [ -e $deb_depackage_folder ]
then
	echo REMOVE DIR
	chmod 0777 $deb_depackage_folder -R
	rm $deb_depackage_folder -R
	mkdir -m 0777 $deb_depackage_folder
fi

# unpack deb
dpkg -x $deb_source_file $deb_depackage_folder || { showError "Error when unpack .deb"; }

# unpack control information
dpkg -e $deb_source_file $deb_depackage_folder/DEBIAN || { showError "Error when unpack control information"; }

# change binary file rights
chmod a+x "$binary_file_path" || { showError "Error when change binary file rights"; }

# change DEBIAN files rights
chmod a+x $deb_depackage_folder/DEBIAN -R || { showError "Error when change DEBIAN files rights"; }

# package Power Pack Builder deb installer
dpkg -b $deb_depackage_folder $deb_target_file || { showError "Error when package Power Pack Builder deb installer"; }

showError()
{
echo ---------------------- 
echo E R R O R :  $1;
echo ---------------------- 

exit 1;
}

