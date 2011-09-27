package
{
	import com.adobe.crypto.MD5Stream;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.PixelSnapping;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Matrix;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	import mx.graphics.codec.PNGEncoder;
	

	public class Utils
	{
		public static const KB : Number = 1024;
		
		public static const FLOAT_DELIMETR : String = ".";
		
		public function Utils()
		{
		}
		
		public static function sourceFileChanged(sourceFile : File, storageFile : File) : Boolean
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
		
		public static function formatFileSize (size:Number) : String
		{
			var fileSizeStr : String = size.toString();
			
			var gig : Number      = Math.pow(KB, 3);
			var meg : Number      = Math.pow(KB, 2);
			var kil : Number      = KB;
			
			if ( size > gig )
				fileSizeStr = getCorrectSizeValue(size / gig) + " Gb";
			else if ( size > meg )
				fileSizeStr = getCorrectSizeValue(size / meg) + " Mb";
			else if ( size > kil )
				fileSizeStr = getCorrectSizeValue(size / kil) + " Kb";
			else
				fileSizeStr = size.toString() + " bytes";
			
			function getCorrectSizeValue (actualSize : Number) : String
			{
				var floatPart : String = actualSize.toString().split(FLOAT_DELIMETR)[1]; // get part after dot
				
				if (!floatPart || floatPart == "0" || floatPart.length <= 2)
					return actualSize.toString();
				
				
				return int(actualSize).toString() + "." + floatPart.substr(0, 2);
			}
			
			return fileSizeStr;
		}
		
		
	}
}