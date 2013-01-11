package net.vdombox.powerpack.lib.player.managers
{
	import com.hurlant.util.Base64;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.PixelSnapping;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.setTimeout;
	
	import mx.utils.Base64Decoder;

	public class ResourceManager extends EventDispatcher
	{

		private static var instance:ResourceManager;

		private var resources : Dictionary;
		private var nameToID : Dictionary;

		public var bitmap : Bitmap;
		
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

		public function getBase64ByID ( id:String ) : String
		{
			return (id in resources) ? resources [ id ] : null ;
		}

		public function getBase64ByName ( name:String ) : String
		{
			var ID : String = (name in  nameToID) ? nameToID[ name ] : null;
			
			return ( ID in resources ) ? resources [ ID ] : null ;  
		}

		public function getBitmapByID( id:String ) : void
		{
			var resourceBase64 : String = getBase64ByID(id);
			
			if (resourceBase64)
				decodeBase64(resourceBase64);
			else
			{
				var errorEvent : ErrorEvent = new ErrorEvent(ErrorEvent.ERROR);
				errorEvent.text = "Resource '"+id+"' is not found.";
				
				setTimeout(sendError, 100);
				
				function sendError () : void
				{
					dispatchEvent( errorEvent );
				}
			}
		}

		public function getBitmapByName( name:String ) : void
		{
			var resourceBase64 : String = getBase64ByName(name);
			
			if (resourceBase64)
				decodeBase64(resourceBase64);
			else
			{
				var errorEvent : ErrorEvent = new ErrorEvent(ErrorEvent.ERROR);
				errorEvent.text = "Resource '"+name+"' is not found.";
				
				setTimeout(sendError, 100);
				
				function sendError () : void
				{
					dispatchEvent( errorEvent );
				}
			}
		}
		
		private function decodeBase64 (data:String) : void
		{               
			var decoder : Base64Decoder = new Base64Decoder();
			decoder.decode( data );
			
			decodeByteArray(decoder.toByteArray());   
		}          
		
		private function decodeByteArray (bytes:ByteArray) : void
		{   
			var ldr:Loader = new Loader(); 
			addLoaderListeners();
			
			ldr.loadBytes(bytes); 
			
			function bytesLoadComplete (event : Event) : void
			{
				ldr.contentLoaderInfo.removeEventListener(Event.COMPLETE, bytesLoadComplete);
				ldr.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, bytesLoadError);
				ldr.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, bytesLoadError);
				
				bitmap = ldr.content as Bitmap;
				
				dispatchEvent( new Event(Event.COMPLETE) );
			}
			
			function bytesLoadError (event : Event) : void
			{
				removeLoaderListeners(); 
				
				bitmap = null;
				
				var errorEvent : ErrorEvent = new ErrorEvent(ErrorEvent.ERROR);
				errorEvent.text = event["text"];
				
				dispatchEvent( errorEvent );
			}
			
			function addLoaderListeners () : void
			{
				ldr.contentLoaderInfo.addEventListener(Event.COMPLETE, bytesLoadComplete);
				ldr.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, bytesLoadError);
				ldr.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, bytesLoadError);
			}
			
			function removeLoaderListeners () : void
			{
				ldr.contentLoaderInfo.removeEventListener(Event.COMPLETE, bytesLoadComplete);
				ldr.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, bytesLoadError);
				ldr.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, bytesLoadError);
			}
			
		}
	}
}