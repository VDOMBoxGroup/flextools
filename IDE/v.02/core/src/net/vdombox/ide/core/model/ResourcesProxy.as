package net.vdombox.ide.core.model
{
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.utils.ByteArray;
	
	import mx.rpc.events.FaultEvent;
	import mx.utils.Base64Encoder;
	
	import net.vdombox.ide.core.events.SOAPEvent;
	import net.vdombox.ide.core.model.business.SOAP;
	import net.vdombox.ide.core.model.vo.ResourceVO;
	
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;

	public class ResourcesProxy extends Proxy implements IProxy
	{
		public static const NAME : String = "ResourcesProxy";

		public function ResourcesProxy( data : Object = null )
		{
			super( NAME, data );

			addEventListeners();
		}

		private var soap : SOAP = SOAP.getInstance();

		public function deleteResource( resourceID : String ) : void
		{
			soap.delete_resource( resourceID );
		}


		public function getListResources( applicatioID : String ) : void
		{
			soap.list_resources( applicatioID );
		}

		public function getResource( ownerID : String, resourceID : String ) : ResourceVO
		{
			if ( !resourceID )
				return null;

			var resourceVO : ResourceVO = new ResourceVO( ownerID, resourceID );
			
			var resource : Resource = new Resource( resourceVO );
			resource.load();
			
			return resourceVO;
		}

		public function setResource( name : String, data : ByteArray, type : String, applicationID : String ) : void
		{
			data.compress();

			var base64Data : Base64Encoder = new Base64Encoder();
			base64Data.insertNewLines = false;
			base64Data.encodeBytes( data );

			soap.set_resource( applicationID, type, name, base64Data.toString());
		}

		private function addEventListeners() : void
		{
			soap.list_resources.addEventListener( SOAPEvent.RESULT, listResourcesHandler );

			soap.set_resource.addEventListener( SOAPEvent.RESULT, setResourceOKHandler );
			soap.set_resource.addEventListener( FaultEvent.FAULT, setResourceFaultHandler );

			soap.delete_resource.addEventListener( SOAPEvent.RESULT, deleteResourceOKHandler );
			soap.set_resource.addEventListener( FaultEvent.FAULT, deleteResourceFaultHandler );
		}

		private function deleteResourceFaultHandler( event : FaultEvent ) : void
		{

		}

		private function deleteResourceOKHandler( event : SOAPEvent ) : void
		{

		}

		private function listResourcesHandler( event : SOAPEvent ) : void
		{

		}

		private function resourceLoadedFaultHandler( event : FaultEvent ) : void
		{

		}

		private function resourceLoadedOKHandler( event : SOAPEvent ) : void
		{

		}

		private function setResourceFaultHandler( event : FaultEvent ) : void
		{

		}

		private function setResourceOKHandler( event : SOAPEvent ) : void
		{

		}
		
		private function resource_loadCompleteHandler( event : Event ) : void
		{
			var d : * = "";
		}
		
		private function resource_loadErrorHandler( event : Event ) : void
		{
			var d : * = "";
		}
	}
}

import flash.errors.IOError;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.utils.ByteArray;

import mx.collections.ArrayCollection;
import mx.collections.IViewCursor;
import mx.collections.Sort;
import mx.collections.SortField;
import mx.rpc.events.FaultEvent;
import mx.utils.Base64Decoder;

import net.vdombox.ide.core.events.SOAPEvent;
import net.vdombox.ide.core.model.business.SOAP;
import net.vdombox.ide.core.model.vo.ResourceVO;

class Resource
{
	public function Resource( resourceVO : ResourceVO )
	{
		_resourceVO = resourceVO;
	}

	private var _resourceVO : ResourceVO;

	private var cacheManager : CacheManager = CacheManager.getInstance();

	private var dispatcher : EventDispatcher = new EventDispatcher( IEventDispatcher( this ));

	private var soap : SOAP = SOAP.getInstance();

	public function get resourceVO() : ResourceVO
	{
		return _resourceVO;
	}
	
	public function load() : void
	{
		var resource : ByteArray = cacheManager.getCachedFileById( _resourceVO.resourceID );
		if ( resource )
		{
			_resourceVO.setData( resource );
			_resourceVO.setStatus( "loaded" );
			
			return;
		}
		
		soap.get_resource.addEventListener( SOAPEvent.RESULT, resourceLoadedOKHandler );
		soap.get_resource.addEventListener( FaultEvent.FAULT, resourceLoadedFaultHandler );
		
		soap.get_resource( _resourceVO.ownerID, _resourceVO.resourceID );
	}
	
	private function resourceLoadedOKHandler( event : SOAPEvent ) : void
	{
		var resourceID : String = event.result.ResourceID;
		var data : String = event.result.Resource;

		var decoder : Base64Decoder = new Base64Decoder();
		decoder.decode( data );

		var imageSource : ByteArray = decoder.toByteArray();

		imageSource.uncompress();

		cacheManager.cacheFile( resourceID, imageSource );
		
		_resourceVO.setData( imageSource );
		_resourceVO.setStatus( "loaded" );
	}
	
	private function resourceLoadedFaultHandler( event : FaultEvent ) : void
	{
		var dummy : * = ""; // FIXME remove dummy
	}
}

class CacheManager
{

	private static var instance : CacheManager;

	public static function getInstance() : CacheManager
	{
		if ( !instance )
			instance = new CacheManager();

		return instance;
	}

	public function CacheManager()
	{
		if ( instance )
			throw new Error( "Instance already exists." );

		init();
	}

	private const CACHE_SIZE : uint = 100000000;

	private var applicationId : String;

	private var cacheFolder : File;

	private var cacheSize : int;

	private var cachedFiles : ArrayCollection = new ArrayCollection();

	private var cursor : IViewCursor;

	private var fileStream : FileStream = new FileStream();

	public function cacheFile( contentName : String, content : ByteArray ) : void
	{

		var fileSize : uint = content.bytesAvailable;

		if ( fileSize > 90000000 )
			return;

		var newFileName : String = contentName;

		if ( cursor.findAny({ name: applicationPrefix + "" + contentName }))
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

		cachedFiles.addItem({ create: newFile.creationDate.time, name: newFile.name, size: newFile.size })
	}

	public function deleteFile( fileName : String ) : Boolean
	{
		var isDone : Boolean = false;

		fileName = applicationPrefix + fileName;

		var isFind : Boolean = cursor.findAny({ name: fileName })

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

	public function getCachedFileById( resourceId : String ) : ByteArray
	{

		var fileName : String = resourceId;

		var result : Boolean = cursor.findFirst({ name: fileName });
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

	public function init() : void
	{
		cursor = cachedFiles.createCursor();

		cachedFiles.sort = new Sort();
		cachedFiles.sort.fields = [ new SortField( "name" )];
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

			var days : Number = ( currentDate - file.creationDate.time ) / 1000 / 60 / 60 / 24;
			if ( days > 4 )
			{
				file.deleteFile();
				continue;
			}

			cacheSize += file.size;
			cachedFiles.addItem({ create: file.creationDate.time, name: file.name, size: file.size });
		}
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
			cachedFiles.sort.fields = [ new SortField( "create" )];
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
			cachedFiles.sort.fields = [ new SortField( "name" )];
			cachedFiles.refresh();
		}
	}
}