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
		
			for each (var wordEn:XML in langEN.children())
			{
				var item:Object = {};
				var id:String = wordEn.@ID;
				
				item["ID"] = id;
								
				for(var i:int = 0; i < countLanguages; i++)
				{
					var lang:XML = data.Language[i];					
					var word:XML =  lang.Sentence.(@ID == id )[0];
					if (!word)
						word = wordEn;
					item[lang.@Code] = word.toString() ;
				}
				arLanguages.addItem(item);
			}
			return arLanguages;
		}
		
//		public function getLanguageVO(id:String):LanguageVO
//		{
//			return _languageList[id];
//		}
		
		public function createXML():void
		{		
		}		
	}
}