package net.vdombox.powerpack.sdkcompiler
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;

	public class SDKCompilerParamsChecker extends EventDispatcher
	{
		private static const SDK_4_1_VERSION	: String = "4.1.0";
		
		private var fileStream : FileStream = new FileStream();
		
		public function SDKCompilerParamsChecker()
		{
		}
		
		public function isSDKPathValid(sdkFolderPath : String) : Boolean
		{
			if ( !sdkFolderPath)
				return false;
			
			try
			{
				var sdkFolder : File = new File(sdkFolderPath);
			}
			catch (e:Error)
			{
				return false;
			}
			
			if (!sdkFolderExists(sdkFolder))
				return false;
			
			var sdkDescriptionFile : File = sdkFolder.resolvePath("flex-sdk-description.xml");
			
			return  sdkDescriptionFileExists(sdkDescriptionFile) &&
					sdkDescriptionFileIsValid(sdkDescriptionFile);
				
		}
		
		private function sdkFolderExists(sdkFolder : File) : Boolean
		{
			return sdkFolder && sdkFolder.exists && sdkFolder.isDirectory;
		}
		
		private function sdkDescriptionFileExists(sdkDescriptionFile : File) : Boolean
		{
			if (!sdkDescriptionFile || !sdkDescriptionFile.exists)
				return false;
			
			if( sdkDescriptionFile.isDirectory)
				return false;
			
			if( sdkDescriptionFile.extension.toLowerCase() != "xml")
				return false;
			
			return true;
		}
		
		private function sdkDescriptionFileIsValid(sdkDescriptionFile : File) : Boolean
		{
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
			
			return sdkVersionIsValid(sdkDescriptionXML);
		}
		
		private function sdkVersionIsValid(sdkDescriptionXML : XML) : Boolean
		{
			var sdkVersion : String = sdkDescriptionXML.version[0]; 
			
			return sdkVersion == SDK_4_1_VERSION;
		}
		
		public function isAppPathValid(appPath : String) : Boolean
		{
			if ( appPath == "")
				return true;
			
			try
			{
				var file : File = new File(appPath);
			}
			catch (e:Error)
			{
				return false;
			}
			
			return selectedApplicationExist(file) && selectedApplicationValid(file);
		}
		
		private function selectedApplicationExist( file : File):Boolean
		{
			if ( !file || !file.exists )
				return false;
			
			if( file.isDirectory)
				return false;
			
			if( file.extension.toLowerCase() != "xml")
				return false;
			
			return true;		
		}
		
		private function selectedApplicationValid(file : File):Boolean
		{
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
		
		
	}
}