package net.vdombox.ide.modules.wysiwyg.view
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import mx.collections.ArrayList;
	import mx.core.UIComponent;
	import mx.events.CloseEvent;
	import mx.graphics.SolidColorStroke;
	
	import net.vdombox.ide.common.interfaces.IVDOMObjectVO;
	import net.vdombox.ide.common.vo.AttributeVO;
	import net.vdombox.ide.common.vo.ObjectVO;
	import net.vdombox.ide.common.vo.VdomObjectAttributesVO;
	import net.vdombox.ide.common.vo.VdomObjectXMLPresentationVO;
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	import net.vdombox.ide.modules.wysiwyg.events.EditorEvent;
	import net.vdombox.ide.modules.wysiwyg.events.RendererDropEvent;
	import net.vdombox.ide.modules.wysiwyg.events.RendererEvent;
	import net.vdombox.ide.modules.wysiwyg.events.SkinPartEvent;
	import net.vdombox.ide.modules.wysiwyg.interfaces.IEditor;
	import net.vdombox.ide.modules.wysiwyg.interfaces.IRenderer;
	import net.vdombox.ide.modules.wysiwyg.model.RenderProxy;
	import net.vdombox.ide.modules.wysiwyg.model.SessionProxy;
	import net.vdombox.ide.modules.wysiwyg.model.vo.EditorVO;
	import net.vdombox.ide.modules.wysiwyg.model.vo.LineVO;
	import net.vdombox.ide.modules.wysiwyg.view.components.PageRenderer;
	import net.vdombox.ide.modules.wysiwyg.view.components.RendererBase;
	import net.vdombox.ide.modules.wysiwyg.view.components.TransformMarker;
	import net.vdombox.ide.modules.wysiwyg.view.components.VdomObjectEditor;
	import net.vdombox.view.Alert;
	import net.vdombox.view.AlertButton;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	import spark.components.Application;
	import spark.primitives.Line;


	public class VdomObjectEditorMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "VdomObjectEditorMediator";

		public static var instancesNameList : Object = {};

		public function VdomObjectEditorMediator( editor : IEditor )
		{
			var instanceName : String = NAME + "/" + editor.editorVO.vdomObjectVO.id;

			super( instanceName, editor );

			instancesNameList[ instanceName ] = true;
		}

		private var sessionProxy : SessionProxy;
		
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
			sessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;

			addHandlers();
		}

		override public function onRemove() : void
		{
			removeHandlers();

			clearData();

			sessionProxy = null;
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( ApplicationFacade.BODY_STOP );

			interests.push( ApplicationFacade.XML_PRESENTATION_GETTED );

			interests.push( ApplicationFacade.SELECTED_OBJECT_CHANGED );

			interests.push( ApplicationFacade.XML_PRESENTATION_SETTED );
			
			interests.push( ApplicationFacade.LINE_LIST_GETTED );

			return interests;
		}
		
		private var listStates : Array = new Array();

		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();

			var pageXML : XML;

			switch ( name )
			{
				case ApplicationFacade.BODY_STOP:
				{
					clearData();

					break;
				}

				case ApplicationFacade.SELECTED_OBJECT_CHANGED:
				{
					//  set transformMarker to selected page

					var editor : IEditor = viewComponent as IEditor;
					var selectedPage : IVDOMObjectVO = sessionProxy.selectedPage as IVDOMObjectVO;
					var selectedObject : IVDOMObjectVO = sessionProxy.selectedObject as IVDOMObjectVO;
					var selRenderer : RendererBase;

					if ( !selectedPage )
						break;


					if ( selectedPage.id != editor.editorVO.vdomObjectVO.id )
						break;

					if ( editor.state.substr( 0, 7 ) == "wysiwyg")
					{
						if ( selectedObject )
						{
							var renderProxy : RenderProxy = facade.retrieveProxy( RenderProxy.NAME ) as RenderProxy;
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
						editor.selectedRenderer = selRenderer;
						if (editor.selectedRenderer != null)
							editor.selectedRenderer.setFocus();
					}
					else if (editor.state.substr( 0, 3 ) == "xml")
					{
						if (selectedObject == null)
							sendNotification( ApplicationFacade.GET_XML_PRESENTATION, { pageVO: editor.editorVO.vdomObjectVO } );
						else
							sendNotification( ApplicationFacade.GET_XML_PRESENTATION, { objectVO: selectedObject } );
					}

					break;
				}

				case ApplicationFacade.XML_PRESENTATION_SETTED:
				{
//					if ( editor.vdomObjectVO && body.hasOwnProperty( "pageVO" ) && body.pageVO && body.pageVO.id == editor.vdomObjectVO.id )
//					{
//						editor.status = PageEditor.STATUS_SAVING_OK;
//					}

					break;
				}
					
				case ApplicationFacade.LINE_LIST_GETTED:
				{
					
					for ( var i : int = 0; i < listStates.length; i++ )
					{
						listStates[i].setState = "normal";
					}
					
					var listLines : Array = body.listLines as Array;
					var component : UIComponent = body.component as UIComponent;
					var lineVO : LineVO;
					var line : Line;
					
					var selectPage : IVDOMObjectVO = sessionProxy.selectedPage as IVDOMObjectVO;
					var rendProxy : RenderProxy = facade.retrieveProxy( RenderProxy.NAME ) as RenderProxy;
					var pageRender : PageRenderer = rendProxy.getRenderersByVO( selectPage )[0] as PageRenderer;
					pageRender.linegroup.removeAllElements();
					
					var strokeColor : SolidColorStroke = new SolidColorStroke();
					strokeColor.color = 0x0000FF;
					strokeColor.weight = 1;
					
					var stepX : Number = body.stepX as Number;
					var stepY : Number = body.stepY as Number;
					
					if ( listLines.length == 0 )
					{
						break;
					}
					
					if ( component is TransformMarker )
					{
						var marker : TransformMarker = component as TransformMarker;
						
						if ( marker.beforeTransform.x == component.x && marker.beforeTransform.y == component.y )
						{
							component.measuredWidth = component.measuredWidth - stepX;
							component.measuredHeight = component.measuredHeight - stepY;

						}
						else
						{
							component.measuredWidth = component.measuredWidth + stepX;
							component.measuredHeight = component.measuredHeight + stepY;
							component.x = component.x - stepX;
							component.y = component.y - stepY;
						}
					}
					else
					{
						component.x = component.x - stepX;
						component.y = component.y - stepY;
					}
					component.dispatchEvent( new RendererEvent( RendererEvent.MOVED ) );
					
					listStates = new Array();
					var step : Number = 15;
					var delta : Number = 7;
					
					for each ( lineVO in listLines)
					{
						listStates.push( lineVO.renderTo );
						if (lineVO.type == 0)
						{
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
							if ( !lineVO.orientationH )
							{
								var y1 : Number = lineVO.y1;
								var y2 : Number = lineVO.y2;
								if ( lineVO.y1 > lineVO.y2 )
								{
									y1 = lineVO.y2;
									y2 = lineVO.y1;
								}
								
								for ( ; y1 < y2; y1 += step + delta)
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
								var x1 : Number = lineVO.x1;
								var x2 : Number = lineVO.x2;
								if ( lineVO.x1 > lineVO.x2 )
								{
									x1 = lineVO.x2;
									x2 = lineVO.x1;
								}
								
								for ( ; x1 < x2; x1 += step + delta)
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
							
							lineVO.renderTo.setState = "select";
						}
					}
					
					break;
				}
			}
		}

		private function addHandlers() : void
		{
			var editor : IEventDispatcher = editor as IEventDispatcher;

			if ( !editor )
				return;
			
			editor.addEventListener( KeyboardEvent.KEY_DOWN, keyDownDeleteHandler, true);
			
			editor.addEventListener( RendererEvent.MOVE_MEDIATOR, moveRendererHandler, true);
			
			editor.addEventListener( RendererEvent.MOUSE_UP_MEDIATOR, mouseUpRendererHandler, true);

			editor.addEventListener( Event.REMOVED_FROM_STAGE, removedFromStageHandler, false, 0, true );

			editor.addEventListener( SkinPartEvent.PART_ADDED, partAddedHandler, false, 0, true );
			editor.addEventListener( EditorEvent.WYSIWYG_OPENED, partOpenedHandler, false, 0, true );
			editor.addEventListener( EditorEvent.XML_EDITOR_OPENED, partOpenedHandler, false, 0, true );

			editor.addEventListener( EditorEvent.XML_SAVE, xmlSaveHandler, false, 0, true );

			editor.addEventListener( EditorEvent.VDOM_OBJECT_VO_CHANGED, vdomObjectVOChangedHandler, false, 0, true );

			editor.addEventListener( EditorEvent.RENDERER_TRANSFORMED, rendererTransformedHandler, false, 0, true );

			editor.addEventListener( RendererEvent.CREATED, renderer_createdHandler, true, 0, true );
			editor.addEventListener( RendererEvent.REMOVED, renderer_removedHandler, true, 0, true );
			editor.addEventListener( RendererEvent.CLICKED, renderer_clickedHandler, true, 0, true );

			editor.addEventListener( RendererEvent.GET_RESOURCE, renderer_getResourseHandler, true, 0, true );

			editor.addEventListener( RendererDropEvent.DROP, renderer_dropHandler, true, 0, true );

			editor.addEventListener( EditorEvent.ATTRIBUTES_CHANGED, attributesChangeHandler, true, 0, true );
		}

		private function removeHandlers() : void
		{
			var editor : IEventDispatcher = editor as IEventDispatcher;

			if ( !editor )
				return;

			editor.removeEventListener( Event.REMOVED_FROM_STAGE, removedFromStageHandler );
			
			editor.removeEventListener( RendererEvent.MOVE_MEDIATOR, moveRendererHandler, true);
			editor.removeEventListener( RendererEvent.MOUSE_UP_MEDIATOR, mouseUpRendererHandler, true);
			
			editor.removeEventListener( KeyboardEvent.KEY_DOWN, keyDownDeleteHandler, true);

			editor.removeEventListener( SkinPartEvent.PART_ADDED, partAddedHandler );
			editor.removeEventListener( EditorEvent.WYSIWYG_OPENED, partOpenedHandler );
			editor.removeEventListener( EditorEvent.XML_EDITOR_OPENED, partOpenedHandler );

			editor.removeEventListener( EditorEvent.XML_SAVE, xmlSaveHandler );

			editor.removeEventListener( EditorEvent.VDOM_OBJECT_VO_CHANGED, vdomObjectVOChangedHandler );

			editor.removeEventListener( EditorEvent.RENDERER_TRANSFORMED, rendererTransformedHandler );

			editor.removeEventListener( RendererEvent.CREATED, renderer_createdHandler, true );
			editor.removeEventListener( RendererEvent.REMOVED, renderer_removedHandler, true );
			editor.removeEventListener( RendererEvent.CLICKED, renderer_clickedHandler, true );

			editor.removeEventListener( RendererDropEvent.DROP, renderer_dropHandler, true );

			editor.removeEventListener( EditorEvent.ATTRIBUTES_CHANGED, attributesChangeHandler, true );

			editor.removeEventListener( RendererEvent.GET_RESOURCE, renderer_getResourseHandler, true );


		}
		
		private function mouseUpRendererHandler ( event : RendererEvent ) : void
		{
			var selectPage : IVDOMObjectVO = sessionProxy.selectedPage as IVDOMObjectVO;
			var rendProxy : RenderProxy = facade.retrieveProxy( RenderProxy.NAME ) as RenderProxy;
			var pageRender : PageRenderer = rendProxy.getRenderersByVO( selectPage )[0] as PageRenderer;
			pageRender.linegroup.removeAllElements();
			
			for ( var i : int = 0; i < listStates.length; i++ )
			{
				listStates[i].setState = "normal";
			}
			listStates = new Array();
		}
		
		private function moveRendererHandler ( event : RendererEvent ) : void
		{
			sendNotification( ApplicationFacade.OBJECT_MOVED, { component : event.target, ctrlKey : event.ctrlKey } );
		}
		
		private function keyDownDeleteHandler(event : KeyboardEvent) : void
		{
			if (event.keyCode == Keyboard.DELETE && sessionProxy.selectedObject != null)
			{
				var componentName : String = sessionProxy.selectedObject.typeVO.displayName;
				
				Alert.noLabel = "Cancel";
				Alert.yesLabel = "Delete";
				
				Alert.Show( "Are you sure want to delete " + componentName + " ?",AlertButton.OK_No, component.parentApplication, closeHandler);
			}
		}

		private function closeHandler(event : CloseEvent) : void
		{
			if (event.detail == Alert.YES)
			{
				if ( sessionProxy.selectedPage && sessionProxy.selectedObject )
					sendNotification( ApplicationFacade.DELETE_OBJECT, { pageVO: sessionProxy.selectedPage, objectVO: sessionProxy.selectedObject } );
			}
		}
		
		private function clearData() : void
		{
			editor.editorVO.vdomObjectVO = null;
		}

		private function removedFromStageHandler( event : Event ) : void
		{
			facade.removeMediator( mediatorName );
			delete instancesNameList[ mediatorName ];
		}

		private function partAddedHandler( event : SkinPartEvent ) : void
		{
		}

		private function partOpenedHandler( event : EditorEvent ) : void
		{
			if ( event.type == EditorEvent.WYSIWYG_OPENED && editor.editorVO.vdomObjectVO )
				sendNotification( ApplicationFacade.GET_WYSIWYG, editor.editorVO.vdomObjectVO );
			else if ( event.type == EditorEvent.XML_EDITOR_OPENED )
			{
				var selectedPage : IVDOMObjectVO = sessionProxy.selectedPage as IVDOMObjectVO;
				var selectedObject : IVDOMObjectVO = sessionProxy.selectedObject as IVDOMObjectVO;
				
				if (selectedObject == null)
					sendNotification( ApplicationFacade.GET_XML_PRESENTATION, { pageVO: editor.editorVO.vdomObjectVO } );
				else
					sendNotification( ApplicationFacade.GET_XML_PRESENTATION, { objectVO: selectedObject } );
			}
		}

		private function xmlSaveHandler( event : EditorEvent ) : void
		{
			editor.status = VdomObjectEditor.STATUS_SAVING;
			sendNotification( ApplicationFacade.SET_XML_PRESENTATION, editor.xmlPresentation );
		}

		private function vdomObjectVOChangedHandler( event : EditorEvent ) : void
		{
			if ( editor.editorVO.vdomObjectVO )
				sendNotification( ApplicationFacade.GET_WYSIWYG, editor.editorVO.vdomObjectVO );
		}

		private function renderer_createdHandler( event : RendererEvent ) : void
		{
			sendNotification( ApplicationFacade.RENDERER_CREATED, event.target as IRenderer );
		}

		private function renderer_removedHandler( event : RendererEvent ) : void
		{
			sendNotification( ApplicationFacade.RENDERER_REMOVED, event.target as IRenderer );
		}

		private function renderer_clickedHandler( event : RendererEvent ) : void
		{
			sendNotification( ApplicationFacade.RENDERER_CLICKED, event.target as IRenderer );
		}

		private function renderer_getResourseHandler( event : RendererEvent ) : void
		{
			sendNotification( ApplicationFacade.GET_RESOURCE_REQUEST, event.object );
		}

		private function renderer_dropHandler( event : RendererDropEvent ) : void
		{
			sendNotification( ApplicationFacade.CREATE_OBJECT_REQUEST, { vdomObjectVO: ( event.target as IRenderer ).vdomObjectVO, typeVO: event.typeVO, point: event.point } )
		}

		private function rendererTransformedHandler( event : EditorEvent ) : void
		{
			var attributeVO : AttributeVO;
			var attributeName : String;
			var attributeValue : String;

			var attributes : Array = [];
			var vdomObjectAttributesVO : VdomObjectAttributesVO = new VdomObjectAttributesVO( event.renderer.vdomObjectVO );

			for ( attributeName in event.attributes )
			{
				if ( attributeName == "x" )
				{
					attributeValue = event.attributes[ attributeName ];
					attributeName = "left";
				}
				else if ( attributeName == "y" )
				{
					attributeValue = event.attributes[ attributeName ];
					attributeName = "top"
				}
				else
				{
					attributeValue = event.attributes[ attributeName ];
				}

				attributeVO = new AttributeVO( attributeName );
				attributeVO.value = attributeValue;

				attributes.push( attributeVO );
			}

			vdomObjectAttributesVO.attributes = attributes;

			sendNotification( ApplicationFacade.RENDERER_TRANSFORMED, vdomObjectAttributesVO );
		}

		private function attributesChangeHandler( event : EditorEvent ) : void
		{

			sendNotification( ApplicationFacade.SAVE_ATTRIBUTES_REQUEST, event.vdomObjectAttributesVO );
		}
	}
}
