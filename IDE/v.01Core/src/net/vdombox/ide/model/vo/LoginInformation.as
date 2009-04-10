package net.vdombox.ide.model.vo
{

	public class LoginInformation
	{
		public var username : String;
		public var hostname : String;
		public var serverVersion : String;

		public function LoginInformation( username : String, hostname : String, serverVersion : String = "" )
		{
			this.username = username;
			this.hostname = hostname;
			this.serverVersion = serverVersion;
		}
	}
}