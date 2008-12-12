package PowerPack.com.gen
{
import PowerPack.com.BasicError;
import PowerPack.com.gen.parse.parseClasses.LexemStruct;

public class ParsedNode
{
	public var result:Boolean; // 'true' if succeed, else 'false'
	public var value:Object; // return value
	
	public var type:String; // node type
	public var lexemsGroup:Array; // array of lexems
	public var current:int = 0; // current code segment
	
	public var funcs:Array; // function variables
	public var vars:Array; // function variables
	
	public var array:Array; // transitions array
	public var transition:String; // transition value
	
	public var error:BasicError; // parse error
	public var lexem:LexemStruct; // error lexem
	
	public var print:Boolean; // print result value to output buffer
}
}