package net.vdombox.ide.modules.wysiwyg.model
{
	import flash.net.SharedObject;
	
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;

	public class VisibleRendererProxy extends Proxy implements IProxy
	{
		public static const NAME : String = "visibleRendererProxy";
		
		private var sessionProxy : SessionProxy;
		private var sharedObjects : Object = {};
		
		public function VisibleRendererProxy()
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