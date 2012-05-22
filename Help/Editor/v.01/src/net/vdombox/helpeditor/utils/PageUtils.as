package net.vdombox.helpeditor.utils
{
	import net.vdombox.helpeditor.model.SQLProxy;

	public class PageUtils
	{
		private static var _instance	: PageUtils;
		
		private static var MAX_RECURSION_DEPTH	: int = 10;
		
		private var recursionDepth : int = 0;
		
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
			
			var templateRegExp : RegExp = /(<p[^>]*>[ \n\t\r]*){0,1}#Template\([a-zA-Z0-9\-. ]+\)[ \n\t\r]*(<\/p>){0,1}/ig;
			
			var templates : Array = pageContent.match(templateRegExp);
			
			if (!templates || templates.length == 0)
				return pageContent;
			
			var templateName : String; 
			var templateContent : String
			var nameStartIndex : int;
			var nameEndIndex : int;
			
			for each (var template : String in templates)
			{
				nameStartIndex =  template.indexOf("#Template(") + 10;
				nameEndIndex = template.indexOf(")",nameStartIndex);
				
				templateName = template.substring(nameStartIndex, nameEndIndex);
				templateContent = sqlProxy.getTemplateContent(templateName);
				
				pageContent = pageContent.replace(template, templateContent);
			}
			
			recursionDepth ++;
			if (recursionDepth < MAX_RECURSION_DEPTH && pageContent.search(templateRegExp) >= 0)
			{
				pageContent = replacePageTemplates(pageContent);
			}
			
			recursionDepth = 0;
			
			return pageContent;
		}
		
	}
}