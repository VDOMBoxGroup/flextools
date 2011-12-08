package net.vdombox.powerpack.gen.parse.parseClasses
{
import net.vdombox.powerpack.BasicError;

public class ParsedBlock
{
	public var lastExecutedFragment:CodeFragment;
	
	public var type:String; // TEXT|CODE
	public var lexems:Array = []; // lexems array

	public var retValue:*; // return value
	public var print:Boolean; // print result value to output buffer
	public var error:BasicError; // parse error
	
	public var fragments:Array = []; // code fragments to execute
	public var current:int = 0; // current fragment
	public var validated:Boolean;
	public var executed:Boolean;

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
			return (fragments[fragments.length-1] as CodeFragment).ctype;
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
			return (fragments[fragments.length-1] as CodeFragment).trans;
		}
		return [];
	}	
	public function set trans(value:Array):void
	{
		if(fragments.length>0)
		{
			(fragments[fragments.length-1] as CodeFragment).trans = value;
		}
	}	
	
    //----------------------------------
    //  transition
    //----------------------------------
	public function get transition():String // transitions value
	{
		if(fragments.length>0)
		{
			return (fragments[fragments.length-1] as CodeFragment).transition;
		}
		return null;
	}
	public function set transition(value:String):void
	{
		if(fragments.length>0)
		{
			(fragments[fragments.length-1] as CodeFragment).transition = value; 
		}
	}
	
    //----------------------------------
    //  errFragment
    //----------------------------------			
	public function get errFragment():LexemStruct
	{
		for(var i:int=0; i<fragments.length; i++)
		{
			var curFragm:LexemStruct = (fragments[i] as CodeFragment).errFragment

			if(curFragm)
				return curFragm;
		}	
		return null; 	
	}

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------
		
	public function resetCurrent():void
	{
		executed = false;
		current = 0;		

		for(var i:int=0; i<fragments.length; i++)
		{
			if(fragments[i] is CodeFragment)
				CodeFragment(fragments[i]).resetCurrent();
		}
	}
}
}