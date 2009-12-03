package net.vdombox.ide.core.model
{
	import mx.resources.IResourceManager;
	import mx.resources.ResourceManager;
	
	import net.vdombox.ide.core.model.vo.LocaleVO;
	
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;

	public class LocalesProxy extends Proxy implements IProxy
	{
		public static const NAME : String = "LocaleProxy";

		private static const LOCALES : XML =
			<locales>
				<locale code="en_US" description="English"/>
				<locale code="ru_RU" description="Русский"/>
				<locale code="fr_FR" description="French"/>
			</locales>


		public function LocalesProxy( data : Object = null )
		{
			super( NAME, data );
		}

		private var sharedObjectProxy : SharedObjectProxy;
		private var resourceManager : IResourceManager = ResourceManager.getInstance();

		private var _locales : Array;

//		private var allLocales : Array;
		private var _defaultLocale : LocaleVO;
		private var _currentLocale : LocaleVO;
		
		public function get locales() : Array
		{
			return _locales.slice();
		}

		public function get currentLocale() : LocaleVO
		{
			return _currentLocale;
		}
		
		public function get defaultLocale() : LocaleVO
		{
			return _defaultLocale;
		}
		
		override public function onRegister() : void
		{
			sharedObjectProxy = facade.retrieveProxy( SharedObjectProxy.NAME ) as SharedObjectProxy;
			
			_locales = [];
			
			var lastLocaleCode : String = sharedObjectProxy.localeCode as String;
			
			
			var localeVO : LocaleVO;
			var code : String;
			var description : String;
			
			for each ( var node : XML in LOCALES.* )
			{
				code = node.@code.toString();
				description = node.@description.toString();
				
				localeVO = new LocaleVO( code, description );
				_locales.push( localeVO );
				
				if ( code == lastLocaleCode )
					_currentLocale = localeVO;
			}
			
			if( locales.length == 0 )
				return;
			
			_defaultLocale = locales[ 0 ];
			
			if ( !_currentLocale )
				_currentLocale = _defaultLocale;
			
			if ( _defaultLocale !== _currentLocale )
				resourceManager.localeChain = [ _currentLocale.code, _defaultLocale.code ];
			else
				resourceManager.localeChain = [ _defaultLocale.code ];
		}
		
		public function changeLocale( localeVO : LocaleVO ) : void
		{
			if ( _currentLocale !== localeVO && 
				 locales.indexOf( localeVO ) != -1 )
			{
				if ( localeVO === defaultLocale )
					resourceManager.localeChain = [ defaultLocale.code ];
				else
					resourceManager.localeChain = [ localeVO.code, defaultLocale.code ];
				
				_currentLocale = localeVO;
				sharedObjectProxy.localeCode = localeVO.code;
			}

		}

		/*public function parseLanguageData( languageData : XMLList ) : void
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
		}*/
	}
}