package net.vdombox.ide.modules.events.model
{
	import flash.net.SharedObject;
	
	import net.vdombox.ide.common.model.StatesProxy;
	
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;

	public class VisibleElementProxy extends Proxy implements IProxy
	{

		public static const NAME : String = "VisibleElementProxy";
		
		private var statesProxy : StatesProxy;
		
		private var sharedObjects : Object = {};
		
		public function VisibleElementProxy()
		{
			
			super( NAME, {} );
		}
		
		public function getRenderer( rendererID : String ) : Boolean
		{	
			return sharedObject.data.hasOwnProperty( rendererID );
		}
		
		public function get showCurrent() : String
		{	
			return sharedObject.data.hasOwnProperty( "showCurrent" ) ? sharedObject.data["showCurrent"] : "Full View";
		}
		
		public function set showCurrent( value : String ) : void
		{
			sharedObject.data["showCurrent"] = value;
		}
		
		private function get sharedObject():SharedObject
		{
			var selectedApplicationId : String; 
			
			statesProxy = facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;
			
			selectedApplicationId = statesProxy.selectedApplication.id;
			
			if (!sharedObjects[ selectedApplicationId ])
				sharedObjects[ selectedApplicationId ] =  SharedObject.getLocal( selectedApplicationId );
			
			return sharedObjects[ selectedApplicationId ]
		}
	}
}