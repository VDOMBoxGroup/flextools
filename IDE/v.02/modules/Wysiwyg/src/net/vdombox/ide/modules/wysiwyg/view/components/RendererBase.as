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
	
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Graphics;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	
	import flashx.textLayout.factory.TruncationOptions;
	
	import mx.binding.utils.BindingUtils;
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.controls.HScrollBar;
	import mx.controls.HTML;
	import mx.controls.Image;
	import mx.controls.Text;
	import mx.controls.ToolTip;
	import mx.controls.VScrollBar;
	import mx.core.Application;
	import mx.core.ClassFactory;
	import mx.core.IFactory;
	import mx.core.IVisualElement;
	import mx.core.ScrollPolicy;
	import mx.core.UIComponent;
	import mx.core.mx_internal;
	import mx.events.DragEvent;
	import mx.events.FlexEvent;
	import mx.events.ResizeEvent;
	import mx.graphics.SolidColor;
	import mx.graphics.SolidColorStroke;
	import mx.managers.SystemManager;
	import mx.managers.ToolTipManager;
	
	import net.vdombox.ide.common.interfaces.IVDOMObjectVO;
	import net.vdombox.ide.common.model._vo.AttributeVO;
	import net.vdombox.ide.common.model._vo.ObjectVO;
	import net.vdombox.ide.common.model._vo.PageVO;
	import net.vdombox.ide.common.model._vo.ResourceVO;
	import net.vdombox.ide.common.model._vo.TypeVO;
	import net.vdombox.ide.modules.wysiwyg.events.RendererDropEvent;
	import net.vdombox.ide.modules.wysiwyg.events.RendererEvent;
	import net.vdombox.ide.modules.wysiwyg.interfaces.IRenderer;
	import net.vdombox.ide.modules.wysiwyg.model.business.VdomDragManager;
	import net.vdombox.ide.modules.wysiwyg.model.vo.RenderVO;
	import net.vdombox.ide.modules.wysiwyg.view.components.controls.ToolbarButton;
	import net.vdombox.ide.modules.wysiwyg.view.skins.ObjectRendererSkin;
	
	import org.osmf.events.TimeEvent;
	
	import spark.components.Application;
	import spark.components.Button;
	import spark.components.Group;
	import spark.components.IItemRenderer;
	import spark.components.RichEditableText;
	import spark.components.Scroller;
	import spark.components.SkinnableDataContainer;
	import spark.components.TextArea;
	import spark.components.VGroup;
	import spark.components.supportClasses.GroupBase;
	import spark.components.supportClasses.ScrollBarBase;
	import spark.components.supportClasses.Skin;
	import spark.layouts.BasicLayout;
	import spark.layouts.HorizontalLayout;
	import spark.layouts.RowAlign;
	import spark.layouts.VerticalLayout;
	import spark.layouts.supportClasses.LayoutBase;
	import spark.primitives.Rect;
	import spark.skins.spark.ScrollerSkin;

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
			itemRendererFunction = chooseItemRenderer;
			
			ToolTip.maxWidth = 180;

			addHandlers();
		}

		[SkinPart( required = "true" )]
		/**
		 *
		 * @default
		 */
		public var background : Group;


		[SkinPart( required = "true" )]
		/**
		 *
		 * @default
		 */
		public var backgroundRect : Rect;

		[Embed( source = "assets/wysiwyg_icon.png" )]
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

		private var _renderVO : RenderVO;

		private var _resourceID : String;

		private var _resourceVO : ResourceVO;

		// TODO: delete 
		private var backgroundRefreshNeedFlag : Boolean = false;

		private var beforeX : uint;

		private var beforeY : uint;

		/**
		 * Display image bitmap once bytes have loaded
		 **/

		private var content : Bitmap;

		private var loader : Loader;

		private var mDeltaX : uint;

		private var mDeltaY : uint;

		private var needRefresh : Boolean               = false;

		private const styleList : Array                 = [ [ "opacity", "backgroundAlpha" ], [ "backgroundcolor", "backgroundColor" ],
															[ "backgroundimage", "backgroundImage" ], [ "backgroundrepeat", "backgroundRepeat" ],
															[ "borderwidth", "borderThickness" ], [ "bordercolor", "borderColor" ], [ "color", "color" ],
															[ "fontfamily", "fontFamily" ], [ "fontsize", "fontSize" ], [ "fontweight", "fontWeight" ],
															[ "fontstyle", "fontStyle" ], [ "textdecoration", "textDecoration" ], [ "textalign", "textAlign" ],
															[ "align", "horizontalAlign" ], [ "valign", "verticalAlign" ] ];

		/**
		 *
		 * @return
		 */
		
		private var beforeCreationComplete : Boolean = true;
			
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

			if ( !beforeCreationComplete && value )
				renderVO = value as RenderVO;
			
		}
		
		/*public function remove() : void
		{
			_data = null;
			
			if ( renderVO )
			{
				if( renderVO.children )
					renderVO.children.splice(0, renderVO.children.length);
				
				renderVO.parent = null;
				renderVO = null;
			}
		}*/

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
		
		public function set setState( value : String ) : void
		{
			skin.currentState = value;
			if ( value != "hovered" )
				hideToolTip();
		}

		public function get getState() : String
		{
			return skin.currentState;
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

			setState = "locked";

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
			if ( _renderVO == value )
				return;

			dispatchEvent( new RendererEvent( RendererEvent.RENDER_CHANGING ) );

			_renderVO = value;

			if ( _renderVO )
				dataProvider = _renderVO.sortedChildren;

			dispatchEvent( new RendererEvent( RendererEvent.RENDER_CHANGED ) );

			needRefresh = true;
			invalidateProperties()
//			refresh();
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
				BindingUtils.bindSetter( dataLoaded, value, "data", false, true  );
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

		override public function stylesInitialized() : void
		{
			super.stylesInitialized();
			setStyle("skinClass", Class(ObjectRendererSkin));
		}

		/**
		 *
		 * @return
		 */
		public function get typeVO() : TypeVO
		{
			return _renderVO ? _renderVO.vdomObjectVO.typeVO : null;
		}

		override public function validateDisplayList() : void
		{
			super.validateDisplayList();
			
			if ( editableComponent && typeVO && ( typeVO.name == "text" || typeVO.name == "richtext" ) 
				&& editableComponent.height != 0 && editableComponent.width != 0)
			{
				width = editableComponent.width;
				height = editableComponent.height;
				measuredWidth = editableComponent.width;
				measuredHeight = editableComponent.height;
			}

			if ( backgroundRefreshNeedFlag )
			{
				backgroundRefreshNeedFlag = false;
				//refresh();
				backgroundContentLoaded(null);
			}

		}

		override public function validateProperties() : void
		{
			super.validateProperties();

			if ( !needRefresh )
				return;

			needRefresh = false;

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
			addEventListener( Event.REMOVED, removeHandler, false, 0, true );

			addEventListener( MouseEvent.MOUSE_OVER, mouseOverHandler, false, 0, true );
			addEventListener( MouseEvent.MOUSE_OUT, mouseOutHandler, false, 0, true );

			addEventListener( MouseEvent.MOUSE_DOWN, mouseDownHandler, false, 0, true );

			addEventListener( MouseEvent.CLICK, mouseClickHandler, false, 0, true );

			addEventListener( DragEvent.DRAG_ENTER, dragEnterHandler, false, 0, true );
			addEventListener( DragEvent.DRAG_EXIT, dragExitHandler, false, 0, true );
			addEventListener( DragEvent.DRAG_DROP, dragDropHandler, false, 0, true );

			addEventListener( KeyboardEvent.KEY_DOWN , keyNavigationHandler);
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

			removeEventListener( KeyboardEvent.KEY_DOWN , keyNavigationHandler);
		}

		private function applyStyles( item : UIComponent, itemXMLDescription : XML ) : void
		{
			var _style : Object    = {};
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

		private function backgroundContentLoaded( event : Event ) : void
		{
			loader = null;

			if ( event != null )
			{
				if ( event.type == IOErrorEvent.IO_ERROR )
					return;
				else if ( event.type == "emptyResource" )
					content = null;
				else if ( event.type != "resizeMainWindow" )
					content = Bitmap( event.target.content );
			}

			if ( _renderVO && content )
			{
				var backGrSprite : Sprite = new Sprite();
				var bitmapWidth : Number, bitmapHeight : Number;
				var rectangle : Rectangle;

				rectangle = getBackGroundRect( content );
				
				background.graphics.clear();
				background.graphics.beginBitmapFill( content.bitmapData, null, true );
				background.graphics.drawRect( rectangle.x, rectangle.y, rectangle.width, rectangle.height );
				background.graphics.endFill();
//				invalidateDisplayList();
			}
			else if ( !content )
				background.graphics.clear();

			function getBackGroundRect( content : Bitmap ) : Rectangle
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
						rectangle.width = background.width;
						rectangle.height = background.height;
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
						rectangle.width = background.width;
						rectangle.height = content.height;
						break;
					}
					case "repeat-y":
					{
						rectangle.width = content.width;
						rectangle.height = background.height;
						break;
					}
				}

				return rectangle;
			}
		}

		private function caseContainer( contetnt : XML, parentContainer : Group ) : void
		{
			var conatiner : Group = getSubContainer( contetnt, parentContainer  );

			if ( !conatiner )
				conatiner = parentContainer;

			// TODO: need sort 'contetnt.children()' by 'z-index'
			for each ( var contetntPart : XML in contetnt.children() )
			{
				choiceContentType( contetntPart, conatiner );
			}
		}
		
		private function caseHtmlText( contetntPart : XML, parentContainer : Group ) : void
		{
			var html : HTML = new HTML();

			html.x = contetntPart.@left;
			html.y = contetntPart.@top;
			html.width = contetntPart.@width;
			html.height = contetntPart.@height;
			
			html.paintsDefaultBackground = true;

			if ( contetntPart.@height[ 0 ] )
				html.height = contetntPart.@height;

			html.setStyle( "borderVisible", false );
			html.blendMode = "darken";

			if ( contetntPart.@editable )
				_editableComponent = html;

			var htmlText : String = "<html>" + "<head>" + "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />" + "</head>" + "<body style=\"margin : 0px;\" >" + contetntPart[ 0 ] + "</body>" + "</html>";

			html.htmlText = htmlText;
			
			disableContainerScroller();
			
			parentContainer.addElement(html);
			
			dispatchEvent(new RendererEvent(RendererEvent.HTML_ADDED));

		}
		
		private function disableContainerScroller():void
		{
			scroller.enabled = false;
		}
		
		private function enableContainerScroller():void
		{
			scroller.enabled = true;
		}

		private function caseSVG( contetntPart : XML, parentContainer : Group ) : void
		{
			var svg : SVGViewer            = new SVGViewer();
			var editableAttributes : Array = svg.setXML( contetntPart );

			if ( editableAttributes.length > 0 )
				_editableComponent = editableAttributes[ 0 ].sourceObject;
			svg.addEventListener( RendererEvent.GET_RESOURCE, svgGetResourseHendler, false, 0, true );

			parentContainer.addElement( svg );
		}

		private function caseText( contetntPart : XML, parentContainer : Group ) : void
		{
			var richText : UIComponent

			if ( contetntPart.@editable[0] && contetntPart.@editable )
			{
				if ( !_editableComponent || !(_editableComponent is RichEditableText) )
				{
					richText = new RichEditableText();
					_editableComponent = richText;
				}
				else
					richText = _editableComponent as UIComponent;
			}
			else
			{
				richText = new Text();
				richText.maxHeight = 22;
			}
			
			richText.x = contetntPart.@left;
			richText.y = contetntPart.@top;
			
			if (contetntPart.@width[0] )
				richText.width = contetntPart.@width;
			else 
				richText.percentWidth = 100;
			
			richText.setStyle( "borderVisible", false );

			richText[ "text" ] = contetntPart[ 0 ];

			applyStyles( richText, contetntPart );
			
			parentContainer.addElement( richText );
		}
		
		private function mouseDownClick( event : MouseEvent ) : void
		{
			event.stopImmediatePropagation();
		}
		
		private function caseTable( contetnt : XML, parentContainer : Group ) : void
		{
			var conatiner : Group = getSubTable( contetnt, parentContainer  );
			
			if ( !conatiner )
				conatiner = parentContainer;
			
			// TODO: need sort 'contetnt.children()' by 'z-index'
			for each ( var contetntPart : XML in contetnt.children() )
			{
				choiceContentType( contetntPart, conatiner );
			}
		}
		
		
		private function caseRow( contetnt : XML, parentContainer : Group ) : void
		{
			var conatiner : Group = getSubRow( contetnt, parentContainer  );
			
			if ( !conatiner )
				conatiner = parentContainer;
			
			// TODO: need sort 'contetnt.children()' by 'z-index'
			for each ( var contetntPart : XML in contetnt.children() )
			{
				choiceContentType( contetntPart, conatiner );
			}
		}
		
		private function caseCell( contetnt : XML, parentContainer : Group ) : void
		{
			var conatiner : Group = getSubCell( contetnt, parentContainer  );
			
			if ( !conatiner )
				conatiner = parentContainer;
			
			// TODO: need sort 'contetnt.children()' by 'z-index'
			for each ( var contetntPart : XML in contetnt.children() )
			{
				choiceContentType( contetntPart, conatiner );
			}
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
					
				case "table":
				{
					caseTable( contetntPart, parentContainer );
					break;
				}
					
				case "row":
				{ 
					caseRow( contetntPart, parentContainer );
					break;
				}
					
				case "cell":
				{
					caseCell( contetntPart, parentContainer );
					break;
				}
					
				default:
				{
					trace( "-ERROR------RenderBase - refresh() - default value!!!--------:" + contetntPart.name().toString() + ":\n")
					caseContainer( contetntPart, parentContainer );
				}
			}
		}

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

		private function creationCompleteHandler( event : FlexEvent ) : void
		{
			beforeCreationComplete = false;
			if ( _data )
				renderVO = _data as RenderVO;
			
			dispatchEvent( new RendererEvent( RendererEvent.CREATED ) );
			createToolTip();
		}

		private function dataLoaded( object : Object = null ) : void
		{
			loader = new Loader();

			loader.contentLoaderInfo.addEventListener( Event.COMPLETE, backgroundContentLoaded );
			parentApplication.addEventListener("resizeMainWindow", resizePageRenderer);
			loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, backgroundContentLoaded );

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
			setState = "normal";

			var rde : RendererDropEvent = new RendererDropEvent( RendererDropEvent.DROP );

			var typeVO : TypeVO         = TypeItemRenderer( event.dragInitiator ).typeVO;

			var objectLeft : Number     = this.mouseX - 25 + this.layout.horizontalScrollPosition;
			var objectTop : Number      = this.mouseY - 25 + this.layout.verticalScrollPosition;
			
			if ( objectLeft < 0 )
				objectLeft = 0;
			
			if ( objectTop < 0 )
				objectTop = 0;

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

			var containersRE : RegExp     = /(\w+)/g;
			var aviableContainers : Array = typeDescription.aviableContainers.match( containersRE );
			var currentItemName : String;

			if ( _renderVO )
				currentItemName = _renderVO.vdomObjectVO.typeVO.name;

			var vdomDragManager : VdomDragManager = VdomDragManager.getInstance();;
			if ( aviableContainers.indexOf( currentItemName ) != -1 )
			{
				vdomDragManager.acceptDragDrop( UIComponent( this ) );
				setState = "highlighted";
			}
			else
			{
				setState = "notPackeg";
				vdomDragManager.hitTarget( UIComponent( this ) );
			}
		}

		private function dragExitHandler( event : DragEvent ) : void
		{
			setState = "normal";
			trace("dragExit");
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

		private function getSubContainer( contetnt : XML , parentContainer : Group ) : Group
		{
			var conatiner : Group;

			var param : Number;

			if ( !contetnt.@id[ 0 ] )
				return null;


			conatiner = new Group();
			conatiner.clipAndEnableScrolling = true;

			parentContainer.addElement( conatiner );


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
			else 
				conatiner.percentWidth = 100;

			param = Number( contetnt.@height[ 0 ] )

			if ( param )
				conatiner.height = param;


			return conatiner;
		}
		
		private function getSubTable( contetnt : XML , parentContainer : Group ) : Group
		{
			var conatiner : Group;
			var param : Number;
			
			conatiner = new Group();
			
			var conatiner2 : Group = new Group();
			
			var groupLayout : VerticalLayout = new VerticalLayout();
			groupLayout.gap = 0;
			conatiner2.layout = groupLayout;
			
			//conatiner2.clipAndEnableScrolling = true;
			
			conatiner2.percentWidth = 100;
			conatiner2.percentHeight = 100;
			
			var scroll : Scroller = new Scroller();
			scroll.percentWidth = 100;
			scroll.percentHeight = 100; 
			scroll.viewport = conatiner2;
			scroll.focusEnabled = false;
			
			//conatiner2.addElement( scroll );
		
			
			parentContainer.addElement( conatiner );
			
			//conatiner.clipAndEnableScrolling = true;
			
			param = Number( contetnt.@top[ 0 ] )
			
			if ( param )
				conatiner.y = param;
			
			param = Number( contetnt.@left[ 0 ] )
			
			if ( param )
				conatiner.x = param;
			
			param = Number( contetnt.@width[ 0 ] )
			
			if ( param )
				conatiner.width = param;
			else 
				conatiner.percentWidth = 100;

			param = Number( contetnt.@height[ 0 ] )
			
			if ( param )
				conatiner.height = param;
			else 
				conatiner.percentHeight = 100;
			
			setStyleField( contetnt, conatiner );
			
			
			disableContainerScroller();
			
			conatiner.addElement( scroll );
			
			
			return conatiner2;
		}
		
		private function getSubRow( contetnt : XML , parentContainer : Group ) : Group
		{
			
			var conatiner : Group;
			var param : Number;

			conatiner = new Group();
			
			conatiner.clipAndEnableScrolling = true;
			
			parentContainer.addElement( conatiner );
			
			param = Number( contetnt.@top[ 0 ] )
			
			if ( param )
				conatiner.y = param;
			
			param = Number( contetnt.@left[ 0 ] )
			
			if ( param )
				conatiner.x = param;
			
			param = Number( contetnt.@width[ 0 ] )
				
			if ( param )
				conatiner.width = param;
			else 
				conatiner.percentWidth = 100;
			
			param = Number( contetnt.@height[ 0 ] )
			
			if ( param )
				conatiner.height = param;
			else 
				conatiner.percentHeight = 100;
			
			setStyleField( contetnt, conatiner );
			
			var conatiner2 : Group = new Group();
			
			var groupLayout : HorizontalLayout = new HorizontalLayout();
			groupLayout.gap = -1;
			conatiner2.layout = groupLayout;
			
			conatiner2.clipAndEnableScrolling = true;
			
			
			conatiner2.percentWidth = 100;
			conatiner2.percentHeight = 100;
			
//			conatiner2.left = 0;
//			conatiner2.right = 0;
//			conatiner2.top = 0;
//			conatiner2.bottom = 0;
			
			conatiner.addElement( conatiner2 );
			
			

			
			return conatiner2;
		}
		
		private function setStyleField( contetnt : XML , conatiner : Group ) : void
		{
			var rect : Rect = new Rect();
			if ( contetnt.@backgroundcolor[ 0 ] )
				rect.fill = new SolidColor( colorToUint(  contetnt.@backgroundcolor[ 0 ] ) );
			if ( contetnt.@bordercolor[ 0 ] )
			{
				rect.stroke = new SolidColorStroke( colorToUint( contetnt.@bordercolor[ 0 ] ) );
				if ( contetnt.@borderwidth[ 0 ] )
					rect.stroke.weight = Number ( contetnt.@borderwidth[ 0 ] );
			}
			
			rect.left = 0;
			rect.top = 0;
			rect.right = 0;
			rect.bottom = 0;
			conatiner.addElement( rect );
		}
		
		private function colorToUint( color : String ) : uint
		{
			if ( color.charAt(0) == "#" )
			{
				color = color.substr( 1, color.length - 1);
				color = "0x" + color;
			}
			return uint( color );
		}
		
		private function getSubCell( contetnt : XML , parentContainer : Group ) : Group
		{
			
			var conatiner : Group;
			var param : Number;
			
			conatiner = new Group();
			
			conatiner.layout = new BasicLayout();
			
			conatiner.clipAndEnableScrolling = true;
			
			parentContainer.addElement( conatiner );
			
			param = Number( contetnt.@top[ 0 ] )
			
			if ( param )
				conatiner.y = param;
			
			param = Number( contetnt.@left[ 0 ] )
			
			if ( param )
				conatiner.x = param;
			
			param = Number( contetnt.@width[ 0 ] )
			
			if ( param )
				conatiner.width = param;
			else 
				conatiner.percentWidth = 100;
			
			param = Number( contetnt.@height[ 0 ] )
			
			if ( param )
				conatiner.height = param;
			else 
				conatiner.percentHeight = 100;
			
			setStyleField( contetnt, conatiner );
			
			return conatiner;
		}

		private function isScroller( target : DisplayObjectContainer ) : Boolean
		{
			var result : Boolean = false;
			
			while ( target )
			{
				if ( isScrollBarObject(target) )
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

		private function isScrollBarObject(target : DisplayObjectContainer) : Boolean
		{
			return target is ScrollBarBase || target is HScrollBar || target is VScrollBar;
		}
		
		private function keyNavigationHandler( event : KeyboardEvent ) : void
		{
			if ( event.target != event.currentTarget )
				return;
			
			var step : Number = 1;

			if ( event.shiftKey )
				step = 10;

			if ( event.keyCode == Keyboard.LEFT )
				x = x - step > 0 ? x - step : 0;
			else if ( event.keyCode == Keyboard.RIGHT )
				x = x + step;
			else if ( event.keyCode == Keyboard.UP )
				y = y - step > 0 ? y - step : 0;
			else if ( event.keyCode == Keyboard.DOWN )
				y = y + step;
			else
			{
				if ( event.keyCode == Keyboard.DELETE )
					dispatchEvent( new KeyboardEvent( "deleteObjectOnScreen" ) );
				else if ( event.ctrlKey )
				{
					var sourceID : String;
					if ( event.keyCode == Keyboard.C )
					{
						
						if ( renderVO && renderVO.vdomObjectVO is ObjectVO )
						{
							var obj : ObjectVO = renderVO.vdomObjectVO as ObjectVO;
							sourceID = "Vlt+VDOMIDE2+ " + obj.pageVO.applicationVO.id  + " " + obj.id + " 0";
						}
						else if ( renderVO && renderVO.vdomObjectVO is PageVO )
						{
							var pg : PageVO = renderVO.vdomObjectVO as PageVO;
							sourceID = "Vlt+VDOMIDE2+ " + pg.applicationVO.id  + " " + pg.id + " 1";
						}
						
						Clipboard.generalClipboard.setData( ClipboardFormats.TEXT_FORMAT, sourceID );
					}
					else if ( event.keyCode == Keyboard.V )
					{
						dispatchEvent( new RendererEvent( RendererEvent.PASTE_SELECTED ) );
					}
					
				}
				return;
			}

			mouseUpHandler( null );

			event.stopImmediatePropagation();

			dispatchEvent( new RendererEvent( RendererEvent.CLEAR_RENDERER ) );
		}

		private function mouseClickHandler( event : MouseEvent ) : void
		{
			event.stopPropagation();

			if ( !isScroller( event.target as DisplayObjectContainer ) )
				dispatchEvent( new RendererEvent( RendererEvent.CLICKED ) );
		}

		private function mouseDownHandler( event : MouseEvent ) : void
		{
			if ( !( editableComponent && editableComponent is RichEditableText && !( event.target is Group ) ) )
			{
				setFocus();
			
				var isScroller : Boolean = isScroller( event.target as DisplayObjectContainer ); 
			
				if ( movable && !isScroller )
				{
					stage.addEventListener( MouseEvent.MOUSE_MOVE, mouseMoveHandler, true, 0, true );
					stage.addEventListener( MouseEvent.MOUSE_UP, mouseUpHandler, false, 0, true );

					mDeltaX = mouseX;
					mDeltaY = mouseY;

					beforeX = x;
					beforeY = y;
					
					beforeLeft = x;
					beforeTop = y;
				}
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

			if ( event.shiftKey )
			{
				dx = x - beforeX;
				dy = y - beforeY;

				if ( Math.abs( dx ) >= Math.abs( dy ) )
				{
					x = beforeX + dx > 0 ? beforeX + dx : 0;
					y = beforeY;
				}
				else
				{
					x = beforeX;
					y = beforeY + dy > 0 ? beforeY + dy : 0;
				}
			}

			dispatchEvent( new RendererEvent( RendererEvent.MOVED ) );

			var moveEvent : RendererEvent = new RendererEvent( RendererEvent.MOVE_MEDIATOR );
			moveEvent.ctrlKey = event.ctrlKey;
			dispatchEvent( moveEvent );
		}

		private function mouseOutHandler( event : MouseEvent ) : void
		{
			trace( "Out" );
			if ( skin.currentState == "hovered" )
				setState = "normal";
			else
				hideToolTip();
		}

		private function mouseOverHandler( event : MouseEvent ) : void
		{
			if ( skin.currentState == "highlighted" || skin.currentState == "notPackeg" )
				return;

			invalidateDisplayList();
			
			if ( findNearestItem( event.target as DisplayObjectContainer ) == this )
			{
				setState = "hovered";
				if ( !( this is PageRenderer ) )
				{ 
					showToolTip( typeVO.name + ": " + renderVO.vdomObjectVO.name );
					event.stopImmediatePropagation();
				}
			}
			else
			{
				setState = "normal";
			}
			
			
		}
		
		public var beforeLeft : Number;
		public var beforeTop : Number;

		private function mouseUpHandler( event : MouseEvent ) : void
		{
			if ( !stage )
				return;
			stage.removeEventListener( MouseEvent.MOUSE_MOVE, mouseMoveHandler, true );
			stage.removeEventListener( MouseEvent.MOUSE_UP, mouseUpHandler );

			if ( x != beforeX || y != beforeY )
			{
				beforeX = x;
				beforeY = y;

				dispatchEvent( new RendererEvent( RendererEvent.MOVE ) );

				stage.addEventListener( MouseEvent.CLICK, stage_mouseClickHandler, true, 0, true );
			}

			dispatchEvent( new RendererEvent( RendererEvent.MOUSE_UP_MEDIATOR ) );
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
			refreshAttributes();

			refreshContent();


			if ( _renderVO.staticFlag )
				locker.visible = true;
			
			setState = "normal";
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

			if ( attributeVO && attributeVO.value != "" )
			{
				_resourceID = attributeVO.value;
				var renderEvent : RendererEvent = new RendererEvent( RendererEvent.GET_RESOURCE );
				renderEvent.object = this;
				dispatchEvent( renderEvent );
			}
			else
				backgroundContentLoaded( new Event( "emptyResource" ) );


		}

		private function refreshContent() : void
		{
			background.removeAllElements();

			for each ( var contetntPart : XML in _renderVO.content )
			{
				choiceContentType( contetntPart, background );
			}
		}

		private function removeHandler( event : Event ) : void
		{
			if ( event.target == this )
			{
				//TODO: check who is lissener
				trace("Remove - " + name);
				
				dispatchEvent( new RendererEvent( RendererEvent.REMOVED ) );
				removeHandlers();
				
				delete this;
			}
		}

		private function resizePageRenderer(event : Event) : void
		{
			backgroundRefreshNeedFlag = true;
			invalidateDisplayList();
		}
		
		private function showHandler( event : FlexEvent ) : void
		{
			addHandlers();
		}

		private function stage_mouseClickHandler( event : MouseEvent ) : void
		{
			event.stopImmediatePropagation();
			event.preventDefault();

			if( stage )
				stage.removeEventListener( MouseEvent.CLICK, stage_mouseClickHandler, true );
		}


		private function svgGetResourseHendler( event : RendererEvent ) : void
		{
			var renderEvent : RendererEvent = new RendererEvent( RendererEvent.GET_RESOURCE );
			renderEvent.object = event.object;

			dispatchEvent( renderEvent );
		}
		
		private var tip : ToolTip;
		
		private function createToolTip() : void
		{
			if( tip )
				ToolTipManager.destroyToolTip( tip );
			
			tip = ToolTip( ToolTipManager.createToolTip( "", 0, 0, null, skin.parentApplication as UIComponent ));
			tip.visible = false;
			tip.setStyle( "backgroundColor", 0xFFFFFF );
			tip.setStyle( "fontSize", 9 );
			tip.setStyle( "cornerRadius", 0 );
		}
		
		private function showToolTip( text : String) : void
		{
			addEventListener( MouseEvent.MOUSE_MOVE, systemManager_mouseMoveHandler );
			tip.text = text;
		}
	
		private function hideToolTip() : void
		{
			removeEventListener( MouseEvent.MOUSE_MOVE, systemManager_mouseMoveHandler );
			if ( tip )
				tip.visible = false;
		}
		
		private function systemManager_mouseMoveHandler( event : MouseEvent ) : void 
		{
			tip.x =	event.stageX + 15;
			tip.y = event.stageY + 15;
			if ( !tip.visible )
				tip.visible = true;
		}
	}
}

