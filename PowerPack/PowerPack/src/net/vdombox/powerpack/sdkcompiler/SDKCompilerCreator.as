package net.vdombox.powerpack.sdkcompiler
{
	import net.vdombox.powerpack.lib.extendedapi.utils.FileUtils;

	public class SDKCompilerCreator
	{
		public static function create() : SDKCompiler
		{
			var compiler : SDKCompiler;
			
			switch(FileUtils.OS)
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
					compiler = new MacSDKCompiler();
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