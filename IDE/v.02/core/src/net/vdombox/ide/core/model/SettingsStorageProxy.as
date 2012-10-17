package net.vdombox.ide.core.model
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;

	public class SettingsStorageProxy extends Proxy implements IProxy
	{
		public static const NAME : String = "SettingsStorageProxy";

		private const SETTINGS_PATH : String = "app-storage";

		public function SettingsStorageProxy( data : Object = null )
		{
			super( NAME, data );
		}

		public function loadSettings( settingsName : String ) : Object
		{
			return readObjectFromFile( "settings/" + settingsName );
		}

		public function saveSettings( settingsID : String, settingsValue : Object ) : void
		{
			writeObjectToFile( settingsValue, "settings/" + settingsID );
		}

		private function writeObjectToFile( object : Object, fname : String ) : void
		{
			var file : File = File.applicationStorageDirectory.resolvePath( fname );

			var fileStream : FileStream = new FileStream();
			fileStream.open( file, FileMode.WRITE );
			fileStream.writeObject( object );
			fileStream.close();
		}

		private function readObjectFromFile( fname : String ) : Object
		{
			var file : File = File.applicationStorageDirectory.resolvePath( fname );

			if ( file.exists )
			{
				var obj : Object;
				var fileStream : FileStream = new FileStream();
				fileStream.open( file, FileMode.READ );
				obj = fileStream.readObject();
				fileStream.close();
				return obj;
			}
			return null;
		}
	}
}