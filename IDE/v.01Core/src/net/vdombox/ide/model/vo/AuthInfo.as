package net.vdombox.ide.model.vo
{

	public class AuthInfo
	{

		public function AuthInfo( username : String, password : String, hostname : String )
		{
			this.username = username;
			this.password = password;
			this.hostname = hostname;
			this.serverVersion = serverVersion;
		}

		public var username : String;
		public var password : String;
		public var hostname : String;
		public var serverVersion : String;

		public function get WSDLFilePath() : String
		{
			return "http://" + hostname + "/vdom.wsdl";
		}
	}
}