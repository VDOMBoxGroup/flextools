package net.vdombox.ide.modules.wysiwyg.model
{
	import flash.net.SharedObject;

	import net.vdombox.ide.common.model.StatesProxy;

	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;

	public class VisibleRendererProxy extends Proxy implements IProxy
	{
		public static const NAME : String = "visibleRendererProxy";

		private var statesProxy : StatesProxy;

		private var sharedObjects : Object = {};

		public function VisibleRendererProxy()
		{
			super( NAME, {} );
		}


		public function getVisible( rendererID : String ) : Boolean
		{
			return sharedObject.data.hasOwnProperty( rendererID ) ? sharedObject.data[ rendererID ] : true
		}

		public function setVisible( rendererID : String, value : Boolean ) : void
		{
			sharedObject.data[ rendererID ] = value;
		}

		private function get sharedObject() : SharedObject
		{
			var id : String;

			statesProxy = facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;

			id = statesProxy.selectedApplication.id;

			if ( !sharedObjects[ id ] )
				sharedObjects[ id ] = SharedObject.getLocal( id )

			return sharedObjects[ id ]
		}
	}
}
