package net.vdombox.ide.core.model.vo
{
	public class LocaleVO
	{
		public function LocaleVO( code : String, description : String )
		{
			_code = code;
			_description = description;
		}
		
		private var _code : String;
		
		private var _description : String;
		
		public function get code() : String
		{
			return _code;
		}
		
		public function get description() : String
		{
			return _description;
		}
	}
}