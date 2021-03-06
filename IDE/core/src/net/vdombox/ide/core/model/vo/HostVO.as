package net.vdombox.ide.core.model.vo
{

	public class HostVO
	{
		public function HostVO( host : String, user : String, password : String, local : LocaleVO, ssl : Boolean  )
		{
			_host = host;
			_user = user;
			_password = password;
			_local = local;
			_ssl = ssl;
			save = false;
		}

		private var _host : String;

		private var _user : String;

		private var _password : String;

		private var _local : LocaleVO;

		private var _ssl : Boolean;
		
		public var save : Boolean;

		public function get host() : String
		{
			return _host;
		}
		
		public function get ssl() : Boolean
		{
			return _ssl;
		}
		
		public function set ssl( value : Boolean ) : void
		{
			_ssl = value;
		}

		public function get user() : String
		{
			return _user;
		}

		public function get password() : String
		{
			return _password;
		}

		public function set password( value : String ) : void
		{
			_password = value;
		}

		public function get local() : LocaleVO
		{
			return _local;
		}

		public function set local( value : LocaleVO ) : void
		{
			_local = value;
		}


	}
}
