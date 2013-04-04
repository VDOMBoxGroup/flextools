package net.vdombox.ide.core.model
{
	import flash.net.SharedObject;
	
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;

	public class SettingsProxy extends Proxy implements IProxy
	{
		public static const NAME : String = "SettingsProxy";
		
		private var shObjData : Object;
		
		public function SettingsProxy()
		{
			super( NAME );
		}
		
		override public function onRegister() : void
		{
			shObjData = SharedObject.getLocal( "appStorage" );
		}
		
		public function setSelectedApp( server : String, id : String ) : void
		{
			shObjData.data[ server ] = id;
		}
		
		public function getSelectedApp( server : String ) : String
		{
			return shObjData.data[ server ] ? shObjData.data[ server ] : "";
		}
	}
}