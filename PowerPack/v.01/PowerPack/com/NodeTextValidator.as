package PowerPack.com
{
	import mx.validators.Validator;
    import mx.validators.ValidationResult;
    import PowerPack.com.graph.GraphNodeCategory;
    import PowerPack.com.graph.GraphNode;
    import mx.controls.Alert;

	public class NodeTextValidator extends Validator
	{
        // Define Array for the return value of doValidation().
        private var results:Array;
		
		public function NodeTextValidator()
		{
			super();
		}
		
        // Override the doValidation() method.
        override protected function doValidation(value:Object):Array 
        {
			var str:String = value.toString();
			
			var node:GraphNode;
			
			var category:String;

            // Clear results Array.
            results = [];
			
            // Call base class doValidation().
            results = super.doValidation(value);        
            // Return if there are errors.
            if (results.length > 0)
                return results;
        	
        	if(!(this.source is GraphNode))
            {
                results.push(new ValidationResult(true, null, "invalidSource", 
                    "Not valid source object."));
                return results;
            }      
            
            node = GraphNode(this.source);
            var arrTrans:Array = [];
        	
        	category = (this.source as GraphNode).category;
       		var pattern:RegExp;
        	
        	if (category == GraphNodeCategory.NORMAL)
        	{
        		pattern = /(\$[^_a-z]|\$$)/gi;
			
				if(pattern.test(str))
            	{
                	results.push(new ValidationResult(true, null, "invalidVarName", 
                    	"Not valid variable name."));
                	//return results;
            	}       
        	}
        	else if (category == GraphNodeCategory.SUBGRAPH)
        	{
	        	pattern = /[^a-z0-9_]/gi;
	        	
				if(pattern.test(str))
            	{
                	results.push(new ValidationResult(true, null, "invalidSubgraph", 
                    	"Not valid graph name."));
                	//return results;
            	}
         	}
        	else if (category == GraphNodeCategory.COMMAND)
        	{        		
       			// check for command
       			var bTestCommand:Boolean = false;
       			var bOperationCommand:Boolean = false;
       			var bFunctionCommand:Boolean = false;
       			
        		var lexem:Array = new Array();

        		// lexical analyzer 
        		
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

        				case ';':
       						type = ';'; 
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
        		        		
    			// syntax analyzer 
    			var strSentence:String = "";       			
    			for(i=0; i<lexem.length; i++)
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
				
				// parse assignment
				pattern = /;+/g;						
				strSentence = strSentence.replace(pattern, ";");
									
				pattern = /v=[Vvifsc]/g;
				strSentence = strSentence.replace(pattern, "A");
				pattern = /^(A;)*A{0,1}$/;				
				if(pattern.test(strSentence))
					bOperationCommand = true;						
				
				// parse test
				if(strSentence.search(/[35]/)>=0)
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
						bTestCommand = true; 			        		
				}
				
				// parse function
				if(strSentence.search(/\[.+\]/)>=0)
				{
					pattern = /^(v=){0,1}\[n[nc]{0,}\]$/;
					
					if(pattern.test(strSentence))
						bFunctionCommand = true;
				}  		     
				
				node.toolTip = "";
        		if(bTestCommand)
        		{
        			node.toolTip = "test command:\n";
	    			arrTrans = ["true", "false"];
	    		}
        		if(bOperationCommand)
        		{
        			node.toolTip = "operation command:\n";
	    		}	    		
        		if(bFunctionCommand)
        		{
        			node.toolTip = "function command:\n";
					
					// generate transitions if there is question command
					for(i=0;i<lexem.length;i++)
					{
						if(lexem[i][0]=='n')
							break;
					}						
					pattern = /^(v=){0,1}\[ncc\]$/;
					if(	i+2<lexem.length &&
						pattern.test(strSentence) && 
						lexem[i][1].toLowerCase()=="question" )
					{
						var strVariations:String = lexem[i+2][1];
						strVariations = strVariations.replace(/(^'|'$)/g, "");
						strVariations = strVariations.replace(/\\'/g, "'");
						arrTrans = strVariations.split(/\s*,\s*/);
					}
	    		}
	    		
	    		if(!bTestCommand && !bOperationCommand && !bFunctionCommand)
	    		{
	    			results.push(new ValidationResult(true, null, "invalidCommand", 
                    	"Not valid command."));
       			}	    		
        		node.toolTip += node.text;
        	}

   			node.arrTrans = arrTrans;
            return results;
        }
	}
}