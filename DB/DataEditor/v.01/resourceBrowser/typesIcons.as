// ActionScript file

private var typesIcons:Array = new Array(); 

[Embed(source="/assets/resourceBrowserIcons/resourceType/avi.png")]
private var avi_Icon:Class;

[Embed(source="/assets/resourceBrowserIcons/resourceType/bin.png")]
private var bin_Icon:Class;

[Embed(source="/assets/resourceBrowserIcons/resourceType/blank.png")]
private var blank_Icon:Class;

[Embed(source="/assets/resourceBrowserIcons/resourceType/bmp.png")]
private var bmp_Icon:Class;

[Embed(source="/assets/resourceBrowserIcons/resourceType/c.png")]
private var c_Icon:Class;

[Embed(source="/assets/resourceBrowserIcons/resourceType/css.png")]
private var css_Icon:Class;

[Embed(source="/assets/resourceBrowserIcons/resourceType/cfg.png")]
private var cfg_Icon:Class;

[Embed(source="/assets/resourceBrowserIcons/resourceType/cpp.png")]
private var cpp_Icon:Class;

[Embed(source="/assets/resourceBrowserIcons/resourceType/dll.png")]
private var dll_Icon:Class;

[Embed(source="/assets/resourceBrowserIcons/resourceType/doc.png")]
private var doc_Icon:Class;

[Embed(source="/assets/resourceBrowserIcons/resourceType/dvi.png")]
private var dvi_Icon:Class;

[Embed(source="/assets/resourceBrowserIcons/resourceType/gif.png")]
private var gif_Icon:Class;

[Embed(source="/assets/resourceBrowserIcons/resourceType/htm.png")]
private var htm_Icon:Class;

[Embed(source="/assets/resourceBrowserIcons/resourceType/swf.png")]
private var swf_Icon:Class;

[Embed(source="/assets/resourceBrowserIcons/resourceType/pdf.png")]
private var pdf_Icon:Class;

[Embed(source="/assets/resourceBrowserIcons/resourceType/txt.png")]
private var txt_Icon:Class;

[Embed(source="/assets/resourceBrowserIcons/resourceType/mid.png")]
private var mid_Icon:Class;

[Embed(source="/assets/resourceBrowserIcons/resourceType/xls.png")]
private var xls_Icon:Class;

[Embed(source="/assets/resourceBrowserIcons/resourceType/wav.png")]
private var wav_Icon:Class;

[Embed(source="/assets/common/spinner.swf")]
private var waiting_Icon:Class;

/* Creating array with embeded icons of resources types */
private function loadTypesIcons():void {
	typesIcons["avi"]	= avi_Icon;
	typesIcons["bin"]	= bin_Icon;
	typesIcons["bmp"]	= bmp_Icon;
	typesIcons["c"]		= c_Icon;
	typesIcons["css"]	= css_Icon;
	typesIcons["cfg"]	= cfg_Icon;
	typesIcons["cpp"]	= cpp_Icon;
	typesIcons["dll"]	= dll_Icon;
	typesIcons["doc"]	= doc_Icon;
	typesIcons["docx"]	= doc_Icon;
	typesIcons["dvi"]	= dvi_Icon;
	typesIcons["gif"]	= gif_Icon;
	typesIcons["htm"]	= htm_Icon;
	typesIcons["html"]	= htm_Icon;
	typesIcons["mht"]	= htm_Icon;
	typesIcons["swf"]	= swf_Icon;
	typesIcons["pdf"]	= pdf_Icon;
	typesIcons["txt"]	= txt_Icon;
	typesIcons["mid"]	= mid_Icon;
	typesIcons["xls"]	= xls_Icon;
	typesIcons["xlsx"]	= xls_Icon;
	typesIcons["wav"]	= wav_Icon;
}