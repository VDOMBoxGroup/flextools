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
		private const cssImage1			: String = "images/button-bg.png";
		private const cssImage2			: String = "images/table-th.png";
		
		private var currentFileName		: String = "";
		
		private var fileStream : FileStream = new FileStream();
		
		private var img : Image = new Image();
		
		public function CSSStyleManager()
		{
		}
		
		public function setStyle():void
		{
			currentFileName = cssFileName;
			loadFile();
		}
		
		private function loadFile():void
		{
			var sourceFile:File = File.applicationDirectory.resolvePath(currentFileName);
			var storageFile:File = File.applicationStorageDirectory.resolvePath(currentFileName);
			
			if (sourceFile.exists)
			{
				if ( !storageFile.exists || sourceFileChanged(sourceFile, storageFile) ) 
				{
					sourceFile.copyTo(storageFile);
				}
			}
				
			onFileCreated();
		}
		
		private function sourceFileChanged(sourceFile : File, storageFile : File) : Boolean
		{
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
					currentFileName = cssImage1;
					loadFile();
					break;
				}
					
				case cssImage1:
				{
					currentFileName = cssImage2;
					loadFile();
					break;
				}
					
				case cssImage2:
				{
					dispatchEvent(new Event(STYLE_SETTED));
					break;
				}
				
				default:
				{
					dispatchEvent(new Event(STYLE_SETTED));
					break;
				}
			}
			
		}
		
	}
}