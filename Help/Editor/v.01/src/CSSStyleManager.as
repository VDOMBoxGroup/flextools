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
				if ( !storageFile.exists || Utils.sourceFileChanged(sourceFile, storageFile) ) 
				{
					sourceFile.copyTo(storageFile, true);
				}
			}
				
			onFileCreated();
		}
		
		private function onFileCreated():void
		{
			trace ("[CSSStyleManager] onFileCreated");
			switch(currentFileName)
			{
				case cssFileName:
				{
					currentFileName = cssImagesFolder;
					var  file : File = File.applicationDirectory.resolvePath(currentFileName) 
					if (file && file.isDirectory)
						imagesDirectoryContent = file.getDirectoryListing();
					
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