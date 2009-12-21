package net.vdombox.ide.core.model
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;

	import mx.rpc.AsyncToken;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.soap.Operation;
	import mx.utils.Base64Encoder;

	import net.vdombox.ide.common.vo.ApplicationVO;
	import net.vdombox.ide.common.vo.ResourceVO;
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.events.SOAPEvent;
	import net.vdombox.ide.core.model.business.SOAP;

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

		private var loadQue : Array;

		public function deleteResource( resourceID : String ) : void
		{
			soap.delete_resource( resourceID );
		}

		public function getListResources( applicationVO : ApplicationVO ) : void
		{
			soap.list_resources( applicationVO.id );
		}

		public function getResource( ownerID : String, resourceID : String ) : ResourceVO
		{
			if ( !resourceID )
				return null;

			var resourceVO : ResourceVO = new ResourceVO();
			resourceVO.ownerID = ownerID;
			resourceVO.resourceID = resourceID;

			var resource : Resource = new Resource( resourceVO );
			resource.load();

			return resourceVO;
		}

		public function setResource( resourceVO : ResourceVO ) : void
		{
			if ( !loadQue )
				loadQue = [];
			
			if ( loadQue.indexOf( resourceVO ) != -1 )
				loadQue.push( resourceVO );

			soap_setResource();
		}

		public function setResources( resources : Array ) : void
		{
			if ( !resources || resources.length == 0 )
				return;

			if ( !loadQue )
				loadQue = [];

			if ( loadQue.length == 0 )
			{
				loadQue = loadQue.concat( resources );
			}
			else
			{
				for ( var i : int = 0; i < resources.length; i++ )
				{
					var resourceVO : ResourceVO = resources[ i ];

					if ( loadQue.indexOf( resourceVO ) != -1 )
						loadQue.push( resourceVO );
				}
			}

			soap_setResource();
		}

		private function addEventListeners() : void
		{
			soap.list_resources.addEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.list_resources.addEventListener( FaultEvent.FAULT, soap_faultHandler );

			soap.set_resource.addEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.set_resource.addEventListener( FaultEvent.FAULT, soap_faultHandler );

			soap.delete_resource.addEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.delete_resource.addEventListener( FaultEvent.FAULT, soap_faultHandler );
		}

		private function createResourcesList( resources : XML ) : Array
		{
			var d : * = "";

			return [];
		}

		private function soap_setResource() : void
		{
			if ( loadQue.length == 0 )
				return;

			var resourceVO : ResourceVO = loadQue.shift() as ResourceVO;
			var data : ByteArray;

			if ( resourceVO.data )
			{
				data = resourceVO.data;
			}
			else if ( resourceVO.path )
			{
				var file : File = File.applicationDirectory;
				file = file.resolvePath( resourceVO.path );

				if ( !file || !file.exists )
					return;

				var fileStream : FileStream = new FileStream();
				data = new ByteArray();

				try
				{
					fileStream.open( file, FileMode.READ );
					fileStream.readBytes( data );
				}
				catch ( error : Error )
				{
					return;
				}
			}

			if ( !data || data.bytesAvailable == 0 )
				return;

			data.compress();

			data.position = 0;
			
			var base64Data : Base64Encoder = new Base64Encoder();
			base64Data.insertNewLines = false;
			base64Data.encodeBytes( data );

			var asyncToken : AsyncToken = soap.set_resource( resourceVO.ownerID, resourceVO.type, resourceVO.name, base64Data.toString());

			asyncToken.resourceVO = resourceVO;
		}

		private function soap_resultHandler( event : SOAPEvent ) : void
		{
			var operation : Operation = event.currentTarget as Operation;
			var result : XML = event.result[ 0 ] as XML;

			if ( !operation || !result )
				return;

			var operationName : String = operation.name;

			switch ( operationName )
			{
				case "set_resource":
				{
					var resourceVO : ResourceVO;

					if ( event.token && event.token.resourceVO )
						resourceVO = event.token.resourceVO as ResourceVO;
					else
						resourceVO = new ResourceVO;

					var id : String = result.Resource.@id.toString();

					if ( id == "" )
						return;

					resourceVO.resourceID = id;

					sendNotification( ApplicationFacade.RESOURCE_SETTED, resourceVO );
					soap_setResource();

					break;
				}

				case "list_resources":
				{

					createResourcesList( <a/> );
					sendNotification( ApplicationFacade.RESOURCES_GETTED );
					break;
				}
			}
		}

		private function soap_faultHandler( event : FaultEvent ) : void
		{
			sendNotification( ApplicationFacade.SEND_TO_LOG, "ResourcesProxy | soap_faultHandler | " + event.currentTarget.name );
		}
	}
}

import flash.errors.IOError;
import flash.events.Event;
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

import net.vdombox.ide.common.vo.ResourceVO;
import net.vdombox.ide.core.events.SOAPEvent;
import net.vdombox.ide.core.model.business.SOAP;

class Resource
{
	public function Resource( resourceVO : ResourceVO )
	{
		_resourceVO = resourceVO;
	}

	private var _resourceVO : ResourceVO;

	private var cacheManager : CacheManager = CacheManager.getInstance();

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
			_resourceVO.data = resource;
			_resourceVO.status = "loaded";

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

		_resourceVO.data = imageSource;
		_resourceVO.status = "loaded";
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