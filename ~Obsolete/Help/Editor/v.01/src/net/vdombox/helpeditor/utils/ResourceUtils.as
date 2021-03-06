package net.vdombox.helpeditor.utils
{
	import com.adobe.crypto.MD5Stream;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.PixelSnapping;
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	import mx.graphics.codec.PNGEncoder;
	import mx.utils.UIDUtil;

	public class ResourceUtils extends EventDispatcher
	{
		public static const FILE_TYPE_PNG	: String = "png";
		public static const FILE_TYPE_JPG	: String = "jpg";
		public static const FILE_TYPE_JPEG	: String = "jpeg";
		public static const FILE_TYPE_GIF	: String = "gif";
		public static const FILE_TYPE_BMP	: String = "bmp";
		
		private static var instance : ResourceUtils;
		
		public static const HTTP_IMAGE_LOADED : String = "httpImageLoaded";
		
		public function ResourceUtils()
		{
			if ( instance )
				throw new Error( "Instance already exists." );
		}
		
		public static function getInstance() : ResourceUtils
		{
			if ( !instance )
			{
				instance = new ResourceUtils();
			}
			
			return instance;
		}
		
		public function loadHttpImg(aImageOldSrc_str:String) : String
		{
			trace ("loadHttpImg");
			
			var targetPath : String;
			var urlRequest : URLRequest;
			var urlLoader : URLLoader;
			var file : File;
			
			
			targetPath = "resources/" + generateFileNameByDefault(aImageOldSrc_str);
			urlRequest = new URLRequest(aImageOldSrc_str);
			urlLoader = new URLLoader();
			
			urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
			
			urlLoader.addEventListener(Event.COMPLETE, urlLoader_complete);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, urlLoader_error);
			urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, urlLoader_error);
			
			urlLoader.load(urlRequest);
			
			file = File.applicationStorageDirectory.resolvePath(targetPath);
			
			var ths:ResourceUtils = this;
			
			function urlLoader_complete(evt:Event) : void 
			{
				var fileStream : FileStream;
				
				fileStream = new FileStream();
				try {
					fileStream.open(file, FileMode.WRITE);
					fileStream.writeBytes(urlLoader.data);
					fileStream.close();
					
					ths.dispatchEvent(new Event(HTTP_IMAGE_LOADED));
					
				} catch ( error : IOError ) {
					trace("!!! Error Write !!! \n" + error.message +"\n");
					ths.dispatchEvent(new Event(HTTP_IMAGE_LOADED));
					return;
				}
			}
			
			function urlLoader_error(evt:Event) : void {
				trace("!!! Error Loading file !!! \n");
				ths.dispatchEvent(new Event(HTTP_IMAGE_LOADED));
			}
			
			return file.url;
		}
		
		public function copyImg(aImageOldSrc_str:String) : String
		{
			var targetPath : String;
			var imgFile : File;
			var newImgFile : File;
			
			if (!aImageOldSrc_str)
				return null;
			
			imgFile = new File(aImageOldSrc_str);
			
			if (!imgFile.exists)
				return null;
			
			targetPath = "resources/" + generateFileNameBySourceFile(imgFile);
			newImgFile = File.applicationStorageDirectory.resolvePath(targetPath);
			
			
			if ( !newImgFile.exists || Utils.identicalFiles(imgFile, newImgFile))
				imgFile.copyTo(newImgFile, true);
			
			return newImgFile.url;
		}
		
		public static function generateFileNameByDefault(filePath : String = "") : String
		{
			var regExp : RegExp = /\W[0-9_]/;
			
			var lastDotIndex : int = filePath.lastIndexOf(".");
			
			var fileName : String = UIDUtil.createUID();
			
			var fileType : String = filePath.substring(lastDotIndex, filePath.length);
			
			if (fileType.search(regExp) >= 0)
				fileType = "";
				
			return fileName + fileType;
		}
		
		public static function generateFileNameBySourceFile(file : File) : String
		{
			if (!fileExists(file))
				return generateFileNameByDefault();
			
			var fileTargetName	: String;
			var hash			: MD5Stream;
			var fileStream		: FileStream;
			var byteArray		: ByteArray;
			var uid				: String;
			
			hash = new MD5Stream();
			fileStream = new FileStream();
			byteArray = new ByteArray();
			
			fileStream.open(file, FileMode.READ);
			fileStream.readBytes(byteArray);
			fileStream.close();
			
			uid = hash.complete(byteArray);
			
			fileTargetName = convertToUIDFormat(uid) + file.type;
			
			return fileTargetName;
		}
		
		public static function generateFileNameByBitmapData(bitmapData : BitmapData) : String
		{
			var pngEncoder	: PNGEncoder = new PNGEncoder();
			var byteArray	: ByteArray = pngEncoder.encode(bitmapData);
			
			var hash		: MD5Stream = new MD5Stream();
			var uid			: String = hash.complete(byteArray);;
			
			var fileName 	: String = convertToUIDFormat(uid) + "." + FILE_TYPE_JPG;
			
			return fileName;
		}
		
		public static function fileExists(file:File) : Boolean
		{
			return file && file.exists;
		}
		
		public static function convertToUIDFormat(strToFormat:String) : String
		{
			var strInUIDFormat : String = "";
			var strDelim : String       = "-";
			var arrParts : Array        = new Array();
			
			if ( strToFormat.length != 32 )
				throw Error("Incorrect type of input string");
			else
			{
				arrParts[ 0 ] = strToFormat.substr(0, 8);
				arrParts[ 1 ] = strToFormat.substr(8, 4);
				arrParts[ 2 ] = strToFormat.substr(12, 4);
				arrParts[ 3 ] = strToFormat.substr(16, 4);
				arrParts[ 4 ] = strToFormat.substr(20, 12);
				
				for ( var i : uint = 0; i < 5; i++ )
				{
					if ( i > 0 )
						strInUIDFormat += strDelim;
					
					strInUIDFormat += arrParts[ i ];
				}
			}
			
			return strInUIDFormat;
		}
	
		public function createResourceFromBitmapData (bitmapData : BitmapData) : File
		{
			var targetPath: String = "resources/" + generateFileNameByBitmapData(bitmapData);
			var imageFile : File = File.applicationStorageDirectory.resolvePath(targetPath);
			
			var pngEncoder : PNGEncoder = new PNGEncoder();
			var byteArray : ByteArray = pngEncoder.encode(bitmapData);
			
			var fileStream : FileStream = new FileStream();
			try
			{
				fileStream.open( imageFile, FileMode.WRITE );
				fileStream.writeBytes( byteArray );
				fileStream.close();
			}
			catch ( error : Error )
			{
				return null;
			}
			
			return imageFile;
		}
		
		public static function filterResources(resources : Array) : Array
		{
			var filteredResources : Array = [];
			for each (var resource:String in resources)
			{
				var resourceType : String = resource.substr(37);
				
				if (correctResourceType(resourceType))
					filteredResources.push(resource);
			}
			
			return filteredResources;
		}
		
		public static function isImageFile(file:File) : Boolean
		{
			if (!file || !file.exists || !file.type)
				return false;
			
			return correctResourceType(file.extension.toLowerCase());
		}
		
		
		public static function correctResourceType(resourceType : String) : Boolean
		{
			switch (resourceType)
			{
				case FILE_TYPE_BMP:
				case FILE_TYPE_GIF:
				case FILE_TYPE_JPEG:
				case FILE_TYPE_JPG:
				case FILE_TYPE_PNG:
				{
					return true;
				}
					
				default:
				{
					return false;
				}
			}
			
		}
		
	}
}