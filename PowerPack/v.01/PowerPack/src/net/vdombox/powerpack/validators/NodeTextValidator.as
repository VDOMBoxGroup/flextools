package net.vdombox.powerpack.validators
{
	import src.net.vdombox.powerpack.lib.extendedapi.utils.Utils;
	
	import net.vdombox.powerpack.BasicError;
	import net.vdombox.powerpack.gen.parse.CodeParser;
	import net.vdombox.powerpack.gen.parse.parseClasses.CodeFragment;
	import net.vdombox.powerpack.gen.parse.parseClasses.ParsedBlock;
	import net.vdombox.powerpack.graph.Node;
	import net.vdombox.powerpack.graph.NodeCategory;
	import net.vdombox.powerpack.managers.LanguageManager;
	
	import mx.validators.ValidationResult;
	import mx.validators.Validator;

	public class NodeTextValidator extends Validator
	{
		static private var defaultCaptions:Object = {
			test_command: "test command",
			operation_command: "operation command",
			function_command: "function command",
			
			msg_not_valid_source: "Not valid source object.",
			msg_normal_node_syntax_error: "State syntax error."
		}
		
		static private var _classConstructed:Boolean = classConstruct(); 
		
		static private function classConstruct():Boolean
		{
			LanguageManager.setSentences(defaultCaptions);
			return true;
		}
							
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
			
			var node:Node;
			
			var category:String;

            // Clear results Array.
            results = [];
			
            // Call base class doValidation().
            results = super.doValidation(value);
                    
            // Return if there are errors.
            if (results.length > 0)
                return results;
        	
        	if(!(source is Node))
            {
                results.push(new ValidationResult(true, null, "invalidSource", 
                    LanguageManager.sentences.msg_not_valid_source));
                return results;
            }      
            
            node = Node(source);
            var arrTrans:Array = [];
        	node.toolTip = null;
        	
        	category = node.category;
       		var pattern:RegExp;
        	
        	var parseResult:ParsedBlock;

        	if (category == NodeCategory.NORMAL)
        	{
        		parseResult = CodeParser.ParseText(str);
      
        	}
        	else if (category == NodeCategory.SUBGRAPH)
        	{
        		parseResult = CodeParser.ParseSubgraphNode(str);
         	}
        	else if (category == NodeCategory.COMMAND)
        	{        		
       			parseResult = CodeParser.ParseCode(str);
				
				node.toolTip = "";
				
				if(parseResult.trans)
					arrTrans = parseResult.trans;
        		
        		switch(parseResult.type)
        		{
        			case CodeFragment.CT_TEST:
	        			node.toolTip = LanguageManager.sentences.test_command;
        				break;
        				 
        			case CodeFragment.CT_OPERATION:
	        			node.toolTip = LanguageManager.sentences.operation_command;
        				break;

        			case CodeFragment.CT_FUNCTION:
	        			node.toolTip = LanguageManager.sentences.function_command;
        				break;
        		}
        		//node.toolTip += node.text;
        	}
        		
            if(parseResult && (parseResult.errFragment || parseResult.error))
			{
	        	var error:Error = parseResult.errFragment ? parseResult.errFragment.error : parseResult.error;
        	
                results.push(new ValidationResult(true, null, error.errorID.toString(), error.message));
            	
            	if(parseResult.errFragment)        	
            		node.nodeTextArea.setSelection(
            			parseResult.errFragment.position, 
            			parseResult.errFragment.position + parseResult.errFragment.origValue.length);
            
   			}
   
            if(!Utils.isEqualArrays(node.arrTrans, arrTrans))
	   			node.arrTrans = arrTrans;
   			
            return results;
        }
	}
}