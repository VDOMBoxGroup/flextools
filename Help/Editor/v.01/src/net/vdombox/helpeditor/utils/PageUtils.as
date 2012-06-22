package net.vdombox.helpeditor.utils
{
	import net.vdombox.helpeditor.model.proxy.SQLProxy;

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
		
		public static const templateRegExp : RegExp = /(<p[^>]*>[ \n\t\r]*){0,1}#Template\([a-zA-Z0-9\- ]+\)[ \n\t\r]*(<\/p>){0,1}/ig;
		
		public function replaceTemplatesLinksByTemplateContent (pageContent : String) : String
		{
			var paragraphContent : String;
			
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
				pageContent = replaceTemplatesLinksByTemplateContent(pageContent);
			}
			
			recursionDepth = 0;
			
			return pageContent;
		}
		
		public function renameTemplateInPage (content:String, oldTemplateName:String, newTemplateName:String) : String
		{
			if (!content)
				return content;
			
			if (content.indexOf(oldTemplateName) < 0)
				return content;
				
			var templates : Array = content.match(templateRegExp);
			
			if (!templates || templates.length == 0)
				return content;
			
			var templateName : String; 
			var nameStartIndex : int;
			var nameEndIndex : int;
			var newTemplate : String;
			
			for each (var template : String in templates)
			{
				nameStartIndex =  template.indexOf("#Template(") + 10;
				nameEndIndex = template.indexOf(")",nameStartIndex);
				
				templateName = template.substring(nameStartIndex, nameEndIndex);
				
				if (templateName == oldTemplateName)
				{
					newTemplate = template.substring(0, nameStartIndex) + newTemplateName + template.substring(nameEndIndex);
				
					content = content.replace(template, newTemplate);
				}
			}
			
			return content;
		}
		
		public function renameTemplateInPages (oldTemplateName:String, newTemplateName:String) : void
		{
			var products : Array = sqlProxy.getAllProducts() as Array;
			
			if (!products)
				return;
			
			var productPages : Array;
			for each (var product:Object in products)
			{
				productPages = sqlProxy.getProductsPages(product.name, product.language) as Array;
				
				if (!productPages)
					continue;
				
				for each (var page : Object in productPages)
				{
					var pageContent : String = page.content;
					var pageVersion : Number = Number(page.version);
					
					if (pageContent.indexOf(oldTemplateName) < 0)
						continue;
					
					pageContent = PageUtils.getInstance().renameTemplateInPage(pageContent, oldTemplateName, newTemplateName);
					
					sqlProxy.setPageContent(page.name, pageContent, pageVersion + 1);
				}
			}
			
		}
		
		public static function templateCombination (templateName:String) : String
		{
			return "#Template(" + templateName + ")";
		}
		
	}
}