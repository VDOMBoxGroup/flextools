package net.vdombox.ide.modules.wysiwyg.model
{
	import flash.net.SharedObject;
	
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;

	public class SharedObjectProxy extends Proxy implements IProxy
	{
		public static const NAME : String = "SharedObjectProxy";
		
		public function SharedObjectProxy()
		{
			super( NAME, {} );
		}
		
		private var shObjData : Object;
		
		override public function onRegister() : void
		{
			shObjData = SharedObject.getLocal( "wysiwigOptions" );
		}
		
		public function get showLinking() : Boolean
		{
			if ( shObjData.data.showLinking != null )
				return shObjData.data.showLinking;
			else
				return true;
		}
		
		public function set showLinking( value : Boolean ) : void
		{
			shObjData.data.showLinking = value;
		}
	}
}