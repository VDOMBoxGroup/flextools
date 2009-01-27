package PowerPack.com.gen.parse.parseClasses
{
import PowerPack.com.gen.errorClasses.CompilerError;
	
public class LexemStruct
{
	public var origValue:String; // original value (source text segment)
	public var position:int; // source text segment`s start position
	public var type:String; // lexem type
	public var error:Error; // parse error if any

	public var value:String; // modified value
	public var operationGroup:int; // operation expression group number (0 - not grouped) USED IN LISTS FOR ARGUMENTS SEPARATING
	public var listGroup:int; // list element number (0 - not grouped) NOT USED!!!
	
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