package net.vdombox.object_editor.model.vo
{
	public class ConnectInfoVO
	{
		private var _serverAddress : String;
		private var _userName : String;
		private var _password : String;
		
		public function ConnectInfoVO( server : String, name : String, pass : String )
		{
			_serverAddress = server;
			_userName = name;
			_password = pass;
		}


		public function get serverAddress():String
		{
			return _serverAddress;
		}
		
		public function get userName():String
		{
			return _userName;
		}
		
		public function get password():String
		{
			return _password;
		}

	}
}