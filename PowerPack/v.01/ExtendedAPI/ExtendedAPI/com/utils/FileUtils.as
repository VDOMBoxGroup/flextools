package ExtendedAPI.com.utils
{
	import mx.utils.StringUtil;
	
	public class FileUtils
	{
		/*
		* 	isRootFolder
		* 	@param	folderPath path to a  folder to check
		* 	@description that function check if folder passed in argument
		* 	is a root folder, allowable root folders prints for Windows are
		* 	"a:/", "b:/", ..., "z:/" (a-z)
		*/
		static public function isRootFolder (folderPath : String) : Boolean
		{
			folderPath = folderPath.split ("\\").join ("/");
			var rootCharCode : Number = folderPath.charAt (0).toLowerCase ().charCodeAt (0);
			var isRoot : Boolean = (rootCharCode >= 97 && rootCharCode <= 122) && (folderPath.length == 3) && (folderPath.lastIndexOf (":/") == 1);
			return isRoot;
		}
		
		/*
		* 	getParentFolder
		* 	@param folderPath a path to folder from which we need to extract
		* 	parent directory. If there is no parent directory that function
		* 	return original folder
		*/
		static public function getParentFolder (folderPath : String) : String
		{
			if (isRootFolder (folderPath))
			{
				return folderPath;
			}
			folderPath = folderPath.split ("\\").join ("/");
			folderPath = (folderPath.substr ( - 1) == "/") ? folderPath.substr (0, folderPath.length - 1) : folderPath;
			folderPath = folderPath.substr (0, folderPath.lastIndexOf ("/") + 1);
			return folderPath;
		}

		static public function isAbsPath (folderPath : String) : Boolean
		{
			folderPath = folderPath.split ("\\").join ("/");
			var rootCharCode : Number = folderPath.charAt (0).toLowerCase ().charCodeAt (0);
			var isAbsPath : Boolean = (rootCharCode >= 97 && rootCharCode <= 122) && (folderPath.lastIndexOf (":/") == 1);
			return isAbsPath;
		}			
		
		public static function pathToUrl(value:String):String
		{
			value = value.split ("\\").join ("/");
			return (isAbsPath(value) ? "file:///" : "app:/") + value;
		}

		public static function isValidFileName(filename:String):Boolean
		{
			var str:String;			
			var pattern:RegExp;
			
			str = StringUtil.trim(filename);

			if(str.length==0)
				return false;			

  			pattern = /([\\\/\|\?\"*:><]|^\.)/;
  			
  			if(pattern.test(str))
  				return false;

			return true;			
		}		
		
		public static function isValidPath(fullpath:String):Boolean
		{
			var str:String;			
			var pattern:RegExp;
			var files:Array;
			
			str = StringUtil.trim(fullpath);

  			pattern = /(\\|\/){2,}/;
  			
  			if(pattern.test(str))
  				return false;
			
			str = str.split ("\\").join ("/");
			
			files = str.split ("/");
			
			for(var i:int=0; i<files.length; i++)
			{
				if(	!(i==0 && isRootFolder(files[i]+"/")) &&
					!isValidFileName(files[i]))	
					return false;
			}			
			
			return true;			
		}		

		public static function getFileName(path:String):String
		{
			var str:String;			
			var pattern:RegExp;
			
			str = StringUtil.trim(path);
			
			if(str.length==0)
				return null;
			
			pattern = /[\\\/]([^\\\/])+$/;			   	
		   	
		    var index:int = str.search(pattern);
			
			if(index>=0)
			{
				str = str.substring(index+1);
			}	
			
			if(isValidFileName(str))
			{
				return str;
			}
			
			return null;
		}
			
		public static function getPath(fullpath:String):String
		{
			var str:String;			
			var pattern:RegExp;
			
			str = StringUtil.trim(fullpath);
			
			if(str.length==0)
				return str;
			
			pattern = /[\\\/]([^\\\/])+$/;			   	
		   	
		    var index:int = str.search(pattern);
			
			if(index>=0)
			{
				str = str.substring(0, index+1);
			}	
			
			if(isValidPath(str))
			{
				return str;
			}
			
			return null;
		}
	}
}