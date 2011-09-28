package net.vdombox.ide.core.model.vo
{
	import flash.utils.ByteArray;

	public class GalleryItemVO
	{
		public function GalleryItemVO( name : String, content : ByteArray )
		{
			_name = name;
			
			_content = content;
		}
		
		private var _name : String;
		
		private var _content : ByteArray;
		
		public function get name() : String
		{
			return _name;
		}
		
		public function get content() : ByteArray
		{
			return _content
		}
	}
}