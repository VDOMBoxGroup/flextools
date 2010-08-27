package net.vdombox.ide.common.vo
{
	import net.vdombox.ide.common.interfaces.IVDOMObjectVO;

	[Bindable]
	public class ObjectVO implements IVDOMObjectVO
	{
		public function ObjectVO( pageVO : PageVO, typeVO : TypeVO )
		{
			_pageVO = pageVO;
			_typeVO = typeVO;
		}

		public var parentID : String;
		
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

		public function setID( value : String ) : void
		{
			_id = value;
		}
		
		public function setXMLDescription( description : XML ) : void
		{
			name = description.@Name[ 0 ];
		}
	}
}