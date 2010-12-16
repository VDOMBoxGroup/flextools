/*
   Class FileProxy have function for returne XML for path to file and save xml to file
 */
package net.vdombox.object_editor.model.proxy
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;

	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;

	public class FileProxy extends org.puremvc.as3.patterns.proxy.Proxy implements IProxy
	{		
		public static const NAME:String = "FileProxy";			

		public function FileProxy ( data:Object = null ) 
		{
			super ( NAME, data );
		}

		public function readFile( path:String ):String
		{	
			var file:File = new File;
			file.nativePath = path;

			var stream:FileStream = new FileStream();   
			stream.open(file, FileMode.READ);
			var data:String = stream.readUTFBytes(stream.bytesAvailable);
			stream.close();	
			return data;				
		}

		public function saveFile( str:String, path:String ): void//Boolean
		{
			var file:File = new File();
			file.nativePath = path; 

			var stream:FileStream = new FileStream();
			stream.open(file, FileMode.WRITE);
			stream.writeUTFBytes(str);
			stream.close();
		}
	}
}

