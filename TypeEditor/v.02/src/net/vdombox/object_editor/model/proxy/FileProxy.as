/*
   Class FileProxy wrapper over file
 */
package net.vdombox.object_editor.model.proxy
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;

	import mx.controls.Alert;
	
	import net.vdombox.object_editor.model.ErrorLogger;
	
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
            if (!path)
                return "";

			var data:String = "";
			
			var file:File = new File;
			file.nativePath = path;

            if (!file.exists)
                return "";

			var stream:FileStream = new FileStream();   
			try
			{
				stream.open(file, FileMode.READ);
				data = stream.readUTFBytes(stream.bytesAvailable);
				stream.close();	
				return data;
			}
			catch (error:Error)
			{
				Alert.show("Failed: was changed path. Open the directory again");
				ErrorLogger.instance.logError("Failed: The path can be changed. "+error.message, "FileProxy.readFile("+path+")");
				trace("Failed: was changed path.", error.message);				
			}
			return data;
		}
		
		public function readByteArrayFile( path:String ):ByteArray
		{	
			var data:ByteArray = new ByteArray();
			
			var file:File = new File;
			file.nativePath = path;
			
			var stream:FileStream = new FileStream();   
			try
			{
				stream.open(file, FileMode.READ);
				stream.readBytes( data, 0 , stream.bytesAvailable );
				stream.close();	
				return data;
			}
			catch (error:Error)
			{
				Alert.show("Failed: was changed path. Open the directory again");
				ErrorLogger.instance.logError("Failed: The path can be changed. "+error.message, "FileProxy.readFile("+path+")");
				trace("Failed: was changed path.", error.message);				
			}
			return data;
		}

		public function saveFile( str:String, path:String ): void
		{
			var file:File = new File();
			file.nativePath = path; 

			try
			{
				var stream:FileStream = new FileStream();
				stream.open(file, FileMode.WRITE);
				stream.writeUTFBytes(str);
				stream.close();
			}
			catch (error:Error)
			{
				//какая здесь ошибка?
				Alert.show("Failed: was changed path. Please restart the application");
				ErrorLogger.instance.logError("Failed: the path can be changed. "+error.message, "FileProxy.saveFile("+file.nativePath+")");
				trace("Failed: was changed path. Please restart the application", error.message);
			}			
		}
		
		public function deleteFile( path:String ): void
		{
			var file:File = new File();
			file.nativePath = path; 
			
			try
			{
				file.deleteFile();
			}
			catch (error:Error)
			{
				Alert.show("Failed: file was not deleted.");
				ErrorLogger.instance.logError("Failed: file was not deleted. "+error.message, "FileProxy.deleteFile("+file.nativePath+")");
				trace("Failed: file was not deleted.", error.message);
			}			
		}

        public function getFolderContent ( folderPath : String ) : Array
        {
            var folder : File = getFile(folderPath);

            if (!folder || !folder.exists || !folder.isDirectory)
                return null;

            return folder.getDirectoryListing();
        }

        public function filterLaTexFiles ( files : Array ) : Array
        {
            if (!files)
                return null;

            var laTexFiles : Array = files.filter(isLaTexFile);

            function isLaTexFile (element:File, index:int, arr:Array):Boolean
            {
                return (element.extension.toLowerCase() == "tex");
            }

            return laTexFiles;
        }

        public function getFileName ( file : File) : String
        {
            if (!file)
                return "";

            var fullName : String = file.name;

            return fullName.substring(0, fullName.lastIndexOf(file.extension)-1)
        }

        public function getCorrectFilePath ( path : String ) : String
        {
            if (!path)
                return "";

            path = path.replace(/\\/g, "/");

            return path;
        }

        public function getFile ( path : String ) : File
        {
            if (!path)
                return new File();

            var file : File;

            try
            {
                file = new File (path);
            }
            catch (e : Error)
            {
                file = null;
            }

            return file;
        }

	}
}