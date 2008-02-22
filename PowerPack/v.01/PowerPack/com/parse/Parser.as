package PowerPack.com.parse
{
	import PowerPack.com.Utils;
	import PowerPack.com.gen.Dynamic;
	
	import com.riaone.deval.D;
		
	import mx.collections.ArrayCollection;
	import PowerPack.com.gen.TemplateStruct;
	
	public class Parser
	{		
		public static const MSG_VARDEF_SYNTAX_ERROR:String = "Variable definition syntax error";		
		public static const MSG_LISTDEF_SYNTAX_ERROR:String = "List definition syntax error";		
		public static const MSG_UNDEFINED_VAR:String = "Variable undefined";		
		public static const MSG_UNKNOWN_FUNC:String = "Access of undefined function in command node";
		public static const MSG_INC_ARGS:String = "Incorrect number of function arguments in command node";
		public static const MSG_FUNC_SYNTAX_ERR:String = "Command node syntax error";
		
		public static function getLexemArray(code:String):Array
		{
      		// [lexem type, substring, start_pos_in_source_text]
       		var lexem:Array = new Array();
       		    		
    		/**
    		 * lexem types:
    		 * u - undefined
    		 * n - name (function name, graph name, prefix, etc)
    		 * s - string constant (double quotes)
    		 * c - string constant (single quotes)
    		 * v - variable
    		 * i - integer constant
    		 * f - float constant
    		 * o - null
    		 * 9 - open bracer '('
    		 * 0 - close bracer ')'
    		 * 1 - operand (*, /, %)
    		 * 2 - minus '-'
    		 * 3 - operator (>, <, <=, >=, ==, !=)
    		 * 4 - plus '+'
    		 * 5 - logical operator (&&, ||)
    		 * ${ - '{'
    		 * } - '}'
    		 * [ - '['
    		 * ] - ']'
    		 * = - '='
    		 * ; - ';'
    		 */
        		 
    		var i:int = 0; 		// iterator
    		var fix:int; 		// current string position
    		var type:String; 	// lexem type
    		var push:Boolean;	// add or not sequence to lexem array
    		
    		while(i<code.length)
    		{
    			fix=i;
    			type='u'; // undefined
    			push=true;
    			
    			switch(code.charAt(i))
    			{
    				case '"':
						do {
    						i++;
    						if(i>=code.length)
    							break;
    						
    						if(code.charAt(i)=='"')
    						{
    							var j:int = i-1;
								while(j>=0 && code.charAt(j)=="\\") {	    						
									j--;
								}
				
								if((i-j)%2==1) {
	    							break;
	    						}
    						}    						
    					} while( true );        						
						
    					if(i<code.length)
    						type = 's'; // string constant
    					break;

    				case "'":
						do {
    						i++;
    						if(i>=code.length)
    							break;
    							
   							if(code.charAt(i)=="'")
    						{
    							j = i-1;
								while(j>=0 && code.charAt(j)=="\\") {	    						
									j--;
								}
				
								if((i-j)%2==1) {
	    							break;
	    						}
    						} 			
    					} while( true );        						
						
    					if(i<code.length)
    						type = 'c'; // string constant
    					break;

    				case '$': // variable
    					if(i+1>=code.length)
    						break;

    					if(code.charAt(i+1).search(/\{/)>=0) //advanced variable
    					{	
    						i++;
    						type = '{';
    						break;        					
    					}
    					
    					if(code.charAt(i+1).search(/[^_a-z]/i)>=0)
    						break;
    					
    					do {
    						i++;
    						if(i>=code.length)
    							break;
    					} while(code.charAt(i).search(/[_a-z0-9]/i)>=0);							
						i--;
   						type = 'v'; // variable
    					break;
    					
    				case '}':
   						type = '}'; 
    					break;  

    				case '(':
   						type = '9'; // open bracer
    					break;        
    									
    				case ')':
   						type = '0'; // close bracer
    					break;  
    					      				
    				case '[':
   						type = '['; // [ bracer
    					break;        
    									
    				case ']':
   						type = ']'; // ] bracer
    					break;  

    				case '+':
   						type = '4'; // plus
    					break;
    					
    				case '-':
   						type = '2'; // minus
    					break;
    					
    				case '*':
    				case '/':
    				case '%':
   						type = '1'; // operand
    					break;
    					
    				case ';':
   						type = ';'; // command separator
    					break;	
    					
    				default: 
    					if(code.charAt(i).search(/\d/)>=0) // digit
    					{
    						do {
    							i++;
	    						if(i>=code.length)
        							break;       							
    						} while(code.charAt(i).search(/\d/)>=0);
    						i--;
    						type = 'i'; // integer constant

       						if(i+2>=code.length)
    							break;
    							       						
    						if(code.charAt(i+1)=='.' && code.charAt(i+2).search(/\d/)>=0)
    						{
    							i++;
    							do {
    								i++;	
		    						if(i>=code.length)
	        							break;         								
    							} while(code.charAt(i).search(/\d/)>=0);
    							i--;   
    							type = 'f'; // float constant    						
    						}        						
    						break;
    					}
    					else if(code.charAt(i).search(/[_a-z]/i)>=0) // name or (null)
    					{
    						if(code.indexOf("null", i) == i)
    						{
    							i+=3;
    							type = 'o';    							
    							break;
    						}
    						
    						do {
    							i++;
    							if(i>=code.length)
    								break;
    						} while(code.charAt(i).search(/[_a-z0-9]/i)>=0);
							i--;
       						type = 'n'; // name
       						break;
    					}
    					else if(code.charAt(i).search(/[=!<>\|&]/)>=0) // any operator or '='
    					{
    						if(code.charAt(i).search(/=/)>=0)
    						{
        						type = '='; // '='
    						}        						
    						else if(code.charAt(i).search(/[<>]/)>=0)
    						{
        						type = '3'; // operator
    						}

    						if(i+1<code.length)
    						{
    							if(	code.charAt(i).search(/[=!<>]/)>=0 && code.charAt(i+1).search(/=/)>=0 )
    							{
    								i++;
    								type = '3'; // operator
    							}
    							else if(
        							code.charAt(i).search(/\|/)>=0 && code.charAt(i+1).search(/\|/)>=0 ||
        							code.charAt(i).search(/&/)>=0 && code.charAt(i+1).search(/&/)>=0 )
        						{
    								i++;
    								type = '5'; // logical operator	       						
        						}
    						}        						
    						break;        						
    					}
    					else if(code.charAt(i).search(/\s/)>=0) // any white space
    					{      				
        					push=false;        				        					
        					break;        					
        				}	        				
    			}

				if(i>=code.length)
					i=code.length-1;
				
				if(push)
				{
 					lexem.push([type, code.substring(fix, i+1), fix]);
 				} 					
    			i++;        			        				
    		} 
    		return lexem;  
		}
		
		public static function getTextLexemArray(text:String):Array
		{
      		// [lexem type, substring, start_pos]
       		var lexem:Array = new Array();
       		    		
    		/**
    		 * lexem types:
    		 * u - undefined
    		 * t - text
    		 * s - string constant (double quotes)
    		 * c - string constant (single quotes)
    		 * v - variable
    		 * i - integer constant
    		 * f - float constant
    		 * o - null
    		 * 9 - open bracer '('
    		 * 0 - close bracer ')'
    		 * 1 - operand (*, /, %)
    		 * 2 - minus '-'
    		 * 4 - plus '+'
    		 * ${ - '{'
    		 * } - '}'
    		 */
        		 
    		var i:int = 0; 				// iterator
    		var fix:int; 				// current string position
    		var type:String; 			// lexem type
    		var push:Boolean;			// add or not sequence to lexem array
    		var sCode:Array=[];			// inside code
    		
    		while(i<text.length)
    		{
    			fix=i;
    			type='t'; // text
    			push=true;
    			
    			if(sCode.length==0)
    			{
	    			switch(text.charAt(i))
    				{
    					case '$': // variable
	    					if(i+1>=text.length)
	    						break;
	    					
	    					var j:int = i-1;
	    					while(j>=0 && text.charAt(j)=="\\")
	    					{	    						
	    						j--;
	    					}
	    					
	    					if((i-j-1)%2==1)
	    						break;

	    					if(text.charAt(i+1).search(/\{/)>=0) //advanced variable
	    					{	
	    						i++;
	    						type = '{';
	    						sCode.push("");
	    						break;        					
	    					}
	    					
	    					if(text.charAt(i+1).search(/[^_a-z]/i)>=0)
	    						break;
	    					
	    					do {
	    						i++;
	    						if(i>=text.length)
	    							break;
	    					} while(text.charAt(i).search(/[_a-z0-9]/i)>=0);							
							i--;
	   						type = 'v'; // variable
	    					break;

	    				default:
							do {
	    						i++;
	    						if(i>=text.length)
	    							break;
	    					} while(text.charAt(i)!="$");        						
							i--;
    				}
    			}
				else
				{    			
	    			type='u'; // undefined

	    			switch(text.charAt(i))
	    			{
	    				case '$': // variable
	    					if(i+1>=text.length)
	    						break;
	
	    					if(text.charAt(i+1).search(/\{/)>=0) //advanced variable
	    					{	
	    						i++;
	    						type = '{';
	    						sCode.push("");
	    						break;        					
	    					}
	    					
	    					if(text.charAt(i+1).search(/[^_a-z]/i)>=0)
	    						break;
	    					
	    					do {
	    						i++;
	    						if(i>=text.length)
	    							break;
	    					} while(text.charAt(i).search(/[_a-z0-9]/i)>=0);							
							i--;
	   						type = 'v'; // variable
	    					break;
	    					
	    				case '}':
	   						type = '}'; 
	   						sCode.pop();
	    					break;  
	
	    				case '"':
							do {
	    						i++;
	    						if(i>=text.length)
	    							break;

	   							if(text.charAt(i)=='"')
	    						{
	    							j = i-1;
									while(j>=0 && text.charAt(j)=="\\") {	    						
										j--;
									}
					
									if((i-j)%2==1) {
		    							break;
		    						}
	    						}	    							
	    					} while( true );        						
							
	    					if(i<text.length)
	    						type = 's'; // string constant
	    					break;
	
	    				case "'":
							do {
	    						i++;
	    						if(i>=text.length)
	    							break;

	   							if(text.charAt(i)=="'")
	    						{
	    							j = i-1;
									while(j>=0 && text.charAt(j)=="\\") {	    						
										j--;
									}
					
									if((i-j)%2==1) {
		    							break;
		    						}
	    						}	    							
	    					} while( true );        						
							
	    					if(i<text.length)
	    						type = 'c'; // string constant
	    					break;
	
	    				case '(':
	   						type = '9'; // open bracer
	    					break;        
	    									
	    				case ')':
	   						type = '0'; // close bracer
	    					break;  
	    					      				
	    				case '+':
	   						type = '4'; // plus
	    					break;
	    					
	    				case '-':
	   						type = '2'; // minus
	    					break;
	    					
	    				case '*':
	    				case '/':
	    				case '%':
	   						type = '1'; // operand
	    					break;
	    					
	    				default: 
    						if(text.indexOf("null", i) == i)
    						{
    							i+=3;
    							type = 'o';    							
    							break;
    						}
	    					if(text.charAt(i).search(/\d/)>=0) // digit
	    					{
	    						do {
	    							i++;
		    						if(i>=text.length)
	        							break;       							
	    						} while(text.charAt(i).search(/\d/)>=0);
	    						i--;
	    						type = 'i'; // integer constant
	
	       						if(i+2>=text.length)
	    							break;
	    							       						
	    						if(text.charAt(i+1)=='.' && text.charAt(i+2).search(/\d/)>=0)
	    						{
	    							i++;
	    							do {
	    								i++;	
			    						if(i>=text.length)
		        							break;         								
	    							} while(text.charAt(i).search(/\d/)>=0);
	    							i--;   
	    							type = 'f'; // float constant    						
	    						}        						
	    						break;
	    					}
	    					else if(text.charAt(i).search(/\s/)>=0) // any white space
	    					{      				
	        					push=false;        				        					
	        					break;        					
	        				}	        				
	    			}
				}
				
				if(i>=text.length)
					i=text.length-1;
				
				if(push)
				{
 					lexem.push([type, text.substring(fix, i+1), fix]);
 				} 					
    			i++;        			        				
    		} 
    		return lexem;  
		}
		
		public static function convertLexemArray(lexems:Array):Array
		{
			var converted:Array = lexems.concat();
			
			for(var i:int=0; i<converted.length; i++)
			{
				switch(converted[i][0])
				{
					case "t": // replace special characters from texts						
						converted[i][1] = Utils.replaceEscapeSequences(converted[i][1], "\\r");
						converted[i][1] = Utils.replaceEscapeSequences(converted[i][1], "\\n");
						converted[i][1] = Utils.replaceEscapeSequences(converted[i][1], "\\t");
						converted[i][1] = Utils.replaceEscapeSequences(converted[i][1], "\\$");
						converted[i][1] = Utils.replaceEscapeSequences(converted[i][1], "\\\\");
						break;
					case "v": // convert variable names to as3 compatible names
						converted[i][1] = String(converted[i][1]).substring(1);
						break;
					case "n": // convert names to string
						//converted[i][1] = Utils.doubleQuotes(converted[i][1])
						break;
				}
			}
			return converted;
		}
	
		/**
		 * 
		 * @param lexems
		 * @param context
		 * @return 	result: Boolean - valid or not
		 * 			resultString: String - error code
		 * 			resultArray: Array - processed lexem array
		 * 
		 */
		public static function processConvertedLexemArray(lexems:Array, context:Dynamic):Object
		{
			var arr:Array = lexems.concat();
			
			var index:int = 0;
			
			while(index<arr.length)
			{
				if(arr[index][0]=="{")
				{
					var variable:Object = recursiveProcessLexemsArray(arr, context, index);
					
					if(variable.result == false)
						return {result:variable.result, resultString:variable.resultString, resultArray:null};
						
					arr[index][0] = "v";
					arr[index][1] = variable.resultString;
				}
				
				index++;
			}		
			
			return {result:true, resultString:null, resultArray:arr};
		}
		
		/**
		 * 
		 * @param lexems
		 * @param context
		 * @param index
		 * @return 	result: Boolean - valid or not
		 * 			resultString: String - variable name or error code
		 * 
		 */
		private static function recursiveProcessLexemsArray(lexems:Array, context:Dynamic, index:int):Object
		{
			var arrColLexems:ArrayCollection = new ArrayCollection(lexems);
			var retVal:Object = {result:false, resultString:null};

			var code:String = "";
			var result:Object;
			var strLexem:String = "";
				
			arrColLexems.removeItemAt(index);
			while(index<arrColLexems.length && lexems[index][0]!="}")
			{
				result = null;
				
				// search for allowable lexem
				if(String(lexems[index][0]).search(/[scvif90124{]/)<0)
					return {result:false, resultString:MSG_VARDEF_SYNTAX_ERROR};
				
				if(String(lexems[index][0]).search(/v/)>=0)
				{
					if(context[lexems[index][1]]==null)
						return {result:false, resultString:MSG_UNDEFINED_VAR + ": " + lexems[index][1]};
				}				
				
				if(lexems[index][0]=="{")
				{
					result = recursiveProcessLexemsArray(lexems, context, index);
					
					if(result.result == false)
						return result;
					
					code += result.resultString;
					strLexem += "V";
				}
				else
				{
					code += lexems[index][1];
					strLexem += lexems[index][0]
				}
				
				arrColLexems.removeItemAt(index);
			}
			
			// '}' not found 
			if(index>=arrColLexems.length)
				return {result:false, resultString:MSG_VARDEF_SYNTAX_ERROR};
				
			if(!isValidOperation(strLexem).result)
				return {result:false, resultString:MSG_VARDEF_SYNTAX_ERROR};
			
			retVal.result = true;
			retVal.resultString = D.eval(code, null, context).toString();
			
			return retVal;
		}
		
		public static function processListsConvertedLexemArray(lexems:Array, context:Dynamic):Object
		{
			var arr:Array = lexems.concat();
			
			var index:int = 0;
			
			while(index<arr.length)
			{
				if(arr[index][0]=="[")
				{
					var variable:Object = recursiveProcessListsLexemsArray(arr, context, index);
					
					if(variable.result == false)
						return {result:variable.result, resultString:variable.resultString, resultArray:null};
						
					arr[index][0] = "A";
					arr[index][1] = variable.resultString;
				}
				
				index++;
			}		
			
			return {result:true, resultString:null, resultArray:arr};
		}
		
		private static function recursiveProcessListsLexemsArray(lexems:Array, context:Dynamic, index:int):Object
		{
			var arrColLexems:ArrayCollection = new ArrayCollection(lexems);
			var retVal:Object = {result:false, resultString:null};

			var code:String = "";
			var result:Object;
			var strLexem:String = "";
				
			arrColLexems.removeItemAt(index);
			while(index<arrColLexems.length && lexems[index][0]!="]")
			{
				result = null;
				
				// search for allowable lexem
				if(String(lexems[index][0]).search(/[nvscifA90124\]]/)<0)
					return {result:false, resultString:MSG_LISTDEF_SYNTAX_ERROR};
				
				if(String(lexems[index][0]).search(/v/)>=0)
				{
					if(context[lexems[index][1]]==null)
						return {result:false, resultString:MSG_UNDEFINED_VAR + ": " + lexems[index][1]};
				}				
				
				if(lexems[index][0]=="[")
				{
					result = recursiveProcessListsLexemsArray(lexems, context, index);
					
					if(result.result == false)
						return result;
					
					code += "," + result.resultString;
					strLexem += "A";
				}
				else
				{
					code += "," + lexems[index][1];
					strLexem += lexems[index][0]
				}
				
				arrColLexems.removeItemAt(index);
			}
			
			// ']' not found 
			if(index>=arrColLexems.length)
				return {result:false, resultString:MSG_LISTDEF_SYNTAX_ERROR};
				
			if(!isValidList(strLexem).result)
				return {result:false, resultString:MSG_LISTDEF_SYNTAX_ERROR};
			
			code = "[" + code.substr(1) + "]";
			
			retVal.result = true;
			retVal.resultString = code;
			
			return retVal;
		}
					
		public static function rollLexemString(lexemString:String, patterns:Array):String
		{
			var len:int;
			var prevLen:int;
			var index:int = 0;
			var strSentence:String = lexemString.concat();
			
			// parse operations
			do {
				len = strSentence.length;
				index = 0;
				
				do {
					prevLen = strSentence.length;
					
					strSentence = strSentence.replace(patterns[index][0], patterns[index][1]);
					
					if(prevLen == strSentence.length)
						index++;				
				} while (index<patterns.length && strSentence.length);
				
			} while	(len!=strSentence.length && strSentence.length)
			
			return strSentence;
		}
		
		public static function isValidOperation(lexemString:String):Object
		{
			var strSentence:String = lexemString.concat();  
			var patterns:Array = 
				[
					[/(^|3|9|=)[24](v|i|f)/g, 	"$1$2"],	// remove signs '-1...', '...=-2...', '...(-3...'
					[/[Vvifo]1[Vvifo]/g, 		"V"],		// (*, /, %)
					[/[Vvifo]2[Vvifo]/g, 		"V"],		// '-'
					[/[Vvifsco]4[Vvifsco]/g,	"V"],		// '+'
					[/9(V|v|i|f|s|c|o)0/g, 		"$1"],
					[/\{[Vvsc]\}/g, 			"v"]
				]
			;     			

			// parse operations
			strSentence = rollLexemString(strSentence, patterns);
			
			if(/^[Vvifsco]$/.test(strSentence))
				return {result: true, resultString: strSentence};
			
			return {result: false, resultString: strSentence};
		}
		
		public static function isValidList(lexemString:String):Object
		{
			var strSentence:String = isValidOperation(lexemString).resultString;  
			var pattern:RegExp;

			var patterns:Array = 
				[
					[/\[[nvscVA][nvscifVA]{0,}\]/g, "A"]
				]
			;
		
			strSentence = rollLexemString(strSentence, patterns);
			
			if(strSentence=="A")
				return {result: true, resultString: strSentence};
			
			return {result: false, resultString: strSentence};						
		}	
		
		public static function isValidFunction(lexemString:String):Object
		{
			var strSentence:String = isValidList(lexemString).resultString;  
			var pattern:RegExp;     			
		
			pattern = /^(v=){0,1}A$/;

			if(pattern.test(strSentence))
				return {result: true, resultString: strSentence};	
			
			return {result: false, resultString: strSentence};						
		}			
		
		public static function isValidCommand(lexemString:String):Object
		{
			var strSentence:String = isValidOperation(lexemString).resultString;  
			var pattern:RegExp;     			
		
			pattern = /^v=[Vvifsco](;v=[Vvifsco]){0,}$/;

			if(pattern.test(strSentence))
				return {result: true, resultString: strSentence};
			
			return {result: false, resultString: strSentence};
		}
				
		public static function isValidTest(lexemString:String):Object
		{
			var strSentence:String = isValidOperation(lexemString).resultString;

			var patterns:Array = 
				[
					[/[Vvifsco]3[Vvifsco]/g, 	"O"],	// operator
					[/[OL]5[OL]/g, 				"L"],	// logical operator
					[/9O0/g, 					"O"],	
					[/9L0/g, 					"L"]
				]
			;     			

			// parse operations
			if(strSentence.search(/[35]/)>=0)
			{
				strSentence = rollLexemString(strSentence, patterns);
			}

			if(strSentence=="O" || strSentence=="L")
				return {result: true, resultString: strSentence};	
			
			return {result: false, resultString: strSentence};						
		}
		
		public static function isFunctionExists(lexems:Array, bValidate:Boolean=true):Object
		{			
			var pattern:RegExp;
			var strSentence:String = "";    
			var retVal:Object = {result:false, resultString:null, resultVar:null, resultFunc:null};   			
			
			for(var i:int=0; i<lexems.length; i++)
				strSentence = strSentence + lexems[i][0];
					
			strSentence = isValidOperation(strSentence).resultString;				

			// search for function name index in lexem array
			for(var nIndex:int=0; nIndex<lexems.length; nIndex++)
			{
				if(lexems[nIndex][0]=='[')
				{	
					nIndex++;
					break;
				}
			}				
					
			// search for variable index in lexem array
			for(var vIndex:int=0; vIndex<lexems.length; vIndex++)
			{
				if(lexems[vIndex][0]=='=')
				{
					vIndex--;
					break;
				}
			}
			
			var patterns:Array = 
				[					
					// sub
					[/^(v=){0,1}\[nn\]$/ , "sub", 1],
					// subprefix
					[/^(v=){0,1}\[nnn\]$/, "subprefix", 2],
					// question
					[/^(v=){0,1}\[n[scvV][scvV]\]$/, "question", 2],
					// convert
					[/^(v=){0,1}\[n[scvV][scviV]\]$/, "convert", 2],
					// writeTo
					[/^(v=){0,1}\[n[scvV]\]$/, "writeTo", 1],
					// writeVarTo
					[/^(v=){0,1}\[n[scvV][scvifV]\]$/, "writeVarTo", 2],
					// GUID
					[/^(v=){0,1}\[n\]$/, "GUID", 0],
					
					/**
					* 1st add-on
					*/
					
					//*********************
					// List manipulation
					//*********************
					
					// Evaluate
					[/^(v=){0,1}\[n[scvV]\]$/, "Evaluate", 1],
					// Get
					[/^(v=){0,1}\[n[viV][scvV]\]$/, "Get", 2],
					// Put
					[/^(v=){0,1}\[n[viV][nscvifV][scvV]\]$/, "Put", 3],
					// Update
					[/^(v=){0,1}\[n[viV][nscvifV][scvV]\]$/, "Update", 3],
					// Length
					[/^(v=){0,1}\[n[scvV]\]$/, "Length", 1]
									
				];
			
			for(var j:int=0; j<patterns.length; j++)
			{
				if(lexems[nIndex][1]==patterns[j][1])
				{
					retVal.resultFunc = lexems[nIndex][1];		
					
					if(strSentence.indexOf("]")-strSentence.indexOf("[")-2 != patterns[j][2])
						retVal.resultString = MSG_INC_ARGS;						
				
					if(	RegExp(patterns[j][0]).test(strSentence) )
					{
						retVal.result = true;
						
						retVal.resultString = "";						
						
						if(!bValidate)
						{
							for(i=nIndex+1; i<lexems.length && lexems[i][0]!="]"; i++)
								retVal.resultString += "," + (lexems[i][0]=='n'?Utils.doubleQuotes(lexems[i][1]):lexems[i][1]);
							
							retVal.resultString = TemplateStruct.CNTXT_INSTANCE + "." + lexems[nIndex][1] + "(" +
								String(retVal.resultString).substr(1) + ")";
						}						
					}

					break;
				}
			}
			
			if(retVal.result)
			{
				if(/^v=/.test(strSentence))
				{
					retVal.resultVar = lexems[vIndex][1];
	
					if(!bValidate)
						retVal.resultString = retVal.resultVar + "=" + retVal.resultString;
				}
			}
			else if(retVal.resultFunc && !retVal.resultString)
			{
				retVal.resultString = MSG_FUNC_SYNTAX_ERR;
			}
			else if(!retVal.resultString)
			{
				retVal.resultString = MSG_UNKNOWN_FUNC;
			}
			
			return retVal;
		}
		
			
	}
}