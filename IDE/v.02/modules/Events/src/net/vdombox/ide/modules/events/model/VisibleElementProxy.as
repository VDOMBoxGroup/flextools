package net.vdombox.ide.modules.events.model
{
	import flash.net.SharedObject;
	
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;

	public class VisibleElementProxy extends Proxy implements IProxy
	{

		public static const NAME : String = "VisibleElementProxy";
		
		private var sessionProxy : SessionProxy;
		private var sharedObjects : Object = {};
		
		public function VisibleElementProxy()
		{
			
			super( NAME, {} );
		}
		
		
		public function getVisible( rendererID : String ) : Boolean
		{	
			return sharedObject.data.hasOwnProperty(rendererID) ? sharedObject.data[rendererID] : true
		}
		
		public function setVisible( rendererID : String, value : Boolean ) : void
		{
			sharedObject.data[rendererID] = value;
		}
		
		public function getShowNotVisible() : Boolean
		{	
			return sharedObject.data.showNotVisible ? sharedObject.data.showNotVisible : false;
		}
		
		public function setShowNotVisible( value : Boolean ) : void
		{
			sharedObject.data.showNotVisible = value;
		}
		
		private function get sharedObject():SharedObject
		{
			var id : String; 
			
			sessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;
			
			id = sessionProxy.selectedApplication.id;
			
			if (!sharedObjects[ id ])
				sharedObjects[ id ] =  SharedObject.getLocal( id )
			
			return sharedObjects[ id ]
		}
	}
}