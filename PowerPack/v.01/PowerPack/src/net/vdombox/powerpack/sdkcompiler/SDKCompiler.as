package net.vdombox.powerpack.sdkcompiler
{
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.errors.IllegalOperationError;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	
	import mx.utils.Base64Encoder;
	import mx.utils.StringUtil;
	
	import net.vdombox.powerpack.lib.extendedapi.containers.SuperAlert;
	import net.vdombox.powerpack.lib.extendedapi.utils.FileUtils;
	import net.vdombox.powerpack.lib.extendedapi.utils.Utils;
	import net.vdombox.powerpack.managers.BuilderContextManager;
	import net.vdombox.powerpack.template.BuilderTemplate;
	import net.vdombox.powerpack.template.BuilderTemplateProject;

	public class SDKCompiler extends EventDispatcher
	{
		public static const PACKAGE_TYPE_AIR	: String = "AIR";
		public static const PACKAGE_TYPE_NATIVE	: String = "NATIVE";
		
		protected var packageTypeNative : Boolean;
		
		protected var process : NativeProcess;

		protected var embeddedAppFileName : String;
		
		protected var flex_sdk4_1Path : String;
		protected var airSDKForLinuxPath : String;
		
		protected var useTimestamp : Boolean = true;
		
		private var installerTplXml : XML = 
			<application xmlns="http://ns.adobe.com/air/application/2.0">
			 <initialWindow>
			  <content>Installer.swf</content> 
			  <systemChrome>none</systemChrome> 
			  <transparent>true</transparent> 
			  <maximizable>false</maximizable> 
			  <resizable>false</resizable> 
			 </initialWindow>
			 <installFolder>VDOM</installFolder> 
			 <programMenuFolder>VDOM</programMenuFolder> 
			 <icon>
			  <image16x16>assets/icons/Installer16.png</image16x16> 
			  <image32x32>assets/icons/Installer32.png</image32x32> 
			  <image48x48>assets/icons/Installer48.png</image48x48> 
			  <image128x128>assets/icons/Installer128.png</image128x128> 
			 </icon>
			</application>;
		
		public function SDKCompiler()
		{
		}
		
		// ---------- BUILD ---------------------
		public function buildInstallerPackage(flexSdkPath : String,
											  airSdkForLinuxPath : String,
											  packageType : String = PACKAGE_TYPE_AIR,
											  timeStamp : Boolean = true) : void
		{
			if (!NativeProcess.isSupported)
			{
				sendEvent(SDKCompilerEvent.BUILD_ERROR, "Native process is not available");
				return;
			}
			
			flex_sdk4_1Path = flexSdkPath;
			airSDKForLinuxPath = airSdkForLinuxPath;
			
			this.useTimestamp = timeStamp;
			
			this.packageTypeNative = packageType == PACKAGE_TYPE_NATIVE;
			
			var prepareComplete : Boolean = prepareForBuild();
			
			if (prepareComplete)
				packageInstaller();
		}
		
		// ---------- PREPARE FOR BUILD ... ---------------------
		private function prepareForBuild () : Boolean
		{
			return prepareInstallerApp() && prepareTemplateXMLFile() && prepareInstallerPropertiesXml();
		}
		
		private function prepareTemplateXMLFile() : Boolean
		{
			try
			{
				var targetTemplateFile : File = File.applicationStorageDirectory.resolvePath("assets/template.xml");
				
				currentTemplate.file.copyTo(targetTemplateFile, true);
			}
			catch (e:Error)
			{
				sendEvent(SDKCompilerEvent.BUILD_ERROR, "Can't prepare template xml");				
				return false;
			}
			
			return true;
		}
		
		private function prepareInstallerPropertiesXml() : Boolean
		{
			var fileStream : FileStream = new FileStream();
			
			var targetXmlFile : File = File.applicationStorageDirectory.resolvePath("Installer-app.xml");
			
			var installerXML : XML;
			var targetXmlSource : String;
			
			try 
			{
				installerXML = installerTplXml;
				
				installerXML.id = "net.vdom." + selectedTemplateProject.installerId;
				installerXML.name = selectedTemplateProject.name;
				installerXML.filename = selectedTemplateProject.name;
				installerXML.version = Utils.getApplicationVersion();
				
				installerXML.normalize();
				
				fileStream.open(targetXmlFile, FileMode.WRITE);
				fileStream.writeUTFBytes( '<?xml version="1.0" encoding="UTF-8"?>' + "\n" + installerXML.toXMLString() );
				fileStream.close();
			} 
			catch (e:Error)
			{
				fileStream.close();
				
				sendEvent(SDKCompilerEvent.BUILD_ERROR, "Can't prepare installer properties xml");
				return false;
			}
			
			return true;
		}
		
		private function prepareInstallerApp() : Boolean
		{
			var embededAppPath : String = selectedTemplateProject.embededAppPath;
			
			if (!embededAppPath)
				return true;
			
			embeddedAppFileName = FileUtils.getFileName(embededAppPath);
			
			var compressedEmbeddedApp : String = compressEmbeddedApplication();
			if (!compressedEmbeddedApp)
			{
				embeddedAppFileName = "";
				return false;
			}
			
			try
			{
				var targetAppFile : File = File.applicationStorageDirectory.resolvePath(embeddedAppFileName);
				
				var fileStream : FileStream = new FileStream();
				fileStream.open(targetAppFile, FileMode.WRITE);
				fileStream.writeUTFBytes(compressedEmbeddedApp);
				
				fileStream.close();
				fileStream = null;
				
			}
			catch (e:Error)
			{
				fileStream.close();
				
				embeddedAppFileName = "";
				
				//sendEvent(SDKCompilerEvent.BUILD_ERROR, "Error when trying to copy embedded application xml");
				var msg:String = "Compressing embedded application:\n\n" + e.message.toString();
				
				sendEvent(SDKCompilerEvent.BUILD_ERROR, msg);
				return false;
			}
			
			return true;
			
		}
		
		private function compressEmbeddedApplication () : String
		{
			var sourceAppFile : File = new File(selectedTemplateProject.embededAppPath);
			
			if (!sourceAppFile || !sourceAppFile.exists)
			{
				var msg : String = "File '" + sourceAppFile.nativePath + "' doesn't exist.";
				
				sendEvent(SDKCompilerEvent.BUILD_ERROR, "");
				
				return "";
			}
			
			var fileStream : FileStream = new FileStream();
			var fileData : ByteArray = new ByteArray();
			
			try
			{
				fileStream.open( sourceAppFile, FileMode.READ );
				fileStream.readBytes( fileData );
				fileStream.close();
			}
			catch ( error : Error )
			{
				fileStream.close();
				
				msg = "Compressing embedded application:\n\n" + error.message.toString();
				sendEvent(SDKCompilerEvent.BUILD_ERROR, msg);
				
				return "";
			}
			
			if ( !fileData || fileData.bytesAvailable == 0 )
			{
				msg = "File '" + sourceAppFile.nativePath + "' is empty.";
				
				sendEvent(SDKCompilerEvent.BUILD_ERROR, "");
				
				return "";
			}
			
			fileData.compress();
			fileData.position = 0;
			
			var base64Data : Base64Encoder = new Base64Encoder();
			base64Data.insertNewLines = false;
			base64Data.encodeBytes( fileData );
			
			return base64Data.toString();
		}
		// ---------- ... PREPARE FOR BUILD ---------------------
		
		protected function packageInstaller() : void
		{
			initProcess();
			startProcess();
		}
		
		protected function initProcess():void
		{
			process = new NativeProcess();
			
			addProcessListeners();
		}
		
		protected function startProcess() : void
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
			var outputFileName : String = selectedTemplateProject.outputFileName + outputPackageType;
			
			return new File(selectedTemplateProject.outputFolderPath).resolvePath(outputFileName).nativePath; 
		}
		
		protected function get outputPackageType () : String
		{
			return packageTypeNative ? FileUtils.nativeInstallerType : ".air";
		}
		
		protected function get adtPath () : String
		{
			return new File(flex_sdk4_1Path).resolvePath("bin/adt").nativePath;
		}
		
		protected function get compilerArguments() : Vector.<String>
		{
			var argVector : Vector.<String>		= new Vector.<String>();
			
			argVector.push(adtPath);
			argVector.push("-package");
			argVector.push("-storetype");
			argVector.push("pkcs12");
			argVector.push("-keystore");
			argVector.push(sertificatePath);
			argVector.push("-storepass");
			argVector.push("q");
			
			if (!useTimestamp)
			{
				argVector.push("-tsa");
				argVector.push("none");
			}
			
			argVector.push("-target");
			
			if (packageTypeNative)
				argVector.push("native");
			else
				argVector.push("air");
			
			argVector.push(outputPackagePath);
			
			argVector.push(new File(powerPackProjectStoragePath).resolvePath("Installer-app.xml").nativePath);
			
			argVector.push("-C");
			argVector.push(powerPackProjectPath);
			argVector.push("Installer.swf");
			argVector.push("-C");
			argVector.push(powerPackProjectPath);
			argVector.push("assets");
			argVector.push("-C");
			argVector.push(powerPackProjectStoragePath);
			argVector.push("assets/template.xml");
			
			if (embeddedAppFileName)
			{
				argVector.push("-C");
				argVector.push(powerPackProjectStoragePath);
				argVector.push(embeddedAppFileName);
			}
			
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
			trace ("[SDKCompiler] onProcessProgressEvent");
			if (evt.type == ProgressEvent.STANDARD_ERROR_DATA)
			{
				sendEvent(SDKCompilerEvent.BUILD_ERROR, errorMsg);
				
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
			var exitMessage : String = exitCode == 0 ? "Building process has been completed successfully." : getErrorMessageByExitCode(exitCode);
			
			sendEvent(SDKCompilerEvent.BUILD_COMPETE, exitMessage);
		}
		
		private function getErrorMessageByExitCode (exitCode:Number) : String
		{
			var exitErrorMsg : String = "Building process has been completed with errors.";
			
			switch(exitCode)
			{
				case 2:
				{
					exitErrorMsg = "Usage error:\nCheck the command-line arguments for errors";
					break;
				}
				case 5:
				{
					exitErrorMsg = "Unknown error:\nThis error indicates a situation that cannot be explained by common error conditions. Possible root causes include incompatibility between ADT and the Java Runtime Environment, corrupt ADT or JRE installations, and programming errors within ADT.";
					break;
				}
				case 6:
				{
					exitErrorMsg = "Could not write to output directory:\nMake sure that the specified (or implied) output directory is accessible and that the containing drive is has sufficient disk space.";
					break;
				}
				case 7:
				{
					exitErrorMsg = "wCould not access certificate:\nMake sure that the path to the keystore is specified correctly.\nCheck that the certificate within the keystore can be accessed. The Java 1.6 Keytool utility can be used to help troubleshoot certificate access issues.";
					break;
				}
				case 8:
				{
					exitErrorMsg = "Invalid certificate:\nThe certificate file is malformed, modified, expired, or revoked.";
					break;
				}
				case 9:
				{
					exitErrorMsg = "Could not sign AIR file:\nVerify the signing options passed to ADT.";
					break;
				}
				case 10:
				{
					exitErrorMsg = "Could not create time stamp:\nADT could not establish a connection to the timestamp server. If you connect to the internet through a proxy server, you may need to configure the JRE proxy settings.";
					break;
				}
				case 11:
				{
					exitErrorMsg = "Certificate creation error:\nVerify the command-line arguments used for creating signatures.";
					break;
				}
				case 12:
				{
					exitErrorMsg = "Invalid input:\nVerify file paths and other arguments passed to ADT on the command line.";
					break;
				}
				case 13:
				{
					exitErrorMsg = "Missing device SDK:\nVerify the device SDK configuration. ADT cannot locate the device SDK required to execute the specified command.";
					break;
				}
				case 14:
				{
					exitErrorMsg = "Device error:\nADT cannot execute the command because of a device restriction or problem. For example, this exit code is emitted when attempting to uninstall an app that is not actually installed.";
					break;
				}
				case 15:
				{
					exitErrorMsg = "No devices:\nVerify that a device is attached and turned on or that an emulator is running.";
					break;
				}
				case 16:
				{
					exitErrorMsg = "Missing GPL components:\nThe current AIR SDK does not include all the components required to perform the request operation.";
					break;
				}
				case 17:
				{
					exitErrorMsg = "Device packaging tool failed:\nThe package could not be created because expected operating system components are missing.";
					break;
				}
				
			}
			
			return exitErrorMsg;
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
		
		protected function sendEvent (eventType : String, msg : String = "") : void
		{
			var processEvent : SDKCompilerEvent = new SDKCompilerEvent(eventType);
			processEvent.message = msg;
			
			dispatchEvent(processEvent);
		}
		
		private function get currentTemplate() : BuilderTemplate
		{
			return BuilderContextManager.currentTemplate;
		}
		
		private function get selectedTemplateProject () : BuilderTemplateProject
		{
			return currentTemplate.selectedProject as BuilderTemplateProject
		}

	}
}

