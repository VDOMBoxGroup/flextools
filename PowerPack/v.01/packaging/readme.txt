Packaging Power Pack Builder:

1) build Installer.swf (flex sdk AMXMLC command)
2) build Builder.swf (flex sdk AMXMLC command)
3) package installer (flex sdk ADT command)

For Linux there are some adds:
1) step 3 executes using air sdk 4.1 for Linux.
2) for linux package PPBuilder in .deb and .rpm formats.
3) after you you packaged PPBuilder you should:
	1. depackage .deb
	2. set executable rights for binary PPB file and debial control files
	3. repackage .deb with new (executable) files
	
	
How to use scripts:
1) open script
2) set params (path to sdk, output folder etc.)
3) execute scritp