package net.vdombox.object_editor.model.vo
{
	import mx.collections.ArrayCollection;
	import mx.messaging.SubscriptionInfo;

	public class LanguagesVO
	{
		public var currentLocation:String 	= "en_US";
		public var words:ArrayCollection 	= new ArrayCollection();		
		public var locales:ArrayCollection 	= new ArrayCollection();
		
		public function LanguagesVO()
		{
			
		}
		
		public function getNextId(startId: String):String
		{
			var idInt:uint = 1;
			var attrID:String = startId +"0"+ idInt;//"#Lang("+startId+"0" + idInt+")";
			
		/*	var idList:Object = new Object();
			
			for each(var word:Object in words)
			{
				if ( word["ID"].slice(0, 1) == "1" )
				{
					[word["ID"]] = word["ID"];   //idList.addItemAt(word["ID"], int(word));
				}				
			}
			
			var i:uint;
			for (i=0; i < words.length; i++)//нужна дилина поменьше
			{
				if( idList[attrID] )
				{
					idInt++;
					if(idInt<10)
					{
						attrID = startId+ "0" + idInt;
					}
					else
					{
						attrID = startId + idInt;
					}					
				}
			}
			return attrID;*/
			var idList:ArrayCollection = new ArrayCollection();
			
			for each(var word:Object in words)
			{
				if ( word["ID"].slice(0, 1) == startId )
				{
					idList.addItemAt(word["ID"], int(word));
				}				
			}
			
			var newWrd:Object = new Object();
			var nextInd:uint = int(idList[0])+1;
			newWrd["ID"] = nextInd.toString();
			for each(var localeName:Object in locales )
			{
				newWrd[localeName.data] = "";
			}
			//добавляет в конец списка
			words.addItem( newWrd );
			return "#Lang("+ nextInd + ")";
		}
	}
}