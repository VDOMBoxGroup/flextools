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
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
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
	
	import net.vdombox.ide.common.model._vo.ApplicationVO;
	import net.vdombox.ide.common.model._vo.ResourceVO;
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.events.SOAPEvent;
	import net.vdombox.ide.core.model.business.SOAP;
	import net.vdombox.ide.core.model.managers.CacheManager;
	import net.vdombox.ide.core.model.managers.IconManager;
	
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
		/**
		 *
		 * @default
		 */
		public static const NAME : String = "ResourcesProxy";

		/**
		 *
		 */
		public function ResourcesProxy()
		{
			super( NAME, data );
		}

		override public function onRegister() : void
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
		

//		private var loadableTypesIcons : ArrayCollection = new ArrayCollection();

		/**
		 *
		 * @param applicationVO
		 * @param resourceVO
		 */
		public function deleteResource( applicationVO : ApplicationVO, resourceVO : ResourceVO ) : void
		{
			
			var token : AsyncToken = soap.delete_resource( applicationVO.id, resourceVO.id );

			token.recipientName = proxyName;
			token.resourceVO = resourceVO;
		}

		/**
		 *
		 * @param applicationVO
		 */
		public function getListResources( applicationVO : ApplicationVO ) : void
		{
			
			var token : AsyncToken = soap.list_resources( applicationVO.id );

			token.recipientName = proxyName;
			token.applicationVO = applicationVO;
		}


		/**
		 *
		 * @param resourceVO
		 */
		public function loadResource( resourceVO : ResourceVO ) : void
		{

			var resource : ByteArray = cacheManager.getCachedFileById( resourceVO.id );

			//file is located in the file system user
			if ( resource && resource.length > 0 )
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

//		private var timeoutGetResource : uint;
		private function loadResourceFromServer( resourceVO : ResourceVO ) : void
		{
			resourceVO.setStatus( ResourceVO.LOAD_PROGRESS );

			getResourceFromServer( resourceVO );
		}

		private function getResourceFromServer( resourceVO : ResourceVO ) : void
		{
			
			var token : AsyncToken = soap.get_resource( resourceVO.ownerID, resourceVO.id );

			token.recipientName = proxyName;
			token.resourceVO = resourceVO;
		}

		/**
		 *
		 * @param resourceVO
		 */
		public function setResource( resourceVO : ResourceVO ) : void
		{
			if ( !loadQue )
				loadQue = [];

			if ( loadQue.indexOf( resourceVO ) == -1 )
				loadQue.push( resourceVO );

			soap_setResource();
		}

		/**
		 *
		 * @param resources
		 */
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

		/**
		 *
		 * @param applicationVO
		 * @param resourceVO
		 * @param attributeName
		 * @param operation
		 * @param attributes
		 */
		public function modifyResource( applicationVO : ApplicationVO, resourceVO : ResourceVO, attributeName : String, operation : String, attributes : XML ) : void
		{
			var token : AsyncToken = soap.modify_resource( applicationVO.id, resourceVO.ownerID, resourceVO.id, attributeName, operation, attributes );

			token.recipientName = proxyName;
			token.resourceVO = resourceVO;
		}

		/**
		 *
		 */
		public function cleanup() : void
		{
			loadQue = null;
		}

		/**
		 *
		 * @param resourceVO
		 */
		public function getIcon( resourceVO : ResourceVO ) : void
		{
			var iconManager : IconManager = new IconManager( resourceVO );
			iconManager.addEventListener( "loadResourceRequest", loadResourceRequestHandler )
			iconManager.setIconForResourceVO();

			function loadResourceRequestHandler( event : Event ) : void
			{
				var rIconManager : IconManager = event.target as IconManager;
				var resourceVO : ResourceVO = rIconManager.resourceVO;
				
				resourceVO.setStatus(ResourceVO.LOAD_ICON);
				
				getResourceFromServer( rIconManager.resourceVO );
			}

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

		}


		private function creationIconCompleted( resourceVO : ResourceVO, file : ByteArray ) : void
		{
			if ( !resourceVO )
				return;

			resourceVO.icon = file;
//			resourceVO.iconId 	= resourceVO.id + "_icon";
			resourceVO.setData( null);
			sendNotification( ApplicationFacade.ICON_GETTED, resourceVO );
		}

		private var tempResourceVO : Object = new Object(); //ResourceVO;


		//reduces the image and set it to icon of resourceVO
		private function setIcon( resourceVO : ResourceVO ) : void
		{
			var cachedIcon : ByteArray = cacheManager.getCachedFileById( resourceVO.iconId );

			//icon is located in the file system user
			if ( cachedIcon )
			{
				resourceVO.icon = cachedIcon;
			}
			else
			{
//				loadableResources.addItem( resourceVO.id );
				loadResourceFromServer( resourceVO );
			}

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

			resourceVO.setStatus( ResourceVO.UPLOAD_PROGRESS );
			
			var token : AsyncToken = soap.set_resource( resourceVO.ownerID, resourceVO.type, resourceVO.name, base64Data.toString() );

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
			
			if ( result.hasOwnProperty( "Error" ) )
			{
				//sendNotification( ApplicationFacade.WRITE_ERROR, result.Error.toString() );
				return;
			}

			var operationName : String = operation.name;
			var resourceVO : ResourceVO;

			switch ( operationName )
			{

				//save resource on user`s local disk and set resource to resourceVO
				case "get_resource":
				{
					resourceVO = event.token.resourceVO as ResourceVO;

					var data : String = event.result.Resource;
					
					var decoder : Base64Decoder = new Base64Decoder();
					decoder.decode( data );

					var imageSource : ByteArray = decoder.toByteArray();

					imageSource.uncompress();
					// TODO: resourceVO.icon = img
					cacheManager.cacheFile( resourceVO.id, imageSource );

					resourceVO.setData( imageSource );
					
					if (resourceVO.status == ResourceVO.LOAD_ICON)
					{
						var iconManager : IconManager = new IconManager(resourceVO);
						iconManager.setIconForResourceVO();
					}

					resourceVO.setStatus( ResourceVO.LOADED );

					resourceVO.icon = null;


					sendNotification( ApplicationFacade.RESOURCE_LOADED, resourceVO );

					break;
				}

				case "set_resource":
				{
					resourceVO = event.token.resourceVO as ResourceVO;

					resourceVO.setXMLDescription( result.Resource[ 0 ] );
					resourceVO.setStatus( ResourceVO.UPLOADED );

					sendNotification( ApplicationFacade.RESOURCE_SETTED, resourceVO );
				
					soap_setResource();

					break;
				}

				case "list_resources":
				{
					var applicationVO : ApplicationVO = event.token.applicationVO;
					var resources : Array = createResourcesList( applicationVO, result.Resources[ 0 ] );

					sendNotification( ApplicationFacade.RESOURCES_GETTED, resources );

					break;
				}

				case "delete_resource":
				{
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
			var token : AsyncToken = event.token;
			
			if ( !token.hasOwnProperty( "recipientName" ) || token.recipientName != proxyName )
				return;
			
			var operation : Operation = event.currentTarget as Operation;
			
			
			var operationName : String = operation.name;
			var resourceVO : ResourceVO;

			switch ( operationName )
			{
				case "get_resource":
				{
					resourceVO = event.token.resourceVO as ResourceVO;
					resourceVO.setData( null );
//					soap_setResource();
					break;
				}
			}

			sendNotification( ApplicationFacade.SEND_TO_LOG, "ResourcesProxy | soap_faultHandler | " + event.currentTarget.name );
			//sendNotification( ApplicationFacade.WRITE_ERROR, event.fault.faultString );
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
