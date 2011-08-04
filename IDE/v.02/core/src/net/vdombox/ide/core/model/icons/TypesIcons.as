package net.vdombox.ide.core.model.icons
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
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
	
	public class TypesIcons extends EventDispatcher
	{	
		public static const ICON_LOADING_COMPLETED:String = "iconLoadingCompleted";
		public static const ICON_LOADING_ERROR:String	  = "iconLoadingError";
		
		public var icon:Array = new Array();
		
		//		[Embed("assets/delete.png")]
		//		private var disclosureOpenIcon:Class;
		
//		[Embed(source="assets/resourceBrowserIcons/resourceType/avi.png")]
//		public var avi_Icon:Class;
		
		private static const avi_Icon 	: String = "resourceBrowserIcons/resourceType/avi.png";
		private static const bin_Icon	: String = "resourceBrowserIcons/resourceType/bin.png";
		private static const blank_Icon	: String = "resourceBrowserIcons/resourceType/blank.png";
		private static const bmp_Icon	: String = "resourceBrowserIcons/resourceType/bmp.png";
		private static const c_Icon		: String = "resourceBrowserIcons/resourceType/c.png";
		private static const cfg_Icon 	: String = "resourceBrowserIcons/resourceType/cfg.png";
		private static const cpp_Icon 	: String = "resourceBrowserIcons/resourceType/cpp.png";
		private static const css_Icon	: String = "resourceBrowserIcons/resourceType/css.png";
		private static const dll_Icon 	: String = "resourceBrowserIcons/resourceType/dll.png";
		private static const doc_Icon 	: String = "resourceBrowserIcons/resourceType/doc.png";
		private static const dvi_Icon 	: String = "resourceBrowserIcons/resourceType/dvi.png";
		private static const gif_Icon 	: String = "resourceBrowserIcons/resourceType/gif.png";
		private static const htm_Icon 	: String = "resourceBrowserIcons/resourceType/htm.png";
		private static const java_Icon 	: String = "resourceBrowserIcons/resourceType/java.png";
		private static const mid_Icon	: String = "resourceBrowserIcons/resourceType/mid.png";
		private static const pdf_Icon	: String = "resourceBrowserIcons/resourceType/pdf.png";
		private static const swf_Icon 	: String = "resourceBrowserIcons/resourceType/swf.png";
		private static const txt_Icon 	: String = "resourceBrowserIcons/resourceType/txt.png";
		private static const wav_Icon 	: String = "resourceBrowserIcons/resourceType/wav.png";
		private static const xls_Icon	: String = "resourceBrowserIcons/resourceType/xls.png";
		
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
//			f
//			file_broken
			icon["gif"]	= gif_Icon;
//			h
//			hlp
//			img
//			ini
			icon["jv"]	= java_Icon;
			icon["htm"]	= htm_Icon;
			icon["html"]= htm_Icon;			
			icon["mht"]	= htm_Icon;
//			mdb
//			mov
//			mp3
//			mpj
			icon["mid"]	= mid_Icon;
			icon["None"]= blank_Icon;
//			nfo
//			o
//			ogg
//			p
			icon["pdf"]	= pdf_Icon;
//			php
//			png
//			ppt
//			ps
//			psd
//			pst
//			py
//			rar
//			real
//			reg
//			rpm
//			s
//			sh			
			icon["swf"]	= swf_Icon;
//			tar
//			tex
//			tgz
//			tiff
//			tmp
//			ttf
			icon["txt"]	= txt_Icon;
			icon["wav"]	= wav_Icon;
//			wma
//			wmv
//			www
			icon["xls"]	= xls_Icon;
			icon["xlsx"]= xls_Icon;
//			y
//			zip
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
			
		}
		
		public function fileDounloaded( event : Event ):void
		{
			//			var file : File = event.currentTarget as File;
			if (file)
			{
				try
				{
					data = file.data;
				}
				catch (error : Error)
				{
					trace("Failed: was changed path.", error.message);
					data = null;
				}
				this.dispatchEvent(new Event(ICON_LOADING_COMPLETED));
			}
		}			

		
		
		public function ioErrorHandler( event : IOErrorEvent ) : void
		{
			data = null;
			this.dispatchEvent(new Event(ICON_LOADING_ERROR));
		}
		
	}
}