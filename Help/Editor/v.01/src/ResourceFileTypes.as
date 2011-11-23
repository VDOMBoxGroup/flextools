package
{
	import flash.filesystem.File;

	public class ResourceFileTypes
	{
		public static const FILE_TYPE_PNG	: String = ".png";
		public static const FILE_TYPE_JPG	: String = ".jpg";
		public static const FILE_TYPE_JPEG	: String = ".jpeg";
		public static const FILE_TYPE_GIF	: String = ".gif";
		public static const FILE_TYPE_BMP	: String = ".bmp";
		
		public function ResourceFileTypes()
		{
		}
		
		public static function isImageFile(file:File) : Boolean
		{
			if (!file || !file.exists || !file.type)
				return false;
			
			switch(file.type.toLowerCase())
			{
				case ResourceFileTypes.FILE_TYPE_BMP:
				case ResourceFileTypes.FILE_TYPE_GIF:
				case ResourceFileTypes.FILE_TYPE_JPEG:
				case ResourceFileTypes.FILE_TYPE_JPG:
				case ResourceFileTypes.FILE_TYPE_PNG:
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