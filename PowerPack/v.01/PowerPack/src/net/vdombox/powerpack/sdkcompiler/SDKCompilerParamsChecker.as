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
		
		private static const SDK_3_6	: String = "3.6.0";
		private static const SDK_4_1	: String = "4.1.0";
		
		private var currentSdkVersion	: String;
		
		private var powerPackProjectPath	: String;
		private var powerPackLibProjectPath	: String;
		
		private var sdk3_6DescriptionXMLPath	: String;
		private var sdk4_1DescriptionXMLPath	: String;
		
		private var fileStream : FileStream = new FileStream();
		
		public function SDKCompilerParamsChecker()
		{
		}
		
		// TODO: need add posible check by 1 param 
		public function checkParams(_sdk3_6DescriptionXMLPath : String, 
									_sdk4_1DescriptionXMLPath : String, 
									_powerPackProjectPath : String,
									_powerPackLibProjectPath : String) : void
		{
			
			sdk3_6DescriptionXMLPath = _sdk3_6DescriptionXMLPath;
			sdk4_1DescriptionXMLPath = _sdk4_1DescriptionXMLPath;
			powerPackProjectPath = _powerPackProjectPath;
			powerPackLibProjectPath = _powerPackLibProjectPath;
			
			currentSdkVersion = SDK_3_6;
			checkSDKPath(sdk3_6DescriptionXMLPath);
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
			
			// TODO: other way to open file 
			fileStream.addEventListener(Event.COMPLETE, onDescriptionXMLOpenComplete);
			fileStream.addEventListener(IOErrorEvent.IO_ERROR, onDescriptionXMLOpenError);
			fileStream.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onDescriptionXMLOpenError);
			
			fileStream.openAsync(descriptionFile, FileMode.READ);
			
			function onDescriptionXMLOpenComplete (event : Event) : void
			{
				fileStream.removeEventListener(Event.COMPLETE, onDescriptionXMLOpenComplete);
				fileStream.removeEventListener(IOErrorEvent.IO_ERROR, onDescriptionXMLOpenError);
				fileStream.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onDescriptionXMLOpenError);
				
				try 
				{
					sdkDescriptionXML = XML( fileStream.readUTFBytes( fileStream.bytesAvailable ) );
					
					fileStream.close();
				} 
				catch (e:Error)
				{
					fileStream.close();
					
					onParamsCheckError();
					return;
				}
				
				if (!isCorrectSDK(sdkDescriptionXML))
				{
					onParamsCheckError();
					return;
				}
				
				onSDKChecked();
			}
			
			function onDescriptionXMLOpenError (event : Event) : void
			{
				fileStream.removeEventListener(Event.COMPLETE, onDescriptionXMLOpenComplete);
				fileStream.removeEventListener(IOErrorEvent.IO_ERROR, onDescriptionXMLOpenError);
				fileStream.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onDescriptionXMLOpenError);
				
				onParamsCheckError();
			}
				
		}
		
		private function onSDKChecked():void
		{
			
			if (currentSdkVersion == SDK_3_6)
			{
				currentSdkVersion = SDK_4_1;
				checkSDKPath(sdk4_1DescriptionXMLPath);
			}
			else
			{
				checkPowerPackPath();
			}

		}
		
		private function isCorrectSDK(sdkDescriptionXML : XML) : Boolean
		{
			return true;
			var sdkVersion : String = XMLList(sdkDescriptionXML.version).toString(); 
			
			return sdkVersion == currentSdkVersion;
		}
		
		private function checkPowerPackPath() : void
		{
			if (correctPowerPackProjectPath && correctPowerPackLibProjectPath)
				onParamsCheckOK();
			else
				onParamsCheckError();
		}
		
		private function get correctPowerPackProjectPath () : Boolean
		{
			var powerPackProjectFolder : File = new File(powerPackProjectPath);
			var powerPackAssetsFolder : File = new File(powerPackProjectPath + "/src/assets");
			var powerPackLibsFolder : File = new File(powerPackProjectPath + "/libs");
			var powerPackBinFolder : File = new File(powerPackProjectPath + "/bin-debug");
			var powerPackGeneratorFile : File = new File(powerPackProjectPath + "/src/Installer.mxml");
			var powerPackDescriptionXmlFile : File = new File(powerPackProjectPath + "/bin-debug/Installer-app.xml");
			
			return powerPackProjectFolder.exists && 
				powerPackAssetsFolder.exists && 
				powerPackLibsFolder.exists && 
				powerPackBinFolder.exists &&
				powerPackGeneratorFile.exists &&
				powerPackDescriptionXmlFile.exists;
			
			
		}
		
		private function get correctPowerPackLibProjectPath () : Boolean
		{
			var powerPackLibProjectFolder : File = new File(powerPackLibProjectPath);
			var powerPackLibSwcFile : File = new File(powerPackLibProjectPath + "/bin/PowerPack_lib.swc");
			
			return powerPackLibProjectFolder.exists && powerPackLibSwcFile.exists;
		}
		
	}
}