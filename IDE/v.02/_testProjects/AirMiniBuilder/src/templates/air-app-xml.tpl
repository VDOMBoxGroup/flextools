<?xml version="1.0" encoding="utf-8" standalone="no"?>
<application xmlns="http://ns.adobe.com/air/application/1.5">


<!-- Adobe AIR Application Descriptor File Template.

	Specifies parameters for identifying, installing, and launching AIR applications.
	See http://www.adobe.com/go/air_1.0_application_descriptor for complete documentation.

	xmlns - The Adobe AIR namespace: http://ns.adobe.com/air/application/1.0
			The last segment of the namespace specifies the version 
			of the AIR runtime required for this application to run.
			
	minimumPatchLevel - The minimum patch level of the AIR runtime required to run 
			the application. Optional.
-->

	<!-- The application identifier string, unique to this application. Required. -->
	<id>${APP_NAME}</id>

	<!-- Used as the filename for the application. Required. -->
	<filename>${APP_NAME}</filename>

	<!-- The name that is displayed in the AIR application installer. Optional. -->
	<name>${APP_NAME}</name>

	<!-- An application version designator (such as "v1", "2.5", or "Alpha 1"). Required. -->
	<version>1.0</version>

	<!-- Description, displayed in the AIR application installer. Optional. -->
	<!-- <description></description> -->

	<!-- Copyright information. Optional -->
	<!-- <copyright></copyright> -->

	<!-- Settings for the application's initial window. Required. -->
	<initialWindow>
		<!-- The main SWF or HTML file of the application. Required. -->
		<!-- Note: In Flex Builder, the SWF reference is set automatically. -->
		<content>${APP_NAME}.swf</content>
		
		<!-- The title of the main window. Optional. -->
		<title>${APP_NAME}</title>

		<!-- The type of system chrome to use (either "standard" or "none"). Optional. Default standard. -->
		<!-- <systemChrome></systemChrome> -->

		<!-- Whether the window is transparent. Only applicable when systemChrome is false. Optional. Default false. -->
		<!-- <transparent></transparent> -->

		<!-- Whether the window is initially visible. Optional. Default false. -->
		<visible>true</visible>

		<!-- Whether the user can minimize the window. Optional. Default true. -->
		<!-- <minimizable></minimizable> -->

		<!-- Whether the user can maximize the window. Optional. Default true. -->
		<!-- <maximizable></maximizable> -->

		<!-- Whether the user can resize the window. Optional. Default true. -->
		<!-- <resizable></resizable> -->


		<height>550</height>
		<width>570</width>

		<!-- The window's initial x position. Optional. -->
		<!-- <x></x> -->

		<!-- The window's initial y position. Optional. -->
		<!-- <y></y> -->

		<!-- The window's minimum size, specified as a width/height pair, such as "400 200". Optional. -->
		<!-- <minSize></minSize> -->

		<!-- The window's initial maximum size, specified as a width/height pair, such as "1600 1200". Optional. -->
		<!-- <maxSize></maxSize> -->
	</initialWindow>

	<!-- The subpath of the standard default installation location to use. Optional. -->
	<!-- <installFolder></installFolder> -->

	<!-- The subpath of the Windows Start/Programs menu to use. Optional. -->
	<!-- <programMenuFolder></programMenuFolder> -->

	<!-- The icon the system uses for the application. For at least one resolution,
		 specify the path to a PNG file included in the AIR package. Optional. -->
	<!-- <icon>
		<image16x16></image16x16>
		<image32x32></image32x32>
		<image48x48></image48x48>
		<image128x128></image128x128>
	</icon> -->

	<!-- Whether the application handles the update when a user double-clicks an update version
	of the AIR file (true), or the default AIR application installer handles the update (false).
	Optional. Default false. -->
	<!-- <customUpdateUI></customUpdateUI> -->
	
	<!-- Whether the application can be launched when the user clicks a link in a web browser.
	Optional. Default false. -->
	<!-- <allowBrowserInvocation>true</allowBrowserInvocation> -->

	<!--
	<fileTypes>
		<fileType>
			<name>MinibuilderProject</name>
			<extension>actionScriptProperties</extension>
			<description>Minibuilder ActionScript Project</description>
			<contentType>application/xml</contentType>
			<icon>
				<image16x16></image16x16>
				<image32x32></image32x32>
				<image48x48></image48x48>
				<image128x128></image128x128>
			</icon>
		</fileType>
	</fileTypes>
	-->

</application>
