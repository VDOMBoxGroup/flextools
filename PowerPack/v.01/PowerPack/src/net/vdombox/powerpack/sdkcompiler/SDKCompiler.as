package net.vdombox.powerpack.sdkcompiler
{
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.errors.IllegalOperationError;
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
	
	import net.vdombox.powerpack.lib.extendedapi.containers.SuperAlert;
	import net.vdombox.powerpack.lib.extendedapi.utils.FileUtils;
	import net.vdombox.powerpack.lib.extendedapi.utils.Utils;

	public class SDKCompiler extends EventDispatcher
	{
		public static const PACKAGE_TYPE_AIR	: String = "AIR";
		public static const PACKAGE_TYPE_NATIVE	: String = "NATIVE";
		
		protected var packageTypeNative : Boolean;
		
		protected var process : NativeProcess;

		protected var outputInstallerFolderPath : String;
		protected var outputInstallerFileName : String;
		protected var installerApp : VDOMApplication;
		
		protected var flex_sdk4_1Path : String;
		protected var airSDKForLinuxPath : String;
		
		public function SDKCompiler()
		{
		}
		
		public function buildInstallerPackage(outputFolderPath : String, outputFileName : String, 
											  app : VDOMApplication, 
											  flexSdkPath : String,
											  airSdkForLinuxPath : String,
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
			flex_sdk4_1Path = flexSdkPath;
			airSDKForLinuxPath = airSdkForLinuxPath;
			
			this.packageTypeNative = packageType == PACKAGE_TYPE_NATIVE;
			
			packageInstaller();
		}
		
		protected function packageInstaller() : void
		{
			// must be overrided by subclass
		}
		
		protected function initProcess():void
		{
			trace ('initProcess');
			process = new NativeProcess();
			
			addProcessListeners();
		}
		
		protected function buildPackage() : void
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
		
		protected function get powerPackProjectPath () : String
		{
			return File.applicationDirectory.nativePath;
		}
		
		protected function get powerPackProjectStoragePath () : String
		{
			return File.applicationStorageDirectory.nativePath;
		}
		
		protected function get sertificatePath () : String
		{
			return new File(powerPackProjectPath).resolvePath("assets/sert.p12").nativePath;
		}
		
		protected function get outputPackagePath () : String
		{
			var outputFileName : String = outputInstallerFileName + outputPackageExtension;
			
			return new File(outputInstallerFolderPath).resolvePath(outputFileName).nativePath; 
		}
		
		protected function get outputPackageExtension () : String
		{
			return ".air";
		}
		
		protected function get compilerArguments() : Vector.<String>
		{
			var argVector : Vector.<String>		= new Vector.<String>();
			
			return argVector;
		}
		
		private function get errorMsg () : String
		{
			return process.standardError ? process.standardError.readUTFBytes(process.standardError.bytesAvailable) : "";
		}
		
		private function get outputMsg () : String
		{
			return process.standardError ? process.standardOutput.readUTFBytes(process.standardOutput.bytesAvailable) : "";
		}

		private function onProcessIOErrorEvent(evt:Event) : void
		{
			trace ("[SDKCompiler] onProcessIOErrorEvent");
		}

		private function onProcessProgressEvent(evt:ProgressEvent) : void
		{
			trace ("[SDKCompiler] onProcessProgressEvent: ");
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
				removeProcessListeners();
				
				process = null;
				
				onProcessExit(evt.exitCode);
			}
		}
		
		protected function onProcessExit (exitCode : Number):void
		{
			trace ("22222222");
			var exitMessage : String = exitCode == 0 ? "Building process was completed Ok." : "Building process completed with errors.";
			
			sendEvent(SDKCompilerEvent.SDK_COMPILER_COMPETE, exitMessage);
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
		
		protected function sendEvent (eventType : String, msg : String) : void
		{
			var processEvent : SDKCompilerEvent = new SDKCompilerEvent(eventType);
			processEvent.message = msg;
			
			dispatchEvent(processEvent);
		}

	}
}

