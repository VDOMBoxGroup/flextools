/*
	Class LanguageProxy is a wrapper over the Language
 */
package net.vdombox.object_editor.model.proxy.componentsProxy
{
	import mx.collections.ArrayCollection;
	
	import net.vdombox.object_editor.model.vo.LanguagesVO;
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
		
		public function createNew(objTypeXML:XML):LanguagesVO
		{
			var languagesXML : XML = objTypeXML.Languages[0];
//			var arLanguages:ArrayCollection = new ArrayCollection();
			var languagesVO:LanguagesVO = new LanguagesVO();			
//			var countLanguages:int = data.children().length();
			
			
			var	langEN:XML = languagesXML.Language.(@Code == "en_US")[0];
			
			for each(var langXML:XML in languagesXML.children())
			{
				languagesVO.locales.push( langXML.@Code.toString() );
			}			
			
			for each (var wordEn:XML in langEN.children())
			{
				var words:Object = {};
				var id:String = wordEn.@ID;				
				words["ID"] = id;
								
				for each(var langXML:XML in languagesXML.children())
				{
//					var langXML:XML = data.Language[i];					
					var word:XML =  langXML.Sentence.(@ID == id )[0];
					if (!word)
						word = wordEn;
					words[langXML.@Code] = word.toString();					
				}
				languagesVO.words.addItem(words);				
			}
			return languagesVO;
		}
		
		public function getWord(id:String):String
		{
			return "qu";
		}
		
		public function createXML( objTypeVO: ObjectTypeVO ):XML
		{						
			var langsXML:XML = new XML("<Languages/>");
			var wordsVO:ArrayCollection = objTypeVO.languages.words;
			var localesVO:Array = objTypeVO.languages.locales;
						
			for each(var localeName:String in localesVO )
			{				
				var lanXML:XML = new XML("<Language/>");
				lanXML.@Code = localeName;
				
				for each(var word:Object in wordsVO)
				{
					var id:String = word["ID"];
					var sentXML: XML = new XML("<Sentence/>");
						sentXML.@ID = id;
						sentXML.appendChild(word[localeName]);
					
						lanXML.appendChild(sentXML);	
				}				
				langsXML.appendChild(lanXML);
			}
			return langsXML;
		}		
	}
}