package net.vdombox.ide.model
{
	import flash.utils.ByteArray;
	
	import mx.rpc.events.FaultEvent;
	import mx.utils.Base64Encoder;
	
	import net.vdombox.ide.events.SOAPEvent;
	import net.vdombox.ide.model.business.SOAP;
	
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;

	public class ResourceProxy extends Proxy implements IProxy
	{
		public static const NAME : String = "ResourceProxy";

		public function ResourceProxy( data : Object = null )
		{
			super( NAME, data );

			addEventListeners();
		}

		private var soap : SOAP = SOAP.getInstance();
		private var cacheManager : CacheManager = CacheManager.getInstance();
		
		private var requestQue : Object = {};

		public function getListResources( applicatioID : String ) : void
		{
			soap.list_resources( applicatioID );
		}

		public function getResource( ownerID : String, resourceID : String ) : void
		{
			if ( !resourceID )
				return;

			var result : ByteArray = cacheManager.getCachedFileById( resourceID );

			if ( result )
			{
				var dummy : * = ""; // FIXME remove dummy
				return;
			}

			if ( !requestQue[ resourceID ] )
			{
				requestQue[ resourceID ] = new Array();
				soap.get_resource( ownerID, resourceID );
			}

			requestQue[ resourceID ].push( {} );
		}

		public function setResource( name : String, data : ByteArray, type : String,
									 applicationID : String ) : void
		{
			data.compress();

			var base64Data : Base64Encoder = new Base64Encoder();
			base64Data.insertNewLines = false;
			base64Data.encodeBytes( data );

			soap.set_resource( applicationID, type, name, base64Data.toString() );
		}

		public function deleteResource( resourceID : String ) : void
		{
			soap.delete_resource( resourceID );
		}

		private function addEventListeners() : void
		{
			soap.list_resources.addEventListener( SOAPEvent.RESULT, listResourcesHandler );

			soap.get_resource.addEventListener( SOAPEvent.RESULT, resourceLoadedOKHandler );
			soap.get_resource.addEventListener( FaultEvent.FAULT, resourceLoadedFaultHandler );

			soap.set_resource.addEventListener( SOAPEvent.RESULT, setResourceOKHandler );
			soap.set_resource.addEventListener( FaultEvent.FAULT, setResourceFaultHandler );

			soap.delete_resource.addEventListener( SOAPEvent.RESULT, deleteResourceOKHandler );
			soap.set_resource.addEventListener( FaultEvent.FAULT, deleteResourceFaultHandler );
		}

		private function listResourcesHandler( event : SOAPEvent ) : void
		{

		}

		private function resourceLoadedOKHandler( event : SOAPEvent ) : void
		{

		}

		private function resourceLoadedFaultHandler( event : FaultEvent ) : void
		{

		}

		private function setResourceOKHandler( event : SOAPEvent ) : void
		{

		}

		private function setResourceFaultHandler( event : FaultEvent ) : void
		{

		}

		private function deleteResourceOKHandler( event : SOAPEvent ) : void
		{

		}

		private function deleteResourceFaultHandler( event : FaultEvent ) : void
		{

		}
	}


}
import flash.utils.ByteArray;
import mx.collections.ArrayCollection;
import flash.filesystem.File;
import flash.filesystem.FileStream;
import mx.collections.IViewCursor;
import mx.collections.Sort;
import mx.collections.SortField;
import flash.filesystem.FileMode;
import flash.errors.IOError;


class CacheManager
{

	private static var instance : CacheManager;
	
	public static function getInstance() : CacheManager
	{
		if ( !instance )
		{

			instance = new CacheManager();
		}

		return instance;
	}

	public function CacheManager()
	{
		if ( instance )
			throw new Error( "Instance already exists." );
	}
	
	private const CACHE_SIZE : uint = 100000000;

	private var cacheFolder : File;
	private var fileStream : FileStream = new FileStream();

	private var applicationId : String;

	private var cacheSize : int;
	private var cachedFiles : ArrayCollection = new ArrayCollection();
	private var cursor : IViewCursor;
	
	public function init() : void
	{
		cursor = cachedFiles.createCursor();

		cachedFiles.sort = new Sort();
		cachedFiles.sort.fields = [ new SortField( "name" ) ];
		cachedFiles.refresh();

		cacheFolder = File.applicationStorageDirectory.resolvePath( "cache" );

		if ( !cacheFolder.exists )
		{
			cacheFolder.createDirectory();
			return;
		}

		var currentDate : Number = new Date().getTime();
		var fileList : Array = cacheFolder.getDirectoryListing();

		for each ( var file : File in fileList )
		{

			var days : Number = ( currentDate - file.creationDate.time ) / 1000 /
				60 / 60 / 24;
			if ( days > 4 )
			{
				file.deleteFile();
				continue;
			}

			cacheSize += file.size;
			cachedFiles.addItem( { create: file.creationDate.time, name: file.name, size: file.size } );
		}
	}

	public function getCachedFileById( resourceId : String ) : ByteArray
	{

		var fileName : String = resourceId;

		var result : Boolean = cursor.findFirst( { name: fileName } );
		if ( result )
		{

			var file : File = cacheFolder.resolvePath( fileName );
			var fileBytes : ByteArray = new ByteArray();

			fileStream.open( file, FileMode.READ );
			fileStream.readBytes( fileBytes );
			fileStream.close();

			return fileBytes;
		}
		else
			return null;
	}

	public function cacheFile( contentName : String, content : ByteArray ) : void
	{

		var fileSize : uint = content.bytesAvailable;

		if ( fileSize > 90000000 )
			return;

		var newFileName : String = contentName;

		if ( cursor.findAny( { name: applicationPrefix + "" + contentName } ) )
		{

			cacheSize -= cursor.current.size;
			cursor.remove();

			try
			{

				cacheFolder.resolvePath( newFileName ).deleteFile();
			}
			catch ( error : IOError )
			{

				return;
			}
		}

		cleanupCache( fileSize );

		var newFile : File = cacheFolder.resolvePath( newFileName );

		try
		{

			fileStream.open( newFile, FileMode.WRITE );
			fileStream.writeBytes( content );
			fileStream.close();

		}
		catch ( error : IOError )
		{

			return;
		}

		cachedFiles.addItem( { create: newFile.creationDate.time, name: newFile.name, size: newFile.size } )
	}

	public function deleteFile( fileName : String ) : Boolean
	{
		var isDone : Boolean = false;

		fileName = applicationPrefix + fileName;

		var isFind : Boolean = cursor.findAny( { name: fileName } )

		if ( isFind )
		{

			cacheSize -= cursor.current.size;
			cursor.remove();

			try
			{

				cacheFolder.resolvePath( fileName ).deleteFile();
				isDone = true
			}
			catch ( error : Error )
			{
			}
		}

		return isDone;
	}

	private function get applicationPrefix() : String
	{

		if ( applicationId )
			return applicationId.substr( 0, 8 );
		else
			return "";
	}

	private function cleanupCache( size : uint ) : void
	{

		var newCacheSize : uint = cacheSize + size;

		if ( newCacheSize > CACHE_SIZE )
		{

			cachedFiles.sort = new Sort();
			cachedFiles.sort.fields = [ new SortField( "create" ) ];
			cachedFiles.refresh();

			var item : Object = {}

			while ( cacheSize > 10000 )
			{

				item = cachedFiles.getItemAt( 0 )

				cacheSize -= item.size;
				cachedFiles.removeItemAt( 0 );

				var removeFile : File = cacheFolder.resolvePath( item.name );
				try
				{
					removeFile.deleteFile();
				}
				catch ( error : Error )
				{

				}
			}

			cachedFiles.sort = new Sort();
			cachedFiles.sort.fields = [ new SortField( "name" ) ];
			cachedFiles.refresh();
		}
	}
}