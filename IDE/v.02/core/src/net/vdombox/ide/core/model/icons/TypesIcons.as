package net.vdombox.ide.core.model.icons
{
	public class TypesIcons
	{		
		public function TypesIcons()
		{
			icon["avi"]	= avi_Icon;
			icon["bin"]	= bin_Icon;
			icon["bmp"]	= bmp_Icon;
			icon["c"]	= c_Icon;
			icon["css"]	= css_Icon;
			icon["cfg"]	= cfg_Icon;
			icon["cpp"]	= cpp_Icon;
			icon["dll"]	= dll_Icon;
			icon["doc"]	= doc_Icon;
			icon["docx"]= doc_Icon;
			icon["dvi"]	= dvi_Icon;
			icon["gif"]	= gif_Icon;
			icon["htm"]	= htm_Icon;
			icon["html"]= htm_Icon;
			icon["mht"]	= htm_Icon;
			icon["swf"]	= swf_Icon;
			icon["pdf"]	= pdf_Icon;
			icon["txt"]	= txt_Icon;
			icon["mid"]	= mid_Icon;
			icon["xls"]	= xls_Icon;
			icon["xlsx"]= xls_Icon;
			icon["wav"]	= wav_Icon;
		}
		
		public function isViewable ( extension : String ) : Boolean {
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
				
		public var icon:Array = new Array();
		
//		[Embed("assets/delete.png")]
//		private var disclosureOpenIcon:Class;
		
		[Embed(source="assets/resourceBrowserIcons/resourceType/avi.png")]
		public var avi_Icon:Class;
		
		[Embed(source="assets/resourceBrowserIcons/resourceType/bin.png")]
		public var bin_Icon:Class;
		
		[Embed(source="assets/resourceBrowserIcons/resourceType/blank.png")]
		public var blank_Icon:Class;
		
		[Embed(source="assets/resourceBrowserIcons/resourceType/bmp.png")]
		public var bmp_Icon:Class;
		
		[Embed(source="assets/resourceBrowserIcons/resourceType/c.png")]
		public var c_Icon:Class;
		
		[Embed(source="assets/resourceBrowserIcons/resourceType/css.png")]
		public var css_Icon:Class;
		
		[Embed(source="assets/resourceBrowserIcons/resourceType/cfg.png")]
		public var cfg_Icon:Class;
		
		[Embed(source="assets/resourceBrowserIcons/resourceType/cpp.png")]
		public var cpp_Icon:Class;
		
		[Embed(source="assets/resourceBrowserIcons/resourceType/dll.png")]
		public var dll_Icon:Class;
		
		[Embed(source="assets/resourceBrowserIcons/resourceType/doc.png")]
		public var doc_Icon:Class;
		
		[Embed(source="assets/resourceBrowserIcons/resourceType/dvi.png")]
		public var dvi_Icon:Class;
		
		[Embed(source="assets/resourceBrowserIcons/resourceType/gif.png")]
		public var gif_Icon:Class;
		
		[Embed(source="assets/resourceBrowserIcons/resourceType/htm.png")]
		public var htm_Icon:Class;
		
		[Embed(source="assets/resourceBrowserIcons/resourceType/swf.png")]
		public var swf_Icon:Class;
		
		[Embed(source="assets/resourceBrowserIcons/resourceType/pdf.png")]
		public var pdf_Icon:Class;
		
		[Embed(source="assets/resourceBrowserIcons/resourceType/txt.png")]
		public var txt_Icon:Class;
		
		[Embed(source="assets/resourceBrowserIcons/resourceType/mid.png")]
		public var mid_Icon:Class;
		
		[Embed(source="assets/resourceBrowserIcons/resourceType/xls.png")]
		public var xls_Icon:Class;
		
		[Embed(source="assets/resourceBrowserIcons/resourceType/wav.png")]
		public var wav_Icon:Class;
		
		[Embed(source="assets/resourceBrowserIcons/resourceType/file_broken.png")]
		public var broken_Icon:Class;

//		[Embed(source="/assets/common/spinner.swf")]
//		public var spinner:Class;
//
//		[Embed(source="/assets/common/box.swf")]
//		public var spinnerbox:Class;

	}
}