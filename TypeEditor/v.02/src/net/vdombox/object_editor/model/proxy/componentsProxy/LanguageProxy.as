/*
	Class LanguageProxy is a wrapper over the Language
 */
package net.vdombox.object_editor.model.proxy.componentsProxy
{
	import mx.rpc.IResponder;
	
	import net.vdombox.object_editor.model.vo.LanguageVO;
	
	import org.puremvc.as3.interfaces.*;
	import org.puremvc.as3.patterns.proxy.Proxy;
   
    public class LanguageProxy extends Proxy implements IProxy, IResponder
    {
		public static const NAME:String = "LanguageProxy";		
		
		public function LanguageProxy ( data:Object = null ) 
        {
            super ( NAME, data );			
        }
		
		public function newLanguage(xml:XML):Array
		{
			data = xml.Languages[0];
					
			var countLanguages:int = data.children().length();
			var	langEN:XML = data.Language.(@Code == "en_US")[0];
			for each (var word:XML in langEN.children())
			{
				var item:Object = {};
				var id:String = word.@ID;
				
				item["ID"] = id;
								
				for(var i:int = 0; i < countLanguages; i++)
				{
					var lang:XML = _data.Language[i];
					item[lang.@Code] = lang.Sentence.(@ID == id )[0].toString();
				}
				arLanguages.addItem(item);
			}
		}
		
		public function getLanguageVO(id:String):LanguageVO
		{
			return _languageList[id];
		}
		
		public function createXML():void
		{		
		}		
	}
}