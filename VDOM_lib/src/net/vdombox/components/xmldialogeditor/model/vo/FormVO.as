package net.vdombox.components.xmldialogeditor.model.vo
{
	import mx.collections.ArrayCollection;
	
	import net.vdombox.components.xmldialogeditor.utils.VersionUtil;
	import net.vdombox.components.xmldialogeditor.model.vo.attributes.AttributeStringVO;
	import net.vdombox.components.xmldialogeditor.model.vo.components.ContainerVO;
	import net.vdombox.components.xmldialogeditor.model.vo.components.base.ComponentBase;

	public class FormVO extends ComponentBase
	{
		private var _version : String;
		private var _title : AttributeStringVO;
		private var _width : AttributeStringVO;
		private var _height : AttributeStringVO;
		private var _container : ContainerVO;
		
		public function FormVO( value : XML = null )
		{
			super( value );

			buildForm( value );
		}
		
		
		private function buildForm( value : XML ) : void
		{
			if ( value && value.@version[0] )
				version = value.@version;
			else
				version = VersionUtil.defaultVersion;
			
			if ( value && value.hasOwnProperty( "Properties" ) )
			{
				var prop : XMLList = value.Properties[0].children();
				
				for each ( var property : XML in prop )
				{
					var name : String = property.@name[0];
					
					switch(name)
					{
						case "title":
						{
							title = new AttributeStringVO( name, property.toString() );
							break;
						}
							
						case "width":
						{
							width = new AttributeStringVO( name, property.toString() );
							break;
						}
							
						case "height":
						{
							height = new AttributeStringVO( name, property.toString() );
							break;
						}
							
						default:
						{
							break;
						}
					}
				}
			}
			
			if( !title )
				title = new AttributeStringVO( "title", "From1" );
			
			if ( !width )
				width = new AttributeStringVO( "width", '400' );
			
			if ( !height )
				height = new AttributeStringVO( "height", '500' );
			
			if ( !value )
				container = new ContainerVO();
		}

		public function get version():String
		{
			return _version;
		}

		public function set version(value:String):void
		{
			_version = value;
		}

		[Bindable]
		public function get title():AttributeStringVO
		{
			return _title;
		}

		public function set title(value:AttributeStringVO):void
		{
			_title = value;
		}

		public function get width():AttributeStringVO
		{
			return _width;
		}

		public function set width(value:AttributeStringVO):void
		{
			_width = value;
		}

		public function get height():AttributeStringVO
		{
			return _height;
		}

		public function set height(value:AttributeStringVO):void
		{
			_height = value;
		}

		public function get container():ContainerVO
		{
			return _container;
		}

		public function set container(value:ContainerVO):void
		{
			_container = value;
		}

		public override function get attributes() : ArrayCollection
		{
			var _attributes : ArrayCollection = new ArrayCollection();
			
			_attributes.addItem( title );
			_attributes.addItem( width );
			_attributes.addItem( height );
			_attributes.addAll( container.attributes );
			
			return _attributes;
		}
		
		public override function toXML() : XML
		{
			var xml : XML = new XML();
			xml = <XMLDialog>
				
			<Properties>
				<Property name="title">{ title.value }</Property>
				<Property name="width">{ width.value }</Property>
				<Property name="height">{ height.value }</Property>
			</Properties>

			</XMLDialog>;
			
			xml.@version = version;
			
			xml.appendChild( container.toXML() );
			
			return xml;
		}
	}
}