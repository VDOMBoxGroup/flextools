package net.vdombox.ide.common.model._vo
{
	public class ColorSchemeVO
	{
		public var name : String;
		private var _defaul_t : uint;
		private var _keyword : uint;
		private var _keyword2 : uint;
		private var _e4x : uint;
		private var _regExp : uint;
		private var _comment : uint;
		private var _string : uint;
		private var _number : uint;
		private var _symbol : uint;
		private var _nameFunction : uint;
		private var _nameClass : uint;
		private var _topType : uint;
		
		private var empty : uint = 0xFFFFFF;
		
		public function ColorSchemeVO( name : String )
		{
			this.name = name;
		}
		
		public function get defaul_t():uint
		{
			return _defaul_t;
		}
		
		public function set defaul_t(value:uint):void
		{
			_defaul_t = value ? value : empty;
		}
		
		public function get keyword():uint
		{
			return _keyword;
		}
		
		public function set keyword(value:uint):void
		{
			_keyword = value ? value : empty;
		}
		
		public function get keyword2():uint
		{
			return _keyword2;
		}
		
		public function set keyword2(value:uint):void
		{
			_keyword2 = value ? value : empty;
		}
		
		public function get e4x():uint
		{
			return _e4x;
		}
		
		public function set e4x(value:uint):void
		{
			_e4x = value ? value : empty;
		}
		
		public function get comment():uint
		{
			return _comment;
		}
		
		public function set comment(value:uint):void
		{
			_comment = value ? value : empty;
		}
		
		public function get string():uint
		{
			return _string;
		}
		
		public function set string(value:uint):void
		{
			_string = value ? value : empty;
		}

		public function get number():uint
		{
			return _number;
		}

		public function set number(value:uint):void
		{
			_number = value ? value : empty;
		}
		
		public function get symbol():uint
		{
			return _symbol;
		}
		
		public function set symbol(value:uint):void
		{
			_symbol = value ? value : empty;
		}

		public function get regExp():uint
		{
			return _regExp;
		}

		public function set regExp(value:uint):void
		{
			_regExp = value ? value : empty;
		}
		
		public function get nameFunction():uint
		{
			return _nameFunction;
		}
		
		public function set nameFunction(value:uint):void
		{
			_nameFunction = value ? value : empty;
		}
		
		public function get nameClass():uint
		{
			return _nameClass;
		}
		
		public function set nameClass(value:uint):void
		{
			_nameClass = value ? value : empty;
		}
		
		public function get topType():uint
		{
			return _topType;
		}
		
		public function set topType(value:uint):void
		{
			_topType = value ? value : empty;
		}

	}
}