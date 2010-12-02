package net.vdombox.object_editor.model
{
	import mx.collections.ArrayCollection;
	

	public class Language
	{
		private static var instance : Language;
		private var _data : XML;
		private var languages:ArrayCollection = new ArrayCollection();
		private var _languagesList:String = "";
		
		
		public function Language()
		{
			if ( instance )
				throw new Error( "Singleton and can only be accessed through Soap.anyFunction()" );
		}
		
		
		public static function getInstance() : Language
		{
			if ( !instance )
				instance = new Language();
			
			return instance;
		}
		
		public function set dataProvider(xml:XML):void
		{
			_data =  xml.Languages[0];
			if (!_data) _data = new XML("<Languages/>");
			
			for each(var child:XML in _data.children())
			{	
				if (child.name() == "Language")
				{
					var langName:String = child[0].@Code;
					var lang:Object = {};
					lang["data"] = langName;
					lang["label"] = langName;
					
					languages.addItem(lang);
					
					_languagesList += langName + ",";
				}
			}
		}
		
		private var _curent:String = "en_US"; 
		public function set current(value:String):void
		{
			_curent = value;
		}
		
		public function getWord(value:String):String
		{
			var xmlLanguage:XML = _data.Language.(@Code == _curent)[0];
			var xmlWord : XML = xmlLanguage.Sentence.(@ID == value)[0];
			return xmlWord.toString();	
		}
		
		public function get languagesList():String
		{
			return _languagesList.substr(0, _languagesList.length - 2 );
		}
			
		public function getLanguageXML(value:String = "en_US"):XML
		{
			return _data.Language.(@Code == value)[0];
		}
	}
}