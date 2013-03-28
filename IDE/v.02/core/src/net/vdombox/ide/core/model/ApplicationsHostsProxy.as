package net.vdombox.ide.core.model
{
	import flash.net.SharedObject;
	
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;

	public class ApplicationsHostsProxy extends Proxy implements IProxy
	{
		public static const NAME : String = "ApplicationsHostsProxy";
		
		public function ApplicationsHostsProxy()
		{
			super( NAME, {} );
		}
		
		private var shObjData : Object;
		
		override public function onRegister() : void
		{
			shObjData = SharedObject.getLocal( "aplicationsHosts" );
		}
		
		public function getSelectedHost( key : String ) : String
		{
			return shObjData.data[key] ? shObjData.data[key] : "";
		}
		
		public function setSelectedHost( key : String, value : String ) : void
		{
			shObjData.data[key] = value;
		}
	}
}