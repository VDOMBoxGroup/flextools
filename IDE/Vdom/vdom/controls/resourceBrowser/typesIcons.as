// ActionScript file

private var typesIcons:Array = new Array(); 

[Embed(source="icons/ttf.png")]
private var ttf_Icon:Class;

[Embed(source="icons/doc.png")]
private var doc_Icon:Class;

[Embed(source="icons/mid.png")]
private var mid_Icon:Class;

[Embed(source="icons/mp3.png")]
private var mp3_Icon:Class;

[Embed(source="icons/pdf.png")]
private var pdf_Icon:Class;

[Embed(source="icons/wav.png")]
private var wav_Icon:Class;

/* Creating array with embeded icons of resources types */
private function loadTypesIcons():void {
	typesIcons["ttf"] = ttf_Icon;
	typesIcons["doc"] = doc_Icon;
	typesIcons["mid"] = mid_Icon;
	typesIcons["mp3"] = mp3_Icon;
	typesIcons["pdf"] = pdf_Icon;
	typesIcons["wav"] = wav_Icon;
}