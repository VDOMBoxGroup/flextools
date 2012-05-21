package net.vdombox.helpeditor.utils
{
	import net.vdombox.helpeditor.model.SQLProxy;

	public class PageUtils
	{
		private static var _instance	: PageUtils;
		
		private var sqlProxy : SQLProxy = new SQLProxy();
		
		public function PageUtils()
		{
			if (_instance)
				throw new Error( "PageUtils can only be accessed through PageUtils.getInstance()" );
		}
		
		public static function getInstance() : PageUtils
		{
			if (!_instance)
			{
				_instance = new PageUtils();
			}
			
			return _instance;
		}
		
		public function replacePageTemplates (pageContent : String) : String
		{
			var paragraphContent : String;
			
			var templateRegExp : RegExp = /(<p[^>]*>[ \n\t\r]*){0,1}#Template\([A-F0-9]{8}(?:-[A-F0-9]{4}){3}-[A-Z0-9]{12}\)(<\/p>){0,1}/g;
			
			var templates : Array = pageContent.match(templateRegExp);
			
			if (!templates || templates.length == 0)
				return pageContent;
			
			var templateName : String; 
			var templateContent : String
			var nameStartIndex : int;
			
			for each (var template : String in templates)
			{
				nameStartIndex =  template.indexOf("(") + 1;
				templateName = template.substr(nameStartIndex, 36);
				templateContent = sqlProxy.getTemplateContent(templateName);
				
				pageContent = pageContent.replace(template, templateContent);
			}
			
			return pageContent;
		}
		
	}
}