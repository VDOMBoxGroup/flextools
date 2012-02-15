package net.vdombox.powerpack.sdkcompiler
{
	import flash.events.NativeProcessExitEvent;
	import flash.filesystem.File;
	
	import net.vdombox.powerpack.lib.extendedapi.utils.FileUtils;

	public class LinuxSDKCompiler extends SDKCompiler
	{
		private var generateTemporaryAirPackage : Boolean;
		
		public function LinuxSDKCompiler()
		{
			super();
		}
		
		protected override function packageInstaller():void
		{
			if (packageTypeNative)
				generateTemporaryAirPackage = true;
			
			startBuilding();
		}
		
		private function startBuilding():void
		{
			initProcess();
			buildPackage();
		}
		
		protected override function get compilerArguments() : Vector.<String>
		{
			if (packageTypeNative && !generateTemporaryAirPackage)
				return compilerNativeArguments;
			
			return compilerAirArguments;
		}
		
		private function get compilerAirArguments() : Vector.<String>
		{
			var airFilePath : String = packageTypeNative && generateTemporaryAirPackage ? temporaryAirPackagePath : outputPackagePath;
			
			trace ("compilerAirArguments: " + airFilePath);
			
			var argVector : Vector.<String>		= new Vector.<String>();
			
			// ------- LINUX -------- Installer.air ------------------
			argVector.push(new File(flex_sdk4_1Path).resolvePath("bin/adt").nativePath);
			argVector.push("-package");
			argVector.push("-storetype");
			argVector.push("pkcs12");
			argVector.push("-keystore");
			argVector.push(sertificatePath);
			argVector.push("-storepass");
			argVector.push("q");
			argVector.push("-target");
			argVector.push("air");
			
			argVector.push(airFilePath);
			
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
			
			
			return argVector;
		}
		
		private function get temporaryAirPackagePath () : String
		{
			return File.applicationStorageDirectory.resolvePath("tmpInstaller.air").nativePath;
		}
		
		private function get compilerNativeArguments() : Vector.<String>
		{
			trace ("compilerNativeArguments");
			var argVector : Vector.<String>		= new Vector.<String>();
			
			argVector.push(new File(airSDKForLinuxPath).resolvePath("bin/adt").nativePath);
			argVector.push("-package");
			argVector.push("-target");
			argVector.push("native");
			argVector.push(outputPackagePath);
			argVector.push(temporaryAirPackagePath);
			
			return argVector;
		}
		
		protected override function onProcessExit (exitCode : Number):void
		{
			if (exitCode == 0)
			{
				if (generateTemporaryAirPackage)
				{
					generateTemporaryAirPackage = false;
					startBuilding();
				}
				else
					super.onProcessExit(exitCode);
			}
		}
		
		
	}
}