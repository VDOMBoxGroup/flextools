package PowerPack.com.gen.parse.parseClasses
{
import PowerPack.com.BasicError;
import PowerPack.com.gen.parse.parseClasses.LexemStruct;

public class ParsedBlock
{
	public var type:String; // node type

	public var lexems:Array = []; // lexems

	public var value:*; // return value
	public var print:Boolean; // print result value to output buffer
	public var trans:Array = []; // transitions array
	public var transition:String; // transition value
	
	public var error:BasicError; // parse error
	public var errLexem:LexemStruct; // error lexem

	public var fragments:Array = []; // code fragments to execute
	public var current:int = 0; // current fragment
}
}