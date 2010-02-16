package net.vdombox.ide.common.vo
{
	[Bindable]
	public class ObjectVO
	{
		public function ObjectVO( id : String, pageVO : PageVO, typeVO : TypeVO )
		{
			_id = id;
			_pageVO = pageVO;
			_typeVO = typeVO;
		}

		private var _id : String;

		private var _pageVO : PageVO;
		private var _typeVO : TypeVO;

		private var _name : String;

		public function get id() : String
		{
			return _id;
		}

		public function get pageVO() : PageVO
		{
			return _pageVO;
		}

		public function get typeVO() : TypeVO
		{
			return _typeVO;
		}

		public function get name() : String
		{
			return _name;
		}

		public function set name( value : String ) : void
		{
			_name = value;
		}

		public function setXMLDescription( description : XML ) : void
		{
			name = description.@Name[ 0 ];
			;
		}
	}
}