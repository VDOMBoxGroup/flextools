package
{
	public class Utils
	{
		public static const KB : Number = 1024;
		
		public static const FLOAT_DELIMETR : String = ".";
		
		
		public function Utils()
		{
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