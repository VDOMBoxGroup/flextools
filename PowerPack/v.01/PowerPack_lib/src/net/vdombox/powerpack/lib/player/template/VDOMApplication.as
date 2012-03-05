package net.vdombox.powerpack.lib.player.template
{
	import net.vdombox.powerpack.lib.extendedapi.utils.FileUtils;

	public class VDOMApplication
	{
		public function VDOMApplication()
		{
		}
		
		public var path : String = "";
		public var stored : Boolean = false;
		
		public function get fileName () : String
		{
			return FileUtils.getFileName(path);
		}
		
	}
}