package net.vdombox.ide.common.model._vo
{

	public class ColorSchemeVO
	{
		public var name : String;

		private var _defaul_t : uint;

		private var _keyword : uint;

		private var _keyword2 : uint;

		private var _keyword3 : uint;

		private var _e4x : uint;

		private var _regExp : uint;

		private var _comment : uint;

		private var _string : uint;

		private var _stringLiteral : uint;

		private var _number : uint;

		private var _symbol : uint;

		private var _nameFunction : uint;

		private var _nameClass : uint;

		private var _topType : uint;

		private var _backGroundColor : uint;

		private var _selectionColor : uint;

		private var _selectionRectsColor : uint;

		private var _indentLinesShapeColor : uint;


		private var _cursorColor : uint;

		private var _lineNumberColor : uint;

		private var _skobkiColor : uint;

		private var _needChangeColorSelected : Boolean;

		public function ColorSchemeVO( name : String )
		{
			this.name = name;
		}

		public function get skobkiColor() : uint
		{
			return _skobkiColor;
		}

		public function set skobkiColor( value : uint ) : void
		{
			_skobkiColor = value;
		}

		public function get lineNumberColor() : uint
		{
			return _lineNumberColor;
		}

		public function set lineNumberColor( value : uint ) : void
		{
			_lineNumberColor = value;
		}

		public function get defaul_t() : uint
		{
			return _defaul_t;
		}

		public function set defaul_t( value : uint ) : void
		{
			_defaul_t = value;
		}

		public function get keyword() : uint
		{
			return _keyword;
		}

		public function set keyword( value : uint ) : void
		{
			_keyword = value;
		}

		public function get keyword2() : uint
		{
			return _keyword2;
		}

		public function set keyword2( value : uint ) : void
		{
			_keyword2 = value;
		}

		public function get keyword3() : uint
		{
			return _keyword3;
		}

		public function set keyword3( value : uint ) : void
		{
			_keyword3 = value;
		}

		public function get e4x() : uint
		{
			return _e4x;
		}

		public function set e4x( value : uint ) : void
		{
			_e4x = value;
		}

		public function get comment() : uint
		{
			return _comment;
		}

		public function set comment( value : uint ) : void
		{
			_comment = value;
		}

		public function get string() : uint
		{
			return _string;
		}

		public function set string( value : uint ) : void
		{
			_string = value;
		}

		public function get stringLiteral() : uint
		{
			return _stringLiteral;
		}

		public function set stringLiteral( value : uint ) : void
		{
			_stringLiteral = value;
		}

		public function get number() : uint
		{
			return _number;
		}

		public function set number( value : uint ) : void
		{
			_number = value;
		}

		public function get symbol() : uint
		{
			return _symbol;
		}

		public function set symbol( value : uint ) : void
		{
			_symbol = value;
		}

		public function get regExp() : uint
		{
			return _regExp;
		}

		public function set regExp( value : uint ) : void
		{
			_regExp = value;
		}

		public function get nameFunction() : uint
		{
			return _nameFunction;
		}

		public function set nameFunction( value : uint ) : void
		{
			_nameFunction = value;
		}

		public function get nameClass() : uint
		{
			return _nameClass;
		}

		public function set nameClass( value : uint ) : void
		{
			_nameClass = value;
		}

		public function get topType() : uint
		{
			return _topType;
		}

		public function set topType( value : uint ) : void
		{
			_topType = value;
		}

		public function get backGroundColor() : uint
		{
			return _backGroundColor;
		}

		public function set backGroundColor( value : uint ) : void
		{
			_backGroundColor = value;
		}

		public function get selectionColor() : uint
		{
			return _selectionColor;
		}

		public function set selectionColor( value : uint ) : void
		{
			_selectionColor = value;
		}

		public function get selectionRectsColor() : uint
		{
			return _selectionRectsColor;
		}

		public function set selectionRectsColor( value : uint ) : void
		{
			_selectionRectsColor = value;
		}

		public function get indentLinesShapeColor() : uint
		{
			return _indentLinesShapeColor;
		}

		public function set indentLinesShapeColor( value : uint ) : void
		{
			_indentLinesShapeColor = value;
		}

		public function get needChangeColorSelected() : Boolean
		{
			return _needChangeColorSelected;
		}

		public function set needChangeColorSelected( value : Boolean ) : void
		{
			_needChangeColorSelected = value;
		}

		public function get cursorColor() : uint
		{
			return _cursorColor;
		}

		public function set cursorColor( value : uint ) : void
		{
			_cursorColor = value;
		}


	}
}
