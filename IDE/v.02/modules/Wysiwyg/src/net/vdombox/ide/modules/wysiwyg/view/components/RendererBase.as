//------------------------------------------------------------------------------
//
//   Copyright 2011 
//   VDOMBOX Resaerch  
//   All rights reserved. 
//
//------------------------------------------------------------------------------

package net.vdombox.ide.modules.wysiwyg.view.components
{
	import com.zavoo.svg.SVGViewer;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mx.binding.utils.BindingUtils;
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.controls.HTML;
	import mx.controls.Image;
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
	import net.vdombox.ide.common.vo.ResourceVO;
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
	import spark.components.supportClasses.GroupBase;
	import spark.components.supportClasses.ScrollBarBase;
	import spark.components.supportClasses.Skin;
	import spark.layouts.BasicLayout;
	import spark.layouts.HorizontalLayout;
	import spark.layouts.VerticalLayout;
	import spark.layouts.supportClasses.LayoutBase;
	import spark.primitives.Rect;


	/**
	 *
	 * @author andreev ap
	 */
	public class RendererBase extends SkinnableDataContainer implements IItemRenderer, IRenderer
	{
		/**
		 *
		 */
		public function RendererBase()
		{
			super();
			//setStyle("skinClass", Class(ObjectRendererSkin));

			itemRendererFunction = chooseItemRenderer;

			addHandlers();
		}
		
		override public function stylesInitialized():void {
			super.stylesInitialized();
			setStyle("skinClass", Class(ObjectRendererSkin));
		}

		[SkinPart( required = "true" )]
		/**
		 *
		 * @default
		 */
		public var background : Group;

		[SkinPart( required = "false" )]
		/**
		 *
		 * @default
		 */
		public var backgroundRect : Rect;

		[Embed( source = "/icons/wysiwyg_icon.png" )]
		/**
		 *
		 * @default
		 */
		public var blank_Icon : Class;

		[SkinPart( required = "true" )]
		/**
		 *
		 * @default
		 */
		public var locker : Group;

		[SkinPart( required = "true" )]
		/**
		 *
		 * @default
		 */
		public var scroller : Scroller;

		private var _data : Object;

		private var _editableComponent : Object;

		private var _isLocked : Boolean;

		private var _needRefresh : Boolean = false;

		private var _renderVO : RenderVO;

		private var _resourceID : String;

		private var _resourceVO : ResourceVO;

		private var beforeX : uint;

		private var beforeY : uint;

		private var loader : Loader;

		private var mDeltaX : uint;

		private var mDeltaY : uint;

		private const styleList : Array = [ [ "opacity", "backgroundAlpha" ], [ "backgroundcolor", "backgroundColor" ],
											[ "backgroundimage", "backgroundImage" ], [ "backgroundrepeat", "backgroundRepeat" ],
											[ "borderwidth", "borderThickness" ], [ "bordercolor", "borderColor" ], [ "color", "color" ],
											[ "fontfamily", "fontFamily" ], [ "fontsize", "fontSize" ], [ "fontweight", "fontWeight" ],
											[ "fontstyle", "fontStyle" ], [ "textdecoration", "textDecoration" ], [ "textalign", "textAlign" ],
											[ "align", "horizontalAlign" ], [ "valign", "verticalAlign" ] ];

		/**
		 *
		 * @param renderVO
		 * @return
		 */
		private function chooseItemRenderer( renderVO : RenderVO ) : IFactory
		{
			var itemFactory : ClassFactory;
			var layout : LayoutBase;

			switch ( renderVO.name )
			{
				case "container":
				{
					itemFactory = new ClassFactory( RendererBase );
					layout = new BasicLayout();
					layout.clipAndEnableScrolling = true;
					itemFactory.properties = { layout: layout };

					break;
				}

				case "table":
				{
					itemFactory = new ClassFactory( RendererBase );
					layout = new VerticalLayout();
					layout.clipAndEnableScrolling = true;
					//VerticalLayout( layout ).gap = 0;
					itemFactory.properties = { layout: layout };

					break;
				}

				case "row":
				{
					itemFactory = new ClassFactory( RendererBase );
					layout = new HorizontalLayout();
					layout.clipAndEnableScrolling = true;
					//HorizontalLayout( layout ).gap = 0;
					itemFactory.properties = { layout: layout, percentWidth: 100, percentHeight: 100 };

					break;
				}

				case "cell":
				{
					itemFactory = new ClassFactory( RendererBase );
					layout = new BasicLayout();
					layout.clipAndEnableScrolling = true;
					itemFactory.properties = { layout: layout, percentWidth: 100, percentHeight: 100 };

					break;
				}
				default:
				{
					itemFactory = new ClassFactory( RendererBase );
					layout = new BasicLayout();
					layout.clipAndEnableScrolling = false;
					itemFactory.properties = { layout: layout };

					break;
				}
			}

			return itemFactory;
		}

		/**
		 *
		 * @return
		 */
		public function get data() : Object
		{
			return _data;
		}

		/**
		 *
		 * @param value
		 */
		public function set data( value : Object ) : void
		{
			_data = value;

			renderVO = value as RenderVO;
		}

		/**
		 *
		 * @return
		 */
		public function get dragging() : Boolean
		{
			return false;
		}

		/**
		 *
		 * @param value
		 */
		public function set dragging( value : Boolean ) : void
		{
		}

		/**
		 *
		 * @return
		 */
		public function get editableComponent() : Object
		{
			return _editableComponent;
		}

		/**
		 *
		 * @return
		 */
		public function get isLocked() : Boolean
		{
			return _isLocked;
		}

		/**
		 *
		 * @param value
		 */
		public function set isLocked( value : Boolean ) : void
		{
			_isLocked = value;
		}

		/**
		 *
		 * @return
		 */
		public function get itemIndex() : int
		{
			return 0;
		}

		/**
		 *
		 * @param value
		 */
		public function set itemIndex( value : int ) : void
		{
		}

		/**
		 *
		 * @return
		 */
		public function get label() : String
		{
			return null;
		}

		/**
		 *
		 * @param value
		 */
		public function set label( value : String ) : void
		{
		}

		/**
		 *
		 * @param isRemoveChildren
		 */
		public function lock( isRemoveChildren : Boolean = false ) : void
		{
			isLocked = true;

			skin.currentState = "locked";

			if ( isRemoveChildren )
			{
				if ( width > 0 )
					width = width;

				if ( height > 0 )
					height = height;

				background.removeAllElements();
				dataProvider = null;
			}
		}

		/**
		 *
		 * @return
		 */
		public function get movable() : Boolean
		{
			var result : Boolean = false;

			if ( typeVO )
			{
				if ( typeVO.moveable == "0" )
					result = false;
				else if ( typeVO.moveable == "1" )
					result = true;
			}

			return result;
		}


		/**
		 *
		 * @return
		 */
		public function get renderVO() : RenderVO
		{
			return _renderVO;
		}

		/**
		 *
		 * @param value
		 */
		public function set renderVO( value : RenderVO ) : void
		{
			dispatchEvent( new RendererEvent( RendererEvent.RENDER_CHANGING ) );

			_renderVO = value;

			dispatchEvent( new RendererEvent( RendererEvent.RENDER_CHANGED ) );

			refresh();
		}

		/**
		 *
		 * @return
		 */
		public function get resizable() : uint
		{
			return typeVO ? uint( typeVO.resizable ) : 0;
		}

		/**
		 *
		 * @return
		 */
		public function get resourceID() : String
		{
			return _resourceID;
		}

		/**
		 *
		 * @return
		 */
		public function get resourceVO() : ResourceVO
		{
			return _resourceVO;
		}

		/**
		 *
		 * @param value
		 */
		public function set resourceVO( value : ResourceVO ) : void
		{
			_resourceVO = value;

			if ( !value.data )
			{
				BindingUtils.bindSetter( dataLoaded, value, "data" );
				return;
			}

			dataLoaded();
		}

		/**
		 *
		 * @return
		 */
		public function get selected() : Boolean
		{
			return true;
		}

		/**
		 *
		 * @param value
		 */
		public function set selected( value : Boolean ) : void
		{

		}


		/**
		 *
		 * @param value
		 */
//		public function set selected( value : Boolean ) : void
//		{
//		}

		/**
		 *
		 * @return
		 */
		public function get showsCaret() : Boolean
		{
			return false;
		}

		/**
		 *
		 * @param value
		 */
		public function set showsCaret( value : Boolean ) : void
		{
		}

		/**
		 *
		 * @return
		 */
		public function get typeVO() : TypeVO
		{
			return _renderVO ? _renderVO.vdomObjectVO.typeVO : null;
		}

		override public function validateProperties() : void
		{
			super.validateProperties();

			if ( !_needRefresh )
				return;

			_needRefresh = true;

			refresh();
		}

		/**
		 *
		 * @return
		 */
		public function get vdomObjectVO() : IVDOMObjectVO
		{
			return _renderVO ? _renderVO.vdomObjectVO : null;
		}


		
		protected function addHandlers() : void
		{
				addEventListener( FlexEvent.CREATION_COMPLETE, creationCompleteHandler, false, 0, true );
				addEventListener( Event.REMOVED_FROM_STAGE, removeHandler, false, 0, true );
	
				addEventListener( MouseEvent.MOUSE_OVER, mouseOverHandler, false, 0, true );
				addEventListener( MouseEvent.MOUSE_OUT, mouseOutHandler, false, 0, true );
	
				addEventListener( MouseEvent.MOUSE_DOWN, mouseDownHandler, false, 0, true );
	
				addEventListener( MouseEvent.CLICK, mouseClickHandler, false, 0, true );
	
				addEventListener( DragEvent.DRAG_ENTER, dragEnterHandler, false, 0, true );
				addEventListener( DragEvent.DRAG_EXIT, dragExitHandler, false, 0, true );
				addEventListener( DragEvent.DRAG_DROP, dragDropHandler, false, 0, true );
				
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

		private function caseContainer( contetnt : XML, parentContainer : Group ) : void
		{
			var conatiner : Group = getSubContainer( contetnt );

			if ( conatiner )
				parentContainer.addElement( conatiner );
			else
				conatiner = parentContainer;

			// TODO: need sort 'contetnt.children()' by 'z-index'
			for each ( var contetntPart : XML in contetnt.children() )
			{
				choiceContentType( contetntPart, conatiner );
			}
		}

		private function getSubContainer( contetnt : XML ) : Group
		{
//			<container id="9723e716-cb19-4539-afc9-491b0ffbd6fb" visible="1" zindex="0" hierarchy="0" order="0" top="91" left="320" width="152" height="34">
			var conatiner : Group;

			var param : Number;

			if ( contetnt.@id[ 0 ] )
			{
				conatiner = new Group();

				if ( contetnt.@visible[ 0 ] == "0" )
					conatiner.visible = false;

				param = Number( contetnt.@top[ 0 ] )

				if ( param )
					conatiner.y = param;

				param = Number( contetnt.@left[ 0 ] )

				if ( param )
					conatiner.x = param;

				param = Number( contetnt.@width[ 0 ] )

				if ( param )
					conatiner.width = param;

				param = Number( contetnt.@height[ 0 ] )

				if ( param )
					conatiner.height = param;


			}
			return conatiner;
		}

		private function caseHtmlText( contetntPart : XML, parentContainer : Group ) : void
		{
			var html : HTML = new HTML();

			html.x = contetntPart.@left;
			html.y = contetntPart.@top;
			html.width = contetntPart.@width;

			html.paintsDefaultBackground = true;

			if ( contetntPart.@height[ 0 ] )
				html.height = contetntPart.@height;

			html.setStyle( "borderVisible", false );
			html.blendMode = "darken";

			if ( contetntPart.@editable )
				_editableComponent = html;

			var htmlText : String = "<html>" + "<head>" + "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />" + "</head>" + "<body style=\"margin : 0px;\" >" + contetntPart[ 0 ] + "</body>" + "</html>";

			html.htmlText = htmlText;

			parentContainer.addElement( html );
		}

		private function caseSVG( contetntPart : XML, parentContainer : Group ) : void
		{
			var svg : SVGViewer = new SVGViewer();
			var editableAttributes : Array = svg.setXML( contetntPart );

			if ( editableAttributes.length > 0 )
				_editableComponent = editableAttributes[ 0 ].sourceObject;
			svg.addEventListener( RendererEvent.GET_RESOURCE, svgGetResourseHendler, false, 0, true );

			parentContainer.addElement( svg );
		}

		private function caseText( contetntPart : XML, parentContainer : Group ) : void
		{
			var richText : UIComponent

			if ( contetntPart.@editable )
			{
				richText = new RichEditableText();
				_editableComponent = richText;
			}
			else
				richText = new Text();

			richText.x = contetntPart.@left;
			richText.y = contetntPart.@top;
			richText.width = contetntPart.@width;

			richText[ "text" ] = contetntPart[ 0 ];

			applyStyles( richText, contetntPart );

			parentContainer.addElement( richText );
		}

		private function choiceContentType( contetntPart : XML, parentContainer : Group ) : void
		{
			switch ( contetntPart.name().toString() )
			{
				case "container":
				{
					caseContainer( contetntPart, parentContainer );
					break;
				}
				case "svg":
				{
					caseSVG( contetntPart, parentContainer );
					break;
				}

				case "text":
				{
					caseText( contetntPart, parentContainer );
					break;
				}
				case "htmltext":
				{
					caseHtmlText( contetntPart, parentContainer );
					break;
				}
				default:
				{
					trace( "-ERROR------RenderBase - refresh() - default value!!!--------:" + contetntPart.name().toString() + ":" )
				}
			}
		}

		private function creationCompleteHandler( event : FlexEvent ) : void
		{
			dispatchEvent( new RendererEvent( RendererEvent.CREATED ) );
		}

		private function dataLoaded( object : Object = null ) : void
		{
			loader = new Loader();

			loader.contentLoaderInfo.addEventListener( Event.COMPLETE, onBytesLoaded );
			loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, onBytesLoaded );

			try
			{
				loader.loadBytes( _resourceVO.data );
			}
			catch ( error : Error )
			{
				// FIXME Сделать обработку исключения если не грузится изображение
			}
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

		private function dragExitHandler( event : DragEvent ) : void
		{
			skin.currentState = "normal";
		}

		private function findNearestItem( currentElement : DisplayObjectContainer ) : RendererBase
		{
			var result : RendererBase;

			while ( currentElement && currentElement.parent )
			{
				if ( currentElement is RendererBase )
				{
					result = currentElement as RendererBase;
					break;
				}

				currentElement = currentElement.parent;
			}

			return result;
		}

		private function getBackGroundRect( content : Bitmap ) : Rectangle
		{
			var attributeVO : AttributeVO;
			var rectangle : Rectangle = new Rectangle();

			attributeVO = _renderVO.getAttributeByName( "backgroundrepeat" );

			if ( !attributeVO )
				return rectangle;

			switch ( attributeVO.value )
			{
				case "repeat":
				{
					rectangle.width = width;
					rectangle.height = height;
					break;
				}
				case "no-repeat":
				{
					rectangle.width = content.width;
					rectangle.height = content.height;
					break;
				}
				case "repeat-x":
				{
					rectangle.width = width;
					rectangle.height = content.height;
					break;
				}
				case "repeat-y":
				{
					rectangle.width = content.width;
					rectangle.height = height;
					break;
				}
			}

			return rectangle;
		}

		/**
		 *
		 * @param target
		 * @return
		 */
		private function getItemByTarget( target : DisplayObjectContainer ) : RendererBase
		{
			var result : RendererBase;
			var item : DisplayObjectContainer = target;

			while ( item && item.parent )
			{
				if ( item is RendererBase )
				{
					result = item as RendererBase;
					break;
				}

				item = item.parent;
			}

			return result;
		}

		private function isScroller( target : DisplayObjectContainer ) : Boolean
		{
			var result : Boolean = false;

			while ( target )
			{
				if ( target is ScrollBarBase )
				{
					result = true;
					break;
				}

				if ( target == this )
					break;

				if ( target.parent )
					target = target.parent;
				else
					target = null;
			}

			return result;
		}

		private function mouseClickHandler( event : MouseEvent ) : void
		{
			event.stopPropagation();

			if ( !isScroller( event.target as DisplayObjectContainer ) )
				dispatchEvent( new RendererEvent( RendererEvent.CLICKED ) );
		}

		private function mouseDownHandler( event : MouseEvent ) : void
		{
			if ( movable && !isScroller( event.target as DisplayObjectContainer ) )
			{
				stage.addEventListener( MouseEvent.MOUSE_MOVE, mouseMoveHandler, false, 0, true );
				stage.addEventListener( MouseEvent.MOUSE_UP, mouseUpHandler, false, 0, true );

				mDeltaX = mouseX;
				mDeltaY = mouseY;

				beforeX = x;
				beforeY = y;
			}

			event.stopImmediatePropagation();
			event.preventDefault();
		}

		private function mouseMoveHandler( event : MouseEvent ) : void
		{
			if ( !event.buttonDown )
				return;

			var dx : int = mouseX - mDeltaX;
			var dy : int = mouseY - mDeltaY;

			x = x + dx > 0 ? x + dx : 0;
			y = y + dy > 0 ? y + dy : 0;

			dispatchEvent( new RendererEvent( RendererEvent.MOVED ) );
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

		private function mouseUpHandler( event : MouseEvent ) : void
		{
			stage.removeEventListener( MouseEvent.MOUSE_MOVE, mouseMoveHandler );
			stage.removeEventListener( MouseEvent.MOUSE_UP, mouseUpHandler );

			if ( x != beforeX || y != beforeY )
			{
				beforeX = x;
				beforeY = y;

				dispatchEvent( new RendererEvent( RendererEvent.MOVE ) );

				stage.addEventListener( MouseEvent.CLICK, stage_mouseClickHandler, true, 0, true );
			}
		}

		/**
		 * Display image bitmap once bytes have loaded
		 **/
		private function onBytesLoaded( event : Event ) : void
		{

			//			event.target.contentLoaderInfo.removeEventListener( Event.COMPLETE, onBytesLoaded );
			//			event.target.contentLoaderInfo.removeEventListener( IOErrorEvent.IO_ERROR, onBytesLoaded );

			loader = null;

			if ( event.type == IOErrorEvent.IO_ERROR )
				return;

			var backGrSprite : Sprite = new Sprite();
			var bitmapWidth : Number, bitmapHeight : Number;
			var content : Bitmap;
			var rectangle : Rectangle;

			content = Bitmap( event.target.content );
			rectangle = getBackGroundRect( content );

			backGrSprite.graphics.clear();
			backGrSprite.graphics.beginBitmapFill( content.bitmapData, null, true );
			backGrSprite.graphics.drawRect( rectangle.x, rectangle.y, rectangle.width, rectangle.height );
			background.addElement( new SpriteUIComponent( backGrSprite ) );
		}

		/**
		 * Refresh att.
		 *
		 */
		private function refresh() : void
		{
			if ( !_renderVO )
			{
				lock( true );
				return;
			}

			var contetntPart : XML;

			background.removeAllElements();
			

			refreshAttributes();


			if ( _renderVO.staticFlag )
				locker.visible = true;

			if ( _renderVO && _renderVO.children && _renderVO.children.length > 0 )
			{
				// sort children by Z-index
				var childrenDataProvider : ArrayCollection;
				childrenDataProvider = new ArrayCollection( _renderVO.children );
				childrenDataProvider.sort = new Sort();
				childrenDataProvider.sort.fields = [ new SortField( "zindex" ), new SortField( "hierarchy" ), new SortField( "order" ) ];
				childrenDataProvider.refresh();

				dataProvider = childrenDataProvider;
			}
			else
				dataProvider = null;


			for each ( contetntPart in _renderVO.content )
			{
				choiceContentType( contetntPart, background );
			}

			skin.currentState = "normal";
		}

		/**
		 * Refresh all atributes contens in  current RenderVO
		 *
		 */
		private function refreshAttributes() : void
		{
			var attributeVO : AttributeVO;

			attributeVO = _renderVO.getAttributeByName( "width" );

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

			// Get BackgroundImage attribute
			attributeVO = _renderVO.getAttributeByName( "backgroundimage" );

			if ( attributeVO )
			{
				_resourceID = attributeVO.value;
				var renderEvent : RendererEvent = new RendererEvent( RendererEvent.GET_RESOURCE );
				renderEvent.object = this;
				dispatchEvent( renderEvent );
			}


		}

		private function removeHandler( event : Event ) : void
		{
			if ( event.target == this )
			{
				//TODO: check who is lissener
				dispatchEvent( new RendererEvent( RendererEvent.REMOVED ) );
				removeHandlers();
			}
		}

		protected function removeHandlers() : void
		{
			removeEventListener( FlexEvent.CREATION_COMPLETE, creationCompleteHandler );
			removeEventListener( Event.REMOVED, removeHandler );

			removeEventListener( MouseEvent.MOUSE_OVER, mouseOverHandler );
			removeEventListener( MouseEvent.MOUSE_OUT, mouseOutHandler );

			removeEventListener( MouseEvent.MOUSE_DOWN, mouseDownHandler );

			removeEventListener( MouseEvent.CLICK, mouseClickHandler );

			removeEventListener( DragEvent.DRAG_ENTER, dragEnterHandler );
			removeEventListener( DragEvent.DRAG_EXIT, dragExitHandler );
			removeEventListener( DragEvent.DRAG_DROP, dragDropHandler );
		}

		
		private function showHandler( event : FlexEvent ) : void
		{
			addHandlers();
		}
		
		private function stage_mouseClickHandler( event : MouseEvent ) : void
		{
			event.stopImmediatePropagation();
			event.preventDefault();

			stage.removeEventListener( MouseEvent.CLICK, stage_mouseClickHandler, true );
		}
		

		private function svgGetResourseHendler( event : RendererEvent ) : void
		{
			var renderEvent : RendererEvent = new RendererEvent( RendererEvent.GET_RESOURCE );
			renderEvent.object = event.object;

			dispatchEvent( renderEvent );
		}
	}
}

