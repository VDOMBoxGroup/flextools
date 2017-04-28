package net.vdombox.ide.core.model.vo
{

	public class AuthInfoVO
	{
		private var _username : String;

		//		private var _password : String;

		private var _hostname : String;

		private var _serverVersion : String;
		private var _useSSL : Boolean;

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

			if ( _hostname )
			{
				wsdlPath = _useSSL ? "https://" : "http://";
				wsdlPath +=  _hostname + "/vdom.wsdl";
			}
				
			trace(wsdlPath);
			return wsdlPath;
		}

		public function setHostname( value : String, ssl :Boolean ) : void
		{
			_hostname = value;
			_useSSL = ssl;
		}
		

		public function setUsername( value : String ) : void
		{
			_username = value;
		}

		public function set serverVersion( value : String ) : void
		{
			_serverVersion = value;
		}

		public function get serverVersion() : String
		{
			return _serverVersion;
		}


	}
}
