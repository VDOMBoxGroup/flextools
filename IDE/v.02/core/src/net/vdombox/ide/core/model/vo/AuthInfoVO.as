package net.vdombox.ide.core.model.vo
{
	public class AuthInfoVO
	{
		private var _username : String;

//		private var _password : String;

		private var _hostname : String;

		public function get username() : String
		{
			return _username;
		}

//		public function get password() : String
//		{
//			return _password;
//		}
		
		public function get hostname() : String
		{
			return _hostname;
		}
		
		public function get WSDLFilePath() : String
		{
			var wsdlPath : String;
			
			if( _hostname )
				wsdlPath = "http://" + _hostname + "/vdom.wsdl";
			
			return wsdlPath;
		}
		
		public function setHostname( value : String ) : void
		{
			trace( "setHostname: " + value );
			_hostname = value;
		}
		
		public function setUsername( value : String ) : void
		{
			_username = value;
		}
	}
}