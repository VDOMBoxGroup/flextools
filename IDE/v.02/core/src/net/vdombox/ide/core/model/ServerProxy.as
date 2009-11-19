package net.vdombox.ide.core.model
{
	import net.vdombox.ide.core.events.SOAPErrorEvent;
	import net.vdombox.ide.core.events.SOAPEvent;
	import net.vdombox.ide.core.interfaces.IApplicationVO;
	import net.vdombox.ide.core.model.business.SOAP;
	import net.vdombox.ide.core.model.vo.ApplicationVO;
	import net.vdombox.ide.core.model.vo.AuthInfo;
	
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;

	public class ServerProxy extends Proxy implements IProxy
	{
		public static const NAME : String = "ServerProxy";

		public static const LOGIN_COMPLETE : String = "Login Complete";

		public static const CONNECT_COMPLETE : String = "Connect Complete";

		public function ServerProxy( data : Object = null )
		{
			super( NAME, data );

			addEventListeners();
		}

		public var connected : Boolean = false;

		private var soap : SOAP = SOAP.getInstance();

		private var tempAuthInfo : AuthInfo;

		private var _authInfo : AuthInfo;

		private var _selectedApplication : ApplicationVO;

		private var listOfApplications : Object;

		public function get authInfo() : AuthInfo
		{
			return _authInfo;
		}

		public function get applications() : Array
		{
			var _applications : Array = [];

			for each ( var applicationVO : IApplicationVO in listOfApplications )
			{
				_applications.push( applicationVO );
			}
			return _applications;
		}

		public function get selectedApplication() : ApplicationVO
		{
			return _selectedApplication;
		}

		public function set selectedApplication( value : ApplicationVO ) : void
		{
			if ( listOfApplications[ value.id ])
			{
				_selectedApplication = value;
			}
		}

		public function connect( authInfo : AuthInfo ) : void
		{
			connected = false;
			tempAuthInfo = authInfo;
			soap.init( authInfo.WSDLFilePath );
		}

		public function getApplicationProxy( applicationID : String ) : ApplicationProxy
		{
			var applicationProxy : ApplicationProxy = facade.retrieveProxy( ApplicationProxy.NAME + "." + applicationID ) as ApplicationProxy;

			if ( !applicationProxy )
			{
				var applicationVO : ApplicationVO = listOfApplications[ applicationID ];

				if ( applicationVO )
				{
					applicationProxy = new ApplicationProxy( ApplicationProxy.NAME + "." + applicationID, applicationVO );
					facade.registerProxy( applicationProxy );
				}
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
			listOfApplications = {};

			for each ( var application : XML in applications.* )
			{
				var applicationVO : IApplicationVO = new ApplicationVO( application );

				if ( !applicationVO.id )
					continue;

				listOfApplications[ applicationVO.id ] = applicationVO;
			}
		}

		private function soap_initCompleteHandler( event : SOAPEvent ) : void
		{
			soap.login( tempAuthInfo.username, tempAuthInfo.password );
		}

		private function soap_loginOKHandler( event : SOAPEvent ) : void
		{
			connected = true;
			var result : XML = event.result;
			_authInfo = new AuthInfo( result.Username[ 0 ], tempAuthInfo.password, result.Hostname[ 0 ]);
			tempAuthInfo = null;

			sendNotification( LOGIN_COMPLETE, _authInfo );

			soap.list_applications.addEventListener( SOAPEvent.RESULT, soap_listApplicationsHandler );
			soap.list_applications();
		}

		private function soap_listApplicationsHandler( event : SOAPEvent ) : void
		{
			createApplicationList( event.result.Applications[ 0 ]);
			sendNotification( CONNECT_COMPLETE );
		}

		private function soap_loginErrorHandler( event : SOAPErrorEvent ) : void
		{
			tempAuthInfo = null;
		}
	}
}