package net.vdombox.ide.common.vo
{
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

		public function get applicationID() : String
		{
			return _pageVO.applicationID;
		}
		
		public function get pageID() : String
		{
			return _pageVO.id;
		}
		
		public function get typeID() : String
		{
			return _typeVO.id;
		}

		public function get name() : String
		{
			return _name;
		}

		public function set name( value : String ) : void
		{

		}

		public function setXMLDescription( description : XML ) : void
		{
			_name = description.@Name[ 0 ];
			name = _name;
		}
	}
}