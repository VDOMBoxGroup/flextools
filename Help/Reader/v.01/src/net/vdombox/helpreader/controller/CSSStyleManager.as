package net.vdombox.helpreader.controller
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
	import net.vdombox.helpreader.utils.Utils;
	
	public class CSSStyleManager extends EventDispatcher
	{
		public static const STYLE_SETTED	: String = "styleSetted";
		
		private const JSFileName		: String = "searchhi_slim.js";
		
		private const cssFileName				: String = "main.css";
		private const cssImagesFolder			: String = "images";
		
		private const syntaxHighliterJSFolder	: String = "assets/syntax_highlighter/js";
		private const syntaxHighliterCSSFolder	: String = "assets/syntax_highlighter/css";
		
		
		private var currentFileName		: String = "";
		
		private var directoryContent : Array;
		
		private var fileStream : FileStream = new FileStream();
		
		private var img : Image = new Image();
		
		public function CSSStyleManager()
		{
		}
		
		public function setStyle():void
		{
			directoryContent = [];
			currentFileName = JSFileName;
			loadFile();
		}
		
		private function loadFile(fileFromDirectory : Boolean = false):void
		{
			var sourceFile	: File;
			var storageFile	: File;
			
			if (fileFromDirectory)
			{	
				sourceFile = File(directoryContent.pop());
				storageFile = File.applicationStorageDirectory.resolvePath(currentFileName+"/"+sourceFile.name);
			} else 
			{
				sourceFile = File.applicationDirectory.resolvePath(currentFileName);
				storageFile = File.applicationStorageDirectory.resolvePath(currentFileName);
			}
			
			if (!sourceFile.isDirectory && sourceFile.exists)
			{
				if ( !storageFile.exists || Utils.identicalFiles(sourceFile, storageFile) ) 
				{
					sourceFile.copyTo(storageFile, true);
				}
			}
			
			onFileCreated();
		}
		
		private function onFileCreated():void
		{
			switch(currentFileName)
			{
				case JSFileName:
				{
					currentFileName = cssFileName;
					loadFile();
					break;
				}
				case cssFileName:
					currentFileName = cssImagesFolder;
					
					addDirectoryContent();
					loadFile(true);
					break;
				case cssImagesFolder:
				{
					if (isEmptyDirectory)
					{
						currentFileName = syntaxHighliterJSFolder;
						
						addDirectoryContent();
					}
					loadFile(true);
					break;
				}
					
				case syntaxHighliterJSFolder:
				{
					if (isEmptyDirectory)
					{
						currentFileName = syntaxHighliterCSSFolder;
						
						addDirectoryContent();
					}
					loadFile(true);
					break;
				}
					
				default:
				{
					if (isEmptyDirectory)
					{
						dispatchEvent(new Event(STYLE_SETTED));
						return;
					}
					loadFile(true);
					return;
				}
			}
			
			
		}
		
		private function get isEmptyDirectory() : Boolean
		{
			return !directoryContent || directoryContent.length == 0;
		}
		
		private function addDirectoryContent():void
		{
			var  file : File = File.applicationDirectory.resolvePath(currentFileName);
			
			if (file && file.isDirectory)
				directoryContent = file.getDirectoryListing();
		}
		
	}
}