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
		
		
	}
}