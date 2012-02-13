package net.vdombox.powerpack.lib.extendedapi.utils
{
	import flash.filesystem.File;
	import flash.system.Capabilities;
	
	import mx.utils.StringUtil;
	
	public class FileUtils
	{
		public static const FILE_FORMAT_JPG		: String = "jpg";
		public static const FILE_FORMAT_JPEG	: String = "jpeg";
		public static const FILE_FORMAT_BMP		: String = "bmp";
		public static const FILE_FORMAT_PNG		: String = "png";
		public static const FILE_FORMAT_GIF		: String = "gif";
		public static const FILE_FORMAT_SVG		: String = "svg";
		
		public static const OS_LINUX	: String = "LIN";
		public static const OS_WINDOWS	: String = "WIN";
		public static const OS_MAC		: String = "MAC";
		
		
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
  			
  			return !pattern.test( str );
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
		
		public static function correctImageFile (file : File) : Boolean
		{
			return file && file.exists && isImageFileFormat(file);
		}
		
		public static function isImageFileFormat (file : File) : Boolean
		{
			if (!file)
				return false;
			
			if (file.isDirectory || file.isPackage || file.isSymbolicLink)
				return false;
			
			var fileExtension	: String = file.extension;
			
			// if ( aaa in array)
			switch ( fileExtension.toLowerCase() )
			{
				case FILE_FORMAT_BMP:
				case FILE_FORMAT_PNG:
				case FILE_FORMAT_GIF:
				case FILE_FORMAT_SVG:
				case FILE_FORMAT_JPG:
				case FILE_FORMAT_JPEG:
					return true;
					
				default:
					return false;
			}
			
			
			return false;
		}
		
		public static function getImagesFileExtension () : String
		{
			// for  ( fileformat in array) 
			
			var strExtension : String = "";
			
			strExtension += "*." + FILE_FORMAT_BMP + ";";
			strExtension += "*." + FILE_FORMAT_PNG + ";";
			strExtension += "*." + FILE_FORMAT_GIF + ";";
			strExtension += "*." + FILE_FORMAT_SVG + ";";
			strExtension += "*." + FILE_FORMAT_JPG + ";";
			strExtension += "*." + FILE_FORMAT_JPEG;
		
			return strExtension;
		}
		
		private static function get OS () : String
		{
			return Capabilities.os.substr(0, 3).toUpperCase();
		}
		
		public static function get cmdFile() : File
		{
			// returt  (OS == OS_WINDOWS) ?   windowsCmdFile : new File("/bin/sh");
			switch (OS) 
			{
				case OS_WINDOWS :
				{
					return windowsCmdFile;
				}
				case OS_LINUX:
				{
					return new File("/bin/sh");
				}
				case OS_MAC:
				{
					return new File("/bin/sh");
				}
			}
			
			return null;
		}
		
		public static function get batFileExtension () : String
		{
			// returt  (OS == OS_WINDOWS) ?   "bat" :  "sh";
			switch (OS) 
			{
				case OS_WINDOWS :
				{
					return "bat";
				}
				case OS_LINUX:
				{
					return "sh";
				}
				case OS_MAC:
				{
					return "sh";
				}
			}
			return "bat";
		}
		
		private static function get windowsCmdFile() : File
		{
			var rootDirs:Array = File.getRootDirectories();
			var consoleExecutable : File;
			
			for (var i:int = 0; i < rootDirs.length; ++i) 
			{
				consoleExecutable = rootDirs[i] as File;
				consoleExecutable  = consoleExecutable.resolvePath("Windows");
				
				if (consoleExecutable.exists == true) 
				{
					consoleExecutable = consoleExecutable.resolvePath("System32");
					consoleExecutable = consoleExecutable.resolvePath("cmd.exe");
					
					return consoleExecutable;                                    
				}                   
			}
			
			return null;
		}
		
		public static function convertPathForCMD(path : String, useQoutesBetweenSlashes:Boolean = false) : String
		{
			var delim : String = "/";
			var regExpDoubleBackSlashes : RegExp = /\\\\/g;
			var regExpDoubleSlashes : RegExp = /\\/g;
			
			path = path.replace(regExpDoubleBackSlashes, delim);
			path = path.replace(regExpDoubleSlashes, delim);
			
			if (!useQoutesBetweenSlashes && path.indexOf(" ") >= 0)
			{
				return "\"" + path + "\""; 
			}
			
			var pathParts : Array = path.split(delim);
			
			if (!pathParts || pathParts.length == 0)
				return path;
			
			for (var i:int; i<pathParts.length; i++)
			{
				if (pathParts[i].indexOf(" ") >= 0)
					pathParts[i] = "\"" + pathParts[i] + "\"";
			}
			
			return pathParts.join(delim);
		}
		
		
		public static function filePathExists (filePath : String, isDirectory : Boolean) : Boolean
		{
			try
			{
				var file : File = new File(filePath);
			}
			catch (e:Error)
			{
				return false;
			}
			
			return fileExists(file, isDirectory);
		}
		
		public static function fileExists (file : File, isDirectory : Boolean) : Boolean
		{
			if ( !file || !file.exists )
				return false;
			
			return file.isDirectory == isDirectory;
		}
		
		public static function isXMLFile (file : File) : Boolean
		{
			if ( !file || !file.exists )
				return false;
			
			return file.extension.toLowerCase() == "xml";
		}
		
		public static function getFileByPath (path : String) : File
		{
			try
			{
				var file : File = new File(path);
			}
			catch (e:Error)
			{
				return null;
			}
			
			return file.exists ? file : null;
		}
		
		
	}
}