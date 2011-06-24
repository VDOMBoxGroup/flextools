package net.vdombox.ide.core.model
{
	import flash.desktop.Icon;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Matrix;
	import flash.utils.ByteArray;
	
	import mx.binding.utils.BindingUtils;
	import mx.collections.ArrayCollection;
	import mx.controls.Image;
	import mx.effects.Resize;
	import mx.graphics.codec.PNGEncoder;
	import mx.resources.ResourceBundle;
	import mx.rpc.AsyncToken;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.soap.Operation;
	import mx.utils.Base64Decoder;
	import mx.utils.Base64Encoder;
	
	import net.vdombox.ide.common.vo.ApplicationVO;
	import net.vdombox.ide.common.vo.ResourceVO;
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.events.SOAPEvent;
	import net.vdombox.ide.core.model.business.SOAP;
	import net.vdombox.ide.core.model.icons.TypesIcons;
	
//	import org.osmf.utils.BinarySearch;
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;
	
	import spark.components.Application;

	/**
	 * ResourcesProxy is wrapper on VDOM Resources.   
	 * Takes data from the server through the SOAP functions.
	 * @author Alexey Andreev
	 * @see net.vdombox.ide.common.vo.ResourceVO
	 * @see net.vdombox.ide.core.model.business.SOAP
	 * @flowerModelElementId _DERy4EomEeC-JfVEe_-0Aw
	 */
	public class ResourcesProxy extends Proxy implements IProxy
	{
		public static const NAME : String = "ResourcesProxy";

		public function ResourcesProxy()
		{
			super( NAME, data );
		}
		
		override public function onRegister():void
		{
			if ( soap.ready )
				addHandlers();
			else
				soap.addEventListener( SOAPEvent.CONNECTION_OK, soap_connectedHandler, false, 0, true );
			
			soap.addEventListener( SOAPEvent.DISCONNECTON_OK, soap_disconnectedHandler );
		}
		
		override public function onRemove() : void
		{
			cleanup();
			
			removeHandlers();
		}
		
		private var soap : SOAP = SOAP.getInstance();
		
		private var cacheManager : CacheManager = CacheManager.getInstance();
		
		private var loadQue : Array;
		
		private var typesIcons : TypesIcons = new TypesIcons();

		public function deleteResource( applicationVO : ApplicationVO, resourceVO : ResourceVO ) : void
		{
			var token : AsyncToken = soap.delete_resource( applicationVO.id, resourceVO.id );
			
			token.recipientName = proxyName;
			token.resourceVO = resourceVO;
		}

		public function getListResources( applicationVO : ApplicationVO ) : void
		{
			var token : AsyncToken = soap.list_resources( applicationVO.id );
			
			token.recipientName = proxyName;
			token.applicationVO = applicationVO;
		}
		
		private function qqq( object : Object ) : void
		{
			if ( object )
			{				
				typesIcons.res.data = object as ByteArray;
				sendNotification( ApplicationFacade.RESOURCE_LOADED, typesIcons.res );
				typesIcons.res = null;
				typesIcons.data = null;
			}
		}

		public function loadResource( resourceVO : ResourceVO ) : void
		{		
			trace("++++++ loadResource ++++++");
			
			if ( resourceVO.type && !typesIcons.isViewable( resourceVO.type ) ) 
			{
				typesIcons.res = resourceVO;
				BindingUtils.bindSetter( qqq, typesIcons, "data" );
				typesIcons.getResource( resourceVO.type );	
				return;
			}
					
			var resource : ByteArray = cacheManager.getCachedFileById( resourceVO.id );
			
			//file is located in the file system user
			if ( resource )
			{
				resourceVO.setData( resource );
				resourceVO.setStatus( ResourceVO.LOADED );
				
				//choseIcon(resourceVO);   // неизвестен тип!!!
				
				sendNotification( ApplicationFacade.RESOURCE_LOADED, resourceVO );
			}
			//file must be downloaded from the server
			else
			{
				loadResourceFromServer( resourceVO );
			}
		}		
		
		private function loadResourceFromServer( resourceVO : ResourceVO ) : void
		{
			resourceVO.setStatus( ResourceVO.LOAD_PROGRESS );
			var token : AsyncToken = soap.get_resource( resourceVO.ownerID, resourceVO.id );
			
			token.recipientName = proxyName;
			token.resourceVO = resourceVO;
		}		

		public function setResource( resourceVO : ResourceVO ) : void
		{
			trace("+++++++++  setResource  ++++++++++");
			if ( !loadQue )
				loadQue = [];
			
			if ( loadQue.indexOf( resourceVO ) == -1 )
				loadQue.push( resourceVO );

			soap_setResource();
		}

		public function setResources( resources : Array ) : void
		{
			trace("+++++++++  setResources  ++++++++++");
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
		
		public function modifyResource( applicationVO : ApplicationVO, resourceVO : ResourceVO, attributeName : String, operation : String, attributes : XML ) : void
		{
			var token : AsyncToken = soap.modify_resource( applicationVO.id, resourceVO.ownerID, resourceVO.id, attributeName, operation, attributes );
			
			token.recipientName = proxyName;
			token.resourceVO = resourceVO;
		}

		public function cleanup() : void
		{
			loadQue = null;
		}
		
		public function getIcon( resourceVO : ResourceVO ) : void
		{
			choseIcon( resourceVO );
		}
		
		private function addHandlers() : void
		{
			soap.get_resource.addEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.get_resource.addEventListener( FaultEvent.FAULT, soap_faultHandler );
			
			soap.list_resources.addEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.list_resources.addEventListener( FaultEvent.FAULT, soap_faultHandler );

			soap.set_resource.addEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.set_resource.addEventListener( FaultEvent.FAULT, soap_faultHandler );

			soap.delete_resource.addEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.delete_resource.addEventListener( FaultEvent.FAULT, soap_faultHandler );
			
			soap.modify_resource.addEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.modify_resource.addEventListener( FaultEvent.FAULT, soap_faultHandler );
		}
		
		private function removeHandlers() : void
		{
			soap.get_resource.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.get_resource.removeEventListener( FaultEvent.FAULT, soap_faultHandler );
			
			soap.list_resources.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.list_resources.removeEventListener( FaultEvent.FAULT, soap_faultHandler );
			
			soap.set_resource.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.set_resource.removeEventListener( FaultEvent.FAULT, soap_faultHandler );
			
			soap.delete_resource.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.delete_resource.removeEventListener( FaultEvent.FAULT, soap_faultHandler );
			
			soap.modify_resource.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.modify_resource.removeEventListener( FaultEvent.FAULT, soap_faultHandler );
		}

		private function soap_connectedHandler( event : SOAPEvent ) : void
		{
			addHandlers();
		}
		
		private function soap_disconnectedHandler( event : SOAPEvent ) : void
		{
			
		}
		
		private function createResourcesList( applicationVO : ApplicationVO, resourcesXML : XML ) : Array
		{
			var resources : Array = [];
			var resource : ResourceVO;
			
			for each ( var resourceDescription : XML in resourcesXML.* )
			{
				resource = new ResourceVO( applicationVO.id );
				resource.setXMLDescription( resourceDescription );
			
//				choseIcon( resource );   здесь есть только описание, нет самих ресурсов
				
				resources.push( resource );
			}
			
			return resources;
		}
		
		private function choseIcon( resourceVO : ResourceVO ) : void
		{			
			if ( typesIcons.isViewable( resourceVO.type ) ) 
			{
				setIcon( resourceVO );
			}
			else // if not viewable
			{ 
				typesIcons.res = resourceVO;
				BindingUtils.bindSetter( aaa, typesIcons, "data" );
				typesIcons.getResource( resourceVO.type );				
			}	 
		}
		
		private function aaa( object : Object ) : void
		{
			if ( object )
			{
				creationIconCompleted( typesIcons.res, object as ByteArray );
				typesIcons.res = null;
				typesIcons.data = null;
			}
		}
		
		private function creationIconCompleted( resourceVO : ResourceVO, file:ByteArray ) : void
		{			
			resourceVO.icon		= file;
			resourceVO.iconId 	= resourceVO.id + "_icon";
			resourceVO.data 	= null;
			sendNotification( ApplicationFacade.ICON_GETTED, resourceVO );
		}
		
		private var tempResourceVO : Object = new Object(); //ResourceVO;
			
		//reduces the image and set it to icon of resourceVO
		private function setIcon( resourceVO : ResourceVO ) : void
		{
			var icon : ByteArray = cacheManager.getCachedFileById( resourceVO.id + "_icon" );
			
			//icon is located in the file system user
			if ( icon )
			{
				creationIconCompleted( resourceVO, icon );
			}	
			else
			{	
				loadableResources.addItem( resourceVO.id );
				loadResourceFromServer( resourceVO );
			}
		}
		
		private function loadedResourceForIcon( resourceVO : ResourceVO ) : void
		{
			loadableResources.removeItemAt( loadableResources.getItemIndex( resourceVO.id ) );
			
			tempResourceVO[ resourceVO.id ] = resourceVO ;
						
			var loader : Loader = new Loader();	
			loader.name = resourceVO.id;
			loader.loadBytes(resourceVO.data);				
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loaderComplete);
		}
		
		//convert to bitmapData 
		private function loaderComplete(event:Event):void
		{
			var loaderInfo : LoaderInfo = LoaderInfo(event.target);
			var bitmapData : BitmapData = new BitmapData(loaderInfo.width, loaderInfo.height, false, 0xFFFFFF);
			bitmapData.draw(loaderInfo.loader); 
			var bitmap:Bitmap = new Bitmap(bitmapData);
			
			if ( bitmap.height > ResourceVO.ICON_SIZE || bitmap.width > ResourceVO.ICON_SIZE )
			{
				var ratio:Number = 1; 
				if(bitmap.width >= bitmap.height) 
					ratio = ResourceVO.ICON_SIZE / bitmap.width; 
				else 
					ratio = ResourceVO.ICON_SIZE / bitmap.height; 
				
				var width :	int = ( int(bitmap.width*ratio) > 0 )  ? int(bitmap.width*ratio)  : 1;
				var height:	int = ( int(bitmap.height*ratio) > 0 ) ? int(bitmap.height*ratio) : 1;				
		
				var btm : BitmapData = new BitmapData( width, height, false); 
				bitmap.smoothing = true;
				
				var matrix : Matrix = new Matrix(); 
				matrix.scale(ratio, ratio); 
				btm.draw( bitmap.bitmapData, matrix );
				
				var encoder : PNGEncoder = new PNGEncoder();
								
				cacheManager.cacheFile( loaderInfo.loader.name + "_icon",  encoder.encode( btm ) );	// not nice			
				tempResourceVO[ loaderInfo.loader.name ].setStatus( ResourceVO.ICON_LOADED );
				
				creationIconCompleted( tempResourceVO[ loaderInfo.loader.name ], encoder.encode( btm ) );
			}
			else
			{
				var encoder1 : PNGEncoder = new PNGEncoder();
				creationIconCompleted( tempResourceVO[ loaderInfo.loader.name ], encoder1.encode( bitmap.bitmapData ) );
			}		
			
			delete tempResourceVO[ loaderInfo.loader.name ];
		}
	
		private function soap_setResource() : void
		{
			trace("+++ soap_setResource +++");
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

			trace("data.bytesAvailable = " + data.bytesAvailable );
			if ( !data || data.bytesAvailable == 0 )
				return;

			data.compress();

			data.position = 0;
			
			var base64Data : Base64Encoder = new Base64Encoder();
			base64Data.insertNewLines = false;
			base64Data.encodeBytes( data );

			resourceVO.setStatus( ResourceVO.UPLOAD_PROGRESS );
			
			var token : AsyncToken = soap.set_resource( resourceVO.ownerID, resourceVO.type, resourceVO.name, base64Data.toString());

			token.recipientName = proxyName;
			token.resourceVO = resourceVO;
		}

		private var loadableResources : ArrayCollection = new ArrayCollection;
		
		private function soap_resultHandler( event : SOAPEvent ) : void
		{
			var token : AsyncToken = event.token;
			
			if ( !token.hasOwnProperty( "recipientName" ) || token.recipientName != proxyName )
				return;
			
			var operation : Operation = event.currentTarget as Operation;
			var result : XML = event.result[ 0 ] as XML;
			
			if ( !operation || !result )
				return;
			
			var operationName : String = operation.name;
			var resourceVO : ResourceVO;
			
			switch ( operationName )
			{
				//save resource on user`s local disk and set resource to resourceVO
				case "get_resource":
				{
					//trace(" get_resource ");
					resourceVO = event.token.resourceVO as ResourceVO;
					
					var data : String = event.result.Resource;
					
					var decoder : Base64Decoder = new Base64Decoder();
					decoder.decode( data );
					
					var imageSource : ByteArray = decoder.toByteArray();
					
					imageSource.uncompress();
					
					cacheManager.cacheFile( resourceVO.id, imageSource );
					
					resourceVO.setData( imageSource );
					
					resourceVO.setStatus( ResourceVO.LOADED );
					
					if ( resourceForIcon( resourceVO.id ) )
						loadedResourceForIcon( resourceVO );
					else
						sendNotification( ApplicationFacade.RESOURCE_LOADED, resourceVO );
					
					break;
				}
				
				case "set_resource":
				{
					//trace("\n******************set_resource ******************");
					resourceVO = event.token.resourceVO as ResourceVO;

					resourceVO.setXMLDescription( result.Resource[ 0 ] );
					resourceVO.setStatus( ResourceVO.UPLOADED );
					
					sendNotification( ApplicationFacade.RESOURCE_SETTED, resourceVO );
					soap_setResource();

					break;
				}

				case "list_resources":
				{
					//trace("\n******************list_resources ******************");
					var applicationVO : ApplicationVO = event.token.applicationVO;
					var resources : Array = createResourcesList( applicationVO, result.Resources[ 0 ] );
					
					sendNotification( ApplicationFacade.RESOURCES_GETTED, resources );
					
					break;
				}
					
				case "delete_resource":
				{
					//trace("\n******************delete_resource ******************");
					resourceVO = event.token.resourceVO as ResourceVO;
					
					cacheManager.deleteFile( resourceVO.id );
					cacheManager.deleteFile( resourceVO.id + "_icon" );
					
					resourceVO.setData( null );
					resourceVO.setPath( null );
					
					sendNotification( ApplicationFacade.RESOURCE_DELETED, resourceVO );
					
					break;
				}
					
				case "modify_resource":
				{
					sendNotification( ApplicationFacade.RESOURCE_MODIFIED, token.resourceVO );
					
					break;
				}
			}
		}

		private function soap_faultHandler( event : FaultEvent ) : void
		{
			sendNotification( ApplicationFacade.SEND_TO_LOG, "ResourcesProxy | soap_faultHandler | " + event.currentTarget.name );
		}
		
		private function resourceForIcon( resourceId : String ) : Boolean
		{
			for each ( var iconID : String in loadableResources )
			{
				if ( iconID == resourceId )					
					return true
			}
			
			return false;
		}
	}
}

import flash.errors.IOError;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.utils.ByteArray;

import mx.collections.ArrayCollection;
import mx.collections.IViewCursor;
import mx.collections.Sort;
import mx.collections.SortField;

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