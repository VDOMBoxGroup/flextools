// ActionScript file

private var typesIcons:Array = new Array(); 

[Embed(source="assets/ttf.png")]
private var ttf_Icon:Class;

[Embed(source="assets/doc.png")]
private var doc_Icon:Class;

[Embed(source="assets/mid.png")]
private var mid_Icon:Class;

[Embed(source="assets/mp3.png")]
private var mp3_Icon:Class;

[Embed(source="assets/pdf.png")]
private var pdf_Icon:Class;

[Embed(source="assets/wav.png")]
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