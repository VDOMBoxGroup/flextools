package net.vdombox.ide.core.model.vo
{
	public class HostVO
	{
		public function HostVO( host : String, user : String, password : String, local : LocaleVO )
		{
			_host = host;
			_user = user;
			_password = password;
			_local = local;
		}
		
		private var _host : String;
		private var _user : String;
		private var _password : String;
		private var _local : LocaleVO;
		
		public function get host():String
		{
			return _host;
		}

		public function get user():String
		{
			return _user;
		}

		public function get password():String
		{
			return _password;
		}

		public function get local():LocaleVO
		{
			return _local;
		}


	}
}