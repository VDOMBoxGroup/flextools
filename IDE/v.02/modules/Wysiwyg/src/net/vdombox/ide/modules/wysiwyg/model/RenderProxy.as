package net.vdombox.ide.modules.wysiwyg.model
{
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	
	import mx.collections.XMLListCollection;
	
	import net.vdombox.ide.common.interfaces.IVDOMObjectVO;
	import net.vdombox.ide.common.vo.AttributeVO;
	import net.vdombox.ide.common.vo.ObjectVO;
	import net.vdombox.ide.common.vo.PageVO;
	import net.vdombox.ide.common.vo.TypeVO;
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	import net.vdombox.ide.modules.wysiwyg.interfaces.IRenderer;
	import net.vdombox.ide.modules.wysiwyg.model.vo.RenderVO;
	
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;
	
	import spark.components.IItemRenderer;

	public class RenderProxy extends Proxy implements IProxy
	{
		public static const NAME : String = "RenderProxy";

		public function RenderProxy()
		{
			super( NAME );
		}

		private var typesProxy : TypesProxy;

		private var rendererIndex : Object;

		override public function onRegister() : void
		{
			typesProxy = facade.retrieveProxy( TypesProxy.NAME ) as TypesProxy;
			rendererIndex = {};
		}

		override public function onRemove() : void
		{
			typesProxy = null;
			rendererIndex = null;
		}

		public function addRenderer( renderer : IRenderer ) : void
		{
			IEventDispatcher( renderer ).addEventListener( Event.CHANGE, renderer_changeHandler, false, 0, true );

			var renderVO : RenderVO = IItemRenderer( renderer ).data as RenderVO;

			if ( renderVO && renderVO.vdomObjectVO )
			{
				if ( !rendererIndex.hasOwnProperty( renderVO.vdomObjectVO.id ) )
					rendererIndex[ renderVO.vdomObjectVO.id ] = [];

				rendererIndex[ renderVO.vdomObjectVO.id ].push( renderer );
			}
		}

		public function removeRenderer( renderer : IRenderer ) : void
		{
			var renderVO : RenderVO = IItemRenderer( renderer ).data as RenderVO;

			if ( renderVO && renderVO.vdomObjectVO && rendererIndex.hasOwnProperty( renderVO.vdomObjectVO.id ) )
			{
				var index : int = rendererIndex[ renderVO.vdomObjectVO.id ].indexOf( renderer );

				if ( index != -1 )
					rendererIndex[ renderVO.vdomObjectVO.id ].splice( index, 1 );
			}

			IEventDispatcher( renderer ).removeEventListener( Event.CHANGE, renderer_changeHandler );
		}

		public function getRenderersByVO( vdomObjectVO : IVDOMObjectVO ) : Array
		{
			return vdomObjectVO ? rendererIndex[ vdomObjectVO.id ] : null;
		}

		public function generateRenderVO( vdomObjectVO : IVDOMObjectVO, rawRenderData : XML ) : RenderVO
		{
			var itemID : String = rawRenderData.@id;
			var renderVO : RenderVO;

//			renderVO = renderVOCache[ itemID ] ? renderVOCache[ itemID ] : new RenderVO( vdomObjectVO );
			
			renderVO =  new RenderVO( vdomObjectVO );

			createAttributes( renderVO, rawRenderData );
			createChildren( renderVO, rawRenderData );

			return renderVO;
		}

		private function createAttributes( renderVO : RenderVO, rawRenderData : XML ) : void
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

		private function createChildren( renderVO : RenderVO, rawRenderData : XML ) : void
		{
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
				childName = childXML.name();
				childID = childXML.@id;

				typeID = childXML.@typeID;

				if ( childName == "container" || childName == "table" || childName == "row" || childName == "cell" )
				{

					typeVO = typesProxy.getTypeVObyID( typeID );

					if ( !childID || !typeVO )
						continue;

					objectVO = new ObjectVO( pageVO, typeVO );
					objectVO.setID( childID );
					objectVO.name = childName;
					
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
						renderVO.content = new XMLList( childXML.copy() );
					else
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

		private function renderer_changeHandler( event : Event ) : void
		{

		}
	}
}