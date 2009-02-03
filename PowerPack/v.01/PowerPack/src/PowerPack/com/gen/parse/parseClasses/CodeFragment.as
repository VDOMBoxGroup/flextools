package PowerPack.com.gen.parse.parseClasses
{
public class CodeFragment extends LexemStruct
{
	public static var lastExecutedFragment:CodeFragment;
	
	public var fragments:Array = []; // lexems of fragment
	//public var codeFragments:Array = []; // fragments without nonusable characters
	
	public var retValue:*; // return value
	public var code:String; // generated code
	public var print:Boolean; // print result value to output buffer

	// for commands
	public var ctype:String; // command type (FUNCTION|TEST|OPERATION|ASSIGN)
	public var funcName:String; // function
	
	public var varNames:Array = []; // variable names for assign result
	public var validated:Boolean;

	// for variation create. ONLY FOR TOP LEVEL FRAGMENTS
	public var trans:Array = []; // transitions array
	public var transition:String; // transition value	
	
	public var parent:Object; // parent fragment|block
	public var current:int = 0; // current subfragment

    //--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

    //----------------------------------
    //  isTopLevel
    //----------------------------------	
	public function get isTopLevel():Boolean
	{
		if(!parent && !(parent is CodeFragment))
			return true;
		return false; 	
	}	

    //----------------------------------
    //  postSpaces
    //----------------------------------	
	override public function get postSpaces():String
	{
		if(fragments.length>0)
		{
			return fragments[fragments.length-1].postSpaces;
		}
		
		return '';
	}

    //----------------------------------
    //  origValue
    //----------------------------------	
	override public function get origValue():String
	{
		var _origValue:String = '';
		for(var i:int=0; i<fragments.length; i++)
		{
			var curFragment:LexemStruct = fragments[i];
			_origValue += curFragment.origValue + 
				(curFragment is CodeFragment ? '' : curFragment.postSpaces);
		}
		
		return _origValue.substr(0, _origValue.length-postSpaces.length);
	}

    //----------------------------------
    //  lastLexem
    //----------------------------------
    public function get lastLexem():LexemStruct
    {
    	var lastFragment:LexemStruct = fragments[fragments.length-1];
    	
    	if(lastFragment is CodeFragment)
	   		return CodeFragment(lastFragment).lastLexem;
	   	
	   	return lastFragment;
    }	

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
					(subfragment as CodeFragment).varPrefix = _varPrefix;
			}
		}
	}	
		
    //----------------------------------
    //  position
    //----------------------------------	
	override public function get position():int
	{
		if(fragments.length>0)
		{
			return fragments[0].position;
		}		
		return -1; 	
	}

    //----------------------------------
    //  length
    //----------------------------------	
	override public function get length():int
	{
		var sum:int = 0;
		var offset:int = 0;
		var curFragment:LexemStruct;
		
		for(var i:int=0; i<fragments.length; i++)
		{
			curFragment = fragments[i];

			sum += curFragment.length + (curFragment is CodeFragment ? 0 : curFragment.postSpaces.length);
		}
		 
		return sum;
	}
	
    //----------------------------------
    //  errFragment
    //----------------------------------			
	public function get errFragment():LexemStruct
	{
		for(var i:int=0; i<fragments.length; i++)
		{
			var fragment:Object = fragments[i];
			var errFrag:LexemStruct;
			
			if(fragment is CodeFragment)
			{
				if((fragment as CodeFragment).error)
					errFrag = (fragment as CodeFragment).errFragment;
			}
			else if(fragment is LexemStruct)
			{
				if((fragment as LexemStruct).error)
					errFrag = fragment as LexemStruct;
			}
			
			if(errFrag)
				return errFrag;			
		}	
		return null; 	
	}
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 *	Constructor
	 */ 	
	public function CodeFragment(type:String)
	{
		super(null, type, -1, null);
	}
}
}