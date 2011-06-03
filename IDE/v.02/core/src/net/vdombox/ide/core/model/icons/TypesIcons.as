package net.vdombox.ide.core.model.icons
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	
	public class TypesIcons
	{	
		public var icon:Array = new Array();
		
		//		[Embed("assets/delete.png")]
		//		private var disclosureOpenIcon:Class;
		
//		[Embed(source="assets/resourceBrowserIcons/resourceType/avi.png")]
//		public var avi_Icon:Class;
		
		private static const avi_Icon 	: String = "./assets/resourceBrowserIcons/resourceType/avi.png";
		private static const bin_Icon	: String = "./assets/resourceBrowserIcons/resourceType/bin.png";
		private static const blank_Icon	: String = "./assets/resourceBrowserIcons/resourceType/blank.png";
		private static const bmp_Icon	: String = "./assets/resourceBrowserIcons/resourceType/bmp.png";
		private static const c_Icon		: String = "./assets/resourceBrowserIcons/resourceType/c.png";
		private static const cfg_Icon 	: String = "./assets/resourceBrowserIcons/resourceType/cfg.png";
		private static const cpp_Icon 	: String = "./assets/resourceBrowserIcons/resourceType/cpp.png";
		private static const css_Icon	: String = "./assets/resourceBrowserIcons/resourceType/css.png";
		private static const dll_Icon 	: String = "./assets/resourceBrowserIcons/resourceType/dll.png";
		private static const doc_Icon 	: String = "./assets/resourceBrowserIcons/resourceType/doc.png";
		private static const dvi_Icon 	: String = "./assets/resourceBrowserIcons/resourceType/dvi.png";
		private static const gif_Icon 	: String = "./assets/resourceBrowserIcons/resourceType/gif.png";
		private static const htm_Icon 	: String = "./assets/resourceBrowserIcons/resourceType/htm.png";
		private static const mid_Icon	: String = "./assets/resourceBrowserIcons/resourceType/mid.png";
		private static const pdf_Icon	: String = "./assets/resourceBrowserIcons/resourceType/pdf.png";
		private static const swf_Icon 	: String = "./assets/resourceBrowserIcons/resourceType/swf.png";
		private static const txt_Icon 	: String = "./assets/resourceBrowserIcons/resourceType/txt.png";
		private static const wav_Icon 	: String = "./assets/resourceBrowserIcons/resourceType/wav.png";
		private static const xls_Icon	: String = "./assets/resourceBrowserIcons/resourceType/xls.png";
		
		private static const file_broken_Icon : String = "assets/resourceBrowserIcons/resourceType/file_broken.png";
		
				
		//		[Embed(source="/assets/common/spinner.swf")]
		//		public var spinner:Class;
		//
		//		[Embed(source="/assets/common/box.swf")]
		//		public var spinnerbox:Class;
		
		public function TypesIcons()
		{
			icon["avi"]	= avi_Icon;
			icon["bin"]	= bin_Icon;
			icon["blank"] = blank_Icon;
			icon["bmp"]	= bmp_Icon;
			icon["c"]	= c_Icon;			
			icon["cfg"]	= cfg_Icon;
			icon["cpp"]	= cpp_Icon;
			icon["css"]	= css_Icon;
			icon["dll"]	= dll_Icon;
			icon["doc"]	= doc_Icon;
			icon["docx"]= doc_Icon;
			icon["dvi"]	= dvi_Icon;
			icon["gif"]	= gif_Icon;
			icon["htm"]	= htm_Icon;
			icon["html"]= htm_Icon;			
			icon["mht"]	= htm_Icon;
			icon["mid"]	= mid_Icon;
			icon["None"]= blank_Icon;
			icon["pdf"]	= pdf_Icon;
			icon["swf"]	= swf_Icon;
			icon["txt"]	= txt_Icon;
			icon["wav"]	= wav_Icon;
			icon["xls"]	= xls_Icon;
			icon["xlsx"]= xls_Icon;
		}
		
		public function getResource( path : String ) : ByteArray
		{
			var file:File = new File( File.applicationDirectory.resolvePath( path ).nativePath );

			var stream:FileStream = new FileStream();
			if ( file )
			{
				stream.open(file, FileMode.UPDATE); 
							
				var leng: int = stream.bytesAvailable;
				var data:String = stream.readUTFBytes(leng);//error return ""
				
				stream.close();	
				
				return data as ByteArray;
			}
			
			return null;
//			goalStream.writeUTFBytes(name);//дозаписывает в файл				
		}
			
		public function isViewable ( extension : String ) : Boolean 
		{
			switch (extension.toLowerCase()) 
			{
				case "jpg":					
				case "jpeg":					
				case "png":
				case "gif":
				case "svg":
					return true;
					
				default:
					return false;
			}
		}
	}
}