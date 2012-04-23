package net.vdombox.powerpack.powerpackscript
{
	public class FunctionsDescription
	{
		public function FunctionsDescription()
		{
		}
		
		public static var funcDetails : Object =
			{
				//*********************
				// General functions
				//*********************
				
				'sub'					: "<b>Description:</b>\n" +
										  "Jumps to subgraph with some params.\n\n" +
										  "<b>Syntax:</b>\n" +
										  "[sub GRAPH param1 param2 … paramN]",
										  
				'subPrefix'				: "<b>Description:</b>\n" +
										  "Jumps to subgraph with some params and\n" +
										  "all the variables name affected by this graph " +
										  "are modified, and a prefix is added.\n\n" +
										  "<b>Syntax:</b>\n" +
										  "[subPrefix GRAPH PREFIX param1 param2 … paramN]",
										  
				'question'				: "<b>Description:</b>\n" +
										  "Shows popup dialog window with the question to user.\n\n" +
										  "<b>Syntax:</b>\n" +
										  "[question QUESTION_TEXT [AnswerType_1] ... [AnswerType_N]]",
				
				'qSwitch'				: "<b>Description:</b>\n" +
										  "Shows popup dialog window for user\n" +
										  "to choose a variant of transition.\n" +
										  "<b>Syntax:</b>\n" +
										  "[qSwitch VARIANT_1 ... VARIANT_N]",
				
				"_switch"				: "<b>Syntax:</b>\n" +
										  "[_switch VALUE ARG_1 ... ARG_N]",
				
				'convert'				: "<b>Description:</b>\n" +
										  "Converts the VALUE type to the type\n" +
										  "defined by the TYPE parameter.\n\n" +
										  "<b>Syntax:</b>\n" +
										  "[convert TYPE VALUE]",
										  
				'loadDataFrom'			: "<b>Description:</b>\n" +
										  "Returna a string that keeps file content.\n\n" +
										  "<b>Syntax:</b>\n" +
										  "[loadDataFrom 'FileName']",
				
				'writeTo'				: "<b>Description:</b>\n" +
										  "Writes the result of the current state of the graph\n" +
										  "into a file whose name is specified by FileName.\n\n" +
										  "<b>Syntax:</b>\n" +
										  "[writeTo 'FileName']",
				
				'writeVarTo'			: "<b>Description:</b>\n" +
										  "Write the VALUE parameter into a file\n" +
										  "specified by FileName.\n\n" +
										  "<b>Syntax:</b>\n" +
										  "[writeVarTo 'FileName' 'VALUE']",
				
				'GUID'					: "<b>Description:</b>\n" +
										  "Returns a unique identifier compatible with\n" +
										  "the internal VDOM unique Identifier.\n\n" +
										  "<b>Syntax:</b>\n" +
										  "[GUID]",
				
				"mid"					: "Returns a substring of SOURCE_STRING beginning at the START position\n" +
										  "(0 is the first value) with a length defined in LENGTH parameter." +
										  "<b>Syntax:</b>\n" +
										  "[mid START LENGTH SOURCE_STRING]",
				
				"replace"				: "<b>Description:</b>\n" +
										  "Replaces PATTERN (seeing REG_EXP_FLAGS) in SOURCE_STRING to NEW_VALUE.\n" +
										  "<b>Syntax:</b>\n" +
										  "[replace SOURCE_STRING PATTERN REG_EXP_FLAGS NEW_VALUE]",
				
				"split"					: "<b>Description:</b>\n" +
										  "Splits a SOURCE_STRING into a list of substrings by dividing it\n" +
										  "wherever the specified DELIMETER parameter occurs.\n" +
										  "<b>Syntax:</b>\n" +
										  "[split DELIMETER SOURCE_STRING]",
				
				"random"				: "<b>Description:</b>\n" +
										  "Returnes random value N where N>=0 and N<MAX_VALUE.\n" +
										  "<b>Syntax:</b>\n" +
										  "[random MAX_VALUE]",
				
				"imageToBase64"			: "<b>Description:</b>\n" +
										  "Converts bitmap to Base64.\n" +
										  "<b>Syntax:</b>\n" +
										  "[imageToBase64 BITMAP IMAGE_FORMAT]",
				
				"alert"					: "<b>Description:</b>\n" +
									      "Shows alert with specified TEXT.\n" +
										  "<b>Syntax:</b>\n" +
										  "[alert TEXT]",
										  
				"wholeMethod"			: "<b>Description:</b>\n" +
										  "Used to call SOAP methods of VDOM Box Server.\n" +
										  "<b>Syntax:</b>\n" +
										  "[wholeMethod 'function_name' Param1 ... ParamN]",
				
				"setXMLValue"			: "<b>Description:</b>\n" +
										  "Sets the value from XML by specified XPATH.\n" +
										  "<b>Syntax:</b>\n" +
										  "[setXMLValue XPATH VALUE]",
										  
				"getXMLValue"			: "<b>Description:</b>\n" +
										  "Returns the value from XML using query string.\n" +
										  "<b>Syntax:</b>\n" +
										  "[getXMLValue QUERY_STRING]",
				
				'dialog'				: "<b>Description:</b>\n" +
											"Shows popup dialog window with the question to user.\n\n" +
											"<b>Syntax:</b>\n" +
											"[dialog QUESTION_TEXT [AnswerType_1] ... [AnswerType_N]]",
				
				'cancelableDialog'		: "The same like usual 'dialog' function.\n" +
											"Only it has 'Cancel' button.",
				
				"progress"				: "<b>Description:</b>\n" +
										  "Shows progress bar filled with VALUE percent and some description.\n" +
										  "<b>Syntax:</b>\n" +
										  "[progress VALUE DESCRIPTION]",
				
				'getFlashVar'			: "<b>Description:</b>\n" +
										  "Returns a value of FlashVar with the name variable_name.\n" +
										  "If FlashVar is not defined function returns default_value.\n" +
										  "<b>Syntax:</b>\n" +
										  "[getFlashVar variable_name default_value]",
				
				'httpPost'				: "<b>Description:</b>\n" +
										  "Used to send http request to the server defined in URL parameter.\n" +
										  "* REQUEST:\n" +
										  "'var1=value1&var2=value2&...&varN=valueN'\n" +
										  "<b>Syntax:</b>\n" +
										  "[httpPost URL REQUEST]",
				
				//*********************
				// List manipulation
				//*********************
				
				"length"				: "<b>Description:</b>\n" +
										  "Returns the length of the LIST.\n" +
										  "<b>Syntax:</b>\n" +
										  "[length [LIST]]",
										  
				"getValue"			 	: "<b>Description:</b>\n" +
										  "Returns the element value of the LIST at the position given by POSITION parameter.\n" +
										  "<b>Syntax:</b>\n" +
										  "[getValue POSITION [LIST]]",
				
				"getType"				: "<b>Description:</b>\n" +
										  "Returns the integer value representing the element type\n" +
										  "inside the given LIST at the position given by POSITION parameter.\n" +
										  "		1 - Word,\n" +
										  "		2 - String,\n" +
										  "		3 - List,\n" +
										  "		4 - Variable,\n" +
										  "<b>Syntax:</b>\n" +
										  "[getType POSITION [LIST]]",
											
				"update"				: "<b>Description:</b>\n" +
										  "Replaces an element of the LIST at the position\n" +
										  "given by POSITION parameter by another VALUE of specified TYPE.\n" +
										  "<b>Syntax:</b>\n" +
										  "[update TYPE POSITION VALUE [LIST]]\n" +
										  "	*TYPE is an integer value:\n" +
										  "		1 - Word,\n" +
										  "		2 - String,\n" +
										  "		3 - List,\n" +
										  "		4 - Variable.\n",
										  
				"put"					: "<b>Description:</b>\n" +
										  "Puts the VALUE of specified TYPE at the position indicated by POSITION parameter\n" +
										  "<b>Syntax:</b>\n" +
										  "[put TYPE POSITION VALUE [LIST]]\n" +
										  "	*TYPE is an integer value:\n" +
										  "		1 - Word,\n" +
										  "		2 - String,\n" +
										  "		3 - List,\n" +
										  "		4 - Variable.\n",
				
				"remove"				: "<b>Description:</b>\n" +
										  "Removes an element at the given position.\n" +
										  "POSITION support integer value and 'Head'/'Tail' constants.\n" +
										  "<b>Syntax:</b>\n" +
										  "[remove POSITION [LIST]]",
				
				"exist"					: "<b>Description:</b>\n" +
										  "Returns 0 if VALUE doesn’t exist in the LIST or\n" +
										  "the position of the element matching in the list.\n" +
										  "<b>Syntax:</b>\n" +
										  "[exist TYPE VALUE [LIST]]",
				
				"evaluate"				: "<b>Description:</b>\n" +
										  "Allows the command node to evaluate the list given in parameter.\n" +
										  "<b>Syntax:</b>\n" +
										  "[evaluate $List]",
				
				"execute"				: "<b>Syntax:</b>\n" +
										  "[execute $List]",
				
				"addStructure"			: "",
				"updateStructure"		: "",
				"deleteStructure"		: "",
				
				//*********************
				// Graphic functions
				//*********************
				
				"loadImage"				: "<b>Syntax:</b>\n" +
										  "[loadImage PATH]",
				
				"createImage"			: "<b>Syntax:</b>\n" +
										  "[createImage w h bgcolor]",
				
				"getWidth"				: "<b>Syntax:</b>\n" +
										  "[getWidth $img]",
				
				"getHeight"				: "<b>Syntax:</b>\n" +
										  "[getHeight $img]",
				
				"getPixel"				: "<b>Syntax:</b>\n" +
										  "[getPixel $img x y]",
				
				"getPixel32"			: "<b>Description:</b>\n" +
										  "Returns color in 32bit ARGB format.\n" +
										  "<b>Syntax:</b>\n" +
										  "[getPixel32 $img x y]",
				
				"setPixel"				: "<b>Syntax:</b>\n" +
										  "[setPixel $img x y color]",
										  
				"getImage"				: "<b>Syntax:</b>\n" +
										  "[getImage FileSize ‘PathFile’]",
										  
				"addImage"				: "<b>Syntax:</b>\n" +
										  "[addImage $img1 $img2 x y alpha alphaColor]",
				
				"mergeImages"			: "<b>Syntax:</b>\n" +
										  "[mergeImages $img1 $img2 percent]",
				
				"drawLine"				: "<b>Syntax:</b>\n" +
										  "[drawLine $img x1 y1 x2 y2 PEN alpha]",
				
				"drawPolygon"			: "<b>Syntax:</b>\n" +
										  "[drawPolygon $img [[x1 y1][x2 y2]...] Pen Fill alpha]",
				
				"drawAngleArc"			: "<b>Syntax:</b>\n" +
										  "[drawAngleArc $img x y radius startAngle endAngle Pen Fill alpha]",
				
				"drawEllipse"			: "<b>Syntax:</b>\n" +
										  "[drawEllipse $img x1 y1 x2 y2 Pen Fill alpha]",
				
				"drawRect"				: "<b>Syntax:</b>\n" +
										  "[drawRect $img x1 y1 x2 y2 Pen Fill alpha]",
				
				"drawRoundRect"			: "<b>Syntax:</b>\n" +
										  "[drawRoundRect $img x1 y1 x2 y2 radius Pen Fill alpha]",
				
				"drawBezier"			: "<b>Syntax:</b>\n" +
										  "[drawBezier $img [[x1 y1][x2 y2]...] Pen alpha]",
				
				"fillBezier"			: "<b>Syntax:</b>\n" +
										  "[fillBezier $img [[x1 y1][x2 y2]...] Pen Fill alpha]",
				
				"writeText"				: "<b>Syntax:</b>\n" +
										  "[writeText $img 'text' x y w h Font alpha]",
				
				"cropImage"				: "<b>Syntax:</b>\n" +
										  "[cropImage $img x y w h]",
										  
				"flipImage"				: "<b>Syntax:</b>\n" +
										  "[flipImage $img direction]",
										  
				"resizeImage"			: "<b>Syntax:</b>\n" +
										  "[resizeImage $img w h]",
										  
				"resizeResampling"		: "<b>Syntax:</b>\n" +
										  "[resizeResampling $img w h]",
										  
				"rotateImage"			: "<b>Syntax:</b>\n" +
										  "[rotateImage $img angle bgcolor]",
				
				"brightness"			: "<b>Syntax:</b>\n" +
										  "[brightness $img value]\n" +
										  "* For darken image use negative value.",
										  
				"contrast"				: "<b>Syntax:</b>\n" +
										  "[contrast $img value]",
										  
				"saturation"			: "<b>Syntax:</b>\n" +
										  "[saturation $img value]",
										  
				"createBlackWhite"		: "<b>Syntax:</b>\n" +
										  "[createBlackWhite $img]",
										  
				"createGrayScale"		: "<b>Syntax:</b>\n" +
										  "[createGrayScale $img]",
										  
				"createNegative"		: "<b>Syntax:</b>\n" +
										  "[createNegative $img]",
				
				"blur"					: "<b>Syntax:</b>\n" +
										  "[blur $img value]",
										  
				"sharpen"				: "<b>Syntax:</b>\n" +
										  "[sharpen $img value]",
										  
				"emboss"				: "<b>Syntax:</b>\n" +
										  "[emboss $img]"
				
			};
		
		public static const wholeMethodFunctionsDescription : Object = 
			{	"login"								: "<b>Description:</b>\n" +
													  "Calls SOAP method 'login'.\n" +
													  "<b>Syntax:</b>\n" +
													  "[wholeMethod 'login' $server $login $password]",
				
				"get_object_script_presentation"	: "<b>Description:</b>\n" +
													  "Calls SOAP method 'get_object_script_presentation'.\n" +
													  "<b>Syntax:</b>\n" +
													  "[wholeMethod 'get_object_script_presentation' $AppId $ObjectId]",
				
				"submit_object_script_presentation"	: "<b>Description:</b>\n" +
														"Calls SOAP method 'submit_object_script_presentation'.\n" +
														"<b>Syntax:</b>\n" +
														"[wholeMethod 'submit_object_script_presentation' $AppId $ObjectId $ScriptPresentation]",
				
				"create_object"						: "<b>Description:</b>\n" +
														"Calls SOAP method 'create_object'.\n" +
														"<b>Syntax:</b>\n" +
														"[wholeMethod 'create_object' $AppId $ParentId $TypeId $name $attributes]",
				
				"get_server_actions"				: "<b>Description:</b>\n" +
														"Calls SOAP method 'get_server_actions'.\n" +
														"<b>Syntax:</b>\n" +
														"[wholeMethod 'get_server_actions' $AppId $ObjectId]",
				
				"set_server_actions"				: "<b>Description:</b>\n" +
														"Calls SOAP method 'set_server_actions'.\n" +
														"<b>Syntax:</b>\n" +
														"[wholeMethod 'set_server_actions' $AppId $ObjectId $actions]",
				
				"get_application_events"			: "<b>Description:</b>\n" +
														"Calls SOAP method 'get_application_events'.\n" +
														"<b>Syntax:</b>\n" +
														"[wholeMethod 'get_application_events' $AppId $ObjectId]",
				
				"export_application"				: "<b>Description:</b>\n" +
														"Calls SOAP method 'export_application'.\n" +
														"<b>Syntax:</b>\n" +
														"[wholeMethod 'export_application' $AppId]",
				
				"install_application"				: "<b>Description:</b>\n" +
														"Calls SOAP method 'install_application'.\n" +
														"<b>Syntax:</b>\n" +
														"[wholeMethod 'install_application' $host $AppXML]",
				
				"update_application"				: "<b>Description:</b>\n" +
														"Calls SOAP method 'update_application'.\n" +
														"<b>Syntax:</b>\n" +
														"[wholeMethod 'update_application' $AppXML]",
				
				"get_application_info"				: "<b>Description:</b>\n" +
														"Calls SOAP method 'get_application_info'.\n" +
														"<b>Syntax:</b>\n" +
														"[wholeMethod 'get_application_info' $AppId]",
				
				"set_application_events"			: "<b>Description:</b>\n" +
														"Calls SOAP method 'set_application_events'.\n" +
														"<b>Syntax:</b>\n" +
														"[wholeMethod 'set_application_events' $AppId $ObjectId $events]",
				
				"close_session"						: "<b>Description:</b>\n" +
														"Calls SOAP method 'close_session'.\n" +
														"<b>Syntax:</b>\n" +
														"[wholeMethod 'close_session']",
				
				"check_application_exists"			: "<b>Description:</b>\n" +
														"Calls SOAP method 'check_application_exists'.\n" +
														"<b>Syntax:</b>\n" +
														"[wholeMethod 'check_application_exists' $AppId]",
				
				"remote_call"						: "<b>Description:</b>\n" +
														"Calls SOAP method 'remote_call'.\n" +
														"<b>Syntax:</b>\n" +
														"[wholeMethod 'remote_call' $AppId $ObjectId $funcName $paramsXML $dataXML]\n\n" +
														"* $paramsXML (example):\n" +
														"<i>&lt;Arguments&gt;&lt;CallType&gt;server_action&lt;/CallType&gt;&lt;/Arguments&gt;</i>",
				
				"list_applications"					: "<b>Description:</b>\n" +
														"Calls SOAP method 'list_applications'.\n" +
														"<b>Syntax:</b>\n" +
														"[wholeMethod 'list_applications']",
				
				"list_backup_drivers"				: "<b>Description:</b>\n" +
														"Calls SOAP method 'list_backup_drivers'.\n" +
														"<b>Syntax:</b>\n" +
														"[wholeMethod 'list_backup_drivers']",
				
				"restore_application"				: "<b>Description:</b>\n" +
														"Calls SOAP method 'restore_application'.\n" +
														"<b>Syntax:</b>\n" +
														"[wholeMethod 'restore_application' $AppId $DriverId $revision]",
				
				"backup_application"				: "<b>Description:</b>\n" +
														"Calls SOAP method 'backup_application'.\n" +
														"<b>Syntax:</b>\n" +
														"[wholeMethod 'backup_application' $AppId $DriverId]"
			};
		
		public static const dialogAnswerTypesDescription : Object =
			{
				"text"								: "<b>Description:</b>\n" +
														"Single line text field.\n" +
														"<b>Syntax:</b>\n" +
														"['text' $Label $DefaultValue]",
				
				"textArea"								: "<b>Description:</b>\n" +
															"Multi line text field.\n" +
															"<b>Syntax:</b>\n" +
															"['textArea' $Label $DefaultValue]",
															
				"password"								: "<b>Description:</b>\n" +
															"Single line password text field.\n" +
															"<b>Syntax:</b>\n" +
															"['password' $Label $DefaultValue]",
															
				"radioButtons"							: "<b>Description:</b>\n" +
															"Radio buttons group.\n" +
															"<b>Syntax:</b>\n" +
															"['radioButtons' $Label $value1 $value2 ... $valueN]",
															
				"comboBox"								: "<b>Description:</b>\n" +
															"Drop down menu.\n" +
															"<b>Syntax:</b>\n" +
															"['comboBox' $Label $value1 $value2 ... $valueN]",
															
				"checkBox"								: "<b>Description:</b>\n" +
															"Checkbox group.\n" +
															"<b>Syntax:</b>\n" +
															"$variants=[[Value1 $DefaultValue] [Value2 $DefaultValue] ... [ValueN $DefaultValue]]\n" +
															"['checkBox' $Label $variants]\n\n" +
															"* $DefaultValue - 'true'|'false'."

															
			};
		
	}
}