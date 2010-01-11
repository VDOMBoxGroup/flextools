package net.vdombox.ide.common.vo
{
	[Bindable]
	public class PageVO
	{
		public function PageVO( id : String, typeID : String )
		{
			_id = id;
			_typeID = typeID;
		}
		
		private var _id : String;
		private var _typeID : String;
		private var _name : String;
		private var _attributes : Array;
		private var _pageLink : Array;
		private var _objectList : Array;
		
		public function get id() : String
		{
			return _id;
		}
		
		public function get typeID() : String
		{
			return _typeID;
		}
		
		public function get name() : String
		{
			return _name;
		}
		
		public function set name( value : String ) : void
		{
			
		}
		
		public function get attributes() : Array
		{
			return _attributes;
		}
		
		public function set attributes( value : Array ) : void
		{
			
		}
		
		public function get pageLink() : Array
		{
			return _pageLink;
		}
		
		public function set pageLink( value : Array ) : void
		{
			
		}
		
		public function get objectList() : Array
		{
			return _objectList;
		}
		
		public function set objectList( value : Array ) : void
		{
			
		}
		
		public function setXMLDescription( description : XML ) : void
		{
			_id = description.@ID[ 0 ];
			
			_name = description.@Name[ 0 ];
			name = _name;
		}
	}
}