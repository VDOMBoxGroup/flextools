package net.vdombox.powerpack.sdkcompiler
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	import net.vdombox.powerpack.lib.extendedapi.utils.FileUtils;

	public class SDKCompilerParamsChecker extends EventDispatcher
	{
		private static const SDK_4_1_VERSION	: String = "4.1.0";
		
		private var fileStream : FileStream = new FileStream();
		
		public function SDKCompilerParamsChecker()
		{
		}
		
		public function isFlexSDK_4_1_PathValid(sdkFolderPath : String) : Boolean
		{
			if ( !sdkFolderPath)
				return false;
			
			if (!FileUtils.filePathExists(sdkFolderPath,true))
				return false;
			
			var sdkFolder : File = FileUtils.getFileByPath(sdkFolderPath);
			if (!sdkFolder)
				return false;
			
			var sdkDescriptionFile : File = sdkFolder.resolvePath("flex-sdk-description.xml");
			
			return  FileUtils.fileExists(sdkDescriptionFile, false) &&
					flexSDK_4_1_DescriptionFileIsValid(sdkDescriptionFile);
				
		}
		
		private function flexSDK_4_1_DescriptionFileIsValid(sdkDescriptionFile : File) : Boolean
		{
			if( !sdkDescriptionFile || sdkDescriptionFile.extension.toLowerCase() != "xml")
				return false;
			
			var sdkDescriptionXML : XML;
			
			try 
			{
				fileStream.open(sdkDescriptionFile, FileMode.READ);
				
				sdkDescriptionXML = XML( fileStream.readUTFBytes( fileStream.bytesAvailable ) );
				
				fileStream.close();
			} 
			catch (e:Error)
			{
				fileStream.close();
				
				return false;
			}
			
			if (sdkDescriptionXML.name() != "flex-sdk-description")
				return false;
			
			return flexSDK_4_1_VersionIsValid(sdkDescriptionXML);
		}
		
		private function flexSDK_4_1_VersionIsValid(sdkDescriptionXML : XML) : Boolean
		{
			var sdkVersion : String = sdkDescriptionXML.version[0]; 
			
			return sdkVersion == SDK_4_1_VERSION;
		}
		
		public function isAppPathValid(appPath : String) : Boolean
		{
			if ( appPath == "")
				return true;
			
			return FileUtils.filePathExists(appPath, false) && selectedApplicationValid(appPath);
		}
		
		private function selectedApplicationValid(appPath : String) : Boolean
		{
			var file : File = FileUtils.getFileByPath(appPath);
			
			if (!file || !FileUtils.isXMLFile(file))
				return false;
			
			var appXml : XML;
			
			try 
			{
				fileStream.open(file, FileMode.READ);
				
				appXml = new XML( fileStream.readUTFBytes( fileStream.bytesAvailable ) );
				
				fileStream.close();
				
				var appId : String = appXml.Information.ID[0];
				
				if (!appId)
					return false;
			}
			catch (e:Error)
			{
				fileStream.close();
				return false;
			}
			
			return true;	
		}
		
		public function isAirSDK_PathValid(airSDKFolderPath : String) : Boolean
		{
			if ( !airSDKFolderPath)
				return false;
			
			if (!FileUtils.filePathExists(airSDKFolderPath,true))
				return false;
			
			var airSDKFolder : File = FileUtils.getFileByPath(airSDKFolderPath);
			if (!airSDKFolder)
				return false;
			
			var airSDKRuntimeLinuxFolder : File = airSDKFolder.resolvePath("runtimes/air/linux");
			
			return  FileUtils.fileExists(airSDKRuntimeLinuxFolder, true);
		}
		
		
	}
}