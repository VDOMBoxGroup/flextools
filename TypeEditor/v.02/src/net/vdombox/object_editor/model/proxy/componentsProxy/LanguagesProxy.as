/*
	Class LanguageProxy is a wrapper over the Language
 */
package net.vdombox.object_editor.model.proxy.componentsProxy
{
	import mx.collections.ArrayCollection;
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
		
		public function createXML():void
		{		
		}		
	}
}