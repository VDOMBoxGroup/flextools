package net.vdombox.ide.core.model.icons
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	
	import mx.binding.utils.BindingUtils;
	import mx.controls.Alert;
	import mx.utils.Base64Decoder;
	
	import net.vdombox.ide.common.vo.ResourceVO;
	
	public class TypesIcons
	{	
		public var icon:Array = new Array();
		
		//		[Embed("assets/delete.png")]
		//		private var disclosureOpenIcon:Class;
		
//		[Embed(source="assets/resourceBrowserIcons/resourceType/avi.png")]
//		public var avi_Icon:Class;
		
		private static const avi_Icon 	: String = "./../assets/resourceBrowserIcons/resourceType/avi.png";
		private static const bin_Icon	: String = "./assets/resourceBrowserIcons/resourceType/bin.png";
		private static const blank_Icon	: String = "resourceBrowserIcons/resourceType/blank.png";
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
		
		private var file : File 	  = new File();
		public  var data : ByteArray  = null;
		public  var res  : ResourceVO = null;
				
		public function getResource( type : String ) : void
		{	
			var path : String;
			
			if ( icon[ type ] != null )
				path = icon[ type ]; 
			else 
				path = icon[ "blank" ]; //default icon
			
//			var file:File = new File( File.applicationDirectory.resolvePath( path ).nativePath );
			file = new File( File.applicationDirectory.resolvePath( path ).nativePath );

			file.addEventListener(Event.COMPLETE, fileDounloaded);			
			file.addEventListener( IOErrorEvent.DISK_ERROR, ioErrorHandler);
			file.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler);
			file.load();
			
			function fileDounloaded( event : Event ):void
			{
				//			var file : File = event.currentTarget as File;
				if (file)
				{
					try
					{
						data = file.data;
//						res.icon = file.data;
					}
					catch (error : Error)
					{
						trace("Failed: was changed path.", error.message);				
					}
				}
			}			
//			
//			return null;
		}
		
		
		public function ioErrorHandler( event : IOErrorEvent ) : void
		{
			trace("========================================================= error =========================================");
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