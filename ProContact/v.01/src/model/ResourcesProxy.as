//------------------------------------------------------------------------------
//
//   Copyright 2011 
//   VDOMBOX Resaerch  
//   All rights reserved. 
//
//------------------------------------------------------------------------------

package model
{
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	public class ResourcesProxy extends EventDispatcher
	{
		private static var instance : ResourcesProxy;

		public static function getInstance() : ResourcesProxy
		{
			if ( !instance )
				instance = new ResourcesProxy();

			return instance;
		}

		public function ResourcesProxy( target : IEventDispatcher = null )
		{
			super( target );

			if ( instance )
				throw new Error( "Singleton and can only be accessed through ResourcesProxy.getInstance()" );

			loadLocalResours();
		}

		private var resourses : Dictionary = new Dictionary();

		public function loadImages( contactsVO : Array ) : void
		{
			for each ( var contactVO : ContactVO in contactsVO )
			{
				if (  contactVO.imgGUID in resourses )
					continue;

				resourses[ contactVO.imgGUID ] = "";

				loadResource( contactVO );
			}
		}

		private function loadLocalResours() : void
		{
			var cacheFolder : File = File.applicationStorageDirectory.resolvePath( "cache" );

			if ( !cacheFolder.exists )
			{
				cacheFolder.createDirectory();
				return;
			}

			// create resources list
			var fileList : Array = cacheFolder.getDirectoryListing();

			for each ( var file : File in fileList )
			{
				resourses[ file.name ] = "";
			}
		}

		private function loadResource( contactVO : ContactVO ) : void
		{
			var newFile : File = File.applicationStorageDirectory.resolvePath( "cache/" + contactVO.imgGUID );

			var request : URLRequest = new URLRequest( contactVO.imgURL );
			var loader : URLLoader = new URLLoader();

			loader.dataFormat = URLLoaderDataFormat.BINARY;

			// pass the post data
			request.method = URLRequestMethod.POST;

			loader.addEventListener( Event.COMPLETE, completeHandler );
			loader.addEventListener( IOErrorEvent.IO_ERROR, errorHandler );
			loader.addEventListener( SecurityErrorEvent.SECURITY_ERROR, errorHandler );

			loader.load( request );

			function completeHandler( event : Event ) : void
			{
				var fileStream : FileStream = new FileStream();

				try
				{
					fileStream.open( newFile, FileMode.WRITE );
					fileStream.writeBytes( event.target.data as ByteArray );
				}
				catch ( error : IOError )
				{
				}

				fileStream.close();
			}

			function errorHandler( event : Event ) : void
			{

			}
		}

		private function resourceExist( value : String ) : Boolean
		{
			for each ( var fileName : String in resourses )
			{
				if ( fileName == value )
					return true;
			}

			return false;
		}
	}
}
