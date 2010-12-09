/*
	Class FileProxy have function for returne XML for path to file
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
		
		public function getXML( path:String ):XML 
		{	
			var file:File = new File;
			file.nativePath = path;
			
			var stream:FileStream = new FileStream();   
			stream.open(file, FileMode.READ);
			var data:String = stream.readUTFBytes(stream.bytesAvailable);
			var objectXML:XML = new XML(data);	
						
			stream.close();	
			return objectXML;				
		}
		
		public function saveXMLToFile( xml:XML, path:String ): void//Boolean
		{		
		}
	}
}