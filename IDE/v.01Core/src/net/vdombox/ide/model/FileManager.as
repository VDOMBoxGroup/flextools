package vdom.managers
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.ByteArray;

	import mx.rpc.events.FaultEvent;
	import mx.utils.Base64Decoder;
	import mx.utils.Base64Encoder;

	import vdom.connection.SOAP;
	import vdom.events.DataManagerEvent;
	import vdom.events.FileManagerEvent;
	import vdom.events.SOAPEvent;

	public class FileManager implements IEventDispatcher
	{
		private static var instance : FileManager;

		private var dispatcher : EventDispatcher = new EventDispatcher();
		private var soap : SOAP = SOAP.getInstance();

		private var requestQue : Object = {};
		private var _resourceStorage : Object = {};

		private var dataManager : DataManager = DataManager.getInstance();
		private var cacheManager : CacheManager = CacheManager.getInstance();

		private var applicationId : String;

		/**
		 *
		 * @return instance of ResourceManager class (Singleton)
		 *
		 */
		public static function getInstance() : FileManager
		{
			if ( !instance )
			{

				instance = new FileManager();
			}

			return instance;
		}

		/**
		 *
		 * Constructor
		 *
		 */
		public function FileManager()
		{
			if ( instance )
				throw new Error( "Instance already exists." );
		}

		public function init() : void
		{
			registerEvent( true );
		}

		public function getListResources( ownerId : String = "" ) : void
		{
			if ( ownerId == "" )
				ownerId = dataManager.currentApplicationId;

			soap.list_resources( ownerId );
		}

		public function setResource( resType : String, resName : String, resData : ByteArray,
									 applicationId : String = '' ) : void
		{
			resData.compress();

			var base64Data : Base64Encoder = new Base64Encoder();
			base64Data.insertNewLines = false;
			base64Data.encodeBytes( resData );

			if ( !applicationId )
				applicationId = dataManager.currentApplicationId;

			soap.set_resource( applicationId, resType, resName, base64Data.toString() );
		}

		public function loadResource( ownerID : String, resourceID : String, destTarget : Object,
									  property : String = 'resource', raw : Boolean = false ) : void
		{
			if ( !resourceID )
				return;

			var result : ByteArray = cacheManager.getCachedFileById( resourceID );

			if ( result )
			{
				if ( raw )
					destTarget[ property ] = result;
				else
					destTarget[ property ] = { resourceID: resourceID, data: result }
				return;
			}

			if ( !requestQue[ resourceID ] )
			{
				requestQue[ resourceID ] = new Array();
				soap.get_resource( ownerID, resourceID );
			}

			requestQue[ resourceID ].push( { object: destTarget, property: property, raw: raw } );
		}

		public function deleteResource( resourceID : String ) : void
		{
			soap.delete_resource( dataManager.currentApplicationId, resourceID );
		}

		private function registerEvent( flag : Boolean ) : void
		{
			if ( flag )
			{
				soap.list_resources.addEventListener( SOAPEvent.RESULT, listResourcesHandler );

				soap.get_resource.addEventListener( SOAPEvent.RESULT, resourceLoadedHandler );
				soap.get_resource.addEventListener( FaultEvent.FAULT, resourceLoadedErrorHandler );

				soap.set_resource.addEventListener( SOAPEvent.RESULT, setResourceOkHandler );
				soap.set_resource.addEventListener( FaultEvent.FAULT, setResourceErrorHandler );

				soap.delete_resource.addEventListener( SOAPEvent.RESULT, soap_deleteResourceHandler );

				dataManager.addEventListener( DataManagerEvent.LOAD_APPLICATION_COMPLETE,
											  dataManager_loadApplicationCompleteHandler );
			}
			else
			{
				soap.list_resources.removeEventListener( SOAPEvent.RESULT, listResourcesHandler );

				soap.get_resource.removeEventListener( SOAPEvent.RESULT, resourceLoadedHandler );
				soap.get_resource.removeEventListener( FaultEvent.FAULT, resourceLoadedErrorHandler );

				soap.set_resource.removeEventListener( SOAPEvent.RESULT, setResourceOkHandler );
				soap.set_resource.removeEventListener( FaultEvent.FAULT, setResourceErrorHandler );

				soap.delete_resource.removeEventListener( SOAPEvent.RESULT, soap_deleteResourceHandler );
			}
		}

		private function listResourcesHandler( event : SOAPEvent ) : void
		{
			var fle : FileManagerEvent = new FileManagerEvent( FileManagerEvent.RESOURCE_LIST_LOADED )
			fle.result = event.result;
			dispatchEvent( fle );
		}



		private function resourceLoadedHandler( event : SOAPEvent ) : void
		{
			var resourceID : String = event.result.ResourceID;
			var resource : String = event.result.Resource;

			var decoder : Base64Decoder = new Base64Decoder();
			decoder.decode( resource );

			var imageSource : ByteArray = decoder.toByteArray();

			imageSource.uncompress();

			cacheManager.cacheFile( resourceID, imageSource );

			imageSource.position = 0;
			_resourceStorage[ resourceID ] = imageSource;

			for each ( var item : Object in requestQue[ resourceID ] )
			{
				var data : ByteArray = new ByteArray();
				_resourceStorage[ resourceID ].readBytes( data );
				_resourceStorage[ resourceID ].position = 0;

				var requestObject : Object = item.object;
				var requestProperty : String = item.property;

				if ( item.raw )
					requestObject[ requestProperty ] = data;
				else
					requestObject[ requestProperty ] = { resourceID: resourceID, data: data };
			}

			delete requestQue[ resourceID ];

			var fme : FileManagerEvent = new FileManagerEvent( FileManagerEvent.RESOURCE_LOADING_OK );
			fme.result = event.result;
			dispatchEvent( fme );
		}

		private function resourceLoadedErrorHandler( event : FaultEvent ) : void
		{
			var faultDetail : XML = new XML( event.fault.faultDetail );
			var resourceID : String = faultDetail.ResourceID[ 0 ];

			for each ( var item : Object in requestQue[ resourceID ] )
			{

				var requestObject : Object = item.object;
				var requestProperty : String = item.property;

				if ( item.raw )
					requestObject[ requestProperty ] = null;
				else
					requestObject[ requestProperty ] = { resourceID: resourceID, data: null };
			}

			if ( requestQue[ resourceID ] )
				delete requestQue[ resourceID ];

			var fme : FileManagerEvent = new FileManagerEvent( FileManagerEvent.RESOURCE_LOADING_ERROR );
//	fme.result = event.result;
			dispatchEvent( fme );
		}



		private function setResourceOkHandler( event : SOAPEvent ) : void
		{
			var fme : FileManagerEvent = new FileManagerEvent( FileManagerEvent.RESOURCE_SAVED )
			fme.result = event.result;
			dispatchEvent( fme );
		}

		private function setResourceErrorHandler( event : FaultEvent ) : void
		{
			var fme : FileManagerEvent = new FileManagerEvent( FileManagerEvent.RESOURCE_SAVED_ERROR )
//	fme.result = event.result;
			dispatchEvent( fme );
		}

		private function soap_deleteResourceHandler( event : SOAPEvent ) : void
		{
			var resourceID : String;

			try
			{
				resourceID = event.result.Resource[ 0 ].toString();
			}
			catch ( error : Error )
			{
			}

			if ( resourceID == null )
				return;

			cacheManager.deleteFile( resourceID );


			var fme : FileManagerEvent = new FileManagerEvent( FileManagerEvent.RESOURCE_DELETED );
			fme.result = event.result;
			dispatchEvent( fme );
		}

		private function dataManager_loadApplicationCompleteHandler( event : DataManagerEvent ) : void
		{
			getListResources();
		}

		// Реализация диспатчера

		/**
		 *  @private
		 */
		public function addEventListener( type : String, listener : Function, useCapture : Boolean = false,
										  priority : int = 0, useWeakReference : Boolean = false ) : void
		{
			dispatcher.addEventListener( type, listener, useCapture, priority );
		}

		/**
		 *  @private
		 */
		public function dispatchEvent( evt : Event ) : Boolean
		{
			return dispatcher.dispatchEvent( evt );
		}

		/**
		 *  @private
		 */
		public function hasEventListener( type : String ) : Boolean
		{
			return dispatcher.hasEventListener( type );
		}

		/**
		 *  @private
		 */
		public function removeEventListener( type : String, listener : Function,
											 useCapture : Boolean = false ) : void
		{
			dispatcher.removeEventListener( type, listener, useCapture );
		}

		/**
		 *  @private
		 */
		public function willTrigger( type : String ) : Boolean
		{
			return dispatcher.willTrigger( type );
		}
	}
}