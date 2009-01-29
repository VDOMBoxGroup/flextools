package PowerPack.com.gen.parse.parseClasses
{
import PowerPack.com.BasicError;

public class ParsedBlock
{
	public var type:String; // code type

	public var lexems:Array = []; // lexems
	public var fastValidated:Boolean = false;	
	public var fullValidated:Boolean = false;

	public var varPrefix:String = '';
	public var retValue:*; // return value
	public var print:Boolean; // print result value to output buffer
	
	public var trans:Array = []; // transitions array
	public var transition:String; // transition value
	
	public var error:BasicError; // parse error
	public var errFragment:LexemStruct; // error lexem

	public var fragments:Array = []; // code fragments to execute
	public var current:int = 0; // current fragment
}
}