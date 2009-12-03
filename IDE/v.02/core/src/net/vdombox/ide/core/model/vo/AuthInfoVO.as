package net.vdombox.ide.core.model.vo
{
	public class AuthInfoVO
	{

		public function AuthInfoVO( username : String, password : String, hostname : String )
		{
			_username = username;
			_password = password;
			_hostname = hostname;
		}

		private var _username : String;

		private var _password : String;

		private var _hostname : String;

		public function get username() : String
		{
			return _username;
		}

		public function get password() : String
		{
			return _password;
		}
		
		public function get hostname() : String
		{
			return _hostname;
		}
		
		public function get WSDLFilePath() : String
		{
			return "http://" + _hostname + "/vdom.wsdl";
		}
	}
}