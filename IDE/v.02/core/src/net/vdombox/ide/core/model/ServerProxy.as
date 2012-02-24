package net.vdombox.ide.core.model
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.events.StateChangeEvent;
	import mx.rpc.AsyncToken;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.soap.Operation;
	
	import net.vdombox.editors.AssistMenu;
	import net.vdombox.ide.common.model._vo.ApplicationInformationVO;
	import net.vdombox.ide.common.model._vo.ApplicationVO;
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.controller.RetrieveModuleSettings;
	import net.vdombox.ide.core.events.SOAPErrorEvent;
	import net.vdombox.ide.core.events.SOAPEvent;
	import net.vdombox.ide.core.model.business.SOAP;
	import net.vdombox.ide.core.model.vo.AuthInfoVO;
	import net.vdombox.ide.core.model.vo.ErrorVO;
	import net.vdombox.ide.core.model.vo.HostVO;
	
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;

	/**
	 * @flowerModelElementId _DEdZEEomEeC-JfVEe_-0Aw
	 */
	public class ServerProxy extends Proxy implements IProxy
	{
		/**
		 * 15 minutes.
		 * defolt SESSION-LIFETIME = 20 minutes.  
		 */		
		private static const PING_TIMER : uint = 1000 * 60 * 15;    
		
		public static const NAME : String = "ServerProxy";

		public static const NOT_CONNECTED : String = "notConnected";

		public static const CONNECTION_PROCESS : String = "connectionProcess";

		public static const CONNECTION_ERROR : String = "connectionError";

		public static const LOGGED : String = "logonProcess";

		public static const CONNECTED : String = "connected";

		public function ServerProxy()
		{
			super( NAME );
		}

		private var soap : SOAP;

		private var sharedObjectProxy : SharedObjectProxy;

		private var isSOAPConnected : Boolean;

		private var _authInfo : AuthInfoVO;

		private var _applications : Array;
		
		private var _pingServerTimer : Timer;
		
		private var hostVO : HostVO;

		public function get applications():Array
		{
			return _applications;
		}

		public function get authInfo() : AuthInfoVO
		{
			return _authInfo;
		}
		 
		
		public function get server() : String
		{
			return _authInfo.hostname;
		}

		override public function onRegister() : void
		{
			sharedObjectProxy = facade.retrieveProxy( SharedObjectProxy.NAME ) as SharedObjectProxy;

			soap = SOAP.getInstance();

			if ( soap.ready )
				soap.disconnect();

			addHandlers();
			
			_pingServerTimer = new Timer(PING_TIMER);
		}

		override public function onRemove() : void
		{
			removeHandlers();
		}

		public function connect( host : HostVO ) : void
		{
			_authInfo = new AuthInfoVO();
			
			hostVO = host;

			_authInfo.setHostname( hostVO.host );
			_authInfo.setUsername( hostVO.user );

			sendNotification( ApplicationFacade.SERVER_CONNECTION_START );

			soap.connect( _authInfo.WSDLFilePath );				
		}

		public function disconnect() : void
		{
			_pingServerTimer.stop();
			
			soap.logout();

			_authInfo = null;
			_applications = null;
		}

		public function loadApplications() : void
		{
			soap.list_applications();
		}

		public function createApplication( applicationInformationVO : ApplicationInformationVO ) : void
		{
			soap.create_application( applicationInformationVO.toXML() );
		}

		public function getApplicationProxy( applicationVO : ApplicationVO ) : ApplicationProxy
		{
			/*if ( _applications.indexOf( applicationVO ) == -1 )
				return null;*/
			
			var appVO : ApplicationVO;
			var flag : Boolean = false;
			for each ( appVO in _applications )
			{
				if ( appVO.id == applicationVO.id )
				{
					flag = true;
					break;
				}
			}
			
			if ( !flag )
				return null;

			var applicationProxy : ApplicationProxy =
				facade.retrieveProxy( ApplicationProxy.NAME + ApplicationFacade.DELIMITER + applicationVO.id ) as ApplicationProxy;

			if ( !applicationProxy )
			{
				applicationProxy = new ApplicationProxy( applicationVO );
				facade.registerProxy( applicationProxy );
			}

			return applicationProxy;
		}

		private function addHandlers() : void
		{
			soap.addEventListener( FaultEvent.FAULT, soap_faultHandler, false, 0, true );
			
			soap.addEventListener( SOAPEvent.CONNECTION_OK, soap_connectionOKHandler, false, 0, true );
			soap.addEventListener( SOAPErrorEvent.CONNECTION_ERROR, soap_connectionErrorHandler, false, 0, true );

			soap.addEventListener( SOAPEvent.DISCONNECTON_OK, soap_disconnectionOKHandler, false, 0, true );

			soap.addEventListener( SOAPEvent.LOGIN_OK, soap_loginOKHandler, false, 0, true );
			soap.addEventListener( SOAPErrorEvent.LOGIN_ERROR, soap_loginErrorHandler, false, 0, true );
		}

		private function removeHandlers() : void
		{
			soap.removeEventListener( SOAPEvent.CONNECTION_OK, soap_connectionOKHandler );
			soap.removeEventListener( SOAPErrorEvent.CONNECTION_ERROR, soap_connectionErrorHandler );

			soap.removeEventListener( SOAPEvent.DISCONNECTON_OK, soap_disconnectionOKHandler );

			soap.removeEventListener( SOAPEvent.LOGIN_OK, soap_loginOKHandler );
			soap.removeEventListener( SOAPErrorEvent.LOGIN_ERROR, soap_loginErrorHandler );

			if ( soap.ready )
			{
				soap.list_applications.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
				soap.create_application.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
			}
		}

		private function createApplicationList( applications : XML ) : void
		{
			var applicationVO : ApplicationVO;
			var applicationVOInd : Number = -1;
			
			var oldapplications : Array = [];
			
			if (_applications)
				oldapplications = _applications.slice();
			
			_applications = [];

			var applicationID : String;

			for each ( var application : XML in applications.* )
			{
				applicationID = application.@ID[ 0 ];

				if ( !applicationID )
					continue;

				applicationVOInd = applicationVOIndex(oldapplications, applicationID); 
			
				applicationVO = applicationVOInd >= 0 ? oldapplications[applicationVOInd] : new ApplicationVO( applicationID );
				
				applicationVO.setInformation( application.Information[ 0 ] );

				_applications.push( applicationVO );
				
			}
			
			_applications.sortOn("name", Array.CASEINSENSITIVE);
		}
		
		private function applicationVOIndex(applicationsVO : Array, applicationID : String) : Number
		{
			var i : uint = 0;
			for each (var applicationVO : ApplicationVO in applicationsVO)
			{
				if (applicationVO.id == applicationID)
					return i;
				
				i++;
			}
			
			return -1;
		}

		private function soap_connectionOKHandler( event : SOAPEvent ) : void
		{
			isSOAPConnected = true;

			if ( soap.ready )
			{
				soap.list_applications.addEventListener( SOAPEvent.RESULT, soap_resultHandler );
				soap.create_application.addEventListener( SOAPEvent.RESULT, soap_resultHandler );
			}

			//only for ProgressViewMediator
			sendNotification( ApplicationFacade.SERVER_CONNECTION_SUCCESSFUL );
			sendNotification( ApplicationFacade.SERVER_LOGIN_START );

			soap.logon( hostVO.user, hostVO.password );
		}

		private function soap_disconnectionOKHandler( event : SOAPEvent ) : void
		{
			isSOAPConnected = false;
		}

		// получили ключик соединения, сессии
		private function soap_loginOKHandler( event : SOAPEvent ) : void
		{
			var result : XML = event.result;
			/*_authInfo.setUsername( result.Username[ 0 ] );
			_authInfo.setHostname( result.Hostname[ 0 ] );*/
			
			_authInfo.serverVersion = result.ServerVersion[0].toString();

			sendNotification( ApplicationFacade.SERVER_LOGIN_SUCCESSFUL, _authInfo );
			startInfiniteSession();
			addHostInSharedObject();
		}
		
		private function addHostInSharedObject() : void
		{
			if ( !hostVO.save )
				hostVO.password = "";
			if ( !sharedObjectProxy.equalHost( hostVO ) )	
				sharedObjectProxy.setHost( hostVO );
		}
				
		private function startInfiniteSession() : void
		{
			
			_pingServerTimer.addEventListener(TimerEvent.TIMER, pingOfServer); 
			_pingServerTimer.start();				
		}
		
		public function pingOfServer(event:TimerEvent):void  
		{ 	
			soap.keep_alive();
		} 
		
		private function soap_loginErrorHandler( event : SOAPErrorEvent ) : void
		{
			var error : ErrorVO = new ErrorVO();
			
			error.code = event.faultCode;
			error.string = event.faultString;
			error.detail = XML( event.faultDetail ).User[ 0 ];
			
			sendNotification( ApplicationFacade.SERVER_LOGIN_ERROR, error );
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
				case "list_applications":
				{
					createApplicationList( result.Applications[ 0 ] );

					sendNotification( ApplicationFacade.SERVER_APPLICATIONS_GETTED, _applications.slice() );

					break;
				}

				case "create_application":
				{
					var applicationVO : ApplicationVO = new ApplicationVO( result.Application[ 0 ].@ID );
					applicationVO.setInformation( result.Application[ 0 ].Information[ 0 ] );
					_applications.push( applicationVO );

					sendNotification( ApplicationFacade.SERVER_APPLICATION_CREATED, applicationVO );

					break;
				}
			}
		}
				
		private function soap_faultHandler( event : FaultEvent ) : void
		{
			var error : ErrorVO = new ErrorVO();
			
			error.code = event.fault.faultCode;
			error.string = event.fault.faultString;
			error.detail = event.fault.faultDetail;
			
			//TODO: creat alert
//			sendNotification( ApplicationFacade.SERVER_ERROR, error );
			
		}
		
		private function soap_connectionErrorHandler( event : SOAPErrorEvent ) : void
		{
			var error : ErrorVO = new ErrorVO();
			
			error.code = event.faultCode;
			error.string = event.faultString;
			error.detail = event.faultDetail;
			
			sendNotification( ApplicationFacade.SERVER_CONNECTION_ERROR, error );
		}
	}
}