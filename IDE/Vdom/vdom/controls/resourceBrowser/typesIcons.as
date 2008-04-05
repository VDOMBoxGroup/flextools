// ActionScript file

private var typesIcons:Array = new Array(); 

[Embed(source="icons/avi.png")]
private var avi_Icon:Class;

[Embed(source="icons/bin.png")]
private var bin_Icon:Class;

[Embed(source="icons/blank.png")]
private var blank_Icon:Class;

[Embed(source="icons/bmp.png")]
private var bmp_Icon:Class;

[Embed(source="icons/c.png")]
private var c_Icon:Class;

[Embed(source="icons/css.png")]
private var css_Icon:Class;

[Embed(source="icons/cfg.png")]
private var cfg_Icon:Class;

[Embed(source="icons/cpp.png")]
private var cpp_Icon:Class;

[Embed(source="icons/dll.png")]
private var dll_Icon:Class;

[Embed(source="icons/doc.png")]
private var doc_Icon:Class;

[Embed(source="icons/dvi.png")]
private var dvi_Icon:Class;

[Embed(source="icons/gif.png")]
private var gif_Icon:Class;

[Embed(source="icons/htm.png")]
private var htm_Icon:Class;

[Embed(source="icons/swf.png")]
private var swf_Icon:Class;

[Embed(source="icons/pdf.png")]
private var pdf_Icon:Class;

[Embed(source="icons/mid.png")]
private var mid_Icon:Class;

[Embed(source="icons/wav.png")]
private var wav_Icon:Class;

/* Creating array with embeded icons of resources types */
private function loadTypesIcons():void {
	typesIcons["avi"]	= avi_Icon;
	typesIcons["bin"]	= bin_Icon;
	typesIcons["blank"] = blank_Icon;
	typesIcons["bmp"]	= bmp_Icon;
	typesIcons["c"]		= c_Icon;
	typesIcons["css"]		= css_Icon;
	typesIcons["cfg"]	= cfg_Icon;
	typesIcons["cpp"]	= cpp_Icon;
	typesIcons["dll"]	= dll_Icon;
	typesIcons["doc"]	= dll_Icon;
	typesIcons["dvi"]	= dvi_Icon;
	typesIcons["gif"]	= gif_Icon;
	typesIcons["htm"]	= htm_Icon;
	typesIcons["html"]	= htm_Icon;
	typesIcons["swf"]	= swf_Icon;
	typesIcons["pdf"]	= pdf_Icon;
	typesIcons["mid"]	= mid_Icon;
	typesIcons["wav"]	= wav_Icon;
}