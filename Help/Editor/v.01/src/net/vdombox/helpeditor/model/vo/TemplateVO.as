package net.vdombox.helpeditor.model.vo
{
	import net.vdombox.helpeditor.utils.RuntimeUtils;

	public class TemplateVO
	{
		private var _name		: String;
		private var _content	: String;
		private var _folder	: String;
		
		private var _invalidXMLFormat : Boolean;
		
		[Bindable]
		public var errorMsg : String;
		
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
		
		public function get validXMLFormat () : Boolean
		{
			try 
			{
				var xml : XMLList = new XMLList(content);
			} 
			catch (error:Error) 
			{
				errorMsg = RuntimeUtils.isRuntimeError(error.message) ? RuntimeUtils.getRuntimeErrorMessage(error.message) : error.message;
				
				return false;
			}
			
			return true;
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