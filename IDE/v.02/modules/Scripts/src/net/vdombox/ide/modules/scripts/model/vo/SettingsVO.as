package net.vdombox.ide.modules.scripts.model.vo
{
	public class SettingsVO
	{
		public function SettingsVO( settings : Object = null )
		{
			for ( var setting : String in settings )
			{
				if ( this.hasOwnProperty( setting ) )
					this[ setting ] = settings[ setting ];
			}
		}

		public var testSetting : String;

		public function copy() : SettingsVO
		{
			var settingsVO : SettingsVO = new SettingsVO( toObject() );

			return settingsVO;
		}

		public function toObject() : Object
		{
			var object : Object = {};

			for ( var setting : String in this )
			{
				object[ setting ] = this[ setting ];
			}

			return object;
		}
	}
}