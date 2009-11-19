package net.vdombox.ide.core.model
{
	import flash.net.SharedObject;
	
	import mx.resources.IResourceManager;
	import mx.resources.ResourceBundle;
	import mx.resources.ResourceManager;
	
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;

	public class LocaleProxy extends Proxy implements IProxy
	{
		public static const NAME : String = "LocaleProxy";

		private static const LOCALES : XML =
			<root>
				<Language code="en_US" label="English"/>
				<Language code="ru_RU" label="Русский"/>
				<Language code="fr_FR" label="French"/>
			</root>


		public function LocaleProxy( data : Object = null )
		{
			super( NAME, data );
			init();
		}

		private var sharedObject : SharedObject = SharedObject.getLocal( "userData" );
		private var resourceManager : IResourceManager = ResourceManager.getInstance();

		private var _languageList : XMLList;

		private var allLocales : Array;
		private var defaultLocale : String;
		private var _currentLocale : String;

		public function get languageList() : XMLList
		{
			return _languageList;
		}

		public function get currentLocale() : String
		{
			return _currentLocale;
		}

		public function changeLocale( locale : String ) : void
		{
			if ( _currentLocale != locale && allLocales.indexOf( locale ) != -1 )
			{
				if ( locale == defaultLocale )
					resourceManager.localeChain = [ defaultLocale ];
				else
					resourceManager.localeChain = [ locale, defaultLocale ];
				
				sharedObject.data.locale = _currentLocale = locale;
			}

		}

		public function parseLanguageData( languageData : XMLList ) : void
		{
			var resourceBundles : Object = {};

			var localeIndex : Number = -1;
			var languageCode : String = ""
			var currentBundle : ResourceBundle;

			var typeName : String = "";
			var resourceName : String = "";
			var content : String = "";
			for each ( var sentence : XML in languageData.Languages.Language.Sentence )
			{

				languageCode = sentence.parent().@Code;
				localeIndex = allLocales.indexOf( languageCode );

				if ( localeIndex == -1 )
					break;

				typeName = sentence.parent().parent().parent().Information.Name.toString();

				if ( !resourceBundles[ languageCode ] )
					resourceBundles[ languageCode ] = [];

				if ( !resourceBundles[ languageCode ][ typeName ] )
					resourceBundles[ languageCode ][ typeName ] = new ResourceBundle( languageCode,
																					  typeName );

				currentBundle = resourceBundles[ languageCode ][ typeName ];

				resourceName = sentence.@ID.toString();
				content = sentence.toString();

				currentBundle.content[ resourceName ] = content;

				resourceManager.addResourceBundle( currentBundle );
			}

			resourceManager.update();
		}

		private function init() : void
		{
			_languageList = LOCALES.*;

			allLocales = [];

			var lastLocale : String = sharedObject.data.locale as String;
			var code : String;

			for each ( var node : XML in _languageList )
			{
				code = node.@code.toString();
				allLocales.push( code );

				if ( code && code == lastLocale )
					_currentLocale = code;
			}

			defaultLocale = allLocales[ 0 ];

			if ( _currentLocale && defaultLocale != _currentLocale )
				resourceManager.localeChain = [ _currentLocale, defaultLocale ];
			else
				resourceManager.localeChain = [ defaultLocale ];
		}
	}
}