package PowerPack.com.gen.parse.parseClasses
{
	import PowerPack.com.gen.errorClasses.CompilerError;
	
public class LexemStruct
{
	public var origValue:String;
	public var position:int;
	public var type:String;
	public var error:Error;

	public var value:String;		
	public var operationGroup:int;
	public var listGroup:int;
	
	public function LexemStruct(value:String, type:String, position:int, error:Error)
	{
		this.origValue = this.value = value;
		this.type = type;
		this.position = position;
		this.error = error;
		this.operationGroup = 0;
		this.listGroup = 0;
	}
		
}
}