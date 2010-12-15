/*
	Class LanguageProxy is a wrapper over the Language
 */
package net.vdombox.object_editor.model.proxy.componentsProxy
{
	import mx.collections.ArrayCollection;
	
	import net.vdombox.object_editor.model.vo.LanguageVO;
	
	import org.puremvc.as3.interfaces.*;
	import org.puremvc.as3.patterns.proxy.Proxy;
   
    public class LanguageProxy extends Proxy implements IProxy
    {
		public static const NAME:String = "LanguageProxy";		
		
		public function LanguageProxy ( data:Object = null ) 
        {
            super ( NAME, data );			
        }
		
		public function createNew(xml:XML):ArrayCollection
		{
			data = xml.Languages[0];
			var arLanguages:ArrayCollection = new ArrayCollection();		
			var countLanguages:int = data.children().length();
			var	langEN:XML = data.Language.(@Code == "en_US")[0];
			for each (var word:XML in langEN.children())
			{
				var item:Object = {};
				var id:String = word.@ID;
				
				item["ID"] = id;
								
				for(var i:int = 0; i < countLanguages; i++)
				{
					var lang:XML = data.Language[i];
					if( lang.Sentence.@ID != id)
					{
						lang.appendChild(word);
					}
					item[lang.@Code] = lang.Sentence.(@ID == id )[0].toString();
				}
				arLanguages.addItem(item);
			}
			return arLanguages;
		}
		
//		for (var item:String in arLanguages)
//		{
//			var word:Object = arLanguages[item];
//			var id:String = word["ID"];
//			for each(var lang:XML in newLangs.children())
//			{
//				var sentence: XML = new XML("<Sentence/>");
//				sentence.@ID = id;
//				sentence.appendChild(word[lang.@Code]);
//				
//				lang.appendChild(sentence);
//			}
//		}
		
		
		
		
		
//		public function getLanguageVO(id:String):LanguageVO
//		{
//			return _languageList[id];
//		}
		
		public function createXML():void
		{		
		}		
	}
}