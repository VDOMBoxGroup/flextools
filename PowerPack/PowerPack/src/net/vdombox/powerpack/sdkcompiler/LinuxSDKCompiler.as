package net.vdombox.powerpack.sdkcompiler
{
	import flash.events.NativeProcessExitEvent;
	import flash.filesystem.File;
	
	import net.vdombox.powerpack.lib.extendedapi.utils.FileUtils;

	public class LinuxSDKCompiler extends SDKCompiler
	{
		public function LinuxSDKCompiler()
		{
			super();
		}
		
		override protected function get adtPath () : String
		{
			return new File(airSDKForLinuxPath).resolvePath("bin/adt").nativePath;
		}
		
	}
}