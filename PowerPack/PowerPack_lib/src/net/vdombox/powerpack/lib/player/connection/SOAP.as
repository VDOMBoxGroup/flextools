package net.vdombox.powerpack.lib.player.connection
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
	
	import mx.resources.IResourceManager;
	import mx.resources.ResourceManager;
	import mx.rpc.AsyncToken;
	import mx.rpc.Fault;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.soap.LoadEvent;
	import mx.rpc.soap.Operation;
	import mx.rpc.soap.SOAPFault;
	import mx.rpc.soap.WebService;
	
	import net.vdombox.powerpack.lib.player.connection.protect.Code;
	import net.vdombox.powerpack.lib.player.events.SOAPErrorEvent;

	

	public dynamic class SOAP extends Proxy implements IEventDispatcher
	{
		private static var instance : SOAP;

		public static function getInstance() : SOAP
		{
			if ( !instance )
				instance = new SOAP();

			return instance;
		}

		private var webService : WebService;

		private var dispatcher : EventDispatcher = new EventDispatcher();

		private var code : Code = Code.getInstance();

		private var resourceManager : IResourceManager = ResourceManager.getInstance();

		private var isLoadWSDLProcess : Boolean;

		public function SOAP()
		{
			if ( instance )
				throw new Error( "Singleton and can only be accessed through Soap.anyFunction()" );
		}

		public function get ready() : Boolean
		{
			return webService ? webService.ready : false;
		}

		public function connect( wsdl : String ) : void
		{
			webService = new WebService();

			webService.wsdl = wsdl;
			webService.useProxy = false;
			webService.requestTimeout = 59;

			webService.addEventListener( LoadEvent.LOAD, loadHandler );
			webService.addEventListener( FaultEvent.FAULT, faultHandler );

			isLoadWSDLProcess = true;

			webService.loadWSDL();
		}

		public function disconnect() : void
		{
			if ( webService )
				webService.disconnect();

			dispatchEvent( new SOAPEvent( SOAPEvent.DISCONNECTON_OK ) );
		}

		public function logon( username : String, password : String ) : AsyncToken
		{
			webService.open_session.addEventListener( ResultEvent.RESULT, logonCompleteHandler );
			webService.open_session.addEventListener( FaultEvent.FAULT, logonErrorHandler );

			return webService.open_session( username, password );
		}

		public function logout() : AsyncToken
		{
			return webService.close_session( code.sessionId );
		}

		override flash_proxy function getProperty( name : * ) : *
		{
			var functionName : String = getLocalName( name );

			if ( functionName )
				return webService.getOperation( functionName );
			else
				return null;
		}

		override flash_proxy function setProperty( name : *, value : * ) : void
		{
			var message : String = resourceManager.getString( "rpc", "operationsNotAllowedInService", [ getLocalName( name ) ] );
			throw new Error( message );
		}

		override flash_proxy function callProperty( name : *, ... args : Array ) : *
		{
			var functionName : String = getLocalName( name );
			var operation : Operation = webService.getOperation( functionName ) as Operation;
			var key : String = code.nextSessionKey;
			var token : AsyncToken;

			args.unshift( code.sessionId, key );
			operation.addEventListener( ResultEvent.RESULT, operationResultHandler );
//			operation.addEventListener( FaultEvent.FAULT, operationFaultHandler );

			token = operation.send.apply( null, args );
			token.key = key;
			
			if ( !ready )
			{
				var fault : Fault = new Fault( "No server connection", "Login to server" ) ;
				operation.dispatchEvent( FaultEvent.createEvent( fault, token ) );
			}

			return token;
		}

		private function getLocalName( name : Object ) : String
		{
			if ( name is QName )
				return QName( name ).localName;
			else
				return String( name );
		}

		private function loadHandler( event : LoadEvent ) : void
		{
			isLoadWSDLProcess = false;
			dispatchEvent( new SOAPEvent( SOAPEvent.CONNECTION_OK ) );
		}

		private function faultHandler( event : FaultEvent ) : void
		{
			
			
				//не зашли в редактирование
				var faultEvent : FaultEvent = FaultEvent.createEvent( event.fault, null, event.message );
				dispatchEvent( faultEvent );
			
		}

		private function logonCompleteHandler( event : ResultEvent ) : void
		{
			var resultXML : XML = new XML( <Result/> );
			resultXML.appendChild( XMLList( event.result ) );

			code.initialize( resultXML.Session.HashString, resultXML.Session.SessionKey );
			code.sessionId = resultXML.Session.SessionId;

			var see : SOAPEvent = new SOAPEvent( SOAPEvent.LOGIN_OK );
			see.result = resultXML;

			dispatchEvent( see );
		}

		private function logonErrorHandler( event : FaultEvent ) : void
		{
			if ( event.fault is SOAPFault )
			{
				var see : SOAPErrorEvent = new SOAPErrorEvent( SOAPErrorEvent.LOGIN_ERROR );

				see.faultCode = event.fault.faultCode;
				see.faultString = event.fault.faultString;
				see.faultDetail = event.fault.faultDetail;

				dispatchEvent( see );
			}
			else if ( event.fault is Fault )
			{
				webService.dispatchEvent( FaultEvent.createEvent( event.fault, event.token, event.message ) );
			}
		}

		private function logoffCompleteHandler( event : ResultEvent ) : void
		{
			var see : SOAPEvent = new SOAPEvent( SOAPEvent.LOGOFF_OK );
			dispatchEvent( see );
		}

		private function logoffErrorHandler( event : FaultEvent ) : void
		{
			if ( event.fault is SOAPFault )
			{
				var see : SOAPErrorEvent = new SOAPErrorEvent( SOAPErrorEvent.LOGIN_ERROR );
				see.faultCode = event.fault.faultCode;
				see.faultString = event.fault.faultString;
				see.faultDetail = event.fault.faultDetail;
				dispatchEvent( see );
			}
			else if ( event.fault is Fault )
			{
				webService.dispatchEvent( FaultEvent.createEvent( event.fault, event.token, event.message ) );
			}
		}

		private function operationResultHandler( event : ResultEvent ) : void
		{
			var resultXML : XML = new XML( <Result/> );

			try
			{
				resultXML.appendChild( XMLList( event.result ) );
			}
			catch ( error : Error )
			{
				////trace( "\n\n*********  XML ERROR: *************\n" + event.result )
				var faultEvent : FaultEvent = FaultEvent.createEvent( new Fault( "i101", "Parse XML data error" ) );
				faultHandler( faultEvent );
				return;
			}

			var soapEvent : SOAPEvent = new SOAPEvent( SOAPEvent.RESULT );
			soapEvent.result = resultXML;
			soapEvent.token = event.token;

			event.target.dispatchEvent( soapEvent );
		}

		private function operationFaultHandler( event : FaultEvent ) : void
		{
			trace("SOAP.operationFaultHandler(...) " + event.type);
//			faultHandler( event );
		}

		// Реализация диспатчера

		/**
		 *  @private
		 */
		public function addEventListener( type : String, listener : Function, useCapture : Boolean = false, priority : int = 0, useWeakReference : Boolean = false ) : void
		{
			dispatcher.addEventListener( type, listener, useCapture, priority );
		}

		/**
		 *  @private
		 */
		public function dispatchEvent( event : Event ) : Boolean
		{
			trace("SOAP.dispathEvent(...) " + event.type)
			return dispatcher.dispatchEvent( event );
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
		public function removeEventListener( type : String, listener : Function, useCapture : Boolean = false ) : void
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
