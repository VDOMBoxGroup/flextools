package net.vdombox.powerpack.lib.player.managers
{
	import flash.display.Bitmap;
	import flash.utils.Dictionary;

	public class ResourceManager
	{

		private static var instance:ResourceManager;

		private var resources : Dictionary;
		private var nameToID : Dictionary;

		public static function getInstance():ResourceManager
		{
			if (!instance)
				instance=new ResourceManager();

			return instance;
		}

		public function ResourceManager()
		{
			if (instance)
				throw new Error("Singleton and can only be accessed through ResourceManager.getInstance()");
		}

		public function createResource( xml : XML ) : void
		{
			var id : String = xml.@ID;
			var name : String = xml.@name;
			var data : String = xml.toString();
			
			resources[ id ] = data;
			nameToID[ name ] = id;
		}

		public function createResources( xml : XML ) : void
		{
			var resourcesXML : XML = xml.resources[0];
			
			if ( !resourcesXML )
				 return;
			
			resources = new Dictionary();
			nameToID= new Dictionary();
			
			for each ( var resourceXML : XML in resourcesXML.children() )
			{
				createResource( resourceXML );
			}
			
		}

		public function getBase64ByID( value:String ) : String
		{
			return (value in resources) ? resources [ value ] : null ;
		}

		public function getBase64ByName( value:String ) : String
		{
			var ID : String = (value in  nameToID) ? nameToID[ value ] : null;
			
			return ( ID in resources ) ? resources [ ID ] : null ;  
		}

		public function getBitmapByID( value:String ) : Bitmap
		{
			return null;
		}

		public function getBitmapByName( value:String ) : Bitmap
		{
			return null;
		}
		
		
	}
}