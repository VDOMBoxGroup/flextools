package net.vdombox.ide.modules.wysiwyg.model
{
	import flash.net.SharedObject;
	
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;

	public class UserTypesProxy extends Proxy implements IProxy
	{
		public static const NAME : String = "userTypesProxy";
		
		private var sharedObject : Object;
		
		public function UserTypesProxy()
		{
			super( NAME, {} );
		}
		
		override public function onRegister() : void
		{
			sharedObject = SharedObject.getLocal( "userTypes" );
		}
		
		public function getTypes( ) : Object
		{
			return sharedObject.data;
		}
		
		public function findTypeId( typeId : String ) : String
		{
			return sharedObject.data.hasOwnProperty(typeId) ? sharedObject.data[typeId] : ""
		}
		
		public function addTypeId( typeId : String ) : void
		{
			sharedObject.data[typeId] = typeId;
		}
		
		public function removeTypeId( typeId : String ) : void
		{
			sharedObject.data[typeId] = "";
		}
		
		
	}
}