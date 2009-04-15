package modules
{
	import mx.controls.Alert;
	import mx.modules.Module;
	
	import net.vdombox.ide.interfaces.IVDOMIDEModule;

	public class VDOMIDEModule extends Module implements IVDOMIDEModule
	{
		public function VDOMIDEModule()
		{
			super();
		}
		public function get title() : String
		{
			return "";
		}
	}
}