/*
	Class LanguageProxy is a wrapper over the Language
 */
package net.vdombox.object_editor.model.proxy.componentsProxy
{
	import mx.collections.ArrayCollection;
	
	import net.vdombox.object_editor.model.vo.ObjectTypeVO;
	
	import org.puremvc.as3.interfaces.*;
	import org.puremvc.as3.patterns.proxy.Proxy;
   
    public class LanguagesProxy extends Proxy implements IProxy
    {
		public static const NAME:String = "LanguageProxy";		
		
		public function LanguagesProxy ( data:Object = null ) 
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
				var words:Object = {};
				var id:String = wordEn.@ID;
				
				words["ID"] = id;
								
				for(var i:int = 0; i < countLanguages; i++)
				{
					var lang:XML = data.Language[i];					
					var word:XML =  lang.Sentence.(@ID == id )[0];
					if (!word)
						word = wordEn;
					words[lang.@Code] = word.toString();
				}
				arLanguages.addItem(words);				
			}
			return arLanguages;
		}
		
		public function getWord(id:String):String
		{
			return "qu";
		}
		
		public function createXML( objTypeVO: ObjectTypeVO ):XML
		{						
			var newLangs:XML = new XML("<Languages/>");
			var languages:ArrayCollection = objTypeVO.languages;
			
			var language:Object = objTypeVO.languages[0];
			for(var i:int=0; i < language.length; i++)
			{
				//var language:Object = objTypeVO.languages[i];
				var lanItem:XML = new XML("<Language/>");
				lanItem.@Code = language["Code"];
				newLangs.appendChild(lanItem);
			}
			for (var item:String in languages)
			{
				var words:Object = languages[item];
				var id:String = words["ID"];
				for each(var lang:XML in newLangs.children())
				{
					var sentence: XML = new XML("<Sentence/>");
					sentence.@ID = id;
					sentence.appendChild(words[lang.@Code]);
					
					lang.appendChild(sentence);
				}
			}			
			
			return newLangs;
		}		
	}
}