/*
   Class LanguageProxy is a wrapper over the LanguageVO
 */
package net.vdombox.object_editor.model.proxy.componentsProxy
{
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	
	import net.vdombox.object_editor.model.ErrorLogger;
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
			var languagesVO: LanguagesVO = new LanguagesVO();
			try
			{
				var languagesXML: XML = objTypeXML.Languages[0];
				var	langEN:XML = languagesXML.Language.(@Code == "en_US")[0];
				
				for each (var langXML:XML in languagesXML.children())
				{
					var lan:String =  langXML.@Code.toString()
					languagesVO.locales.addItem( {label:lan, data:lan} );
				}	
				
				for each (var wordEn:XML in langEN.children())
				{
					var words:Object = {};
					var id:String = wordEn.@ID;	
					//temp languagesVO.isUsedWords[id] = false;
					words["ID"] = id;
					
					for each (langXML in languagesXML.children())
					{			
						var word:XML =  langXML.Sentence.(@ID == id )[0];
						if (!word)
							word = wordEn;
						words[langXML.@Code] = word.toString();					
					}
					languagesVO.tempWords.addItem(words);				
				}				
			}		
			catch(error:TypeError)
			{	
				ErrorLogger.instance.logError("Failed: not teg: <Language>", "LanguageProxy.createFromXML()");
			}
			finally
			{
				return languagesVO;
			}
		}
	
		/**
		 * 
		 * @param langsVO
		 * @return all the names of locales in LanguagesVO
		 * 
		 */		
		public function getWordsOnCarentLocal(langsVO:LanguagesVO):ArrayCollection
		{
			var localeName:String = langsVO.currentLocation;
			var getArr:ArrayCollection = new ArrayCollection();
			var wordsVO:ArrayCollection = langsVO.words;
			var retString:String;

			for each (var word:Object in wordsVO)
			{	
				var str:Object = {};
				str["data"]  = word["ID"];	
				str["label"] = word[localeName];
				getArr.addItem( str );
			}
			return getArr;
		}

		/**
		 * 
		 * @param langsVO
		 * @param id - ID of word
		 * @return object of ID and the value of ID in different locales
		 * 
		 */		
		public function tempGetWords(langsVO:LanguagesVO,id:String):Object
		{	
			var localeName:String = langsVO.currentLocation;
			var wordsVO:ArrayCollection = langsVO.tempWords;
			var retString:Object;
			
			for each (var word:Object in wordsVO)
			{		
				if (word["ID"] == id)
				{
					retString = word;
					break;
				}
			}
			return retString;
		}
		public function getWords(langsVO:LanguagesVO,id:String):Object
		{	
			var localeName:String = langsVO.currentLocation;
			var wordsVO:ArrayCollection = langsVO.words;
			var retString:Object;

			for each (var word:Object in wordsVO)
			{		
				if (word["ID"] == id)
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

		/**
		 * 
		 * @param langsVO
		 * @param code in format: #Lang(ID)
		 * @return a word in the current location
		 * 
		 */		
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
				
		/**
		 * 
		 * @param langsVO - current LanguagesVO
		 * @param code in formate: #Lang(ID)
		 * @return ID
		 * 
		 */		
		public function getRegExpID(langsVO:LanguagesVO,code:String):String
		{				
			var regResource:RegExp = /#Lang\((\d+)\)/;
			var matchResult:Array = code.match(regResource);			
			return matchResult[1] ;
		}
		
		/**
		 * 
		 * @param langsVO
		 * @param id - ID of word
		 * @return a word in the current location
		 * 
		 */		
		private function getWord(langsVO:LanguagesVO,id:String):String
		{
			var localeName:String = langsVO.currentLocation;
			var wordsVO:ArrayCollection = langsVO.words;
			var retString:String;
			
			for each (var word:Object in wordsVO)
			{
				if (word["ID"] == id)
				{
					retString = word[localeName];
					break;
				}
			}
			return retString;
		}

		public function createXML(languagesVO: LanguagesVO):XML
		{		
			var langsXML:XML = <Languages/>;
			var wordsVO:ArrayCollection = languagesVO.words;
			var localesVO:ArrayCollection = languagesVO.locales;

			for each (var localeName:Object in localesVO)
			{				
				var lanXML:XML = <Language/>;
				lanXML.@Code = localeName.data;

				for each (var word:Object in wordsVO)
				{
					var id:String = word["ID"];
					var sentXML: XML = <Sentence/>;
					sentXML.@ID = id;
					sentXML.appendChild(word[localeName.data]);

					lanXML.appendChild(sentXML);	
				}				
				langsXML.appendChild(lanXML);
			}
			return langsXML;
		}		
		
		/**
		 * 
		 * @param langsVO - current LanguagesVO
		 * @param startId - first number of ID in new Word
		 * @param owner   - path to new Word
		 * @param newValue - value of curent local Language of new Word
		 * @return new Word
		 * 
		 */		
		public function newWords(langsVO: LanguagesVO, startId: String, owner: String, newValue: String = ""):String
		{
			//wordID have format: "#Lang(ID)"
			var wordID:String = langsVO.getNextId( startId, newValue ).toString();  
			
			var str:String = getRegExpID( langsVO,wordID );
			langsVO.isUsedWords[str]	= true;
			langsVO.isWordsOwner[str]	= owner;
			return wordID;
		}
		
		/**
		 * format of id: "#Lang(ID)"
		 * 
		**/
		public function changeWordsOwner(objVO: ObjectTypeVO, IDs:Object, newValue: String):void
		{
			for each (var id:String in IDs)
			{
				var s:String = getRegExpID(objVO.languages, id);
				var st:String = objVO.languages.isWordsOwner[s] as String;
				var ar:Array = st.split(".");
				objVO.languages.isWordsOwner[s] = newValue + "."+ ar[ar.length-1];
			}
		}		
		
		/**
		 * 
		 * @param langsVO - current LanguagesVO;
		 * @param startId - first number of ID;
		 * @param newValue - value for current location language;
		 * @param oldWord - copy to newWord;
		 * @return ID of new word with new ID, ID - first not used, i nformat: "#Lang(ID)". 
		 * 
		 */		
		public function getNextId(langsVO: LanguagesVO, startId: String, newValue: String = "", oldWord: Object = null):String
		{
			return langsVO.tempGetNextId( startId, "", oldWord ).toString();
		}		
		
		/**
		 * 
		 * @param langsVO - current LanguagesVO;		 
		 * @param firstNumberID - figure with which to start the ID, in format: id:uint; 
		 * @param idString - ID in format: "#Lang(ID)";
		 * @param owner - name of owner;  
		 * @return not used ID in format: "#Lang(ID)".
		 * 
		 */
		public function used(langsVO: LanguagesVO, firstNumberID:uint, idString:String, owner:String):String
		{	
			var id:String = getRegExpID(langsVO, idString);
			var newID:String = getNextId(langsVO, firstNumberID.toString().slice(0,1), "", tempGetWords(langsVO, id));
			
			var idNumber:String = newID.toString().slice(6,newID.length-1);
			langsVO.isUsedWords[idNumber] = true;
			langsVO.isWordsOwner[idNumber]= owner;
			return newID;		
		}
				
		public function deleteWord(objTypeVO:ObjectTypeVO, word:String):void
		{		
			if (word != "")
			{
				var id:String = getRegExpID(objTypeVO.languages, word);
				var words:Object = getWords(objTypeVO.languages, id);
				if (words)
				{
					var ind:int = objTypeVO.languages.words.getItemIndex(words)
					objTypeVO.languages.words.removeItemAt(ind);
				}
			}
		}		
	}
}