package net.vdombox.ide.core.model
{
	import mx.rpc.soap.Operation;

	import net.vdombox.ide.common.vo.ApplicationInformationVO;
	import net.vdombox.ide.common.vo.ApplicationVO;
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.events.SOAPErrorEvent;
	import net.vdombox.ide.core.events.SOAPEvent;
	import net.vdombox.ide.core.model.business.SOAP;
	import net.vdombox.ide.core.model.vo.AuthInfoVO;

	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;

	public class ServerProxy extends Proxy implements IProxy
	{
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

		public function get authInfo() : AuthInfoVO
		{
			return _authInfo;
		}

		override public function onRegister() : void
		{
			sharedObjectProxy = facade.retrieveProxy( SharedObjectProxy.NAME ) as SharedObjectProxy;
			
			soap = SOAP.getInstance();

			if ( soap.ready )
				soap.disconnect();

			

			addHandlers();
		}

		override public function onRemove() : void
		{
			soap.removeEventListener( SOAPEvent.CONNECTED, soap_connectedHandler );
			soap.removeEventListener( SOAPEvent.DISCONNECTED, soap_disconnectedHandler );

			removeHandlers();
		}

		public function connect() : void
		{
			_authInfo = new AuthInfoVO();

			_authInfo.setHostname( sharedObjectProxy.hostname );
			_authInfo.setUsername( sharedObjectProxy.username );

			sendNotification( ApplicationFacade.SERVER_CONNECTION_START );

			soap.connect( _authInfo.WSDLFilePath );
		}

		public function disconnect() : void
		{
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
			soap.create_application.addEventListener( SOAPEvent.RESULT, soap_resultHandler );

			soap.create_application( applicationInformationVO.toXML() );
		}

		public function getApplicationProxy( applicationVO : ApplicationVO ) : ApplicationProxy
		{
			if ( _applications.indexOf( applicationVO ) == -1 )
				return null;

			var applicationProxy : ApplicationProxy = facade.retrieveProxy( ApplicationProxy.NAME + "/" + applicationVO.id ) as ApplicationProxy;

			if ( !applicationProxy )
			{
				applicationProxy = new ApplicationProxy( applicationVO );
				facade.registerProxy( applicationProxy );
			}

			return applicationProxy;

		}

		private function addHandlers() : void
		{
			soap.addEventListener( SOAPEvent.CONNECTED, soap_connectedHandler, false, 0, true );
			soap.addEventListener( SOAPEvent.DISCONNECTED, soap_disconnectedHandler, false, 0, true );
			
			soap.addEventListener( SOAPEvent.LOGIN_OK, soap_loginOKHandler, false, 0, true );
			soap.addEventListener( SOAPErrorEvent.LOGIN_ERROR, soap_loginErrorHandler, false, 0, true );
		}

		private function removeHandlers() : void
		{
			soap.removeEventListener( SOAPEvent.CONNECTED, soap_connectedHandler );
			soap.removeEventListener( SOAPEvent.DISCONNECTED, soap_disconnectedHandler );
			
			soap.removeEventListener( SOAPEvent.LOGIN_OK, soap_loginOKHandler );
			soap.removeEventListener( SOAPErrorEvent.LOGIN_ERROR, soap_loginErrorHandler );
			
			if( soap.ready )
				soap.list_applications.addEventListener( SOAPEvent.RESULT, soap_resultHandler );
		}

		private function createApplicationList( applications : XML ) : void
		{
			_applications = [];

			var applicationID : String;

			for each ( var application : XML in applications.* )
			{
				applicationID = application.@ID[ 0 ];

				if ( !applicationID )
					continue;

				var applicationVO : ApplicationVO = new ApplicationVO( applicationID );
				applicationVO.setInformation( application.Information[ 0 ] );

				_applications.push( applicationVO );
			}
		}

		private function soap_connectedHandler( event : SOAPEvent ) : void
		{
			isSOAPConnected = true;

			if( soap.ready )
				soap.list_applications.addEventListener( SOAPEvent.RESULT, soap_resultHandler );
			
			sendNotification( ApplicationFacade.SERVER_CONNECTION_SUCCESSFUL );
			sendNotification( ApplicationFacade.SERVER_LOGIN_START );

			soap.logon( sharedObjectProxy.username, sharedObjectProxy.password );
		}

		private function soap_disconnectedHandler( event : SOAPEvent ) : void
		{
			isSOAPConnected = false;
		}

		private function soap_loginOKHandler( event : SOAPEvent ) : void
		{
			var result : XML = event.result;
			_authInfo.setUsername( result.Username[ 0 ] );
			_authInfo.setHostname( result.Hostname[ 0 ] );

			sendNotification( ApplicationFacade.SERVER_LOGIN_SUCCESSFUL, _authInfo );
		}
		
		private function soap_loginErrorHandler( event : SOAPErrorEvent ) : void
		{
			sendNotification( ApplicationFacade.SERVER_LOGIN_ERROR );
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
	}
}