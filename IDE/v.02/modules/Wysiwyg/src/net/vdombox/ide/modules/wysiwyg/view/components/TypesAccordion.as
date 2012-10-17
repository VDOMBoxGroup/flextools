package net.vdombox.ide.modules.wysiwyg.view.components
{
	import mx.collections.ArrayCollection;
	import mx.collections.IViewCursor;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.containers.Accordion;
	
	import spark.components.NavigatorContent;

	public class TypesAccordion extends Accordion
	{
		private const STANDART_CATEGORIES : Array = [ "usual", "standard", "form", "table", "database",
													  "debug" ];

		private const USUAL_ELEMENTS : Array = [ "button", "copy", "image", "richtext" ];

		private var fileManager : FileManager = FileManager.getInstance();

		private var _dataProvider : XMLList;

		private var categories : Object = {};

		private var types : ArrayCollection;

		private var phraseRE : RegExp = /#lang\((\w+)\)/;

		private var resourceRE : RegExp = /#Res\((.*)\)/;

		private var currentLocale : String;

		public function TypesAccordion()
		{
			super();
		}

		public function set dataProvider( value : XMLList ) : void
		{
			if ( !value )
				return;

			var newLocale : String = resourceManager.localeChain[ 0 ];

			if ( currentLocale == newLocale && _dataProvider == value )
				return;

			currentLocale = newLocale;
			_dataProvider = value;

			categories = {};
			removeAllChildren();

			types = new ArrayCollection();
			types = createTypeDescriptions( value );

			createStandartCategories();

			var currentDescription : Object, currentCategory : Object, type : Type;
			var cursor : IViewCursor = types.createCursor();

			while ( !cursor.afterLast )
			{
				currentDescription = cursor.current;

				currentCategory = insertCategory( currentDescription.categoryName, currentDescription.categoryNameLocalized );

				type = new Type();
				type.typeDescription = currentDescription;

				type.setStyle( "horizontalAlign", "center" );
				type.width = 90;
				type.typeLabel = currentDescription.typeNameLocalized;

				currentCategory.addChild( type );

				fileManager.loadResource( currentDescription.typeId, currentDescription.resourceId, type, "resource", true );
				cursor.moveNext();
			}

			if ( !categories[ "usual" ] )
				return;

			currentCategory = categories[ "usual" ];

			for each ( var usualElement : String in USUAL_ELEMENTS )
			{
				var result : Boolean = cursor.findFirst( { typeName: usualElement } );

				if ( result )
				{
					currentDescription = cursor.current;

					type = new Type();
					type.typeDescription = currentDescription;

					type.setStyle( "horizontalAlign", "center" );
					type.width = 90;
					type.typeLabel = currentDescription.typeNameLocalized;

					currentCategory.addChild( type );

					fileManager.loadResource( currentDescription.typeId, currentDescription.resourceId, type, "resource", true );
				}
			}
		}

		private function createTypeDescriptions( value : XMLList ) : ArrayCollection
		{
			var typesArrayCollection : ArrayCollection = new ArrayCollection();
			var categoryName : String, categoryNameLocalized : String, categoryPhraseId : String;
			var typeId : String, typeName : String, typeNameLocalized : String;
			var displayName : String, phraseId : String, resourceId : String, aviableContainers : String;

			for each ( var typeDescription : XML in value )
			{

				if ( typeDescription.Information.Container == '3' )
					continue;

				categoryName = typeDescription.Information.Category.toLowerCase();
				categoryNameLocalized = "";

				if ( STANDART_CATEGORIES.indexOf( categoryName ) != -1 )
					categoryNameLocalized = resourceManager.getString( "Edit", categoryName );

				else if ( categoryName.match( phraseRE ) )
				{

					categoryPhraseId = categoryName.match( phraseRE )[ 1 ];
					categoryNameLocalized = resourceManager.getString( typeDescription.Information.Name, categoryPhraseId );

					if ( categoryNameLocalized )
						categoryName = "lang_" + MD5Utils.encrypt( categoryNameLocalized );
				}

				if ( !categoryNameLocalized )
					continue;

				typeId = typeDescription.Information.ID;
				displayName = typeDescription.Information.DisplayName.toLowerCase();

				phraseId = displayName.match( phraseRE )[ 1 ];
				resourceId = typeDescription.Information.Icon.match( resourceRE )[ 1 ];

				typeName = typeDescription.Information.Name;
				typeNameLocalized = resourceManager.getString( typeName, phraseId );

				aviableContainers = typeDescription.Information.Containers;

				typesArrayCollection.addItem( { categoryName: categoryName, categoryNameLocalized: categoryNameLocalized,
												  typeName: typeName, typeNameLocalized: typeNameLocalized,
												  typeId: typeId, resourceId: resourceId, aviableContainers: aviableContainers } );
			}

			typesArrayCollection.sort = new Sort();
			typesArrayCollection.sort.fields = [ new SortField( "typeName" ) ];
			typesArrayCollection.refresh();

			return typesArrayCollection;
		}

		private function createStandartCategories() : void
		{
			var labelValue : String;

			for each ( var category : String in STANDART_CATEGORIES )
			{

				labelValue = resourceManager.getString( "Edit", category );
				insertCategory( category, labelValue );
			}
		}

		private function insertCategory( categoryName : String, label : String ) : NavigatorContent
		{
			var currentCategory : Types;

			if ( !categories[ categoryName ] )
			{

				currentCategory = new Types();

				categories[ categoryName ] = currentCategory;

				currentCategory.label = label;
				currentCategory.setStyle( "horizontalAlign", "center" );
				currentCategory.horizontalScrollPolicy = "off";
				currentCategory.percentWidth = 100;

				addChild( currentCategory );
			}
			else
			{

				currentCategory = categories[ categoryName ];
			}

			return currentCategory;
		}
	}
}
