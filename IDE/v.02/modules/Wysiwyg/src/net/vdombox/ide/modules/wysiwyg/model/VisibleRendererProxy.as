package net.vdombox.ide.modules.wysiwyg.model
{
	import flash.net.SharedObject;
	
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;

	public class VisibleRendererProxy extends Proxy implements IProxy
	{
		public static const NAME : String = "visibleRendererProxy";
		
		public function VisibleRendererProxy()
		{
			
			super( NAME, {} );
		}
		
		private var shObjData : Object;
		private var sessionProxy : SessionProxy;
		
		public function getVisible( rendererID : String ) : Boolean
		{
			shObjData = getSharedObject();
			if ( shObjData.data[rendererID] != null )
				return shObjData.data[rendererID];
			else
				return true;
		}
		
		public function setVisible( rendererID : String, value : Boolean ) : void
		{
			shObjData = getSharedObject();
			shObjData.data[rendererID] = value;
		}
		
		private function getSharedObject():SharedObject
		{
			sessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;
			return SharedObject.getLocal( sessionProxy.selectedApplication.id );
		}
	}
}