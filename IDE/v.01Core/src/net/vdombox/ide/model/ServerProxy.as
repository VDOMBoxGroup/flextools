package net.vdombox.ide.model
{
	import net.vdombox.ide.events.SOAPErrorEvent;
	import net.vdombox.ide.events.SOAPEvent;
	import net.vdombox.ide.model.business.SOAP;
	import net.vdombox.ide.model.vo.ApplicationVO;
	import net.vdombox.ide.model.vo.AuthInfo;
	
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

//		private var registeredHandlers : Array = [ { methodName: "list_applications", handlerName: "soap_listApplicationsHandler" },
//												   { methodName: "get_all_types", handlerName: "soap_getAllTypesHandler" } ]

		private var tempAuthInfo : AuthInfo;
		private var _authInfo : AuthInfo;
		private var _applications : Array;

		public function get authInfo() : AuthInfo
		{
			return _authInfo;
		}

		public function get applications() : Array
		{
			return _applications;
		}

		public function connect( authInfo : AuthInfo ) : void
		{
			connected = false;
			tempAuthInfo = authInfo;
			soap.init( authInfo.WSDLFilePath );
		}

		public function getApplicationProxy( applicationID : String ) : void
		{

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
			
			for each( var application : XML in applications.* )
			{
				_applications.push( new ApplicationVO( application ) );
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
			_authInfo = new AuthInfo( result.Username[ 0 ], tempAuthInfo.password,
									  result.Hostname[ 0 ] );
			tempAuthInfo = null;

			sendNotification( LOGIN_COMPLETE, _authInfo );

			soap.list_applications.addEventListener( SOAPEvent.RESULT, soap_listApplicationsHandler )
			soap.list_applications();
		}

		private function soap_listApplicationsHandler( event : SOAPEvent ) : void
		{
			createApplicationList( event.result.Applications[ 0 ] );
			sendNotification( CONNECT_COMPLETE );
		}

		private function soap_loginErrorHandler( event : SOAPErrorEvent ) : void
		{
			tempAuthInfo = null;
		}
	}
}