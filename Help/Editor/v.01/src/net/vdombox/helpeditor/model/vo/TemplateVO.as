package net.vdombox.helpeditor.model.vo
{
	public class TemplateVO
	{
		private var _name		: String;
		private var _content	: String;
		private var _folder	: String;
		
		public function TemplateVO(templateObj : Object = null)
		{
			if (!templateObj)
				return;
			
			if (templateObj.hasOwnProperty("name"))
				name = templateObj.name;
			
			if (templateObj.hasOwnProperty("content"))
				content = templateObj.content;
			
			if (templateObj.hasOwnProperty("folder"))
				folder = templateObj.folder;
		}
		
		public function set name (value : String) : void
		{
			_name = value;
		}
		
		public function get name () : String
		{
			return _name;
		}
		
		public function set content (value : String) : void
		{
			_content = value;
		}
		
		public function get content () : String
		{
			return _content;
		}
		
		public function set folder (value : String) : void
		{
			_folder = value;
		}
		
		public function get folder () : String
		{
			return _folder;
		}
		
	}
}