private var template:String = 
"<html>" + 
	"<head>" + 
		"<meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\"/>" + 
		"<title>Script</title>" + 
		"<script language=\"javascript\" type=\"text/javascript\" src=\"libs/tinymce/jscripts/tiny_mce/tiny_mce_src.js\" />" + 
		"<script>tinyMCE.init(" + 
			"{" + 
				"mode: \"none\", " +
				"force_br_newlines: \"true\", " + 
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
		"<textarea id=\"content\" name=\"content\" />" + 
	"</div>" + 
"</body>" + 
"</html>"