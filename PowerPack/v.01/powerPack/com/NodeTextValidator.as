package powerPack.com
{
	import mx.validators.Validator;
    import mx.validators.ValidationResult;

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

            // Clear results Array.
            results = [];
			
            // Call base class doValidation().
            results = super.doValidation(value);        
            // Return if there are errors.
            if (results.length > 0)
                return results;
        
        	var pattern:RegExp = /(\$[^_A-Za-z]|\$$)/gi;
			if(pattern.test(str))
            {
                results.push(new ValidationResult(true, null, "invalidVarName", 
                    "Not valid variable name."));
                return results;
            }       
			
            return results;
        }
	}
}