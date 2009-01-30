package PowerPack.com.gen.parse.parseClasses
{
public class CodeFragment extends LexemStruct
{
	public var fragments:Array = []; // lexems of fragment
	public var codeFragments:Array = []; // fragments without nonusable characters
	
	public var retValue:*; // return value
	public var print:Boolean; // print result value to output buffer

	// for commands
	public var ctype:String; // command type
	public var funcName:String; // function
	
	public var varNames:Array = []; // variable names for assign result
	public var validated:Boolean;

	// for variation create. ONLY FOR TOP LEVEL FRAGMENTS
	public var trans:Array = []; // transitions array
	public var transition:String; // transition value	
	
	public var parent:Object; // parent fragment
	public var current:int = 0; // current subfragment

    //--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

    //----------------------------------
    //  origValue
    //----------------------------------	
	override public function get origValue():String
	{
		var _origValue:String = '';
		for(var i:int=0; i<fragments.length; i++)
		{
			_origValue += LexemStruct(fragments[i]).origValue + LexemStruct(fragments[i]).postSpaces;
		}
		
		return _origValue;
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
					(subfragment as CodeFragment).varPrefix = _varPrefix
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
		for(var i:int=0; i<fragments.length; i++)
		{
			var curFragment:LexemStruct = fragments[i];
			var nextFragment:LexemStruct = null;
			if(i<fragments.length-1)
				nextFragment = fragments[i+1];
			
			sum += offset;
			sum += curFragment.length;
			
			if(i<fragments.length-1)
				offset = nextFragment.position - (curFragment.position + curFragment.length);
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