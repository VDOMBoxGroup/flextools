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
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
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
		
		public function build(sdk3_6DescriptionXMLPath : String, 
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
			
			this.sdk3_6DescriptionXMLPath = sdk3_6DescriptionXMLPath;
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
			
			generateBuildingBatFiles();
		}
		
		private function onParamsError(evt:Event):void
		{
			paramsChecker.removeEventListener(SDKCompilerParamsChecker.PARAMS_OK, onParamsOK);
			paramsChecker.removeEventListener(SDKCompilerParamsChecker.PARAMS_ERROR, onParamsError);
			
			sendEvent(SDKCompilerEvent.SDK_COMPILER_ERROR, "Incorrect params");
		}
		
		private function generateBuildingBatFiles () : void
		{
			var batFileType : String;
			var batFileGenerated : Boolean;
			
			batFileType = "swf";
			
			batFileGenerated = generateBuildingBatFile();
			
			if (batFileGenerated)
			{
				batFileType = "package";
				
				batFileGenerated = generateBuildingBatFile();
				
				if (batFileGenerated)
					onBatFilesGenerated();
			}
			
			function generateBuildingBatFile () : Boolean
			{
				var batFilePath : String = batFileType == "swf" ? swfBatFilePath : packageBatFilePath;
				var batFileContent : String = batFileType == "swf" ? swfBatFileContent : packageBatFileContent;
				
				var fileStream : FileStream = new FileStream();
				var swfBatFile : File = new File(batFilePath);
				
				try
				{
					fileStream.openAsync(swfBatFile, FileMode.WRITE);
					fileStream.writeUTFBytes(batFileContent);
					fileStream.close();
				}
				catch (e:Error)
				{
					sendEvent(SDKCompilerEvent.SDK_COMPILER_ERROR, "Error when creating bat file");
					return false;
				}
				
				return true;
			}
		}
		
		private function get swfBatFilePath () : String
		{
			var batFilePath : String = File.applicationStorageDirectory.nativePath + "/generatePlayerSwf.bat";
			
			return batFilePath;
		}
		
		private function get swfBatFileContent() : String
		{
			var content : String = "";
			
			content += FileUtils.convertPathForCMD(sdk3_6Path + '/bin/amxmlc.bat') + ' ';
			content += '-output=' + FileUtils.convertPathForCMD(outputSwfPath) + ' ';
			content += '-library-path+='
			content += FileUtils.convertPathForCMD(powerPackProjectPath + '/libs') + ',';
			content += FileUtils.convertPathForCMD(powerPackLibProjectPath + '/bin/PowerPack_lib.swc') + ',';
			content += FileUtils.convertPathForCMD(sdk4_1Path + '/frameworks/libs/air/airglobal.swc');
			content += ' -- ';
			content += FileUtils.convertPathForCMD(powerPackProjectPath + '/src/Generator.mxml');
			
			return content;
		}
		
		private function get packageBatFilePath () : String
		{
			var batFilePath : String = File.applicationStorageDirectory.nativePath + "/generatePlayerPackage.bat";
			
			return batFilePath;
		}
		
		private function get packageBatFileContent() : String
		{
			var content : String = "";
			
			content += FileUtils.convertPathForCMD(sdk4_1Path + "/bin/adt.bat") + " ";
			content += "-package -storetype pkcs12 -keystore ";
			content += FileUtils.convertPathForCMD(sertificatePath) + " ";
			content += "-storepass q -target native -storetype pkcs12 -keystore ";
			content += FileUtils.convertPathForCMD(sertificatePath) + " ";
			content += "-storepass q ";
			content += FileUtils.convertPathForCMD(outputPackagePath) + " ";
			content += FileUtils.convertPathForCMD(powerPackProjectPath + "/bin-debug/Generator-app.xml") + " ";
			content += "-C ";
			content += FileUtils.convertPathForCMD(powerPackProjectPath + "/bin-debug") + " ";
			content += "Generator.swf ";
			content += "-C ";
			content += FileUtils.convertPathForCMD(powerPackProjectPath + "/bin-debug") + " ";
			content += "assets";
			
			return content;
		}
		
		private function onBatFilesGenerated():void
		{
			initProcess();
			
			buildSwf();
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
				return null;
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
//					outputPath = File.applicationStorageDirectory.nativePath + '/appInstaller.exe'
					outputPath = "c:/temp/appInstaller.exe"					
					
					break;
				}
			}
			
			return outputPath;
		}
		
		private function get compilerArguments() : Vector.<String>
		{
			var argVector : Vector.<String>               = new Vector.<String>();
			var batFilePath : String;
			switch(compilerType)
			{
				case COMPILER_TYPE_SWF:
				{
					batFilePath = FileUtils.convertPathForCMD(swfBatFilePath, true);
					
					break;
				}
				case COMPILER_TYPE_PACKAGE:
				{
					batFilePath = FileUtils.convertPathForCMD(packageBatFilePath, true);
					
					break;
				}	
			}
			
			argVector.push("/c");
			argVector.push(batFilePath);
				
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
				
				var exitMessage : String = evt.exitCode == 0 ? "Building process was completed Ok." : "Building process completed with errors.";
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

