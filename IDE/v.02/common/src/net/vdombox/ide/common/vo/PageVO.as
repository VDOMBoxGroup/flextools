package net.vdombox.ide.common.vo
{
	[Bindable]
	public class PageVO
	{
		public function PageVO( id : String, applicationVO : ApplicationVO, typeVO : TypeVO )
		{
			_id = id;
			_applicationVO = applicationVO;
			_typeVO = typeVO;
		}
		
		private var _id : String;
		private var _applicationVO : ApplicationVO;
		private var _typeVO : TypeVO;
		private var _name : String;
		
		public function get id() : String
		{
			return _id;
		}
		
		public function get applicationVO() : ApplicationVO
		{
			return _applicationVO;
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
		}
	}
}