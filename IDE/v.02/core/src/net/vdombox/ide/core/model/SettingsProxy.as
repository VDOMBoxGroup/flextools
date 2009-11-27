package net.vdombox.ide.core.model
{
	import flash.filesystem.File;
	
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;
	
	public class SettingsProxy extends Proxy implements IProxy
	{
		public static const NAME : String = "SettingsProxy";
		
		private const SETTINGS_PATH : String = "app-storage";
		
		public function SettingsProxy( data : Object = null )
		{
			super( NAME, data );
		}
		
		public function getSettings( settingsName : String ) : String
		{
			return "";
		}
		
		public function saveSettings( settingsName : String, settingsValue : String ) : Boolean
		{
			return true;
		}
		
		override public function onRegister() : void
		{
			var path : String = File.applicationStorageDirectory.nativePath;	
		}
	}
}