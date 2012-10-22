private var template:String = 
"<html>" + 
	"<head>" + 
		"<meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\"/>" + 
		"<title>Script</title>" + 
		"<script language=\"javascript\" type=\"text/javascript\" src=\"app:/modules/wysiwyg/libs/tinymce/jscripts/tiny_mce/tiny_mce_src.js\" />" + 
		"<script>tinyMCE.init(" + 
			"{" + 
				"mode: \"none\", " +
				"theme: \"advanced\", " + 
				"browsers: \"gecko\", " + 
				"dialog_type : \"modal\", " + 
				"src_mode: \"_src\", " + 
				"height:\"100%\",  " + 
				"width:\"100%\"" + 
			"});" + 
		"</script>" + 
	"</head>" + 
"<body>" + 
	"<div>" + 
		"<textarea id=\"elm1\" name=\"elm1\"></textarea>" + 
	"</div>" + 
"</body>" + 
"</html>"