package net.vdombox.ide.modules.wysiwyg.model
{
	import flash.net.SharedObject;
	
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;

	public class VisibleRendererProxy extends Proxy implements IProxy
	{
		public static const NAME : String = "VisibleRendererProxy";
		private var _appName : String;
		
		public function VisibleRendererProxy( appName : String )
		{
			super( NAME, {} );
			_appName = appName;
		}
		
		private var shObjData : Object;
		
		override public function onRegister() : void
		{
			shObjData = SharedObject.getLocal( _appName );
		}
		
		public function getVisible( rendererID : String ) : Boolean
		{
			if ( shObjData.data.rendererID != null )
				return shObjData.data.rendererID;
			else
				return true;
		}
		
		public function setVisible( rendererID : String, value : Boolean ) : void
		{
			shObjData.data.rendererID = value;
		}
	}
}