//------------------------------------------------------------------------------
//
//   Copyright 2011 
//   VDOMBOX Resaerch  
//   All rights reserved. 
//
//------------------------------------------------------------------------------

package net.vdombox.ide.modules.wysiwyg.model
{
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	
	import mx.core.IUIComponent;
	
	import net.vdombox.ide.common.interfaces.IVDOMObjectVO;
	import net.vdombox.ide.common.model.TypesProxy;
	import net.vdombox.ide.common.model._vo.AttributeVO;
	import net.vdombox.ide.common.model._vo.ObjectVO;
	import net.vdombox.ide.common.model._vo.PageVO;
	import net.vdombox.ide.common.model._vo.TypeVO;
	import net.vdombox.ide.modules.wysiwyg.events.RendererEvent;
	import net.vdombox.ide.modules.wysiwyg.interfaces.IRenderer;
	import net.vdombox.ide.modules.wysiwyg.model.vo.RenderVO;
	import net.vdombox.ide.modules.wysiwyg.view.components.PageRenderer;
	import net.vdombox.ide.modules.wysiwyg.view.components.RendererBase;
	
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;
	
	import spark.components.IItemRenderer;

	/**
	 *
	 * @author andreev ap
	 */
	public class RenderProxy extends Proxy implements IProxy
	{
		/**
		 *
		 * @default
		 */
		public static const NAME : String = "RenderProxy";
		
		private var vdomObjectsName : Dictionary = new Dictionary(true);

		/**
		 *
		 */
		public function RenderProxy()
		{
			super( NAME );
		}

		private var _renderersIndex : Object;

		private var typesProxy : TypesProxy;

		/**
		 *
		 * @param renderer
		 */
		public function addRenderer( renderer : IRenderer ) : void
		{
			IEventDispatcher( renderer ).addEventListener( RendererEvent.RENDER_CHANGED, renderer_renderchangedHandler, false, 0, true );
			IEventDispatcher( renderer ).addEventListener( RendererEvent.RENDER_CHANGING, renderer_renderchangingHandler, false, 0, true );

			var visibleRendererProxy : VisibleRendererProxy = facade.retrieveProxy( VisibleRendererProxy.NAME ) as VisibleRendererProxy;
			
			
			//TODO: rewrite
			if ( !(renderer is PageRenderer) )
			{
				var visible : Boolean = visibleRendererProxy.getVisible(  renderer.vdomObjectVO.id );
				
				IUIComponent(renderer).visible = visible;
			}
			
			var renderVO : RenderVO = renderer.renderVO;

			if ( renderVO && renderVO.vdomObjectVO )
			{ 
				var objectID : String = renderVO.vdomObjectVO.id;
				
				if ( !renderersIndex.hasOwnProperty( objectID ) )
					renderersIndex[ objectID ] = [];

				renderersIndex[ objectID ].push( renderer );

				if ( vdomObjectsName[ objectID ] )
					renderVO.vdomObjectVO.name = vdomObjectsName[ objectID ];
			}
		}

		/**
		 *
		 */
		public function cleanup() : void
		{
			renderersIndex = null;
			data = null;
		}

		/**
		 *
		 * @param vdomObjectVO
		 * @param rawRenderData
		 * @return
		 */
		public function generateRenderVO( vdomObjectVO : IVDOMObjectVO, rawRenderData /*is Wysiwyg*/ : XML ) : RenderVO
		{
			var itemID : String;
			var renderVO : RenderVO;

			if ( !rawRenderData )
			{
				trace( "\n*************ERROR****************** \n generateRenderVO() - RenderProxy" );
				return renderVO;
			}

			itemID = rawRenderData.@id;
			
			renderVO = new RenderVO( vdomObjectVO );
			
			var rendererBase : RendererBase = getRendererByVO( vdomObjectVO );
			if ( rendererBase )
				renderVO.parent = rendererBase.renderVO.parent;

			createAttributes( renderVO, rawRenderData );
			createChildren( renderVO, rawRenderData );

			return renderVO;
		}

		/**
		 *
		 * @param vdomObjectVO
		 * @return
		 */
		public function getRenderersByVO( vdomObjectVO : IVDOMObjectVO ) : Array
		{
			return vdomObjectVO ? renderersIndex[ vdomObjectVO.id ] : [null];
		}
		
		public function getRendererByVO( vdomObjectVO : IVDOMObjectVO ) : RendererBase
		{
			// ???
			return getRendererByID( vdomObjectVO.id )
			
		}
		
		public function getRendererByID( ID : String ) : RendererBase
		{
			var rendererBase : RendererBase = null;
			
			if ( renderersIndex[ ID ] && renderersIndex[ ID  ][0] )
				rendererBase = renderersIndex[ID ][0];
			
			return rendererBase;
		}
		
		public function setNormalScinToRenderers() : void
		{
			for each( var object : Array in renderersIndex )
			{
				if ( object.length > 0 )
					object[0].setState = "normal";
			}
		}
		
		public function setVisibleRenderer( rendererID : String, flag : Boolean ) : void
		{
			
			var _renderer : RendererBase = getRendererByID( rendererID );
			
			if ( _renderer )
				_renderer.visible = flag;
		}
		

		override public function onRegister() : void
		{
			typesProxy = facade.retrieveProxy( TypesProxy.NAME ) as TypesProxy;
		}

		override public function onRemove() : void
		{
			typesProxy = null;
			cleanup();
		}

		/**
		 *
		 * @param renderer
		 */
		public function removeRenderer( renderer : IRenderer ) : void
		{
			var renderVO : RenderVO = IItemRenderer( renderer ).data as RenderVO;

			if ( renderVO && renderVO.vdomObjectVO && renderersIndex.hasOwnProperty( renderVO.vdomObjectVO.id ) )
			{
				var index : int = renderersIndex[ renderVO.vdomObjectVO.id ].indexOf( renderer );

				if ( index != -1 )
				{
					renderersIndex[ renderVO.vdomObjectVO.id ].splice( index, 1 );
					trace("Delete");
				}
			}

			IEventDispatcher( renderer ).removeEventListener( RendererEvent.RENDER_CHANGED, renderer_renderchangedHandler );
			IEventDispatcher( renderer ).removeEventListener( RendererEvent.RENDER_CHANGING, renderer_renderchangingHandler );
			
		}
		

		/**
		 *
		 * @param renderVO
		 * @param rawRenderData
		 *
		 *  Creating standart and selfs atributes
		 */
		private function createAttributes( renderVO : RenderVO, rawRenderData /*is Wysiwyg*/ : XML ) : void
		{
			var typeVO : TypeVO;

			renderVO.name = rawRenderData.name()

			renderVO.visible = rawRenderData.@visible == 1 ? true : false;

			renderVO.zindex = uint( rawRenderData.@zindex );
			renderVO.hierarchy = uint( rawRenderData.@hierarchy );
			renderVO.order = uint( rawRenderData.@order );

			renderVO.staticFlag = rawRenderData.@contents == "static" ? true : false;

			delete rawRenderData.@id;
			delete rawRenderData.@zindex;
			delete rawRenderData.@hierarchy;
			delete rawRenderData.@order;
			delete rawRenderData.@visible;
			delete rawRenderData.@typeID;
			delete rawRenderData.@contents;

			var attribute : XML;
			var attributeVO : AttributeVO;

			var attributesList : XMLList = rawRenderData.attributes();

			if ( attributesList && attributesList.length() > 0 )
			{
				renderVO.attributes = [];

				for each ( attribute in attributesList )
				{
					attributeVO = new AttributeVO( attribute.name(), attribute[ 0 ] );
					renderVO.attributes.push( attributeVO );
				}
			}
		}

		private function createChildren( renderVO : RenderVO, rawRenderData /*is Wysiwyg*/ : XML ) : void
		{
			
			if ( renderVO.vdomObjectVO.id == "1e0680bc-e2b1-404c-adb9-14481f171cbc" )
				trace("createChildren" );
			var pageVO : PageVO = renderVO.vdomObjectVO is PageVO ? renderVO.vdomObjectVO as PageVO : ObjectVO( renderVO.vdomObjectVO ).pageVO;
			var objectVO : ObjectVO;

			var typeVO : TypeVO;
			var typeID : String;

			var childRenderVO : RenderVO;

			var childXML : XML;
			var childName : String;
			var childID : String;

			for each ( childXML in rawRenderData.* )
			{
				childName = childXML.name().toString();
				childID = childXML.@id;

				typeID = childXML.@typeID;

				typeVO = typesProxy.getTypeVObyID( typeID );

				if ( typeVO && ( childName == "container" || childName == "table" || childName == "row" || childName == "cell" ) )
				{
					if ( !childID || !typeVO )
						continue;

					objectVO = new ObjectVO( pageVO, typeVO );
					objectVO.setID( childID );
					//objectVO.name = childName;

					childRenderVO = new RenderVO( objectVO );

					createAttributes( childRenderVO, childXML );

					createChildren( childRenderVO, childXML );

					childRenderVO.parent = renderVO;

					if ( !renderVO.children )
						renderVO.children = [];


					renderVO.children.push( childRenderVO );
				}
				else
				{
					if ( !renderVO.content )
						renderVO.content = new XMLList();

					renderVO.content += childXML.copy();
				}
			}

			if ( renderVO.content && renderVO.content.length() > 0 )
			{
				var editableAttribute : XML;

				editableAttribute = renderVO.content.@ediatable[ 0 ];

				if ( !editableAttribute )
					editableAttribute = renderVO.content..@editable[ 0 ];

				if ( editableAttribute )
				{
					if ( !renderVO.attributes )
						renderVO.attributes = [];

					renderVO.attributes.push( new AttributeVO( "editable", editableAttribute ) );
				}
			}
		}

		private function renderer_renderchangedHandler( event : RendererEvent ) : void
		{
			var renderer : IRenderer = event.currentTarget as IRenderer;

			if ( !renderer || !renderer.vdomObjectVO )
				return;

			addRenderer( renderer );
		}

		private function renderer_renderchangingHandler( event : RendererEvent ) : void
		{
			var renderer : IRenderer = event.currentTarget as IRenderer;
			var renderers : Array;

			if ( renderer.vdomObjectVO && renderersIndex.hasOwnProperty( renderer.vdomObjectVO.id ) )
				renderers = renderersIndex[ renderer.vdomObjectVO.id ];

			var index : int = -1;

			if ( renderers && renderers.length > 0 )
				index = renderers.indexOf( renderer );
			else
				return;

			if ( index != -1 )
				renderers.splice( index, 1 );

			if ( renderers.length == 0 )
				delete renderersIndex[ renderer.vdomObjectVO.id ];

		}

//		var dic : Dictionary
		private function get renderersIndex() : Object
		{
			if ( !_renderersIndex )
				_renderersIndex = {};

			return _renderersIndex;
		}

		private function set renderersIndex( value : Object ) : void
		{
			_renderersIndex = value;
		}
		
		public function setToolTipRenderers( pageXMLTree : XML ) : void
		{
			var xmlList : XMLList = pageXMLTree..object;
			var xmlObject : XML;

			for each ( xmlObject in xmlList )
			{
				var objectID : String = xmlObject.@id;
				var name : String = xmlObject.@name;
				var renderer :RendererBase = getRendererByID(  objectID );
				
				if ( renderer ) 
					renderer.renderVO.vdomObjectVO.name = name;
				else
					vdomObjectsName[objectID] = name;
			}
		}
	}
}
