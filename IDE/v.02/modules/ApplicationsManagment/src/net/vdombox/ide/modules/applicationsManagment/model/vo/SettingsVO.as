package net.vdombox.ide.modules.applicationsManagment.model.vo
{
	[Bindable]
	public class SettingsVO
	{
		public function SettingsVO( settings : Object )
		{
			if( settings.hasOwnProperty( "saveLastApplication" ) )
				saveLastApplication = settings[ "saveLastApplication" ];
			
			if( settings.hasOwnProperty( "lastApplicationID" ) )
				lastApplicationID = settings[ "lastApplicationID" ];
		}
		
		public var saveLastApplication : Boolean;
		
		public var lastApplicationID : String;
	}
}