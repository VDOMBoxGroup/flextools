package PowerPack.com
{
	import PowerPack.com.graph.GraphNode;
	import PowerPack.com.graph.GraphNodeCategory;
	import PowerPack.com.parse.*;
	
	import mx.controls.Alert;
	import mx.validators.ValidationResult;
	import mx.validators.Validator;

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
        	node.toolTip = null;
        	
        	category = (this.source as GraphNode).category;
       		var pattern:RegExp;
        	
        	if (category == GraphNodeCategory.NORMAL)
        	{
				if(NodeParser.NormalNodeParse(str).result==false)
            	{
                	results.push(new ValidationResult(true, null, "invalidVarName", 
                    	"Not valid variable name."));
            	}       
        	}
        	else if (category == GraphNodeCategory.SUBGRAPH)
        	{
	        	if(NodeParser.SubgraphNodeParse(str).result==false)
            	{
                	results.push(new ValidationResult(true, null, "invalidSubgraph", 
                    	"Not valid graph name."));
            	}
         	}
        	else if (category == GraphNodeCategory.COMMAND)
        	{        		
       			// check for command
       			       			
       			var nodeDef:Object =
       				NodeParser.CommandNodeParse(str);
				
				node.toolTip = "";
				
				if(nodeDef.resultArray)
					arrTrans = nodeDef.resultArray;
        		
        		if(nodeDef.type == NodeParser.CT_TEST)
        		{
        			node.toolTip = "test command:\n";
	    		}
        		else if(nodeDef.type == NodeParser.CT_OPERATION)
        		{
        			node.toolTip = "operation command:\n";
	    		}	    		
        		else if(nodeDef.type == NodeParser.CT_FUNCTION)
        		{
        			node.toolTip = "function command:\n";
	    		}
	    		
	    		if(nodeDef.result==false)
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