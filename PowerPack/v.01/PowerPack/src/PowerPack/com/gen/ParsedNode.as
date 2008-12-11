package PowerPack.com.gen
{
	import PowerPack.com.BasicError;
	import PowerPack.com.gen.parse.parseClasses.LexemStruct;
	
	public class ParsedNode
	{
		public var result:Boolean; // true if succeed
		public var value:String; // return value
		
		public var lexems:Object; // lexems
		public var program:String; // parsed code for exec
		public var type:String; // node type
		public var variable:String; // variable name for assign
		public var array:Array; // transitions array
		public var transition:String; // transition value
		
		public var error:BasicError; // parse error
		public var lexem:LexemStruct; // error lexem
		
		public var print:Boolean; // print result value to output buffer
				
		public function ParsedNode()
		{
		}
	}
}