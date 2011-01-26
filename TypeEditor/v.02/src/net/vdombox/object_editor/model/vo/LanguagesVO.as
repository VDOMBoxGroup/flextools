package net.vdombox.object_editor.model.vo
{
	import mx.collections.ArrayCollection;
	import mx.messaging.SubscriptionInfo;

	public class LanguagesVO
	{
		public var currentLocation:	String 			= "en_US";
		public var words:			ArrayCollection = new ArrayCollection();		
		public var locales:			ArrayCollection = new ArrayCollection();

		//required to verify the uniqueness of the words ID
		public var isUsedWords:		Object			= new Object();

		public function LanguagesVO()
		{			
		}

		public function getNextId(startId: String, newValue:String = "", oldWord:Object = null):String
		{
			var idInt  :uint = 1;
			var attrID :String = startId +"0"+ idInt;		
			var idList :ArrayCollection = new ArrayCollection();

			for each(var word:Object in words)
				if ( word["ID"].slice(0, 1) == startId )
					idList.addItemAt(word["ID"], int(word));

			var newWrd  :Object = new Object();
			var nextInd :String = new String();

			if( idList.length > 0 )
			{
				var lengthNextInd:int = idList[0].length; 				
				nextInd = (int(idList[0])+1).toString();
				
				//for numbers: "001", "002", ..., "010"
				lengthNextInd -=nextInd.length;
				if(lengthNextInd > 0)
				{
					for(var i:int=0; i < lengthNextInd; i++)
					{
						nextInd = "0" + nextInd;
					}
				}				
			}
			else
				nextInd = startId.toString() + "00";

			newWrd["ID"] = nextInd;


			for each( var localeName:Object  in locales )
				newWrd[localeName.data] = (oldWord) ? oldWord[localeName.data] : "";


			newWrd[currentLocation] = newValue;		

			//добавляет в конец списка
			words.addItem( newWrd );			

			return "#Lang("+ nextInd + ")";
		}
	}
}

