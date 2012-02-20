package net.vdombox.powerpack.sdkcompiler
{
	import flash.filesystem.File;

	public class MacSDKCompiler extends SDKCompiler
	{
		public function MacSDKCompiler()
		{
			super();
		}
		
		protected override function get compilerArguments() : Vector.<String>
		{
			var argVector : Vector.<String>		= new Vector.<String>();
			
			argVector.push(new File(flex_sdk4_1Path).resolvePath("bin/adt").nativePath);
			argVector.push("-package");
			argVector.push("-storetype");
			argVector.push("pkcs12");
			argVector.push("-keystore");
			argVector.push(sertificatePath);
			argVector.push("-storepass");
			argVector.push("q");
			argVector.push("-target");
			
			if (packageTypeNative)
				argVector.push("native");
			else
				argVector.push("air");
			
			argVector.push(outputPackagePath);
			
//			argVector.push("-storetype");
//			argVector.push("pkcs12");
//			argVector.push("-keystore");
//			argVector.push(sertificatePath);
//			argVector.push("-storepass");
//			argVector.push("q");
			
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
		
	}
}