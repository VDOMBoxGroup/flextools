package net.vdombox.ide.model
{
	import flash.net.SharedObject;
	
	import net.vdombox.ide.events.SOAPErrorEvent;
	import net.vdombox.ide.events.SOAPEvent;
	import net.vdombox.ide.model.business.SOAP;
	
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;

	public class LoginProxy extends Proxy implements IProxy
	{
		public static const NAME : String = "LoginProxy";
		
		public static const LOGIN_OK : String = "Login OK";

		public function LoginProxy( data : Object = null )
		{
			super( NAME, data );
			addEventListeners();
		}
		
		private var soap : SOAP = SOAP.getInstance();
		private var sharedObject : SharedObject = SharedObject.getLocal( "userData" );
		
		private var tempUserData : Object = {};
		
		public function get username() : String
		{
			return sharedObject.data.username ? sharedObject.data.username : "";
		}

		public function set username( value : String ) : void
		{
			sharedObject.data.username = value;
		}

		public function get password() : String
		{
			return "";
//			return sharedObject.data.username ? sharedObject.data.password : "";
		}

		public function set password( value : String ) : void
		{
//			sharedObject.data.password = value;
		}

		public function get hostname() : String
		{
			return sharedObject.data.username ? sharedObject.data.hostname : "";
		}

		public function set hostname( value : String ) : void
		{
			sharedObject.data.hostname = value;
		}

		public function login( username : String, password : String, hostname : String ) : void
		{
			tempUserData = { username : username, password : password, hostname : hostname };
			soap.init( "http://" + hostname + "/vdom.wsdl" );
		}

		private function addEventListeners() : void
		{
			soap.addEventListener( SOAPEvent.INIT_COMPLETE, soap_initCompleteHandler );
			soap.addEventListener( SOAPEvent.LOGIN_OK, soap_loginOKHandler );
			soap.addEventListener( SOAPErrorEvent.LOGIN_ERROR, soap_loginErrorHandler );
		}

		private function soap_initCompleteHandler( event : SOAPEvent ) : void
		{
			soap.login( tempUserData.username, tempUserData.password );
		}

		private function soap_loginOKHandler( event : SOAPEvent ) : void
		{
			var result : XML = event.result;
			username = result.Username[0];
			hostname = result.Hostname[0];
			
//			sendNotification( LOGIN_OK,  
		}

		private function soap_loginErrorHandler( event : SOAPErrorEvent ) : void
		{
			tempUserData = {};
		}
	}
}