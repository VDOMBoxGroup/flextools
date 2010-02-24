package net.vdombox.ide.modules.wysiwyg.view.components
{
	import com.zavoo.svg.SVGViewer;
	
	import mx.collections.ArrayList;
	import mx.controls.HTML;
	import mx.controls.Text;
	import mx.core.ClassFactory;
	import mx.core.IFactory;
	import mx.core.UIComponent;
	
	import net.vdombox.ide.common.vo.AttributeVO;
	import net.vdombox.ide.modules.wysiwyg.events.ItemEvent;
	import net.vdombox.ide.modules.wysiwyg.model.vo.ItemVO;
	import net.vdombox.ide.modules.wysiwyg.view.skins.ItemSkin;
	
	import spark.components.Group;
	import spark.components.IItemRenderer;
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
			
			dispatchEvent( new ItemEvent( ItemEvent.CREATED ) );
		}
		
		private const styleList : Array = 
			[
				["opacity", "backgroundAlpha"],
				["backgroundcolor", "backgroundColor"],
				["backgroundimage", "backgroundImage"],
				["backgroundrepeat", "backgroundRepeat"],
				["borderwidth", "borderThickness"],
				["bordercolor", "borderColor"],
				["color", "color"],
				["fontfamily", "fontFamily"],
				["fontsize", "fontSize"],
				["fontweight", "fontWeight"],
				["fontstyle", "fontStyle"],
				["textdecoration", "textDecoration"],
				["textalign", "textAlign"],
				["align", "horizontalAlign"],
				["valign", "verticalAlign"]
			];
		
		[SkinPart(required="true")]
		public var background : Group;
		
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

		public function get data() : Object
		{
			return null;
		}

		public function set data( value : Object ) : void
		{
			var itemVO : ItemVO = value as ItemVO;

			if ( !itemVO )
				return;

			var attributeVO : AttributeVO = itemVO.getAttributeByName( "width" );

			if ( attributeVO )
				width = int( attributeVO.value );

			attributeVO = itemVO.getAttributeByName( "height" );

			if ( attributeVO )
				height = int( attributeVO.value );

			attributeVO = itemVO.getAttributeByName( "top" );

			if ( attributeVO )
				y = int( attributeVO.value );

			attributeVO = itemVO.getAttributeByName( "left" );

			if ( attributeVO )
				x = int( attributeVO.value );

			if ( itemVO && itemVO.children.length > 0 )
			{
				dataProvider = new ArrayList( itemVO.children );
			}
			
			var contetntPart : XML;
			
			for each( contetntPart in itemVO.content )
			{
				switch( contetntPart.name().toString() )
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
					case "htmltext" : 
					{
						var html : HTML = new HTML();
						
						html.x = contetntPart.@left;
						html.y = contetntPart.@top;
						html.width = contetntPart.@width;
						
						var htmlText  : String =
							"<html>" + 
							"<head>" + 
							"<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />" +
							"</head>" +
							"<body style=\"margin : 0px;\" >" +
							contetntPart[ 0 ] +
							"</body>" + 
							"</html>";
						
						html.htmlText = htmlText;
						
						background.addElement( html );
					}
				}
			}
		}

		public function chooseItemRenderer( itemVO : ItemVO ) : IFactory
		{
			var itemFactory : ClassFactory;

			switch ( itemVO.type )
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
					itemFactory.properties = { layout: new HorizontalLayout(), percentWidth : 100, percentHeight : 100 };
					break;
				}

				case "cell":
				{
					itemFactory = new ClassFactory( Item );
					itemFactory.properties = { layout: new BasicLayout(), percentWidth : 100, percentHeight : 100 };
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
	}
}