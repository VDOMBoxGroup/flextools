package PowerPack.com.gen.parse.parseClasses
{
import PowerPack.com.BasicError;

public class ParsedBlock
{
	public var type:String;
	public var lexems:Array = []; // lexems
	public var validated:Boolean;	

	public var retValue:*; // return value
	public var print:Boolean; // print result value to output buffer
	public var error:BasicError; // parse error
	
	public var fragments:Array = []; // code fragments to execute
	public var current:int = 0; // current fragment

    //--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

    //----------------------------------
    //  varPrefix
    //----------------------------------
	private var _varPrefix:String = ''; // variable name prefix
	public function get varPrefix():String
	{
		return _varPrefix;
	}
	public function set varPrefix(value:String):void
	{
		if(_varPrefix!=value)
		{
			_varPrefix = value;
			
			for each(var subfragment:Object in fragments)
			{
				if(subfragment is CodeFragment)
					(subfragment as CodeFragment).varPrefix = _varPrefix
			}
		}
	}

    //----------------------------------
    //  ctype
    //----------------------------------
	public function get ctype():String // code type
	{
		if(fragments.length>0)
		{
			(fragments[fragments.length-1] as CodeFragment).ctype;
		}
		return null;
	}	
	
    //----------------------------------
    //  trans
    //----------------------------------
	public function get trans():Array // transitions array
	{
		if(fragments.length>0)
		{
			(fragments[fragments.length-1] as CodeFragment).trans;
		}
		return [];
	}	
	
    //----------------------------------
    //  transition
    //----------------------------------
	public function get transition():String // transitions value
	{
		if(fragments.length>0)
		{
			(fragments[fragments.length-1] as CodeFragment).transition;
		}
		return null;
	}	

	
    //----------------------------------
    //  errFragment
    //----------------------------------			
	public function get errFragment():LexemStruct
	{
		for(var i:int=0; i<fragments.length; i++)
		{
			if((fragments[i] as CodeFragment).error)
				return (fragments[i] as CodeFragment).errFragment;
		}	
		return null; 	
	}
}
}