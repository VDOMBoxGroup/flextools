package net.vdombox.powerpack.utils
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	import net.vdombox.powerpack.lib.player.gen.TemplateLib;
	import net.vdombox.powerpack.lib.player.gen.TemplateStruct;
	
	import r1.deval.D;
	
	public class LibLoader extends EventDispatcher
	{
		public function LibLoader()
		{
			super();
		}
		
		public static function loadLib() : void
		{
			TemplateStruct.lib = new TemplateLib();
			
			var libFolder : File = File.applicationDirectory.resolvePath( 'libs' );
			
			if ( !libFolder.exists )
				return;
			
			var libs : Array = libFolder.getDirectoryListing();
			for each( var libFile : File in libs )
			{
				var stream : FileStream = new FileStream();
				var strData : String;
				
				if ( !libFile.isDirectory && !libFile.isPackage && !libFile.isSymbolicLink && libFile.exists &&
					(libFile.extension == 'as' || libFile.extension == 'txt') )
				{
					stream.open( libFile, FileMode.READ );
					strData = stream.readUTFBytes( stream.bytesAvailable );
					stream.close();
					D.setOutput( evalHandler );
					strData = strData + ';true;';
					D.eval( strData, TemplateStruct.lib );
				}
			}
			
			function evalHandler( value : String ) : void
			{
				trace( value );
			}
		}
		
	}
}