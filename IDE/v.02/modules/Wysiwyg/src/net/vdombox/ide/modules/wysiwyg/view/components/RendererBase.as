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
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	
	import flashx.textLayout.factory.TruncationOptions;
	
	import mx.binding.utils.BindingUtils;
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.containers.Canvas;
	import mx.controls.HScrollBar;
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
	import net.vdombox.utils.XMLUtils;
	
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
		private static var OVERFLOW_NONE	: String = "none";
		private static var OVERFLOW_AUTO	: String = "auto";
		private static var OVERFLOW_HIDDEN	: String = "hidden";
		private static var OVERFLOW_SCROLL	: String = "scroll";
		private static var OVERFLOW_VISIBLE	: String = "visible";
		
		private var overflow : String = OVERFLOW_NONE;
		/**
		 *
		 */
		public function RendererBase()
		{
			super();
			itemRendererFunction = chooseItemRenderer;
			
			ToolTip.maxWidth = 180;
			doubleClickEnabled = true;

			addHandlers();
			
			doubleClickEnabled = true;
		}

		[SkinPart( required = "true" )]
		public var background : Group;

		[SkinPart( required = "true" )]
		public var backgroundRect : Rect;

		[Embed( source = "assets/wysiwyg_icon.png" )]
		public var blank_Icon : Class;

		[SkinPart( required = "true" )]
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
		
		private var _selected : Boolean;

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
		
		private var _move : Boolean = false;
			
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

			if ( !beforeCreationComplete )
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
			return _selected;
		}

		/**
		 *
		 * @param value
		 */
		public function set selected( value : Boolean ) : void
		{
			_selected = value;
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
			addEventListener( Event.REMOVED_FROM_STAGE, removeHandler, false, 0, true );

			addEventListener( MouseEvent.MOUSE_OVER, mouseOverHandler, false, 0, true );
			addEventListener( MouseEvent.MOUSE_OUT, mouseOutHandler, false, 0, true );

			addEventListener( MouseEvent.MOUSE_DOWN, mouseDownHandler, false, 0, true );
			addEventListener( MouseEvent.MOUSE_DOWN, mouseDownForEditableComponentHandler, true, 0, true );
			addEventListener( MouseEvent.CLICK, mouseClickHandler, false, 0, true );
			addEventListener( MouseEvent.DOUBLE_CLICK, mouse2ClickHandler, false, 0, true );

			addEventListener( DragEvent.DRAG_ENTER, dragEnterHandler, false, 0, true );
			addEventListener( DragEvent.DRAG_EXIT, dragExitHandler, false, 0, true );
			addEventListener( DragEvent.DRAG_DROP, dragDropHandler, false, 0, true );

			addEventListener( KeyboardEvent.KEY_DOWN , keyNavigationHandler, false, 0 , true);
		}

		protected function removeHandlers() : void
		{
			removeEventListener( FlexEvent.CREATION_COMPLETE, creationCompleteHandler );
			removeEventListener( Event.REMOVED_FROM_STAGE, removeHandler );

			removeEventListener( MouseEvent.MOUSE_OVER, mouseOverHandler );
			removeEventListener( MouseEvent.MOUSE_OUT, mouseOutHandler );


			removeEventListener( MouseEvent.MOUSE_DOWN, mouseDownHandler );
			removeEventListener( MouseEvent.MOUSE_DOWN, mouseDownForEditableComponentHandler, true );
            removeEventListener( MouseEvent.CLICK, mouseClickHandler );
			removeEventListener( MouseEvent.DOUBLE_CLICK, mouse2ClickHandler );
			
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
			
			var childrenXMLList : XMLList = contetnt.children().copy();
			
			var leng : int = childrenXMLList.length();
			var temp : XML;
			
			for ( var i : int = 0; i < leng; i++ )
			{
				for ( var j : int = i+1; j < leng; j++ )
				{
					if ( childrenXMLList[i].@zindex === childrenXMLList[j].@zindex )
					{
						if ( int( childrenXMLList[i].@hierarchy ) === int( childrenXMLList[j].@hierarchy ) )
						{
							if ( int( childrenXMLList[i].@order ) > int( childrenXMLList[j].@order ) )
							{
								temp = childrenXMLList[i];
								childrenXMLList[i] = childrenXMLList[j];
								childrenXMLList[j] = temp;
							}
						}
						else if ( int( childrenXMLList[i].@hierarchy ) > int( childrenXMLList[j].@hierarchy ) )
						{
							temp = childrenXMLList[i];
							childrenXMLList[i] = childrenXMLList[j];
							childrenXMLList[j] = temp;
						}
					}
					else if ( int( childrenXMLList[i].@zindex ) > int( childrenXMLList[j].@zindex ) )
					{
						temp = childrenXMLList[i];
						childrenXMLList[i] = childrenXMLList[j];
						childrenXMLList[j] = temp;
					}
				}
			}
			
			for each ( var contetntPart : XML in childrenXMLList )
			{
				choiceContentType( contetntPart, conatiner );
			}
		}
		
		private function caseHtmlText( contetntPart : XML, parentContainer : Group ) : void
		{
			var html : HTML = new HTML();

			html.x = contetntPart.@left;
			html.y = contetntPart.@top;
			
			html.paintsDefaultBackground = true;

			if ( contetntPart.@width[ 0 ] && contetntPart.@width[ 0 ]!="" )
				html.width = contetntPart.@width;
			
			if ( contetntPart.@height[ 0 ] && contetntPart.@height[ 0 ]!="" )
				html.height = contetntPart.@height;
			
			if ( contetntPart.@overflow[ 0 ] )
				html.overflow = contetntPart.@overflow[ 0 ];
						
			html.setStyle( "borderVisible", false );
			
			html.blendMode = contetntPart.@blendMode;
			
			if ( contetntPart.@editable )
				_editableComponent = html;

			var htmlText : String = "<html>" + "<head>" + "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />" + "</head>" + "<body style=\"margin : 0px;\" >" + contetntPart.children().toString() + "</body>" + "</html>";

			html.htmlText = htmlText;
			
			disableContainerScroller();
			
			parentContainer.addElement(html);
			
			var locked:String = contetntPart.@locked;
			html.locked = locked.toLowerCase() == "true";
				
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
		
		override protected function childrenCreated():void
		{
			super.childrenCreated();
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
		
		private function caseTable( contetnt : XML, parentContainer : Group ) : void
		{
			var conatiner : Group = getSubTable( contetnt, parentContainer  );
			
			if ( !conatiner )
				conatiner = parentContainer;
			
			// TODO: need sort 'contetnt.children()' by 'z-index'
			
			var childrenXMLList : XMLList = XMLUtils.sortElementsInXMLList( contetnt.children(), [ new SortField( "zindex" ), new SortField( "hierarchy" ), new SortField( "order" ) ] );
				
			for each ( var contetntPart : XML in childrenXMLList )
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
			
			var childrenXMLList : XMLList = XMLUtils.sortElementsInXMLList( contetnt.children(), [ new SortField( "zindex" ), new SortField( "hierarchy" ), new SortField( "order" ) ] );
			
			for each ( var contetntPart : XML in childrenXMLList )
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
			var childrenXMLList : XMLList = XMLUtils.sortElementsInXMLList( contetnt.children(), [ new SortField( "zindex" ), new SortField( "hierarchy" ), new SortField( "order" ) ] );
			
			for each ( var contetntPart : XML in childrenXMLList )
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

			var objectLeft : Number     = this.mouseX - 25 + (this.dataGroup.parent as Group).horizontalScrollPosition;
			var objectTop : Number      = this.mouseY - 25 + (this.dataGroup.parent as Group).verticalScrollPosition;
			
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
			else if ( typeVO.container == 2 )
			{
				setState = "notPackeg";
				vdomDragManager.hitTarget( UIComponent( this ) );
			}
		}

		private function dragExitHandler( event : DragEvent ) : void
		{
			setState = "normal";
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

			if ( event.keyCode >= 37 && event.keyCode <= 40 )
			{
				if ( skin.currentState == "multiSelect" )
				{
					var dx : int = 0;
					var dy : int = 0;
					if ( event.keyCode == Keyboard.LEFT || event.keyCode == Keyboard.RIGHT )
					{
						if ( event.keyCode == Keyboard.LEFT )
							dx = -step;
						else
							dx = step;
					}
					else
					{
						if ( event.keyCode == Keyboard.UP )
							dy = -step;
						else
							dy = step;
					}
					
					var rendererEvent : RendererEvent = new RendererEvent( RendererEvent.MULTI_SELECTED_MOVE );
					rendererEvent.object = { dx : dx, dy : dy };
					dispatchEvent( rendererEvent );
					
					dispatchEvent( new RendererEvent ( RendererEvent.MULTI_SELECTED_MOVED ) );
				}
				else
				{
					if ( event.keyCode == Keyboard.LEFT )
						x = x - step > 0 ? x - step : 0;
					else if ( event.keyCode == Keyboard.RIGHT )
						x = x + step;
					else if ( event.keyCode == Keyboard.UP )
						y = y - step > 0 ? y - step : 0;
					else
						y = y + step;
				}
					
			}
			else
			{
				if ( event.keyCode == Keyboard.DELETE )
					dispatchEvent( new KeyboardEvent( "deleteObjectOnScreen" ) );
				else if ( event.ctrlKey )
				{
					
					if ( event.keyCode == Keyboard.C )
						dispatchEvent( new RendererEvent( RendererEvent.COPY_SELECTED ) );
					else if ( event.keyCode == Keyboard.V )
						dispatchEvent( new RendererEvent( RendererEvent.PASTE_SELECTED ) );
					
				}
				return;
			}

			mouseUpHandler( null );

			event.stopImmediatePropagation();

			dispatchEvent( new RendererEvent( RendererEvent.CLEAR_RENDERER ) );
		}
		
		private var selecteRectDraw : Boolean = false;

		private function mouseDownHandler( event : MouseEvent ) : void
		{	
			_move = false;
			
			if ( event.shiftKey )
			{
				setFocus();
				dispatchEvent( new RendererEvent ( RendererEvent.MOUSE_DOWN, false, true, true ) );
				event.stopImmediatePropagation();
				event.preventDefault();
				
				stage.addEventListener( MouseEvent.MOUSE_UP, mouseUpHandler, false, 0, true );
				
				return;
			}
			
			if ( !( editableComponent && editableComponent is RichEditableText && !( event.target is Group ) && stage.focus == editableComponent ) )
			{
				setFocus();
				var isScroller : Boolean = isScroller( event.target as DisplayObjectContainer ); 
			
				if ( movable && !isScroller )
				{
					stage.addEventListener( MouseEvent.MOUSE_MOVE, mouseMoveHandler, true, 0, true );
					stage.addEventListener( MouseEvent.MOUSE_UP, mouseUpHandler, false, 0, true );

					mDeltaX = int(mouseX);
					mDeltaY = int(mouseY);
	
					beforeX = x;
					beforeY = y;
					
					beforeLeft = x;
					beforeTop = y;
				}
			}
			
			event.stopImmediatePropagation();
			event.preventDefault();
		}
		
		private function mouseDownForEditableComponentHandler( event : MouseEvent ) : void
		{
			if ( editableComponent is HTML && !selected )
				mouseDownHandler( event );
		}
		
		private function mouseClickHandler( event : MouseEvent ) : void
		{
			event.stopPropagation();
			
			if ( !isScroller( event.target as DisplayObjectContainer ) )
			{
				dispatchEvent( new RendererEvent( RendererEvent.CLICKED, false, true, event.shiftKey ) );
			}
			
			if( !editableComponent )
				dispatchEvent( new RendererEvent( RendererEvent.EDITED ) );
		}
		

		private function mouse2ClickHandler( event : MouseEvent ) : void
		{
			event.stopPropagation();
			
			if ( editableComponent )
			{
				dispatchEvent( new RendererEvent( RendererEvent.EDITED ) );
			}
		}

		private function mouseMoveHandler( event : MouseEvent ) : void
		{
			_move = true;
			
			if ( !event.buttonDown )
				return;
			
			var dx : int = int( mouseX - mDeltaX );
			var dy : int = int( mouseY - mDeltaY );
			
			var moveEvent : RendererEvent = new RendererEvent( RendererEvent.MOVE_MEDIATOR );
			moveEvent.ctrlKey = event.ctrlKey;
			moveEvent.object = { x : mDeltaX, y : mDeltaY, dx : dx, dy : dy };
			
			if ( skin.currentState == "multiSelect" )
			{
				var rendererEvent : RendererEvent = new RendererEvent( RendererEvent.MULTI_SELECTED_MOVE );
				rendererEvent.object = { dx : dx, dy : dy };
				dispatchEvent( rendererEvent );
				
				//dispatchEvent( moveEvent );
				return;
			}

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

			dispatchEvent( moveEvent );
		}
		
		public function hasMoved( dx : int, dy : int ) : Boolean
		{
			if ( x + dx < 0 || y + dy < 0 )
				return false;
			
			return true;
		}
		
		public function moveRenderer( dx : int, dy : int ) : void
		{
			if (  skin.currentState == "multiSelect" )
			{				
				var rendererEvent : RendererEvent = new RendererEvent( RendererEvent.MULTI_SELECTED_MOVE );
				rendererEvent.object = { dx : dx, dy : dy };
				dispatchEvent( rendererEvent );
			}
			else
			{
				x += dx;
				y += dy;
				
				dispatchEvent( new RendererEvent( RendererEvent.MOVED ) );
			}
		}

		public function moveTo( dx : int, dy : int, target : RendererBase = null ) : void
		{
			x += dx;
			y += dy;
			
			dispatchEvent( new RendererEvent( RendererEvent.MOVED ) );
			
			if ( target == this )
			{
				var moveEvent : RendererEvent = new RendererEvent( RendererEvent.MOVE_MEDIATOR );
				moveEvent.object = { x : mDeltaX, y : mDeltaY, dx : dx, dy : dy };
				dispatchEvent( moveEvent );
			}
		}
		
		private function mouseOutHandler( event : MouseEvent ) : void
		{
			if ( skin.currentState == "hovered" )
				setState = "normal";
			else
				hideToolTip();
		}

		private function mouseOverHandler( event : MouseEvent ) : void
		{
			if ( skin.currentState == "highlighted" || skin.currentState == "notPackeg" || skin.currentState == "multiSelect")
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
		
		public function savePosition() : void
		{
			if ( x != beforeX || y != beforeY )
			{
				beforeX = x;
				beforeY = y;
				
				dispatchEvent( new RendererEvent( RendererEvent.MOVE ) );
				
				//stage.addEventListener( MouseEvent.CLICK, stage_mouseClickHandler, true, 0, true );
			}
		}

		private function mouseUpHandler( event : MouseEvent ) : void
		{		
			if ( skin.currentState == "multiSelect" && _move )
				dispatchEvent( new RendererEvent ( RendererEvent.MULTI_SELECTED_MOVED ) );
			
			if ( !stage )
				return;
			
			stage.removeEventListener( MouseEvent.MOUSE_MOVE, mouseMoveHandler, true );
			stage.removeEventListener( MouseEvent.MOUSE_UP, mouseUpHandler );

			if ( x != beforeX || y != beforeY )
			{
				beforeX = x;
				beforeY = y;

				dispatchEvent( new RendererEvent( RendererEvent.MOVE ) );

				//stage.addEventListener( MouseEvent.CLICK, stage_mouseClickHandler, true, 0, true );
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
			
			dispatchEvent(new RendererEvent(RendererEvent.ATTRIBUTES_REFRESHED));
			
			if (!renderVO.children || renderVO.children.length == 0)
				invalidateDisplayList();
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

			overflow = OVERFLOW_NONE;
			attributeVO = _renderVO.getAttributeByName( "overflow" );
			if ( attributeVO )
				parseOverflowAttribute(attributeVO.value);
			
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
			else
				SolidColor( backgroundRect.fill ).alpha = 0;
			
			attributeVO = _renderVO.getAttributeByName( "alpha" );
			if ( attributeVO )
				alpha = Number(attributeVO.value);
			else
				alpha = 1;

			attributeVO = _renderVO.getAttributeByName( "bordercolor" );
			if ( attributeVO )
			{
				SolidColorStroke( backgroundRect.stroke ).alpha = 1;
				SolidColorStroke( backgroundRect.stroke ).color = uint( "0x" + attributeVO.value.substr( 1 ) );
				attributeVO = _renderVO.getAttributeByName( "borderwidth" );

				if ( attributeVO )
					SolidColorStroke( backgroundRect.stroke ).weight = uint( attributeVO.value );
			}
			else
				SolidColorStroke( backgroundRect.stroke ).alpha = 0;

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

		private var recalculateSkinMetrics : Boolean;
		private function parseOverflowAttribute (overflow:String) : void
		{
			this.overflow = overflow;
			
			switch (overflow)
			{
				case OVERFLOW_VISIBLE:
				case OVERFLOW_HIDDEN:
					scroller.setStyle("verticalScrollPolicy", ScrollPolicy.OFF);
					scroller.setStyle("horizontalScrollPolicy", ScrollPolicy.OFF);
					break;
				case OVERFLOW_SCROLL:
					scroller.setStyle("verticalScrollPolicy", ScrollPolicy.ON);
					scroller.setStyle("horizontalScrollPolicy", ScrollPolicy.ON);
					break;
				case OVERFLOW_AUTO:
				default:
					scroller.setStyle("verticalScrollPolicy", ScrollPolicy.AUTO);
					scroller.setStyle("horizontalScrollPolicy", ScrollPolicy.AUTO);
					break;
			}
			
			recalculateSkinMetrics = true;
			invalidateDisplayList();
		}
		
		private function refreshContent() : void
		{
			background.removeAllElements();
			
			var contentXMLList : XMLList = _renderVO.content;

			for each ( var contetntPart : XML in contentXMLList )
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
			}
		}

		private function resizePageRenderer(event : Event) : void
		{
			backgroundRefreshNeedFlag = true;
			invalidateDisplayList();
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
		
		public var skinWidth	: Number = 0;
		public var skinHeight	: Number = 0;
		
		private function get maxRightPosition () : Number
		{
			var maxRight : Number = 0;
			
			for each (var child:RenderVO in renderVO.children)
			{
				var attribute : AttributeVO;
				
				attribute = child.getAttributeByName("left");
				var childLeft : Number =  attribute ? Number(attribute.value) : 0;
				
				attribute = child.getAttributeByName("width");
				var childWidth : Number =  attribute ? Number(attribute.value) : 0;
				
				var childRightPosition : Number= childLeft + childWidth;
				
				if (childRightPosition > maxRight)
					maxRight = childRightPosition;
			}
			
			return maxRight;
		}
		
		private function get maxBottomPosition () : Number
		{
			var maxBottom : Number = 0;
			
			for each (var child:RenderVO in renderVO.children)
			{
				var attribute : AttributeVO;
				
				attribute = child.getAttributeByName("top");
				var childTop : Number =  attribute ? Number(attribute.value) : 0;
				
				attribute = child.getAttributeByName("height");
				var childHeight : Number =  attribute ? Number(attribute.value) : 0;
				
				var childBottomPosition : Number= childTop + childHeight;
				
				if (childBottomPosition > maxBottom)
					maxBottom = childBottomPosition;
			}
			
			return maxBottom;
		}
		
		protected function refreshSkinMetrics():void
		{				
			if (overflow != OVERFLOW_VISIBLE)
				return;
			
			if (background.numChildren == 0)
				return;
			
			var sizeChanged : Boolean = false;
			
			if (skinWidth < width) skinWidth = width;
			if (skinHeight < height) skinHeight = height;
			
			var maxRightPos : Number = maxRightPosition;
			var maxBottomPos : Number = maxBottomPosition;
			
			if (skinWidth != maxRightPos || skinHeight != maxBottomPos)
				sizeChanged = true;
			
			skinWidth = maxRightPos;
			skinHeight = maxBottomPos;
			
			if (sizeChanged)
				invalidateDisplayList();
		}
		
		public function refreshOnChildTransform (child : RendererBase, maxRightPos:Number, maxBottomPos:Number) : void
		{
			if (overflow != OVERFLOW_VISIBLE)
				return;
			
			var childRightPosition:Number = child.x + child.width; 
			var childBottomPosition:Number = child.y + child.height;
			
			if (childRightPosition > skinWidth || childRightPosition > maxRightPos)
				skinWidth = childRightPosition;
			else
				skinWidth = maxRightPos;
				
			if (childBottomPosition > skinHeight || childBottomPosition > maxBottomPos)
				skinHeight = childBottomPosition;
			else
				skinHeight = maxBottomPos;
			
			invalidateDisplayList();
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			if (overflow == OVERFLOW_NONE)
				return;
			
			if (overflow != OVERFLOW_VISIBLE)
			{
				skin.width = width;
				skin.height = height;
				return;
			}
			
			if (recalculateSkinMetrics)
			{
				recalculateSkinMetrics = false;
				refreshSkinMetrics();
			}
			
			if (skinWidth < width) skinWidth = width;
			if (skinHeight < height) skinHeight = height;
			
			skin.width = skinWidth;
			skin.height = skinHeight;
		}
		
	}
}

