package net.vdombox.ide.modules.applicationsManagment.model.vo
{
	public class SettingsVO
	{
		public function SettingsVO( stringSetting : String, arraySetting : Array )
		{
			_stringSetting = stringSetting;
			_arraySetting = arraySetting;
		}
		
		private var _stringSetting : String;
		private var _arraySetting : Array;
		
		public function get stringSetting() : String
		{
			return _stringSetting;
		}
		
		public function get arraySetting() : Array
		{
			return _arraySetting;
		}
	}
}