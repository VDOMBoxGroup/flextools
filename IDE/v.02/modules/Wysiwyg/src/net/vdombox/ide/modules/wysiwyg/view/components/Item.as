package net.vdombox.ide.modules.wysiwyg.view.components
{
	import com.zavoo.svg.SVGViewer;
	
	import flash.display.DisplayObjectContainer;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.controls.HTML;
	import mx.controls.Text;
	import mx.core.ClassFactory;
	import mx.core.IFactory;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	
	import net.vdombox.ide.common.vo.AttributeVO;
	import net.vdombox.ide.modules.wysiwyg.events.ItemEvent;
	import net.vdombox.ide.modules.wysiwyg.model.vo.ItemVO;
	import net.vdombox.ide.modules.wysiwyg.view.skins.ItemSkin;
	
	import spark.components.Group;
	import spark.components.IItemRenderer;
	import spark.components.Scroller;
	import spark.components.SkinnableDataContainer;
	import spark.layouts.BasicLayout;
	import spark.layouts.HorizontalLayout;
	import spark.layouts.VerticalLayout;

	public class Item extends SkinnableDataContainer implements IItemRenderer
	{
		public function Item()
		{
			super();

			itemRendererFunction = chooseItemRenderer;
			setStyle( "skinClass", ItemSkin );


//			addEventListener( MouseEvent.MOUSE_OVER, mouseOverHandler, true );
//			addEventListener( MouseEvent.MOUSE_OUT, mouseOutHandler );
			addEventListener( FlexEvent.CREATION_COMPLETE, creatiomCompleteHandler );

		}



		private const styleList : Array = [ [ "opacity", "backgroundAlpha" ], [ "backgroundcolor", "backgroundColor" ],
											  [ "backgroundimage", "backgroundImage" ], [ "backgroundrepeat", "backgroundRepeat" ],
											  [ "borderwidth", "borderThickness" ], [ "bordercolor", "borderColor" ], [ "color", "color" ],
											  [ "fontfamily", "fontFamily" ], [ "fontsize", "fontSize" ], [ "fontweight", "fontWeight" ],
											  [ "fontstyle", "fontStyle" ], [ "textdecoration", "textDecoration" ], [ "textalign", "textAlign" ],
											  [ "align", "horizontalAlign" ], [ "valign", "verticalAlign" ] ];

		[SkinPart( required="true" )]
		public var background : Group;
		
		[SkinPart(required="true" )]
		public var scroller: Scroller;

		private var _data : Object;
		private var _itemVO : ItemVO;
		
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

		public function get itemVO () : ItemVO
		{
			return _itemVO;
		}
		
		public function set itemVO ( value : ItemVO ) : void
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

			if ( _itemVO && _itemVO.children.length > 0 )
			{
				var childrenDataProvider : ArrayCollection = new ArrayCollection( _itemVO.children );
				childrenDataProvider.sort = new Sort();
				childrenDataProvider.sort.fields = [ new SortField( "zindex" ), new SortField( "hierarchy" ), new SortField( "order" ) ];
				childrenDataProvider.refresh();

				dataProvider = childrenDataProvider;
			}

			var contetntPart : XML;

			for each ( contetntPart in _itemVO.content )
			{
				switch ( contetntPart.name().toString() )
				{
					case "svg":
					{
						var svg : SVGViewer = new SVGViewer();
						var d : * = svg.setXML( contetntPart );
						background.addElement( svg );

						break
					}

					case "text":
					{
						var richText : Text = new Text();

						richText.x = contetntPart.@left;
						richText.y = contetntPart.@top;
						richText.width = contetntPart.@width;


						richText.text = contetntPart[ 0 ];

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

						var htmlText : String = "<html>" + "<head>" + "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />" +
							"</head>" + "<body style=\"margin : 0px;\" >" + contetntPart[ 0 ] + "</body>" + "</html>";

						html.htmlText = htmlText;

						background.addElement( html );
					}
				}
			}
		}

		public function chooseItemRenderer( itemVO : ItemVO ) : IFactory
		{
			var itemFactory : ClassFactory;

			switch ( itemVO.name )
			{
				case "container":
				{
					itemFactory = new ClassFactory( Item );
					itemFactory.properties = { layout: new BasicLayout() };
					break;
				}

				case "table":
				{
					itemFactory = new ClassFactory( Item );
					itemFactory.properties = { layout: new VerticalLayout() };
					break;
				}

				case "row":
				{
					itemFactory = new ClassFactory( Item );
					itemFactory.properties = { layout: new HorizontalLayout(), percentWidth: 100, percentHeight: 100 };
					break;
				}

				case "cell":
				{
					itemFactory = new ClassFactory( Item );
					itemFactory.properties = { layout: new BasicLayout(), percentWidth: 100, percentHeight: 100 };
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

//		private function mouseOutHandler( event : MouseEvent ) : void
//		{
//			skin.currentState = "normal";
//		}

//		private function mouseOverHandler( event : MouseEvent ) : void
//		{
//			var item : Item = getItemByTarget( event.target as DisplayObjectContainer );
//
//			if ( item == this )
//				skin.currentState = "hovered";
//			else
//				skin.currentState = "normal";
//		}

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
	}
}