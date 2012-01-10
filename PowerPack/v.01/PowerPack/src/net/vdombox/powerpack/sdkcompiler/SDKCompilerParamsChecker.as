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
		public static const PARAMS_OK		: String = "paramsOK";
		public static const PARAMS_ERROR	: String = "paramsError";
		
		private var powerPackProjectPath	: String;
		
		private static const SDK_4_1_VERSION	: String = "4.1.0";
		
		private var fileStream : FileStream = new FileStream();
		
		public function SDKCompilerParamsChecker()
		{
		}
		
		// TODO: need add posible check by 1 param 
		public function checkParams(_sdk4_1Path : String, 
									_powerPackProjectPath : String) : void
		{
			
			powerPackProjectPath = _powerPackProjectPath;
			
			checkSDKPath(_sdk4_1Path + "/flex-sdk-description.xml");
		}
		
		private function onParamsCheckOK():void
		{
			dispatchEvent(new Event(PARAMS_OK));
		}
		
		private function onParamsCheckError():void
		{
			// TODO: need error details
			dispatchEvent(new Event(PARAMS_ERROR));
		}
		
		private function checkSDKPath(descriptionXMLPath : String) : void
		{
			var descriptionFile : File = new File().resolvePath(descriptionXMLPath);
			var sdkDescriptionXML : XML;
			
			if (!descriptionFile || !descriptionFile.exists)
			{
				onParamsCheckError();
				return;
			}
			
			try 
			{
				fileStream.open(descriptionFile, FileMode.READ);
				
				sdkDescriptionXML = XML( fileStream.readUTFBytes( fileStream.bytesAvailable ) );
				
				fileStream.close();
			} 
			catch (e:Error)
			{
				fileStream.close();
				
				onParamsCheckError();
				return;
			}
			
			onSDKChecked();
				
		}
		
		private function onSDKChecked():void
		{		
			checkPowerPackPath();
			//onParamsCheckOK();
		}
		
		private function isCorrectSDK(sdkDescriptionXML : XML) : Boolean
		{
			return true;
			var sdkVersion : String = XMLList(sdkDescriptionXML.version).toString(); 
			
			return sdkVersion == SDK_4_1_VERSION;
		}
		
		private function checkPowerPackPath() : void
		{
			if (correctPowerPackProjectPath)
				onParamsCheckOK();
			else
				onParamsCheckError();
		}
		
		private function get correctPowerPackProjectPath () : Boolean
		{
			var powerPackProjectFolder : File = new File(powerPackProjectPath);
			var powerPackAssetsFolder : File = new File(powerPackProjectPath + "/assets");
			var powerPackInstallerSwfFile : File = new File(powerPackProjectPath + "/Installer.swf");
			
			return powerPackProjectFolder.exists && 
				powerPackAssetsFolder.exists && 
				powerPackInstallerSwfFile.exists;
			
			
		}
		
	}
}