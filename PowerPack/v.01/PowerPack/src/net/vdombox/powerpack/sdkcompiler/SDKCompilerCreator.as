package net.vdombox.powerpack.sdkcompiler
{
	import flash.system.Capabilities;
	
	import net.vdombox.powerpack.lib.extendedapi.utils.FileUtils;

	public class SDKCompilerCreator
	{
		public static function create() : SDKCompiler
		{
			var compiler : SDKCompiler;
			
			var os : String = Capabilities.os.substr(0, 3).toUpperCase();
			
			switch(os)
			{
				case FileUtils.OS_LINUX:
				{
					compiler = new LinuxSDKCompiler();
					break;
				}
					
				case FileUtils.OS_WINDOWS:
				{
					compiler = new WindowsSDKCompiler();
					break;
				}
					
				case FileUtils.OS_MAC:
				{
					// TODO: MAC
					break;
				}
				default :
				{
					throw Error("Can't detect OS");
					break;
				}
					
			}
			
			return compiler;	
		}
		
		
		
	}
}