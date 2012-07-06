package net.vdombox.powerpack.sdkcompiler
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	import net.vdombox.powerpack.lib.extendedapi.utils.FileUtils;

	public class WindowsSDKCompiler extends SDKCompiler
	{
		public function WindowsSDKCompiler()
		{
			super();
		}
		
		protected override function packageInstaller():void
		{
			var batFileGenerated : Boolean = generateBuildingBatFile();
			
			if (batFileGenerated)
				onBatFilesGenerated();
		}
		
		private function generateBuildingBatFile () : Boolean
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
				sendEvent(SDKCompilerEvent.BUILD_ERROR, "Error when creating bat file");
				return false;
			}
			
			return true;
		}
		
		private function get packageBatFilePath () : String
		{
			return File.applicationStorageDirectory.resolvePath("generatePlayerPackage.bat").nativePath;
		}
		
		private function get packageBatFileContent() : String
		{
			var argVector : Vector.<String>		= new Vector.<String>();
			
			argVector.push(FileUtils.convertPathForCMD(new File(flex_sdk4_1Path).resolvePath("bin/adt.bat").nativePath));
			argVector.push("-package");
			argVector.push("-storetype");
			argVector.push("pkcs12");
			argVector.push("-keystore");
			argVector.push(FileUtils.convertPathForCMD(sertificatePath));
			argVector.push("-storepass");
			argVector.push("q");
			
			if (!useTimestamp)
			{
				argVector.push("-tsa");
				argVector.push("none");
			}
			
			argVector.push("-target");
			
			if (!packageTypeNative)
				argVector.push("air");
			else
				argVector.push("native");
			
			argVector.push(FileUtils.convertPathForCMD(outputPackagePath));
			argVector.push(FileUtils.convertPathForCMD(new File(powerPackProjectStoragePath).resolvePath("Installer-app.xml").nativePath));
			
			argVector.push("-C");
			argVector.push(FileUtils.convertPathForCMD(powerPackProjectPath));
			argVector.push("Installer.swf");
			argVector.push("-C");
			argVector.push(FileUtils.convertPathForCMD(powerPackProjectPath));
			argVector.push("assets");
			argVector.push("-C");
			argVector.push(FileUtils.convertPathForCMD(powerPackProjectStoragePath));
			argVector.push("assets/template.xml");
			
			if (embeddedAppFileName)
			{
				argVector.push("-C");
				argVector.push(FileUtils.convertPathForCMD(powerPackProjectStoragePath));
				argVector.push(embeddedAppFileName);
			}
			
			return argVector.join(" ");
		}
		
		private function onBatFilesGenerated():void
		{
			initProcess();
			
			startProcess();
		}
		
		protected override function get compilerArguments() : Vector.<String>
		{
			var argVector : Vector.<String>		= new Vector.<String>();
			
			argVector.push("/c");
			argVector.push(FileUtils.convertPathForCMD(packageBatFilePath, true));
			
			return argVector;
		}
		
	}
}