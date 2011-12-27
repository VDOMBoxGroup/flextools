package net.vdombox.powerpack.sdkcompiler
{
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.system.Capabilities;
	
	import net.vdombox.powerpack.lib.extendedapi.utils.FileUtils;
	import net.vdombox.powerpack.lib.extendedapi.utils.Utils;

	public class SDKCompiler extends EventDispatcher
	{
		private var process : NativeProcess;

		private var paramsChecker	: SDKCompilerParamsChecker = new SDKCompilerParamsChecker();;
		
		private var powerPackProjectPath	: String;
		private var powerPackLibProjectPath	: String;
		
		private var sdk3_6DescriptionXMLPath	: String;
		private var sdk4_1DescriptionXMLPath	: String;
		
		private static const COMPILER_TYPE_SWF		: String = "swfCompiler";
		private static const COMPILER_TYPE_PACKAGE	: String = "packageCompiler";
		
		private var compilerType : String;
		
		
		public function SDKCompiler()
		{
		}
		
		public function build(_sdk3_6DescriptionXMLPath : String, 
							  _sdk4_1DescriptionXMLPath : String, 
							  _powerPackProjectPath : String,
							  _powerPackLibProjectPath : String) : void
		{
			var processEvent : SDKCompilerEvent;
			
			if (!NativeProcess.isSupported)
			{
				sendEvent(SDKCompilerEvent.SDK_COMPILER_ERROR, "Native process is not available");
				return;
			}
			
			sdk3_6DescriptionXMLPath = _sdk3_6DescriptionXMLPath;
			sdk4_1DescriptionXMLPath = _sdk4_1DescriptionXMLPath;
			powerPackProjectPath = _powerPackProjectPath;
			powerPackLibProjectPath = _powerPackLibProjectPath;
			
			paramsChecker.addEventListener(SDKCompilerParamsChecker.PARAMS_OK, onParamsOK);
			paramsChecker.addEventListener(SDKCompilerParamsChecker.PARAMS_ERROR, onParamsError);
			
			paramsChecker.checkParams(sdk3_6DescriptionXMLPath, sdk4_1DescriptionXMLPath, powerPackProjectPath, powerPackLibProjectPath);
			
		}
		
		private function onParamsOK(evt:Event):void
		{
			paramsChecker.removeEventListener(SDKCompilerParamsChecker.PARAMS_OK, onParamsOK);
			paramsChecker.removeEventListener(SDKCompilerParamsChecker.PARAMS_ERROR, onParamsError);
			
			initProcess();
			
			buildSwf();
		}
		
		private function onParamsError(evt:Event):void
		{
			paramsChecker.removeEventListener(SDKCompilerParamsChecker.PARAMS_OK, onParamsOK);
			paramsChecker.removeEventListener(SDKCompilerParamsChecker.PARAMS_ERROR, onParamsError);
			
			sendEvent(SDKCompilerEvent.SDK_COMPILER_ERROR, "Incorrect params");
		}
		
		private function initProcess():void
		{
			process = new NativeProcess();
			
			addProcessListeners();
		}
		
		private function buildSwf() : void
		{
			compilerType = COMPILER_TYPE_SWF;
			
			process.start(processStartupInfo);
		}
		
		private function buildPackage() : void
		{
			compilerType = COMPILER_TYPE_PACKAGE;
			
			process.start(processStartupInfo);
		}
		
		private function get processStartupInfo() : NativeProcessStartupInfo
		{
			var startupInfo	:	NativeProcessStartupInfo    = new NativeProcessStartupInfo();
			
			if (!FileUtils.cmdFile || !FileUtils.cmdFile.exists)
			{
				throw Error("Can't find cmd file");
				return;
			}
			
			startupInfo.arguments	= compilerArguments;
			startupInfo.executable	= FileUtils.cmdFile;
			
			return startupInfo;
		}
		
		private function get sdk3_6Path () : String
		{
			var sdkFolder : File = new File(sdk3_6DescriptionXMLPath).parent;
			
			if (!sdkFolder || !sdkFolder.exists)
				return null;
			
			return sdkFolder.nativePath;
		}
		
		private function get sdk4_1Path () : String
		{
			var sdkFolder : File = new File(sdk4_1DescriptionXMLPath).parent;
			
			if (!sdkFolder || !sdkFolder.exists)
				return null;
			
			return sdkFolder.nativePath;
		}
		
		private function get sertificatePath () : String
		{
			return powerPackProjectPath + "/src/assets/sert.p12";
		}
		
		private function get outputSwfPath () : String
		{
			return powerPackProjectPath + "/bin-debug/Generator.swf";
		}
		
		public function get outputPackagePath () : String
		{
			var outputPath : String;
			
			var os : String = Capabilities.os.substr(0, 3).toUpperCase();
			
			switch(os)
			{
				case FileUtils.OS_MAC:
				{
					outputPath = File.applicationStorageDirectory.nativePath + '/appInstaller.dmg'
					break;
				}
				case FileUtils.OS_LINUX:
				{
					outputPath = File.applicationStorageDirectory.nativePath + '/appInstaller.deb'
					break;
				}
				case FileUtils.OS_WINDOWS:
				default:
				{
					//outputPath = File.applicationStorageDirectory.nativePath + '/appInstaller.exe'
					outputPath = "C:/temp" + '/appInstaller.exe'
					break;
				}
			}
			
			return outputPath;
		}

		private function get compilerArguments() : Vector.<String>
		{
			var argVector : Vector.<String>               = new Vector.<String>();
			var arguments : String;
			
			switch(compilerType)
			{
				case COMPILER_TYPE_SWF:
				{
					arguments = "";
					arguments += "/c ";
					arguments += sdk3_6Path + "/bin/amxmlc.bat"+" "; // D:/upload/3.6.0/bin/amxmlc.bat
					arguments += "-output=" + outputSwfPath + " "; //C:/temp/playerApp.swf

//					 -library-path+=D:/workspaces/workspacePowerPack/PowerPack/v.01/PowerPack/libs,
//									D:/workspaces/workspacePowerPack/PowerPack/v.01/PowerPack_lib/bin/PowerPack_lib.swc,
//									D:/upload/4.1.0/frameworks/libs/air/airglobal.swc : 
					arguments += "-library-path+="
					arguments += powerPackProjectPath + "/libs" + ",";
					arguments += powerPackLibProjectPath + "/bin/PowerPack_lib.swc" + ",";
					arguments += sdk4_1Path + "/frameworks/libs/air/airglobal.swc";
					arguments += " -- ";
					arguments += powerPackProjectPath + "/src/Generator.mxml"; // D:/workspaces/workspacePowerPack/PowerPack/v.01/PowerPack/src/Generator.mxml
						
					break;
				}
				case COMPILER_TYPE_PACKAGE:
				{
					arguments = "";
					arguments += "/c ";
					arguments += sdk4_1Path + "/bin/adt.bat "; //"D:/upload/4.1.0/bin/adt.bat"
					arguments += "-package -storetype pkcs12 -keystore ";
					arguments += sertificatePath + " "; //"D:/workspaces/workspaceMiniBuilder/innerProject/sert.p12"
					arguments += "-storepass q -target native -storetype pkcs12 -keystore ";
					arguments += sertificatePath + " "; //"D:/workspaces/workspaceMiniBuilder/innerProject/sert.p12"
					arguments += "-storepass q ";
					arguments += outputPackagePath + " "; // "c:/temp/myPlayerApp.exe"
					arguments += powerPackProjectPath + "/bin-debug/Generator-app.xml" + " "; //"D:/workspaces/workspacePowerPack/PowerPack/v.01/PowerPack/bin-debug/Generator-app.xml"
					arguments += "-C ";
					arguments += powerPackProjectPath + "/bin-debug" + " "; //"D:/workspaces/workspacePowerPack/PowerPack/v.01/PowerPack/bin-debug"
					arguments += "Generator.swf ";
					arguments += "-C ";
					arguments += powerPackProjectPath + "/bin-debug" + " "; //"D:/workspaces/workspacePowerPack/PowerPack/v.01/PowerPack/bin-debug"
					arguments += "assets";
					
					break;
				}	
				default:
				{
					arguments = "";
					break;
				}
			}
			
			if (arguments)
				argVector.push(arguments);
				
			return argVector;
		}
		
		private function get errorMsg () : String
		{
			return process.standardError ? process.standardError.readUTFBytes(process.standardError.bytesAvailable) : "";
		}

		private function onProcessIOErrorEvent(evt:Event) : void
		{
			trace ("[SDKCompiler] onProcessIOErrorEvent");
		}

		private function onProcessProgressEvent(evt:ProgressEvent) : void
		{
			trace ("[SDKCompiler] onProcessProgressEvent");
			if (evt.type == ProgressEvent.STANDARD_ERROR_DATA)
			{
				sendEvent(SDKCompilerEvent.SDK_COMPILER_ERROR, errorMsg);
				
				removeProcessListeners()

				process.exit(true);

				process = null;
			}
		}

		private function onProcessExitEvent(evt:NativeProcessExitEvent) : void
		{
			trace ("[SDKCompiler] onProcessExitEvent");
			if (evt.type == NativeProcessExitEvent.EXIT)
			{
				if (compilerType == COMPILER_TYPE_SWF)
				{
					buildPackage();
					return;
				}
				
				var exitMessage : String = evt.exitCode == 0 ? "Building process was completed without errors." : "Building process completed with errors.";
				sendEvent(SDKCompilerEvent.SDK_COMPILER_COMPETE, exitMessage);
				
				removeProcessListeners();
				
				process = null;
			}
		}

		private function addProcessListeners() : void
		{
			process.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA,    onProcessProgressEvent);
			process.addEventListener(ProgressEvent.STANDARD_ERROR_DATA,     onProcessProgressEvent);
			
			process.addEventListener(NativeProcessExitEvent.EXIT,           onProcessExitEvent);
			
			process.addEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, onProcessIOErrorEvent);
			process.addEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR,  onProcessIOErrorEvent);
		}

		private function removeProcessListeners() : void
		{
			process.removeEventListener(ProgressEvent.STANDARD_OUTPUT_DATA,    onProcessProgressEvent);
			process.removeEventListener(ProgressEvent.STANDARD_ERROR_DATA,     onProcessProgressEvent);
			
			process.removeEventListener(NativeProcessExitEvent.EXIT,           onProcessExitEvent);
			
			process.removeEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, onProcessIOErrorEvent);
			process.removeEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR,  onProcessIOErrorEvent);
		}
		
		private function sendEvent (eventType : String, msg : String) : void
		{
			var processEvent : SDKCompilerEvent = new SDKCompilerEvent(eventType);
			processEvent.message = msg;
			
			dispatchEvent(processEvent);
		}

	}
}

