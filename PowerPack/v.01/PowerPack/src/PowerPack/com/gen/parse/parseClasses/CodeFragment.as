package PowerPack.com.gen.parse.parseClasses
{
import PowerPack.com.BasicError;

public class CodeFragment
{
	public var type:String; // command type

	public var lexems:Array = []; // lexems

	public var func:String; // function
	public var varName:String; // variable name for assign result

	public var trans:Array = []; // transitions array
	public var transition:String; // transition value
	public var value:*; // return value
	public var print:Boolean; // print result value to output buffer
	
	public var error:BasicError; // any parse or runtime error
	public var errLexem:LexemStruct; // error lexem

	public var parrent:Object; // parent fragment
	public var fragments:Array = []; // code subfragments to execute
	public var current:int = 0; // current subfragment
}
}