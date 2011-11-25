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
		
		
		public function getRenderer( rendererID : String ) : Boolean
		{	
			return sharedObject.data.hasOwnProperty( rendererID );
		}
		
		public function getElementEyeOpened( rendererID : String ) : Boolean
		{	
			return sharedObject.data.hasOwnProperty(rendererID) ? sharedObject.data[rendererID] : true;
		}
		
		public function setElementEyeOpened( rendererID : String, opened : Boolean ) : void
		{
			sharedObject.data[rendererID] = opened;
		}
		
		public function getObjectEyeOpened( objectID : String ) : Boolean
		{	
			return sharedObject.data.hasOwnProperty(objectID) ? sharedObject.data[objectID] : true;
		}
		
		public function setObjectEyeOpened( objectID : String, _visible : Boolean ) : void
		{
			sharedObject.data[objectID] = _visible;
		}
		
		public function get showHidden() : Boolean
		{	
			return sharedObject.data.hasOwnProperty( "showHidden" ) ? sharedObject.data["showHidden"] : false;
		}
		
		public function set showHidden( value : Boolean ) : void
		{
			sharedObject.data["showHidden"] = value;
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
			
			sessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;
			
			selectedApplicationId = sessionProxy.selectedApplication.id;
			
			if (!sharedObjects[ selectedApplicationId ])
				sharedObjects[ selectedApplicationId ] =  SharedObject.getLocal( selectedApplicationId );
			
			return sharedObjects[ selectedApplicationId ]
		}
	}
}