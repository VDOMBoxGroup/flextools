package net.vdombox.ide.modules.wysiwyg.view
{
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	import flash.utils.getQualifiedClassName;
	
	import mx.collections.ArrayList;
	import mx.controls.CheckBox;
	import mx.core.UIComponent;
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	import mx.graphics.SolidColorStroke;
	import mx.resources.ResourceManager;
	import mx.utils.ObjectUtil;
	
	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.common.interfaces.IVDOMObjectVO;
	import net.vdombox.ide.common.model.StatesProxy;
	import net.vdombox.ide.common.model._vo.AttributeVO;
	import net.vdombox.ide.common.model._vo.ObjectVO;
	import net.vdombox.ide.common.model._vo.PageVO;
	import net.vdombox.ide.common.model._vo.VdomObjectAttributesVO;
	import net.vdombox.ide.common.model._vo.VdomObjectXMLPresentationVO;
	import net.vdombox.ide.common.view.components.VDOMImage;
	import net.vdombox.ide.common.view.components.button.AlertButton;
	import net.vdombox.ide.common.view.components.windows.Alert;
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	import net.vdombox.ide.modules.wysiwyg.events.EditorEvent;
	import net.vdombox.ide.modules.wysiwyg.events.RendererDropEvent;
	import net.vdombox.ide.modules.wysiwyg.events.RendererEvent;
	import net.vdombox.ide.modules.wysiwyg.events.SkinPartEvent;
	import net.vdombox.ide.modules.wysiwyg.interfaces.IEditor;
	import net.vdombox.ide.modules.wysiwyg.interfaces.IRenderer;
	import net.vdombox.ide.modules.wysiwyg.model.RenderProxy;
	import net.vdombox.ide.modules.wysiwyg.model.SettingsApplicationProxy;
	import net.vdombox.ide.modules.wysiwyg.model.vo.EditorVO;
	import net.vdombox.ide.modules.wysiwyg.model.vo.LineVO;
	import net.vdombox.ide.modules.wysiwyg.model.vo.RenderVO;
	import net.vdombox.ide.modules.wysiwyg.utils.DisplayUtils;
	import net.vdombox.ide.modules.wysiwyg.view.components.PageRenderer;
	import net.vdombox.ide.modules.wysiwyg.view.components.RendererBase;
	import net.vdombox.ide.modules.wysiwyg.view.components.TransformMarker;
	import net.vdombox.ide.modules.wysiwyg.view.components.VdomObjectEditor;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	import spark.components.Application;
	import spark.primitives.Line;
	import spark.primitives.Rect;


	/**
	 * 
	 * @author andreev ap
	 */
	public class VdomObjectEditorMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "VdomObjectEditorMediator";

		public static var instancesNameList : Object = {};
		
		private var selectPage : IVDOMObjectVO;
		private var rendProxy : RenderProxy;
		private var pageRender : PageRenderer;

		public function VdomObjectEditorMediator( editor : IEditor )
		{
			var instanceName : String = NAME + "/" + editor.editorVO.vdomObjectVO.id;

			super( instanceName, editor );

			instancesNameList[ instanceName ] = true;
		}

		private var statesProxy : StatesProxy;
		
		private var sharedObjectProxy : SettingsApplicationProxy;
		
		public function get component() : VdomObjectEditor
		{
			return viewComponent as VdomObjectEditor;
		}

		public function get editor() : IEditor
		{
			return viewComponent as IEditor;
		}

		public function get editorVO() : EditorVO
		{
			return editor ? editor.editorVO : null;
		}

		public function get vdomObjectXMLPresentationVO() : VdomObjectXMLPresentationVO
		{
			return editor.xmlPresentation;
		}
		
		public function set vdomObjectXMLPresentationVO( value : VdomObjectXMLPresentationVO ) : void
		{
			editor.xmlPresentation = value;
		}


		override public function onRegister() : void
		{
			statesProxy = facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;
			
			rendProxy = facade.retrieveProxy( RenderProxy.NAME ) as RenderProxy;
			
			sharedObjectProxy = facade.retrieveProxy( SettingsApplicationProxy.NAME ) as SettingsApplicationProxy;

			addHandlers();
		}

		override public function onRemove() : void
		{
			removeHandlers();

			clearData();

			statesProxy = null;
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( Notifications.BODY_STOP );

			interests.push( Notifications.XML_PRESENTATION_GETTED );

			interests.push( StatesProxy.SELECTED_OBJECT_CHANGED );

			interests.push( Notifications.XML_PRESENTATION_SETTED );
			
			interests.push( Notifications.LINE_LIST_GETTED );
			
			interests.push( Notifications.PAGE_STRUCTURE_GETTED );
			
			return interests;
		}
		
		private var listStates : Array = new Array();
		
		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();

			var pageXML : XML;
			
			var editor : IEditor = viewComponent as IEditor;
			

			switch ( name )
			{
				case Notifications.BODY_STOP:
				{
					clearData();

					break;
				}

				case StatesProxy.SELECTED_OBJECT_CHANGED:
				{
					//  set transformMarker to selected page
					var selectedPage : IVDOMObjectVO = statesProxy.selectedPage as IVDOMObjectVO;
					var selectedObject : IVDOMObjectVO = statesProxy.selectedObject as IVDOMObjectVO;
					var selRenderer : RendererBase;

					if ( !selectedPage )
						break;


					if ( selectedPage.id != editor.editorVO.vdomObjectVO.id )
						break;

					if ( editor.state.substr( 0, 7 ) == "wysiwyg")
					{
						var renderProxy : RenderProxy = facade.retrieveProxy( RenderProxy.NAME ) as RenderProxy;
						if ( selectedObject )
						{
							var renderers : Array = renderProxy.getRenderersByVO( selectedObject );

							// find nesesary renderer

							for each ( var renderer : RendererBase in renderers )
							{
								if ( renderer.renderVO.vdomObjectVO.id == selectedObject.id )
								{
									selRenderer = renderer;
									break;
								}
							}
						}
						// mark object
						
						
						if ( selRenderer && visibleOnStage( selRenderer ) )
							editor.selectedRenderer = selRenderer;
						else
							editor.selectedRenderer = null;
						
						if (editor.selectedRenderer != null)
							editor.selectedRenderer.setFocus();
							
					}
					else if (editor.state.substr( 0, 3 ) == "xml")
					{
						if (selectedObject == null)
							sendNotification( Notifications.GET_XML_PRESENTATION, { pageVO: editor.editorVO.vdomObjectVO } );
						else
							sendNotification( Notifications.GET_XML_PRESENTATION, { objectVO: selectedObject } );
					}

					break;
				}

				case Notifications.XML_PRESENTATION_SETTED:
				{
//					if ( editor.vdomObjectVO && body.hasOwnProperty( "pageVO" ) && body.pageVO && body.pageVO.id == editor.vdomObjectVO.id )
//					{
//						editor.status = PageEditor.STATUS_SAVING_OK;
//					}
					
					break;
				}
					
				case Notifications.LINE_LIST_GETTED:
				{			
					drawLine( body );
					break;
				}
					
				case Notifications.PAGE_STRUCTURE_GETTED:
				{
					var pageXMLTree : XML = notification.getBody() as XML;
					var selectedPageVO : PageVO = statesProxy.selectedPage as PageVO;
					break;
				}
					
			}
		}
		
		
		/**
		 * Whether or not the display object or his parent is visible. Display objects that are not visible are disabled.
		 *	For example, if self or pernt visible=false   for an InteractiveObject instance, it cannot be selected. 
		 * 
		 * @param render
		 * @return 
		 */
		private function visibleOnStage( render : RendererBase ) : Boolean
		{
			if ( !render.visible )
				return false;
			
			var parentRenderer : RendererBase; 
			var renderers : Array ;

			var renderProxy : RenderProxy;
			var parentRenderVO : RenderVO;
			
			if ( !render.renderVO )
			{
				trace("\nERROR: render has not renderVO !")
				return true;
			}
			
			parentRenderVO = render.renderVO.parent;
			
			// it is top item, can not by invisible
			if ( !parentRenderVO )
				return true;
			
			renderProxy  = facade.retrieveProxy( RenderProxy.NAME ) as RenderProxy;
			parentRenderer  = renderProxy.getRendererByVO( parentRenderVO.vdomObjectVO );
			
			// it is top item, can not by invisible
			if ( !parentRenderer )
				return true;

			// this render is visible and has parent, need chek parent render.
			return visibleOnStage( parentRenderer );
			
		}
		
		private function drawLine( body : Object ) : void
		{
			var selectedPage : IVDOMObjectVO = statesProxy.selectedPage as IVDOMObjectVO;
			if ( !selectedPage )
				return;		
			
			if ( selectedPage.id != editor.editorVO.vdomObjectVO.id )
				return;
			
			for ( var i : int = 0; i < listStates.length; i++ )
			{
				listStates[i].setState = "normal";
			}
			
			var listLines : Array = body.listLines as Array;
			var element : UIComponent = body.component as UIComponent;
			var lineVO : LineVO;
			var line : Line;
			
			selectPage = statesProxy.selectedPage as IVDOMObjectVO;
			pageRender = rendProxy.getRenderersByVO( selectPage )[0] as PageRenderer;
			pageRender.linegroup.removeAllElements();
			
			var strokeColor : SolidColorStroke = new SolidColorStroke();
			strokeColor.color = 0x0000FF;
			strokeColor.weight = 1;
			
			var stepX : Number = body.stepX as Number;
			var stepY : Number = body.stepY as Number;
			
			if ( listLines.length == 0 )
				return;
			
			if ( element is TransformMarker )
			{
				var marker : TransformMarker = element as TransformMarker;
				if ( marker.equallySize( element.measuredWidth, element.measuredHeight ) )
				{
					var _renderer : RendererBase = marker.renderer as RendererBase;
					_renderer.x -= stepX;
					_renderer.y -= stepY;
					element.x -= stepX;
					element.y -= stepY;
					
					needDrawVLine = true;
					needDrawHLine = true;
				}
				else
				{
					//var marker : TransformMarker = element as TransformMarker;
					var rend : RendererBase;
					var point : Point = new Point( element.x, element.y );
					if ( marker.renderer.renderVO.parent )
					{
						rend = rendProxy.getRendererByVO( marker.renderer.renderVO.parent.vdomObjectVO ) as RendererBase;
						
						point =  DisplayUtils.getConvertedPoint( element, rend.dataGroup );
					}
					
					var needDrawHLine : Boolean = false;
					var needDrawVLine : Boolean = false;
					
					
					if ( marker.equallyPoint( point.x, point.y ) )
					{
						if ( !marker.equallyWidth( element.measuredWidth) )
						{
							element.measuredWidth = element.measuredWidth - stepX;
							needDrawVLine = true;
						}
						if ( !marker.equallyHeight( element.measuredHeight) )
						{
							element.measuredHeight = element.measuredHeight - stepY;
							needDrawHLine = true;
						}
						
					}
					else
					{
						if ( marker.equallySize( element.measuredWidth, element.measuredHeight ) )
						{
							element.x = element.x - stepX;
							element.y = element.y - stepY;
							var _renderer2 : RendererBase = marker.renderer as RendererBase;
							_renderer2.x -= stepX;
							_renderer2.y -= stepY;
						}
						else
						{
							if ( !marker.equallyX( point.x ) )
							{
								element.x = element.x - stepX;
								element.measuredWidth = element.measuredWidth + stepX;
							}
							else if ( !marker.equallyWidth( element.measuredWidth) )
							{
								element.measuredWidth = element.measuredWidth - stepX;
							}
							
							if ( !marker.equallyY( point.y ) )
							{
								element.y = element.y - stepY;
								element.measuredHeight = element.measuredHeight + stepY;
							}
							else if ( !marker.equallyHeight( element.measuredHeight) )
							{
								element.measuredHeight = element.measuredHeight - stepY;
							}
							
							if ( stepX != 0 )
								needDrawVLine = true;
							
							if ( stepY != 0 )
								needDrawHLine = true;
						}
					}
				}
			}
			else
			{
				element.x -= stepX;
				element.y -= stepY;
			}
			
			listStates = new Array();
			var step : Number = 15;
			var delta : Number = 7;
			
			for each ( lineVO in listLines )
			{
				
				listStates.push( lineVO.renderTo );
				if (lineVO.type == 0)
				{					
					if ( element is TransformMarker )
						if ( !lineVO.orientationH && !needDrawVLine 
						 || lineVO.orientationH && !needDrawHLine )
							continue;
					
					line = new Line();
					if ( lineVO.orientationH )
					{
						line.xFrom = lineVO.x1 - stepX;
						line.yFrom = lineVO.y1;
					}
					else
					{
						line.xFrom = lineVO.x1;
						line.yFrom = lineVO.y1 - stepY;
					}
					line.xTo = lineVO.x2;
					line.yTo = lineVO.y2;
					lineVO.renderTo.setState = "select";
					line.stroke = strokeColor;
					pageRender.linegroup.addElement( line );
				}
				else
				{
					if ( element is TransformMarker && !marker.equallySize( element.measuredWidth, element.measuredHeight ) )
						continue;
					if ( !lineVO.orientationH )
					{
						var y1 : Number = lineVO.y1;
						var y2 : Number = lineVO.y2;
						if ( y1 < y2 )
						{
							for ( y1 -= stepY; y1 < y2; y1 += step + delta)
							{
								line = new Line();
								line.xFrom = lineVO.x2;
								line.yFrom = y1;
								line.xTo = lineVO.x2;
								if ( y1 < (y2 - step - delta))
									line.yTo = y1 + step;
								else
									line.yTo = y2;
								line.stroke = strokeColor;
								pageRender.linegroup.addElement( line );
							}
						}
						else
						{
							for ( y1 -= stepY; y2 < y1; y1 -= step + delta)
							{
								line = new Line();
								line.xFrom = lineVO.x2;
								line.yFrom = y1;
								line.xTo = lineVO.x2;
								if ( y1 > (y2 + step + delta))
									line.yTo = y1 - step;
								else
									line.yTo = y2;
								line.stroke = strokeColor;
								pageRender.linegroup.addElement( line );
							}
						}
						
						
						
					}
					else
					{
						var x1 : Number = lineVO.x1;
						var x2 : Number = lineVO.x2;
						if ( x1 < x2 )
						{
							for ( x1 -= stepX ; x1 < x2; x1 += step + delta)
							{
								line = new Line();
								line.xFrom = x1;
								line.yFrom = lineVO.y2;
								if ( x1 < (x2 - step - delta))
									line.xTo = x1 + step;
								else
									line.xTo = x2;
								line.yTo = lineVO.y2;
								line.stroke = strokeColor;
								pageRender.linegroup.addElement( line );
							}
						}
						else
						{
							for ( x1 -= stepX; x2 < x1; x1 -= step + delta)
							{
								line = new Line();
								line.xFrom = x1;
								line.yFrom = lineVO.y2;
								if ( x1 > (x2 + step + delta))
									line.xTo = x1 - step;
								else
									line.xTo = x2;
								line.yTo = lineVO.y2;
								line.stroke = strokeColor;
								pageRender.linegroup.addElement( line );
							}
						}
					}
					
					lineVO.renderTo.setState = "select";
				}
			}
		}
		
		
		// TODO: rename function
		private function writeLinkage( event : Event ) :void
		{
			component.showLinking = sharedObjectProxy.showLinking;
		}
		
		private function readLinkage( event : Event = null ) :void
		{
			sharedObjectProxy.showLinking = component.showLinking;
		}

		private function addHandlers() : void
		{
			var editor : IEventDispatcher = editor as IEventDispatcher;

			if ( !editor )
				return;
			editor.addEventListener( FlexEvent.HIDE, hideRendererHandler, true );
			
			editor.addEventListener( FlexEvent.SHOW, showRendererHandler, true );
			
			editor.addEventListener( "deleteObjectOnScreen", keyDownDeleteHandler, true );
			
			editor.addEventListener( RendererEvent.CLEAR_RENDERER, clearLineGroup, true );
			
			editor.addEventListener( RendererEvent.MOVE_MEDIATOR, moveRendererHandler, true );
			
			editor.addEventListener( RendererEvent.MOUSE_UP_MEDIATOR, clearLineGroup, true);
			
			component.addEventListener( MouseEvent.MOUSE_UP, clearLineGroup, true);

			editor.addEventListener( Event.REMOVED_FROM_STAGE, removedFromStageHandler, false, 0, true );

			editor.addEventListener( SkinPartEvent.PART_ADDED, partAddedHandler, false, 0, true );
			editor.addEventListener( EditorEvent.WYSIWYG_OPENED, partOpenedHandler, false, 0, true );
			editor.addEventListener( EditorEvent.XML_EDITOR_OPENED, partOpenedHandler, false, 0, true );

			editor.addEventListener( EditorEvent.XML_SAVE, xmlSaveHandler, false, 0, true );

			editor.addEventListener( EditorEvent.VDOM_OBJECT_VO_CHANGED, vdomObjectVOChangedHandler, false, 0, true );

			editor.addEventListener( EditorEvent.RENDERER_TRANSFORMED, rendererTransformedHandler, false, 0, true );

			editor.addEventListener( RendererEvent.CREATED, renderer_createdHandler, true, 0, true );
			editor.addEventListener( RendererEvent.REMOVED, renderer_removedHandler, true, 0 , true );
			editor.addEventListener( RendererEvent.CLICKED, renderer_clickedHandler, true, 0, true );
			
			editor.addEventListener( RendererEvent.MOUSE_DOWN, renderer_DownHandler, true, 0, true );
			
			editor.addEventListener( RendererEvent.MULTI_SELECTED_MOVE, renderer_multiSelectedMoveHandler, true, 0, true );
			editor.addEventListener( RendererEvent.MULTI_SELECTED_MOVED, renderer_multiSelectedMovedHandler, true, 0, true );
			
			editor.addEventListener( RendererEvent.PASTE_SELECTED, renderer_pasteHandler, true, 0, true );

			editor.addEventListener( RendererEvent.GET_RESOURCE, renderer_getResourseHandler, true, 0, true );

			editor.addEventListener( RendererDropEvent.DROP, renderer_dropHandler, true, 0, true );

			editor.addEventListener( EditorEvent.ATTRIBUTES_CHANGED, attributesChangeHandler, true, 0, true );
			
			component.addEventListener( FlexEvent.CREATION_COMPLETE, writeLinkage, true );
			
			component.addEventListener( KeyboardEvent.KEY_DOWN, keyHandler, true, 0 ,true );
			
			component.addEventListener( Event.CHANGE, readLinkage);
		}

		private function removeHandlers() : void
		{
			var editor : IEventDispatcher = editor as IEventDispatcher;

			if ( !editor )
				return;

			editor.removeEventListener( FlexEvent.HIDE, hideRendererHandler, true );
			editor.removeEventListener( FlexEvent.SHOW, showRendererHandler, true );
			editor.removeEventListener( Event.REMOVED_FROM_STAGE, removedFromStageHandler );
			
			editor.removeEventListener( RendererEvent.MOVE_MEDIATOR, moveRendererHandler, true);
			editor.removeEventListener( RendererEvent.MOUSE_UP_MEDIATOR, clearLineGroup, true);
			
			component.removeEventListener( MouseEvent.MOUSE_UP, clearLineGroup, true);
			
			editor.removeEventListener( "deleteObjectOnScreen", keyDownDeleteHandler, true);
			editor.removeEventListener( RendererEvent.CLEAR_RENDERER, clearLineGroup, true );

			editor.removeEventListener( SkinPartEvent.PART_ADDED, partAddedHandler );
			editor.removeEventListener( EditorEvent.WYSIWYG_OPENED, partOpenedHandler );
			editor.removeEventListener( EditorEvent.XML_EDITOR_OPENED, partOpenedHandler );

			editor.removeEventListener( EditorEvent.XML_SAVE, xmlSaveHandler );

			editor.removeEventListener( EditorEvent.VDOM_OBJECT_VO_CHANGED, vdomObjectVOChangedHandler );

			editor.removeEventListener( EditorEvent.RENDERER_TRANSFORMED, rendererTransformedHandler );

			editor.removeEventListener( RendererEvent.CREATED, renderer_createdHandler, true );
			editor.removeEventListener( RendererEvent.REMOVED, renderer_removedHandler, true );
			editor.removeEventListener( RendererEvent.CLICKED, renderer_clickedHandler, true );
			
			editor.removeEventListener( RendererEvent.PASTE_SELECTED, renderer_pasteHandler, true );

			editor.removeEventListener( RendererDropEvent.DROP, renderer_dropHandler, true );

			editor.removeEventListener( EditorEvent.ATTRIBUTES_CHANGED, attributesChangeHandler, true );

			editor.removeEventListener( RendererEvent.GET_RESOURCE, renderer_getResourseHandler, true );
			
			component.removeEventListener( FlexEvent.CREATION_COMPLETE, writeLinkage, true );
			
			component.removeEventListener( KeyboardEvent.KEY_DOWN, keyHandler, true );
			
			component.removeEventListener( Event.CHANGE, readLinkage);
		}
		
		private function hideRendererHandler ( event : FlexEvent ) : void
		{
			var _renderer : RendererBase = event.target as RendererBase;
			if ( _renderer == editor.selectedRenderer || editor.selectedRenderer && !visibleOnStage( editor.selectedRenderer as RendererBase) )
				editor.selectedRenderer = null;
			if ( _renderer )
				clearLineGroup();
		}
		
		
		private function showRendererHandler ( event : FlexEvent ) : void
		{
			var renderProxy : RenderProxy;
			var _renderer : RendererBase = event.target as RendererBase;
			
			if ( !_renderer )
				return;
			
			renderProxy  = facade.retrieveProxy( RenderProxy.NAME ) as RenderProxy;
			
			if ( !statesProxy.selectedObject )
				return;
			
			if ( _renderer.renderVO.vdomObjectVO.id != statesProxy.selectedObject.id )
				return;
			
			if ( !visibleOnStage( _renderer ) )
				return;
			
			editor.selectedRenderer = _renderer;
		}
		
		private function clearLineGroup ( event : Event = null ) : void
		{
			var selectPage : IVDOMObjectVO = statesProxy.selectedPage as IVDOMObjectVO;
			var rendProxy : RenderProxy = facade.retrieveProxy( RenderProxy.NAME ) as RenderProxy;
			
			var pageRender : PageRenderer = rendProxy.getRendererByVO( selectPage ) as PageRenderer;
			
			if ( !pageRender )
				return;
			
			pageRender.linegroup.removeAllElements();
			
			for ( var i : int = 0; i < listStates.length; i++ )
			{
				listStates[i].setState = "normal";
			}
			listStates = [];
		}
		
		private function moveRendererHandler ( event : RendererEvent ) : void
		{
			if ( component.showLinking )
				sendNotification( Notifications.OBJECT_MOVED, { component : event.target, ctrlKey : event.ctrlKey } );
		}
		
		private function keyDownDeleteHandler(event : KeyboardEvent) : void
		{
			var arr : Array = new Array();
			
			if ( multiSelectRenderers )
			{
				for each ( var renderer : RendererBase in multiSelectRenderers )
					arr.push( renderer.vdomObjectVO );
				
				Alert.setPatametrs( "Delete", "Cancel", VDOMImage.Delete );
				Alert.Show( ResourceManager.getInstance().getString( 'Wysiwyg_General', 'delete_Renderer' ) + arr.length.toString() + " elements ?",AlertButton.OK_No, component.parentApplication, closeHandler);
			}
			else if ( statesProxy.selectedObject != null)
			{
				var componentName : String = statesProxy.selectedObject.typeVO.displayName;
				
				Alert.setPatametrs( "Delete", "Cancel", VDOMImage.Delete );
				
				Alert.Show( ResourceManager.getInstance().getString( 'Wysiwyg_General', 'delete_Renderer' ) + componentName + " ?",AlertButton.OK_No, component.parentApplication, closeHandler);
			}
			
			function closeHandler(event : CloseEvent) : void
			{
				if (event.detail == Alert.YES)
				{
					if ( multiSelectRenderers )
						sendNotification( Notifications.DELETE_OBJECT, { pageVO: statesProxy.selectedPage, objectVO: arr } );
					else if ( statesProxy.selectedPage && statesProxy.selectedObject )
						sendNotification( Notifications.DELETE_OBJECT, { pageVO: statesProxy.selectedPage, objectVO: statesProxy.selectedObject } );
				}
			}
		}
		
		private function clearData() : void
		{
			editor.editorVO.vdomObjectVO = null;
		}

		private function removedFromStageHandler( event : Event ) : void
		{
			
			//for each( var render : RenderVO in editor.editorVO.renderVO.children )
			//editor.editorVO.renderVO.children.splice(); 
			
			
			
				
			/*for each ( var render : RenderVO in editorVO.renderVO.children )
			{
				sendNotification( Notifications.RENDERER_REMOVED, render );	
			}
			
			editorVO.renderVO.children.splice( 0, editorVO.renderVO.children.length );
				
			sendNotification( Notifications.RENDERER_REMOVED, editorVO.renderVO );	*/
			
			facade.removeMediator( mediatorName );
			delete instancesNameList[ mediatorName ];
			
			
		}

		private function partAddedHandler( event : SkinPartEvent ) : void
		{
		}

		private function partOpenedHandler( event : EditorEvent ) : void
		{
			if ( event.type == EditorEvent.WYSIWYG_OPENED && editor.editorVO.vdomObjectVO )
				sendNotification( Notifications.GET_WYSIWYG, editor.editorVO.vdomObjectVO );
			else if ( event.type == EditorEvent.XML_EDITOR_OPENED )
			{
				var selectedPage : IVDOMObjectVO = statesProxy.selectedPage as IVDOMObjectVO;
				var selectedObject : IVDOMObjectVO = statesProxy.selectedObject as IVDOMObjectVO;
				
				if (selectedObject == null)
					sendNotification( Notifications.GET_XML_PRESENTATION, { pageVO: editor.editorVO.vdomObjectVO } );
				else
					sendNotification( Notifications.GET_XML_PRESENTATION, { objectVO: selectedObject } );
			}
		}

		private function xmlSaveHandler( event : EditorEvent ) : void
		{
			editor.status = VdomObjectEditor.STATUS_SAVING;
			sendNotification( Notifications.SET_XML_PRESENTATION, editor.xmlPresentation );
		}

		private function vdomObjectVOChangedHandler( event : EditorEvent ) : void
		{
			if ( editor.editorVO.vdomObjectVO )
			{
				sendNotification( Notifications.GET_WYSIWYG, editor.editorVO.vdomObjectVO );
			}
		}

		private function renderer_createdHandler( event : RendererEvent ) : void
		{
			sendNotification( Notifications.RENDERER_CREATED, event.target as IRenderer );
		}

		private function renderer_removedHandler( event : RendererEvent ) : void
		{
			sendNotification( Notifications.RENDERER_REMOVED, event.target as IRenderer );
		}
		
		private var multiSelectRenderers : Object;
		private var addInMultiSelect : String;
		private var deleteInMultiSelect : String;

		private function renderer_clickedHandler( event : RendererEvent ) : void
		{
			var target : RendererBase = event.target as RendererBase;
			
			var renderer : RendererBase;
			
			if (  target.getState == "multiSelect" )
			{
				if ( target.vdomObjectVO.id == deleteInMultiSelect )
				{
					target.setState = "normal";
					delete multiSelectRenderers[ deleteInMultiSelect ];
					
					if ( multiSelectRenderers )
					{
						for each ( renderer in multiSelectRenderers )
						{
							renderer.setFocus();
							break;
						}
					}
					
					if ( !renderer )
					{
						if ( statesProxy.selectedObject )
						{
							renderer = rendProxy.getRendererByVO( statesProxy.selectedObject );
							
							renderer.setFocus();
						}
						else if ( statesProxy.selectedPage )
						{
							renderer = rendProxy.getRendererByVO( statesProxy.selectedPage );
							
							renderer.setFocus();
						}
					}
					
					deleteInMultiSelect = "";
					
					return;
				}
				else if (  target.vdomObjectVO.id == addInMultiSelect )
				{
					addInMultiSelect = "";
					
					return;
				}
			}
			
			if ( multiSelectRenderers )
			{
				for each ( renderer in multiSelectRenderers )
				{
					renderer.setState = "normal";
				}
				
				multiSelectRenderers = null;
			}
			
			sendNotification( Notifications.RENDERER_CLICKED, target as IRenderer );
			
			
		}
		
		private function renderer_DownHandler( event : RendererEvent ) : void
		{
			var target : RendererBase = event.target as RendererBase;
			
			if ( target is PageRenderer )
				return;
			
			
			if ( target.getState == "multiSelect" )
			{
				deleteInMultiSelect = target.vdomObjectVO.id;
			}
			else
			{
				target.setFocus();
				target.setState = "multiSelect";
				if ( !multiSelectRenderers )
				{
					multiSelectRenderers = [];
					
					if ( statesProxy.selectedObject )
					{
						var targetTemp : RendererBase = rendProxy.getRendererByVO( statesProxy.selectedObject );
						targetTemp.setState = "multiSelect";
						multiSelectRenderers[ statesProxy.selectedObject.id ] = targetTemp;
						
						sendNotification( ApplicationFacade.MULTI_SELECT_START );
						sendNotification( Notifications.RENDERER_CLICKED, rendProxy.getRendererByVO( statesProxy.selectedPage ) );
					}
					
				}
				
				addInMultiSelect = target.vdomObjectVO.id;
				multiSelectRenderers[ target.vdomObjectVO.id ] = target ;
			}
		}
		
		private function renderer_multiSelectedMovedHandler( event : RendererEvent ) : void
		{
			var renderer : RendererBase;
			
			for each ( renderer in multiSelectRenderers )
			{
				renderer.savePosition();
			}
		}
		
		private function renderer_multiSelectedMoveHandler( event : RendererEvent ) : void
		{
			if ( !multiSelectRenderers )
				return;
			
			var dx : int = event.object.dx;
			var dy : int = event.object.dy;
			
			var renderer : RendererBase;
			
			for each ( renderer in multiSelectRenderers )
			{
				if ( !renderer.hasMoved( dx, dy ) )
					return;
			}
			
			for each ( renderer in multiSelectRenderers )
			{
				renderer.moveRenderer( dx, dy );
			}
		}
		
		private function renderer_pasteHandler( event : RendererEvent ) : void
		{
			var rend : RendererBase = event.target as RendererBase;
			
			if ( !rend )
				return;
			
			var sourceID : String = Clipboard.generalClipboard.getData( ClipboardFormats.TEXT_FORMAT ) as String;
			var sourceInfo : Array = sourceID.split( " " );
			if ( sourceInfo.length != 4 || sourceInfo[0] != "Vlt+VDOMIDE2+" )
				return;
			
			var sourceAppId : String = sourceInfo[1] as String;
			var sourceObjId : String = sourceInfo[2] as String;
			var typeObject : String = sourceInfo[3] as String;
				
			var object : IVDOMObjectVO = rend.vdomObjectVO;
			if ( object is ObjectVO && 
				(rend.typeVO.container != 2 || rend.typeVO.container == 2 && sourceObjId == object.id ) && rend.renderVO.parent )
				object = rend.renderVO.parent.vdomObjectVO;
			
			if ( typeObject == "1" )
				sendNotification( Notifications.COPY_REQUEST, { applicationVO : statesProxy.selectedApplication, sourceID : sourceID } );
			else if ( object is PageVO )
				sendNotification( Notifications.COPY_REQUEST, { pageVO : object, sourceID : sourceID } );
			else if ( object is ObjectVO )
				sendNotification( Notifications.COPY_REQUEST, {  objectVO : object, sourceID : sourceID } );
		}

		private function renderer_getResourseHandler( event : RendererEvent ) : void
		{
			sendNotification( Notifications.GET_RESOURCE_REQUEST, event.object );
		}

		private function renderer_dropHandler( event : RendererDropEvent ) : void
		{
			sendNotification( Notifications.CREATE_OBJECT_REQUEST, { vdomObjectVO: ( event.target as IRenderer ).vdomObjectVO, typeVO: event.typeVO, point: event.point } )
		}

		private function rendererTransformedHandler( event : EditorEvent ) : void
		{
			var attributeVO : AttributeVO;
			var attributeName : String;
			var attributeValue : String;

			var attributes : Array = [];
			var vdomObjectAttributesVO : VdomObjectAttributesVO = new VdomObjectAttributesVO( event.renderer.vdomObjectVO );
			
			var obj : Object = event.renderer.vdomObjectVO;
			
			var renderProxy : RenderProxy = facade.retrieveProxy( RenderProxy.NAME ) as RenderProxy;
			
			var renderer : RendererBase = renderProxy.getRendererByID( obj.id );
			
			var attributesRender : Array = renderer.renderVO.attributes;

			for ( attributeName in event.attributes )
			{
				if ( attributeName == "x" )
				{
					attributeValue = event.attributes[ attributeName ];
					attributeName = "left";
					
					attributeVO = new AttributeVO( attributeName, renderer.beforeLeft.toString() );
				}
				else if ( attributeName == "y" )
				{
					attributeValue = event.attributes[ attributeName ];
					attributeName = "top";
					
					attributeVO = new AttributeVO( attributeName, renderer.beforeTop.toString() );
				}
				else
				{
					for each ( var attrVO : AttributeVO in attributesRender )
					{
						if ( attrVO.name == attributeName )
						{
							attributeVO = attrVO;
						}
					}
					
					attributeValue = event.attributes[ attributeName ];
				}
				
				if ( !attributeVO )
					continue;
				
				attributeVO.value = attributeValue;

				attributes.push( attributeVO );
			}

			vdomObjectAttributesVO.attributes = attributes;

			sendNotification( Notifications.RENDERER_TRANSFORMED, vdomObjectAttributesVO );
			//sendNotification( Notifications.GET_WYSIWYG, vdomObjectAttributesVO.vdomObjectVO );
		}

		private function attributesChangeHandler( event : EditorEvent ) : void
		{

			sendNotification( Notifications.SAVE_ATTRIBUTES_REQUEST, event.vdomObjectAttributesVO );
		}
		
		private function keyHandler( event : KeyboardEvent ) : void
		{
			if ( !component.skin || component.skin.currentState == "xml" || component.skin.currentState == "xmlDisabled" )
				return;
			
			if ( event.keyCode == Keyboard.F5 )
			{
				sendNotification( Notifications.GET_WYSIWYG, statesProxy.selectedPage );
				sendNotification( Notifications.GET_PAGES, statesProxy.selectedApplication );
				
				if ( statesProxy.selectedObject )
					sendNotification( Notifications.GET_OBJECT_ATTRIBUTES, statesProxy.selectedObject );
				else if ( statesProxy.selectedPage )
					sendNotification( Notifications.GET_PAGE_ATTRIBUTES, statesProxy.selectedPage );
			}
			else if ( event.ctrlKey )
			{
				if ( event.keyCode == Keyboard.F )
				{
					if ( !editor.selectedRenderer )
						return;
					
					var render : RendererBase = editor.selectedRenderer as RendererBase;
					
					var point : Point =  DisplayUtils.getConvertedPoint( render, component.renderer.dataGroup );
					
					var needScroll : Boolean = true;
					
					//vertical
					if ( render.height < component.renderer.scroller.height )
					{
						if ( point.y + render.height > component.renderer.scroller.verticalScrollBar.value + component.renderer.scroller.height )
							point.y -= ( component.renderer.scroller.height - render.height);
						else if ( point.y > component.renderer.scroller.verticalScrollBar.value )
							needScroll = false;
					}
					
					if ( point.y < 0 )
						point.y = 0;
					if ( needScroll )
						component.renderer.scroller.verticalScrollBar.value = point.y;
					
					
					//horizontal
					needScroll = true;
					if ( render.width < component.renderer.scroller.width )
					{
						if ( point.x + render.width > component.renderer.scroller.horizontalScrollBar.value + component.renderer.scroller.width )
							point.x -= ( component.renderer.scroller.width - render.width);
						else if ( point.x > component.renderer.scroller.horizontalScrollBar.value )
							needScroll = false;
					}
					
					if ( point.x < 0 )
						point.x = 0;
					
					if ( needScroll )
						component.renderer.scroller.horizontalScrollBar.value = point.x;
				}
				else if ( event.keyCode == Keyboard.D )
				{
					component.showLinking = !component.showLinking;
					readLinkage();
				}
				else if ( event.keyCode == Keyboard.Z )
					sendNotification( Notifications.UNDO, component.editorVO.vdomObjectVO );
				else if ( event.keyCode == Keyboard.Y )
					sendNotification( Notifications.REDO, component.editorVO.vdomObjectVO );
			}
			
		}
	}
}
