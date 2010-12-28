/*
   Class LanguageProxy is a wrapper over the LanguageVO
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

		public function createFromXML(objTypeXML:XML):LanguagesVO
		{
			var languagesXML: XML = objTypeXML.Languages[0];
			var languagesVO: LanguagesVO = new LanguagesVO();
			var	langEN:XML = languagesXML.Language.(@Code == "en_US")[0];

			for each(var langXML:XML in languagesXML.children())
			{
				var lan:String =  langXML.@Code.toString()

				languagesVO.locales.addItem( {label:lan, data:lan} );
			}	

			for each (var wordEn:XML in langEN.children())
			{

				var words:Object = {};
				var id:String = wordEn.@ID;				
				words["ID"] = id;

//				var wrdsOV  : WordsVO = new WordsVO();
//				wrdsOV["en"] = wordEn.@ID;

				for each(langXML in languagesXML.children())
				{			
					var word:XML =  langXML.Sentence.(@ID == id )[0];
					if (!word)
						word = wordEn;
					words[langXML.@Code] = word.toString();					
				}
				languagesVO.words.addItem(words);				
			}
			return languagesVO;
		}

		public function getWordsOnCarentLocal(langsVO:LanguagesVO):ArrayCollection
		{
			var localeName:String = langsVO.currentLocation;
			var getArr:ArrayCollection = new ArrayCollection();
			var wordsVO:ArrayCollection = langsVO.words;
			var retString:String;

			for each(var word:Object in wordsVO)
			{	
				var str:Object = {};
				str["data"]   = word["ID"];	
				str["label"] = word[localeName];
				getArr.addItem( str );
			}
			return getArr;
		}

		public function getWords(langsVO:LanguagesVO,id:String):Object
		{	
			var localeName:String = langsVO.currentLocation;
			var wordsVO:ArrayCollection = langsVO.words;
			var retString:Object;

			for each(var word:Object in wordsVO)
			{		
				if( word["ID"] == id)
				{
					retString = word;
					break;
				}
			}
			return retString;
		}

		/*public function setWord(langsVO:LanguagesVO,newWord:String):void
		   {
		   var curLocation:String = langsVO.currentLocation;
		   var wordsVO:ArrayCollection = langsVO.words;

		   for each(var word:Object in wordsVO)
		   {
		   if( word["ID"] == id)
		   {
		   word[curLocation] == newWord;
		   break;
		   }
		   }
		 }*/		

		public function getRegExpWord(langsVO:LanguagesVO,code:String):String
		{	
			var  regResource:RegExp = /#Lang\((\d+)\)/;
			var matchResult:Array = code.match(regResource);			
			if (matchResult)
			{
				var word:String = getWord( langsVO, matchResult[1] );
				return word;								
			}
			return "";
		}
		
		private function getWord(langsVO:LanguagesVO,id:String):String
		{
			var localeName:String = langsVO.currentLocation;
			var wordsVO:ArrayCollection = langsVO.words;
			var retString:String;
			
			for each(var word:Object in wordsVO)
			{
				if( word["ID"] == id)
				{
					retString = word[localeName];
					break;
				}
			}
			return retString;
		}

		public function createXML( languagesVO: LanguagesVO ):XML
		{						
			var langsXML:XML = new XML("<Languages/>");
			var wordsVO:ArrayCollection = languagesVO.words;
			var localesVO:ArrayCollection = languagesVO.locales;

			for each(var localeName:Object in localesVO )
			{				
				var lanXML:XML = new XML("<Language/>");
				lanXML.@Code = localeName.data;

				for each(var word:Object in wordsVO)
				{
					var id:String = word["ID"];
					var sentXML: XML = new XML("<Sentence/>");
					sentXML.@ID = id;
					sentXML.appendChild(word[localeName.data]);

					lanXML.appendChild(sentXML);	
				}				
				langsXML.appendChild(lanXML);
			}
			return langsXML;
		}	
		
		public function getNextId(langsVO: LanguagesVO, startId: String, newValue:String = ""):String
		{
			return langsVO.getNextId( startId, newValue);
		}
	}
}

