package net.vdombox.ide.modules.wysiwyg.view.components
{
	import com.zavoo.svg.SVGViewer;
	
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.controls.HTML;
	import mx.controls.Text;
	import mx.core.ClassFactory;
	import mx.core.IFactory;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.graphics.SolidColor;
	import mx.graphics.SolidColorStroke;
	
	import net.vdombox.ide.common.vo.AttributeVO;
	import net.vdombox.ide.modules.wysiwyg.events.ItemEvent;
	import net.vdombox.ide.modules.wysiwyg.model.vo.ItemVO;
	
	import spark.components.Group;
	import spark.components.IItemRenderer;
	import spark.components.RichEditableText;
	import spark.components.Scroller;
	import spark.components.SkinnableDataContainer;
	import spark.layouts.BasicLayout;
	import spark.layouts.HorizontalLayout;
	import spark.layouts.VerticalLayout;
	import spark.layouts.supportClasses.LayoutBase;
	import spark.primitives.Rect;

	public class Item extends SkinnableDataContainer implements IItemRenderer
	{
		public function Item()
		{
			super();

			itemRendererFunction = chooseItemRenderer;
//			setStyle( "skinClass", ItemSkin );

			addEventListener( FlexEvent.CREATION_COMPLETE, creatiomCompleteHandler );
			addEventListener( Event.REMOVED, removeHandler );

		}

		private const styleList : Array = [ [ "opacity", "backgroundAlpha" ], [ "backgroundcolor", "backgroundColor" ],
											[ "backgroundimage", "backgroundImage" ], [ "backgroundrepeat",
																						"backgroundRepeat" ],
											[ "borderwidth", "borderThickness" ], [ "bordercolor", "borderColor" ],
											[ "color", "color" ], [ "fontfamily", "fontFamily" ], [ "fontsize",
																									"fontSize" ],
											[ "fontweight", "fontWeight" ], [ "fontstyle", "fontStyle" ],
											[ "textdecoration", "textDecoration" ], [ "textalign", "textAlign" ],
											[ "align", "horizontalAlign" ], [ "valign", "verticalAlign" ] ];

		[SkinPart( required="true" )]
		public var background : Group;

		[SkinPart( required="true" )]
		public var scroller : Scroller;

		[SkinPart( required="true" )]
		public var locker : Group;

		[SkinPart( required="false" )]
		public var backgroundRect : Rect;

		public var editableComponent : Object;

		private var _data : Object;

		private var _itemVO : ItemVO;

		private var _isLocked : Boolean;


		public function get selected() : Boolean
		{
			return false;
		}

		public function set selected( value : Boolean ) : void
		{
		}

		public function get showsCaret() : Boolean
		{
			return false;
		}

		public function set showsCaret( value : Boolean ) : void
		{
		}

		public function get label() : String
		{
			return null;
		}

		public function set label( value : String ) : void
		{
		}

		public function get itemVO() : ItemVO
		{
			return _itemVO;
		}

		public function set itemVO( value : ItemVO ) : void
		{
			_itemVO = value;
		}

		public function get data() : Object
		{
			return _data;
		}

		public function set data( value : Object ) : void
		{
			_data = value;
			_itemVO = value as ItemVO;

			if ( !_itemVO )
				return;

			var attributeVO : AttributeVO = _itemVO.getAttributeByName( "width" );

			if ( attributeVO )
				width = int( attributeVO.value );

			attributeVO = _itemVO.getAttributeByName( "height" );

			if ( attributeVO )
				height = int( attributeVO.value );

			attributeVO = _itemVO.getAttributeByName( "top" );

			if ( attributeVO )
				y = int( attributeVO.value );

			attributeVO = _itemVO.getAttributeByName( "left" );

			if ( attributeVO )
				x = int( attributeVO.value );

			attributeVO = _itemVO.getAttributeByName( "backgroundcolor" );

			if ( attributeVO )
			{
				SolidColor( backgroundRect.fill ).alpha = 1;
				SolidColor( backgroundRect.fill ).color = uint( "0x" + attributeVO.value.substr( 1 ) );
			}

			attributeVO = _itemVO.getAttributeByName( "bordercolor" );

			if ( attributeVO )
			{
				SolidColorStroke( backgroundRect.stroke ).alpha = 1;
				SolidColorStroke( backgroundRect.stroke ).color = uint( "0x" + attributeVO.value.substr( 1 ) );
				attributeVO = _itemVO.getAttributeByName( "borderwidth" );
				if ( attributeVO )
					SolidColorStroke( backgroundRect.stroke ).weight = uint( attributeVO.value );
			}

			if ( _itemVO.staticFlag )
				locker.visible = true;

			if ( _itemVO && _itemVO.children.length > 0 )
			{
				var childrenDataProvider : ArrayCollection = new ArrayCollection( _itemVO.children );
				childrenDataProvider.sort = new Sort();
				childrenDataProvider.sort.fields = [ new SortField( "zindex" ), new SortField( "hierarchy" ),
													 new SortField( "order" ) ];
				childrenDataProvider.refresh();

				dataProvider = childrenDataProvider;
			}

			var contetntPart : XML;

			background.removeAllElements();

			for each ( contetntPart in _itemVO.content )
			{
				switch ( contetntPart.name().toString() )
				{
					case "svg":
					{
						var svg : SVGViewer = new SVGViewer();
						var editableAttributes : Array = svg.setXML( contetntPart );

						if ( editableAttributes.length > 0 )
						{
							editableComponent = editableAttributes[ 0 ].sourceObject;
						}

						background.addElement( svg );

						break
					}

					case "text":
					{
						var richText : UIComponent

						if ( contetntPart.@editable )
						{
							richText = new RichEditableText();
							editableComponent = richText;
						}
						else
						{
							richText = new Text();
						}

						richText.x = contetntPart.@left;
						richText.y = contetntPart.@top;
						richText.width = contetntPart.@width;



						richText[ "text" ] = contetntPart[ 0 ];

						applyStyles( richText, contetntPart );

						background.addElement( richText );

						break;
					}
					case "htmltext":
					{
						var html : HTML = new HTML();

						html.x = contetntPart.@left;
						html.y = contetntPart.@top;
						html.width = contetntPart.@width;

						if ( contetntPart.@editable )
							editableComponent = html;

						var htmlText : String = "<html>" + "<head>" + "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />" + "</head>" + "<body style=\"margin : 0px;\" >" + contetntPart[ 0 ] + "</body>" + "</html>";

						html.htmlText = htmlText;

						background.addElement( html );
					}
				}
			}

			skin.currentState = "normal";
		}

		public function get isLocked() : Boolean
		{
			return _isLocked;
		}

		public function set isLocked( value : Boolean ) : void
		{
			_isLocked = value;
		}

		public function lock() : void
		{
			isLocked = true;

			skin.currentState = "locked";
			background.removeAllElements();
		}

		public function chooseItemRenderer( itemVO : ItemVO ) : IFactory
		{
			var itemFactory : ClassFactory;
			var layout : LayoutBase;
			switch ( itemVO.name )
			{
				case "container":
				{
					itemFactory = new ClassFactory( Item );
					layout = new BasicLayout();
					layout.clipAndEnableScrolling = true;
					itemFactory.properties = { layout: layout };
					break;
				}

				case "table":
				{
					itemFactory = new ClassFactory( Item );
					layout = new VerticalLayout();
					layout.clipAndEnableScrolling = true;
					VerticalLayout( layout ).gap = 0;
					itemFactory.properties = { layout: layout };
					break;
				}

				case "row":
				{
					itemFactory = new ClassFactory( Item );
					layout = new HorizontalLayout();
					layout.clipAndEnableScrolling = true;
					HorizontalLayout( layout ).gap = 0;
					itemFactory.properties = { layout: layout, percentWidth: 100, percentHeight: 100 };

					break;
				}

				case "cell":
				{
					itemFactory = new ClassFactory( Item );
					layout = new BasicLayout();
					layout.clipAndEnableScrolling = true;
					itemFactory.properties = { layout: layout, percentWidth: 100, percentHeight: 100 };
					break;
				}
			}

			return itemFactory;
		}

		private function applyStyles( item : UIComponent, itemXMLDescription : XML ) : void
		{
			var _style : Object = {};
			var hasStyle : Boolean = false;

			item.styleName = "WYSIWYGItem";


			var xmlList : XMLList;
			for each ( var attribute : Array in styleList )
			{
				xmlList = itemXMLDescription.attribute( attribute[ 0 ] );
				if ( xmlList.length() > 0 )
				{
					_style[ attribute[ 1 ] ] = xmlList[ 0 ].toString().toLowerCase();
					hasStyle = true;
				}
			}

			if ( !hasStyle )
				return;

			if ( _style.hasOwnProperty( "backgroundColor" ) && !_style.hasOwnProperty( "backgroundAlpha" ) )
				_style[ "backgroundAlpha" ] = 100;

			if ( _style.hasOwnProperty( "borderColor" ) )
				_style[ "borderStyle" ] = "solid";

			if ( _style.hasOwnProperty( "textDecoration" ) )
				if ( !( _style[ "textDecoration" ] != "none" || _style[ "textDecoration" ] != "underline" ) )
					_style[ "textDecoration" ] = "none";
		}

		private function getItemByTarget( target : DisplayObjectContainer ) : Item
		{
			var result : Item;
			var item : DisplayObjectContainer = target;

			while ( item && item.parent )
			{
				if ( item is Item )
				{
					result = item as Item;
					break;
				}

				item = item.parent;
			}

			return result;
		}

		private function creatiomCompleteHandler( event : FlexEvent ) : void
		{
			dispatchEvent( new ItemEvent( ItemEvent.CREATED ) );
		}

		private function removeHandler( event : Event ) : void
		{
			if ( event.target == this )
				dispatchEvent( new ItemEvent( ItemEvent.REMOVED ) );
		}
	}
}