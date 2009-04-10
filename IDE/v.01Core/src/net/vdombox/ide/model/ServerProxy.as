package net.vdombox.ide.model
{
	import net.vdombox.ide.events.SOAPErrorEvent;
	import net.vdombox.ide.events.SOAPEvent;
	import net.vdombox.ide.model.business.SOAP;
	import net.vdombox.ide.model.vo.AuthInfo;

	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;

	public class ServerProxy extends Proxy implements IProxy
	{
		public static const NAME : String = "ServerProxy";
		public static const LOGIN_OK : String = "Login OK";

		public function ServerProxy( data : Object = null )
		{
			super( NAME, data );

			addEventListeners();
		}

		public var connected : Boolean = false;

		private var soap : SOAP = SOAP.getInstance();
		private var tempAuthInfo : AuthInfo;

		public function connect( authInfo : AuthInfo ) : void
		{
			connected = false;
			tempAuthInfo = authInfo;
			soap.init( authInfo.WSDLFilePath );
		}

		private function addEventListeners() : void
		{
			soap.addEventListener( SOAPEvent.INIT_COMPLETE, soap_initCompleteHandler );
			soap.addEventListener( SOAPEvent.LOGIN_OK, soap_loginOKHandler );
			soap.addEventListener( SOAPErrorEvent.LOGIN_ERROR, soap_loginErrorHandler );
		}

		private function soap_initCompleteHandler( event : SOAPEvent ) : void
		{
			soap.login( tempAuthInfo.username, tempAuthInfo.password );
		}

		private function soap_loginOKHandler( event : SOAPEvent ) : void
		{
			connected = true;
			var result : XML = event.result;
			tempAuthInfo = null;
			var authInfo : AuthInfo = new AuthInfo( result.Username[ 0 ], result.Hostname[ 0 ] );

			sendNotification( LOGIN_OK, authInfo );
		}

		private function soap_loginErrorHandler( event : SOAPErrorEvent ) : void
		{
			tempAuthInfo = null;
		}
	}
}