package net.vdombox.ide.modules.scripts.model
{
	import flash.net.SharedObject;
	
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;

	public class SaveParametersTabsProxy extends Proxy implements IProxy
	{
		public static const NAME : String = "SaveParametersTabsProxy";
		
		public function SaveParametersTabsProxy()
		{
			super( NAME, {} );
		}
		
		private var shObjData : Object;
		
		override public function onRegister() : void
		{
			shObjData = SharedObject.getLocal( "parametersTabs" );
		}
		
		public function get libraryWidth() : int
		{
			return shObjData.data['libraryWidth'] ? shObjData.data['libraryWidth'] : 228;
		}
		
		public function set libraryWidth( value : int ) : void
		{
			shObjData.data['libraryWidth'] = value;
		}
		
		public function get actionsWidth() : int
		{
			return shObjData.data['actionsWidth'] ? shObjData.data['actionsWidth'] : 228;
		}
		
		public function set actionsWidth( value : int ) : void
		{
			shObjData.data['actionsWidth'] = value;
		}
		
		public function get containersHeight() : Number
		{
			return shObjData.data['containersHeight'] ? shObjData.data['containersHeight'] : 0;
		}
		
		public function set containersHeight( value : Number ) : void
		{
			shObjData.data['containersHeight'] = value;
		}
		
		public function get globalScriptsHeight() : Number
		{
			return shObjData.data['globalScriptsHeight'] ? shObjData.data['globalScriptsHeight'] : 0;
		}
		
		public function set globalScriptsHeight( value : Number ) : void
		{
			shObjData.data['globalScriptsHeight'] = value;
		}
	}
}