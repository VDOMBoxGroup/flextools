package net.vdombox.powerpack.gen.parse.parseClasses
{

public class LexemStruct
{
	public var type : String; // lexem type
	public var code : String; // as3 execution code
	public var relative : LexemStruct; // for brakes pairs

	// USED IN FUNCTIONS FOR ARGUMENTS SEPARATING
	public var operationGroup : int = 0; // operation expression group number (0 - not grouped)

	// USED IN LISTS FOR ARGUMENTS SEPARATING
	public var listGroup : int = 0; // list element number (0 - not grouped)

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  tailSpaces
	//----------------------------------
	private var _tailSpaces : String = '';
	public function get tailSpaces() : String
	{
		return _tailSpaces;
	}

	public function set tailSpaces( value : String ) : void
	{
		if ( _tailSpaces != value )
		{
			_tailSpaces = value;
		}
	}

	//----------------------------------
	//  origValue
	//----------------------------------
	private var _origValue : String; // original value (source text segment)
	public function get origValue() : String
	{
		return _origValue;
	}

	public function set origValue( value : String ) : void
	{
		if ( _origValue != value )
		{
			_origValue = value;
		}
	}

	//----------------------------------
	//  value
	//----------------------------------
	private var _value : String; // evaluate value
	public function get value() : String
	{
		return _value;
	}

	public function set value( val : String ) : void
	{
		if ( _value != val )
		{
			_value = val;
		}
	}

	//----------------------------------
	//  error
	//----------------------------------
	private var _error : Error; // parse error if any
	public function get error() : Error
	{
		return _error;
	}

	public function set error( value : Error ) : void
	{
		_error = value;
	}

	//----------------------------------
	//  position
	//----------------------------------
	private var _position : int = -1; // source text segment`s start position
	public function get position() : int
	{
		return _position;
	}

	public function set position( value : int ) : void
	{
		if ( _position != value )
		{
			_position = value;
		}
	}

	//----------------------------------
	//  length
	//----------------------------------
	public function get length() : int
	{
		return origValue.length;
	}

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 *	Constructor
	 */
	public function LexemStruct( value : String, type : String, position : int, error : Error )
	{
		this.origValue = value;
		this.value = value;
		this.code = value;

		this.type = type;
		this.position = position;
		this.error = error;
	}
}
}