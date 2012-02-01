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
	
	import mx.utils.StringUtil;
	
	import net.vdombox.powerpack.lib.extendedapi.utils.FileUtils;
	import net.vdombox.powerpack.lib.extendedapi.utils.Utils;

	public class SDKCompiler extends EventDispatcher
	{
		public static const PACKAGE_TYPE_AIR	: String = "AIR";
		public static const PACKAGE_TYPE_NATIVE	: String = "NATIVE";
		
		private var _packageType : String = PACKAGE_TYPE_NATIVE;
		
		private var process : NativeProcess;

		private var outputInstallerFolderPath : String;
		private var outputInstallerFileName : String;
		private var installerApp : VDOMApplication;
		
		private var sdk4_1Path : String;
		
		public function SDKCompiler()
		{
		}
		
		public function buildInstallerPackage(outputFolderPath : String, outputFileName : String, 
											  app : VDOMApplication, sdkPath : String,
											  packageType : String) : void
		{
			var processEvent : SDKCompilerEvent;
			
			if (!NativeProcess.isSupported)
			{
				sendEvent(SDKCompilerEvent.SDK_COMPILER_ERROR, "Native process is not available");
				return;
			}
			
			outputInstallerFolderPath = outputFolderPath;
			outputInstallerFileName = outputFileName;
			installerApp = app;
			sdk4_1Path = sdkPath;
			
			this.packageType = packageType;
			
			generateBuildingBatFiles();
		}
		
		private function set packageType (value : String) : void
		{
			_packageType = value;
			
			if (!validPackageType)
				_packageType = PACKAGE_TYPE_NATIVE;
		}
		
		private function get validPackageType () : Boolean
		{
			return _packageType == PACKAGE_TYPE_AIR || _packageType == PACKAGE_TYPE_NATIVE;
		}
		
		private function generateBuildingBatFiles () : void
		{
			var batFileGenerated : Boolean;
			
			batFileGenerated = generateBuildingBatFile();
			
			if (batFileGenerated)
				onBatFilesGenerated();
			
			function generateBuildingBatFile () : Boolean
			{
				var batFilePath : String = packageBatFilePath;
				var batFileContent : String = packageBatFileContent;
				
				var fileStream : FileStream = new FileStream();
				var batFile : File = new File(batFilePath);
				
				try
				{
					fileStream.openAsync(batFile, FileMode.WRITE);
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
			content += "-storepass q ";
			
			if (_packageType == PACKAGE_TYPE_NATIVE)
			{
				content += "-target native -storetype pkcs12 -keystore ";
				content += FileUtils.convertPathForCMD(sertificatePath) + " ";
				content += "-storepass q ";
			} 
			else
				content += "-target air ";
			
			content += FileUtils.convertPathForCMD(outputPackagePath) + " ";
			content += FileUtils.convertPathForCMD(powerPackProjectStoragePath + "/Installer-app.xml") + " ";
			content += "-C ";
			content += FileUtils.convertPathForCMD(powerPackProjectPath) + " ";
			content += "Installer.swf ";
			content += "-C ";
			content += FileUtils.convertPathForCMD(powerPackProjectPath) + " ";
			content += "assets" + " ";
			content += "-C ";
			content += FileUtils.convertPathForCMD(powerPackProjectStoragePath) + " ";
			content += "assets/template.xml"
			
			if (installerApp.stored && installerApp.fileName)
			{
				content += " ";
				content += "-C ";
				content += FileUtils.convertPathForCMD(powerPackProjectStoragePath) + " ";
				content += installerApp.fileName; //"app.xml";
			}
			
			return content;
		}
		
		private function onBatFilesGenerated():void
		{
			initProcess();
			
			buildPackage();
		}
		
		private function initProcess():void
		{
			process = new NativeProcess();
			
			addProcessListeners();
		}
		
		private function buildPackage() : void
		{
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
		
		private function get powerPackProjectPath () : String
		{
			return File.applicationDirectory.nativePath;
		}
		
		private function get powerPackProjectStoragePath () : String
		{
			return File.applicationStorageDirectory.nativePath;
		}
		
		private function get sertificatePath () : String
		{
			return powerPackProjectPath + "/assets/sert.p12";
		}
		
		public function get outputPackagePath () : String
		{
			var outputPath : String = outputInstallerFolderPath + "/" + outputInstallerFileName + outputPackageExtension; 
			
			return outputPath;
		}
		
		private function get outputPackageExtension () : String
		{
			if (_packageType == PACKAGE_TYPE_AIR)
				return ".air";
			
			var outputExtension	: String;
			
			var os : String = Capabilities.os.substr(0, 3).toUpperCase();
			
			switch(os)
			{
				case FileUtils.OS_MAC:
				{
					outputExtension = ".dmg";
					break;
				}
				case FileUtils.OS_LINUX:
				{
					outputExtension = ".deb";
					break;
				}
				case FileUtils.OS_WINDOWS:
				default:
				{
					outputExtension = ".exe";
					break;
				}
			}
			
			return outputExtension;
		}
		
		private function get compilerArguments() : Vector.<String>
		{
			var argVector : Vector.<String>		= new Vector.<String>();
			
			var batFilePath : String			= FileUtils.convertPathForCMD(packageBatFilePath, true);
			
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

