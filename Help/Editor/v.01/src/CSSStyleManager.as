package
{
	import com.adobe.crypto.MD5Stream;
	
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	import mx.controls.Image;
	import mx.graphics.codec.PNGEncoder;
	
	public class CSSStyleManager extends EventDispatcher
	{
		public static const STYLE_SETTED	: String = "styleSetted";
		
		private const cssFileName		: String = "main.css";
		private const cssImagesFolder	: String = "images";
		
		private var currentFileName		: String = "";
		
		private var imagesDirectoryContent : Array;
		
		private var fileStream : FileStream = new FileStream();
		
		private var img : Image = new Image();
		
		public function CSSStyleManager()
		{
		}
		
		public function setStyle():void
		{
			imagesDirectoryContent = [];
			currentFileName = cssFileName;
			loadFile();
		}
		
		private function loadFile(fileFromImagesDirectory : Boolean = false):void
		{
			var sourceFile	: File;
			var storageFile	: File;
			
			if (currentFileName == cssImagesFolder && fileFromImagesDirectory)
			{	
				sourceFile = File(imagesDirectoryContent.pop());
				storageFile = File.applicationStorageDirectory.resolvePath(currentFileName+"/"+sourceFile.name);
			} else 
			{
				sourceFile = File.applicationDirectory.resolvePath(currentFileName);
				storageFile = File.applicationStorageDirectory.resolvePath(currentFileName);
			}
			
			if (!sourceFile.isDirectory && sourceFile.exists)
			{
				if ( !storageFile.exists || sourceFileChanged(sourceFile, storageFile) ) 
				{
					sourceFile.copyTo(storageFile, true);
				}
			}
				
			onFileCreated();
		}
		
		private function sourceFileChanged(sourceFile : File, storageFile : File) : Boolean
		{
			if (sourceFile.isDirectory)
				return false;
			
			var md5StreamForSourceFile : MD5Stream;
			var md5StreamStorageFile : MD5Stream;
			var fileStream : FileStream;
			var byteArray : ByteArray;
			
			var uidForSourceFile : String;
			var uidForStorageFile : String;
			
			if (!sourceFile.exists || !storageFile.exists)
				return true;
			
			md5StreamForSourceFile  = new MD5Stream();
			md5StreamStorageFile = new MD5Stream();
			
			fileStream = new FileStream();
			byteArray = new ByteArray();
			
			fileStream.open(sourceFile, FileMode.READ);
			fileStream.readBytes(byteArray);
			uidForSourceFile = md5StreamForSourceFile.complete(byteArray);
			fileStream.close();
			
			byteArray.clear();
			
			fileStream.open(storageFile, FileMode.READ);
			fileStream.readBytes(byteArray);
			uidForStorageFile = md5StreamForSourceFile.complete(byteArray);
			fileStream.close();

			
			if (uidForSourceFile == uidForStorageFile)
				return false;
				
			
			return true;
		}
		
		private function onFileCreated():void
		{
			trace ("[CSSStyleManager] onFileCreated");
			switch(currentFileName)
			{
				case cssFileName:
				{
					currentFileName = cssImagesFolder;
					if (File.applicationDirectory.resolvePath(currentFileName).isDirectory)
						imagesDirectoryContent = File.applicationDirectory.resolvePath(currentFileName).getDirectoryListing();
					
					loadFile(true);
					break;
				}
				
				default:
				{
					if (!imagesDirectoryContent || imagesDirectoryContent.length == 0)
					{
						dispatchEvent(new Event(STYLE_SETTED));
						return;
					}
					loadFile(true);
					
					break;
				}
			}
			
		}
		
	}
}