package PowerPack.com.gen.parse.parseClasses
{
import PowerPack.com.gen.parse.Parser;

import mx.utils.UIDUtil;
	
public class CodeFragment extends LexemStruct
{
	public static const CT_OPERATION:String = 'operation';
	public static const CT_TEST:String = 'test';
	public static const CT_FUNCTION:String = 'function';
	public static const CT_ASSIGN:String = 'assign';
	public static const CT_TEXT:String = 'text';
	public static const CT_LIST:String = 'list';

	public var fragments:Array = []; // lexems of fragment
	//public var codeFragments:Array = []; // fragments without nonusable characters
	
	public var retVarName:String = "tmp_" + UIDUtil.createUID().replace(/-/g, "_"); 
	public var retValue:*; // return value
	public var print:Boolean; // print result value to output buffer

	// for commands
	public var ctype:String; // command type (FUNCTION|TEST|OPERATION|ASSIGN|LIST|TEXT)
	public var funcName:String; // function
	
	public var varNames:Array = []; // variable names for assign result
	public var validated:Boolean;

	// for variation create. ONLY FOR TOP LEVEL FRAGMENTS
	public var trans:Array = []; // transitions array
	public var transition:String; // transition value	
	
	public var parent:Object; // parent fragment|block
	public var current:int = 0; // current subfragment
	public var executed:Boolean = false;

    //--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

    //----------------------------------
    //  lastExecutedFragment
    //----------------------------------	
	public function get lastExecutedFragment():CodeFragment
	{
		var topLevel:Object = getTopLevel();		
		return topLevel.hasOwnProperty('lastExecutedFragment') ? topLevel.lastExecutedFragment : null;
	}
	public function set lastExecutedFragment(value:CodeFragment):void
	{
		var topLevel:Object = getTopLevel();		
		if(topLevel.hasOwnProperty('lastExecutedFragment'))
			topLevel.lastExecutedFragment = value;
	}

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
    //  evalValue
    //----------------------------------	
	public function get evalValue():String
	{		
		var _value:String = '';
		for(var i:int=0; i<fragments.length; i++)
		{
			var curFragment:LexemStruct = fragments[i];
			
			if(curFragment is CodeFragment)
			{
				if(CodeFragment(curFragment).ctype == CT_FUNCTION)
					_value += CodeFragment(curFragment).retValue + curFragment.postSpaces;
				else if(CodeFragment(curFragment).type == 'W')
					_value += CodeFragment(curFragment).retValue + curFragment.postSpaces;
				else
					_value += CodeFragment(curFragment).evalValue;
			}			
			else if(curFragment is LexemStruct)
			{
				if(curFragment.type == 'v')			
					_value += curFragment.value + curFragment.postSpaces;
				else
					_value += curFragment.origValue + curFragment.postSpaces;
			}
		}
		
		return _value.substr(0, _value.length-postSpaces.length);
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
	
	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------
		
	public function getTopLevel():Object
	{
		var target:Object = parent;	
		
		while(target.parent)
		{
			target = target.parent;
		}
		
		return target;
	}
}
}