package proxy
{
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	public class ResourcesProxy extends EventDispatcher
	{
		private static var instance : ResourcesProxy;
		
		private var _contacts : Array;
		private var resourcesStack : Vector.<String> = new Vector.<String>(); 
		
		public function ResourcesProxy(target:IEventDispatcher=null)
		{
			super(target);
			
			if ( instance )
				throw new Error( "Singleton and can only be accessed through Soap.anyFunction()" );
			
			var fileStream : FileStream = new FileStream();
			
			var contactsJSON : String = "[]";
			try
			{
				fileStream.open( contactsFile, FileMode.READ );
				contactsJSON = fileStream.readUTF();
			}
			catch ( error : IOError )
			{
//				Event.
				
			}
			_contacts = JSON.parse( contactsJSON ) as Array;
			fileStream.close();
			
		}
		
		public static function getInstance() : ResourcesProxy
		{
			if ( !instance )
				instance = new ResourcesProxy();
			
			return instance;
		}
			
		
		public function setContacts( value : String ) : void
		{
			
			_contacts = JSON.parse( value ) as Array;
			
			
			
			// save to File store
			saveContacts()
			// dounload  and save images 
			
		}
		
		public function get contacts() : Array
		{
			return _contacts;
		}
		
		private function get  contactsFile (): File
		{
			return File.applicationStorageDirectory.resolvePath( "contacts.json" );
		}
		
		
		private function saveContacts():void
		{
			var contactsJSON : String = JSON.stringify( _contacts );
			var fileStream : FileStream = new FileStream();
			
			try
			{
				fileStream.open( contactsFile, FileMode.WRITE );
				fileStream.writeUTF( contactsJSON );
				
			}
			catch ( error : IOError )
			{
				
				
			}
			fileStream.close();
			
		}
		
		
	}
}