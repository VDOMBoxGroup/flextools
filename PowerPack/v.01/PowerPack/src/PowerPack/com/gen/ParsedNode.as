package PowerPack.com.gen
{
	import PowerPack.com.BasicError;
	import PowerPack.com.gen.parse.parseClasses.LexemStruct;
	
	public class ParsedNode
	{
		public var result:Boolean;
		public var string:String;
		
		public var program:String;
		public var type:String;
		public var func:String;
		public var variable:String;
		public var array:Array;
		public var transition:String;
		
		public var error:BasicError;
		public var lexem:LexemStruct;
		
		public var print:Boolean;
				
		public function ParsedNode()
		{
		}
	}
}