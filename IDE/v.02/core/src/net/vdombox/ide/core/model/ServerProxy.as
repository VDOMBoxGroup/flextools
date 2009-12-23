package net.vdombox.ide.core.model
{
	import mx.rpc.soap.Operation;
	
	import net.vdombox.ide.common.vo.ApplicationPropertiesVO;
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
			super( NAME, data );
		}

		private var soap : SOAP;

		private var _status : String;

		private var _authInfo : AuthInfoVO;

		private var _selectedApplication : ApplicationVO;

		private var _applications : Array;

		public function get status() : String
		{
			return _status;
		}

		public function get authInfo() : AuthInfoVO
		{
			return _authInfo;
		}

		public function get applications() : Array
		{
			return _applications.slice();
		}

		public function get selectedApplication() : ApplicationVO
		{
			return _selectedApplication;
		}

		public function set selectedApplication( value : ApplicationVO ) : void
		{
			if ( _applications.indexOf( value ) != -1 )
				_selectedApplication = value;
		}

		override public function onRegister() : void
		{
			_status = NOT_CONNECTED;
			soap = SOAP.getInstance();

			addEventListeners();
		}

		public function connect( hostname : String ) : void
		{
			_status = CONNECTION_PROCESS;

			_authInfo = new AuthInfoVO();
			_authInfo.setHostname( hostname );

			sendNotification( ApplicationFacade.CONNECTION_SERVER_STARTS );

			soap.init( _authInfo.WSDLFilePath );
		}

		public function logon( username : String, password : String ) : void
		{
			if ( _status == CONNECTED || _status == LOGGED )
			{
				sendNotification( ApplicationFacade.LOGON_STARTS );
				soap.logon( username, password );
			}
		}

		public function disconnect() : void
		{
			_status = NOT_CONNECTED;
		}

		public function loadApplications() : void
		{
			soap.list_applications.addEventListener( SOAPEvent.RESULT, soap_resultHandler );

			sendNotification( ApplicationFacade.APPLICATIONS_LOADING );

			soap.list_applications();
		}

		public function createApplication( applicationPropertiesVO : ApplicationPropertiesVO ) : void
		{
			soap.create_application.addEventListener( SOAPEvent.RESULT, soap_resultHandler );
			
			soap.create_application( applicationPropertiesVO.toXML() );
		}

		public function getApplicationProxy( applicationVO : ApplicationVO ) : ApplicationProxy
		{
			if ( applications.indexOf( applicationVO ) == -1 )
				return null;

			var applicationProxy : ApplicationProxy = facade.retrieveProxy( ApplicationProxy.NAME + "/" + applicationVO.id ) as ApplicationProxy;

			if ( !applicationProxy )
			{
				applicationProxy = new ApplicationProxy( applicationVO );
				facade.registerProxy( applicationProxy );
			}

			return applicationProxy;

		}

		private function addEventListeners() : void
		{
			soap.addEventListener( SOAPEvent.INIT_COMPLETE, soap_initCompleteHandler );
			soap.addEventListener( SOAPEvent.LOGIN_OK, soap_loginOKHandler );
			soap.addEventListener( SOAPErrorEvent.LOGIN_ERROR, soap_loginErrorHandler );
		}

		private function createApplicationList( applications : XML ) : void
		{			
			_applications = [];
			
			var applicationID : String;
			
			for each ( var application : XML in applications.* )
			{
				applicationID = application.@ID[ 0 ];
				
				if( !applicationID )
					continue;
				
				var applicationVO : ApplicationVO = new ApplicationVO( applicationID );
				applicationVO.setInformation( application.Information[ 0 ] );

				_applications.push( applicationVO );
			}
		}

		private function soap_initCompleteHandler( event : SOAPEvent ) : void
		{
			_status = CONNECTED;
			sendNotification( ApplicationFacade.CONNECTION_SERVER_SUCCESSFUL );
		}

		private function soap_loginOKHandler( event : SOAPEvent ) : void
		{
			_status = LOGGED;

			var result : XML = event.result;
			_authInfo.setUsername( result.Username[ 0 ] );
			_authInfo.setHostname( result.Hostname[ 0 ] );

			sendNotification( ApplicationFacade.LOGON_SUCCESS, _authInfo );
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
					sendNotification( ApplicationFacade.APPLICATIONS_LOADED, _applications );

					break;
				}

				case "create_application":
				{
					var applicationVO : ApplicationVO = new ApplicationVO( result.Application[ 0 ].@ID );
					applicationVO.setInformation( result.Application[ 0 ].Information[ 0 ] );
					_applications.push( applicationVO );

					sendNotification( ApplicationFacade.APPLICATION_CREATED, applicationVO );

					break;
				}
			}
		}

		private function soap_loginErrorHandler( event : SOAPErrorEvent ) : void
		{
			sendNotification( ApplicationFacade.LOGON_ERROR );
		}
	}
}