package net.vdombox.ide.modules.wysiwyg.view.components
{
	import com.zavoo.svg.SVGViewer;
	
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.controls.HTML;
	import mx.controls.Text;
	import mx.core.ClassFactory;
	import mx.core.IFactory;
	import mx.core.UIComponent;
	import mx.events.DragEvent;
	import mx.events.FlexEvent;
	import mx.graphics.SolidColor;
	import mx.graphics.SolidColorStroke;
	
	import net.vdombox.ide.common.interfaces.IVDOMObjectVO;
	import net.vdombox.ide.common.vo.AttributeVO;
	import net.vdombox.ide.common.vo.TypeVO;
	import net.vdombox.ide.modules.wysiwyg.events.RendererDropEvent;
	import net.vdombox.ide.modules.wysiwyg.events.RendererEvent;
	import net.vdombox.ide.modules.wysiwyg.interfaces.IRenderer;
	import net.vdombox.ide.modules.wysiwyg.model.business.VdomDragManager;
	import net.vdombox.ide.modules.wysiwyg.model.vo.RenderVO;
	import net.vdombox.ide.modules.wysiwyg.view.skins.ObjectRendererSkin;
	
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

	public class ObjectRenderer extends SkinnableDataContainer implements IItemRenderer, IRenderer
	{
		public function ObjectRenderer()
		{
			super();

			itemRendererFunction = chooseItemRenderer;

			addHandlers();
		}

		private const styleList : Array = [ [ "opacity", "backgroundAlpha" ], [ "backgroundcolor", "backgroundColor" ],
			[ "backgroundimage", "backgroundImage" ], [ "backgroundrepeat", "backgroundRepeat" ],
			[ "borderwidth", "borderThickness" ], [ "bordercolor", "borderColor" ], [ "color", "color" ],
			[ "fontfamily", "fontFamily" ], [ "fontsize", "fontSize" ], [ "fontweight", "fontWeight" ],
			[ "fontstyle", "fontStyle" ], [ "textdecoration", "textDecoration" ], [ "textalign", "textAlign" ],
			[ "align", "horizontalAlign" ], [ "valign", "verticalAlign" ] ];

		[SkinPart( required="true" )]
		public var background : Group;

		[SkinPart( required="true" )]
		public var scroller : Scroller;

		[SkinPart( required="true" )]
		public var locker : Group;

		[SkinPart( required="false" )]
		public var backgroundRect : Rect;

		private var _editableComponent : Object;

		private var _data : Object;

		private var _renderVO : RenderVO;

		private var _isLocked : Boolean;


		public function get itemIndex() : int
		{
			return 0;
		}

		public function set itemIndex( value : int ) : void
		{
		}

		public function get dragging() : Boolean
		{
			return false;
		}

		public function set dragging( value : Boolean ) : void
		{
		}

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

		public function get renderVO() : RenderVO
		{
			return _renderVO;
		}

		public function set renderVO( value : RenderVO ) : void
		{
			_renderVO = value;
			
			refresh();
		}

		public function get vdomObjectVO() : IVDOMObjectVO
		{
			return _renderVO ? _renderVO.vdomObjectVO : null;
		}
		
		public function get typeVO() : TypeVO
		{
			return _renderVO ? _renderVO.vdomObjectVO.typeVO : null;
		}
		
		public function get resizable() : uint
		{
			return typeVO ? uint( typeVO.resizable ) : 0;
		}
		
		public function get movable() : Boolean
		{
			var result : Boolean = false;
			
			if( typeVO )
			{
				if( typeVO.moveable == "0" )
					result = false;
				else if( typeVO.moveable == "1" )
					result = true;
			}
			
			return result;
		}
		
		public function get data() : Object
		{
			return _data;
		}

		public function set data( value : Object ) : void
		{
			_data = value;
			_renderVO = value as RenderVO;
			
			refresh();
		}

		public function get isLocked() : Boolean
		{
			return _isLocked;
		}

		public function set isLocked( value : Boolean ) : void
		{
			_isLocked = value;
		}

		public function get editableComponent() : Object
		{
			return _editableComponent;
		}
		
		public function lock() : void
		{
			isLocked = true;

			skin.currentState = "locked";
			background.removeAllElements();
		}

		public function chooseItemRenderer( renderVO : RenderVO ) : IFactory
		{
			var itemFactory : ClassFactory;
			var layout : LayoutBase;
			switch ( renderVO.name )
			{
				case "container":
				{
					itemFactory = new ClassFactory( ObjectRenderer );
					layout = new BasicLayout();
					layout.clipAndEnableScrolling = true;
					itemFactory.properties = { layout: layout };
					break;
				}

				case "table":
				{
					itemFactory = new ClassFactory( ObjectRenderer );
					layout = new VerticalLayout();
					layout.clipAndEnableScrolling = true;
					VerticalLayout( layout ).gap = 0;
					itemFactory.properties = { layout: layout };
					break;
				}

				case "row":
				{
					itemFactory = new ClassFactory( ObjectRenderer );
					layout = new HorizontalLayout();
					layout.clipAndEnableScrolling = true;
					HorizontalLayout( layout ).gap = 0;
					itemFactory.properties = { layout: layout, percentWidth: 100, percentHeight: 100 };

					break;
				}

				case "cell":
				{
					itemFactory = new ClassFactory( ObjectRenderer );
					layout = new BasicLayout();
					layout.clipAndEnableScrolling = true;
					itemFactory.properties = { layout: layout, percentWidth: 100, percentHeight: 100 };
					break;
				}
			}

			return itemFactory;
		}

		private function addHandlers() : void
		{
			addEventListener( FlexEvent.CREATION_COMPLETE, creationCompleteHandler, false, 0, true );
			addEventListener( Event.REMOVED, removeHandler, false, 0, true );

			addEventListener( MouseEvent.MOUSE_OVER, mouseOverHandler, false, 0, true );
			addEventListener( MouseEvent.MOUSE_OUT, mouseOutHandler, false, 0, true );
			addEventListener( MouseEvent.CLICK, mouseClickHandler, false, 0, true );

			addEventListener( DragEvent.DRAG_ENTER, dragEnterHandler, false, 0, true );
			addEventListener( DragEvent.DRAG_EXIT, dragExitHandler, false, 0, true );
			addEventListener( DragEvent.DRAG_DROP, dragDropHandler, false, 0, true );
		}

		private function removeHandlers() : void
		{
			removeEventListener( FlexEvent.CREATION_COMPLETE, creationCompleteHandler );
			removeEventListener( Event.REMOVED, removeHandler );

			removeEventListener( MouseEvent.MOUSE_OVER, mouseOverHandler );
			removeEventListener( MouseEvent.MOUSE_OUT, mouseOutHandler );
			removeEventListener( MouseEvent.CLICK, mouseClickHandler );

			removeEventListener( DragEvent.DRAG_ENTER, dragEnterHandler );
			removeEventListener( DragEvent.DRAG_EXIT, dragExitHandler );
			removeEventListener( DragEvent.DRAG_DROP, dragDropHandler );
		}

		private function refresh() : void
		{
			if ( !_renderVO )
				return;
			
			var attributeVO : AttributeVO = _renderVO.getAttributeByName( "width" );
			
			if ( attributeVO )
				width = int( attributeVO.value );
			
			attributeVO = _renderVO.getAttributeByName( "height" );
			
			if ( attributeVO )
				height = int( attributeVO.value );
			
			attributeVO = _renderVO.getAttributeByName( "top" );
			
			if ( attributeVO )
				y = int( attributeVO.value );
			
			attributeVO = _renderVO.getAttributeByName( "left" );
			
			if ( attributeVO )
				x = int( attributeVO.value );
			
			attributeVO = _renderVO.getAttributeByName( "backgroundcolor" );
			
			if ( attributeVO )
			{
				SolidColor( backgroundRect.fill ).alpha = 1;
				SolidColor( backgroundRect.fill ).color = uint( "0x" + attributeVO.value.substr( 1 ) );
			}
			
			attributeVO = _renderVO.getAttributeByName( "bordercolor" );
			
			if ( attributeVO )
			{
				SolidColorStroke( backgroundRect.stroke ).alpha = 1;
				SolidColorStroke( backgroundRect.stroke ).color = uint( "0x" + attributeVO.value.substr( 1 ) );
				attributeVO = _renderVO.getAttributeByName( "borderwidth" );
				if ( attributeVO )
					SolidColorStroke( backgroundRect.stroke ).weight = uint( attributeVO.value );
			}
			
			if ( _renderVO.staticFlag )
				locker.visible = true;
			
			if ( _renderVO && _renderVO.children && _renderVO.children.length > 0 )
			{
				var childrenDataProvider : ArrayCollection = new ArrayCollection( _renderVO.children );
				childrenDataProvider.sort = new Sort();
				childrenDataProvider.sort.fields = [ new SortField( "zindex" ), new SortField( "hierarchy" ), new SortField( "order" ) ];
				childrenDataProvider.refresh();
				
				dataProvider = childrenDataProvider;
			}
			else
			{
				dataProvider = null;
			}
			
			var contetntPart : XML;
			
			background.removeAllElements();
			
			for each ( contetntPart in _renderVO.content )
			{
				switch ( contetntPart.name().toString() )
				{
					case "svg":
					{
						var svg : SVGViewer = new SVGViewer();
						var editableAttributes : Array = svg.setXML( contetntPart );
						
						if ( editableAttributes.length > 0 )
						{
							_editableComponent = editableAttributes[ 0 ].sourceObject;
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
							_editableComponent = richText;
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
							_editableComponent = html;
						
						var htmlText : String = "<html>" + "<head>" + "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />" +
							"</head>" + "<body style=\"margin : 0px;\" >" + contetntPart[ 0 ] + "</body>" + "</html>";
						
						html.htmlText = htmlText;
						
						background.addElement( html );
					}
				}
			}
			
			skin.currentState = "normal";
		}
		
		private function applyStyles( item : UIComponent, itemXMLDescription : XML ) : void
		{
			var _style : Object = {};
			var hasStyle : Boolean = false;

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

			var styleName : String;

			for ( styleName in _style )
			{
				if ( styleName == "color" || styleName == "backgroundColor" || styleName == "borderColor" )
					_style[ styleName ] = uint( "0x" + String( _style[ styleName ] ).substr( 1 ) );

				item.setStyle( styleName, _style[ styleName ] );
			}
		}

		private function getItemByTarget( target : DisplayObjectContainer ) : ObjectRenderer
		{
			var result : ObjectRenderer;
			var item : DisplayObjectContainer = target;

			while ( item && item.parent )
			{
				if ( item is ObjectRenderer )
				{
					result = item as ObjectRenderer;
					break;
				}

				item = item.parent;
			}

			return result;
		}

		private function creationCompleteHandler( event : FlexEvent ) : void
		{
			dispatchEvent( new RendererEvent( RendererEvent.CREATED ) );
		}

		private function dragEnterHandler( event : DragEvent ) : void
		{
			var typeDescription : Object = event.dragSource.dataForFormat( "typeDescription" );

			if ( !typeDescription )
				return;

			var containersRE : RegExp = /(\w+)/g;
			var aviableContainers : Array = typeDescription.aviableContainers.match( containersRE );
			var currentItemName : String;
			if ( _renderVO )
				currentItemName = _renderVO.vdomObjectVO.typeVO.name;

			if ( aviableContainers.indexOf( currentItemName ) != -1 )
			{
				var vdomDragManager : VdomDragManager = VdomDragManager.getInstance();
				vdomDragManager.acceptDragDrop( UIComponent( this ) );
				skin.currentState = "highlighted";
			}
		}

		private function mouseOutHandler( event : MouseEvent ) : void
		{
			if ( skin.currentState == "hovered" )
				skin.currentState = "normal";
		}

		private function mouseOverHandler( event : MouseEvent ) : void
		{
			if ( skin.currentState == "highlighted" )
				return;

			if ( findNearestItem( event.target as DisplayObjectContainer ) == this )
				skin.currentState = "hovered";
			else
				skin.currentState = "normal";
		}

		private function mouseClickHandler( event : MouseEvent ) : void
		{
			event.stopPropagation();
			dispatchEvent( new RendererEvent( RendererEvent.CLICKED ) );
		}

		private function dragDropHandler( event : DragEvent ) : void
		{
			skin.currentState = "normal";
			
			var rde : RendererDropEvent = new RendererDropEvent( RendererDropEvent.DROP );
			
			var typeVO : TypeVO = TypeItemRenderer( event.dragInitiator ).typeVO;
			
			var objectLeft : Number = this.mouseX - 25 + this.layout.horizontalScrollPosition;
			var objectTop : Number = this.mouseY - 25 + this.layout.verticalScrollPosition;
			
			var point : Point = new Point( objectLeft, objectTop );
			
			rde.typeVO = typeVO;
			rde.point = point;
			
			dispatchEvent( rde );
		}

		private function dragExitHandler( event : DragEvent ) : void
		{
			skin.currentState = "normal";
		}

		private function removeHandler( event : Event ) : void
		{
			if ( event.target == this )
			{
				dispatchEvent( new RendererEvent( RendererEvent.REMOVED ) );
				removeHandlers();
			}
		}

		private function findNearestItem( currentElement : DisplayObjectContainer ) : ObjectRenderer
		{
			var result : ObjectRenderer;

			while ( currentElement && currentElement.parent )
			{
				if ( currentElement is ObjectRenderer )
				{
					result = currentElement as ObjectRenderer;
					break;
				}

				currentElement = currentElement.parent;
			}

			return result;
		}
	}
}