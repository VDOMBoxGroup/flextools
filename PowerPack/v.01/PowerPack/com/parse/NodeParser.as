package PowerPack.com.parse
{
	import PowerPack.com.gen.*;
	import com.riaone.deval.D;
	import PowerPack.com.Utils;
	
	public class NodeParser
	{		
		public static const CT_OPERATION:int = 1;
		public static const CT_TEST:int = 2;
		public static const CT_FUNCTION:int = 3;		
		
		public static function NormalNodeParse(	_nodeText:String,
												_context:Dynamic=null):Object
		{
			var pattern:RegExp;
			var str:String = new String(_nodeText);
			var retVal:Object = new Object();
			
			retVal.result = false;
			retVal.resultString = null;
			
        	// '...$123asd...' or '...dfdsf$' is not allowed sequence
        	pattern = /(\$[^_a-z]|\$$)/gi;
			
			if(pattern.test(str))
            	return retVal;
			
			retVal.result = true;
			
			// context - instance of dynamic class that contains global variables
			if(_context)
			{
				pattern = /\$([_a-z0-9]+)/gi;
				var variables:Array = str.match(pattern);
				
				for(var i:int=0; i<variables.length; i++)
					str = str.replace(variables[i], _context[variables[i].substring(1)]);
					
				retVal.resultString = str;
			}
			
           	return retVal;
		}
		
		public static function SubgraphNodeParse( _nodeText:String ):Object
		{
			var pattern:RegExp;
			var str:String = new String(_nodeText);
			var retVal:Object = new Object();
			
			retVal.result = false;
			retVal.resultString = null;			
			
        	pattern = /[^a-z0-9_]/gi;
			
			if(pattern.test(str))
            	return retVal;
			
			retVal.result = true;
			
           	return retVal;
		}
				
		public static function CommandNodeParse(	_nodeText:String, 
													_fValidate:Boolean = true,
													_varPrefix:String = "" ):Object
		{
			var pattern:RegExp;
			var str:String = new String(_nodeText);
			var retVal:Object = new Object();
			var func:String;
			
			retVal.result = false;
			retVal.type = null;
			retVal.program = null;
			
			retVal.print = true;
			retVal.func = null;
			retVal.variable = null;
			retVal.resultArray = null;
					
       		var bTestCommand:Boolean = false;
       		var bOperationCommand:Boolean = false;
       		var bFunctionCommand:Boolean = false;
       			
       		/**
       		 * lexical analyzer 
       		 */
       		 
      		var lexem:Array = GenLexemArray(str);
  		        		
       		/**
       		 * syntax analyzer 
       		 */
       		 
			var strSentence:String = "";       			
			for(var i:int=0; i<lexem.length; i++)
				strSentence = strSentence + lexem[i][0];

			var prevLen:int;
			
			// parse operations
			do {
				prevLen = strSentence.length;
				
				// remove signs
				pattern = /(^|3|9|=)[24](v|i|f)/g;						
				strSentence = strSentence.replace(pattern, "$1$2");

				// split into variable
				pattern = /[Vvif]1[Vvif]/g;						
				strSentence = strSentence.replace(pattern, "V");
				pattern = /[Vvif]2[Vvif]/g;						
				strSentence = strSentence.replace(pattern, "V");  
				pattern = /[Vvifsc]4[Vvifsc]/g;						
				strSentence = strSentence.replace(pattern, "V");
				
				pattern = /9(V|v|i|f|s|c)0/g;						
				strSentence = strSentence.replace(pattern, "$1");	

				pattern = /\{[Vvifsc]\}/g;						
				strSentence = strSentence.replace(pattern, "v");													  

			} while (prevLen != strSentence.length && strSentence.length);
			
			pattern = /^v=[Vvifsc](;v=[Vvifsc]){0,}$/;
			if(pattern.test(strSentence))
			{
				bOperationCommand = true;
				retVal.result = true;
				retVal.type = CT_OPERATION;
			}
			
			// parse test
			if(retVal.result==false && strSentence.search(/[35]/)>=0)
			{
				do {
					prevLen = strSentence.length;

					pattern = /[Vvifsc]3[Vvifsc]/g;						
					strSentence = strSentence.replace(pattern, "O"); // operator							

					pattern = /[OL]5[OL]/g;						
					strSentence = strSentence.replace(pattern, "L"); // logical operator							

					pattern = /9O0/g;						
					strSentence = strSentence.replace(pattern, "O");							  

					pattern = /9L0/g;						
					strSentence = strSentence.replace(pattern, "L");							  
					
				} while (prevLen != strSentence.length && strSentence.length);
			
				if(strSentence=="O" || strSentence=="L")
				{
					bTestCommand = true;
					retVal.result = true;
					retVal.type = CT_TEST;
					retVal.resultArray = ["true", "false"];
				}
			}
			
			// parse function
			if(retVal.result==false && strSentence.search(/\[.+\]/)>=0)
			{
				pattern = /^(v=){0,1}\[n[nscvif]{0,}\]$/;
				
				if(pattern.test(strSentence))
				{
					bFunctionCommand = true;
					retVal.type = CT_FUNCTION;
				}
			}  		     
 			
    		if(bFunctionCommand)
    		{				
				for(i=0;i<lexem.length;i++)
				{
					if(lexem[i][0]=='v')
						lexem[i][1] = String(lexem[i][1]).substring(1);
					else if(lexem[i][0]=='c')
						lexem[i][1] = Utils.ReplaceSingleQuotes(lexem[i][1]);
					else if(lexem[i][0]=='s')
						lexem[i][1] = Utils.ReplaceDoubleQuotes(lexem[i][1]);
				}
					    			
				// search for function name in lexem array
				for(i=0;i<lexem.length;i++)
				{
					if(lexem[i][0]=='n')
						break;
				}						

				for(var j:int=0;j<lexem.length;j++)
				{
					if(lexem[j][0]=='v')
						break;
				}
				
				var bFunc:Boolean = false;
				
				// question
				pattern = /^(v=){0,1}\[ncc\]$/;
				if(	pattern.test(strSentence) && 
					lexem[i][1]=="question" )
				{
					bFunc = true;
					func = TemplateStruct.INSTANCE + "." + lexem[i][1] + "(" + 
						Utils.DoubleQuotes(lexem[i+1][1]) + "," + 
						Utils.DoubleQuotes(lexem[i+2][1]) + ")";
					
					// generate transitions if there is question command
					var strVariations:String = lexem[i+2][1];
					
					if(strVariations!="*")
						retVal.resultArray = strVariations.split(/\s*,\s*/);
				}
				// sub
				pattern = /^(v=){0,1}\[nn\]$/;
				if(	pattern.test(strSentence) && 
					lexem[i][1]=="sub" )
				{
					bFunc = true;
					func = TemplateStruct.INSTANCE + "." + lexem[i][1] + "(" + 
						Utils.DoubleQuotes(lexem[i+1][1]) + ")";
				}	
				// subprefix
				pattern = /^(v=){0,1}\[nnn\]$/;
				if(	pattern.test(strSentence) && 
					lexem[i][1]=="subprefix" )
				{
					bFunc = true;
					func = TemplateStruct.INSTANCE + "." + lexem[i][1] + "(" + 
						Utils.DoubleQuotes(lexem[i+1][1]) + "," + 
						Utils.DoubleQuotes(lexem[i+2][1]) + ")";
				}	
				// convert
				pattern = /^(v=){0,1}\[nc[scvi]\]$/;
				if(	pattern.test(strSentence) && 
					lexem[i][1]=="convert" )
				{
					bFunc = true;
					func = TemplateStruct.INSTANCE + "." + lexem[i][1] + "(" + 
						Utils.DoubleQuotes(lexem[i+1][1]) + "," + 
						(lexem[i+2][0]=="c" || lexem[i+2][0]=="s")?
							Utils.DoubleQuotes(lexem[i+2][1]):lexem[i+2][1] + ")";
				}		
				// writeTo
				pattern = /^(v=){0,1}\[n[cv]\]$/;
				if(	pattern.test(strSentence) && 
					lexem[i][1]=="writeTo" )
				{
					bFunc = true;
					func = TemplateStruct.INSTANCE + "." + lexem[i][1] + "(" + 
						(lexem[i+1][0]=="c" || lexem[i+1][0]=="s")?
							Utils.DoubleQuotes(lexem[i+1][1]):lexem[i+1][1] + ")";
				}			
				// writeVarTo
				pattern = /^(v=){0,1}\[n[cv][scvif]\]$/;
				if(	pattern.test(strSentence) && 
					lexem[i][1]=="writeVarTo" )
				{
					bFunc = true;
					func = TemplateStruct.INSTANCE + "." + lexem[i][1] + "(" + 
						(lexem[i+1][0]=="c" || lexem[i+1][0]=="s")?
							Utils.DoubleQuotes(lexem[i+1][1]):lexem[i+1][1] + "," + 
						(lexem[i+2][0]=="c" || lexem[i+2][0]=="s")?
							Utils.DoubleQuotes(lexem[i+2][1]):lexem[i+2][1] + ")";
				}					
				// GUID
				pattern = /^(v=){0,1}\[n\]$/;
				if(	pattern.test(strSentence) && 
					lexem[i][1]=="GUID" )
				{
					bFunc = true;
					func = TemplateStruct.INSTANCE + "." + lexem[i][1] + "()";
				}
				
				if(bFunc)
				{					
					retVal.result = true;
					retVal.func = lexem[i][1];					

					if(/^v=/.test(strSentence))
					{
						retVal.variable = _varPrefix + lexem[j][1];
						func = retVal.variable + "=" + func;
						retVal.print = false;
					}
				}		
    		}
    		
   			// generate programm code
    		if(_fValidate==false && retVal.result)
    		{
    			var program:String = "";
    			
    			if(bOperationCommand)
    			{
					for(i=0;i<lexem.length;i++)
					{
						if(lexem[i][0]=='v')							
							lexem[i][1] = String(lexem[i][1]).substring(1);
						
						if(lexem[i][0]=='=' && lexem[i-1][0]=='v')
							lexem[i-1][1] = _varPrefix + lexem[i-1][1];							
					}
					
					for(i=0;i<lexem.length;i++)
					{
						program += lexem[i][1];
					}
					retVal.program = program;
				}				
				else if(bTestCommand)
				{
					for(i=0;i<lexem.length;i++)
					{
						if(lexem[i][0]=='v')							
							lexem[i][1] = String(lexem[i][1]).substring(1);						
					}	
					
					for(i=0;i<lexem.length;i++)
					{
						program += lexem[i][1];
					}
					retVal.program = program;
				}	
				else if(bFunctionCommand)
				{
					program = func;
					retVal.program = program;
				}	
    		}		
			
			return retVal;
		}

		private static function GenLexemArray(str:String):Array
		{
      		// [lexem type, substring]
       		var lexem:Array = new Array();
       		    		
    		/**
    		 * lexem types:
    		 * u - undefined
    		 * n - name (function name, graph name, prefix, etc)
    		 * s - string constant (double quote)
    		 * c - string constant (single quote)
    		 * v - variable
    		 * i - integer constant
    		 * f - float constant
    		 * 9 - open bracer
    		 * 0 - close bracer
    		 * 1 - operand
    		 * 2 - minus
    		 * 3 - operator 
    		 * 4 - plus
    		 * 5 - logical operator
    		 * ${ - {
    		 * } - }
    		 * [ - [
    		 * ] - ]
    		 * = - =
    		 * ; - ;
    		 */
        		 
    		var i:int = 0;
    		var fix:int;
    		var type:String;
    		var push:Boolean;
    		
    		while(i<str.length)
    		{
    			fix=i;
    			type='u';
    			push=true;
    			
    			switch(str.charAt(i))
    			{
    				case '"':
						do {
    						i++;
    						if(i>=str.length)
    							break;
    					} while(	str.charAt(i)!='"' || 
    								(str.charAt(i-1)=='\\' && str.charAt(i)=='"') );        						
						
    					if(i<str.length)
    						type = 's'; // string constant
    					break;

    				case '\'':
						do {
    						i++;
    						if(i>=str.length)
    							break;
    					} while(	str.charAt(i)!='\'' || 
    								(str.charAt(i-1)=='\\' && str.charAt(i)=='\'') );        						
						
    					if(i<str.length)
    						type = 'c'; // string constant
    					break;

    				case '$':
    					if(i+1>=str.length)
    						break;

    					if(str.charAt(i+1).search(/\{/)>=0)
    					{	
    						i++;
    						type = '{';
    						break;        					
    					}
    					
    					if(str.charAt(i+1).search(/[^_a-z]/i)>=0)
    						break;
    					
    					do {
    						i++;
    						if(i>=str.length)
    							break;
    					} while(str.charAt(i).search(/[_a-z0-9]/i)>=0);							
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
   						type = ';'; 
    					break;	
    					
    				default: 
    					if(str.charAt(i).search(/\d/)>=0) // digit
    					{
    						do {
    							i++;
	    						if(i>=str.length)
        							break;       							
    						} while(str.charAt(i).search(/\d/)>=0);
    						i--;
    						type = 'i'; // integer constant

       						if(i+2>=str.length)
    							break;
    							       						
    						if(str.charAt(i+1)=='.' && str.charAt(i+2).search(/\d/)>=0)
    						{
    							i++;
    							do {
    								i++;	
		    						if(i>=str.length)
	        							break;         								
    							} while(str.charAt(i).search(/\d/)>=0);
    							i--;   
    							type = 'f'; // float constant    						
    						}        						
    						break;
    					}
    					else if(str.charAt(i).search(/[_a-z]/i)>=0)
    					{
    						do {
    							i++;
    							if(i>=str.length)
    								break;
    						} while(str.charAt(i).search(/[_a-z0-9]/i)>=0);
							i--;
       						type = 'n'; // name
       						break;
    					}
    					else if(str.charAt(i).search(/[=!<>\|&]/)>=0) // any operator
    					{
    						if(str.charAt(i).search(/=/)>=0)
    						{
        						type = '='; // =
    						}        						
    						else if(str.charAt(i).search(/[<>]/)>=0)
    						{
        						type = '3'; // operator
    						}

    						if(i+1<str.length)
    						{
    							if(	str.charAt(i).search(/[=!<>]/)>=0 && str.charAt(i+1).search(/=/)>=0 )
    							{
    								i++;
    								type = '3'; // operator
    							}
    							else if(
        							str.charAt(i).search(/\|/)>=0 && str.charAt(i+1).search(/\|/)>=0 ||
        							str.charAt(i).search(/&/)>=0 && str.charAt(i+1).search(/&/)>=0 )
        						{
    								i++;
    								type = '5'; // logical operator	       						
        						}
    						}        						
    						break;        						
    					}
    					else if(str.charAt(i).search(/\s/)>=0) // any white space
    					{      				
        					push=false;        				        					
        					break;        					
        				}	        				
    			}

				if(i>=str.length)
					i=str.length-1;
				
				if(push)
				{
 					lexem.push([type, str.substring(fix, i+1)]);
 				} 					
    			i++;        			        				
    		} 
    		return lexem;  
		}
	
	////////////////////////////////////////////////////////////
	}
}